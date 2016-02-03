Class DavidVehicleExplosionSmoke extends xEmitter;

defaultproperties
{
     mStartParticles=100
     mMaxParticles=100
     mLifeRange(0)=2.000000
     mLifeRange(1)=2.200000
     mSpeedRange(0)=5000.000000
     mSpeedRange(1)=1000.000000
     mAirResistance=8.000000
     mSpinRange(0)=20.000000
     mSpinRange(1)=-20.000000
     mSizeRange(0)=200.000000
     mSizeRange(1)=125.000000
     mGrowthRate=50.000000
     mAttenKb=0.020000
     mColorRange(1)=(B=100,G=100,R=100)
     mSpawningType=ST_ExplodeRing
     mAttenFunc=ATF_SmoothStep
     mRegen=False
     mPosRelative=True
     mRandOrient=True
     Skins(0)=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.explosion_smoke'
     Style=STY_Alpha
}
