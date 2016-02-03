Class MannyWaterSplash extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter47
         MaxParticles=3
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.350000
         FadeInEndTime=2.000000
         ParticlesPerSecond=3.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.wter_mist1'
         SizeScale(0)=(RelativeTime=0.800000,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=25.000000)
         Acceleration=(Z=-500.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(Z=(Min=-30.000000,Max=-30.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.080000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=5.000000,Max=6.000000))
         LifetimeRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=400.000000,Max=400.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=5.000000,Max=5.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter47'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter48
         MaxParticles=6
         ParticlesPerSecond=4.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.waterfall_hit1'
         ColorScale(0)=(RelativeTime=15.000000,Color=(B=67,G=86,R=93))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Z=-1800.000000)
         ColorMultiplierRange=(X=(Min=255.000000,Max=255.000000),Y=(Min=255.000000,Max=255.000000),Z=(Min=255.000000,Max=255.000000))
         StartColorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartLocationRange=(Y=(Min=-60.000000,Max=60.000000),Z=(Min=-40.000000,Max=-40.000000))
         SpinCCWorCW=(X=-1.000000,Y=1.000000,Z=-2.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.500000))
         StartSizeRange=(X=(Min=30.000000,Max=40.000000))
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=480.000000,Max=500.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter48'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
