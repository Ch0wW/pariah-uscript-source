class FragSpawn extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter414
         MaxParticles=20
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'VehicleGameTextures.Effects.DustCloud'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         AutoResetTimeRange=(Min=0.300000,Max=0.300000)
         StartLocationRange=(X=(Min=6.000000,Max=25.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
         SphereRadiusRange=(Min=5.000000,Max=5.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-1.000000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=3.500000,Max=5.000000),Z=(Min=3.500000,Max=5.000000))
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRadialRange=(Min=200.000000,Max=600.000000)
         VelocityLossRange=(X=(Min=5.000000,Max=7.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter414'
     bNoDelete=False
}
