Class VGRocketMetalHit extends DavidVehicleExplosionDirt;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(3.0, false);
}

simulated function Timer()
{
	Emitters[2].ParticlesPerSecond = 0;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter320
         MaxParticles=6
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.black_debrie'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=-1600.000000)
         SphereRadiusRange=(Max=50.000000)
         SpinCCWorCW=(Y=-0.500000)
         SpinsPerSecondRange=(X=(Max=0.080000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         RevolutionsPerSecondRange=(Y=(Min=0.200000,Max=0.200000))
         StartSizeRange=(X=(Min=40.000000,Max=50.000000))
         LifetimeRange=(Min=0.600000,Max=0.800000)
         StartVelocityRange=(X=(Min=-350.000000,Max=350.000000),Y=(Min=-350.000000,Max=350.000000),Z=(Min=1400.000000,Max=1600.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter320'
     Begin Object Class=MeshEmitter Name=MeshEmitter52
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         UseParticleColor=True
         MaxParticles=3
         FadeOutStartTime=3.000000
         InitialParticlesPerSecond=100.000000
         Acceleration=(Z=-2000.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.400000,Max=0.500000))
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RotationDampingFactorRange=(X=(Max=0.000010),Z=(Max=0.100000))
         StartSizeRange=(X=(Min=0.150000,Max=0.200000),Y=(Min=0.800000,Max=1.200000),Z=(Min=0.800000,Max=1.200000))
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=1300.000000,Max=2500.000000))
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Min=0.700000,Max=1.000000))
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter52'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter302
         MaxParticles=20
         AddLocationFromOtherEmitter=1
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         ParticlesPerSecond=70.000000
         InitialParticlesPerSecond=70.000000
         Texture=Texture'NoonTextures.Fire.firepoop'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSizeRange=(X=(Min=3.000000,Max=4.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(Z=(Min=30.000000,Max=40.000000))
         DrawStyle=PTDS_Brighten
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter302'
     Begin Object Class=MeshEmitter Name=MeshEmitter55
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         UseParticleColor=True
         InitialParticlesPerSecond=250.000000
         Acceleration=(Z=-1600.000000)
         DampingFactorRange=(X=(Min=0.600000,Max=0.700000),Y=(Min=0.600000,Max=0.700000),Z=(Min=0.400000,Max=0.500000))
         SpinsPerSecondRange=(Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         StartSpinRange=(X=(Min=1.000000,Max=4.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=1.000000,Max=4.000000))
         RotationDampingFactorRange=(X=(Min=20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=0.010000,Max=0.400000),Y=(Min=0.360000,Max=0.360000),Z=(Min=0.800000,Max=0.900000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-1100.000000,Max=1100.000000),Y=(Min=-1100.000000,Max=1100.000000),Z=(Min=200.000000,Max=900.000000))
         VelocityLossRange=(X=(Max=0.500000))
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(3)=MeshEmitter'VehicleEffects.MeshEmitter55'
     LifeSpan=3.500000
     Tag="DavidVehicleExplosionDirt"
     bUnlit=False
}
