class NetTrigger extends Triggers
	abstract
	native;

var int TriggerId, LastTriggerId;

// if this is true, this trigger controls persistent state
// - in this case, when a trigger of this type is on a client it will
//   try to determine whether the server side trigger had fired and if so it
//   will also trigger on the client
//   - an example would be a trigger which changes a light color
// - if bTriggersPersistentState is false, it doesn't care about what might have
//   occurred on the server in the past
//   - an example would be a trigger which plays a sound
var const bool bTriggersPersistentState;

replication
{
	reliable if (Role == ROLE_Authority)
		TriggerId;
}

native function int GetNextTriggerId();

// this will get called on server and clients when Trigger() is called on server
//
simulated function Triggered();

// this is called to determine whether the passed in NetTrigger should be considered 
// when determining whether a trigger should be triggered on the client
//
simulated function bool EquivalentTrigger( NetTrigger t )
{
	return False;
}

simulated function CheckEquivalentClientTriggers()
{
	local NetTrigger nt;
	local bool bTrigger;

	if ( bTriggersPersistentState && Role < ROLE_Authority && TriggerId > 0 && LastTriggerId == 0 )
	{
		// if this NetTrigger's ID is greater than 0, it must be on a client
		// - search for all other equivalent triggers and fire this trigger if it's
		//   ID is greater than all the others
		//
		bTrigger = True;
		foreach AllActors( class'NetTrigger', nt )
		{
			if ( nt != self && EquivalentTrigger( nt ) && nt.TriggerId > TriggerId )
			{
				bTrigger = False;
				break;
			}
		}
		if ( bTrigger )
		{
			GLog( RJ3, "CheckEquivalentClientTriggers() calling Triggered() - TriggerId="$TriggerId$",LastTriggerId="$LastTriggerId );
			Triggered();
		}
		LastTriggerId = TriggerId;
	}
}

simulated event PostNetBeginPlay()
{
	GLog( RJ3, "PostNetBeginPlay() called, TriggerId="$TriggerId );
	CheckEquivalentClientTriggers();
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	TriggerId = GetNextTriggerId();
	GLog( RJ3, "Trigger("$Other$","$EventInstigator$") calling Triggered() - TriggerId = "$TriggerId );
	Triggered();
}

simulated event PostNetReceive()
{
	GLog( RJ3, "PostNetReceive() called - TriggerId="$TriggerId$",LastTriggerId="$LastTriggerId );
	CheckEquivalentClientTriggers();
	if ( TriggerId != LastTriggerId )
	{
		GLog( RJ3, "PostNetReceive() calling Triggered() - TriggerId="$TriggerId$",LastTriggerId="$LastTriggerId );
		LastTriggerId = TriggerId;
		Triggered();
	}
}

defaultproperties
{
     NetUpdateFrequency=4.000000
     bNoDelete=True
     bAlwaysRelevant=True
     bNetNotify=True
}
