//=============================================================================
// xDomA.
//=============================================================================
class xDomA extends xDOMLetter;

defaultproperties
{
     DrawScale=0.250000
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.Assault.AssaultPoint'
     Skins(0)=Shader'VehicleGamePickupsTex.Ammo.assault_neutral_shader'
     RotationRate=(Yaw=24000)
     Physics=PHYS_Rotating
     DrawType=DT_StaticMesh
     bStatic=False
     bStasis=False
     bFixedRotationDir=True
}
