Class RailBeamWave extends xEmitter;

var		float		MaxBendStrength;
var		float		BendFactor;

simulated function PostBeginPlay()
{
	MaxBendStrength = RandRange(3.0,10.0);
	if(LifeSpan != 0.0)
		BendFactor = MaxBendStrength / LifeSpan;
	else
		BendFactor = 0;
}

simulated function Tick(float dt)
{
	mBendStrength += dt * BendFactor;
}

defaultproperties
{
     mMaxParticles=1
     mRegenDist=25.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=20.000000
     mAttenKa=0.100000
     mWaveFrequency=0.003000
     mWaveAmplitude=25.000000
     mWaveShift=5.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mParticleType=PT_Beam
     mWaveLockEnd=True
     LifeSpan=1.500000
     Skins(0)=TexPanner'PariahEffectsTextures.LaserRail.LaserRail_beam_pan'
     Style=STY_Additive
}
