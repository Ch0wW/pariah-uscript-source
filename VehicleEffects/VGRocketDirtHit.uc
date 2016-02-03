Class VGRocketDirtHit extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter73
         MaxParticles=17
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=1.000000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.brown_smoke'
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=25.000000)
         Acceleration=(Z=-100.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=20.000000,Max=180.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         StartSizeRange=(X=(Min=8.000000,Max=9.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter73'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter74
         MaxParticles=6
         FadeOutStartTime=-1.000000
         InitialParticlesPerSecond=250.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.Explosion_Dirt'
         ColorScale(0)=(RelativeTime=15.000000,Color=(B=67,G=86,R=93))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=-1800.000000)
         ColorMultiplierRange=(X=(Min=255.000000,Max=255.000000),Y=(Min=255.000000,Max=255.000000),Z=(Min=255.000000,Max=255.000000))
         StartColorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Min=-0.080000,Max=0.080000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=80.000000,Max=80.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=800.000000,Max=1500.000000))
         VelocityLossRange=(Z=(Max=4.000000))
         UseRotationFrom=PTRS_Actor
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
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter74'
     AutoDestroy=True
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
