Class TurretCasings extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'PariahWeaponMeshes.bullet_shells.bullet_shell1'
         UseMeshBlendMode=False
         UseParticleColor=True
         MaxParticles=30
         ParticlesPerSecond=12.500000
         InitialParticlesPerSecond=12.500000
         OwnerBaseVelocityTransferAmount=0.500000
         Acceleration=(Z=-1400.000000)
         StartLocationRange=(Z=(Min=-1.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         StartSizeRange=(X=(Min=2.100000,Max=2.100000),Y=(Min=2.100000,Max=2.100000),Z=(Min=2.100000,Max=2.100000))
         LifetimeRange=(Min=1.600000,Max=1.700000)
         StartVelocityRange=(X=(Min=990.000000,Max=990.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=100.000000,Max=400.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Regular
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         FadeOut=True
         AutoDestroy=True
         SpinParticles=True
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter2'
     Tag="Emitter"
     bNoDelete=False
     bDirectional=True
}
