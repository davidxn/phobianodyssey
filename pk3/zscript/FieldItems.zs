class POChest : FloatingSkull
{
    MFInventoryItem containedItem;
    int containedCoins;
    int containedAmmo;
    int containedAmmoType;
    bool hasBeenOpened;
    
    default {
        //$Arg0 Contents
        //$Arg0Tooltip Numeric content ID
        //$Arg1 Cash
        //$Arg1Tooltip Amount of cash in chest
        //$Arg2 Ammo
        //$Arg2Tooltip Ammo in chest
        //$Arg3 Ammo Type
        //$Arg4Tooltip Type of ammo in chest
    }
    States {
        Spawn:
            CHST A -1;
        Opened:
            CHST B -1 A_PlaySound("po/chest");
    }
    override bool Used (Actor user)
    {
        if (user && !hasBeenOpened)
        {
            if (self.containedItem && DataLibrary.GetInstance().InventoryIsFull()) {
                DataLibrary.SetChestToOpen(self);
                DataLibrary.StartConversation("CANNOT_TAKE_CHEST");
                return false;
            }

            self.SetStateLabel("Opened");
            DataLibrary.SetChestToOpen(self);
            DataLibrary.StartConversation("OPEN_CHEST");
            if (self.containedItem) {
                DataLibrary.InventoryAdd(self.containedItem.getClassName(), -1);
            }
            if (self.containedAmmo) {
                switch (self.containedAmmoType) {
                    case 2: user.GiveInventory("POShell", containedAmmo); break;
                    case 3: user.GiveInventory("PORocket", containedAmmo); break;
                    case 4: user.GiveInventory("POCell", containedAmmo); break;
                    default: user.GiveInventory("POClip", containedAmmo); break;
                }
                
            }
            if (self.containedCoins) {
                user.GiveInventory("POCoin", containedCoins);
            }
            hasBeenOpened = true;
            return true;
        }

        return false;
    }
    
    override void PostBeginPlay() {
        int itemId = self.args[0];
        if (itemId > 0) {
            String classname = DataLibrary.inst().ReadClassnameByID(itemID);
            containedItem = MFInventoryItem(new(classname)).Init();
        }
        containedCoins = self.args[1];
        containedAmmo = self.args[2];
        containedAmmoType = self.args[3];
    }
}

class CoinBag : FloatingSkull
{
    states {
        Spawn:
            M002 A -1;
    }
}

class FireballTrap : FloatingSkull
{
    int ticksSinceLast;
    int period;
    int phase;
    
    default {
        //$Sprite BAL1A0
        //$Arg0 Period
        //$Arg1 Phase
        Mass 0;
        +DONTTHRUST;
    }
    
    states {
        Spawn:
            TNT1 A -1;
    }
    
    override void PostBeginPlay() {
        int period = self.args[0];
        if (!period) { period = 70; }
        ticksSinceLast = self.args[1];
        self.period = period;
    }
    
    override void Tick() {
        ticksSinceLast++;
        if (ticksSinceLast >= period) {
            ticksSinceLast = 0;
            A_SpawnProjectile("POFireball", 16.0, 0.0, 0.0, CMF_AIMDIRECTION);
        }
        super.Tick();
    }
}

class SmallBush : Actor
{
    Default {
        //$category "Obstacles"
        Radius 15;
        Height 160;
        +SOLID;
    }
	States
	{
		Spawn:
			LMAO A -1;
	}
}

class SemiLargeTree : Actor
{
    Default {
        //$category "Obstacles"
        Radius 15;
        Height 180;
        +Solid;
    }
	States
	{
		Spawn:
		 HOHO A -1;
	}
}

class LargeTree : Actor
{
	States
	{
		Spawn:
		 TIHI A -1;
	}
}

class PoWaterFountain : FloatingSkull
{
    Default {
        Radius 2;
        Height 2;
        Scale 1;
        Alpha 0.75;
        +NOBLOCKMAP;
        +MOVEWITHSECTOR;
    }
  States
  {
  Spawn:
    WFOU ABCD 3;
    Loop;
  }
}

class PoCharacterElan : FloatingSkull
{
    Default {
        Radius 16;
        Height 2;
        Scale 1;
    }
  States
  {
  Spawn:
    CRSH A -1;
    Loop;
  }
}

class PoCharacterEzo : FloatingSkull
{
    Default {
        Radius 16;
        Height 2;
        Scale 1;
    }
  States
  {
  Spawn:
    CRWP A -1;
    Loop;
  }
}

