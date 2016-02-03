Class GrenadeFuse extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter428
         MaxParticles=16
         Texture=Texture'MannyTextures.Coronas.sun_corona3'
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=128,G=128,R=128))
         ColorScale(2)=(RelativeTime=0.750000,Color=(B=128,G=128,R=128,A=12))
         ColorScale(3)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=22.000000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=19.000000)
         ColorMultiplierRange=(X=(Min=0.300000,Max=0.300000),Y=(Min=0.300000,Max=0.300000),Z=(Min=0.300000,Max=0.300000))
         StartSpinRange=(X=(Min=15.000000,Max=20.000000))
         StartSizeRange=(X=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-16.000000,Max=-24.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         VelocityLossRange=(X=(Min=0.900000,Max=0.900000))
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter428'
     Tag="Emitter"
     bNoDelete=False
}
