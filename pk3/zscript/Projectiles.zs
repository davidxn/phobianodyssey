//Fired by enemies

class POFireball : DoomImpBall
{
    Default {
        +NODAMAGETHRUST;
        DamageFunction 10 + random(0, 2);
        DamageType "Fire";
        
    }
}

// Fired by player

class PlasmaBallNone : PlasmaBall replaces PlasmaBall { Default { DamageType "None"; } }
class PlasmaBallBlue : PlasmaBall {
    Default {
        Translation "192:207=192:199";
        DamageType "Blue";
    }
}

class PlasmaBallRed : PlasmaBall {
    Default {
        Translation "192:207=168:191";
        DamageType "Red";
    }
}

class PlasmaBallGreen : PlasmaBall {
    Default {
        Translation "192:207=112:127";
        DamageType "Green";
    }
}

class PlasmaBallYellow : PlasmaBall {
    Default {
        Translation "192:207=224:231";
        DamageType "Yellow";
    }
}

class BulletPuffNone : BulletPuff replaces BulletPuff { Default { DamageType "None"; } }
class BulletPuffBlue : BulletPuff { Default { DamageType "Blue"; } }
class BulletPuffRed : BulletPuff { Default { DamageType "Red"; } }
class BulletPuffGreen : BulletPuff { Default { DamageType "Green"; } }
class BulletPuffYellow : BulletPuff { Default { DamageType "Yellow"; } }
