Class CigarSmoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter417
         MaxParticles=50
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=1.200000
         FadeInEndTime=0.500000
         ParticlesPerSecond=15.000000
         InitialParticlesPerSecond=15.000000
         SecondsBeforeInactive=0.000000
         OwnerBaseVelocityTransferAmount=1.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=11.000000)
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=3.000000)
         Acceleration=(Z=40.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(Y=(Min=-5.000000,Max=-6.000000))
         SphereRadiusRange=(Min=100.000000,Max=100.000000)
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=12.000000,Max=12.000000))
         LifetimeRange=(Min=2.500000,Max=2.800000)
         StartVelocityRange=(Z=(Min=30.000000,Max=30.000000))
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseRevolution=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter417'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
