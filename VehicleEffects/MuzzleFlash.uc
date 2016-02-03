class MuzzleFlash extends xEmitter;

var int NumPerFlash;

simulated function Flash(int mode)
{
    mStartParticles = NumPerFlash;
}

defaultproperties
{
     NumPerFlash=1
     mStartParticles=0
     mMaxParticles=3
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mAirResistance=0.000000
     mSpawnVecB=(Z=0.000000)
     mParticleType=PT_Mesh
     mPosRelative=True
     mRandOrient=True
     Skins(0)=Texture'Engine.S_Emitter'
}
