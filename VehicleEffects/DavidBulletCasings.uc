class DavidBulletCasings extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter73
         StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Puncher.BulletCasing'
         MaxParticles=30
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.500000
         Acceleration=(Z=-1000.000000)
         MaxCollisions=(Min=2.000000,Max=3.000000)
         StartLocationRange=(Z=(Min=-1.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=500.000000,Max=600.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Regular
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseMaxCollisions=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter73'
     AutoDestroy=True
     LifeSpan=5.000000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
     bDirectional=True
}
