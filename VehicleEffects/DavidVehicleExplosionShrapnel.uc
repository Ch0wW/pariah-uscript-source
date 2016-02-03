Class DavidVehicleExplosionShrapnel extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         MaxParticles=50
         InitialParticlesPerSecond=400.000000
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=3.000000),Y=(Min=0.100000,Max=3.000000),Z=(Min=0.100000,Max=3.000000))
         StartSizeRange=(X=(Min=0.300000,Max=0.600000))
         LifetimeRange=(Min=1.800000,Max=2.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000,Max=1200.000000))
         VelocityLossRange=(X=(Min=0.300000,Max=0.800000),Y=(Min=0.300000,Max=0.800000),Z=(Min=0.300000,Max=0.800000))
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter1'
     AutoDestroy=True
     bNoDelete=False
}
