class PoPlayer : PlayerPawn Replaces DoomPlayer
{
    default {
        Player.DisplayName "Player";
        Player.StartItem "Clip", 15;
        Player.UseRange 96;
    }
	States
	{
	Spawn:
		PLAY A -1;
		Loop;
	See:
		PLAY ABCD 4;
		Loop;
	Missile:
		PLAY E 12;
		Goto Spawn;
	Melee:
		PLAY F 6 BRIGHT;
		Goto Missile;
	Pain:
		PLAY G 4;
		PLAY G 4 A_Pain;
		Goto Spawn;
	Death:
		PLAY H 0 A_PlayerSkinCheck("AltSkinDeath");
	Death1:
		PLAY H 10;
		PLAY I 10 A_PlayerScream;
		PLAY J 10 A_NoBlocking;
		PLAY KLM 10;
		PLAY N -1;
		Stop;
	XDeath:
		PLAY O 0 A_PlayerSkinCheck("AltSkinXDeath");
	XDeath1:
		PLAY O 5;
		PLAY P 5 A_XScream;
		PLAY Q 5 A_NoBlocking;
		PLAY RSTUV 5;
		PLAY W -1;
		Stop;
	AltSkinDeath:
		PLAY H 6;
		PLAY I 6 A_PlayerScream;
		PLAY JK 6;
		PLAY L 6 A_NoBlocking;
		PLAY MNO 6;
		PLAY P -1;
		Stop;
	AltSkinXDeath:
		PLAY Q 5 A_PlayerScream;
		PLAY R 0 A_NoBlocking;
		PLAY R 5 A_SkullPop;
		PLAY STUVWX 5;
		PLAY Y -1;
		Stop;
	}
}