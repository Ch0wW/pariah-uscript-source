//=============================================================================
// xCTFBase.
// For decoration only, this actor serves no game-related purpose!
//=============================================================================
class xCTFBase extends Decoration;

defaultproperties
{
     DrawScale=0.600000
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.FlagBase'
     Skins(0)=Texture'EmitterTextures2.FlagBase_Blue'
     Skins(1)=Shader'EmitterTextures2.FlagBase_shader'
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_None
     bStatic=False
}
