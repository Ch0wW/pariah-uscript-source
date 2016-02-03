Class shipthrusterback_distortion extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         MaxParticles=3
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-0.500000
         ParticlesPerSecond=6.000000
         InitialParticlesPerSecond=300.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.shimmer2'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-200.000000,Max=-200.000000),Z=(Min=-150.000000,Max=-150.000000))
         SphereRadiusRange=(Min=150.000000,Max=150.000000)
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=10.000000,Max=10.000000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-800.000000,Max=-1000.000000),Z=(Min=-700.000000,Max=-800.000000))
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_Brighten
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter7'
     PostEffectsType=PTFT_Distortion
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
