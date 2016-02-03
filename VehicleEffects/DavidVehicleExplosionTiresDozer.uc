class DavidVehicleExplosionTiresDozer extends Vehicles;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter68
         StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerTire'
         MaxParticles=4
         InitialParticlesPerSecond=100.000000
         Acceleration=(Z=-2000.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.300000),Y=(Min=0.700000,Max=0.300000),Z=(Min=0.700000,Max=0.300000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=2.000000),Y=(Min=-1.000000,Max=2.000000),Z=(Min=-1.000000,Max=2.000000))
         RotationDampingFactorRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Max=0.100000))
         StartSizeRange=(X=(Min=0.800000,Max=1.200000),Y=(Min=0.800000,Max=1.200000),Z=(Min=0.800000,Max=1.200000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=1300.000000,Max=2500.000000))
         VelocityLossRange=(X=(Max=0.100000),Y=(Max=0.100000),Z=(Min=0.700000,Max=1.000000))
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=MeshEmitter'VehicleEffects.MeshEmitter68'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter358
         MaxParticles=100
         AddLocationFromOtherEmitter=0
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.200000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=5.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.explosion_smoke_soft'
         ColorScale(0)=(Color=(B=121,G=222,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=1,G=1,R=1,A=100))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=200,G=200,R=200,A=50))
         SizeScale(0)=(RelativeSize=0.950000)
         SizeScale(1)=(RelativeTime=0.900000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.900000)
         LifetimeRange=(Min=2.000000,Max=2.000000)
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter358'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter359
         MaxParticles=50
         AddLocationFromOtherEmitter=0
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.100000
         InitialParticlesPerSecond=4.000000
         Texture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.Explosion_Flame'
         ColorScale(0)=(Color=(B=252,G=237,R=199,A=255))
         ColorScale(1)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=0.300000)
         LifetimeRange=(Min=1.000000,Max=1.000000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter359'
     AutoDestroy=True
     Tag="Emitter"
     Skins(0)=Texture'PariahVehicleTextures.Tire.DozerTireColour'
     bNoDelete=False
     bUnlit=False
}
