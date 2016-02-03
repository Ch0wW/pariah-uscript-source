Class GrenadeTrail extends ParticleRocketTrailFlameSmall;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter450
         MaxParticles=50
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.300000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=50.000000
         Texture=Texture'PariahWeaponEffectsTextures.explosions.Explo4x4Blue'
         ColorScale(0)=(Color=(B=26,G=140,R=255,A=128))
         ColorScale(1)=(RelativeTime=2.000000,Color=(B=55,G=255,R=250,A=102))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=300.000000)
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         RotationDampingFactorRange=(X=(Min=50.000000,Max=50.000000))
         RevolutionsPerSecondRange=(X=(Max=2.000000),Y=(Max=0.200000),Z=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=8.000000,Max=10.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=1.000000))
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_Brighten
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter450'
     AutoDestroy=True
     Skins(0)=Texture'PariahWeaponEffectsTextures.Rocket.RocketFlareZ'
}
