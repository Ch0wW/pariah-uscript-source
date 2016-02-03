Class Steam extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SteamSpriteEmitter16
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.800000
         FadeInEndTime=0.200000
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=100.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=150.000000,Max=160.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SteamSpriteEmitter16'
     bNoDelete=False
}
