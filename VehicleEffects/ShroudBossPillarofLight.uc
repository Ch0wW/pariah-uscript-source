class ShroudBossPillarofLight extends Shroud
      placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter49
         MaxParticles=150
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flare'
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Acceleration=(Z=200.000000)
         StartLocationOffset=(Z=70.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SphereRadiusRange=(Min=60.000000,Max=80.000000)
         RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=40.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=-50.000000,Max=-50.000000))
         StartLocationShape=PTLS_Sphere
         UseColorScale=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter49'
     Begin Object Class=MeshEmitter Name=MeshEmitter6
         StaticMesh=StaticMesh'StocktonBossPrefabs.StocktonShield.StocktonShieldRing'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         MaxParticles=5
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         RelativeWarmupTime=1.000000
         Texture=None
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartLocationOffset=(Z=-25.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.400000,Max=0.400000))
         LifetimeRange=(Min=2.500000,Max=2.500000)
         StartVelocityRange=(Z=(Min=70.000000,Max=70.000000))
         UseColorScale=True
         SpinParticles=True
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter6'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter50
         MaxParticles=60
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flare'
         ColorScale(0)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeTime=0.300000,RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(Z=-100.000000)
         StartLocationOffset=(Z=800.000000)
         RevolutionsPerSecondRange=(Z=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=15.000000,Max=35.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter50'
     Begin Object Class=MeshEmitter Name=MeshEmitter7
         StaticMesh=StaticMesh'StocktonBossPrefabs.StocktonShield.StocktonShieldRing'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         MaxParticles=3
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=-50.000000)
         StartLocationOffset=(Z=720.000000)
         SpinsPerSecondRange=(Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
         LifetimeRange=(Min=1.200000,Max=1.200000)
         StartVelocityRange=(Z=(Min=-30.000000,Max=-30.000000))
         UseColorScale=True
         SpinParticles=True
     End Object
     Emitters(3)=MeshEmitter'VehicleEffects.MeshEmitter7'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter51
         MaxParticles=30
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flare'
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=-200.000000)
         StartLocationOffset=(Z=700.000000)
         StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000))
         SphereRadiusRange=(Min=70.000000,Max=80.000000)
         RevolutionsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=60.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(Z=(Min=100.000000,Max=-100.000000))
         UseColorScale=True
         UseRevolution=True
         UniformSize=True
     End Object
     Emitters(4)=SpriteEmitter'VehicleEffects.SpriteEmitter51'
     Begin Object Class=EmberEmitter Name=EmberEmitter3
         MaxParticles=200
         ColorScaleRepeats=2.000000
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flare'
         ColorScale(0)=(Color=(B=6,G=209,R=225))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         Acceleration=(Z=0.000000)
         StartLocationOffset=(Z=400.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=0.000000,Max=0.000000))
         SphereRadiusRange=(Min=300.000000,Max=300.000000)
         RevolutionsPerSecondRange=(Z=(Min=0.050000,Max=0.400000))
         StartSizeRange=(X=(Min=4.000000,Max=3.000000),Y=(Min=12.000000,Max=12.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         StartLocationShape=PTLS_Sphere
         FadeOut=False
         UseRevolution=True
         UseSizeScale=False
         UseRegularSizeScale=True
     End Object
     Emitters(5)=EmberEmitter'VehicleEffects.EmberEmitter3'
     Tag="ShroudBossPillarofLight"
     bNoDelete=False
}
