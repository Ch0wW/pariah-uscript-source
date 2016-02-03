class FlakMuzSparks extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter394
         MaxParticles=26
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=0.300000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahWeaponEffectsTextures.FragRifle.FragFlak'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=140,G=140,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(Z=-190.000000)
         StartLocationRange=(X=(Max=20.000000))
         SphereRadiusRange=(Min=-2.000000,Max=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=29.000000,Max=45.000000),Y=(Min=20.000000,Max=50.000000),Z=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
         StartVelocityRange=(X=(Min=200.000000,Max=1900.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Min=4.000000,Max=5.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRevolution=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter394'
     DrawScale=0.100000
     bNoDelete=False
}
