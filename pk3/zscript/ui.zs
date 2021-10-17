class FriendlyUIHandler : EventHandler
{
	const UI_WIDTH = 400;
	const UI_HEIGHT = 300;
	const UI_SHADE_ALPHA = 0.5;

	// % vertical space between lines when drawing strings
	const DIALOG_VSPACE = 0.05;

	// mouse movement will be multiplied by this
	const MOUSE_SENSITIVITY_FACTOR_X = 0.6;
    const MOUSE_SENSITIVITY_FACTOR_Y = 1.9;

	ui bool initialized;

	// Fonts and textures
	ui transient Font tinyFont;
	ui transient Font journalFont;

	ui TextureID invBGFrame;
    ui TextureID invBGClosedFrame;
	ui TextureID invItemBG;
	ui TextureID invHilight;
	ui TextureID mouseMiniCursorTex;
    ui TextureID dialogBackFrame;
    ui TextureID blockMapFrame;
    ui TextureID weaponCursorTex;
    ui TextureID itemShopBG;

    // Mouse position
	ui Vector2 mouseCursorPos;

    // Inventory screen stuff
	ui int hoveredInvStack;
    ui int hoveredShopNumber;
	ui MFInventoryItem uiGrabbedItem;
	play MFInventoryItem newGrabbedItem;
    play bool grabbedItemIsFromShop;
	play bool shouldClearUIGrabbedItem;
	ui bool hoveringDropButton;
    ui bool hoveringOverShop;

    // Dialogue screen
    ui double dialogOpacity;
    ui double textPercentDisplayed;

	// Inventory measurements
	const INV_STACK_BUTTON_START_X = 0.095;
	const INV_STACK_BUTTON_START_Y = 0.72;
	const INV_STACK_BUTTON_WIDTH = 0.08;
	const INV_STACK_BUTTON_HEIGHT = 0.1;
	const INV_STACK_BUTTON_MARGIN = 0.01;
	const INV_STACK_BUTTON_MARGIN_INNERPCT = 0.25;
	const INV_STACK_BUTTON_ROWS = 4;
	const INV_STACK_BUTTON_COLUMNS = 4;

    // Item shop measurements
    const ITEM_SHOP_START_X = 0.51;
    const ITEM_SHOP_START_Y = 0.04;

	// Drop button
	const INV_DROP_BUTTON_X = 0.335;
	const INV_DROP_BUTTON_Y = 0.865;
	const INV_DROP_BUTTON_WIDTH = 0.08;
	const INV_DROP_BUTTON_HEIGHT = 0.1;

    // Weapon boxes
    const WEAPON_START_X = 0.49;
    const WEAPON_START_Y = 0.886;
    const WEAPON_WIDTH = 0.053;

    ui bool showInvScreen;

    ui void DrawDialog()
    {
        if (DataLibrary.ReadInt("shouldHideDialog") == 1) { dialogOpacity = 0; DataLibrary.GetInstance().dic.Insert("shouldHideDialog", "0"); }
        if (DataLibrary.ReadInt("shouldEraseText") == 1) { textPercentDisplayed = 0; DataLibrary.GetInstance().dic.Insert("shouldEraseText", "0"); }

        if (dialogOpacity < 1.0) dialogOpacity += 0.01;
        ScreenDrawTexture(dialogBackFrame, 0.5, 0.75, alpha: dialogOpacity, centerX: true, centerY: true);

        String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
        int eventDialogPage = DataLibrary.ReadInt("eventDialogPage");
        String s = StringTable.Localize("$CONV_" .. eventDialogConversation .. "_" .. eventDialogPage);

        //If there's a chest item mentioned, get information about the chest
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

    ui void DrawItemShopScreen()
    {
        ScreenDrawTexture(itemShopBG, 0, 0, alpha: 1.0);
        double x = ITEM_SHOP_START_X;
		double y = ITEM_SHOP_START_Y;
		Vector2 mv = RealToVirtual(mouseCursorPos);
		mv.x /= UI_WIDTH;
		mv.y /= UI_HEIGHT;
        
        hoveringOverShop = (mv.x >= ITEM_SHOP_START_X);
        hoveredShopNumber = -1;

        for (int i = 0; i < DataLibrary.GetInstance().itemShopInventory.Size(); i++) {

            ScreenDrawTexture(invItemBG, x, y, alpha: 0.5);
            //Can't hover over a shop item if we already have something
            bool hovering = !uiGrabbedItem && (mv.x >= x && mv.x <= x + INV_STACK_BUTTON_WIDTH && mv.y >= y && mv.y <= y + INV_STACK_BUTTON_HEIGHT);
            if (hovering) {
                // hilight box
                ScreenDrawTexture(invHilight, x, y);
                hoveredShopNumber = i;
            }
			// draw item sprite
            MFInventoryItem item = DataLibrary.GetInstance().itemShopInventory[i];
            ScreenDrawTextureWithinArea(item.getTexture(), x, y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT);

            ScreenDrawString(item.getName(), Font.CR_WHITE, journalFont, x + 0.09, y + 0.03);
            ScreenDrawString(item.getBuyPrice() .."", Font.CR_GREEN, journalFont, x + 0.4, y + 0.03);

            y += INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN;
        }
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
            //Stop if we've reached the inventory size limit
			if ( stackNum >= DataLibrary.GetInstance().MFinventory.Size() ) break;
			for ( int col = 0; col < INV_STACK_BUTTON_COLUMNS; col++ )
			{
				if ( stackNum >= DataLibrary.GetInstance().MFinventory.Size() ) break;

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
				// draw item sprite
				MFInventoryItem item = DataLibrary.GetInstance().MFinventory[stackNum];
				ScreenDrawTextureWithinArea(item.getTexture(), x, y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT);

				// And move along!
				x += (INV_STACK_BUTTON_WIDTH + INV_STACK_BUTTON_MARGIN);
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

		invBGFrame = TexMan.CheckForTexture("invbg", 0);
        invBGClosedFrame = TexMan.CheckForTexture("invbgcl", 0);
		invItemBG = TexMan.CheckForTexture("invitmbg", 0);
        itemShopBG = TexMan.CheckForTexture("shopbg", 0);
		invHilight = TexMan.CheckForTexture("invsel", 0);

        dialogBackFrame = TexMan.CheckForTexture("DIALBACK", 0);
        blockMapFrame = TexMan.CheckForTexture("MAPBLOCK", 0);

		mouseMiniCursorTex = TexMan.CheckForTexture("invcurs", 0);
		mouseCursorPos = (UI_WIDTH/2, UI_HEIGHT/2);
        weaponCursorTex = TexMan.CheckForTexture("guncurs", 0);

		hoveredInvStack = -1;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
        PlayerPawn p = PlayerPawn(players[e.Player].mo);

		if ( e.Name == "ClearedUIGrabbedItem" ) { newGrabbedItem = NULL; shouldClearUIGrabbedItem = false; grabbedItemIsFromShop = false; }
        else if ( e.Name == "BinItem" ) { p.A_PlaySound("po/inventory/bin", CHAN_VOICE); }
        else if ( e.Name == "ToggledPack" ) { p.A_PlaySound("po/inventory/open", CHAN_VOICE); }
		else if ( e.Name == "ClickedInvStack" )
		{
			int stackIndex = e.Args[0];
			MFInventoryItem invItem = DataLibrary.GetInstance().MFinventory[stackIndex];

            //If we don't have a grabbed item, see if we're clicking an empty stack - if not, grab this one
			if (!newGrabbedItem) {
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
                if (grabbedItemIsFromShop) {
                    if (p.CountInv("POCoin") < newGrabbedItem.getBuyPrice()) {
                        p.A_PlaySound("po/deny", CHAN_VOICE);
                        return;
                    }
                    else {
                        p.TakeInventory("POCoin", newGrabbedItem.getBuyPrice());
                        p.A_PlaySound("po/pickup/cash", CHAN_VOICE);
                    }
                }
                else {
                    p.A_PlaySound("po/inventory/down", CHAN_VOICE);
                }
 				MFInventoryItem itemToGrab = (invItem.getClassName() == "MFIEmpty" ? NULL : invItem);
                if (!itemToGrab) {
                    shouldClearUIGrabbedItem = true;
                }
                DataLibrary.GetInstance().InventoryAdd(newGrabbedItem.getClassName(), stackIndex);
                newGrabbedItem = itemToGrab;
                grabbedItemIsFromShop = false;
			}
		}
        else if ( e.Name == "ClickedShopStack" )
        {
            int shopIndex = e.Args[0];
            MFInventoryItem invItem = DataLibrary.GetInstance().itemShopInventory[shopIndex];
            //If we don't already have a new grabbed item, grab this one
            if (!newGrabbedItem) {
                String newItemClassName = invItem.getClassName();
                newGrabbedItem = MFInventoryItem(new(newItemClassName)).Init();
                grabbedItemIsFromShop = true;
                p.A_PlaySound("po/inventory/up", CHAN_VOICE);
            } else {
                grabbedItemIsFromShop = false;
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
        else if (e.Name == "DroppedItemToShop") {
            if (!newGrabbedItem) {
                console.printf("ERROR: Requested to drop an item to shop, but no item found!");
            }
            if (grabbedItemIsFromShop) {
                //Can't sell an item we just picked up!
                newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
            } else {
                int sellPrice = newGrabbedItem.getSellPrice();
                p.GiveInventory("POCoin", sellPrice);
                newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
                p.A_PlaySound("po/sell");
            }
        }
        else if ( e.Name == "ClickedPastDialog" ) {
            //Advance the conversation
            int eventDialogPage = DataLibrary.ReadInt("eventDialogPage") + 1;
            String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
            String dialogKey = "CONV_" .. eventDialogConversation .. "_" .. eventDialogPage;
            String theString = StringTable.Localize("$" .. dialogKey);
            DataLibrary.GetInstance().dic.Insert("shouldEraseText", "1");

            if (theString == "STOP" || theString == dialogKey) {
                DataLibrary.WriteData(NULL, "shouldHideDialog", "1");
                DataLibrary.WriteData(NULL, "showEventDialog", "0");
                DataLibrary.WriteData(NULL, "eventDialogPage", "");
                DataLibrary.WriteData(NULL, "eventDialogConversation", "");
            }
            else {
                DataLibrary.WriteData(NULL, "eventDialogPage", eventDialogPage .. "");
            }
        }
        else if (e.Name == "ClosedShopScreen" ) {
            newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
            DataLibrary.WriteDataFromUI("OpenShopScreen", "0");
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
        bool showEventDialog = (DataLibrary.ReadData("showEventDialog") == "1");
		if ( !initialized ) return false;
		if ( automapactive ) return false;

		// OK, let's get some binds!
		int leftBind, rightBind, i;
		[leftBind, i] = Bindings.GetKeysForCommand("+moveleft");
		[rightBind, i] = Bindings.GetKeysForCommand("+moveright");

        int useBind1, useBind2; [useBind1, useBind2] = Bindings.GetKeysForCommand("+use");
        int invBind1, invBind2; [invBind1, invBind2] = Bindings.GetKeysForCommand("invscreen");

        if ( e.Type == InputEvent.Type_KeyDown && (e.KeyScan == invBind1 || e.KeyScan == invBind2)) {
            showInvScreen = !showInvScreen;
            
            //If we aren't showing the inventory screen any more, the item shop screen must be closed
            //and the current grabbed item (if from shop) has to be cleared
            if (!showInvScreen) {
                EventHandler.SendNetworkEvent("ClosedShopScreen");
            }
            EventHandler.SendNetworkEvent("ToggledPack");
            return true;
        }

        //If not showing anything, no need to check for keys
		if ( !showInvScreen && !showEventDialog ) return false;

        if (showInvScreen) {
            if ( newGrabbedItem ) {	uiGrabbedItem = newGrabbedItem;	}

            if ( shouldClearUIGrabbedItem )
            {
                uiGrabbedItem = NULL;
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
                    if ( hoveredInvStack != -1 ) { EventHandler.SendNetworkEvent("ClickedInvStack", hoveredInvStack); return true; }

                    if ( hoveringDropButton && uiGrabbedItem ) {
                        uiGrabbedItem = NULL;
                        EventHandler.SendNetworkEvent("ClearedUIGrabbedItem");
                        EventHandler.SendNetworkEvent("BinItem");
                        return true;
                    }

                    //If we have the item shop open, also handle shop-related clicks
                    if (DataLibrary.ReadData("OpenShopScreen") == "1") {
                        if (uiGrabbedItem && hoveringOverShop) { EventHandler.SendNetworkEvent("DroppedItemToShop"); return true; }
                        if (hoveredShopNumber != -1) { EventHandler.SendNetworkEvent("ClickedShopStack", hoveredShopNumber); return true; }
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
                
                //If just the inventory screen is open, return false to allow other inputs. But return true to block other inputs if the shop screen is open
                return (DataLibrary.ReadData("OpenShopScreen") == "1"); 
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
                if ( e.KeyScan == InputEvent.Key_Mouse1 || e.KeyScan == useBind1 || e.KeyScan == useBind2 )
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
        if ( !Datalibrary.GetInstance()) {
            return;
        }

        //Always draw the weapon slots
        double weaponX = WEAPON_START_X;
        double weaponY = WEAPON_START_Y;

        for (int i = 0; i < 5; i++) {
            POWeaponSlot w = DataLibrary.getWeaponSlot(i);
            if (w) {
                ScreenDrawTexture(w.getTexture(), weaponX, weaponY);
                let t = w.getElementTexture();
                if (t) {
                    ScreenDrawTexture(t, weaponX, weaponY);
                }
            }
            weaponX += WEAPON_WIDTH;
        }

        //Then do the rest conditionally
		if ( automapactive ) {
            //Block out the automap if we're not playing on a skill that allows it!
            if ( G_SkillPropertyInt(SKILLP_ACSReturn) != 1) {
                ScreenDrawTexture(blockMapFrame, 0.5, 0.5, alpha: 1.0, centerX: true, centerY: true);
            }
            return;
        }
        
        if (DataLibrary.ReadData("OpenShopScreen") == "1") {
            showInvScreen = true;
            DrawItemShopScreen();
        }
		if ( showInvScreen ) {
			DrawInvScreen();
		} else {
            //Draw closed inventory on status bar
            ScreenDrawTexture(invBGClosedFrame, 0, 0, alpha: 0.9);
        }
        if ( DataLibrary.ReadData("showEventDialog") == "1" ) {
            showInvScreen = 0;
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
			y += int((centerYHeight * UI_HEIGHT) / 2 - (lineHeight * UI_HEIGHT) / 2);
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
		int ix = int(pct_x * UI_WIDTH);
		int iy = int(pct_y * UI_HEIGHT);
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
		ix += int(areaW * ((1 - marginScale) / 2) * UI_WIDTH);
		iy += int(areaH * ((1 - marginScale) / 2) * UI_HEIGHT);
		if ( centerX )
			ix -= int(w / 2);
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
        if (!showInvScreen) { return; }

        if (uiGrabbedItem) {
            ScreenDrawTextureWithinArea(uiGrabbedItem.getTexture(), v.x + iconPadX, v.y + iconPadY, iconArea, iconArea);
        }

		// tooltip-style text for grabbed / hovered item
		MFInventoryItem item;
		if ( uiGrabbedItem ) { item = uiGrabbedItem; }
		else if ( hoveredInvStack != -1 ) { item = DataLibrary.GetInstance().InventoryPeek(hoveredInvStack); }
        else if ( hoveredShopNumber != -1 ) { item = DataLibrary.GetInstance().itemShopInventory[hoveredShopNumber]; }
		else return;

		String toolTipText = item.getName();
		double textMargin = -0.04;
		Screen.DrawText(tinyFont, Font.CR_LIGHTBLUE,
						(v.x + textMargin) * UI_WIDTH,
						(v.y + textMargin) * UI_HEIGHT,
						toolTipText,
						DTA_VirtualWidth, UI_WIDTH,
						DTA_VirtualHeight, UI_HEIGHT);
        String descriptionKey = "INV_" .. item.getClassName();
		String descriptionText = StringTable.Localize("$" .. descriptionKey);
        if ((descriptionText == descriptionKey) || !descriptionText) {
            return;
        }
        ScreenDrawString(descriptionText, Font.CR_WHITE, tinyFont, 0.5, 0.75, lineHeight: 0.03, wrapWidth: 0.5);
	}
}
