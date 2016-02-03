class AssassinBurst extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter328
         FadeOutStartTime=0.400000
         FadeInEndTime=0.100000
         StartLocationScaleUpTime=1.000000
         StartLocationScaleDownTime=1.000000
         InitialParticlesPerSecond=10000000.000000
         OwnerBaseVelocityTransferAmount=1000.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(0)=(Color=(B=250,G=255,R=151))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=213))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.600000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=100.000000)
         Acceleration=(Z=5000.000000)
         StartLocationOffset=(Z=-50.000000)
         StartLocationRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-3000.000000,Max=3000.000000))
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         RevolutionsPerSecondRange=(Z=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=50.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(Z=(Min=-1000.000000,Max=-1000.000000))
         StartVelocityRadialRange=(Min=200.000000,Max=200.000000)
         VelocityLossRange=(Z=(Min=18.000000,Max=18.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter328'
     bNoDelete=False
}
