Class VehicleDeathFire extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=1.200000
         FadeInEndTime=0.200000
         Texture=Texture'NoonTextures.Smoke.smoke_3'
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=3.000000)
         StartLocationOffset=(Z=15.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.120000),Y=(Min=-0.100000,Max=0.120000))
         StartSizeRange=(X=(Min=80.000000,Max=85.000000),Y=(Min=80.000000,Max=85.000000),Z=(Min=80.000000,Max=85.000000))
         LifetimeRange=(Min=1.500000,Max=2.200000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=240.000000,Max=260.000000))
         VelocityLossRange=(Z=(Min=0.100000,Max=1.000000))
         EffectAxis=PTEA_PositiveZ
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         MaxParticles=5
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.300000
         FadeInEndTime=0.200000
         Texture=Texture'NoonTextures.Fire.fire_v2e'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.750000,RelativeSize=2.000000)
         StartLocationRange=(X=(Min=-28.000000,Max=28.000000),Y=(Min=-28.000000,Max=28.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=-0.120000),Y=(Min=0.100000,Max=-0.100000),Z=(Max=0.100000))
         StartSizeRange=(X=(Min=110.000000,Max=120.000000),Y=(Min=110.000000,Max=120.000000),Z=(Min=110.000000,Max=110.000000))
         LifetimeRange=(Min=0.850000,Max=0.500000)
         StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=215.000000,Max=240.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Brighten
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter2'
     Tag="Emitter"
     bNoDelete=False
}
