class DavidBossShield extends David;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=DavidBossShieldEmitter
         StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.ShieldHitPlane'
         UseParticleColor=True
         MaxParticles=5
         AddVelocityFromOtherEmitter=0
         ColorScaleRepeats=30.000000
         SizeScaleRepeats=30.000000
         ParticlesPerSecond=3.000000
         InitialParticlesPerSecond=3.000000
         ColorScale(0)=(Color=(B=128,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         SizeScale(0)=(RelativeSize=1.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationOffset=(X=50.000000)
         StartLocationRange=(X=(Min=50.000000,Max=50.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         RotationNormal=(X=1.000000)
         RevolutionsPerSecondRange=(Y=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=300.000000,Max=300.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         FadeOut=True
         ResetAfterChange=True
         AutoDestroy=True
         AutoReset=True
         SpinParticles=True
         DampRotation=True
         UseRevolution=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.DavidBossShieldEmitter'
     Skins(0)=Shader'StocktonBossTextures.StocktonShield.WateryShader'
     bNoDelete=False
     bDirectional=True
}
