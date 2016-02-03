//=============================================================================
// DecoVolumeObject.
//
// A class that allows staticmesh actors to get spawned inside of
// deco volumes.  These are the actors that you actually see in the level.
//=============================================================================
class DecoVolumeObject extends Actor
	native;

defaultproperties
{
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     DrawType=DT_StaticMesh
}
