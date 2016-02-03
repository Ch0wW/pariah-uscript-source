Class DavidVehicleExplosionDirt extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter373
         FadeOutStartTime=1.000000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=3.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.Explosion_Dirt'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=-300.000000)
         SphereRadiusRange=(Max=50.000000)
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=200.000000,Max=250.000000))
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter373'
     AutoDestroy=True
     Tag="Emitter"
     bNoDelete=False
}
