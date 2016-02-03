Class DavidDamagePieceShrapnel extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter75
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         InitialParticlesPerSecond=400.000000
         OwnerBaseVelocityTransferAmount=0.300000
         Acceleration=(Z=-500.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=3.000000),Y=(Min=0.100000,Max=3.000000),Z=(Min=0.100000,Max=3.000000))
         StartSizeRange=(X=(Min=0.100000,Max=0.300000))
         LifetimeRange=(Min=1.800000,Max=2.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=200.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=0.100000,Max=0.400000),Y=(Min=0.100000,Max=0.400000),Z=(Min=0.100000,Max=0.400000))
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter75'
     bNoDelete=False
}
