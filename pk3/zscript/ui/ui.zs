class FriendlyUIHandler : EventHandler
{
	// mouse movement will be multiplied by this
	const MOUSE_SENSITIVITY_FACTOR_X = 1.9;
    const MOUSE_SENSITIVITY_FACTOR_Y = 1.9;

	ui bool initialized;

	// Fonts
	ui transient Font tinyFont;
	ui transient Font journalFont;
    
    // Delegates
    ui DialogParser dialogParser;
    ui TextureCache tx;

    // Mouse position
	ui Vector2 mouseCursorPos;

    // Inventory screen stuff
	ui int hoveredInvStack;
    ui int hoveredShopNumber;

	play MFInventoryItem grabbedItem;
    play bool grabbedItemIsFromShop;
    play int grabbedItemFromSlot;

	ui bool hoveringDropButton;
    ui bool hoveringOverShop;
    ui int shopItemsDisplayed;
    play int shopFirstItemIndex;
    
    // Armory screen stuff
    ui POWeaponSlot uiGrabbedArm;
    play POWeaponSlot grabbedArm;
    play bool shouldClearUIGrabbedArm;
    
    ui int hoveredArmOption;
    ui int hoveredArmStack;
    ui int hoveringForgeButton;


	// Inventory measurements
	const INV_STACK_BUTTON_START_X = 0.095;
	const INV_STACK_BUTTON_START_Y = 0.72;
	const INV_STACK_BUTTON_WIDTH = 0.08;
	const INV_STACK_BUTTON_HEIGHT = 0.1;
	const INV_STACK_BUTTON_MARGIN = 0.01;
    const INV_STACK_BUTTON_MARGIN_INV = 0.02;
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
    
    const POWERS_X = -0.048;
    const POWERS_Y = 0.85;
    const POWERS_SIZE = 0.03;
    const POWERS_TEXT_GAP = 0.033;
    const POWERS_VERTICAL_GAP = 0.04;

    play bool inventoryIsOpen;

	ui void InitFonts()
	{
		tinyFont = Font.GetFont("fonts/jimmy_tinyfont.lmp");
		journalFont = Font.GetFont("fonts/jimmy_APOS_BOK.lmp");
	}

	ui void Init()
	{
		initialized = true;
        PoLogger.Log("inv", "Initialized UI");
		InitFonts();

        //Set up our delegates
        dialogParser = new("DialogParser");
        tx = new("TextureCache");
        tx.Init();

        //Set up variables
        mouseCursorPos = (DrawFunctions.UI_WIDTH/2, DrawFunctions.UI_HEIGHT/2);
		hoveredInvStack = -1;
        hoveredShopNumber = -1;
	}

    ui void DrawDialog()
    {
        if (inventoryIsOpen) {
            EventHandler.SendNetworkEvent("CloseInventory");
        }
        // get mouse coordinates in % based numbers used by drawers
		Vector2 mv = DrawFunctions.GetVirtualVector(mouseCursorPos);

        if (DataLibrary.ReadInt("UIRequest_ClearDialog")) { dialogParser.ClearDialog(); DataLibrary.GetInstance().dic.Insert("UIRequest_ClearDialog", "0"); return; }

        //We display the dialogue texture first because it has to appear behind the dialogue window
        if (dialogParser.parsedDialogTexture && dialogParser.dialogOpacity >= 1.0) {
           DrawFunctions.ScreenDrawTexture(TexMan.checkForTexture(dialogParser.parsedDialogTexture, 0), 0.5, 0.54, centerX: true, lowerUnpegged: true); 
        }
        
        DrawFunctions.ScreenDrawTexture(tx.get("dialogBackFrame"), 0.5, 0.75, alpha: dialogParser.dialogOpacity, centerX: true, centerY: true);

        if (dialogParser.parsedDialogChestItem) {
            DrawFunctions.ScreenDrawTextureWithinArea(dialogParser.parsedDialogChestItem.getTexture(), 0.5, 0.2, 0.3, 0.3, alpha:dialogParser.dialogOpacity, centerX:true);
        }

        //Don't actually do anything with the string until dialog opacity is 1.0
        if (dialogParser.dialogOpacity < 1.0) { dialogParser.dialogOpacity += 0.05; return; }

        DrawFunctions.ScreenDrawString(dialogParser.parsedDialogString, Font.CR_WHITE, journalFont, 0.145, 0.56, wrapWidth: 0.7, displayPercent: dialogParser.textPercentDisplayed);

        DrawMouseCursor();

        //If text isn't fully displayed yet, stop here
        if (dialogParser.textPercentDisplayed < 1.0) { dialogParser.textPercentDisplayed += 0.005; return; }
        
        //Now draw any responses
        dialogParser.hoveredDialogOption = -1;
        if (dialogParser.textPercentDisplayed >= 1.0 && dialogParser.parsedDialogOptions.Size() > 0) {
            double yPos = 1.0;
            yPos -= 0.1 * dialogParser.parsedDialogOptions.Size();
            for (int i = 0; i < dialogParser.parsedDialogOptions.Size(); i++) {
                int optionColor = Font.CR_GOLD;
                if (mv.y >= yPos - 0.03 && mv.y <= yPos + 0.03) {
                    dialogParser.hoveredDialogOption = i;
                    optionColor = Font.CR_WHITE;
                }
                DrawFunctions.ScreenDrawTexture(tx.get("dialogOptionFrame"), 0.5, yPos, alpha: 1.0, centerX: true, centerY: true);
                DrawFunctions.ScreenDrawString(dialogParser.parsedDialogOptions[i], optionColor, journalFont, 0.5, yPos - 0.015, wrapWidth: 1.0, centerX: true);
                yPos += 0.1;
            }
        }
    }

    ui void DrawItemShopScreen()
    {
        if (!inventoryIsOpen) {
            EventHandler.SendNetworkEvent("OpenInventory");
        }
        DrawFunctions.ScreenDrawTexture(tx.get("itemShopBG"), 0, 0, alpha: 1.0);
        Vector2 drawSpot = (ITEM_SHOP_START_X, ITEM_SHOP_START_Y);
		Vector2 mv = DrawFunctions.GetVirtualVector(mouseCursorPos);
        
        hoveringOverShop = (mv.x >= ITEM_SHOP_START_X);
        hoveredShopNumber = -1;
        
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        
        //Display material inventory
        String materialsString = "POJam,POHorn,POLeather,PODarkHeart";
        Array<String> materials; materialsString.Split(materials, ",");
        Vector2 materialSpot = (0.41, 0.02);
        for (int i = 0; i < materials.Size(); i++) {
            class<Actor> cls = materials[i];
            int quantity = p.CountInv(materials[i]);
            String spriteName = POMaterial(GetDefaultByType(cls)).mySprite .. "A0";
            if (quantity > 0) {
                TextureID tex = TexMan.CheckForTexture(spriteName, TexMan.Type_Sprite);
                DrawFunctions.ScreenDrawTextureWithinArea(tex, materialSpot.x, materialSpot.y, MATERIAL_ICON_WIDTH, MATERIAL_ICON_HEIGHT);
                DrawFunctions.ScreenDrawString(quantity .. "", Font.CR_WHITE, tinyFont, materialSpot.x + 0.05, materialSpot.y+0.002);
                materialSpot.y += 0.033;
            }
        }
        
        shopItemsDisplayed = 0;
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
            
            DrawFunctions.ScreenDrawTexture(tx.get("invItemBG"), drawSpot.x, drawSpot.y, alpha: 0.5);
            //Is the mouse hovering over this? Highlight it, if it's eligible
            bool hovering = requirementsAllFulfilled && !grabbedItem && (mv.x >= drawSpot.x && mv.x <= drawSpot.x + INV_STACK_BUTTON_WIDTH && mv.y >= drawSpot.y && mv.y <= drawSpot.y + INV_STACK_BUTTON_HEIGHT);
            if (hovering) {
                // hilight box
                DrawFunctions.ScreenDrawTexture(tx.get("invHilight"), drawSpot.x, drawSpot.y);
                hoveredShopNumber = i;
            }
			// draw item sprite
            DrawFunctions.ScreenDrawTextureWithinArea(item.getTexture(), drawSpot.x, drawSpot.y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT, alpha: (requirementsAllFulfilled ? 1.0 : 0.5));
            
            int itemNameColor = Font.CR_WHITE;
            if (!requirementsAllFulfilled) {
                itemNameColor = Font.CR_DARKGRAY;
            }

            DrawFunctions.ScreenDrawString(item.getName(), itemNameColor, journalFont, drawSpot.x + 0.09, drawSpot.y + 0.01);
            DrawFunctions.ScreenDrawString(item.getBuyPrice() .."", Font.CR_GREEN, journalFont, drawSpot.x + 0.4, drawSpot.y + 0.01);
            DrawItemRequirements(interpretedRequirements, drawSpot.x, drawSpot.y);

            drawSpot.y += INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN;
        }
    }
    
    ui void DrawItemRequirements(Array<String> requirements, double startX, double startY) {
        double y = startY + 0.045;
        double x = startX + 0.09;
        for (int i = 0; i < requirements.Size(); i++) {
            Array<String> requirementsData; requirements[i].Split(requirementsData, ",");
            int quantity = requirementsData[1].toInt();
            TextureID icon = TexMan.CheckForTexture(requirementsData[2], TexMan.Type_Sprite);
            DrawFunctions.ScreenDrawTextureWithinArea(icon, x, y, MATERIAL_ICON_WIDTH, MATERIAL_ICON_HEIGHT);
            
            int itemColor = Font.CR_DARKGRAY;
            if (requirementsData[3] == "1") {
                itemColor = Font.CR_WHITE;
            }
            DrawFunctions.ScreenDrawString("x" .. quantity, itemColor, tinyFont, x + 0.03, y);
            x += 0.07;
        }
    }

	ui void DrawInvScreen()
	{
        if (!inventoryIsOpen) {
            DrawFunctions.ScreenDrawTexture(tx.get("invBGClosedFrame"), 0, 0, alpha: 0.9);
            return;
        }

        string bgFrame = "invBGFrame";
        if (DataLibrary.GetInstance().inventorySize > 4) { bgFrame = "invBGFrame2"; }
        if (DataLibrary.GetInstance().inventorySize > 8) { bgFrame = "invBGFrame3"; }
        if (DataLibrary.GetInstance().inventorySize > 12) { bgFrame = "invBGFrame4"; }

        DrawFunctions.ScreenDrawTexture(tx.get(bgFrame), 0, 0, alpha: 0.9);

        // draw stack buttons
		double x = INV_STACK_BUTTON_START_X;
		double y = INV_STACK_BUTTON_START_Y;
		// get mouse coordinates in % based numbers used by drawers
        Vector2 mv = DrawFunctions.GetVirtualVector(mouseCursorPos);

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
				DrawFunctions.ScreenDrawTexture(tx.get("invItemBG"), x, y, alpha: 0.5);
				if ( hovering ) {
					if ( !(wasHovering) ) EventHandler.SendNetworkEvent("UIStartHover");
					// hilight box
					DrawFunctions.ScreenDrawTexture(tx.get("invHilight"), x, y);
					hoveredInvStack = stackNum;
				}
				// draw item sprite
				MFInventoryItem item = DataLibrary.GetInstance().MFinventory[stackNum];
				DrawFunctions.ScreenDrawTextureWithinArea(item.getTexture(), x, y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT);

				// And move along!
				x += (INV_STACK_BUTTON_WIDTH + INV_STACK_BUTTON_MARGIN);
				stackNum++;
			}
			x = INV_STACK_BUTTON_START_X;
			y -= INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN_INV;
		}

		hoveringDropButton = mv.x >= INV_DROP_BUTTON_X && mv.x <= INV_DROP_BUTTON_X + INV_DROP_BUTTON_WIDTH && mv.y >= INV_DROP_BUTTON_Y && mv.y <= INV_DROP_BUTTON_Y + INV_DROP_BUTTON_HEIGHT;

        DrawMouseCursor();
        return;
	}
    
    ui void DrawArmoryScreen()
    {
        if (inventoryIsOpen) {
            EventHandler.SendNetworkEvent("CloseInventory");
        }
        DrawFunctions.ScreenDrawTexture(tx.get("armoryBG"), 0, 0, alpha: 1.0);
        double x = ITEM_SHOP_START_X;
		double y = ITEM_SHOP_START_Y;
        Vector2 mv = DrawFunctions.GetVirtualVector(mouseCursorPos);

        hoveringOverShop = (mv.x >= ITEM_SHOP_START_X);
        hoveredArmStack = -1;

        for (int i = 0; i < DataLibrary.GetInstance().armoryInventory.Size(); i++) {

            DrawFunctions.ScreenDrawTexture(tx.get("invItemBG"), x, y, alpha: 0.5);
            //Can't hover over a weapon if we already have something
            bool hovering = !uiGrabbedArm && (mv.x >= x && mv.x <= x + INV_STACK_BUTTON_WIDTH && mv.y >= y && mv.y <= y + INV_STACK_BUTTON_HEIGHT);
            if (hovering) {
                // hilight box
                DrawFunctions.ScreenDrawTexture(tx.get("invHilight"), x, y);
                hoveredShopNumber = i;
            }
			// draw item sprite
            MFInventoryItem item = DataLibrary.GetInstance().itemShopInventory[i];
            DrawFunctions.ScreenDrawTextureWithinArea(item.getTexture(), x, y, INV_STACK_BUTTON_WIDTH, INV_STACK_BUTTON_HEIGHT, INV_STACK_BUTTON_MARGIN_INNERPCT);

            DrawFunctions.ScreenDrawString(item.getName(), Font.CR_WHITE, journalFont, x + 0.09, y + 0.03);
            DrawFunctions.ScreenDrawString(item.getBuyPrice() .."", Font.CR_GREEN, journalFont, x + 0.4, y + 0.03);

            y += INV_STACK_BUTTON_HEIGHT + INV_STACK_BUTTON_MARGIN;
        }
    }

    play void clearGrabbedItem(bool putItBack = false) {
        if (!grabbedItem) { return; }
        if (!putItBack) {
            PoLogger.Log("inv", "Cleared grabbed item without placing it.");
            grabbedItem = NULL; grabbedItemIsFromShop = false; grabbedItemFromSlot = -1; return;
        }
        PoLogger.Log("inv", "Attempting to replace grabbed item in inventory");
        DataLibrary.GetInstance().InventoryAdd(grabbedItem.getClassName());
        grabbedItem = NULL; grabbedItemIsFromShop = false; grabbedItemFromSlot = -1;
    }

    override void WorldUnloaded(WorldEvent e)
    {
        //If an item is grabbed and we transition into another level, attempt to save it
        clearGrabbedItem(true);
    }

	override void NetworkProcess(ConsoleEvent e)
	{
        PlayerPawn p = PlayerPawn(players[e.Player].mo);

        if ( e.Name == "Action_BinnedGrabbedItem" ) { clearGrabbedItem(); p.A_PlaySound("po/inventory/bin", CHAN_VOICE); }
        else if ( e.Name == "CloseInventory" ) { inventoryIsOpen = false; clearGrabbedItem(true); }
        else if ( e.Name == "OpenInventory" ) { inventoryIsOpen = true; }
        else if ( e.Name == "ToggleInventory" ) { p.A_PlaySound("po/inventory/open", CHAN_VOICE); inventoryIsOpen = !inventoryIsOpen; clearGrabbedItem(true); }

        else if ( e.Name == "Action_ClickedInvStack" )
		{
			int inventorySlotNumber = e.Args[0];
			MFInventoryItem invItem = DataLibrary.GetInstance().MFinventory[inventorySlotNumber];

            //If we don't have a grabbed item and we've clicked on a non-empty stack, grab it.
			if (!grabbedItem) {
                if (invItem.getClassName() != "MFIEmpty") {
                    DataLibrary.GetInstance().InventoryRemove(inventorySlotNumber);
                    grabbedItem = invItem;
                    grabbedItemFromSlot = inventorySlotNumber;
                    p.A_PlaySound("po/inventory/up", CHAN_VOICE);
                }
                return;
            }
			//If we do have a grabbed item, put it where we've clicked. If we have an item in there already, it becomes the new grabbed item
            if (grabbedItemIsFromShop) {
                // If trying to put this in inventory from shop, check the price first
                if (p.CountInv("POCoin") < grabbedItem.getBuyPrice()) { p.A_PlaySound("po/deny", CHAN_VOICE); return; }
                else {
                    //Take the coin price and (if applicable) the consumed materials from the player's inventory
                    //Materials are checked previously - if insufficient materials, won't be able to pick it up from shop
                    p.TakeInventory("POCoin", grabbedItem.getBuyPrice());
                    Array<String> requirements; grabbedItem.getRequirements().Split(requirements, ",");
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
            DataLibrary.GetInstance().InventoryAdd(grabbedItem.getClassName(), inventorySlotNumber);
            clearGrabbedItem();

            //If there was already an item in this space, grab it now
			MFInventoryItem itemToGrab = (invItem.getClassName() == "MFIEmpty" ? NULL : invItem);
            if (itemToGrab) {
                grabbedItem = itemToGrab;
                grabbedItemFromSlot = inventorySlotNumber;
            }
		}
        else if ( e.Name == "Action_ClickedShopStack" )
        {
            int shopIndex = e.Args[0];
            MFInventoryItem invItem = DataLibrary.GetInstance().itemShopInventory[shopIndex];
            if (DataLibrary.InventoryIsFull()) { p.A_PlaySound("po/deny"); return; } //If our inventory is full, can't buy!
            
            //If we don't have an item already grabbed, grab this one
            if (!grabbedItem) {
                String newItemClassName = invItem.getClassName();
                grabbedItem = MFInventoryItem(new(newItemClassName)).Init();
                grabbedItemIsFromShop = true;
                p.A_PlaySound("po/inventory/up", CHAN_VOICE);
            } else {
                grabbedItemIsFromShop = false;
                grabbedItemFromSlot = -1;
            }
        }
        else if ( e.Name == "Action_UsedInventorySlot" )
        {
            int inventorySlotNumber = e.Args[0];
            MFInventoryItem invItem = DataLibrary.GetInstance().MFinventory[inventorySlotNumber];
            bool success = invItem.use();
            if (success) {
                DataLibrary.GetInstance().InventoryRemove(inventorySlotNumber);
            } else {
                p.A_PlaySound("po/deny");
            }
        }
        else if (e.Name == "Action_DroppedItemToShop") {
            if (!grabbedItem) { PoLogger.Log("inv", "Requested to drop an item to shop, but no item found!"); return; }
            if (grabbedItemIsFromShop) { clearGrabbedItem(); return; } //Just put it back if this item came from the shop
            if (grabbedItem.getSellPrice() == 0) { p.A_PlaySound("po/deny"); return; } // No sale price = this is a key item

            // OK, sell the item
            int sellPrice = grabbedItem.getSellPrice();
            p.GiveInventory("POCoin", sellPrice);
            clearGrabbedItem();
            p.A_PlaySound("po/sell");
        }
        else if (e.Name == "Action_ScrolledShop") {
            int direction = e.Args[0] ? 1 : -1;
            shopFirstItemIndex += direction;
            if (shopFirstItemIndex < 0) {
                shopFirstItemIndex = 0;
            }
        }
        else if ( e.Name == "Action_AdvancedDialog" ) {
            int destination = e.args[0];
            if (destination == 0) {
                destination = DataLibrary.ReadInt("eventDialogPage") + 1;
            }
            
            String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
            String dialogKey = "CONV_" .. eventDialogConversation .. "_" .. destination;
            String theString = StringTable.Localize("$" .. dialogKey);
            DataLibrary.GetInstance().dic.Insert("UIRequest_ClearDialog", "1");

            if (theString == "STOP" || theString == dialogKey) {
                //If this is a chest and it forces an event afterwards, run it now
                if (
                    DataLibrary.ReadData("eventDialogConversation") == "OPEN_CHEST" &&
                    (DataLibrary.GetInstance().chestToOpen && DataLibrary.GetInstance().chestToOpen.causeEvent > 0)
                ) {
                    DataLibrary.writeData(NULL, "ForceEvent", "runEvent" .. DataLibrary.GetInstance().chestToOpen.causeEvent);
                }
                DataLibrary.WriteData(NULL, "showEventDialog", "0");
                DataLibrary.WriteData(NULL, "eventDialogPage", "");
                DataLibrary.WriteData(NULL, "eventDialogConversation", "");
            }
            else {
                DataLibrary.WriteData(NULL, "eventDialogPage", destination .. "");
            }
        }
        else if (e.Name == "Action_CloseShopScreen" ) {
            clearGrabbedItem(true); //Clear grabbed item but put it back in inventory
            DataLibrary.WriteDataFromUI("OpenShopScreen", "0");
        }
        else if (e.Name == "Action_CloseArmoryScreen" ) {
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
            //If the dialogue screen is open, ignore the keypress. If shop/armory is open, close them but let the press through
            if (showEventDialog) { return true; }                        
            if (DataLibrary.ReadData("OpenArmoryScreen") == "1") { EventHandler.SendNetworkEvent("Action_CloseArmoryScreen"); }
            if (DataLibrary.ReadData("OpenShopScreen") == "1") { EventHandler.SendNetworkEvent("Action_CloseShopScreen"); }

            EventHandler.SendNetworkEvent("ToggleInventory");           
            return true;
        }

        if (inventoryIsOpen) {
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
                    if ( hoveredInvStack != -1 ) { EventHandler.SendNetworkEvent("Action_ClickedInvStack", hoveredInvStack); return true; }

                    if ( hoveringDropButton && grabbedItem && !grabbedItemIsFromShop && grabbedItem.getSellPrice() > 0) {
                        EventHandler.SendNetworkEvent("Action_BinnedGrabbedItem");
                        return true;
                    }

                    //If we have the item shop open, also handle shop-related clicks
                    if (DataLibrary.ReadData("OpenShopScreen") == "1") {
                        if (grabbedItem && hoveringOverShop) { EventHandler.SendNetworkEvent("Action_DroppedItemToShop"); return true; }
                        if (hoveredShopNumber != -1) { EventHandler.SendNetworkEvent("Action_ClickedShopStack", hoveredShopNumber); return true; }
                    }
                    return true;
                }
                if ( e.KeyScan == InputEvent.Key_Mouse2 )
                {
                    if ( hoveredInvStack != -1 ) { EventHandler.SendNetworkEvent("Action_UsedInventorySlot", hoveredInvStack); }
                    return true;
                }
                if (e.KeyScan >=2 && e.KeyScan <= 5) { //1 to 4, funnily enough
                    EventHandler.SendNetworkEvent("Action_UsedInventorySlot", e.KeyScan-2);
                    return true;
                }
                if (e.KeyScan == InputEvent.Key_MWheelDown || e.KeyScan == InputEvent.Key_MWheelUp) {
                    if (DataLibrary.ReadData("OpenShopScreen") == "1") {
                        if (shopItemsDisplayed == 6 && e.KeyScan == InputEvent.Key_MWheelDown) {
                            EventHandler.SendNetworkEvent("Action_ScrolledShop", true);
                        }
                        else if (shopFirstItemIndex > 0 && e.KeyScan == InputEvent.Key_MWheelUp) {
                            EventHandler.SendNetworkEvent("Action_ScrolledShop", false);
                        }
                    }
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
                    if (dialogParser.dialogOpacity >= 1.0) {
                        if (dialogParser.textPercentDisplayed >= 1.0 && dialogParser.parsedDialogOptions.Size() <= 1) {
                            EventHandler.SendNetworkEvent("Action_AdvancedDialog", 0);
                        }
                        else if (dialogParser.textPercentDisplayed >= 1.0 && dialogParser.hoveredDialogOption != -1) {
                            EventHandler.SendNetworkEvent("Action_AdvancedDialog", dialogParser.parsedDialogDestinations[dialogParser.hoveredDialogOption]);
                        }
                        else {
                            //If clicked before text is all displayed, set it to displayed
                            dialogParser.textPercentDisplayed = 1.0;
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
                //console.printf("\ckDEBUG: Blocked use key");
                return true;
            }
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
        //ReadLiveVars();
        RenderWeaponSlots();
        RenderPowerSlots();

		if ( automapactive ) { RenderAutomapScreen(); return; }
        
        if (DataLibrary.ReadData("OpenShopScreen") == "1") { DrawItemShopScreen(); }
        if (DataLibrary.ReadData("OpenArmoryScreen") == "1") { DrawArmoryScreen(); }
		
        DrawInvScreen();

        if ( DataLibrary.ReadData("showEventDialog") == "1" ) {
            dialogParser.ParseDialog();
            DrawDialog();
        } else {
            if (dialogParser.dialogOpacity > 0) {
                dialogParser.dialogOpacity = 0;
            }
        }
	}

    ui void ReadLiveVars() {
        //Massively handy thing by JP - activate this to read from a lump constantly and edit layout while Doom is running!
        int lumpindex = Wads.FindLump("LIVEVARS", 0, 0);
        String varData = Wads.ReadLump(lumpindex);
        Array<String> vars; varData.Split(vars, ",");
    }

    ui void RenderWeaponSlots() {
        double weaponX = WEAPON_START_X;
        double weaponY = WEAPON_START_Y;

        for (int i = 0; i < DataLibrary.getInstance().weaponInventorySize; i++) {
            POWeaponSlot w = DataLibrary.getWeaponSlot(i);
            if (w) {
                DrawFunctions.ScreenDrawTexture(w.getTexture(), weaponX, weaponY);
                let t = w.getElementTexture();
                if (t) {
                    DrawFunctions.ScreenDrawTexture(t, weaponX, weaponY);
                }
                let t2 = w.getPowerTexture();
                if (t2) {
                    DrawFunctions.ScreenDrawTexture(t2, weaponX, weaponY);
                }
            }
            weaponX += WEAPON_WIDTH;
        }
    }

    ui void RenderPowerSlots() {
        double powerX = POWERS_X;
        double powerY = POWERS_Y;

        int powerBiosuit = DataLibrary.ReadInt("PowerBiosuit");
        if (powerBiosuit) {
            DrawFunctions.ScreenDrawTextureWithinArea(tx.get("power1"), powerX, powerY, POWERS_SIZE, POWERS_SIZE);
            DrawFunctions.ScreenDrawString(powerBiosuit .. "", Font.CR_GREEN, journalFont, powerX + POWERS_TEXT_GAP, powerY);
        }
        powerY += POWERS_VERTICAL_GAP;        
    }

    ui void RenderAutomapScreen() {
        //Block out the automap if we're not playing on a skill that allows it!
        if ( G_SkillPropertyInt(SKILLP_ACSReturn) != 1 && DataLibrary.ReadInt("InFight") == 0) {
            PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
            DrawFunctions.ScreenDrawTexture(tx.get("blockMapSquares"), 0.5, 0.5, alpha: 1.0, centerX: true, centerY: true);
            double x = MAP_SQUARE_START_X;
            double y = MAP_SQUARE_START_Y + (MAP_SQUARE_DISTANCE_Y * 19);
            double playerX = p.pos.x / LevelHelper.TILE_SIZE;
            double playerY = p.pos.y / LevelHelper.TILE_SIZE;
            x += playerX * MAP_SQUARE_DISTANCE_X;
            y -= playerY * MAP_SQUARE_DISTANCE_Y;
            
            DrawFunctions.ScreenDrawTexture(tx.get("mapCounter"), x, y, centerX:true, centerY:true);
        }        
    }

    ///////////////////////////////////

    ui void DrawMouseCursor()
	{
		TextureID tex;
		double iconPadX = 0.01;
		double iconPadY = 0.01;
		double iconArea = 0.05;
        Vector2 v = DrawFunctions.GetVirtualVector(mouseCursorPos);

		Screen.DrawTexture(tx.get("mouseMiniCursorTex"), true,
						   mouseCursorPos.x, mouseCursorPos.y,
						   DTA_DestWidth, 24, DTA_DestHeight, 24);

        //The rest of this is only for the inventory screen
        if (!inventoryIsOpen) { return; }

        if (grabbedItem) {
            DrawFunctions.ScreenDrawTextureWithinArea(grabbedItem.getTexture(), v.x + iconPadX, v.y + iconPadY, iconArea, iconArea);
        }

		// tooltip-style text for grabbed / hovered item
		MFInventoryItem tooltipSubject;
		if ( grabbedItem ) { tooltipSubject = grabbedItem; }
		else if ( hoveredInvStack != -1 ) { tooltipSubject = DataLibrary.GetInstance().InventoryPeek(hoveredInvStack); }
        else if ( hoveredShopNumber != -1 ) { tooltipSubject = DataLibrary.GetInstance().itemShopInventory[hoveredShopNumber]; }
		else return;

		String toolTipText = tooltipSubject.getName();
		double textMargin = -0.04;
		Screen.DrawText(tinyFont, Font.CR_LIGHTBLUE,
						(v.x + textMargin) * DrawFunctions.UI_WIDTH,
						(v.y + textMargin) * DrawFunctions.UI_HEIGHT,
						toolTipText,
						DTA_VirtualWidth, DrawFunctions.UI_WIDTH,
						DTA_VirtualHeight, DrawFunctions.UI_HEIGHT);
        String descriptionKey = "INV_" .. tooltipSubject.getClassName();
		String descriptionText = StringTable.Localize("$" .. descriptionKey);
        if ((descriptionText == descriptionKey) || !descriptionText) {
            return;
        }
        DrawFunctions.ScreenDrawString(descriptionText, Font.CR_WHITE, tinyFont, 0.5, 0.75, lineHeight: 0.03, wrapWidth: 0.5);
	}
}
