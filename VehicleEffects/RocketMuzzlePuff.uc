Class RocketMuzzlePuff extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter86
         MaxParticles=32
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=-1.000000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=730.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         SizeScale(0)=(RelativeTime=0.050000,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(X=20.000000,Y=9.000000,Z=200.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=30.000000,Max=160.000000),Z=(Min=-20.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=6.500000,Max=10.500000))
         LifetimeRange=(Min=1.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=-200.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-250.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=3.000000),Y=(Max=4.000000),Z=(Min=2.000000,Max=15.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter86'
     AutoDestroy=True
     DrawScale=0.200000
     Tag="Emitter"
     RemoteRole=ROLE_DumbProxy
     bNoDelete=False
     bNetInitialRotation=True
     bUnlit=False
}
