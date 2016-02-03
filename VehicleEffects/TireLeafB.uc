Class TireLeafB extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter79
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Tire.single_leaf'
         UseParticleColor=True
         MaxParticles=20
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.700000
         Acceleration=(Z=-100.000000)
         StartLocationOffset=(Z=-45.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000),Y=(Min=0.100000,Max=1.000000),Z=(Min=0.100000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         StartSizeRange=(X=(Min=0.500000),Y=(Min=0.500000),Z=(Min=0.500000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=300.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=5.000000,Max=8.000000))
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         AutoReset=True
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter79'
     bNoDelete=False
}
