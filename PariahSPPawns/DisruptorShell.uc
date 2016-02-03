class DisruptorShell extends Actor;

function Tick(float dt)
{
	local rotator r;

	r.roll = Rotation.roll + 50000.0*dt;

	SetRelativeRotation(r);
}

defaultproperties
{
     DrawScale=2.000000
     StaticMesh=StaticMesh'DronesStaticMeshes.ProtectorDroneShell'
     Skins(0)=Shader'DroneTex.Protector.ProtectorShader'
     DrawType=DT_StaticMesh
}
