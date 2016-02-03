/*
	MiniEdPawn.uc
	Desc: I need a pawn that can fly but that can also behave differently
	Author: Matthieu
*/

class MiniEdPawn extends xPawn
	native;

var bool   bRebounding;     			// camera is rebounding away from a selected mesh it collided with
var bool   bAutoRaising;                // camera height is being locked in with terrain heigh changes
var float  IndependantControlTimeLeft;	// how much time left till user regains control of camera
var vector SnappingVelocity;			// in snapping mode, objects pull the camera prop. to 1/dist^2

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem147
     End Object
     HParams=HavokSkeletalSystem'MiniEd.HavokSkeletalSystem147'
     Physics=PHYS_Manual
}
