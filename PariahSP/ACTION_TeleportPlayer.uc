class ACTION_TeleportPlayer extends LatentScriptedAction;


var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence
var Actor Dest;

function bool InitActionFor(ScriptedController C)
{
    local Pickup Pick;
	local Pawn P;
	Dest = C.SequenceScript.GetMoveTarget();

	if ( DestinationTag != '' )
	{
		ForEach C.AllActors(class'Actor',Dest,DestinationTag)
			break;
	}
	P = C.Level.GetLocalPlayerController().Pawn;
	P.SetLocation(Dest.Location);
	P.SetRotation(Dest.Rotation);
	if(P.Controller != NOne)
		P.Controller.SetRotation(Dest.Rotation);
	
	// fix teleport onto pickups
	ForEach P.TouchingActors(class'Pickup', Pick)
	{
		Pick.Touch(P);
    }
		
	P.OldRotYaw = P.Rotation.Yaw;
	BringCoopPlayersTo(P);
	return false;	
}

function BringCoopPlayersTo(Pawn EventInstigator)
{
    local Controller C;
    local LevelInfo Level;
    
    Level = EventInstigator.Level;
    C = EventInstigator.Controller;

	if ( Level.NetMode == NM_DedicatedServer )
		return;

    if(!Level.IsCoopSession() || EventInstigator.Controller == None || !EventInstigator.Controller.IsA('PlayerController'))
    {
        return;
    }

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) && C != EventInstigator.Controller )
		{
		    if(PlayerController(C).Pawn != None && PlayerController(C).Pawn.Health > 0 && !PlayerController(C).IsInState('Dead'))
		    {
		        Level.Game.QueueBringForward(PlayerController(EventInstigator.Controller), PlayerController(C));
			}
		}
	}
}

function String GetActionString()
{
	return ActionString;
}

defaultproperties
{
     ActionString="TeleportPlayer"
}
