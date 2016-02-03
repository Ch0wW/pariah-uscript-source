//=============================================================================
// BloodJet.
//=============================================================================
class BloodJet extends xEmitter;

simulated function Tick( float dt )
{
    if( LifeSpan < 1.0 )
    {
        mRegenRange[0] *= LifeSpan;
        mRegenRange[1] = mRegenRange[0];
    }
    Super.Tick(dt);
}

defaultproperties
{
     mStartParticles=0
     mMaxParticles=30
     mNumTileColumns=4
     mNumTileRows=4
     mRegenOnTime(0)=1.000000
     mRegenOnTime(1)=2.000000
     mRegenOffTime(0)=0.400000
     mRegenOffTime(1)=1.000000
     mLifeRange(0)=0.600000
     mLifeRange(1)=1.000000
     mRegenRange(0)=80.000000
     mRegenRange(1)=80.000000
     mSpeedRange(0)=50.000000
     mSpeedRange(1)=90.000000
     mMassRange(0)=0.400000
     mMassRange(1)=0.500000
     mAirResistance=0.600000
     mGrowthRate=12.000000
     mDirDev=(X=0.050000,Y=0.050000,Z=0.050000)
     mRegenPause=True
     mRandOrient=True
     mRandTextures=True
     LifeSpan=1.000000
     Skins(0)=Texture'VehicleGameTextures.Effects.BloodJet'
     Style=STY_Alpha
}
