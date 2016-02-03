Class Minied_GameObjectPulse extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=Pulse
         MaxParticles=3
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         InitialParticlesPerSecond=100.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.shield_ring'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=7.000000)
         StartColorRange=(Y=(Min=128.000000,Max=128.000000),Z=(Min=128.000000,Max=128.000000))
         SpinsPerSecondRange=(X=(Min=0.300000,Max=0.500000))
         StartSizeRange=(X=(Min=22.000000,Max=37.000000))
         LifetimeRange=(Min=0.400000,Max=0.500000)
         FadeOut=True
         RespawnDeadParticles=False
         AutoReset=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.Pulse'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
