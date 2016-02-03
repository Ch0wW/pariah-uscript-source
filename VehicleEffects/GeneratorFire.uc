class GeneratorFire Extends Stockton;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter40
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.800000
         FadeInEndTime=0.200000
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=5.000000
         Texture=Texture'MynkiTextures.Effects.BrightYellowFlames'
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=53,G=133,R=191))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=5.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartLocationRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         SpinsPerSecondRange=(X=(Min=-0.250000,Max=0.250000))
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=60.000000,Max=60.000000),Z=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=0.500000,Max=5.000000),Z=(Min=35.000000,Max=250.000000))
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter40'
     DrawScale=15.000000
     Tag="Fire!"
     bNoDelete=False
}
