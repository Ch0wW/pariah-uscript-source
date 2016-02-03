Class shipthrusterback_flame extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         SecondsBeforeInactive=0.000000
         OwnerBaseVelocityTransferAmount=1.000000
         Texture=Texture'MannyTextures.Coronas.sun_corona3'
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=11.000000)
         SizeScale(1)=(RelativeTime=3.000000,RelativeSize=3.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
         SphereRadiusRange=(Min=100.000000,Max=100.000000)
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRange=(X=(Min=-800.000000,Max=-1000.000000),Z=(Min=-800.000000,Max=-1000.000000))
         UseRotationFrom=PTRS_Normal
         FadeOut=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter8'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
