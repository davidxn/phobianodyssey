class POMonster : Actor
{
    
    int dropRoll;
    bool hasRolled;

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
            console.printf("Made new drop roll %d", dropRoll);
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
        spawnedActor.vel.X = frandom(-3, 3);
        spawnedActor.vel.Y = frandom(-3, 3);
        spawnedActor.vel.Z = frandom(5, 10);
    }
    
    void doBurst() {
        for (int i = 0; i < 20; i++) {
            let spawnedActor = Actor.Spawn("POSpeck", (pos.x, pos.y, pos.z + 40));
            spawnedActor.vel.X = frandom(-3, 3);
            spawnedActor.vel.Y = frandom(-3, 3);
            spawnedActor.vel.Z = frandom(5, 12);
        }    
    }
    
}

class POZombieMan : POMonster replaces ZombieMan
{
    Default {
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
        poDropItemWithProbability("PoClip1", 80);
        poDropItemWithProbability("PoClip1", 50);
        poDropItemWithProbability("PoClip1", 50);
        
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 80);
        poDropItemWithProbability("PoCoin1", 80);
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }

}

Class HazmatZombie : POMonster
{
  Default
  {
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
    HMZP E 4 A_FaceTarget();
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

        poDropItemWithProbability("PoHeal1", 90);
        poDropItemWithProbability("PoHeal1", 80);
        poDropItemWithProbability("PoHeal1", 70);
        poDropItemWithProbability("PoHeal1", 60);
        poDropItemWithProbability("PoHeal5", 50);
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}


class PoImp : POMonster REPLACES DoomImp
{
    Default {
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
        poDropItemWithProbability("PoHorn", 50);
        
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 100);
        poDropItemWithProbability("PoCoin1", 60);
        poDropItemWithProbability("PoCoin1", 40);
        poDropItemWithProbability("PoCoin5", 20);
        
        super.doBurst();       
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}