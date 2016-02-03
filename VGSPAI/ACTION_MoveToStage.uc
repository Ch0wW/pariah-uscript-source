/*
 * Same as the move to point, 'cept it looks at the name rather than
 * the tag. We only ennumerate stages in the level.
 */
class ACTION_MoveToStage extends LatentScriptedAction;

var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence
var Stage Movetarget;

function bool MoveToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	if ( Movetarget != None )
		return MoveTarget;

	MoveTarget = Stage(C.SequenceScript.GetMoveTarget());
	if ( DestinationTag != '' )
	{
           ForEach C.AllActors(class'Stage', MoveTarget){
              if (MoveTarget.StageName == DestinationTag){
                 break;
              }
           }

	}
        //	if ( AIScript(MoveTarget) != None )
        //MoveTarget = Stage(AIScript(MoveTarget).GetMoveTarget());
	return MoveTarget;
}


function string GetActionString()
{
	return ActionString@DestinationTag;
}

defaultproperties
{
     ActionString="Move to point"
     bValidForTrigger=False
}
