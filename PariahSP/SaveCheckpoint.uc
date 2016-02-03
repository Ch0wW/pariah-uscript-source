class SaveCheckpoint extends Info
	native
	placeable;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var bool bUsed; 
var() localized string Description;
var() int CheckpointID;



struct native SaveRequiredEvent
{
	var() Name Event;
	var() int Count;
	var bool bSatisfied;
};

var() editinline array<SaveRequiredEvent> RequiredEvents; 

var(Events) editconst const Name hSaveGame;
var const Name hRequiredEvent;


function TriggerEx(Actor Other, Pawn EventInstigator, Name Handler, Name realevent)
{
	switch(Handler)
	{
	case hSaveGame:
		if(CanSave()) 
		{
			SaveGame();
		}
		break;
	case hRequiredEvent:
		CountEvent(realevent);
		break;

	}

}

function CountEvent(Name Event)
{
	local int i;

	for(i=0;i< RequiredEvents.Length;i++)
	{
		if(RequiredEvents[i].Event == Event && !RequiredEvents[i].bSatisfied)
		{
			if(RequiredEvents[i].Count > 0)
			{
				RequiredEvents[i].Count -= 1;

				if(RequiredEvents[i].Count == 0)
					RequiredEvents[i].bSatisfied = true;
			}
			else
			{
				RequiredEvents[i].bSatisfied = true;
			}
			
		}
	}
}

function bool CanSave()
{
	local int i;

	if(bUsed) return false;

	for(i=0;i< RequiredEvents.Length;i++)
	{
		if(! RequiredEvents[i].bSatisfied)
			return false;
	}

	return true;
}

function SaveGame()
{
	bUsed = true;	
	DisablePreviousCheckpoints();
	Level.Game.SaveGame(Description);
}

function DisablePreviousCheckpoints()
{
	local SaveCheckpoint s;

	ForEach AllActors(class'SaveCheckpoint',s)
	{
		if(s.CheckpointID < CheckpointID)
			s.bUsed = true;
	}
}

defaultproperties
{
     hSaveGame="SaveGame"
     hRequiredEvent="REQUIREDEVENT"
     bHasHandlers=True
}
