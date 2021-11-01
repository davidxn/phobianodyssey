class POMonster : Actor
{
    
    int dropRoll;
    bool hasRolled;
    int deathDamage;
    bool dropSpecial;

	Default
	{
		Health 20;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 200;
		Monster;
		+FLOORCLIP
	}

    bool poDropItemWithProbability(String classname, int rollThreshold) {
        if (!hasRolled) {
            dropRoll = random(0, 100);
            hasRolled = true;
            //Offset for luck here if I implement it
        }
        //Cancel dropping this if our roll means we shouldn't
        if (dropRoll > rollThreshold) {
            return false;
        }
        doDrop(classname);
        return true;
    }
    
    void doDrop(String classname) {
        let spawnedActor = Actor.Spawn(classname, (pos.x, pos.y, pos.z + (height/2)));
        if (!spawnedActor) {
            console.printf("\caERROR: No spawned actor found for dropped item " .. classname);
            return;
        }
        spawnedActor.vel.X = frandom(-3, 3);
        spawnedActor.vel.Y = frandom(-3, 3);
        spawnedActor.vel.Z = frandom(5, 10);
    }
    
    void doBurst() {
        for (int i = 0; i < 30; i++) {
            let spawnedActor = Actor.Spawn("POSpeck", (pos.x, pos.y, pos.z + 40));
            spawnedActor.vel.X = frandom(-3, 3);
            spawnedActor.vel.Y = frandom(-3, 3);
            spawnedActor.vel.Z = frandom(5, 12);
        }    
    }
      
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle) {
        if (damage > self.health) {
            self.deathDamage = damage;
        }
        return super.DamageMobj(inflictor, source, damage, mod, flags, angle);
    }
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 90);
        poDropItemWithProbability("PoCoin1", 60);
        poDropItemWithProbability("PoCoin1", 30);
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
    
}

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
        
        super.doBurst();       
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
        
        super.doBurst();       
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
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}


class PoImp : POMonster REPLACES DoomImp
{
    Default {
        Tag "Imp";
        DamageFunction 10;
		Health 60;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 200;

		SeeSound "imp/sight";
		PainSound "imp/pain";
		DeathSound "imp/death";
		ActiveSound "imp/active";
		HitObituary "$OB_IMPHIT";
		Obituary "$OB_IMP";
		Tag "$FN_IMP";
    }
    
	States
	{
	Spawn:
		TROO AB 10 A_Look;
		Loop;
	See:
		TROO AABBCCDD 3 A_Chase;
		Loop;
	Melee:
	Missile:
		TROO EF 8 A_FaceTarget;
		TROO G 6 A_TroopAttack ;
		Goto See;
	Pain:
		TROO H 2;
		TROO H 2 A_Pain;
		Goto See;
	Death:
		TROO I 8;
		TROO J 8 A_Scream;
		TROO K 6;
		TROO L 6 A_NoBlocking;
		TROO M -1;
		Stop;
	XDeath:
		TROO N 5;
		TROO O 5 A_XScream;
		TROO P 5;
		TROO Q 5 A_NoBlocking;
		TROO RST 5;
		TROO U -1;
		Stop;
	Raise:
		TROO ML 8;
		TROO KJI 6;
		Goto See;
	}
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoHorn", 30);
        
        poDropItemWithProbability("PoCoin5", 50);
        poDropItemWithProbability("PoCoin5", 50);
        poDropItemWithProbability("PoCoin1", 50);
        poDropItemWithProbability("PoCoin10", 90);
        
        poDropItemWithProbability("PoHeal5", 33);
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}

class PoBlueImp : PoImp
{
    Default {
        Tag "Blue Imp";
        Translation "64:79=192:199";
        DamageFunction 11;
        Health 70;
        DamageType "Blue";
        DamageFactor "Yellow", 2;
        Scale 1.1;
    }
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoHorn", 30);
        
        poDropItemWithProbability("PoCoin10", 80);
        poDropItemWithProbability("PoCoin10", 70);
        poDropItemWithProbability("PoCoin5", 50);
        
        poDropItemWithProbability("PoHeal5", 30);
        if (MeansOfDeath == "Yellow") {
            poDropItemWithProbability("PoCoin10", 100);
        }
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}

class Devil : POImp
{
    Default {
      //$Category Monsters
      Tag "Devil";
      obituary "%o was fried by a Devil.";
      hitobituary "%o was flayed by a Devil.";
      health 120;
      radius 20;
      height 56;
      mass 120;
      speed 10;
      painchance 100;
      seesound "monster/dvlsit";
      painsound "monster/dvlpai";
      deathsound "monster/dvldth";
      activesound "monster/dvlact";
      MONSTER;
      +FLOORCLIP;
    }
    states
    {
    Spawn:
      TRO2 AB 10 A_Look;
      loop;
    See:
      TRO2 AABBCCDD 3 A_Chase;
      loop;
    Melee:
    Missile:
      TRO2 EF 6 A_FaceTarget;
      TRO2 G 4 A_TroopAttack;
      TRO2 B 2;
      TRO2 VW 6 A_FaceTarget;
      TRO2 X 4 A_TroopAttack;
      TRO2 E 0 A_Jump(200,9);
      TRO2 D 2;
      TRO2 EF 6 A_FaceTarget;
      TRO2 G 4 A_TroopAttack;
      TRO2 B 2;
      TRO2 VW 6 A_FaceTarget;
      TRO2 X 4 A_TroopAttack;
      TRO2 B 0;
      goto See;
    Pain:
      TRO2 H 2;
      TRO2 H 2 A_Pain;
      goto See;
    Death:
      TRO2 I 8;
      TRO2 J 8 A_Scream;
      TRO2 K 6;
      TRO2 L 6 A_NoBlocking;
      TRO2 M -1;
      stop;
    XDeath:
      TRO2 N 5;
      TRO2 O 5 A_XScream;
      TRO2 P 5;
      TRO2 Q 5 A_NoBlocking;
      TRO2 RST 5;
      TRO2 U -1;
      stop;
    Raise:
      TRO2 ML 8;
      TRO2 KJI 6;
      goto See;
    }
    
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
        poDropItemWithProbability("PoHorn", 50);
        poDropItemWithProbability("PoMagmaWad", 30);
        
        poDropItemWithProbability("PoCoin10", 80);
        poDropItemWithProbability("PoCoin5", 50);
        poDropItemWithProbability("PoCoin1", 50);
        poDropItemWithProbability("PoCoin20", 30);
                
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}



Class Darkling : POMonster
{
  Default
  {
    //$Category Monsters
    Tag "Darkling";
    Health 50;
    GibHealth 50;
    Radius 19;
    Height 48;
    Speed 10;
    PainChance 128;
    Mass 200;
    Scale 0.8;
    BloodColor "Purple";
    SeeSound "Roach/Sight";
    PainSound "Roach/Pain";
    DeathSound "Roach/Death";
    ActiveSound "Roach/Active";
    Obituary "%o was scalded by a Darkling";
    Monster;
    +DontHarmClass
    Species "Roach";
  }

  States
  {
  Spawn:
    DRKL A 6 RoachLook();
    Loop;
  SeeAlert:
    DRKL A 0 A_AlertMonsters();
    Goto See;
  See:
    DRKL B 0 A_Jump(32, "Stand");
    DRKL BB 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL B 2 A_Chase();
    DRKL CC 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL C 2 A_Chase();
    DRKL DD 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL D 2 A_Chase();
    DRKL EE 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL E 2 A_Chase();
    Loop;
  Stand:
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Chase("Melee", "Missile", CHF_NOPLAYACTIVE | CHF_DONTMOVE);
    DRKL A 3 A_FaceTarget();
    DRKL A 0 A_Jump(192, "Stand");
    Goto See+1;
  Melee:
  Missile:
    DRKL AAAAFF 3 A_FaceTarget();
    DRKL G 6
    {
      A_SpawnProjectile("RoachBall", 32, 0,  1);
    }
    Goto See;
  Pain:
    DRKL H 3;
    DRKL H 3 A_Pain();
    Goto See;
  Death:
    DRKL I 8 A_ScreamAndUnblock();
    DRKL JKL 6;
    DRKL M -1;
  XDeath:
    DRKL I 4 A_XScream();
	DRKL NOP 6;
	DRKL Q 6 A_NoBlocking();
	DRKL RS 6;
	DRKL T -1;
  Raise:
    DRKL MLKJI 5;
    Goto See;
  }

  void RoachLook()
  {
    if(Args[0] == 1)
      A_LookEx(LOF_NOSEESOUND, 0, 0, 0, 0, "See");
    else if(Args[0] > 1)
      A_LookEx(0, 0, 0, 0, 0, "SeeAlert");
    else
      A_Look();
  }
  
  override void Tick()
  {
    super.tick();
    //Run away when low on health
    if(health < 40 && !bFrightened)
      bFrightened = true;
  }
  
    override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {      
        poDropItemWithProbability("PoHeal5", 50);
        poDropItemWithProbability("PoCoin10", 100);
        poDropItemWithProbability("PoCoin5", 90);
        poDropItemWithProbability("PoCoin5", 80);
        poDropItemWithProbability("PoCoin5", 70);
        poDropItemWithProbability("PoCoin10", 20);
        
        poDropItemWithProbability("PoDarkHeart", 20);
        
        if (MeansOfDeath == "Melee") {
            poDropItemWithProbability("PoShell2", 100);
            poDropItemWithProbability("PoClip5", 100);
        }
        
        super.doBurst();       
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
        
        super.doBurst();       
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
