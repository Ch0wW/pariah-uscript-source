class ShroudEnergyDrainOff extends Characters;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter63
         MaxParticles=75
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(0)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.500000)
         Acceleration=(Z=250.000000)
         ColorMultiplierRange=(X=(Min=0.500000),Y=(Min=0.700000))
         StartLocationRange=(Y=(Min=-50.000000,Max=140.000000))
         StartLocationPolarRange=(Y=(Max=65535.000000),Z=(Min=110.000000,Max=120.000000))
         RotationOffset=(Pitch=16384)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000))
         StartSpinRange=(X=(Max=16384.000000))
         RevolutionsPerSecondRange=(Z=(Min=0.100000,Max=0.800000))
         StartSizeRange=(X=(Min=10.000000,Max=70.000000))
         InitialTimeRange=(Max=0.500000)
         LifetimeRange=(Min=0.700000,Max=1.000000)
         StartVelocityRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartVelocityRadialRange=(Min=300.000000,Max=300.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_All
         UseRotationFrom=PTRS_Actor
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter63'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter480
         MaxParticles=1
         InitialParticlesPerSecond=10000.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         SizeScale(0)=(RelativeSize=5.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=5.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartLocationOffset=(X=-50.000000)
         StartSpinRange=(X=(Max=16384.000000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter480'
     AutoDestroy=True
     Tag="ShroudEnergyDrain"
     bNoDelete=False
     bDirectional=True
}
