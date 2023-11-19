class DialogParser {

    ui String parsedDialogString;
    ui String parsedDialogTexture;
    ui MFInventoryItem parsedDialogChestItem;
    ui String parsedDialogType;
    ui Array<String> parsedDialogOptions;
    ui Array<int> parsedDialogDestinations;
    ui double dialogOpacity;
    ui double textPercentDisplayed;
    ui int hoveredDialogOption;

    ui void ClearDialog() {
        textPercentDisplayed = 0;
        parsedDialogString = "";
        parsedDialogChestItem = null;
        parsedDialogOptions.Clear();
        parsedDialogDestinations.Clear();
        hoveredDialogOption = -1;
    }

    ui void ParseDialog() {
    	if (!parsedDialogString) {
        	String eventDialogConversation = DataLibrary.ReadData("eventDialogConversation");
        	int eventDialogPage = DataLibrary.ReadInt("eventDialogPage");

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

                if (tokenType == "F") { //Indicates face texture to use
                    parsedDialogTexture = tokenValue;
                }
                if (tokenType == "R") { //Response
                    tokenValue.Substitute("_", " ");
                    parsedDialogOptions.push(tokenValue);
                }
                if (tokenType == "D") { //Destination (immediately follows response, otherwise response has no effect on flow)
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
            }

            //If there's a chest item mentioned, get information about the chest
	        if (parsedDialogString.IndexOf("$chestitem$") == 0) { return; }

	        POChest chest = DataLibrary.GetInstance().chestToOpen;
	        if (chest.containedItem) {
	            parsedDialogString.Substitute("$chestitem$", "the " .. chest.containedItem.getName());
	            parsedDialogChestItem = chest.containedItem;
	            return;
	        }

            //No item - check for coins or ammo instead
            if (chest.containedCoins) {
                parsedDialogString.Substitute("$chestitem$", (chest.containedCoins .. " coins")); return;
            }

            if (chest.containedAmmo) {
                String ammoType = "bullets";
                switch (chest.containedAmmoType) {
                    case 2: ammoType = "shells"; break;
                    case 3: ammoType = "rockets"; break;
                    case 4: ammoType = "plasma cells"; break;
                }
                parsedDialogString.Substitute("$chestitem$", (chest.containedAmmo .. " " .. ammoType));
                return;
            }

            parsedDialogString = "There is nothing in the chest. That's probably a bug.";
        }
    }
}