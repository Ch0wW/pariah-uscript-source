Class TitanFistEnergy extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         MaxParticles=33
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.200000
         FadeInEndTime=0.100000
         ParticlesPerSecond=22.000000
         InitialParticlesPerSecond=22.000000
         Texture=Texture'EmitterTextures.MultiFrame.Effect_D'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-1.000000,Max=0.100000))
         StartSizeRange=(X=(Min=3.500000,Max=5.000000),Y=(Min=3.500000,Max=5.000000),Z=(Min=3.500000,Max=5.000000))
         LifetimeRange=(Min=0.350000,Max=0.350000)
         StartVelocityRange=(X=(Min=150.000000,Max=250.000000))
         CoordinateSystem=PTCS_Relative
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter10'
     bNoDelete=False
}
