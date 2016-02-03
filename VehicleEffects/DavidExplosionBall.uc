Class DavidExplosionBall extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter415
         MaxParticles=1
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SubdivisionEnd=3
         FadeOutStartTime=0.250000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.Explosion_ball'
         ColorScale(0)=(Color=(B=64,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=120,G=146,R=199))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=5.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=7.000000)
         LifetimeRange=(Min=0.500000,Max=0.500000)
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter415'
     bNoDelete=False
}
