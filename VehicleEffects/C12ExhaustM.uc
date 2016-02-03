class C12ExhaustM extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter401
         MaxParticles=50
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=0.700000
         ParticlesPerSecond=80.000000
         InitialParticlesPerSecond=80.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'MannyTextures.Coronas.sun_corona3'
         ColorScale(0)=(Color=(B=128,G=204,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=253,G=141,R=132))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=206,G=11,R=26))
         SizeScale(0)=(RelativeSize=7.000000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=15.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=9.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         SpinCCWorCW=(Y=-0.500000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         RevolutionCenterOffsetRange=(X=(Min=5.000000,Max=5.000000))
         RevolutionsPerSecondRange=(Z=(Max=0.070000))
         StartSizeRange=(X=(Min=7.000000,Max=15.000000),Y=(Min=300.000000,Max=400.000000),Z=(Min=300.000000,Max=400.000000))
         LifetimeRange=(Min=0.300000,Max=0.300000)
         UseRotationFrom=PTRS_Normal
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter401'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter31
         MaxParticles=200
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         ParticlesPerSecond=60.000000
         InitialParticlesPerSecond=60.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         ColorScale(0)=(Color=(B=5,G=106,R=134))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=205,G=225,R=255))
         SizeScale(1)=(RelativeTime=0.080000)
         SizeScale(2)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(Y=1200.000000)
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000))
         StartSizeRange=(X=(Min=200.000000,Max=300.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         DrawStyle=PTDS_Brighten
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter31'
     Physics=PHYS_Trailer
     bNoDelete=False
}
