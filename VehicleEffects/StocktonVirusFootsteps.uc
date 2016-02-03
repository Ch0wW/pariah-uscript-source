class StocktonVirusFootsteps extends Stockton;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter28
         UseDirectionAs=PTDU_Normal
         MaxParticles=1
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         ColorScale(0)=(Color=(B=139,G=255,R=23))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=217,G=217))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000))
         LifetimeRange=(Min=6.000000,Max=6.000000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter28'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter30
         MaxParticles=1
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         ColorScale(0)=(Color=(B=148,G=255,R=40))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=215,G=215))
         StartSizeRange=(X=(Min=30.000000,Max=40.000000))
         LifetimeRange=(Min=6.000000,Max=6.000000)
         StartVelocityRange=(Z=(Min=5.000000,Max=10.000000))
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter30'
     LifeSpan=6.000000
     Tag="StocktonVirusFootsteps"
     bNoDelete=False
}
