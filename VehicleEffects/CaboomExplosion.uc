class CaboomExplosion extends Vehicles;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter482
         MaxParticles=5
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.black_smoke'
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=10.000000,RelativeSize=30.000000)
         Acceleration=(Z=450.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-80.000000,Max=100.000000),Y=(Min=-80.000000,Max=100.000000),Z=(Min=20.000000,Max=180.000000))
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=12.000000,Max=16.000000))
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=12.000000))
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter482'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter484
         MaxParticles=3
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.300000
         InitialParticlesPerSecond=40.000000
         Texture=Texture'PariahWeaponEffectsTextures.explosions.manny_boom'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         StartSizeRange=(X=(Min=360.000000,Max=500.000000))
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(Z=(Min=700.000000,Max=1200.000000))
         VelocityLossRange=(Z=(Min=10.000000,Max=10.000000))
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
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter484'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter419
         MaxParticles=6
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.black_debrie'
         SizeScale(0)=(RelativeTime=5.000000,RelativeSize=15.000000)
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
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter419'
     Begin Object Class=MeshEmitter Name=MeshEmitter78
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         MaxParticles=6
         FadeOutStartTime=3.000000
         InitialParticlesPerSecond=100.000000
         Acceleration=(Z=-2000.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RotationDampingFactorRange=(X=(Max=0.000010),Z=(Max=0.100000))
         StartSizeRange=(X=(Min=0.200000,Max=0.400000),Y=(Min=0.800000,Max=1.200000),Z=(Min=0.800000,Max=1.200000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=1300.000000,Max=2500.000000))
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Min=0.700000,Max=1.000000))
         DrawStyle=PTDS_Regular
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(3)=MeshEmitter'VehicleEffects.MeshEmitter78'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter443
         MaxParticles=22
         AddLocationFromOtherEmitter=3
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.200000
         InitialParticlesPerSecond=70.000000
         Texture=Texture'NoonTextures.Fire.firepoop'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSizeRange=(X=(Min=4.000000,Max=5.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
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
     Emitters(4)=SpriteEmitter'VehicleEffects.SpriteEmitter443'
     Begin Object Class=MeshEmitter Name=MeshEmitter74
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         UseMeshBlendMode=False
         UseParticleColor=True
         MaxParticles=25
         InitialParticlesPerSecond=250.000000
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(Z=-1600.000000)
         DampingFactorRange=(X=(Min=0.600000,Max=0.700000),Y=(Min=0.600000,Max=0.700000),Z=(Min=0.400000,Max=0.500000))
         SpinsPerSecondRange=(Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         StartSpinRange=(X=(Min=1.000000,Max=4.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=1.000000,Max=4.000000))
         RotationDampingFactorRange=(X=(Min=20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=0.050000,Max=0.400000),Y=(Min=0.360000,Max=0.360000),Z=(Min=0.800000,Max=0.900000))
         LifetimeRange=(Min=0.700000,Max=0.800000)
         StartVelocityRange=(X=(Min=-1100.000000,Max=1100.000000),Y=(Min=-1100.000000,Max=1100.000000),Z=(Min=200.000000,Max=900.000000))
         VelocityLossRange=(X=(Max=0.500000))
         DrawStyle=PTDS_Darken
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(5)=MeshEmitter'VehicleEffects.MeshEmitter74'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter77
         MaxParticles=3
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.explo4x4'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Z=800.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=220.000000,Max=220.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(Z=(Min=500.000000,Max=500.000000))
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
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
     Emitters(6)=SpriteEmitter'VehicleEffects.SpriteEmitter77'
     AutoDestroy=True
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
