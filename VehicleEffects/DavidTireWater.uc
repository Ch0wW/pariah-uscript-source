Class DavidTireWater extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter392
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.500000
         Texture=Texture'NoonTextures.Particles.water3_b'
         ColorScale(0)=(Color=(B=231,G=227,R=218,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=112,G=97,R=90,A=255))
         SizeScale(0)=(RelativeSize=0.600000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Acceleration=(X=-50.000000,Y=-50.000000,Z=-1700.000000)
         ColorMultiplierRange=(X=(Min=0.900000),Y=(Min=0.900000),Z=(Min=0.900000))
         StartLocationOffset=(Z=-30.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=100.000000,Max=150.000000))
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter392'
     Tag="DavidTireWater"
     bNoDelete=False
}
