Class DavidTB3Exhaust extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter11
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         ParticlesPerSecond=10.000000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=169,G=169,R=169,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=120,G=120,R=120,A=255))
         SizeScale(0)=(RelativeSize=0.050000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.150000)
         LifetimeRange=(Min=0.200000,Max=0.250000)
         StartVelocityRange=(X=(Min=-50.000000,Max=-100.000000),Z=(Min=20.000000,Max=40.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter11'
     Tag="Emitter"
     bNoDelete=False
}
