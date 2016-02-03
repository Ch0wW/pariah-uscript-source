class FlameTrail extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter395
         UseDirectionAs=PTDU_Up
         MaxParticles=60
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SubdivisionEnd=4
         FadeOutStartTime=0.600000
         FadeInEndTime=0.300000
         ParticlesPerSecond=70.000000
         InitialParticlesPerSecond=70.000000
         Texture=Texture'MynkiTextures.Effects.BrightYellowFlames'
         ColorScale(0)=(Color=(B=179))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=17,G=210,R=238))
         ColorScale(2)=(RelativeTime=0.700000,Color=(B=2,G=92,R=191))
         StartLocationRange=(X=(Max=750.000000),Y=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=50.000000,Max=60.000000),Y=(Max=200.000000),Z=(Min=25.000000,Max=30.000000))
         LifetimeRange=(Min=0.900000,Max=1.200000)
         StartVelocityRange=(Y=(Min=-10.000000,Max=10.000000),Z=(Min=200.000000,Max=300.000000))
         VelocityLossRange=(Z=(Min=1.000000,Max=2.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Brighten
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter395'
     LifeSpan=20.000000
     bNoDelete=False
}
