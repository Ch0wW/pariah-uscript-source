Class AssaultShells extends DavidVehicleExplosionDirt;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter70
         StaticMesh=StaticMesh'PariahWeaponMeshes.bullet_shells.bullet_shell1'
         UseParticleColor=True
         MaxParticles=7
         FadeOutStartTime=0.300000
         ParticlesPerSecond=7.000000
         InitialParticlesPerSecond=7.000000
         Acceleration=(Z=-2000.000000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.400000,Max=0.500000))
         MaxCollisions=(Min=4.000000,Max=4.000000)
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RotationDampingFactorRange=(X=(Max=0.000010),Z=(Max=0.100000))
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=1.200000),Z=(Min=0.800000,Max=1.200000))
         LifetimeRange=(Min=0.700000,Max=0.700000)
         StartVelocityRange=(X=(Min=100.000000,Max=200.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=500.000000,Max=500.000000))
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Min=0.700000,Max=1.000000))
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter70'
     Tag="DavidVehicleExplosionDirt"
     bUnlit=False
}
