Class MannyWaterRings extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter43
         UseDirectionAs=PTDU_Normal
         MaxParticles=4
         FadeOutStartTime=-3.000000
         FadeInEndTime=0.500000
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=5.000000
         Texture=Texture'MannyTextures.water.water_ring'
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=3.000000)
         StartLocationRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-5.000000,Max=8.000000),Z=(Min=-10.000000))
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSizeRange=(X=(Min=68.000000,Max=80.000000))
         LifetimeRange=(Min=0.700000,Max=1.300000)
         StartVelocityRange=(Y=(Min=20.000000,Max=30.000000))
         DrawStyle=PTDS_Brighten
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter43'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
     bDirectional=True
}
