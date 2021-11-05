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
        for (int i = 0; i < 25; i++) {
            let spawnedActor = Actor.Spawn("POSpeck", (pos.x, pos.y, pos.z + 40));
            spawnedActor.vel.X = frandom(-3, 3);
            spawnedActor.vel.Y = frandom(-3, 3);
            spawnedActor.vel.Z = frandom(5, 12);
        }
        if (dropSpecial) {
            for (int i = 0; i < 25; i++) {
                let spawnedActor = Actor.Spawn("POSpeck2", (pos.x, pos.y, pos.z + 40));
                spawnedActor.vel.X = frandom(-3, 3);
                spawnedActor.vel.Y = frandom(-3, 3);
                spawnedActor.vel.Z = frandom(5, 12);
            }
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
        doBurst();
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
    
}

#include "zscript/MonstersHumanoids.zs"
#include "zscript/MonstersImps.zs"
#include "zscript/MonstersDemons.zs"


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
  SeeNoStand:
    DRKL BB 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL B 2 A_Chase();
    DRKL CC 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL C 2 A_Chase();
    DRKL DD 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL D 2 A_Chase();
    DRKL EE 2 A_Chase("Melee", null, CHF_NOPLAYACTIVE);
    DRKL E 2 A_Chase();
    DRKL A 0 A_Jump(255, "See");
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
    DRKL A 0 A_Jump(255, "SeeNoStand");
  Melee:
  Missile:
    DRKL AAAAFF 3 A_FaceTarget();
    DRKL G 6
    {
      A_SpawnProjectile("RoachBall", 32, 0,  1);
    }
    DRKL A 0 A_Jump(255, "See");
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
    DRKL A 0 A_Jump(255, "See");
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
            poDropItemWithProbability("PoShell4", 100);
            poDropItemWithProbability("PoClip5", 100);
            poDropItemWithProbability("PoClip5", 100);
        }  
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}
