class GeneratorShield extends Stockton;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter8
         StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.GeneratorShield'
         RenderTwoSided=True
         MaxParticles=1
         SizeScaleRepeats=25.000000
         InitialParticlesPerSecond=1000000.000000
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Normal
         UseColorScale=True
         ResetAfterChange=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter8'
     Tag="GeneratorShield"
     bNoDelete=False
     bDirectional=True
}
