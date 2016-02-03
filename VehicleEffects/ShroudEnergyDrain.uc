class ShroudEnergyDrain extends Characters;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter80
         MaxParticles=50
         InitialParticlesPerSecond=7.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=0.500000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         ColorMultiplierRange=(X=(Min=0.700000),Y=(Min=0.700000))
         StartColorRange=(X=(Min=200.000000),Y=(Min=200.000000),Z=(Min=200.000000))
         StartLocationOffset=(X=120.000000,Z=70.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=0.010000,Max=0.050000))
         StartSpinRange=(X=(Max=16384.000000))
         RotationDampingFactorRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=70.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(Z=(Min=-50.000000,Max=-50.000000))
         UseColorScale=True
         SpinParticles=True
         DampRotation=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter80'
     Tag="ShroudEnergyDrain"
     bNoDelete=False
     bDirectional=True
}
