//=============================================================================
//=============================================================================
class TracerTurretMesh extends Projectile;



simulated function PostBeginPlay()
{
	local vector Dir;

	Super.PostBeginPlay();

	Dir = vector(Rotation);
	Velocity = Speed * Dir;
}


simulated singular function Touch(Actor Other)
{
	Destroy();
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	Destroy();
}

simulated function BlowUp(vector HitLocation)
{
	Destroy();
}

defaultproperties
{
     Speed=34000.000000
     MaxSpeed=34000.000000
     LifeSpan=1.500000
     DrawScale=1.500000
     StaticMesh=StaticMesh'JS_Forest.TracerPlanes'
     DrawScale3D=(X=7.000000)
     DrawType=DT_StaticMesh
     bCollideActors=False
     bCollideWorld=False
}
