class StocktonSmallGeneratorDrain extends Stockton;

defaultproperties
{
     Begin Object Class=EmberEmitter Name=EmberEmitter4
         ProjectionNormal=(Z=0.000000)
         MaxParticles=100
         ColorScaleRepeats=1.500000
         FadeOutStartTime=0.100000
         FadeInEndTime=0.200000
         Texture=Texture'DavidTextures.Shroud.DNAstrip4'
         ColorScale(0)=(Color=(B=115,G=95,R=83))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=203,G=154,R=124))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=115,G=95,R=83))
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=0.000000)
         StartLocationOffset=(X=200.000000,Z=200.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=25.000000,Max=50.000000))
         RotationOffset=(Pitch=10000,Yaw=-10000)
         RotationDampingFactorRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RevolutionsPerSecondRange=(Y=(Min=0.500000,Max=1.000000))
         StartSizeRange=(X=(Min=6.000000,Max=8.000000),Y=(Min=32.000000,Max=32.000000),Z=(Min=100.000000,Max=100.000000))
         LifetimeRange=(Min=1.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-600.000000,Max=-800.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=-150.000000,Max=-500.000000))
         VelocityLossRange=(X=(Min=1.500000,Max=2.000000),Y=(Min=1.500000,Max=2.000000),Z=(Min=1.500000,Max=2.000000))
         UseRotationFrom=PTRS_Actor
         DampRotation=True
         UseRevolution=True
         UseSizeScale=False
     End Object
     Emitters(0)=EmberEmitter'VehicleEffects.EmberEmitter4'
     LifeSpan=3.000000
     AmbientSound=Sound'BossFightSounds.Stockton.StocktonGeneratorDrain'
     Tag="SmallGeneratorDrain"
     bNoDelete=False
     bDirectional=True
}
