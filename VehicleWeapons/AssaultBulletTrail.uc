class AssaultBulletTrail extends RailBeamWave;

simulated function Destroyed()
{
	//log("ABT destroyed!");
	Super.Destroyed();
}


//defaultproperties
//{
//    mStartParticles=0
//    mMaxParticles=1
//    mLifeRange(0)=0.150000
//    mLifeRange(1)=2.000000
//	LifeSpan=0.0
//    mRegenDist=1750.000000
//    mSpeedRange(0)=0.000000
//    mSpeedRange(1)=0.000000
//    mAirResistance=20.000000
//    mSpinRange(0)=90000000.000000
//    mSpinRange(1)=2398733312.000000
//    mSizeRange(0)=3.000000
//    mSizeRange(1)=2.500000
//    mWaveFrequency=0.008000
//    mWaveAmplitude=1.000000
//    mWaveShift=1.000000
//    mBendStrength=0.008000
//    mDistanceAtten=True
//    Tag="RailBeamWave"
//    Skins(0)=Shader'PariahWeaponEffectsTextures.Bulldog.bullet_tracer_shader'
//    bNoDelete=false
//	mRegen=true
//	bNetTemporary=false
//}

defaultproperties
{
     mStartParticles=0
     mMaxParticles=4
     mLifeRange(0)=1.000000
     mLifeRange(1)=0.000000
     mRegenDist=5000.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mAirResistance=10.000000
     mSpinRange(0)=200000.000000
     mSpinRange(1)=30926.289063
     mSizeRange(0)=6.000000
     mSizeRange(1)=6.000000
     mWaveFrequency=0.008000
     mWaveAmplitude=2.000000
     mWaveShift=0.050000
     mBendStrength=0.005000
     mColorRange(0)=(B=0,G=163,R=232)
     mColorRange(1)=(B=255,G=192,R=26)
     mAttenFunc=ATF_None
     mAttenuate=False
     LifeSpan=0.000000
     Tag="RailBeamWave"
     Skins(0)=Shader'PariahWeaponEffectsTextures.Bulldog.bullet_tracer_shader'
     bNetTemporary=False
}
