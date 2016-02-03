class DaviDTireDirtC extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter412
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         ParticlesPerSecond=30.000000
         OwnerBaseVelocityTransferAmount=0.300000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=145,G=155,R=162,A=155))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=66,G=80,R=89,A=155))
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter412'
     Tag="DavidTireDirtC"
     bNoDelete=False
     bUnlit=False
}
