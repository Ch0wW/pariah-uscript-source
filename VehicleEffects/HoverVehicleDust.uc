Class HoverVehicleDust extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter430
         MaxParticles=50
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=4.000000
         FadeInEndTime=0.100000
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=230.000000
         OwnerBaseVelocityTransferAmount=0.300000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=145,G=155,R=162,A=155))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=66,G=80,R=89,A=155))
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=10.000000)
         Acceleration=(Z=-500.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=500.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=2.000000,Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter430'
     Tag="DavidTireDirtC"
     bNoDelete=False
}
