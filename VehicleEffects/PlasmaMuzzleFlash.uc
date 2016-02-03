Class PlasmaMuzzleFlash extends xEmitter;

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

defaultproperties
{
     mNumPerFlash=1
     mStartParticles=0
     mMaxParticles=3
     mLifeRange(0)=0.050000
     mLifeRange(1)=0.050000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSizeRange(0)=1.200000
     mSizeRange(1)=1.500000
     mGrowthRate=2.200000
     mMeshNodes(0)=StaticMesh'PariahWeaponEffectsMeshes.PulseRifle.PulseRifleMuzzleMesh'
     mSpawnVecB=(Z=0.000000)
     mParticleType=PT_Mesh
     mPosRelative=True
     mRandOrient=True
     Skins(0)=FinalBlend'PariahWeaponEffectsTextures.PulseRifle.PulseRifleMuzzleFB'
     Style=STY_Additive
}
