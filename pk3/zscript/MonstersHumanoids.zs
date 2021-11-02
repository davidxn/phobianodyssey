class POZombieMan : POMonster replaces ZombieMan
{
    Default {
        Tag "Zombieman";
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "$OB_ZOMBIE";
		Tag "$FN_ZOMBIE";
        
        DamageFunction 5;
    }
    
    States {
        Spawn:
            POSS AB 10 A_Look;
            Loop;
        See:
            POSS AABBCCDD 4 A_Chase;
            Loop;
        Missile:
            POSS E 10 A_FaceTarget;
            POSS E 0 A_PlaySound ("grunt/attack");
            POSS F 8 A_CustomBulletAttack (22.5, 0, 1, 5 + random(0, 2), "BulletPuff", 0, CBAF_NORANDOM);
            POSS E 8;
            Goto See;
        Pain:
            POSS G 3;
            POSS G 3 A_Pain;
            Goto See;
        Death:
            POSS H 5;
            POSS I 5 A_Scream;
            POSS J 5 A_NoBlocking;
            POSS K 5;
            POSS L -1;
            Stop;
        XDeath:
            POSS M 5;
            POSS N 5 A_XScream;
            POSS O 5 A_NoBlocking;
            POSS PQRST 5;
            POSS U -1;
            Stop;
        Raise:
            POSS K 5;
            POSS JIH 5;
            Goto See;
    }
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoClip1", 100);
        poDropItemWithProbability("PoClip1", 100);
        poDropItemWithProbability("PoClip1", 100);
        poDropItemWithProbability("PoClip5", 50);
        
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 80);
        poDropItemWithProbability("PoCoin1", 80);
        
        poDropItemWithProbability("PoJam", 20);
        
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

}

class POSergeant : POMonster replaces ShotgunGuy
{
    Default {
        Tag "Sergeant";
		Health 30;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 170;
		Monster;
		+FLOORCLIP
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";
		Obituary "$OB_SHOTGUY";
		Tag "$FN_SHOTGUN";
        
        DamageFunction 5;
    }
    
	States
	{
        Spawn:
            SPOS AB 10 A_Look;
            Loop;
        See:
            SPOS AABBCCDD 3 A_Chase;
            Loop;
        Missile:
            SPOS E 10 A_FaceTarget;
            SPOS F 0 bright A_PlaySound("shotguy/attack", CHAN_WEAPON);
            SPOS F 10 bright A_CustomBulletAttack(22.5, 0, 3, 5 + random(0, 2), "BulletPuff", 0, CBAF_NORANDOM);
            SPOS E 10;
            Goto See;
        Pain:
            SPOS G 3;
            SPOS G 3 A_Pain;
            Goto See;
        Death:
            SPOS H 5;
            SPOS I 5 A_Scream;
            SPOS J 5 A_NoBlocking;
            SPOS K 5;
            SPOS L -1;
            Stop;
        XDeath:
            SPOS M 5;
            SPOS N 5 A_XScream;
            SPOS O 5 A_NoBlocking;
            SPOS PQRST 5;
            SPOS U -1;
            Stop;
        Raise:
            SPOS L 5;
            SPOS KJIH 5;
            Goto See;
	}
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoShell2", 100);
        poDropItemWithProbability("PoShell2", 50);

        poDropItemWithProbability("PoCoin5", 90);
        poDropItemWithProbability("PoCoin1", 80);
        poDropItemWithProbability("PoCoin1", 80);
        poDropItemWithProbability("PoCoin1", 60);
        poDropItemWithProbability("PoCoin1", 50);
        
        poDropItemWithProbability("PoHeal5", 25);
        
        poDropItemWithProbability("PoJam", 30);
             
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

}

Class HazmatZombie : POMonster
{
  Default
  {
    Tag "Hazmat Zombie";
    obituary "%o was electrocuted by a zombie scientist.";
    health 20;
    mass 90;
    speed 8;
    Radius 20;
    Height 52;
    painchance 200;
    seesound "grunt/sight";
    painsound "grunt/pain";
    deathsound "grunt/death";
    activesound "grunt/active";
    MONSTER;
    +FLOORCLIP
  }

  States
  {
   Spawn:
    HMZP AB 10 A_Look();
    loop;
  See:
    HMZP AABBCCDD 4 A_Chase();
    loop;
  Melee:
    HMZP E 10 A_FaceTarget();
    HMZP F 4 Bright
    {
      A_PlaySound("hazmat/tazer");
      A_CustomMeleeAttack (10);
    }
    HMZP E 4;
    goto See;
  Pain:
    HMZP G 3;
    HMZP G 3 A_Pain();
    goto See;
  Death:
    HMZP H 5;
    HMZP I 5 A_Scream();
    HMZP J 5 A_NoBlocking();
    HMZP K 5;
    HMZP L -1;
    stop;
  XDeath:
    HMZP M 5;
    HMZP N 5 A_XScream();
    HMZP O 5 A_NoBlocking();
    HMZP PQRST 5;
    HMZP U -1;
    stop;
  Raise:
    HMZP LKJIH 5;
    goto See;
  }
  
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {      
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 80);
        poDropItemWithProbability("PoCoin1", 70);

        poDropItemWithProbability("PoHeal1", 80);
        poDropItemWithProbability("PoHeal1", 70);
        poDropItemWithProbability("PoHeal1", 60);
        poDropItemWithProbability("PoHeal1", 50);
        poDropItemWithProbability("PoHeal5", 30);
        
        poDropItemWithProbability("PoJam", 10);
        
        if (MeansOfDeath == "Melee") {
            poDropItemWithProbability("PoClip5", 100);
        }
             
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}

class ZombieScientistPlasma : POMonster
{
  default {
      //$Category Monsters
      Tag "Zombie Scientist Plasma";
      obituary "%o was melted by a zombie scientist.";
      health 50;
      mass 100;
      speed 16;
      Radius 20;
      Height 52;
      painchance 150;
      seesound "scientist/sight";
      painsound "scientist/pain";
      deathsound "scientist/death";
      activesound "scientist/active";
      +FLOORCLIP;
      +AVOIDMELEE;
      +MISSILEMORE;
  }
  States
  {
  Spawn:
    SCZP AB 10 A_Look;
    loop;
  See:
    SCZP AABBCCDD 3 A_Chase;
    loop;
  Missile:
    SCZP E 6 A_FaceTarget;
    SCZP E 1 A_PlaySound ("PlasmaHi/Fire");
	SCZP F 5 A_SpawnProjectile ("ZombiePlasmaBall", 45, 3, (1)*Random(-3, 3), CMF_OFFSETPITCH, (0.1)*Random(-3, 3));
	SCZP E 12;
    goto See;
  Pain:
    SCZP G 3;
    SCZP G 3 A_Pain;
    goto See;
  Death:
    SCZP H 5 A_SpawnItemEx ("ZombiePlasmaDeathExplosion", 0.0, 0.0, 32.0, 0.0, 0.0, 0.0, 0.0, SXF_NOCHECKPOSITION, 0);
    SCZP I 5 A_Scream;
    SCZP J 5 A_NoBlocking;
    SCZP K 5;
    SCZP L 5;
    SCZP M 5;
    SCZP N -1;
    stop;
  XDeath:
    SCZP O 5 A_SpawnItemEx ("ZombiePlasmaDeathExplosion", 0.0, 0.0, 32.0, 0.0, 0.0, 0.0, 0.0, SXF_NOCHECKPOSITION, 0);
    SCZP P 5 A_XScream;
    SCZP Q 5 A_NoBlocking;
    SCZP RSTUV 5;
    SCZP W -1;
    stop;
  Raise:
    SCZP MLKJIH 5;
    goto See;
  }
  
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {      
        poDropItemWithProbability("PoHeal5", 50);
        poDropItemWithProbability("PoCoin10", 80);
        poDropItemWithProbability("PoCoin5", 50);
        poDropItemWithProbability("PoCoin10", 20);
        poDropItemWithProbability("PoCell2", 50);
        
        if (MeansOfDeath == "Melee") {
            poDropItemWithProbability("PoCell2", 100);
            poDropItemWithProbability("PoCell5", 50);
        }
             
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}

class ZombiePlasmaBall : Actor
{
  default {
      Height 8;
      Radius 6;
      Speed 15;
      FastSpeed 25;
      Projectile;
      RenderStyle "Add";
      DamageFunction (10 + random(1,5));
      Scale 0.4;
      DeathSound "weapons/plasmax";
      Decal "PlasmaScorch";
  }
  States
  {
  Spawn:
    ZPLS AB 2 BRIGHT;
	loop;
  Death:
    PLSE ABCDE 4 Bright;
	Stop;
  }
}


//Why can we get his plasma gun?
//Because it went up in a flash of plasma when he died, that's why. :P
class ZombiePlasmaDeathExplosion : Actor
{
  default {
      Radius 1;
      Height 2;
      +NOGRAVITY;
      RenderStyle "Add";
      Alpha 0.75;
      Scale 0.5;
  }
  States
  {
  Spawn:
    ZPLX A 0;
    ZPLX A 4 A_PlaySound("weapons/plasmax");
    ZPLX BCDE 4 Bright;
    Stop;
  }
}
