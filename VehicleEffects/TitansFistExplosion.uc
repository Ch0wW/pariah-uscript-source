Class TitansFistExplosion extends Emitter;

defaultproperties
{
     CameraShakeRadius=1000.000000
     CameraShakeTime=0.500000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter474
         MaxParticles=18
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.150000
         InitialParticlesPerSecond=2000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'MynkiTextures.Effects.BrightYellowFlames'
         ColorScale(0)=(Color=(B=45,G=109,R=140))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
         SizeScale(0)=(RelativeSize=10.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=150.000000)
         AutoResetTimeRange=(Min=1.000000,Max=1.000000)
         StartLocationRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Max=100.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartLocationPolarRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=9.000000,Max=11.000000),Y=(Min=9.000000,Max=11.000000),Z=(Min=17.000000,Max=25.000000))
         LifetimeRange=(Min=0.300000,Max=1.100000)
         StartVelocityRange=(X=(Min=-2000.000000,Max=2000.000000),Y=(Min=-2000.000000,Max=2000.000000),Z=(Min=-2000.000000,Max=2000.000000))
         StartVelocityRadialRange=(Min=-150.000000,Max=400.000000)
         VelocityLossRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
         EffectAxis=PTEA_PositiveZ
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter474'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         MaxParticles=100
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.bullet_slug_glowing'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=-2000.000000)
         DampingFactorRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.600000,Max=0.600000),Z=(Min=0.700000,Max=0.800000))
         AutoResetTimeRange=(Min=1.000000,Max=1.000000)
         SphereRadiusRange=(Min=-10.000000,Max=10.000000)
         StartSizeRange=(X=(Min=9.000000,Max=13.000000))
         LifetimeRange=(Min=0.700000,Max=1.500000)
         StartVelocityRadialRange=(Min=1200.000000,Max=6000.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         StartLocationShape=PTLS_Sphere
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseCollision=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter16'
     LifeSpan=15.000000
     DrawScale=0.500000
     Tag="Emitter"
     RemoteRole=ROLE_SimulatedProxy
     bNoDelete=False
     bNetInitialRotation=True
}
