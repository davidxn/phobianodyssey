class MFInventoryItem : Thinker abstract {

    virtual clearscope String myTexture() { return "SOULA0"; }
    virtual clearscope String myName() { return ""; }
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
}

class MFIMegasphere : MFInventoryItem {
    override String myTexture() { return "MEGAA0"; }
    override String myName() { return "Megasphere!"; }
    override bool use() {
        console.printf("Used a megasphere");
        return true;
    }
}

class MFIRadsuit : MFInventoryItem {
    override String myTexture() { return "SUITA0"; }
    override String myName() { return "Radiation suit"; }
    override bool use() {
        console.printf("Used a radiation suit");
        return true;
    }
}

class MFIMedikit : MFInventoryItem {
    override String myTexture() { return "MEDIA0"; }
    override String myName() { return "Medikit"; }
    override bool use() {
        PlayerPawn p; ThinkerIterator it = ThinkerIterator.Create("PlayerPawn"); p = PlayerPawn(it.Next());
        if (p.Health >= 100) {
            return false;
        }
        p.Health = min(p.Health + 25, 100);
        p.A_PlaySound("po/heal");
        console.printf("Used a medikit on %s", p.getClassName());
        return true;
    }
}

///////////////////////

class POWeaponSlot : Thinker abstract {
    
    String weaponElement;
    
    virtual clearscope String myTexture() { return "WSLOTNUN"; }
    virtual clearscope String myType() { return "None"; }

    POWeaponSlot Init(void) {
        ChangeStatNum(STAT_STATIC);
        return self;
    }
    
    clearscope TextureID getTexture() {
        return TexMan.CheckForTexture(myTexture(), TexMan.Type_MiscPatch);
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