//
// CTF Messages
//
// Switch 0: Capture Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 1: Return Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 2: Dropped Message
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//	
// Switch 3: Was Returned Message
//	OptionalObject is the flag's team teaminfo.
//
// Switch 4: Has the flag.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 5: Auto Send Home.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 6: Pickup stray.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.

class CTFMessage extends CriticalEventPlus;

var(Message) localized string ReturnBlue, ReturnRed;
var(Message) localized string ReturnedBlue, ReturnedRed;
var(Message) localized string CaptureBlue, CaptureRed;
var(Message) localized string DroppedBlue, DroppedRed;
var(Message) localized string HasBlue,HasRed;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

    local String PlayerName;
    
    PlayerName = RelatedPRI_1.RetrivePlayerName();
    
	switch (Switch)
	{
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";
			if ( CTFFlag(OptionalObject) == None )
				return "";
				
            if( PlayerName == "" )
                return "";
                
			if ( CTFFlag(OptionalObject).Team.TeamIndex == 0 ) // jij
				return PlayerName@Default.CaptureRed;
			else
				return PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if ( CTFFlag(OptionalObject) == None )
				return "";
			if (RelatedPRI_1 == None)
			{
				if ( CTFFlag(OptionalObject).Team.TeamIndex == 0 ) // jij
					return Default.ReturnedRed;
				else
					return Default.ReturnedBlue;
			}

            if( PlayerName == "" )
                return "";

			if ( CTFFlag(OptionalObject).Team.TeamIndex == 0 ) // jij
				return PlayerName@Default.ReturnRed;
			else
				return PlayerName@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

            if( PlayerName == "" )
                return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) // jij
				return PlayerName@Default.DroppedRed;
			else
				return PlayerName@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) // jij
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

            if( PlayerName == "" )
                return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) // jij
				return PlayerName@Default.HasRed;
			else
				return PlayerName@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) // jij
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

            if( PlayerName == "" )
                return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) // jij
				return PlayerName@Default.HasRed;
			else
				return PlayerName@Default.HasBlue;
			break;
		// brutal hack for localizing objective destuction at this level
		case 7:
		    return class'GameObjective'.default.DestructionMessage;
		    break;
	}
	return "";
}

defaultproperties
{
     ReturnBlue="returned the blue flag!"
     ReturnRed="returned the red flag!"
     ReturnedBlue="The blue flag was returned!"
     ReturnedRed="The red flag was returned!"
     CaptureBlue="captured the blue flag! The red team scores!"
     CaptureRed="captured the red flag! The blue team scores!"
     DroppedBlue="dropped the blue flag!"
     DroppedRed="dropped the red flag!"
     HasBlue="took the blue flag!"
     HasRed="took the red flag!"
     Lifetime=3.000000
     PosX=0.980000
     PosY=0.120000
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
}
