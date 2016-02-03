Class DavidEngineSmoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter379
         MaxParticles=30
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         OwnerBaseVelocityTransferAmount=0.500000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=70,G=170,R=244,A=100))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=77,G=77,R=77,A=200))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=129,G=129,R=129,A=1))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.700000)
         Acceleration=(Z=-200.000000)
         SphereRadiusRange=(Max=50.000000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(Z=(Min=50.000000,Max=300.000000))
         VelocityLossRange=(Z=(Min=0.500000,Max=1.000000))
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter379'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter380
         MaxParticles=5
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.050000
         FadeInEndTime=0.020000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.Explosion_Flame'
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         SphereRadiusRange=(Max=10.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         LifetimeRange=(Min=0.250000,Max=0.300000)
         StartVelocityRange=(Z=(Min=50.000000,Max=150.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter380'
     bNoDelete=False
}
