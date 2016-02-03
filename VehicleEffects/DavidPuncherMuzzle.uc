Class DavidPuncherMuzzle extends MuzzleFlash;


simulated function Flash(int mode)
{
	mRegenPause=false;
	SetTimer(0.05,false);
}

simulated function Timer()
{
	mRegenPause=true;
}

defaultproperties
{
     mMaxParticles=100
     mNumTileColumns=4
     mPreheatSeconds=5.000000
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.300000
     mRegenRange(0)=20.000000
     mRegenRange(1)=20.000000
     mSpeedRange(0)=400.000000
     mSpeedRange(1)=200.000000
     mAirResistance=2.000000
     mSizeRange(0)=25.000000
     mSizeRange(1)=25.000000
     mGrowthRate=120.000000
     mAttenKa=0.300000
     mSpawnVecB=(Z=0.300000)
     mParticleType=PT_Sprite
     mAttenFunc=ATF_None
     mRegenPause=True
     mAttenuate=False
     mTileAnimation=True
     Tag="xEmitter"
     Skins(0)=Texture'PariahVehicleWeaponTextures.Puncher.MuzzleFlash'
     Style=STY_Translucent
}
