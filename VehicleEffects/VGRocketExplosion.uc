Class VGRocketExplosion extends Emitter;

defaultproperties
{
     CameraShakeRadius=800.000000
     CameraShakeTime=0.500000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter95
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.black_smoke'
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=25.000000)
         Acceleration=(Z=450.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-80.000000,Max=100.000000),Y=(Min=-80.000000,Max=100.000000),Z=(Min=20.000000,Max=180.000000))
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=7.000000,Max=8.500000))
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=12.000000))
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter95'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter96
         MaxParticles=1
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         InitialParticlesPerSecond=250.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.ExploOrange'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         LifetimeRange=(Min=0.500000,Max=0.600000)
         InitialDelayRange=(Min=-0.250000,Max=-0.250000)
         StartVelocityRange=(Z=(Min=500.000000,Max=500.000000))
         VelocityLossRange=(Z=(Min=2.000000,Max=3.000000))
         GetVelocityDirectionFrom=PTVD_StartPositionAndOwner
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter96'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter97
         MaxParticles=1
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.explo4x4'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=180.000000,Max=200.000000))
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(Z=(Min=900.000000,Max=900.000000))
         VelocityLossRange=(Z=(Min=10.000000,Max=10.000000))
         GetVelocityDirectionFrom=PTVD_StartPositionAndOwner
         RespawnDeadParticles=False
         AutoDestroy=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter97'
     AutoDestroy=True
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
