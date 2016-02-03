class MercHelmetShatter extends ChassisSparks;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter321
         ProjectionNormal=(Z=0.000000)
         UseDirectionAs=PTDU_Scale
         SpawnFromOtherEmitter=0
         MaxParticles=40
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'MannyTextures.Glass.glass_shards_black'
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=-0.090000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         SubdivisionScale(0)=2.000000
         SubdivisionScale(1)=1.000000
         Acceleration=(Z=-1000.000000)
         ExtentMultiplier=(X=0.200000,Y=0.200000,Z=0.200000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.300000,Max=0.400000))
         MaxCollisions=(Min=3.000000,Max=3.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=5.000000,Max=6.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Max=200.000000),Y=(Min=-60.000000,Max=100.000000),Z=(Min=220.000000,Max=320.000000))
         DrawStyle=PTDS_AlphaBlend
         UseCollision=True
         UseMaxCollisions=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter321'
     DrawScale=0.400000
     Tag="shatterglass"
}
