class DavidTireDust extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter387
         MaxParticles=30
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=1.000000
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.200000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=67,G=77,R=80,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=131,G=145,R=150,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=122,G=125,R=126,A=255))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(X=-100.000000,Y=-100.000000,Z=-30.000000)
         StartLocationOffset=(Z=-40.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         LifetimeRange=(Min=2.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=50.000000,Max=100.000000))
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter387'
     bNoDelete=False
     bUnlit=False
}
