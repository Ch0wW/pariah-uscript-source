Class PlasmaTrail extends ParticleRocketTrailFlameSmall;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter447
         MaxParticles=90
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=60.000000
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flame'
         SizeScale(0)=(RelativeSize=4.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=5.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(Z=400.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=20.000000))
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         RotationDampingFactorRange=(X=(Min=50.000000,Max=50.000000))
         RevolutionsPerSecondRange=(X=(Max=2.000000),Y=(Max=0.200000),Z=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=8.000000,Max=10.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         UseRotationFrom=PTRS_Normal
         UseColorScale=True
         FadeOut=True
         AutoDestroy=True
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter447'
     AutoDestroy=True
     Skins(0)=Texture'PariahWeaponEffectsTextures.Rocket.RocketFlareZ'
}
