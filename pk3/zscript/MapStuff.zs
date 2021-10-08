class ExitSpot : MapSpot
{
    default {
        //$Sprite EXITA0
        //$Arg0 Go To Map
        //$Arg0Tooltip The mapnum of this exit's target
        //$Arg1 Go To Square
        //$Arg1Tooltip The square number of this exit's target
    }
}

class EventSpot : MapSpot
{
    default {
        //$Sprite EVNTA0
        //$Arg0 Event Number
        //$Arg0Tooltip Event number to run
        //$Arg1 Repeatable
        //$Arg1Tooltip 1 if this event should be repeatable
        //$Arg2 Do next event
        //$Arg2Tooltip 1 if this event should also trigger next event numerically
    }
}

class MapDescriber : MapSpot
{
    default {
        //$Sprite MINFA0
        //$Arg0 Map Type
        //$Arg0Tooltip 0 for no special, 1 to run RPG movement, 2 for arena
        //$Arg1 Arena Mapnum
        //$Arg1Tooltip Mapnum to use for arenas on this level
    }
}

class MonsterTurner : MapSpot
{
    default {
        //$Sprite TURNA0
    }
}

class FOESpot : MapSpot
{
    default {
        //$Sprite PAINA1
    }
}


class POChest : FloatingSkull
{
    default {
        //$Arg0 Contents
        //$Arg0Tooltip Numeric content ID
    }
    States {
        Spawn:
            CHST A -1;
        Opened:
            CHST B -1 A_PlaySound("po/chest");
    }
    override bool Used (Actor user)
    {
        if (user && self.InStateSequence("Spawn"))
        {
            self.SetStateLabel("Opened");
            ScriptCall("DataLibrary", "WriteData", "eventDialogPage", "1");
            ScriptCall("DataLibrary", "WriteData", "eventDialogConversation", "OPEN_CHEST");
            ScriptCall("DataLibrary", "WriteData", "showEventDialog", "1");
            return true;
        }

        return false;
    }
}
