class POFist : Fist replaces Fist {
    Default {
      Weapon.SelectionOrder 3700;
      Weapon.Kickback 100;
      Weapon.SlotNumber 1;
      Obituary "$OB_MPFIST";
      Tag "$TAG_FIST";
      +WEAPON.WIMPY_WEAPON;
      +WEAPON.MELEEWEAPON;
      -INVENTORY.UNDROPPABLE;
    }
    
      States
      {
      Ready:
        PUNG A 1 A_WeaponReady;
        Loop;
      Deselect:
        PUNG A 1 A_Lower(12);
        Loop;
      Select:
        PUNG A 1 A_Raise(12);
        Loop;
      Fire:
        PUNG B 2;
        TNT1 A 0 A_JumpIfInventory("PowerStrength", 1, "Berserked");
        PUNG C 2 A_CustomPunch(random(5, 8), TRUE);
        Goto PunchEnd;
      Berserked:
        PUNG C 3 A_CustomPunch(20 + random(5, 8), TRUE);
      PunchEnd:
        PUNG D 5;
        PUNG C 5;
        PUNG B 4 A_ReFire;
        Goto Ready;
      }
}

class POWeapon : Weapon {
    
    String myWeaponType;
    String myElement;
    String myPower;
    property WeaponType : myWeaponType;
    property Element : myElement;
    property Power : myPower;
    Default {
        Weapon.AmmoGive 0;
        POWeapon.WeaponType "Pistol";
        POWeapon.Element "None";
        POWeapon.Power "None";
        Weapon.SlotNumber 2;
        
        Weapon.SelectionOrder 1900;
		Obituary "$OB_MPPISTOL";
		+WEAPON.WIMPY_WEAPON;
		Inventory.Pickupmessage "$PICKUP_PISTOL_DROPPED";
		Tag "$TAG_PISTOL";
    }
    
    States
	{
	Ready:
        PISG A 0 { invoker.changeWeaponType(invoker.myWeaponType, invoker.myElement, invoker.myPower); }
		PISG A 0 A_JumpIf(invoker.myWeaponType == "Pistol", "ReadyPistol");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "Shotgun", "ReadyShotgun");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "Chaingun", "ReadyChaingun");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "RocketLauncher", "ReadyRocketLauncher");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "PlasmaRifle", "ReadyPlasmaRifle");
	Deselect:
        #### A 1 A_Lower(18);
        Loop;
    Select:
		PISG A 0 A_JumpIf(invoker.myWeaponType == "Pistol", "SelectPistol");
		PISG A 0 A_JumpIf(invoker.myWeaponType == "Shotgun", "SelectShotgun");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "Chaingun", "SelectChaingun");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "RocketLauncher", "SelectRocketLauncher");
        PISG A 0 A_JumpIf(invoker.myWeaponType == "PlasmaRifle", "SelectPlasmaRifle");
        Stop;
	Fire:
        #### A 0 A_JumpIf(invoker.myWeaponType == "Pistol", "FirePistol");
        #### A 0 A_JumpIf(invoker.myWeaponType == "Shotgun", "FireShotgun");
        #### A 0 A_JumpIf(invoker.myWeaponType == "Chaingun", "FireChaingun");
        #### A 0 A_JumpIf(invoker.myWeaponType == "RocketLauncher", "FireRocketLauncher");
        #### A 0 A_JumpIf(invoker.myWeaponType == "PlasmaRifle", "FirePlasmaRifle");
	Flash:
        #### A 0 A_JumpIf(invoker.myWeaponType == "Pistol", "FlashPistol");
        #### A 0 A_JumpIf(invoker.myWeaponType == "Shotgun", "FlashShotgun");
        #### A 0 A_JumpIf(invoker.myWeaponType == "Chaingun", "FlashChaingun");
        #### A 0 A_JumpIf(invoker.myWeaponType == "RocketLauncher", "FlashRocketLauncher");
        #### A 0 A_JumpIf(invoker.myWeaponType == "PlasmaRifle", "FlashPlasmaRifle");
    Spawn:
        TNT1 A 1;
		PIST A -1;
		Stop;

    // Pistol!
    ReadyPistol:
		PISG A 1 A_WeaponReady;
		Loop;
	SelectPistol:
		PISG A 1 A_Raise(12);
		Loop;
	FirePistol:
        PISG A 0 A_JumpIfInventory("POClip", 1, "FirePistolOK");
        PISG A 4;
        PISG B 4 A_PlaySound("po/empty", CHAN_WEAPON);
        PISG C 3;
        PISG B 3;
        PISG A 0 A_Jump(255, "ReadyPistol");
    FirePistolOK:
		PISG A 4;
        PISG B 0 A_PlaySound("weapons/pistol", CHAN_WEAPON);
		PISG B 0 firePistolBullets();
        PISG B 0 A_TakeInventory("POClip", 1);
        PISG B 0 A_JumpIf(invoker.myPower == "Speed", "SpeedyPistolOK");
        PISG B 6 A_GunFlash("FlashPistol");
		PISG C 4;
		PISG B 5 A_ReFire;
		Goto ReadyPistol;
    SpeedyPistolOK:
        PISG B 6 A_GunFlash;
        PISG B 1;
        PISG B 1 A_ReFire;
        Goto ReadyPistol;
	FlashPistol:
		PISF A 7 Bright A_Light1;
		Goto LightDone;
    
    // Shotgun!
    ReadyShotgun:
        SHTG A 1 A_WeaponReady;
        Loop;
    SelectShotgun:
        SHTG A 1 A_Raise(12);
        Loop;
    FireShotgun:
        SHTG A 0 A_JumpIfInventory("POShell", 1, "FireShotgunOK");
        SHTG A 4 A_PlaySound("po/empty", CHAN_WEAPON);
        SHTG A 0 A_Jump(255, "ReadyShotgun");
    FireShotgunOK:
        SHTG A 1;
        SHTG A 0 fireShotgunBullets();
        SHTG A 0 A_PlaySound ("weapons/shotgf", CHAN_WEAPON);
        SHTG A 0 A_TakeInventory("POShell", 1);
        SHTG A 7 A_GunFlash("FlashShotgun");
        SHTG A 0 A_JumpIf(invoker.myPower == "Speed", "SpeedyShotgunOK");
        SHTG BC 5;
        SHTG D 4;
        SHTG CB 5;
        SHTG A 3;
        SHTG A 7 A_ReFire;
        Goto ReadyShotgun;
    SpeedyShotgunOK:
        SHTG BC 3;
        SHTG D 3;
        SHTG CB 3;
        SHTG A 2;
        SHTG A 5 A_ReFire;
        Goto ReadyShotgun;
    FlashShotgun:
        SHTF A 4 Bright A_Light1;
        SHTF B 3 Bright A_Light2;
        Goto LightDone;

    //Chaingun!
    ReadyChaingun:
        CHGG A 1 A_WeaponReady;
        Loop;
    SelectChaingun:
        CHGG A 1 A_Raise(12);
        Loop;
    FireChaingun:
        CHGG A 0 A_JumpIfInventory("POClip", 1, "FireChaingunOK");
        CHGG A 4 A_PlaySound("po/empty", CHAN_WEAPON);
        CHGG A 0 A_Jump(255, "ReadyChaingun");
    FireChaingunOK:
        CHGG A 0 A_JumpIf(invoker.myPower == "Speed", "SpeedyChaingunOK");
        CHGG A 0 A_PlaySound("weapons/chngun", CHAN_WEAPON);
        CHGG A 0 A_GunFlash("FlashChaingun");
        CHGG A 4 fireChaingunBullets();
        CHGG A 0 A_TakeInventory("POClip", 1);
        CHGG B 0 A_PlaySound("weapons/chngun", CHAN_WEAPON);
        CHGG B 0 A_GunFlash("FlashChaingun2");
        CHGG B 4 fireChaingunBullets();
        CHGG B 0 A_TakeInventory("POClip", 1);
        CHGG B 0 A_ReFire;
        Goto ReadyChaingun;
    SpeedyChaingunOK:
        CHGG A 0 A_PlaySound("weapons/chngun", CHAN_WEAPON);
        CHGG A 0 A_GunFlash("FlashChaingun");
        CHGG A 3 fireChaingunBullets();
        CHGG A 0 A_TakeInventory("POClip", 1);
        CHGG B 0 A_PlaySound("weapons/chngun", CHAN_WEAPON);
        CHGG B 0 A_GunFlash("FlashChaingun2");
        CHGG B 3 A_FireBullets(5.6, 0, 1, 5, "BulletPuff");
        CHGG B 0 A_TakeInventory("POClip", 1);
        CHGG B 0 A_ReFire;
        Goto ReadyChaingun;
    FlashChaingun:
        CHGF A 2 Bright A_Light1;
        Goto LightDone;
    FlashChaingun2:
        CHGF B 2 Bright A_Light2;
        Goto LightDone;

    //Rocket launcher!
    ReadyRocketLauncher:
        MISG A 1 A_WeaponReady;
        Loop;
    SelectRocketLauncher:
        MISG A 1 A_Raise(12);
        Loop;
    FireRocketLauncher:
        MISG B 8 A_GunFlash;
        MISG B 12 A_FireMissile;
        MISG B 0 A_ReFire;
        Goto ReadyRocketLauncher;
    FlashRocketLauncher:
        MISF A 3 Bright A_Light1;
        MISF B 4 Bright;
        MISF CD 4 Bright A_Light2;
        Goto LightDone;

    //Plasma!
    ReadyPlasmaRifle:
        PLSG A 1 A_WeaponReady;
        Loop;
    SelectPlasmaRifle:
        PLSG A 1 A_Raise(12);
        Loop;
    FirePlasmaRifle:
        PLSG A 3 A_FirePlasma;
        PLSG B 20 A_ReFire;
        Goto ReadyPlasmaRifle;
    FlashPlasmaRifle:
        PLSF A 4 Bright A_Light1;
        Goto LightDone;
        PLSF B 4 Bright A_Light1;
        Goto LightDone;

	}
    
    action void firePistolBullets() {
        String puffClass = ("BulletPuff" .. invoker.myElement);
        int baseDamage = 8;
        int maxBonusDamage = 5;
        if (invoker.myPower == "Power") { baseDamage += 10; }
        if (invoker.myPower == "Speed") { baseDamage -= 2; maxBonusDamage += 2; }
        A_FireBullets(3.5, 0.5, 1, baseDamage + random(0,maxBonusDamage), puffClass, FBF_NORANDOM);
    }
    
    action void fireShotgunBullets() {
        String puffClass = ("BulletPuff" .. invoker.myElement);
        int baseDamage = 8;
        if (invoker.myPower == "Power") { baseDamage += 1; }
        if (invoker.myPower == "Speed") { baseDamage -= 1; }
        A_FireBullets (5.6, 0, 7, baseDamage + random(0,5), puffClass, FBF_NORANDOM);
    }
    
    action void fireChaingunBullets() {
        String puffClass = ("BulletPuff" .. invoker.myElement);
        int baseDamage = 8;
        if (invoker.myPower == "Power") { baseDamage += 2; }
        if (invoker.myPower == "Speed") { baseDamage -= 3; }
        A_FireBullets (5.6, 0, 1, baseDamage + random(0,5), puffClass, FBF_NORANDOM);
    }
    
    void changeWeaponType(String type, String element, String power) {
        self.myWeaponType = type;
        if (type == "Pistol" || type == "Chaingun") {
            self.AmmoType1 = "Clip";
        }
        if (type == "Shotgun") {
            self.AmmoType1 = "Shell";
        }
        if (type == "RocketLauncher") {
            self.AmmoType1 = "RocketAmmo";
        }
        if (type == "PlasmaRifle") {
            self.AmmoType1 = "Cell";
        }
        
        element = element ? element : "None";
        power = power ? power : "None";
        self.myElement = element;
        self.myPower = power;
        self.DamageType = element;
    }
}

//The weapon slots all inherit from the unified weapon
class POWeapon2 : POWeapon {
    Default {
        Weapon.SlotNumber 2;
    }
}
class POWeapon3 : POWeapon {
    Default {
        Weapon.SlotNumber 3;
    }
}
class POWeapon4 : POWeapon {
    Default {
        Weapon.SlotNumber 4;
    }
}
class POWeapon5 : POWeapon {
    Default {
        Weapon.SlotNumber 5;
    }
}
