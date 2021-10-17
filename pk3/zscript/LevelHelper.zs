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
    
    static int getSquareFromPosition(float x, float y) {
        int squareNum = 10000;
        squareNum += (int) (x / TILE_SIZE);
        squareNum += (int) (y*100 / TILE_SIZE);
        return squareNum;
    }

    static int, int getPositionFromSquare(int squareNum) {
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
                //console.printf("DEBUG: Translated angle is %f", myangle);
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
                //console.printf("DEBUG: Hit event number " .. spot.args[0]);
                int blocked = DataLibrary.inst().ReadInt("blockEvent" .. spot.args[0]);
                //console.printf("DEBUG: Blocked? %d", blocked);
                if (!blocked) {
                    return "runEvent" .. spot.args[0];
                }
                return "";
            }
        }
        return "";
    }
    
    static bool PlayerCanMoveTo(Actor activator, double stepX, double stepY) {
        int initialX = activator.pos.x;
        int initialY = activator.pos.y;
        int currentZ = activator.pos.z;
        
        int testX;
        int testY;
        //Check in 16th-bigtile steps for any barriers (therefore, all walls must be 16mu+ thick)
        for (double i = (1.0/16); i <= 1.0; i += (1.0/16)) {
            testX = initialX + (128*i*stepX);
            testY = initialY + (128*i*stepY);
            int testZFloor = activator.GetZAt(testX, testY, 0, GZF_ABSOLUTEPOS);
            int testZCeiling = activator.GetZAt(testX, testY, 0, GZF_CEILING | GZF_ABSOLUTEPOS);
            //Check with checkMove
            if (!activator.CheckMove((testX, testY))) { console.printf("DEBUG: CheckMove returned false, rejecting"); return false; }
            //Is this point inside the level?
            if(!level.IsPointInLevel((testX, testY, testZFloor))) { console.printf("DEBUG: Point not in level, rejecting"); return false; }
            //Is this point in a place the player could fit?
            if(testZCeiling - testZFloor < 56) { console.printf("DEBUG: Point too small for player, rejecting"); return false; }
            //Is this point greater than a 16-unit jump from the last point we checked?
            if(testZFloor-currentZ > 16 || testZFloor-currentZ < -16) { console.printf("DEBUG: Journey has more than 16-unit jump"); return false; }
            currentZ = testZFloor;
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
            m.Destroy();
        }
        PoAmmo a; it = ThinkerIterator.Create("PoAmmo");
        while (a = PoAmmo(it.Next() ) ) {
            a.Destroy();
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
                    weapon.changeWeaponType(s.myType(), s.myElement());
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