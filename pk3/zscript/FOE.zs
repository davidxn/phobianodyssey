class FOE : FloatingSkull
{

    default {
        Health 50;
        Radius 20;
        Height 60;
        +FLOATBOB;
        +NOGRAVITY;
        //$Arg0 Monster Population
        //$Arg0Tooltip The ID of the monster population that this FOE will trigger.
    }
    States {
        Spawn:
            PAIN ABC 15;
            Loop;
        Destroy:
            PAIN H 8 A_PlaySound("po/foe/death");
            PAIN IJKLM 8;
            Stop;
    }

    bool overlapsPlayer(Actor other) {
        return isAtPosition(other.pos.x, other.pos.y);
    }
    
    bool isAtPosition(float x, float y) {
        return (pos.x == x && pos.y == y);
    }
    
    int getMonsterPop() {
        return args[0];
    }
}

class FOEHelper : Thinker
{
    
    //Quick, make this a static thinker when we initialize
    FOEHelper Init(void)
	{
		ChangeStatNum(STAT_STATIC);
		return self;
	}
    
    static int moveFOEs(Actor activator)
    {
        int foeMonsterPop = 0;
        FOE foe; ThinkerIterator foeIterator = ThinkerIterator.Create("FOE");
        while (foe = FOE(foeIterator.Next() ) ) {
            
            //Move the monster one grid space according to its current angle
            vector3 mypos = foe.Pos;
            vector3 oldpos = mypos;
            int myangle = (int) (foe.angle);
            int deltaX = 0;
            int deltaY = 0;
            switch (myangle) {
                case 0: deltaX = 128; break;
                case 90: deltaY = 128; break;
                case 180: deltaX = -128; break;
                case 270: deltaY = -128; break;
            }
            mypos.x += deltaX;
            mypos.y += deltaY;
            foe.SetOrigin(mypos, true);
            
            if (foe.overlapsPlayer(activator)) {
                foe.SetOrigin(oldpos, false);
                int squareNum = LevelHelper.getSquareFromPosition(oldpos.x, oldpos.y);
                DataLibrary.inst().WriteData(null, "CurrentFOESquare", squareNum .. "");
                foeMonsterPop = foe.getMonsterPop();
            }
            
            //If they've hit a turner, set their angle to match that turner
            MonsterTurner turner; ThinkerIterator turnIterator = ThinkerIterator.Create("MonsterTurner");
            while (turner = MonsterTurner(turnIterator.next())) {
                vector3 turnpos = turner.Pos;
                if (turnpos.x == mypos.x && turnpos.y == mypos.y) {
                    foe.angle = turner.angle;
                }
            }
        }
        
        return foeMonsterPop; //This will be positive if a FOE has hit the player
    }
    
    static int PlayerOverlapsAnyFOE(Actor activator)
    {
        FOE foe; ThinkerIterator foeIterator = ThinkerIterator.Create("FOE");
        while (foe = FOE(foeIterator.Next() ) ) {
            if (foe.overlapsPlayer(activator)) {
                int squareNum = LevelHelper.getSquareFromPosition(foe.pos.x, foe.pos.y);
                DataLibrary.inst().WriteData(null, "CurrentFOESquare", squareNum .. "");
                return foe.getMonsterPop();
            }
        }
        return 0;
    }
    
    static void DestroyCurrentFOE()
    {
        String squareNum = DataLibrary.inst().ReadData("CurrentFOESquare");
        if (!squareNum) {
            return;
        }
        //Got a squarenum! Let's translate it
        int x;
        int y;
        [x, y] = LevelHelper.getPositionFromSquare(squareNum.ToInt());
        FOE foe; ThinkerIterator foeIterator = ThinkerIterator.Create("FOE");
        while (foe = FOE(foeIterator.Next() ) ) {
            if (foe.isAtPosition(x, y)) {
                DataLibrary.inst().WriteData(null, "CurrentFOESquare", "");
                foe.SetState(foe.FindState("Destroy"));
                break;
            }
        }
    }
}