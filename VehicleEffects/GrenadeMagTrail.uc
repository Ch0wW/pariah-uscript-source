Class GrenadeMagTrail extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter451
         MaxParticles=90
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         ParticlesPerSecond=60.000000
         InitialParticlesPerSecond=90.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=400.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-1.000000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=3.500000,Max=5.000000),Z=(Min=3.500000,Max=5.000000))
         LifetimeRange=(Min=1.300000,Max=1.600000)
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter451'
     LifeSpan=8.000000
     Physics=PHYS_Trailer
     bNoDelete=False
}
