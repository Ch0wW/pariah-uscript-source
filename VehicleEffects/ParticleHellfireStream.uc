//=============================================================================
class ParticleHellfireStream extends xEmitter;

#exec OBJ LOAD File=VehicleGameTextures.utx

defaultproperties
{
     mStartParticles=2
     mMaxParticles=30
     mLifeRange(0)=1.500000
     mLifeRange(1)=1.500000
     mRegenRange(0)=50.000000
     mRegenRange(1)=50.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mSizeRange(0)=18.000000
     mSizeRange(1)=18.000000
     mGrowthRate=6.000000
     mAttenKa=0.000000
     mSpawnVecB=(X=40.000000,Z=0.000000)
     mParticleType=PT_Stream
     LifeSpan=10.000000
     Skins(0)=Texture'VehicleGameTextures.Effects.VioletTrail'
     Physics=PHYS_Trailer
     Style=STY_Additive
}
