class MilShipBottomThrust extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter32
         MaxParticles=9
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=0.700000
         ParticlesPerSecond=8.000000
         InitialParticlesPerSecond=8.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'MannyTextures.Coronas.sun_corona3'
         ColorScale(0)=(Color=(B=128,G=204,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=253,G=141,R=132))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=206,G=11,R=26))
         SizeScale(0)=(RelativeSize=7.000000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=15.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=9.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=150.000000,Max=300.000000))
         SphereRadiusRange=(Min=150.000000,Max=150.000000)
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=25.000000,Max=30.000000),Y=(Min=300.000000,Max=400.000000),Z=(Min=300.000000,Max=400.000000))
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(Z=(Min=-2200.000000,Max=-2000.000000))
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Normal
         UseColorScale=True
         FadeOut=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter32'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
     bDirectional=True
}
