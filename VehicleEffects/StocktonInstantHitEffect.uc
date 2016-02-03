class StocktonInstantHitEffect extends Stockton;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter52
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseDirectionAs=PTDU_Normal
         MaxParticles=1
         FadeOutStartTime=0.100000
         InitialParticlesPerSecond=1000.000000
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.shield_hit_orange'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartLocationOffset=(X=120.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=0.200000,Max=0.200000)
         UseRotationFrom=PTRS_Actor
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter52'
     Tag="StocktonInstantHitEffect"
     bNoDelete=False
     bDirectional=True
}
