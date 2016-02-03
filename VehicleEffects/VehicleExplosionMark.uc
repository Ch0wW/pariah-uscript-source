class VehicleExplosionMark extends WallMark;

#exec OBJ LOAD FILE=..\textures\PariahWeaponEffectsTextures.utx

defaultproperties
{
     Lifetime=10.000000
     MaxTraceDistance=100
     ProjTexture=Texture'PariahWeaponEffectsTextures.Decals.ScorchRocket'
     bProjectParticles=False
     bClipBSP=False
     DrawScale=6.000000
}
