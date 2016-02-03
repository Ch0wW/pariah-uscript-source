class FlakBeam extends xEmitter
	placeable;

defaultproperties
{
     mStartParticles=2
     mMaxParticles=2
     mLifeRange(0)=0.700000
     mRegenDist=5000.000000
     mSpinRange(0)=50000.000000
     mSpinRange(1)=12546.416992
     mSizeRange(0)=8.000000
     mSizeRange(1)=8.000000
     mGrowthRate=30.000000
     mColorRange(0)=(B=250,G=250,R=250)
     mColorRange(1)=(B=250,G=250,R=250)
     mParticleType=PT_Beam
     mDistanceAtten=True
     mWaveLockEnd=True
     LifeSpan=1.500000
     Skins(0)=Shader'PariahWeaponEffectsTextures.Bulldog.FBeamShader'
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Translucent
     bReplicateInstigator=True
     bReplicateMovement=False
}
