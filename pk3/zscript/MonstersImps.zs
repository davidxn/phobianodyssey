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
        
        poDropItemWithProbability("PoShell2", 50);
        
        if (MeansOfDeath == "Melee") {
            poDropItemWithProbability("PoShell2", 100);
        }
        super.Die(source, inflictor, dmgflags, MeansOfDeath);
    }
}

class PoSprog : PoImp
{
    
    default {
        //$Sprite TROTE1
        Tag "Sprog";
        Scale 0.85;
        Translation "64:79=176:191", "80:95=160:167";
        Height 48;
        Health 60;
        Radius 16;
        Speed 10;
        obituary "%o was shredded by a Sprog.";
    }
	States
	{
	See:
		TNT1 A 0;
		TROT A 4 A_FaceTarget;
		TROT B 4;
		TROT C 10;
		Goto SeeContinue;
	SeeContinue:
		TROO AA 2 A_Chase;
		TROO BB 2 A_Chase;
		TROO CC 2 A_Chase;
		TROO DD 2 A_Chase;
		TROO AA 2 A_Chase;
		TROO BB 2 A_Chase;
		TROO CC 2 A_Chase;
		TROO DD 2 A_Chase;
		Goto Missile;
	
	Melee:
	Missile:
		TROO E 1 A_FaceTarget;
		TROT CD 4;
		TNT1 A 0 A_JumpIfCloser(200, "NormalJump");
		TNT1 A 0 A_Jump(128, "NormalJump");
		TROT H 7 A_PlaySound("sprog/hiss");
        TNT1 A 0 ThrustThingZ(0,50,0,1);
		TNT1 A 0 A_FaceTarget;
        TNT1 A 0 A_Recoil (-13);
        TNT1 A 0 { invoker.dropSpecial = true; }
        TNT1 A 0 A_FaceTarget;
        TROT EF 14 A_CustomMeleeAttack(random(3, 6), "skeleton/melee");
		TNT1 A 0 A_CustomMeleeAttack(random(3, 6), "skeleton/melee");
        TNT1 A 0 { invoker.dropSpecial = false; }
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_FaceTarget;
		TROT G 1;
		TNT1 A 0 A_PlaySound("world/enemylanding");
		TROT GG 2 A_CustomMeleeAttack(random(3, 6), "skeleton/melee");
		TROT H 7;
		Goto See;
		
	NormalJump:
		TROT H 4 A_PlaySound("sprog/hiss");
	NormalJumpRepeat:
        TNT1 A 0 ThrustThingZ(0,25,0,1);
        TNT1 A 0 A_FaceTarget;
		TNT1 A 0 A_JumpIfCloser(100, "StraightJump");
		TNT1 A 0 A_SetAngle(angle + (random(0, 1)*2 - 1) * 30);
	StraightJump:
        TNT1 A 0 A_Recoil (-10);
        TNT1 A 0 { invoker.dropSpecial = true; }
        TNT1 A 0 A_FaceTarget;
        TROT EF 7;
		TNT1 A 0 A_CustomMeleeAttack(random(3, 6), "skeleton/melee");
        TNT1 A 0 { invoker.dropSpecial = false; }
		TNT1 A 0 A_Stop;
		TNT1 A 0 A_FaceTarget;
		TROT G 1;
		TROT GG 2 A_CustomMeleeAttack(random(3, 6), "skeleton/melee");
		TROT G 1;
		TNT1 A 0 A_PlaySound("world/enemylanding");
		TROT H 7;
		TNT1 A 0 A_Jump(128, "NormalJumpRepeat");
		Goto See;
	}
}
