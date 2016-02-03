class LevelChangeTrigger extends Triggers;


var() string NextMap;
var transient bool bTriggered;

function Trigger( actor Other, pawn EventInstigator )
{
	if ( bTriggered )
	{
		`log("LevelChangeTrigger "$self$" was already triggered!");
	}
	else
	{
		bTriggered = true;
		`log("LevelChangeTrigger "$self$" got Trigger from Other "$Other$" with Instigator "$EventInstigator);

		if(Level.Game.IsA('SinglePlayer'))
		{
			SinglePlayer(Level.Game).ChangeLevel(NextMap);
		}
		else
		{
			assert(false);
		}
	}
}

defaultproperties
{
}
