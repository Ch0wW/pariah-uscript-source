class DavidBossShieldHitArea extends David;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter76
         StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.ShieldHitPlane'
         UseParticleColor=True
         MaxParticles=30
         AddVelocityFromOtherEmitter=0
         FadeOutStartTime=2.000000
         SizeScaleRepeats=30.000000
         InitialParticlesPerSecond=1.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=1.000000
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationOffset=(X=50.000000)
         SphereRadiusRange=(Min=100.000000,Max=100.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         RotationNormal=(X=1.000000)
         RevolutionsPerSecondRange=(Z=(Min=-1.300000,Max=1.300000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter76'
     Tag="DavidBossShieldHitArea"
     Skins(0)=Shader'StocktonBossTextures.StocktonShield.WateryShader'
     bNoDelete=False
     bDirectional=True
}
