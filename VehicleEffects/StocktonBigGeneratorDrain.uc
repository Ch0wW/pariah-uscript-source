class StocktonBigGeneratorDrain extends Stockton;

defaultproperties
{
     Begin Object Class=EmberEmitter Name=EmberEmitter0
         ProjectionNormal=(Z=0.000000)
         MaxParticles=100
         FadeOutStartTime=0.950000
         FadeInEndTime=0.200000
         Texture=Texture'DavidTextures.Shroud.DNAstrip4'
         ColorScale(0)=(Color=(B=64,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=230,G=224,R=250))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=0.000000)
         StartLocationOffset=(X=550.000000)
         StartLocationRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         SphereRadiusRange=(Min=-64.000000,Max=64.000000)
         RotationDampingFactorRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RevolutionsPerSecondRange=(Y=(Min=0.050000,Max=0.050000))
         StartSizeRange=(X=(Min=6.000000,Max=8.000000),Y=(Min=32.000000,Max=32.000000),Z=(Min=100.000000,Max=100.000000))
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=-800.000000,Max=-800.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         FadeIn=True
         RespawnDeadParticles=False
     End Object
     Emitters(0)=EmberEmitter'VehicleEffects.EmberEmitter0'
     Tag="BigGeneratorDrain"
     bNoDelete=False
     bDirectional=True
}
