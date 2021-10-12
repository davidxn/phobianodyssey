class POFireball : DoomImpBall
{
    Default {
        +NODAMAGETHRUST;
        DamageFunction 10 + random(0, 2);
        DamageType "Fire";
    }
}