class DaviDTireDirtB extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter385
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         ParticlesPerSecond=30.000000
         OwnerBaseVelocityTransferAmount=0.300000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=45,G=55,R=62,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=66,G=80,R=89,A=255))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartLocationOffset=(Z=-45.000000)
         SphereRadiusRange=(Min=-5.000000,Max=5.000000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         LifetimeRange=(Min=0.200000,Max=0.300000)
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter385'
     Tag="DavidTireDirtB"
     bNoDelete=False
     bUnlit=False
}
