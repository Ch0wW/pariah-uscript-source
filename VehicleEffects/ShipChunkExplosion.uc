class ShipChunkExplosion extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         MaxParticles=12
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.950000
         FadeInEndTime=0.850000
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.explo4x4'
         ColorScale(0)=(Color=(B=45,G=109,R=140))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
         SizeScale(0)=(RelativeSize=6.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=9.000000)
         Acceleration=(Z=150.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartLocationPolarRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000),Y=(Min=-0.400000,Max=0.400000),Z=(Min=-0.400000,Max=0.400000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=17.000000,Max=25.000000),Y=(Min=17.000000,Max=25.000000),Z=(Min=17.000000,Max=25.000000))
         LifetimeRange=(Min=1.500000,Max=0.250000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-100.000000,Max=150.000000))
         StartVelocityRadialRange=(Min=-150.000000,Max=150.000000)
         VelocityLossRange=(X=(Max=0.300000),Y=(Max=0.300000),Z=(Min=2.000000,Max=3.000000))
         EffectAxis=PTEA_PositiveZ
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter0'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter476
         MaxParticles=2
         InitialParticlesPerSecond=4000.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.FlashRound'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=23,G=32,R=83))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=1,G=21,R=31))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.500000)
         StartLocationRange=(X=(Min=75.000000,Max=75.000000))
         LifetimeRange=(Min=0.150000,Max=0.150000)
         StartVelocityRange=(X=(Min=3000.000000,Max=3000.000000))
         UseRotationFrom=PTRS_Actor
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter476'
     AutoDestroy=True
     Tag="ShipChunkExplosion"
     bNoDelete=False
}
