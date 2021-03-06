class StocktonShieldHit extends Stockton;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter389
         MaxParticles=7
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-0.100000
         InitialParticlesPerSecond=100.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.shield_ring'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=4.000000)
         SpinsPerSecondRange=(X=(Min=0.300000,Max=0.500000))
         StartSizeRange=(X=(Min=8.000000,Max=13.000000))
         LifetimeRange=(Min=0.400000,Max=0.500000)
         DrawStyle=PTDS_Brighten
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter389'
     DrawScale=0.400000
     Tag="StocktonShieldHit"
     bNoDelete=False
     bUnlit=False
}
