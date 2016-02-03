class StocktonShieldOff extends Stockton;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter58
         StaticMesh=StaticMesh'StocktonBossPrefabs.StocktonShield.StocktonShieldRing'
         UseParticleColor=True
         MaxParticles=5
         FadeOutStartTime=0.500000
         SizeScaleRepeats=5.000000
         InitialParticlesPerSecond=1.800000
         WarmupTicksPerSecond=30.000000
         RelativeWarmupTime=1.000000
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Y=(Min=0.200000,Max=0.200000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.910000,Max=0.930000),Y=(Min=0.910000,Max=0.930000),Z=(Min=2.000000,Max=2.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter58'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter340
         MaxParticles=1
         FadeOutStartTime=0.100000
         InitialParticlesPerSecond=1.000000
         WarmupTicksPerSecond=30.000000
         RelativeWarmupTime=1.000000
         Texture=Texture'StocktonBossTextures.StocktonShield.StocktonShieldRing2'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.010000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
         SphereRadiusRange=(Max=1.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=129.000000,Max=131.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter340'
     Tag="StocktonShieldOff"
     Skins(0)=Shader'StocktonBossTextures.StocktonShield.DNAstripShader'
     bNoDelete=False
     bAcceptsProjectors=False
}
