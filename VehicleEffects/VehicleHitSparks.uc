Class VehicleHitSparks extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter4
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         UseParticleColor=True
         MaxParticles=5
         InitialParticlesPerSecond=250.000000
         Acceleration=(Z=-1600.000000)
         DampingFactorRange=(X=(Min=0.600000,Max=0.700000),Y=(Min=0.600000,Max=0.700000),Z=(Min=0.400000,Max=0.500000))
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         SpinsPerSecondRange=(Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         StartSpinRange=(X=(Min=1.000000,Max=4.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=1.000000,Max=4.000000))
         RotationDampingFactorRange=(X=(Min=20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=0.010000,Max=0.400000),Y=(Min=0.360000,Max=0.360000),Z=(Min=0.800000,Max=0.900000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=200.000000,Max=750.000000))
         VelocityLossRange=(X=(Max=0.500000))
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter4'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         UseDirectionAs=PTDU_Right
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.weld_spark'
         ColorScale(0)=(RelativeTime=0.500000,Color=(B=94,G=139,R=234))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=-0.005000)
         Acceleration=(Z=-2800.000000)
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         SphereRadiusRange=(Min=20.000000,Max=20.000000)
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=12.000000,Max=18.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=800.000000),Y=(Min=-700.000000,Max=800.000000),Z=(Min=200.000000,Max=1200.000000))
         StartLocationShape=PTLS_Sphere
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter12'
     Tag="VehicleHitSparks"
     bNoDelete=False
     bUnlit=False
}
