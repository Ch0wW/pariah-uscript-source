Class shield_hit_energy extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter37
         MaxParticles=2
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=-0.100000
         InitialParticlesPerSecond=15.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.shield_hit_ring'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=15.000000)
         SpinsPerSecondRange=(X=(Min=0.300000,Max=0.500000))
         StartSizeRange=(X=(Min=8.000000,Max=13.000000))
         LifetimeRange=(Min=0.400000,Max=0.500000)
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter37'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
