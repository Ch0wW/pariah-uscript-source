class KeeperWeaponChargeEffect extends David;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter374
         MaxParticles=1
         ColorScaleRepeats=10.000000
         FadeOutStartTime=2.900000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(0)=(Color=(B=221,G=174,R=196))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=188,G=97,R=137))
         ColorScale(2)=(Color=(B=221,G=174,R=196))
         SizeScale(1)=(RelativeTime=0.900000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.925000,RelativeSize=5.000000)
         SizeScale(3)=(RelativeTime=0.935000)
         SizeScale(4)=(RelativeTime=0.945000,RelativeSize=5.000000)
         SizeScale(5)=(RelativeTime=0.955000)
         SizeScale(6)=(RelativeTime=1.000000)
         SpinsPerSecondRange=(X=(Min=10.000000,Max=10.000000))
         StartSpinRange=(X=(Min=-10.000000,Max=10.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter374'
     Tag="KeeperWeaponChargeEffect"
     bNoDelete=False
     bDirectional=True
}
