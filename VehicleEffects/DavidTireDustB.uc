Class DavidTireDustB extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter390
         MaxParticles=15
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.100000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=67,G=77,R=80,A=155))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=131,G=145,R=150,A=155))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=122,G=125,R=126,A=155))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(X=-50.000000,Y=-50.000000,Z=-20.000000)
         StartLocationOffset=(Z=-40.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=10.000000,Max=50.000000),Y=(Min=10.000000,Max=50.000000))
         StartLocationShape=PTLS_All
         DrawStyle=PTDS_AlphaBlend
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter390'
     bNoDelete=False
}
