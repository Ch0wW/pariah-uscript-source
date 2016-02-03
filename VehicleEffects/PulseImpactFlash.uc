Class PulseImpactFlash extends xEmitter;

defaultproperties
{
     mMaxParticles=1
     mLifeRange(0)=0.100000
     mLifeRange(1)=0.100000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mSizeRange(0)=0.700000
     mSizeRange(1)=0.500000
     mMeshNodes(0)=StaticMesh'PariahWeaponEffectsMeshes.Puncher.BulletFlash'
     mParticleType=PT_Mesh
     mRegen=False
     Tag="xEmitter"
     Skins(0)=Shader'PariahWeaponEffectsTextures.PulseRifle.PulseRifleContactShader'
     Style=STY_Additive
}
