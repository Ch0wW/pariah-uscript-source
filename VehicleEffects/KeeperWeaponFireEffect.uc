class KeeperWeaponFireEffect extends David;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         RotatingSheets=3
         MaxParticles=1
         ColorScaleRepeats=3.000000
         FadeOutStartTime=0.020000
         FadeInEndTime=0.010000
         SizeScaleRepeats=3.000000
         InitialParticlesPerSecond=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.PulseRifle.PulseRifleBeamTex'
         ColorScale(0)=(Color=(B=253,G=193,R=222))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=251,G=114,R=178))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         LifetimeRange=(Min=0.250000,Max=0.250000)
         StartVelocityRange=(X=(Min=5000.000000,Max=5000.000000))
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=BeamEmitter'VehicleEffects.BeamEmitter0'
     Tag="KeeperWeaponFireEffect"
     bNoDelete=False
     bDirectional=True
}
