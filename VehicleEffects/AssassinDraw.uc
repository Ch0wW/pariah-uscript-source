class AssassinDraw extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=EmberEmitter Name=EmberEmitter2
         MaxParticles=300
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.995000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         Acceleration=(Z=0.000000)
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=0.000000,Max=0.000000))
         SphereRadiusRange=(Min=300.000000,Max=300.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         RevolutionsPerSecondRange=(Z=(Min=-2.000000,Max=2.000000))
         StartSizeRange=(X=(Min=16.000000,Max=32.000000),Y=(Min=64.000000,Max=128.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=False
         RespawnDeadParticles=False
         AutoDestroy=True
         UseRevolution=True
         UseSizeScale=False
         UseRegularSizeScale=True
     End Object
     Emitters(0)=EmberEmitter'VehicleEffects.EmberEmitter2'
     Begin Object Class=EmberEmitter Name=EmberEmitter7
         UseDirectionAs=PTDU_Forward
         MaxParticles=100
         InitialParticlesPerSecond=1000.000000
         WarmupTicksPerSecond=30.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=13.000000)
         Acceleration=(Z=0.000000)
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         SphereRadiusRange=(Min=320.000000,Max=320.000000)
         StartLocationPolarRange=(X=(Max=65535.000000),Y=(Max=65535.000000),Z=(Min=300.000000,Max=300.000000))
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         RotationNormal=(Z=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         InitialDelayRange=(Min=5.400000,Max=5.400000)
         StartVelocityRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         StartVelocityRadialRange=(Min=1.000000,Max=1.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Normal
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=False
         FadeOut=False
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseRevolution=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=EmberEmitter'VehicleEffects.EmberEmitter7'
     AmbientSound=Sound'BossFightSounds.Assassin.AssassinShockwaveCharge'
     bNoDelete=False
}