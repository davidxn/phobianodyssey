class FriendlyUIHandler : EventHandler
{
	const UI_WIDTH = 400;
	const UI_HEIGHT = 300;
	const UI_SHADE_ALPHA = 0.5;

	// % vertical space between lines of dialogFont
	const DIALOG_VSPACE = 0.05;

	// mouse movement will be multiplied by this
	const MOUSE_SENSITIVITY_FACTOR_X = 0.6;
    const MOUSE_SENSITIVITY_FACTOR_Y = 1.9;
	
	ui bool initialized;
    
	// drawing
	ui transient Font tinyFont;
	ui transient Font journalFont;
	ui TextureID blackGradTex;
	ui TextureID invBGFrame;
    ui TextureID invBGClosedFrame;
	ui TextureID invItemBG;
	ui TextureID invHilight;
	ui TextureID mouseMiniCursorTex;
    ui TextureID dialogBackFrame;
	
    // input handling
	ui Vector2 mouseCursorPos;
	
    // inventory screen
	ui int hoveredInvStack;
	ui MFInventoryItem uiGrabbedItem;
	play MFInventoryItem newGrabbedItem;
	play bool shouldClearUIGrabbedItem;
	ui bool hoveringDropButton;
    
    ui double dialogOpacity;
    ui double textPercentDisplayed;

	// inventory boxes
	const INV_STACK_BUTTON_START_X = 0.095;
	const INV_STACK_BUTTON_START_Y = 0.72;
	const INV_STACK_BUTTON_WIDTH = 0.08;
	const INV_STACK_BUTTON_HEIGHT = 0.1;
	const INV_STACK_BUTTON_MARGIN = 0.01;
	const INV_STACK_BUTTON_MARGIN_INNERPCT = 0.25;
	const INV_STACK_BUTTON_ROWS = 4;
	const INV_STACK_BUTTON_COLUMNS = 4;

	// drop button
	const INV_DROP_BUTTON_X = 0.335;
	const INV_DROP_BUTTON_Y = 0.865;
	const INV_DROP_BUTTON_WIDTH = 0.08;
	const INV_DROP_BUTTON_HEIGHT = 0.1;
    
    // Weapon boxes
    const WEAPON_START_X = 0.49;
    const WEAPON_START_Y = 0.886;
    const WEAPON_WIDTH = 0.053;
	
    ui void DrawDialog()
    {
        if (DataLibrary.GetInstance().dic.At("shouldHideDialog").ToInt() == 1) { dialogOpacity = 0; DataLibrary.GetInstance().dic.Insert("shouldHideDialog", "0"); }
        if (DataLibrary.GetInstance().dic.At("shouldEraseText").ToInt() == 1) { textPercentDisplayed = 0; DataLibrary.GetInstance().dic.Insert("shouldEraseText", "0"); }
        
        if (dialogOpacity < 1.0) dialogOpacity += 0.01;
        ScreenDrawTexture(dialogBackFrame, 0.5, 0.75, alpha: dialogOpacity, centerX: true, centerY: true);
        

        
        String eventDialogConversation = DataLibrary.GetInstance().dic.At("eventDialogConversation");
        int eventDialogPage = DataLibrary.GetInstance().dic.At("eventDialogPage").ToInt();
        String s = StringTable.Localize("$CONV_" .. eventDialogConversation .. "_" .. eventDialogPage);
        
        if (s.IndexOf("$chestitem$") > 0) {
            POChest chest = DataLibrary.GetInstance().chestToOpen;
            if (!chest.containedItem) {
                //No item - check for coins or ammo instead
                if (chest.containedCoins) {
                    s.Substitute("$chestitem$", (chest.containedCoins .. " coins"));
                }
                if (chest.containedAmmo) {
                    String ammoType = "bullets";
                    switch (chest.containedAmmoType) {
                        case 2: ammoType = "shells"; break;
                        case 3: ammoType = "rockets"; break;
                        case 4: ammoType = "plasma cells"; break;
                    }
                    s.Substitute("$chestitem$", (chest.containedAmmo .. " " .. ammoType));
                }
            } else {
                ScreenDrawTextureWithinArea(chest.containedItem.getTexture(), 0.5, 0.2, 0.3, 0.3, alpha:dialogOpacity, centerX:true);
                s.Substitute("$chestitem$", "the " .. chest.containedItem.getName());
            }
        }
        
        //Don't actually do anything with the string until dialog opacity is 1.0
        if (dialogOpacity < 1.0) {
            return;
        }
        
        ScreenDrawString(s, Font.CR_WHITE, journalFont, 0.145, 0.56, wrapWidth: 0.7, displayPercent: textPercentDisplayed);
        if (textPercentDisplayed < 1.0) textPercentDisplayed += 0.005;
        DrawMouseCursor();
        return;
    }
    
	ui void DrawInvScreen()
	{
        //TODO Alter this for expanding inventory
		ScreenDrawTexture(invBGFrame, 0, 0, alpha: 0.9);
		// draw stack buttons
		double x = INV_STACK_BUTTON_START_X;
		double y = INV_STACK_BUTTON_START_Y;
		// get mouse coordinates in % based numbers used by drawers
		Vector2 mv = RealToVirtual(mouseCursorPos);
		mv.x /= UI_WIDTH;
		mv.y /= UI_HEIGHT;
		int stackNum = 0;
		bool wasHovering = hoveredInvStack >= 0;
		hoveredInvStack = -1;
        
		for ( int row = 0; row < INV_STACK_BUTTON_ROWS; row++ )
		{
			if ( stackNum >= DataLibrary.GetInstance().MFinventory.Size() )
				break;
			for ( int col = 0; col < INV_STACK_BUTTON_COLUMNS; col++ )
			{
				if ( stackNum >= DataLibrary.GetInstance().MFinventory.Size() )
					break;
				// get whether mouse is within this button
				bool hovering = mv.x >= x && mv.x <= x + INV_STACK_BUTTON_WIDTH && mv.y >= y && mv.y <= y + INV_STACK_BUTTON_HEIGHT;
				// Draw background box
				ScreenDrawTexture(invItemBG, x, y, alpha: 0.5);
				if ( hovering ) {
					if ( !(wasHovering) ) EventHandler.SendNetworkEvent("UIStartHover");
					// hilight box
					ScreenDrawTexture(invHilight, x, y);
					hoveredInvStack = stackNum;
				}
				// draw item sprite & quantity
				// scale and center icon in box regardless of original size
				// (GetSpriteTexture has a scale param that might be useful)
				MFInventoryItem item = DataLibrary.GetInstance().MFinventory[stackNum];
				ScreenDrawTextureWithinArea(item.getTexture(), x, y,
											INV_STACK_BUTTON_WIDTH,
											INV_STACK_BUTTON_HEIGHT,
											INV_STACK_BUTTON_MARGIN_INNERPCT);
				// next item
				x += INV_STACK_BUTTON_WIDTH + INV_STACK_BUTTON_MARGIN;
				stackNum++;
			}
			x = INV_STACK_BUTTON_START_X;
			y += INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN;
		}

		hoveringDropButton = mv.x >= INV_DROP_BUTTON_X && mv.x <= INV_DROP_BUTTON_X + INV_DROP_BUTTON_WIDTH && mv.y >= INV_DROP_BUTTON_Y && mv.y <= INV_DROP_BUTTON_Y + INV_DROP_BUTTON_HEIGHT;

        DrawMouseCursor();
        return;
	}
	
	ui void InitFonts()
	{
		tinyFont = Font.GetFont("fonts/jimmy_tinyfont.lmp");
		journalFont = Font.GetFont("fonts/jimmy_APOS_BOK.lmp");
	}
	
	ui void Init()
	{
		initialized = true;
		InitFonts();
		blackGradTex = TexMan.CheckForTexture("blkgrad", 0);
		invBGFrame = TexMan.CheckForTexture("invbg", 0);
        invBGClosedFrame = TexMan.CheckForTexture("invbgcl", 0);
		invItemBG = TexMan.CheckForTexture("invitmbg", 0);
		invHilight = TexMan.CheckForTexture("invsel", 0);

        dialogBackFrame = TexMan.CheckForTexture("DIALBACK", 0);

		mouseMiniCursorTex = TexMan.CheckForTexture("invcurs", 0);
		mouseCursorPos = (UI_WIDTH/2, UI_HEIGHT/2);

		hoveredInvStack = -1;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
        PlayerPawn p = PlayerPawn(players[e.Player].mo);

        if ( e.Name == "ClearNewGrabbedItem" ) { newGrabbedItem = NULL; }
		else if ( e.Name == "ClearedUIGrabbedItem" ) { shouldClearUIGrabbedItem = false; }
        else if ( e.Name == "BinItem" ) { p.A_PlaySound("po/inventory/bin", CHAN_VOICE); }
		else if ( e.Name == "ClickedInvStack" )
		{
			int stackIndex = e.Args[0];
			MFInventoryItem invItem = DataLibrary.GetInstance().MFinventory[stackIndex];

            //If we don't have a grabbed item and this is not empty, grab this one
			if ( !(newGrabbedItem) )
			{
                if (invItem.getClassName() != "MFIEmpty") {
                    //console.printf("DEBUG: Grabbed item %s from %d without replacing", invItem.getClassName(), stackIndex);
                    newGrabbedItem = invItem;
                    DataLibrary.GetInstance().InventoryRemove(stackIndex);
                    p.A_PlaySound("po/inventory/up", CHAN_VOICE);
                }
			}
			//If we do have a grabbed item, put it there. If we have an item in there already, it becomes the new grabbed item
			else
			{
                //console.printf("DEBUG: We have an already-grabbed item %s", newGrabbedItem.getClassName());
				MFInventoryItem itemToGrab = (invItem.getClassName() == "MFIEmpty" ? NULL : invItem);
                if (!itemToGrab) {
                    //console.printf("DEBUG: No item already there in slot %d", stackIndex);
                    shouldClearUIGrabbedItem = true;
                } else {
                    //console.printf("DEBUG: Replacing with %s in slot %d", newGrabbedItem.getClassName(), stackIndex);
                }
                DataLibrary.GetInstance().InventoryAdd(newGrabbedItem.getClassName(), stackIndex);
				p.A_PlaySound("po/inventory/down", CHAN_VOICE);
                newGrabbedItem = itemToGrab;
                
			}
		}
        else if ( e.Name == "RightClickedInvStack" )
        {
            int stackIndex = e.Args[0];
            MFInventoryItem invItem = DataLibrary.GetInstance().MFinventory[stackIndex];
            bool success = invItem.use();
            if (success) {
                DataLibrary.GetInstance().InventoryRemove(stackIndex);            
            } else {
                p.A_PlaySound("po/deny");
            }
        }
        else if ( e.Name == "ClickedPastDialog" ) {
            //Advance the conversation
            int eventDialogPage = DataLibrary.ReadInt("eventDialogPage") + 1;
            String eventDialogConversation = DataLibrary.GetInstance().dic.At("eventDialogConversation");
            String dialogKey = "$CONV_" .. eventDialogConversation .. "_" .. eventDialogPage;
            String theString = StringTable.Localize(dialogKey);
            DataLibrary.GetInstance().dic.Insert("shouldEraseText", "1");
            
            if (eventDialogConversation == "OPEN_MAINDOOR" && eventDialogPage == 4) {
                console.printf("------------------------------------------------------------------------");
                console.printf("    ____  __          __    _            "); //Trust me
                console.printf("   / __ \\/ /_  ____  / /_  (_)___ _____  ");
                console.printf("  / /_/ / __ \\/ __ \\/ __ \\/ / __ `/ __ \\ ");
                console.printf(" / ____/ / / / /_/ / /_/ / / /_/ / / / / ");
                console.printf("/_/___/_/ /_/\\____/_.___/_/\\__,_/_/ /_/  ");
                console.printf("  / __ \\____/ /_  _______________  __  __");
                console.printf(" / / / / __  / / / / ___/ ___/ _ \\/ / / /");
                console.printf("/ /_/ / /_/ / /_/ (__  |__  )  __/ /_/ / ");
                console.printf("\\____/\\__,_/\\__, /____/____/\\___/\\__, /  ");
                console.printf("           /____/               /____/   ");
                console.printf("------------------------------------------------------------------------");
                console.printf("That's the end of the Phobian Odyssey demo so far.");
                console.printf("Thanks for giving it a try - more dungeon crawling will be coming later!");
                console.printf("------------------------------------------------------------------------");
                DataLibrary y = DataLibrary.GetInstance();
                y = null;
                let x = y.getClassName();
            }
            
            if (theString == "STOP") {
                DataLibrary.GetInstance().dic.Insert("shouldHideDialog", "1");
                DataLibrary.WriteData(NULL, "showEventDialog", "0");
                DataLibrary.WriteData(NULL, "eventDialogPage", "");
                DataLibrary.WriteData(NULL, "eventDialogConversation", "");
            }
            else {
                DataLibrary.WriteData(NULL, "eventDialogPage", eventDialogPage .. "");
            }
        }
		else if ( e.Name == "UIStartHover" )
		{
			p.A_PlaySound("UIHover", CHAN_VOICE);
		}
		else if ( e.Name == "UINegativeFeedback" )
		{
			p.A_PlaySound("po/deny");
		}
	}
	
	override bool InputProcess(InputEvent e)
	{
        let dl = DataLibrary.GetInstance();
        if (!dl) {
            return false;
        }
        bool showInvScreen = (DataLibrary.GetInstance().dic.At("showInvScreen") == "1");
        bool showEventDialog = (DataLibrary.GetInstance().dic.At("showEventDialog") == "1");
		if ( !initialized ) return false;
		if ( automapactive ) return false;
		if ( !showInvScreen && !showEventDialog ) return false;
		// get binds for left/right movement so we can check em on quest screen
		int leftBind, rightBind, i;
		[leftBind, i] = Bindings.GetKeysForCommand("+moveleft");
		[rightBind, i] = Bindings.GetKeysForCommand("+moveright");
		// play scope may tell us a new item has been grabbed

        if (showInvScreen) {
            if ( newGrabbedItem ) {	uiGrabbedItem = newGrabbedItem;	}

            if ( shouldClearUIGrabbedItem )
            {
                uiGrabbedItem = NULL;
                EventHandler.SendNetworkEvent("ClearNewGrabbedItem");
                EventHandler.SendNetworkEvent("ClearedUIGrabbedItem");
            }
            
            // grab mouse move & clicks for inventory cursor
            if ( e.Type == InputEvent.Type_Mouse )
            {
                mouseCursorPos.x += e.MouseX * MOUSE_SENSITIVITY_FACTOR_X;
                mouseCursorPos.y -= e.MouseY * MOUSE_SENSITIVITY_FACTOR_Y;
                // clamp within screen edges
                mouseCursorPos.x = max(0, min(Screen.GetWidth(), mouseCursorPos.x));
                mouseCursorPos.y = max(0, min(Screen.GetHeight(), mouseCursorPos.y));
            }
            else if ( e.Type == InputEvent.Type_KeyDown )
            {
                // handle mouse clicks
                if ( e.KeyScan == InputEvent.Key_Mouse1 )
                {
                    if ( hoveredInvStack != -1 ) { EventHandler.SendNetworkEvent("ClickedInvStack", hoveredInvStack); }
                    else if ( hoveringDropButton && uiGrabbedItem ) {
                        uiGrabbedItem = NULL;
                        EventHandler.SendNetworkEvent("ClearNewGrabbedItem");
                        EventHandler.SendNetworkEvent("ClearedUIGrabbedItem");
                        EventHandler.SendNetworkEvent("BinItem");                    
                    }
                    return true;
                }
                if ( e.KeyScan == InputEvent.Key_Mouse2 )
                {
                    if ( hoveredInvStack != -1 ) { EventHandler.SendNetworkEvent("RightClickedInvStack", hoveredInvStack); }
                    return true;
                }
                if (e.KeyScan >=2 && e.KeyScan <= 5) { //1 to 4, funnily enough
                    EventHandler.SendNetworkEvent("RightClickedInvStack", e.KeyScan-2);
                    return true;
                }
                return false;
            }

            // process keyup events else inputs active when screen invoked bleed & stay on
            else if ( e.Type == InputEvent.Type_KeyUp ) { return false; }
            return true;
        }
        
        if (showEventDialog) {
            // grab mouse move & clicks for inventory cursor
            if ( e.Type == InputEvent.Type_Mouse )
            {
                mouseCursorPos.x += e.MouseX * MOUSE_SENSITIVITY_FACTOR_X;
                mouseCursorPos.y -= e.MouseY * MOUSE_SENSITIVITY_FACTOR_Y;
                // clamp within screen edges
                mouseCursorPos.x = max(0, min(Screen.GetWidth(), mouseCursorPos.x));
                mouseCursorPos.y = max(0, min(Screen.GetHeight(), mouseCursorPos.y));
                return true;
            }
            else if ( e.Type == InputEvent.Type_KeyDown )
            {
                // handle mouse clicks
                if ( e.KeyScan == InputEvent.Key_Mouse1 )
                {
                    EventHandler.SendNetworkEvent("ClickedPastDialog");
                    return true;
                }
                return true;   
            }
            // process keyup events else inputs active when screen invoked bleed & stay on
            
            if ( e.Type == InputEvent.Type_KeyUp ) { return false; }
            return true;
        }
        
        return false;

	}
	
	override void RenderOverlay(RenderEvent e)
	{
		// fonts must be transient; if we're loading a savegame they'll be null so reinit
		if ( !initialized ) Init();
		if ( !(tinyFont) ) InitFonts();
        
        //Always draw the weapon slots
        double weaponX = WEAPON_START_X;
        double weaponY = WEAPON_START_Y;
        
        for (int i = 0; i < 5; i++) {
            POWeaponSlot w = DataLibrary.getWeaponSlot(i);
            if (w) {
                ScreenDrawTexture(w.getTexture(), weaponX, weaponY);
            }
            weaponX += WEAPON_WIDTH;
        }
        
        //Then do the rest conditionally
		if ( automapactive ) return;
		if ( DataLibrary.GetInstance().dic.At("showInvScreen") == "1" ) {
			DrawInvScreen();
		} else {
            //Draw closed inventory on status bar
            ScreenDrawTexture(invBGClosedFrame, 0, 0, alpha: 0.9);
        }
        if ( DataLibrary.GetInstance().dic.At("showEventDialog") == "1" ) {
            DataLibrary.GetInstance().dic.Insert("showInvScreen", "0");
            DrawDialog();
        } else {
            dialogOpacity = 0;
        }
	}
    
    ///////////////////////////////////
    
	ui void ScreenDrawString(String s, Color c, Font f, double pct_x, double pct_y, double lineHeight = DIALOG_VSPACE, double wrapWidth = 1.0, bool dropShadow = true, bool centerX = false, double centerYHeight = -1, double alpha = 1, double displayPercent = 1.0)
	{
		// thanks gwHero https://forum.zdoom.org/viewtopic.php?f=122&t=59381&p=1039574
		int x = int(pct_x * UI_WIDTH);
		int y = int(pct_y * UI_HEIGHT);
		// center vertically within given height
		if ( centerYHeight > 0 )
			y += (centerYHeight * UI_HEIGHT) / 2 - (lineHeight * UI_HEIGHT) / 2;
		// split strings separated by \n into multiple lines
		Array<String> lines;
		s.Split(lines, "\n");
        
        int totalCharacterCount = 0;
        Array<String> dLines;
        //Let's work out our total number of lines and characters first
		for ( int i = 0; i < lines.Size(); i++ )
		{
			BrokenLines blines = f.BreakLines(lines[i], int(wrapWidth * UI_WIDTH));
			for ( int n = 0; n < blines.Count(); n++ )
            {
                String plainText = bLines.StringAt(n);
                dLines.push(plainText);
                totalCharacterCount += plainText.Length();
            }
        }
        
        //Now write each line until we exceed our limit
        int charactersDisplayed = 0;
        int charactersToDisplay = int(totalCharacterCount * displayPercent);
        for (int i = 0; i < dLines.Size(); i++)
		{
            String textToDisplay = dlines[i];
            //If the characters already displayed total above our display target, we can break
            if (charactersDisplayed >= charactersToDisplay) { break; }

            // If the target would be hit by drawing this line, we have to truncate
            if (charactersDisplayed + textToDisplay.Length() > charactersToDisplay) {
                int charactersToDisplayThisLine = (charactersToDisplay - charactersDisplayed);
                textToDisplay = textToDisplay.Left(charactersToDisplaythisLine);
            }
            // center wrapped line horizontally
            int x = int(pct_x * UI_WIDTH);
            if ( centerX )
                x -= f.StringWidth(textToDisplay) / 2;
            if ( dropShadow )
            {
                // line color codes will mess up shadow color, strip em
                String plainText = textToDisplay;
                plainText.Replace("\cg", "\cm");
                plainText.Replace("\ck", "\cm");
                plainText.Replace("\cd", "\cm");
                plainText.Replace("\cv", "\cm");
                plainText.Replace("\cl", "\cm");
                Screen.DrawText(f, Font.CR_BLACK, x + 1, y + 1,
                                plainText,
                                DTA_VirtualWidth, UI_WIDTH,
                                DTA_VirtualHeight, UI_HEIGHT,
                                DTA_Alpha, alpha);
            }
            // void DrawText(Font font, int normalcolor, double x, double y, String text, ...);
            Screen.DrawText(f, c, x, y, textToDisplay,
                            DTA_VirtualWidth, UI_WIDTH,
                            DTA_VirtualHeight, UI_HEIGHT,
                            DTA_Alpha, alpha);
            // between wrap-breaks and \n-breaks, don't carriage return twice
            if ( dLines.Size() > 1 ) { y += int(lineHeight * UI_HEIGHT); }
            charactersDisplayed += textToDisplay.Length();
        }
	}
	
	ui void ScreenDrawShadedBox(double pct_x, double pct_y, double pct_w, double pct_h)
	{
		int x = int(pct_x * UI_WIDTH);
		int y = int(pct_y * UI_HEIGHT);
		int w = int(pct_w * UI_WIDTH);
		int h = int(pct_h * UI_HEIGHT);
		// DrawTexture(TextureID tex, bool animate, double x, double y, ...);
		Screen.DrawTexture(blackGradTex, false, x, y,
						   DTA_DestWidth, w, DTA_DestHeight, h,
						   DTA_VirtualWidth, UI_WIDTH,
						   DTA_VirtualHeight, UI_HEIGHT,
						   DTA_Alpha, UI_SHADE_ALPHA);
	}
	
	ui Vector2 RealToVirtual(Vector2 r)
	{
		Vector2 v;
		double vw, vh, rw, rh;
		vw = UI_WIDTH;
		vh = UI_HEIGHT;
		rw = Screen.GetWidth();
		rh = Screen.GetHeight();
		double realAspect = rw / rh;
		double virtualAspect = vw / vh;
		// pillarbox: aspect correct X axis
		if ( realAspect > virtualAspect )
		{
			// offset for aspect
			// (TODO: below works for 16:9 and 16:10 *and* 17:10 @ 800x480,
			// but not 17:10 @ 1024x600... why?!?)
			double pillarWidth;
			pillarWidth = ((rw * vh) / rh) - vw;
			pillarWidth /= 2;
			double croppedRealWidth = (rh * vw) / vh;
			v.x = vw / croppedRealWidth * r.x;
			v.x -= pillarWidth;
			v.y = (vh / rh) * r.y;
		}
		// letterbox: aspect correct Y axis (eg 5:4)
		else if ( realAspect < virtualAspect )
		{
			v.x = (vw / rw) * r.x;
			double letterBoxHeight;
			letterBoxHeight = ((rh * vw) / rw) - vh;
			letterBoxHeight /= 2;
			double croppedRealHeight = (rw * vh) / vw;
			v.y = vh / croppedRealHeight * r.y;
			v.y -= letterBoxHeight;
		}
		else
		{
			v.x = (vw / rw) * r.x;
			v.y = (vh / rh) * r.y;
		}
		return v;
	}
	
	ui void ScreenDrawTextureWithinArea(TextureID tex, double pct_x, double pct_y, double areaW, double areaH, double marginPct = 0, double alpha = 1, bool aspectCorrect = true, bool centerX = false)
	{
		int ix = pct_x * UI_WIDTH;
		int iy = pct_y * UI_HEIGHT;
		int tw, th;
		[tw, th] = TexMan.GetSize(tex);
		// correct for Doom's nonsquare aspect
		double sqth;
		if ( aspectCorrect )
			sqth = double(th) * (1 + ((320.0 / 200) - (320.0 / 240)));
		else
			sqth = double(th);
		double w, h;
		// scale down to create margin around icon in button
		double marginScale = 1 - marginPct;
		// wide stuff: make shorter, skootch down
		if ( tw >= sqth )
		{
			w = (areaW * marginScale) * UI_WIDTH;
			h = (areaH * marginScale) * UI_HEIGHT / (double(tw) / sqth);
			double yOff = ((areaH * marginScale) * UI_HEIGHT) - h;
			iy += int(yOff / 2);
		}
		// tall stuff: make narrower, skootch right
		else
		{
			w = (areaW * marginScale) * UI_WIDTH * (double(tw) / sqth);
			double xOff = ((areaW * marginScale) * UI_WIDTH) - w;
			ix += int(xOff / 2);
			h = (areaH * marginScale) * UI_HEIGHT;
		}
		// offset for margin
		ix += areaW * ((1 - marginScale) / 2) * UI_WIDTH;
		iy += areaH * ((1 - marginScale) / 2) * UI_HEIGHT;
		if ( centerX )
			ix -= w / 2;
		Screen.DrawTexture(tex, true, ix, iy,
						   DTA_DestWidth, int(w), DTA_DestHeight, int(h),
						   DTA_VirtualWidth, UI_WIDTH,
						   DTA_VirtualHeight, UI_HEIGHT,
						   DTA_LeftOffset, 0,
						   DTA_TopOffset, 0,
						   DTA_Alpha, alpha);
	}
	
	ui void ScreenDrawTexture(TextureID tex, double pct_x, double pct_y, double scale = 1.0, double alpha = 1.0, bool centerX = false, bool centerY = false)
	{
		int x = int(pct_x * UI_WIDTH);
		int y = int(pct_y * UI_HEIGHT);
		// calculate size based on texture's scale
		int tw, th;
		[tw, th] = TexMan.GetSize(tex);
		int w = int(tw * scale);
		int h = int(th * scale);
		if ( centerX ) x -= w / 2;
		if ( centerY ) y -= h / 2;

		Screen.DrawTexture(tex, true, x, y, DTA_Alpha, alpha,
						   DTA_DestWidth, w, DTA_DestHeight, h,
						   DTA_VirtualWidth, UI_WIDTH,
						   DTA_VirtualHeight, UI_HEIGHT,
						   // ignore any sprite offsets, this is UI-land
						   DTA_LeftOffset, 0,
						   DTA_TopOffset, 0);
	}

    ui void DrawMouseCursor()
	{
		TextureID tex;
		Vector2 v = RealToVirtual(mouseCursorPos);
		double iconPadX = 0.01;
		double iconPadY = 0.01;
		double iconArea = 0.05;
		v.x /= UI_WIDTH;
		v.y /= UI_HEIGHT;
		Screen.DrawTexture(mouseMiniCursorTex, true,
						   mouseCursorPos.x, mouseCursorPos.y,
						   DTA_DestWidth, 24, DTA_DestHeight, 24);
        
        //The rest of this is only for the inventory screen
        if (DataLibrary.GetInstance().dic.At("showInvScreen") != "1") { return; }

        if (uiGrabbedItem) {
            ScreenDrawTextureWithinArea(uiGrabbedItem.getTexture(), v.x + iconPadX, v.y + iconPadY, iconArea, iconArea);
        }

		// tooltip-style text for grabbed / hovered item
		MFInventoryItem item;
		if ( uiGrabbedItem ) { item = uiGrabbedItem; }
		else if ( hoveredInvStack != -1 ) { item = DataLibrary.GetInstance().InventoryPeek(hoveredInvStack); }
		else return;
        
		String toolTipText = item.getName();
		double textMargin = -0.04;
		Screen.DrawText(tinyFont, Font.CR_LIGHTBLUE,
						(v.x + textMargin) * UI_WIDTH,
						(v.y + textMargin) * UI_HEIGHT,
						toolTipText,
						DTA_VirtualWidth, UI_WIDTH,
						DTA_VirtualHeight, UI_HEIGHT);
                        
		String descriptionText = StringTable.Localize("$INV_" .. item.getClassName());
        if ((descriptionText == "$INV_" .. item.getClassName()) || !descriptionText) {
            return;   
        }
        ScreenDrawString(descriptionText, Font.CR_WHITE, tinyFont, 0.5, 0.5, wrapWidth: 0.3);
	}
}
