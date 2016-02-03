Class ShroudPlasmaGunMuzzleFlash extends AltMuzzleFlash;

defaultproperties
{
     numEmitters=2
     bOnceOnly=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         MaxParticles=1
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         InitialParticlesPerSecond=230.000000
         Texture=Texture'PariahWeaponEffectsTextures.PulseRifle.shroud_muzzleb'
         SizeScale(0)=(RelativeTime=0.100000,RelativeSize=30.000000)
         SizeScale(1)=(RelativeTime=0.570000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=1.500000,Max=2.000000))
         LifetimeRange=(Min=0.300000,Max=0.300000)
         DrawStyle=PTDS_Brighten
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter20'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter336
         MaxParticles=35
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         InitialParticlesPerSecond=900.000000
         Texture=Texture'PariahWeaponEffectsTextures.PulseRifle.shroudrifle_smoke'
         ColorScale(0)=(Color=(G=152,R=234))
         ColorScale(1)=(RelativeTime=5.000000,Color=(B=253,G=254,R=255))
         SizeScale(0)=(RelativeTime=0.050000,RelativeSize=6.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.000000)
         Acceleration=(X=200.000000,Y=9.000000,Z=100.000000)
         AutoResetTimeRange=(Min=0.500000,Max=0.500000)
         StartLocationRange=(X=(Min=80.000000,Max=-15.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=1.800000,Max=2.700000))
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=100.000000,Max=200.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Max=4.000000),Z=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter336'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
