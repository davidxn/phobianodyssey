class PoDanger : Inventory
{
  default {
    Inventory.MaxAmount 100;
  }
}

class PoCoin : Inventory {
  default {
    Inventory.MaxAmount 999999999;
  }
}

class POAmmo : Ammo {

    bool decaying;
    int age;
    int maxAge;
    String mySprite;
    
    property SpriteName: mySprite;
    default {
        +BRIGHT;
        Inventory.Amount 1;
        Inventory.PickupSound "po/ammo1";
        POAmmo.SpriteName "A001";
    }
    
  //Classes with variable sprite names have to load their own sprites in a dummy state, so list them here
    states {
      X:
        A001 A 0;
        A002 A 0;
        A003 A 0;
        A004 A 0;
        A005 A 0;
        A006 A 0;
        A007 A 0;
        A008 A 0;
        A009 A 0;
      Spawn:
        TNT1 A 4 { applySprite(); }
        TNT1 B 4 { applySprite(); }
        Loop;
      Decaying:
        TNT1 A 4 { applySprite(); }
        TNT1 B 4 { applySprite(); }
        TNT1 C 4;
        Loop;
    }
  
    override Class<Ammo> GetParentAmmo () {
        return (class<Ammo>) ("Clip");
    }

    override void Tick() {
        
        if (maxAge == 0) { maxAge = random(350, 450); }
        age++;
        if (!decaying && (age > maxAge-100)) {
            self.SetStateLabel("Decaying");
            decaying = true;
        }
        if (age > maxAge) {
            self.Destroy();
        }
        super.Tick();
    }

    action void applySprite() {self.sprite = GetSpriteIndex(invoker.mySprite); }

}

class POClip : Ammo {
    default {
        Inventory.MaxAmount 60;
    }
}

class POShell : Ammo {
    default {
        Inventory.MaxAmount 25;
    }
}

class PORocket : Ammo {
    default {
        Inventory.MaxAmount 10;
    }
}

class POCell : Ammo {
    default {
        Inventory.MaxAmount 50;
    }
}

class POClip1 : POAmmo
{
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "po/ammo1";
        Inventory.PickupMessage "Bullet";
        POAmmo.SpriteName "A001";
    }
    
    override Class<Ammo> GetParentAmmo () {
        return (class<Ammo>) ("POClip");
    }
}

class POClip5 : POClip1
{
  default {
      Inventory.Amount 5;
      Inventory.PickupSound "po/ammo2";
      Inventory.PickupMessage "Bullets";
      POAmmo.SpriteName "A002";
  }
 
}

class POShell2 : POAmmo
{
    default {
        Inventory.Amount 2;
        Inventory.PickupSound "po/ammo1";
        Inventory.PickupMessage "Shells";
        POAmmo.SpriteName "A003";
    }
    
    override Class<Ammo> GetParentAmmo () {
        return (class<Ammo>) ("POShell");
    }
}

class POShell4 : POShell2
{
  default {
      Inventory.Amount 4;
      Inventory.PickupSound "po/ammo2";
      POAmmo.SpriteName "A004";
  }
}

////////////////////////////

class PODroppable : Inventory {

    bool decaying;
    int age;
    int maxAge;
    String mySprite;
    
    property SpriteName: mySprite;
    default {
        +BRIGHT;
        Inventory.MaxAmount 9999;
        Inventory.PickupSound "po/inventory/up";
        PODroppable.SpriteName "A001";
    }
    
    states {
      X:
        M000 A 0;
        M001 A 0;
        M002 A 0;
        M003 A 0;
        M004 A 0;
        M005 A 0;
        M006 A 0;
        M007 A 0;
        M008 A 0;
        M009 A 0;
        M010 A 0;
        M011 A 0;
        M012 A 0;
        M013 A 0;
      Spawn:
        M001 A 4 { applySprite(); }
        M001 B 4 { applySprite(); }
        Loop;
      Decaying:
        M001 A 4 { applySprite(); }
        M001 B 4 { applySprite(); }
        M001 C 4;
        Loop;
    }

    override void Tick() {
        
        if (maxAge == 0) { maxAge = random(350, 450); }
        age++;
        if (!decaying && (age > maxAge-100)) {
            self.SetStateLabel("Decaying");
            decaying = true;
        }
        if (age > maxAge) {
            self.Destroy();
        }
        super.Tick();
    }

    action void applySprite() {self.sprite = GetSpriteIndex(invoker.mySprite); }

}

class POCoin1 : PODroppable
{
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "po/pickup/cash";
        PODroppable.SpriteName "M000";
        Inventory.PickupMessage "Coin";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("POCoin", 1);
        self.Destroy();
    }
}

class POCoin5 : POCoin1
{
    default {
        Inventory.Amount 5;
        Inventory.PickupSound "po/pickup/cash";
        PODroppable.SpriteName "M002";
        Inventory.PickupMessage "Coins";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("POCoin", 5);
        self.Destroy();
    }
}

class POCoin10 : POCoin1
{
    default {
        Inventory.Amount 10;
        Inventory.PickupSound "po/pickup/cash";
        PODroppable.SpriteName "M005";
        Inventory.PickupMessage "Coins";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("POCoin", 10);
        self.Destroy();
    }
}

class POCoin50 : POCoin1
{
    default {
        Inventory.Amount 50;
        Inventory.PickupSound "po/pickup/cash";
        PODroppable.SpriteName "M006";
        Inventory.PickupMessage "Coins";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("POCoin", 50);
        self.Destroy();
    }
}

class POHeal1 : PODroppable
{
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "po/pickup/hp";
        PODroppable.SpriteName "M003";
        Inventory.PickupMessage "1 Health";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("Health", 1);
        self.Destroy();
    }
}

class POHeal5 : PODroppable
{
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "po/pickup/hp";
        PODroppable.SpriteName "M004";
        Inventory.PickupMessage "5 Health";
    }
    
    override void AttachToOwner(Actor owner) {
        owner.GiveInventory("Health", 5);
        self.Destroy();
    }
}



class POHorn : PODroppable
{
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "po/cash";
        PODroppable.SpriteName "M001";
        Inventory.PickupMessage "Demonic Horn";
    }
}

class POSpeck : Actor
{
    
    int age;
    int maxAge;
    
    states {
      Spawn:
        SPEK A -1;
        Loop;
    }
    
    override void Tick() {
        
        if (maxAge == 0) { maxAge = random(250, 450); }
        age++;
        if (age > maxAge) {
            self.Destroy();
        }
        super.Tick();
    }
}

class DecorativeWeapon : FloatingSkull
{
    Default {
        Radius 8;
        Height 16;
    }
    States {
        Spawn:
            RWEP A -1 NoDelay { frame = random(0, 15);}
    }
}