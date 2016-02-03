Class CaboomDistort extends Vehicles;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter369
         MaxParticles=2
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=-7.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.ExploOrange'
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=11.000000)
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=3.000000)
         Acceleration=(Z=450.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(Z=(Min=50.000000,Max=50.000000))
         SphereRadiusRange=(Min=150.000000,Max=150.000000)
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=20.000000,Max=35.000000))
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=300.000000,Max=300.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter369'
     PostEffectsType=PTFT_Distortion
     AutoDestroy=True
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
