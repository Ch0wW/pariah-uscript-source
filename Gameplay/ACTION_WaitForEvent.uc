class ACTION_WaitForEvent extends LatentScriptedAction;

var(Action) name ExternalEvent;	//tag to give controller (to affect triggering)
var name OriginalTag;
var TriggeredCondition T;


function bool InitActionFor(ScriptedController C)
{
	if ( T == None )
		ForEach C.AllActors(class'TriggeredCondition',T,ExternalEvent)
			break;

	if ( (T != None) && T.bEnabled )
		return false;
	
	C.CurrentAction = self;
    if( OriginalTag == '' )
        OriginalTag = C.Tag;
	C.Tag = ExternalEvent;
	return true;
}

function bool CompleteWhenTriggered()
{
	return true;
}

function ProceedToNextAction(ScriptedController C)
{
    Super.ProceedToNextAction(C);
    C.Tag = OriginalTag;
}

function string GetActionString()
{
	return ActionString@ExternalEvent;
}

defaultproperties
{
     ActionString="Wait for external event"
}
