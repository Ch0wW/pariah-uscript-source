class DavidBossShieldHit extends David;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter5
         StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.ShieldHitPlane'
         UseParticleColor=True
         MaxParticles=5
         AddVelocityFromOtherEmitter=0
         FadeOutStartTime=0.400000
         SizeScaleRepeats=30.000000
         InitialParticlesPerSecond=20.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=0.500000
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationOffset=(X=50.000000)
         StartLocationRange=(X=(Min=50.000000,Max=50.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         RotationNormal=(X=1.000000)
         RevolutionsPerSecondRange=(Z=(Min=1.300000,Max=1.300000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=400.000000,Max=400.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         CoordinateSystem=PTCS_Relative
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         AutoReset=True
         SpinParticles=True
         DampRotation=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter5'
     LifeSpan=0.500000
     Tag="DavidBossShieldHit"
     bNoDelete=False
     bDirectional=True
}
