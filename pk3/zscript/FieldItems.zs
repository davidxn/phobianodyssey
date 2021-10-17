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
                    case 2: user.GiveInventory("Shell", containedAmmo); break;
                    case 3: user.GiveInventory("RocketAmmo", containedAmmo); break;
                    case 4: user.GiveInventory("Cell", containedAmmo); break;
                    default: user.GiveInventory("Clip", containedAmmo); break;
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
        switch (itemId) {
            case 1: containedItem = new("MFIMegasphere"); break;
            case 2: containedItem = new("MFIRadsuit"); break;
            case 3: containedItem = new("MFIMedikit"); break;
            case 4: containedItem = new("MFIStimpack"); break;
            case 5: containedItem = new("MFIAmmoBox"); break;
            case 6: containedItem = new("MFISoulsphere"); break;
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
