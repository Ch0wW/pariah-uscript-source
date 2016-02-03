//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\Lift_exit.pcx Name=S_LiftExit Mips=Off MASKED=1

var() name LiftTag;
var	Mover MyLift;
var() byte SuggestedKeyFrame;	// mover keyframe associated with this exit - optional
var byte KeyFrame;

function bool SuggestMovePreparation(Pawn Other)
{
	local Controller C;
	
	if ( (MyLift == None) || (Other.Controller == None) )
		return false;
	if ( (Other.Base == MyLift)
			|| ((LiftCenter(Other.Anchor) != None) && (LiftCenter(Other.Anchor).MyLift == MyLift)
				&& (Other.ReachedDestination(Other.Anchor))) )
	{
		// if pawn is on the lift, see if it can get off and go to this lift exit
		if ( (Location.Z < Other.Location.Z + Other.CollisionHeight)
			 && Other.LineOfSightTo(self) )
			return false;

		// make pawn wait on the lift
		Other.DesiredRotation = rotator(Location - Other.Location);
		Other.Controller.WaitForMover(MyLift);
		return true;
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.nextController )
			if ( (C.Pawn != None) && (C.PendingMover == MyLift) && C.SameTeamAs(Other.Controller) && C.Pawn.ReachedDestination(self) )
			{
				Other.DesiredRotation = rotator(Location - Other.Location);
				Other.Controller.WaitForMover(MyLift);
				return true;
			}
	}
	return false;
}

defaultproperties
{
     SuggestedKeyFrame=255
     bNeverUseStrafing=True
     bForceNoStrafing=True
     bSpecialMove=True
     Texture=Texture'Engine.S_LiftExit'
}
