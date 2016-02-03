Class ShipDamageSmoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         MaxParticles=130
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=1.000000
         FadeInEndTime=0.200000
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=14.000000
         Texture=Texture'EmitterTextures2.Smokes.smoke_mt'
         StartAlphaRange=(Min=110.000000,Max=150.000000)
         StartLocationRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         SpinCCWorCW=(X=0.040000,Y=0.040000,Z=0.040000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=90.000000,Max=135.000000),Y=(Min=90.000000,Max=125.000000),Z=(Min=97.000000,Max=125.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         DrawStyle=PTDS_Darken
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter5'
     LifeSpan=20.000000
     DrawScale=8.000000
     Tag="Emitter"
     bNoDelete=False
}
