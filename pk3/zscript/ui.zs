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
    ui TextureID dialogOptionFrame;
    ui TextureID blockMapFrame;
    ui TextureID blockMapSquares;
    ui TextureID mapCounter;
    ui TextureID weaponCursorTex;
    ui TextureID itemShopBG;
    ui TextureID armoryBG;

    // Mouse position
	ui Vector2 mouseCursorPos;

    // Inventory screen stuff
	ui int hoveredInvStack;
    ui int hoveredShopNumber;
    ui int hoveredDialogOption;
	ui MFInventoryItem uiGrabbedItem;
	play MFInventoryItem newGrabbedItem;
    play bool grabbedItemIsFromShop;
	play bool shouldClearUIGrabbedItem;
	ui bool hoveringDropButton;
    ui bool hoveringOverShop;
    ui int shopFirstItemIndex;
    
    ui POWeaponSlot uiGrabbedArm;
    play POWeaponSlot grabbedArm;
    play bool shouldClearUIGrabbedArm;
    
    ui int hoveredArmStack;
    ui int hoveringForgeButton;

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
    
	const MATERIAL_ICON_WIDTH = 0.03;
	const MATERIAL_ICON_HEIGHT = 0.03;

	// Drop button
	const INV_DROP_BUTTON_X = 0.335;
	const INV_DROP_BUTTON_Y = 0.865;
	const INV_DROP_BUTTON_WIDTH = 0.08;
	const INV_DROP_BUTTON_HEIGHT = 0.1;

    // Weapon boxes
    const WEAPON_START_X = 0.49;
    const WEAPON_START_Y = 0.886;
    const WEAPON_WIDTH = 0.053;
    
    const MAP_SQUARE_START_X = 0.24;
    const MAP_SQUARE_START_Y = 0.155;
    const MAP_SQUARE_DISTANCE_X = 0.0275;
    const MAP_SQUARE_DISTANCE_Y = 0.0366;

    play bool showInvScreen;
    
    ui String parsedDialogString;
    ui String parsedDialogTexture;
    ui MFInventoryItem parsedDialogChestItem;
    ui String parsedDialogType;
    ui Array<String> parsedDialogOptions;
    ui Array<int> parsedDialogDestinations;

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
        armoryBG = TexMan.CheckForTexture("armorybg", 0);
		invHilight = TexMan.CheckForTexture("invsel", 0);

        dialogBackFrame = TexMan.CheckForTexture("DIALBACK", 0);
        dialogOptionFrame = TexMan.CheckForTexture("DIALRESP", 0);
        blockMapFrame = TexMan.CheckForTexture("MAPBLOCK", 0);
        blockMapSquares = TexMan.CheckForTexture("MAPSQUAR", 0);
        mapCounter = TexMan.CheckForTexture("MAPCOUNT", 0);

		mouseMiniCursorTex = TexMan.CheckForTexture("invcurs", 0);
		mouseCursorPos = (UI_WIDTH/2, UI_HEIGHT/2);
        weaponCursorTex = TexMan.CheckForTexture("guncurs", 0);

		hoveredInvStack = -1;
        hoveredShopNumber = -1;
        hoveredDialogOption = -1;
        shopFirstItemIndex = 0;
	}


    ui void DrawDialog()
    {
        // get mouse coordinates in % based numbers used by drawers
		Vector2 mv = RealToVirtual(mouseCursorPos);
		mv.x /= UI_WIDTH;
		mv.y /= UI_HEIGHT;
        
        if (DataLibrary.ReadInt("shouldHideDialog") == 1) { dialogOpacity = 0; DataLibrary.GetInstance().dic.Insert("shouldHideDialog", "0"); }
        if (DataLibrary.ReadInt("shouldEraseText") == 1) {
            textPercentDisplayed = 0;
            parsedDialogString = "";
            parsedDialogChestItem = null;
            parsedDialogOptions.Clear();
            parsedDialogDestinations.Clear();
            DataLibrary.GetInstance().dic.Insert("shouldEraseText", "0");
        }

        //We display the dialogue texture first because it has to appear behind the dialogue window
        if (parsedDialogTexture && dialogOpacity >= 1.0) {
           ScreenDrawTexture(TexMan.checkForTexture(parsedDialogTexture, 0), 0.5, 0.54, centerX: true, lowerUnpegged: true); 
        }
        
        if (dialogOpacity < 1.0) dialogOpacity += 0.01;
        ScreenDrawTexture(dialogBackFrame, 0.5, 0.75, alpha: dialogOpacity, centerX: true, centerY: true);

        //If there's a chest item mentioned, get information about the chest
        if (parsedDialogString.IndexOf("$chestitem$") > 0) {
            POChest chest = DataLibrary.GetInstance().chestToOpen;
            if (!chest.containedItem) {
                //No item - check for coins or ammo instead
                if (chest.containedCoins) {
                    parsedDialogString.Substitute("$chestitem$", (chest.containedCoins .. " coins"));
                }
                else if (chest.containedAmmo) {
                    String ammoType = "bullets";
                    switch (chest.containedAmmoType) {
                        case 2: ammoType = "shells"; break;
                        case 3: ammoType = "rockets"; break;
                        case 4: ammoType = "plasma cells"; break;
                    }
                    parsedDialogString.Substitute("$chestitem$", (chest.containedAmmo .. " " .. ammoType));
                }
                else { parsedDialogString = "There is nothing in the chest. That's probably a bug."; }
            } else {
                parsedDialogString.Substitute("$chestitem$", "the " .. chest.containedItem.getName());
                parsedDialogChestItem = chest.containedItem;
            }
        }
        if (parsedDialogChestItem) {
            ScreenDrawTextureWithinArea(parsedDialogChestItem.getTexture(), 0.5, 0.2, 0.3, 0.3, alpha:dialogOpacity, centerX:true);
        }

        //Don't actually do anything with the string until dialog opacity is 1.0
        if (dialogOpacity < 1.0) {
            return;
        }

        ScreenDrawString(parsedDialogString, Font.CR_WHITE, journalFont, 0.145, 0.56, wrapWidth: 0.7, displayPercent: textPercentDisplayed);
        if (textPercentDisplayed < 1.0) textPercentDisplayed += 0.005;
        
        //Draw any responses
        hoveredDialogOption = -1;
        if (textPercentDisplayed >= 1.0 && parsedDialogOptions.Size() > 0) {
            double yPos = 1.0;
            yPos -= 0.1 * parsedDialogOptions.Size();
            for (int i = 0; i < parsedDialogOptions.Size(); i++) {
                int optionColor = Font.CR_GOLD;
                if (mv.y >= yPos - 0.03 && mv.y <= yPos + 0.03) {
                    hoveredDialogOption = i;
                    optionColor = Font.CR_WHITE;
                }
                ScreenDrawTexture(dialogOptionFrame, 0.5, yPos, alpha: 1.0, centerX: true, centerY: true);
                ScreenDrawString(parsedDialogOptions[i], optionColor, journalFont, 0.5, yPos - 0.015, wrapWidth: 1.0, centerX: true);
                yPos += 0.1;
            }
        }
        
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
        
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        
        //Display material inventory
        String materialsString = "POJam,POHorn,POLeather,PODarkHeart";
        Array<String> materials; materialsString.Split(materials, ",");
        double materialX = 0.41;
        double materialY = 0.02;
        for (int i = 0; i < materials.Size(); i++) {
            class<Actor> cls = materials[i];
            int quantity = p.CountInv(materials[i]);
            String spriteName = POMaterial(GetDefaultByType(cls)).mySprite .. "A0";
            if (quantity > 0) {
                TextureID tex = TexMan.CheckForTexture(spriteName, TexMan.Type_Sprite);
                ScreenDrawTextureWithinArea(tex, materialX, materialY, MATERIAL_ICON_WIDTH, MATERIAL_ICON_HEIGHT);
                ScreenDrawString(quantity .. "", Font.CR_WHITE, tinyFont, materialX + 0.05, materialY+0.002);
                materialY += 0.033;
            }
        }
        
        int shopItemsDisplayed = 0;
        for (int i = shopFirstItemIndex; i < DataLibrary.GetInstance().itemShopInventory.Size() && shopItemsDisplayed < 6; i++) {
            
            MFInventoryItem item = DataLibrary.GetInstance().itemShopInventory[i];

            Array<String> interpretedRequirements;
            int requirementsWithAtLeastOneInventoryItem = 0;
            bool requirementsAllFulfilled = 1;
            
            //If we shouldn't display this item, move on. We can display if we have at least one of all but one required item...
            Array<String> requirements; item.getRequirements().Split(requirements, ",");
            if (requirements.Size() > 0) {
                
                for (int i = 0; i < requirements.Size(); i += 2) {
                    class<Actor> cls = requirements[i];
                    int quantity = requirements[i+1].ToInt();
                    String spriteName = POMaterial(GetDefaultByType(cls)).mySprite .. "A0";
                    bool hasEnough = p.CountInv(requirements[i]) >= quantity;
                    if (!hasEnough) {
                        requirementsAllFulfilled = 0;
                    }
                    bool hasOne = p.CountInv(requirements[i]) > 0;
                    if (hasOne) {
                        requirementsWithAtLeastOneInventoryItem++;
                    }
                    interpretedRequirements.push(requirements[i] .. "," .. quantity .. "," .. spriteName .. "," .. hasEnough .. "," .. hasOne);
                }
                
                if (requirementsWithAtLeastOneInventoryItem < interpretedRequirements.Size() - 1) {
                    continue; //Forget it!
                }
            }
            
            //We've passed the requirements for display!
            shopItemsDisplayed++;
            
            ScreenDrawTexture(invItemBG, x, y, alpha: 0.5);
            //Can't hover over a shop item if we already have something, or if it's disabled
            bool hovering = requirementsAllFulfilled && !uiGrabbedItem && (mv.x >= x && mv.x <= x + INV_STACK_BUTTON_WIDTH && mv.y >= y && mv.y <= y + INV_STACK_BUTTON_HEIGHT);
            if (hovering) {
                // hilight box
                ScreenDrawTexture(invHilight, x, y);
                hoveredShopNumber = i;
            }
			// draw item sprite
            ScreenDrawTextureWithinArea(item.getTexture(), x, y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT, alpha: (requirementsAllFulfilled ? 1.0 : 0.5));
            
            int itemNameColor = Font.CR_WHITE;
            if (!requirementsAllFulfilled) {
                itemNameColor = Font.CR_DARKGRAY;
            }

            ScreenDrawString(item.getName(), itemNameColor, journalFont, x + 0.09, y + 0.01);
            ScreenDrawString(item.getBuyPrice() .."", Font.CR_GREEN, journalFont, x + 0.4, y + 0.01);
            DrawItemRequirements(interpretedRequirements, x, y);

            y += INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN;
        }
    }
    
    ui void DrawItemRequirements(Array<String> requirements, double startX, double startY) {
        double y = startY + 0.045;
        double x = startX + 0.09;
        for (int i = 0; i < requirements.Size(); i++) {
            console.printf(requirements[i]);
            Array<String> requirementsData; requirements[i].Split(requirementsData, ",");
            int quantity = requirementsData[1].toInt();
            TextureID icon = TexMan.CheckForTexture(requirementsData[2], TexMan.Type_Sprite);
            ScreenDrawTextureWithinArea(icon, x, y, MATERIAL_ICON_WIDTH, MATERIAL_ICON_HEIGHT);
            
            int itemColor = Font.CR_DARKGRAY;
            if (requirementsData[3] == "1") {
                itemColor = Font.CR_WHITE;
            }
            ScreenDrawString("x" .. quantity, itemColor, tinyFont, x + 0.03, y);
            x += 0.07;
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
    
    ui void DrawArmoryScreen()
    {
        ScreenDrawTexture(armoryBG, 0, 0, alpha: 1.0);
        double x = ITEM_SHOP_START_X;
		double y = ITEM_SHOP_START_Y;
		Vector2 mv = RealToVirtual(mouseCursorPos);
		mv.x /= UI_WIDTH;
		mv.y /= UI_HEIGHT;
        
        hoveringOverShop = (mv.x >= ITEM_SHOP_START_X);
        hoveredArmStack = -1;

        for (int i = 0; i < DataLibrary.GetInstance().armoryInventory.Size(); i++) {

            ScreenDrawTexture(invItemBG, x, y, alpha: 0.5);
            //Can't hover over a weapon if we already have something
            bool hovering = !uiGrabbedArm && (mv.x >= x && mv.x <= x + INV_STACK_BUTTON_WIDTH && mv.y >= y && mv.y <= y + INV_STACK_BUTTON_HEIGHT);
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

	override void NetworkProcess(ConsoleEvent e)
	{
        PlayerPawn p = PlayerPawn(players[e.Player].mo);

		if ( e.Name == "ClearedUIGrabbedItem" ) { newGrabbedItem = NULL; shouldClearUIGrabbedItem = false; grabbedItemIsFromShop = false; }
        else if ( e.Name == "ClearedUIGrabbedArm" ) { grabbedArm = NULL; shouldClearUIGrabbedArm = false; }
        else if ( e.Name == "BinItem" ) { p.A_PlaySound("po/inventory/bin", CHAN_VOICE); }
        else if ( e.Name == "CloseInventory" ) { showInvScreen = false; }
        else if ( e.Name == "OpenInventory" ) { showInvScreen = true; }
        else if ( e.Name == "ToggleInventory" ) { p.A_PlaySound("po/inventory/open", CHAN_VOICE); showInvScreen = !showInvScreen; }

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
                        Array<String> requirements; newGrabbedItem.getRequirements().Split(requirements, ",");
                        if (requirements.Size() > 0) {
                            
                            for (int i = 0; i < requirements.Size(); i += 2) {
                                String className = requirements[i];
                                int quantity = requirements[i+1].ToInt();
                                p.TakeInventory(className, quantity);
                            }
                        }
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
            //If our inventory is full, refuse
            if (DataLibrary.InventoryIsFull()) {
                p.A_PlaySound("po/deny");
            }
            //If we don't already have a new grabbed item, grab this one
            else if (!newGrabbedItem) {
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
            else if (grabbedItemIsFromShop) {
                //Put it back
                newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
            }
            else if (newGrabbedItem.getSellPrice() == 0) {
                //No sale price means this is a key item
                p.A_PlaySound("po/deny");
            }
            else {
                int sellPrice = newGrabbedItem.getSellPrice();
                p.GiveInventory("POCoin", sellPrice);
                newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
                p.A_PlaySound("po/sell");
            }
        }
        else if ( e.Name == "ClickedPastDialog" ) {
            int destination = e.args[0];
            if (destination == 0) {
                destination = DataLibrary.ReadInt("eventDialogPage") + 1;
            }
            
            String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
            String dialogKey = "CONV_" .. eventDialogConversation .. "_" .. destination;
            String theString = StringTable.Localize("$" .. dialogKey);
            DataLibrary.GetInstance().dic.Insert("shouldEraseText", "1");

            if (theString == "STOP" || theString == dialogKey) {
                //If this is a chest and it forces an event afterwards, run it now
                if (
                    DataLibrary.ReadData("eventDialogConversation") == "OPEN_CHEST" &&
                    (DataLibrary.GetInstance().chestToOpen && DataLibrary.GetInstance().chestToOpen.causeEvent > 0)
                ) {
                    DataLibrary.writeData(NULL, "ForceEvent", "runEvent" .. DataLibrary.GetInstance().chestToOpen.causeEvent);
                }
                DataLibrary.WriteData(NULL, "shouldHideDialog", "1");
                DataLibrary.WriteData(NULL, "showEventDialog", "0");
                DataLibrary.WriteData(NULL, "eventDialogPage", "");
                DataLibrary.WriteData(NULL, "eventDialogConversation", "");
            }
            else {
                DataLibrary.WriteData(NULL, "eventDialogPage", destination .. "");
            }
        }
        else if (e.Name == "CloseShopScreen" ) {
            newGrabbedItem = NULL; shouldClearUIGrabbedItem = true; grabbedItemIsFromShop = false;
            DataLibrary.WriteDataFromUI("OpenShopScreen", "0");
        }
        else if (e.Name == "CloseArmoryScreen" ) {
            grabbedArm = NULL; shouldClearUIGrabbedArm = true;
            DataLibrary.WriteDataFromUI("OpenArmoryScreen", "0");
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

		// OK, let's get some binds!
		int leftBind, rightBind, i;
		[leftBind, i] = Bindings.GetKeysForCommand("+moveleft");
		[rightBind, i] = Bindings.GetKeysForCommand("+moveright");

        int useBind1, useBind2; [useBind1, useBind2] = Bindings.GetKeysForCommand("+use");
        int invBind1, invBind2; [invBind1, invBind2] = Bindings.GetKeysForCommand("invscreen");
        
		if ( automapactive ) return false;
        
        if ( e.Type == InputEvent.Type_KeyDown && (e.KeyScan == invBind1 || e.KeyScan == invBind2)) {
            //If the dialogue screen is open, ignore the keypress
            if ( DataLibrary.ReadData("showEventDialog") == "1" ) {
                return true;
            }
            
            //If the shop screen is currently open, need to close that as well
            if (DataLibrary.ReadData("OpenShopScreen") == "1") {
                EventHandler.SendNetworkEvent("CloseShopScreen");
            }
            
            //If the armory screen is currently open, close that
            if (DataLibrary.ReadData("OpenArmoryScreen") == "1") {
                EventHandler.SendNetworkEvent("CloseArmoryScreen");
            }

            EventHandler.SendNetworkEvent("ToggleInventory");
           
            return true;
        }

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

                    if ( hoveringDropButton && uiGrabbedItem && !grabbedItemIsFromShop && uiGrabbedItem.getSellPrice() > 0) {
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
                
                //If just the inventory screen is open, return false to allow other inputs. But return true to block other inputs if the shop/armory screen is open
                return (DataLibrary.ReadData("OpenShopScreen") == "1" || DataLibrary.ReadData("OpenArmoryScreen") == "1"); 
            }

            // process keyup events else inputs active when screen invoked bleed & stay on - otherwise, block other keypresses
            else if ( e.Type == InputEvent.Type_KeyUp ) { return false; }
            return true;
        }
        
        //Same for armory screen
        if (DataLibrary.ReadData("OpenArmoryScreen") == "1") {
            if (shouldClearUIGrabbedArm) {
                uiGrabbedArm = NULL;
                EventHandler.SendNetworkEvent("ClearedUIGrabbedArm");
            }
            if ( e.KeyScan == InputEvent.Key_Mouse1 ) {
                //if (uiGrabbedItem && hoveringOverShop) { EventHandler.SendNetworkEvent("DroppedItemToShop"); return true; }
                //if (hoveredShopNumber != -1) { EventHandler.SendNetworkEvent("ClickedShopStack", hoveredShopNumber); return true; }
            }
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
                    if (dialogOpacity >= 1.0) {
                        if (textPercentDisplayed >= 1.0 && parsedDialogOptions.Size() <= 1) {
                            EventHandler.SendNetworkEvent("ClickedPastDialog", 0);
                        }
                        else if (textPercentDisplayed >= 1.0 && hoveredDialogOption != -1) {
                            EventHandler.SendNetworkEvent("ClickedPastDialog", parsedDialogDestinations[hoveredDialogOption]);
                        }
                        else {
                            //If clicked before text is all displayed, set it to displayed
                            textPercentDisplayed = 1.0;
                        }
                    }
                }
                return true;
            }
            // process keyup events else inputs active when screen invoked bleed & stay on - otherwise, block other keypresses
            if ( e.Type == InputEvent.Type_KeyUp ) { return false; }
            return true;
        }
        
        //Check to see whether we should swallow the use key for any other reason (used when player is moving)
        if (e.Type == InputEvent.Type_KeyDown && (e.KeyScan == useBind1 || e.KeyScan == useBind2)) {
            if (DataLibrary.ReadInt("BlockUseKey")) {
                console.printf("DEBUG: Blocked use key");
                return true;
            }
        }

        return false;

	}

	override void RenderOverlay(RenderEvent e)
	{
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        
		// fonts must be transient; if we're loading a savegame they'll be null so reinit
		if ( !initialized ) Init();
		if ( !(tinyFont) ) InitFonts();
        if ( !Datalibrary.GetInstance()) {
            return;
        }

        //Always draw the weapon slots
        double weaponX = WEAPON_START_X;
        double weaponY = WEAPON_START_Y;

        for (int i = 0; i < DataLibrary.getInstance().weaponInventorySize; i++) {
            POWeaponSlot w = DataLibrary.getWeaponSlot(i);
            if (w) {
                ScreenDrawTexture(w.getTexture(), weaponX, weaponY);
                let t = w.getElementTexture();
                if (t) {
                    ScreenDrawTexture(t, weaponX, weaponY);
                }
                let t2 = w.getPowerTexture();
                if (t2) {
                    ScreenDrawTexture(t2, weaponX, weaponY);
                }
            }
            weaponX += WEAPON_WIDTH;
        }

        //Then do the rest conditionally
		if ( automapactive ) {
            //Block out the automap if we're not playing on a skill that allows it!
            if ( G_SkillPropertyInt(SKILLP_ACSReturn) != 1 && DataLibrary.ReadInt("InFight") == 0) {
                ScreenDrawTexture(blockMapSquares, 0.5, 0.5, alpha: 1.0, centerX: true, centerY: true);
                double x = MAP_SQUARE_START_X;
                double y = MAP_SQUARE_START_Y + (MAP_SQUARE_DISTANCE_Y * 19);
                double playerX = p.pos.x / LevelHelper.TILE_SIZE;
                double playerY = p.pos.y / LevelHelper.TILE_SIZE;
                x += playerX * MAP_SQUARE_DISTANCE_X;
                y -= playerY * MAP_SQUARE_DISTANCE_Y;
                
                ScreenDrawTexture(mapCounter, x, y, centerX:true, centerY:true);
                //p.pos.x, p.pos.y;
                //console.printf("%d", squarenum);
            }
            return;
        }
        
        if (DataLibrary.ReadData("OpenShopScreen") == "1") {
            EventHandler.SendNetworkEvent("OpenInventory");
            DrawItemShopScreen();
        }
        if (DataLibrary.ReadData("OpenArmoryScreen") == "1") {
            EventHandler.SendNetworkEvent("CloseInventory");
            DrawArmoryScreen();
        }
		if (showInvScreen) {
			DrawInvScreen();
		} else {
            //Draw closed inventory on status bar
            ScreenDrawTexture(invBGClosedFrame, 0, 0, alpha: 0.9);
        }
        if ( DataLibrary.ReadData("showEventDialog") == "1" ) {
            EventHandler.SendNetworkEvent("CloseInventory");
            
            String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
            int eventDialogPage = DataLibrary.ReadInt("eventDialogPage");
            if (!parsedDialogString) {
                parsedDialogTexture = "";
                parsedDialogType = "";
                String s = StringTable.Localize("$CONV_" .. eventDialogConversation .. "_" .. eventDialogPage);
                Array<String> tokens; s.Split(tokens, " ");
                int nextTokenStartChar = 0;
                for (int i = 0; i < tokens.Size(); i++) {
                    if (tokens[i].Left(1) != "[") {
                        parsedDialogString = s.Mid(nextTokenStartChar);
                        break; //All special tokens have been handled
                    }
                    
                    //This is a special token, let's parse it!
                    String tokenType = tokens[i].Mid(1, 1);
                    String tokenValue = tokens[i].Mid(3, tokens[i].Length()-4);

                    if (tokenType == "F") {
                        parsedDialogTexture = tokenValue;
                    }
                    if (tokenType == "R") { //Response
                        tokenValue.Substitute("_", " ");
                        parsedDialogOptions.push(tokenValue);
                    }
                    if (tokenType == "D") { //Destination (for responses)
                        parsedDialogDestinations.push(tokenValue.ToInt());
                    }
                    if (tokenType == "S") { //Set flag
                        DataLibrary.WriteDataFromUI(tokenValue, "1");
                    }
                    if (tokenType == "C") { //Clear flag
                        DataLibrary.WriteDataFromUI(tokenValue, "0");
                    }
                    
                    nextTokenStartChar += tokens[i].Length() + 1;
                }
                
                //To make it easier, fill the destinations with 0s if there are too few for the responses
                //This means we don't have to provide a destination if it doesn't matter (e.g. single response)
                while (parsedDialogOptions.Size() > parsedDialogDestinations.size()) {
                    parsedDialogDestinations.push(0);
                    console.printf("Padded dialogue destinations");
                }
            }
            
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

	ui void ScreenDrawTexture(TextureID tex, double pct_x, double pct_y, double scale = 1.0, double alpha = 1.0, bool centerX = false, bool centerY = false, bool lowerUnpegged = false)
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
        if ( lowerUnpegged ) y -= h;

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
        
        if (uiGrabbedArm) {
            
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
