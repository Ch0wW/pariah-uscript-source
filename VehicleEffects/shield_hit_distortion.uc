Class shield_hit_distortion extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter475
         MaxParticles=1
         FadeOutStartTime=-0.250000
         InitialParticlesPerSecond=1500.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.shield_hit_distort'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=35.000000,Max=35.000000))
         LifetimeRange=(Min=0.500000,Max=0.600000)
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter475'
     PostEffectsType=PTFT_Distortion
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
