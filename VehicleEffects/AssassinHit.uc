class AssassinHit extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter93
         UseDirectionAs=PTDU_Right
         MaxParticles=20
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=500.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.new_bloodspray'
         ColorScale(0)=(RelativeTime=0.500000,Color=(B=94,G=139,R=234))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=4.000000)
         Acceleration=(Z=-20.000000)
         StartLocationRange=(X=(Max=10.000000))
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=8.000000,Max=12.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRange=(X=(Min=200.000000,Max=450.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=10.000000,Max=20.000000))
         VelocityLossRange=(Y=(Min=1.000000,Max=1.000000))
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter93'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter365
         MaxParticles=4
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=500.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.newblood_cloud'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=15.000000)
         Acceleration=(Z=-500.000000)
         StartLocationRange=(X=(Max=-10.000000))
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=2.000000,Max=4.000000))
         LifetimeRange=(Min=0.300000,Max=0.800000)
         StartVelocityRange=(X=(Min=70.000000,Max=110.000000),Z=(Min=100.000000,Max=100.000000))
         VelocityLossRange=(Z=(Min=12.000000,Max=12.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter365'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter281
         MaxParticles=20
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         InitialParticlesPerSecond=500.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.newblood_cloud2'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         SubdivisionScale(0)=50.000000
         SubdivisionScale(1)=0.500000
         StartSizeRange=(X=(Min=0.200000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-1200.000000,Max=1200.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         VelocityLossRange=(X=(Max=15.000000),Z=(Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseSubdivisionScale=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter281'
     AutoDestroy=True
     bNoDelete=False
}
