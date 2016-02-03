//=============================================================================
// used for timed projectors on walls (bullet marks, blood stains)
//=============================================================================
class WallMark extends Projector;

var float Lifetime;

function PostBeginPlay()
{
	local rotator randRoll;
	randRoll = RotRand(true);
	randRoll.Pitch = Rotation.Pitch;
	randRoll.Yaw = Rotation.Yaw;
	SetRotation(randRoll);
	AttachProjector();
	//AbandonProjector(Lifetime);

	SetTimer(LifeTime,false);
//	Destroy();
}

simulated function Timer()
{
	Destroy();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Destroy();
}

defaultproperties
{
     Lifetime=3.000000
     MaxTraceDistance=32
     bProjectActor=False
     bClipBSP=True
     bStatic=False
}
