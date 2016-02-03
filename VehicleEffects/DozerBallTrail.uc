class DozerBallTrail extends Vehicles
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter368
         MaxParticles=500
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         InitialParticlesPerSecond=25.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.wter_mist1'
         ColorScale(0)=(Color=(B=198,G=199,R=204,A=150))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=148,G=148,R=148))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.150000,RelativeSize=0.600000)
         SizeScale(2)=(RelativeTime=1.000000)
         Acceleration=(Z=50.000000)
         StartAlphaRange=(Min=200.000000)
         RotationDampingFactorRange=(X=(Min=11.000000,Max=50.000000),Y=(Min=11.000000,Max=50.000000),Z=(Min=11.000000,Max=50.000000))
         RevolutionsPerSecondRange=(X=(Min=-0.050000,Max=0.050000),Y=(Min=-0.050000,Max=0.050000),Z=(Min=-0.050000,Max=0.050000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=5.000000))
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter368'
     AutoDestroy=True
     Tag="DozerBallTrail"
     bNoDelete=False
     bAcceptsProjectors=False
     bUnlit=False
     bDirectional=True
}
