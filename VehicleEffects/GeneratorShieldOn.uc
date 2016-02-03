class GeneratorShieldOn extends Stockton;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter64
         StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.GeneratorShield'
         RenderTwoSided=True
         UseParticleColor=True
         MaxParticles=1
         SizeScaleRepeats=25.000000
         InitialParticlesPerSecond=1000000.000000
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(1)=(RelativeTime=0.250000)
         SizeScale(2)=(RelativeTime=0.260000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(4)=(RelativeTime=0.510000)
         SizeScale(5)=(RelativeTime=0.600000)
         SizeScale(6)=(RelativeTime=0.610000,RelativeSize=1.000000)
         SizeScale(7)=(RelativeTime=1.000000,RelativeSize=1.000000)
         LifetimeRange=(Min=1.000000,Max=1.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter64'
     Tag="StocktonShieldOn"
     bNoDelete=False
     bUnlit=False
}
