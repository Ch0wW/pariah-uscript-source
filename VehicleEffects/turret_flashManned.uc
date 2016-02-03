Class turret_flashManned extends MuzzleFlash;

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    mStartParticles += mNumPerFlash;
}

simulated function Flash(int mode)
{
    mStartParticles = mNumPerFlash;
}

simulated function StartFlash()
{
    mRegenRange[0]=12.000000;
    mRegenRange[1]=12.000000;
}

simulated function StopFlash()
{
    mRegenRange[0]=0;
    mRegenRange[1]=0;
}

defaultproperties
{
     mNumPerFlash=2
     mMaxParticles=2
     mLifeRange(0)=0.050000
     mLifeRange(1)=0.050000
     mSizeRange(0)=0.700000
     mSizeRange(1)=1.000000
     mMeshNodes(0)=StaticMesh'BlowoutGeneralMeshes.Effects.MachinegunMuzFlashMesh'
     mAttenFunc=ATF_SmoothStep
     DrawScale=0.650000
     Skins(0)=FinalBlend'VehicleGameTextures.Effects.LazerMuzFlash_B'
     Style=STY_Translucent
}
