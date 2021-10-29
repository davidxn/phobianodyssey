class DataLibrary : Thinker
{
    //Level status index corresponds to map number
    Dictionary dic;
    Dictionary monsterParties;
    Dictionary monsterPops;
    Array<MFInventoryItem> MFinventory;
    Array<POWeaponSlot> weaponSlots;
    int inventorySize;
    int weaponInventorySize;
    POChest chestToOpen;
    Array<MFInventoryItem> itemShopInventory;
    Array<POWeaponSlot> armoryInventory;
    
    //Quick, make this a static thinker when we initialize
    DataLibrary Init(void)
	{
		ChangeStatNum(STAT_STATIC);
        dic = Dictionary.Create();
        monsterParties = Dictionary.Create();
        monsterPops = Dictionary.Create();
        inventorySize = 4;
        weaponInventorySize = 3;
        

        //Set up inventory slots
        for (int i = 0; i < inventorySize; i++) {
            MFInventoryItem newItem = MFInventoryItem(new("MFIEmpty")).Init();
            MFinventory.Push(newItem);
        }
        
        //Set up the initial shop inventory
        itemShopInventory.push(new("MFIStimpack").Init());
        itemShopInventory.push(new("MFIAmmoBox").Init()); 
        itemShopInventory.push(new("MFIHomingDevice").Init());
        
        //Set up weapon slots
        weaponSlots.push(new("POWeaponSlotFist").Init());
        for (int i = 0; i < 4; i++) {
            POWeaponSlot w = POWeaponSlot(new("POWeaponSlotEmpty").Init());
            weaponSlots.push(w);
        }
        
        int lumpindex = Wads.FindLump('MPARTY', 0, 0);
        String lumpdata = Wads.ReadLump(lumpindex);

        Array<String> lines; lumpdata.Split(lines, "\n");
        for (int i = 0; i < lines.Size(); i++)
        {
            String line = lines[i];
            if (line.Length() < 2) { continue; } //In the absence of trim()
            Array<String> lineData; line.Split(lineData, ",");
            String partyName = lineData[0];
            monsterParties.Insert(partyName .. "-Name", lineData[1]);
            for (int t = 2; t < lineData.Size(); t++) {
                if (lineData[t] == "NONE") { continue; }
                monsterParties.Insert(partyName .. "-" .. t-2, lineData[t]);
                
            }
        }
        
        // ---
        
        lumpindex = Wads.FindLump('MPOPUL', 0, 0);
        lumpdata = Wads.ReadLump(lumpindex);
        Array<String> mPops; lumpdata.Split(mPops, "\n");
        for (int i = 0; i < mPops.Size(); i++)
        {
            String line = mPops[i];
            if (line.Length() < 2) { continue; } //In the absence of trim()
            Array<String> lineData; line.Split(lineData, "=");
            String popId = lineData[0];
            monsterPops.Insert(popId, lineData[1]);
        }
        
        // ---
        
        lumpindex = Wads.FindLump('SQUAREDT', 0, 0);
        lumpdata = Wads.ReadLump(lumpindex);
        Array<String> squareData; lumpdata.Split(squareData, "\n");
        for (int i = 0; i < squareData.Size(); i++)
        {
            String line = squareData[i];
            if (line.Length() < 2) { continue; } //In the absence of trim()
            Array<String> lineData; line.Split(lineData, "=");
            String key = lineData[0];
            dic.Insert(key, lineData[1]);
        }
        
        // ---
        
        lumpindex = Wads.FindLump('CLASSDAT', 0, 0);
        lumpdata = Wads.ReadLump(lumpindex);
        Array<String> itemData; lumpdata.Split(itemData, "\n");
        for (int i = 0; i < itemData.Size(); i++) {
            String line = itemData[i];
            if (line.Length() < 2) { continue; } //In the absence of trim()
            Array<String> lineData; line.Split(lineData, ",");
            String key = "ItemID" .. lineData[0];
            dic.Insert(key, lineData[1]);
        }
        
		return self;
	}

    static DataLibrary inst(void)
	{
		ThinkerIterator it = ThinkerIterator.Create("DataLibrary", STAT_STATIC);
		let p = DataLibrary(it.Next());
		if (p) return p;
        return new("DataLibrary").Init();
	}
    
    static clearscope DataLibrary GetInstance(void)
    {
		ThinkerIterator it = ThinkerIterator.Create("DataLibrary", STAT_STATIC);
		let p = DataLibrary(it.Next());
		if (p) return p;
        return NULL;
    }
    
    //Static methods for calling from ACS - these will create an instance of the thinker if it doesn't already exist
    static void WriteData(Actor activator, String position, String value) { DataLibrary.inst().dic.Insert(position, value); }
    
    static clearscope void WriteDataFromUI(String position, String value) { DataLibrary.GetInstance().dic.Insert(position, value); }
    
    static clearscope String ReadData(String position) { return DataLibrary.GetInstance().dic.At(position); }
    static clearscope int ReadInt(String position) { return DataLibrary.GetInstance().dic.At(position).ToInt(); }
    static clearscope double ReadDouble(String position) { return DataLibrary.GetInstance().dic.At(position).ToDouble(); }
    static String ReadClassnameByID(int id) { return DataLibrary.inst().dic.At("ItemID" .. id); }
    
    //////////////////////////////////////////////
    // Item Inventory
    //////////////////////////////////////////////
    
    static bool InventoryAdd(String classname, int slot) {
        let thing = MFInventoryItem(new(classname)).Init();
        if (slot >= 0 && slot < DataLibrary.inst().inventorySize) {
            DataLibrary.inst().MFinventory[slot] = thing;
            //console.printf("DEBUG: Added %s to inventory at position %d", classname, slot);
            return true;
        }
        
        //If no slot, search through until we find an empty one. If no room, return false
        for (int i = 0; i < DataLibrary.inst().inventorySize; i++) {
            if (DataLibrary.inst().MFinventory[i].getClassName() == "MFIEmpty") {
                DataLibrary.inst().MFinventory[i] = thing;
                //console.printf("DEBUG: Added %s to inventory at position %d", classname, i);
                return true;
            }
        }
        return false;
    }
    
    static clearscope bool InventoryIsFull() {
        for (int i = 0; i < DataLibrary.GetInstance().inventorySize; i++) {
            if (DataLibrary.GetInstance().MFinventory[i].getClassName() == "MFIEmpty") {
                return false;
            }
        }
        return true;
    }

	static bool InventoryRemove(int i)
	{
        MFinventoryItem inventoryItem = DataLibrary.GetInstance().MFinventory[i];
        if (inventoryItem.getClassName() == "MFIEmpty") {
            return false;
        }
        DataLibrary.inst().MFinventory[i] = MFInventoryItem(new("MFIEmpty")).Init();
        return inventoryItem;
	}
    
    static clearscope MFinventoryItem InventoryPeek(int i) {
        MFinventoryItem inventoryItem = DataLibrary.GetInstance().MFinventory[i];
        return inventoryItem;
    }
    
    static clearscope int InventoryHas(String classname) {
        for (int i = 0; i < DataLibrary.GetInstance().inventorySize; i++) {
            if (DataLibrary.GetInstance().MFinventory[i].getClassName() == classname) {
                return i;
            }
        }
        return -1;
    }
    
    static void InventoryExpand(int slots) {
        if (slots < DataLibrary.GetInstance().MFinventory.Size()) {
            return;
        }
        while (DataLibrary.GetInstance().MFinventory.Size() < slots) {
            MFInventoryItem newItem = MFInventoryItem(new("MFIEmpty")).Init();
            DataLibrary.GetInstance().MFinventory.Push(newItem);
        }
    }
    
    //////////////////////////////////////////
    // Weapon Inventory
    //////////////////////////////////////////
    
    static clearscope POWeaponSlot getWeaponSlot(int i) {
        return DataLibrary.GetInstance().weaponSlots[i];
    }
    
    static clearscope int getNextFreeWeaponSlot() {
        for (int i = 0; i < DataLibrary.GetInstance().weaponInventorySize; i++) {
            POWeaponSlot s = DataLibrary.GetInstance().WeaponSlots[i];
            if (s.getClassName() == "POWeaponSlotEmpty") {
                return i;
            }
        }
        return -1;
    }
    
    static void setWeaponSlot(int i, POWeaponSlot s) {
        DataLibrary.inst().weaponSlots[i] = s;
    }
    
    static void AddWeapon(String type, String element, String power) {
        int i = DataLibrary.getNextFreeWeaponSlot();
        if (i == -1) {
            //No free slots!
            return;
        }
        type = "PoWeaponSlot" .. type;
        POWeaponSlot s = POWeaponSlot(new(type)).Init();
        if (!s) {
            console.printf("Bad weapon type: %s", type);
        }
        s.weaponElement = (element != "") ? element : "None";
        s.weaponPower = (power != "") ? power : "None";
        DataLibrary.inst().setWeaponSlot(i, s);
    }
    
    static void RemoveWeapon(int i) {
        DataLibrary.GetInstance().WeaponSlots[i] = POWeaponSlot(new("POWeaponSlotEmpty")).Init();
    }
    
    static bool HasWeaponType(String type) {
        for (int i = 0; i < DataLibrary.GetInstance().weaponInventorySize; i++) {
            if (DataLibrary.getWeaponSlot(i).getType() == type) { return true; }
        }
        return false;
    }
    
    //////////////////////////////////////////
    // Square Data
    //////////////////////////////////////////
    
    static String ReadMonsterParty(String party, String slot)
    {
        String key = party .. "-" .. slot;
        return DataLibrary.inst().monsterParties.At(key);
    }
    
    static String ChooseMonsterParty(int mapnum, int square) {
    
        //To choose a monster party, get the population ID of this square
        String key = "MP-" .. mapnum .. "-" .. square;
        String popId = DataLibrary.GetInstance().ReadData(key);

        //Ask the monsterpop dictionary which parties correspond to this population ID
        //console.printf("DEBUG: Key %s has monster population ID %s", key, popId);
        return ChooseMonsterPartyFromPopulationID(popId);
    }
    
    static String ChooseMonsterPartyFromPopulationID(String popId) {
        //Get the parties that correspond to this monster population
        String monsterPartyString = DataLibrary.inst().monsterPops.At(popId);
        //console.printf("DEBUG: Monster parties: %s", monsterPartyString);
        //Now split the string and return a name
        Array<String> monsterParties; monsterPartyString.Split(monsterParties, ",");
        if (monsterParties.Size() == 0) {
            console.printf("WARNING: No monster parties set for population %s", popId);
            DataLibrary.inst().WriteData(null, "NextMonsterParty", "ZombieWeak");
            DataLibrary.inst().WriteData(null, "NextMonsterPartyName", "Nobody really");
            return "ZombieWeak";
        }
        
        String chosenParty = monsterParties[random(0, monsterParties.Size()-1)];
        //console.printf("DEBUG: Chosen party is: %s", chosenParty);
        DataLibrary.inst().WriteData(null, "NextMonsterParty", chosenParty);
        String chosenPartyName = DataLibrary.inst().ReadMonsterParty(chosenParty, "Name");
        chosenPartyName.Replace("_", " ");
        DataLibrary.inst().WriteData(null, "NextMonsterPartyName", chosenPartyName);
        return chosenParty;
    }
    
    static int ReadDangerValue(int mapnum, int square)
    {
        String key = "DN-" .. mapnum .. "-" .. square;
        int value = DataLibrary.ReadInt(key);
        int cheatValue = DataLibrary.ReadInt("CheatForceDangerLevel");
        if (cheatValue != 0) {
            value = cheatValue;
        }
        return value;
    }
    
    static int LoadMapProperties(Actor activator)
    {
        MapDescriber m; ThinkerIterator it = ThinkerIterator.Create("MapDescriber");
        while (m = MapDescriber(it.Next() ) ) {
            DataLibrary.inst().WriteData(null, "ArenaMap", m.args[1] .. "");
            DataLibrary.inst().WriteData(null, "SpecialArenaMap", m.args[2] .. "");
            return m.args[0];
        }
        return 0;
    }
    
    static void setChestToOpen(POChest chest) {
        DataLibrary.GetInstance().chestToOpen = chest;
    }
    
    static clearscope POChest getChestToOpen() {
        return DataLibrary.GetInstance().chestToOpen;
    }
    
    static void startConversation(String convId) {
        DataLibrary.WriteData(null, "eventDialogPage", "1");
        DataLibrary.WriteData(null, "eventDialogConversation", convId);
        DataLibrary.WriteData(null, "showEventDialog", "1");
    }
    
    static void outputData(int which) {
        Dictionary theDictionary;
        
        if (which == 0) { theDictionary = DataLibrary.getInstance().dic; }
        if (which == 1) { theDictionary = DataLibrary.getInstance().monsterParties; }
        if (which == 2) { theDictionary = DataLibrary.getInstance().monsterPops; }
        
        DictionaryIterator d = DictionaryIterator.Create(theDictionary);

        console.printf("\ckDictionary Contents");
        while (d.Next()) {    
            console.printf("\ck%-30s \cl%s", d.Key(), d.Value());
        }
    }
    
}
