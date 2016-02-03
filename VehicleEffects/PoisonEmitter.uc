class PoisonEmitter extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter71
         MaxParticles=50
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         InitialParticlesPerSecond=10.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.green_smoke'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.050000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.990000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         Acceleration=(Z=10.000000)
         StartLocationOffset=(Z=50.000000)
         StartLocationRange=(Z=(Min=-20.000000,Max=20.000000))
         SphereRadiusRange=(Min=10.000000,Max=25.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         StartSizeRange=(X=(Min=180.000000,Max=200.000000))
         LifetimeRange=(Min=11.000000,Max=11.000000)
         StartVelocityRange=(X=(Min=-550.000000,Max=550.000000),Y=(Min=-550.000000,Max=550.000000),Z=(Min=-20.000000,Max=-25.000000))
         VelocityLossRange=(X=(Min=0.700000,Max=1.200000),Y=(Min=0.700000,Max=1.200000),Z=(Min=1.500000,Max=1.500000))
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter71'
     AutoDestroy=True
     LifeSpan=15.000000
     Tag="PoisonEmitter"
     bNoDelete=False
     bUnlit=False
}
