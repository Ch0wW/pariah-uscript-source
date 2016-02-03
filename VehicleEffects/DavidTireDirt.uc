class DavidTireDirt extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter80
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Tire.RockLump'
         UseParticleColor=True
         FadeOutStartTime=0.500000
         ParticlesPerSecond=10.000000
         OwnerBaseVelocityTransferAmount=0.700000
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=0.800000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=-1400.000000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.700000),Y=(Min=0.400000,Max=0.700000),Z=(Min=0.400000,Max=0.700000))
         MaxCollisions=(Min=3.000000,Max=3.000000)
         StartLocationOffset=(Z=-45.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000),Y=(Min=0.100000,Max=1.000000),Z=(Min=0.100000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         StartSizeRange=(X=(Min=0.500000,Max=0.800000),Y=(Min=0.500000,Max=0.800000),Z=(Min=0.500000,Max=0.800000))
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=200.000000,Max=600.000000))
         StartLocationShape=PTLS_All
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseCollision=True
         UseMaxCollisions=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter80'
     bNoDelete=False
     bUnlit=False
}
