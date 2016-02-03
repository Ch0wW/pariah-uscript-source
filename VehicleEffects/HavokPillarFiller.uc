Class HavokPillarFiller extends Destructable;

// Created by DavidPayne

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter63
         StaticMesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.MeshConcreteMedium'
         MaxParticles=5
         InitialParticlesPerSecond=1000.000000
         Acceleration=(Z=-1000.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
         MaxCollisions=(Min=2.000000,Max=3.000000)
         CollisionSoundProbability=(Max=1.000000)
         StartLocationOffset=(X=75.000000)
         StartLocationRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=-100.000000,Max=100.000000))
         StartMassRange=(Min=100.000000,Max=150.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         StartSizeRange=(X=(Min=0.800000,Max=1.200000),Y=(Min=0.800000,Max=1.200000),Z=(Min=0.800000,Max=1.200000))
         VelocityLossRange=(X=(Min=0.200000,Max=0.600000),Y=(Min=0.200000,Max=0.600000),Z=(Min=0.200000,Max=0.600000))
         UseRotationFrom=PTRS_Actor
         UseCollision=True
         UseMaxCollisions=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter63'
     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.MeshConcreteSmall'
         MaxParticles=15
         InitialParticlesPerSecond=1000.000000
         Acceleration=(Z=-1000.000000)
         DampingFactorRange=(X=(Min=0.300000,Max=0.500000),Y=(Min=0.300000,Max=0.500000),Z=(Min=0.300000,Max=0.500000))
         MaxCollisions=(Min=2.000000,Max=3.000000)
         StartLocationOffset=(X=25.000000)
         StartLocationRange=(X=(Min=25.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-100.000000,Max=100.000000))
         SpinsPerSecondRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         RotationDampingFactorRange=(X=(Min=0.100000,Max=1.000000),Y=(Min=0.100000,Max=1.000000),Z=(Min=0.100000,Max=1.000000))
         StartSizeRange=(X=(Max=2.000000),Y=(Max=2.000000),Z=(Max=2.000000))
         VelocityLossRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         UseRotationFrom=PTRS_Actor
         UseCollision=True
         UseMaxCollisions=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseRevolution=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter3'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter410
         MaxParticles=60
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SubdivisionEnd=16
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         ColorScale(0)=(Color=(B=172,G=187,R=193,A=250))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=172,G=187,R=193,A=250))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=226,G=233,R=235))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(X=5.000000,Z=-10.000000)
         StartLocationRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=-150.000000,Max=150.000000))
         SpinsPerSecondRange=(X=(Min=-0.120000,Max=0.100000))
         LifetimeRange=(Min=1.000000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter410'
     Tag="HavokPillarFiller"
     bNoDelete=False
}
