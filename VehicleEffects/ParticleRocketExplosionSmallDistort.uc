class ParticleRocketExplosionSmallDistort extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter442
         MaxParticles=9
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.950000
         FadeInEndTime=0.250000
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'RonsTextures.Distort.explo4x4norm'
         ColorScale(0)=(Color=(B=45,G=109,R=140))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         Acceleration=(Z=150.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=5.000000,Max=10.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartLocationPolarRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000),Y=(Min=-0.400000,Max=0.400000),Z=(Min=-0.400000,Max=0.400000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=17.000000,Max=25.000000),Y=(Min=17.000000,Max=25.000000),Z=(Min=17.000000,Max=25.000000))
         LifetimeRange=(Min=1.500000,Max=0.250000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=100.000000,Max=700.000000))
         StartVelocityRadialRange=(Min=-150.000000,Max=150.000000)
         VelocityLossRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Min=2.000000,Max=3.000000))
         EffectAxis=PTEA_PositiveZ
         DrawStyle=PTDS_AlphaBlend
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter442'
     PostEffectsType=PTFT_Distortion
     AutoDestroy=True
     Tag="ParticleRocketExplosion"
     bNoDelete=False
}
