Class HoverVehicleWater extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter441
         MaxParticles=50
         FadeOutStartTime=4.000000
         FadeInEndTime=0.200000
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=230.000000
         OwnerBaseVelocityTransferAmount=0.500000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireWaterMist'
         ColorScale(0)=(Color=(B=250,G=250,R=250,A=64))
         ColorScale(1)=(RelativeTime=5.000000,Color=(B=250,G=250,R=250,A=1))
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=10.000000)
         Acceleration=(Z=-500.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=500.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=2.000000,Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter441'
     Tag="DavidTireWater"
     bNoDelete=False
}
