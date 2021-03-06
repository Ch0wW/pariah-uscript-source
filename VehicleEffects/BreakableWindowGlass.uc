class BreakableWindowGlass extends Environmental;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter36
         ProjectionNormal=(X=1.000000,Y=1.000000,Z=0.000000)
         MaxParticles=60
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SubdivisionStart=4
         SubdivisionEnd=1
         FadeOutStartTime=2.000000
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'MannyTextures.Glass.glass_shards'
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(0)=(RelativeTime=1.000000)
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.300000,Max=0.600000),Y=(Min=0.300000,Max=0.600000),Z=(Min=0.300000,Max=0.400000))
         MaxCollisions=(Min=3.000000,Max=3.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-60.000000,Max=60.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=0.200000,Max=1.000000),Z=(Min=0.200000,Max=1.000000))
         StartSpinRange=(X=(Max=16384.000000))
         RotationNormal=(X=1.000000)
         StartSizeRange=(X=(Min=4.000000,Max=10.000000))
         LifetimeRange=(Min=2.500000,Max=3.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-50.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=0.400000,Max=0.400000),Y=(Max=0.100000),Z=(Max=0.400000))
         EffectAxis=PTEA_PositiveZ
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         FadeOut=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter36'
     Tag="BreakableWindowGlass"
     AmbientGlow=50
     bNoDelete=False
     bUnlit=False
}
