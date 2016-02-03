class ACTION_SetAttentionTarget extends CinematicActions;

var(Action) name ViewTargetTag;
var(Action) bool eyes;
var(Action) bool head;
var(Action) bool torso;
var(Action) float EyesTurnRate;
var(Action) float HeadTurnRate;
var(Action) float TorsoTurnRate;

function bool InitActionFor(ScriptedController C)
{
    if (SPAICinematicController(C) != None){
        SPAICinematicController(C).SetLookAtRates( EyesTurnRate, HeadTurnRate, TorsoTurnRate);
        SPAICinematicController(C).SetLookAtActor(ViewTargetTag, eyes, head, torso);
    }
	return false;
}

function String GetActionString()
{
	return ActionString;
}

defaultproperties
{
     EyesTurnRate=6.000000
     HeadTurnRate=3.000000
     TorsoTurnRate=1.000000
     Eyes=True
     head=True
     ActionString="set viewtarget"
     bValidForTrigger=False
}
