class C12GenExpl extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter56
         MaxParticles=12
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.400000
         FadeInEndTime=0.010000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'JamesTextures.Chapter12.EnergyPurple'
         ColorScale(0)=(Color=(B=45,G=109,R=140))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Y=2000.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=-400.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         SphereRadiusRange=(Min=20.000000,Max=20.000000)
         StartLocationPolarRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000),Z=(Min=25.000000,Max=50.000000))
         LifetimeRange=(Min=2.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=-5000.000000))
         StartVelocityRadialRange=(Min=-400.000000,Max=400.000000)
         VelocityLossRange=(X=(Min=2.000000,Max=3.000000))
         CoordinateSystem=PTCS_Relative
         EffectAxis=PTEA_PositiveZ
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter56'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter411
         MaxParticles=1
         InitialParticlesPerSecond=2100.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.Flash'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=211,R=243))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=9.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
         Acceleration=(Y=2000.000000)
         StartLocationRange=(X=(Min=450.000000,Max=450.000000),Z=(Min=350.000000,Max=350.000000))
         LifetimeRange=(Min=0.170000,Max=0.170000)
         StartVelocityRange=(X=(Min=4500.000000,Max=4500.000000))
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter411'
     Begin Object Class=MeshEmitter Name=MeshEmitter72
         StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.Vehicle_Explosion.Shrapnel'
         MaxParticles=90
         InitialParticlesPerSecond=3000.000000
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=-1500.000000)
         StartLocationRange=(X=(Min=100.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=3.000000),Y=(Min=0.100000,Max=3.000000),Z=(Min=0.100000,Max=3.000000))
         StartSizeRange=(X=(Min=0.400000,Max=2.000000))
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=500.000000,Max=5000.000000),Y=(Min=-1500.000000,Max=1500.000000),Z=(Min=-500.000000,Max=1000.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000))
         GetVelocityDirectionFrom=PTVD_GetFromOwnersBase
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(2)=MeshEmitter'VehicleEffects.MeshEmitter72'
     LifeSpan=7.500000
     Tag="Emitter"
     bNoDelete=False
}
