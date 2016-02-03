Class GlassShatterB extends ChassisSparks;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter290
         MaxParticles=155
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.300000
         Texture=Texture'MannyTextures.Glass.glass_shards'
         StartSizeRange=(X=(Min=3.000000,Max=6.000000),Y=(Min=7.000000,Max=20.000000),Z=(Min=0.000000,Max=0.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter290'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter291
         ProjectionNormal=(Z=0.000000)
         UseDirectionAs=PTDU_Scale
         SpawnFromOtherEmitter=0
         SpawnAmount=1
         MaxParticles=95
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'MannyTextures.Glass.glass_shards'
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=-0.050000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         SubdivisionScale(0)=2.000000
         SubdivisionScale(1)=1.000000
         Acceleration=(Z=-900.000000)
         ExtentMultiplier=(X=0.200000,Y=0.200000,Z=0.200000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.300000,Max=0.400000))
         MaxCollisions=(Min=3.000000,Max=3.000000)
         StartLocationRange=(X=(Min=-150.000000,Max=150.000000),Z=(Min=-90.000000,Max=90.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=8.000000,Max=12.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=50.000000,Max=150.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         UseCollision=True
         UseMaxCollisions=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter291'
}
