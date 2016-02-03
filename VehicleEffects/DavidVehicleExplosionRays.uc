Class DavidVehicleExplosionRays extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         MaxParticles=2
         FadeOutStartTime=0.600000
         FadeInEndTime=0.400000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.explosion_rays'
         SizeScale(1)=(RelativeTime=0.600000,RelativeSize=6.000000)
         SizeScale(2)=(RelativeTime=0.900000,RelativeSize=8.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Min=-30.000000,Max=30.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_All
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter3'
     AutoDestroy=True
     bNoDelete=False
}
