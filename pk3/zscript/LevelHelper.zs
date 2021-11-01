class LevelHelper : Thinker
{
    const TILE_SIZE = 128;
    
    //Quick, make this a static thinker when we initialize
    LevelHelper Init(void)
	{
		ChangeStatNum(STAT_STATIC);
		return self;
	}

    static bool IsPointInLevel(Actor activator, int x, int y, int z)
    {
        Vector3 a = (x >> 16, y >> 16, z >> 16);
        bool isPoint = level.IsPointInLevel(a);
        return(isPoint);
    }
    
    static clearscope int getSquareFromPosition(float x, float y) {
        int squareNum = 10000;
        squareNum += (int) (x / TILE_SIZE);
        squareNum += (int) (y*100 / TILE_SIZE);
        return squareNum;
    }

    static clearscope int, int getPositionFromSquare(int squareNum) {
        squareNum -= 10000;
        int x = ((squareNum % 100) * TILE_SIZE);
        squareNum /= 100;
        int y = ((squareNum % 100) * TILE_SIZE);
        return x, y;
    }
    
    static int HandleMapExit(Actor activator)
    {
        ExitSpot spot; ThinkerIterator it = ThinkerIterator.Create("ExitSpot");
        while (spot = ExitSpot(it.Next() ) ) {
            if (spot.pos.x == activator.pos.x && spot.pos.y == activator.pos.y) {
                int squareNum = spot.args[1];
                double myangle = spot.angle * 182; //This converts from degrees to fixed-point angle
                DataLibrary.inst().WriteData(null, "FieldSquare", squareNum .. "");
                DataLibrary.inst().WriteData(null, "FieldAngle",  myangle .. "");
                return spot.args[0]; //This is the mapnum for the exit's target
            }
        }
        return 0;
    }
    
    static String HandleEvent(Actor activator)
    {
        EventSpot spot; ThinkerIterator it = ThinkerIterator.Create("EventSpot");
        while (spot = EventSpot(it.Next() ) ) {
            if (spot.pos.x == activator.pos.x && spot.pos.y == activator.pos.y) {
                int blocked = DataLibrary.inst().ReadInt("blockEvent" .. spot.args[0]);
                if (!blocked) {
                    return "runEvent" .. spot.args[0];
                }
                return "";
            }
        }
        return "";
    }
    
    static String CheckForForcedEvent(Actor activator)
    {
        return DataLibrary.readData("ForceEvent");
    }
    
    static bool PlayerCanMoveTo(Actor activator, double stepX, double stepY) {
        double initialX = activator.pos.x;
        double initialY = activator.pos.y;
        double currentZ = activator.pos.z;
        double initialZ = activator.pos.z;
        double testZFloor = 0.0;
        double testZCeiling = 0.0;
        
        double testX;
        double testY;
        int dropStepsAllowed = 0;
        //Check in 16th-bigtile steps for any barriers (therefore, all walls must be 16mu+ thick)
        for (double i = (1.0/16); i <= 1.0 + (1.0/8); i += (1.0/16)) { //We actually test a bit beyond the next square to prevent literal edge cases where the player can't fit!
            testX = initialX + (128*i*stepX);
            testY = initialY + (128*i*stepY);
            testZFloor = activator.GetZAt(testX, testY, 0, GZF_ABSOLUTEPOS);
            testZCeiling = activator.GetZAt(testX, testY, 0, GZF_CEILING | GZF_ABSOLUTEPOS);
            //Is this point inside the level?
            if(!level.IsPointInLevel((testX, testY, testZFloor))) { console.printf("\ckMOVEDEBUG: Point not in level, rejecting"); return false; }
            //Is this point in a place the player could fit?
            if(testZCeiling - testZFloor < 56) { console.printf("\ckMOVEDEBUG: Point too small for player, rejecting"); return false; }
            
            //Is this point greater than a 16-unit jump up from the last point we checked AND greater than a 16-unit jump from the initial floor?
            if(currentZ-testZFloor < -16 && initialZ-testZFloor < -16) {
                console.printf("\ckMOVEDEBUG: Journey has more than 16-unit step up"); return false;
            }
            //If it's a drop, allow 3 in a row before we reject - allows little cracks in ground
            else if (initialZ-testZFloor >= 32) {
                if (currentZ-testZFloor <= 16 && initialZ-testZFloor <= 16) {
                    //Doesn't count as a drop
                } else {
                    if (dropStepsAllowed > 2) {
                        console.printf("\ckMOVEDEBUG: Journey has more than 16-unit step down 3 steps in row"); return false;
                    }
                    dropStepsAllowed++;
                }
            }
            currentZ = testZFloor;
            
            //One more check if we've hit one square away - check line of sight to the new position
            if (i == 1.0) {
                MapSpot x = MapSpot(Actor.Spawn("MapSpot", (testX, testY, testZFloor + 40)));
                console.printf("%d %d %d", x.pos.x, x.pos.y, x.pos.z);
                if (!activator.CheckSight(x, SF_IGNOREVISIBILITY)) { console.printf("\ckMOVEDEBUG: Mapspot sight check returned false, rejecting"); return false; }
                x.Destroy();
            }
        }

        return true;
    }
    
    static String GetFloorSound(Actor actor) {
        String textureName = GetActorFloorTexture(actor);
        String wetFloors = "FWATER1 NUKAGE1 SLIME01";
        String grassyFloors = "GRASS2";
        if (wetFloors.indexOf(textureName) > -1) {
            return "po/tread/water";
        }
        if (grassyFloors.indexOf(textureName) > -1) {
            return "po/tread/natural";
        }
        return "po/tread/general";
    }
    
    static int IsOnDamagingFloor(Actor actor) {
        String textureName = GetActorFloorTexture(actor);
        String damagingFloors = "NUKAGE1";
        if (damagingFloors.indexOf(textureName) > -1) {
            return 1;
        }
        return 0;
    }
    
    static String GetActorFloorTexture(Actor actor)
    {
        Sector sec = actor.CurSector;
        TextureID tex = sec.GetTexture(0);
        String name = TexMan.getName(tex);
        return name;
    }
    
    static void CleanupArena()
    {
        PoDroppable m; ThinkerIterator it = ThinkerIterator.Create("PoDroppable");
        while (m = PoDroppable(it.Next() ) ) {
            if (!m.Owner) {
                m.Destroy();
            }
        }
        PoAmmo a; it = ThinkerIterator.Create("PoAmmo");
        while (a = PoAmmo(it.Next() ) ) {
            a.Destroy();
        }
        PoSpeck s; it = ThinkerIterator.Create("PoSpeck");
        while (s = PoSpeck(it.Next() ) ) {
            s.Destroy();
        }
    }
    
    static void StopActor(Actor activator)
    {
        activator.vel.X = 0;
        activator.vel.Y = 0;
        activator.vel.Z = 0;
    }
    
    static void PrepareWeapons(Actor activator) {
        activator.GiveInventoryType("POFist");
        for (int i = 1; i < 5; i++) {
            POWeaponSlot s = DataLibrary.getWeaponSlot(i);
            if(!s) continue;
            if (s.getClassName() != "POWeaponSlotEmpty") {
                POWeapon weapon = POWeapon(activator.GiveInventoryType("POWeapon" .. i+1));
                if (weapon) {
                    weapon.changeWeaponType(s.myType(), s.myElement(), s.myPower());
                } else {
                    console.printf("Failed to add weapon %s", "POWeapon" .. i+1);
                }
                
            }
        }        
    }
    
    static void StashWeapons(Actor activator) {
        activator.TakeInventory("POFist", 1);
        activator.TakeInventory("POWeapon2", 1);
        activator.TakeInventory("POWeapon3", 1);
        activator.TakeInventory("POWeapon4", 1);
        activator.TakeInventory("POWeapon5", 1);
    }
    
    static void AdvanceTurnBasedTraps()
    {
        return;
    }
}