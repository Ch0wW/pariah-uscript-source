class StocktonShield extends Stockton;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter57
         StaticMesh=StaticMesh'StocktonBossPrefabs.StocktonShield.StocktonShieldRing'
         RenderTwoSided=True
         UseParticleColor=True
         MaxParticles=5
         FadeOutStartTime=0.700000
         FadeInEndTime=0.100000
         SizeScaleRepeats=45.000000
         ParticlesPerSecond=1.800000
         InitialParticlesPerSecond=1.800000
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(Y=(Min=0.200000,Max=0.200000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.910000,Max=0.930000),Y=(Min=0.910000,Max=0.930000),Z=(Min=2.000000,Max=2.000000))
         LifetimeRange=(Min=90.000000,Max=90.000000)
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter57'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter316
         MaxParticles=1
         FadeInEndTime=0.300000
         InitialParticlesPerSecond=5000.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=1.000000
         Texture=Texture'StocktonBossTextures.StocktonShield.StocktonShieldRing2'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.010000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
         SphereRadiusRange=(Max=1.000000)
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=129.000000,Max=131.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         UseColorScale=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter316'
     Tag="StocktonShield"
     Skins(0)=Shader'StocktonBossTextures.StocktonShield.DNAstripShader'
     bNoDelete=False
     bAcceptsProjectors=False
}
