class SinglePlayerTriggers extends Triggers
	placeable
	native
	abstract;


var() bool DebugLogging;

function Reset()
{
	GotoState('');
}

function DisableTrigger()
{
	if(DebugLogging)
		log("Trigger "$self$" with Tag "$Tag$" has been Disabled");
	GotoState('Disabled');
}

state Disabled 
{
	ignores Trigger,UnTrigger;
}

defaultproperties
{
}
