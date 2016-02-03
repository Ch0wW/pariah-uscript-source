//=============================================================================
//=============================================================================
class LaserEffect extends xEmitter;

//#exec TEXTURE  IMPORT NAME=LightningBoltT FILE=textures\LightningBolt.tga GROUP="Skins" DXT=5
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
#exec OBJ LOAD File=VehicleGameTextures.utx

defaultproperties
{
     mStartParticles=30
     mMaxParticles=30
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.500000
     mPosDev=(X=15.000000,Y=15.000000,Z=15.000000)
     mSpawnVecB=(X=40.000000,Y=40.000000,Z=10.000000)
     mParticleType=PT_Branch
     mRegen=False
     blockOnNet=True
     Skins(0)=Texture'VehicleGameTextures.Effects.BlueTrail'
     RemoteRole=ROLE_DumbProxy
     Style=STY_Additive
     bReplicateInstigator=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
}
