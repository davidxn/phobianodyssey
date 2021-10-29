class MFInventoryItem : Thinker abstract {

    virtual clearscope String myTexture() { return "SOULA0"; }
    virtual clearscope String myName() { return ""; }
    virtual clearscope int getBuyPrice() { return 0; }
    virtual clearscope int getSellPrice() { return 0; }
    virtual clearscope bool isAvailable() { return true; }

    virtual virtualscope bool use() { return true; }

    MFInventoryItem Init(void) {
        ChangeStatNum(STAT_STATIC);
        return self;
    }
    
    clearscope String getName() { return myName(); }
    
    clearscope TextureID getTexture() {
        return TexMan.CheckForTexture(myTexture(), TexMan.Type_Sprite);
    }
    
}

class MFIEmpty : MFInventoryItem {

    override String myTexture() { return ""; }
    override String myName() { return ""; }
    override bool isAvailable() { return false; }
}

class MFIMegasphere : MFInventoryItem {

    override String myTexture() { return "MEGAA0"; }
    override String myName() { return "Megasphere"; }
    override int getBuyPrice() { return 2000; }
    override int getSellPrice() { return 1000; }
    
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        if (p.Health >= 200) {
            return false;
        }
        p.GiveInventory("MegasphereHealth", 1);
        return true;
    }
}

class MFIRadsuit : MFInventoryItem {
    override String myTexture() { return "SUITA0"; }
    override String myName() { return "Radsuit"; }
    override int getBuyPrice() { return 1000; }
    override int getSellPrice() { return 500; }
    
    override bool use() {
        return true;
    }
}

class MFIMedikit : MFInventoryItem {
    override String myTexture() { return "MEDIA0"; }
    override String myName() { return "Medikit"; }
    override int getBuyPrice() { return 100; }
    override int getSellPrice() { return 50; }
    
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        if (p.Health >= 100) {
            return false;
        }
        p.GiveInventory("Health", 50);
        p.A_PlaySound("po/heal");
        return true;
    }
}

class MFIStimpack : MFInventoryItem {
    override String myTexture() { return "STIMA0"; }
    override String myName() { return "Stimpack"; }
    override int getBuyPrice() { return 60; }
    override int getSellPrice() { return 30; }
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        if (p.Health >= 100) {
            return false;
        }
        p.GiveInventory("Health", 20);
        p.A_PlaySound("po/heal");
        return true;
    }
}

class MFIAmmoBox : MFInventoryItem {
    override String myTexture() { return "AMMOA0"; }
    override String myName() { return "Bullet Box"; }
    override int getBuyPrice() { return 30; }
    override int getSellPrice() { return 15; }
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        p.GiveInventory("POClip", 25);
        p.A_PlaySound("po/reload");
        return true;
    }
}

class MFISoulsphere : MFInventoryItem {
    override String myTexture() { return "SOULA0"; }
    override String myName() { return "Soulsphere"; }
    override int getBuyPrice() { return 1000; }
    override int getSellPrice() { return 500; }
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        if (p.Health >= 200) {
            return false;
        }
        p.A_PlaySound("misc/p_pkup");
        p.GiveInventory("HealthBonus", 100);
        return true;
    }
}

class MFIRiskyBoots : MFInventoryItem {
    override String myTexture() { return "BOT2A0"; }
    override String myName() { return "Risky Boots"; }
    override int getBuyPrice() { return 100; }
    override int getSellPrice() { return 100; }
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        p.TakeInventory("PoDanger", 100);
        p.GiveInventory("PoDanger", 99);
        p.A_PlaySound("po/magic");
        return true;
    }
}

class MFISneakyBoots : MFInventoryItem {
    override String myTexture() { return "BOT1A0"; }
    override String myName() { return "Sneaky Boots"; }
    override int getBuyPrice() { return 200; }
    override int getSellPrice() { return 100; }
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        p.TakeInventory("PoDanger", 100);
        p.A_PlaySound("po/magic");
        return true;
    }
}

class MFIHomingDevice : MFInventoryItem {
    override String myTexture() { return "HOMDA0"; }
    override String myName() { return "Homing Device"; }
    override int getBuyPrice() { return 200; }
    override int getSellPrice() { return 100; }
    
    override bool use() {
        PlayerPawn p = PlayerPawn(players[consoleplayer].mo);
        if (DataLibrary.ReadInt("DisableHomingDevice")) {
            p.A_PlaySound("po/deny");
            return false;
        }
        p.A_PlaySound("po/warp");
        EventHandler.SendNetworkEvent("CloseInventory");
        CallACS("useHomingDevice");
        return true;
    }
}

class MFITreasure1 : MFInventoryItem {
    override String myTexture() { return "TRESA0"; }
    override String myName() { return "\ckBlood Charm"; }
    override int getBuyPrice() { return 250; }
    override int getSellPrice() { return 250; }
    
    override bool use() {
        return false;
    }
}

class MFITreasure2 : MFInventoryItem {
    override String myTexture() { return "TRESB0"; }
    override String myName() { return "\ckDevil Ring"; }
    override int getBuyPrice() { return 500; }
    override int getSellPrice() { return 500; }
    
    override bool use() {
        return false;
    }
}

class MFITreasure3 : MFInventoryItem {
    override String myTexture() { return "TRESC0"; }
    override String myName() { return "\ckMagic Bangle"; }
    override int getBuyPrice() { return 750; }
    override int getSellPrice() { return 750; }
    
    override bool use() {
        return false;
    }
}

class MFITreasure4 : MFInventoryItem {
    override String myTexture() { return "TRESD0"; }
    override String myName() { return "\ckAngel Statue"; }
    override int getBuyPrice() { return 1000; }
    override int getSellPrice() { return 1000; }
    
    override bool use() {
        return false;
    }
}

class MFITreasure5 : MFInventoryItem {
    override String myTexture() { return "TRESE0"; }
    override String myName() { return "\ckGold Gross"; }
    override int getBuyPrice() { return 2500; }
    override int getSellPrice() { return 2500; }
    
    override bool use() {
        return false;
    }
}

class MFITreasure6 : MFInventoryItem {
    override String myTexture() { return "TRESF0"; }
    override String myName() { return "\ckDemon Crown"; }
    override int getBuyPrice() { return 5000; }
    override int getSellPrice() { return 5000; }
    
    override bool use() {
        return false;
    }
}

class MFIBookPower : MFInventoryItem {
    override String myTexture() { return "BUCHA0"; }
    override String myName() { return "\clPower Manual"; }
    override int getBuyPrice() { return 0; }
    override int getSellPrice() { return 0; }
    
    override bool use() {
        return false;
    }
}

class MFIBookSpeed : MFInventoryItem {
    override String myTexture() { return "BUCHB0"; }
    override String myName() { return "\clSpeed Manual"; }
    override int getBuyPrice() { return 0; }
    override int getSellPrice() { return 0; }
    
    override bool use() {
        return false;
    }
}

class MFIBookLuck : MFInventoryItem {
    override String myTexture() { return "BUCHC0"; }
    override String myName() { return "\clLuck Manual"; }
    override int getBuyPrice() { return 0; }
    override int getSellPrice() { return 0; }
    
    override bool use() {
        return false;
    }
}

class MFIBookSave : MFInventoryItem {
    override String myTexture() { return "BUCHC0"; }
    override String myName() { return "\clSave Manual"; }
    override int getBuyPrice() { return 0; }
    override int getSellPrice() { return 0; }
    
    override bool use() {
        return false;
    }
}

class MFIBookShotgun : MFInventoryItem {
    override String myTexture() { return "BLUPA0"; }
    override String myName() { return "\clShotgun Blueprint"; }
    override int getBuyPrice() { return 0; }
    override int getSellPrice() { return 0; }
    
    override bool use() {
        return false;
    }
}


///////////////////////

class POWeaponSlot : Thinker abstract {
    
    String weaponElement;
    String weaponPower;
    
    virtual clearscope String myTexture() { return "WSLOTNUN"; }
    virtual clearscope String myType() { return "None"; }
    virtual clearscope String myElement() { return weaponElement; }
    virtual clearscope String myPower() { return weaponPower; }

    POWeaponSlot Init(void) {
        ChangeStatNum(STAT_STATIC);
        return self;
    }
    
    clearscope TextureID getTexture() {
        return TexMan.CheckForTexture(myTexture(), TexMan.Type_MiscPatch);
    }
    
    clearscope TextureID getElementTexture() {
        if (self.weaponElement == "Blue")   { return TexMan.CheckForTexture("WSLOTEL1", TexMan.Type_MiscPatch); }
        if (self.weaponElement == "Red")    { return TexMan.CheckForTexture("WSLOTEL2", TexMan.Type_MiscPatch); }
        if (self.weaponElement == "Green")  { return TexMan.CheckForTexture("WSLOTEL3", TexMan.Type_MiscPatch); }
        if (self.weaponElement == "Yellow") { return TexMan.CheckForTexture("WSLOTEL4", TexMan.Type_MiscPatch); }
        return TexMan.CheckForTexture("WSLOTEL0", TexMan.Type_MiscPatch);
    }
    
    clearscope TextureID getPowerTexture() {
        if (self.weaponPower == "Power") { return TexMan.CheckForTexture("WSLOTPW1", TexMan.Type_MiscPatch); }
        if (self.weaponPower == "Speed") { return TexMan.CheckForTexture("WSLOTPW2", TexMan.Type_MiscPatch); }
        if (self.weaponPower == "Luck")  { return TexMan.CheckForTexture("WSLOTPW3", TexMan.Type_MiscPatch); }
        if (self.weaponPower == "Save")  { return TexMan.CheckForTexture("WSLOTPW4", TexMan.Type_MiscPatch); }
        return TexMan.CheckForTexture("WSLOTEL0", TexMan.Type_MiscPatch);
    }
    
    clearscope String getType() { return myType(); }
}

class POWeaponSlotEmpty : POWeaponSlot {
    override String myType() { return "None"; }
    override String myTexture() { return "WSLOTNUN"; }
}

class POWeaponSlotFist : POWeaponSlot {
    override String myType() { return "Fist"; }
    override String myTexture() { return "WSLOTFST"; }
}

class POWeaponSlotPistol : POWeaponSlot {
    override String myType() { return "Pistol"; }
    override String myTexture() { return "WSLOTPIS"; }
}

class POWeaponSlotShotgun : POWeaponSlot {
    override String myType() { return "Shotgun"; }
    override String myTexture() { return "WSLOTSHT"; }
}

class POWeaponSlotChaingun : POWeaponSlot {
    override String myType() { return "Chaingun"; }
    override String myTexture() { return "WSLOTCHN"; }
}

class POWeaponSlotLauncher : POWeaponSlot {
    override String myType() { return "RocketLauncher"; }
    override String myTexture() { return "WSLOTLAN"; }
}

class POWeaponSlotPlasma : POWeaponSlot {
    override String myType() { return "PlasmaRifle"; }
    override String myTexture() { return "WSLOTPLS"; }
}