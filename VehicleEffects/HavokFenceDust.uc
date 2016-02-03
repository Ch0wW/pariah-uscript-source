class HavokFenceDust extends Environmental;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter75
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SubdivisionEnd=3
         InitialParticlesPerSecond=15.000000
         WarmupTicksPerSecond=30.000000
         RelativeWarmupTime=0.250000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.wter_mist1'
         ColorScale(0)=(Color=(B=58,G=81,R=112,A=255))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=116,G=134,R=152,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=58,G=81,R=112))
         SizeScale(0)=(RelativeTime=0.200000,RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         SubdivisionScale(0)=0.200000
         SubdivisionScale(1)=0.050000
         SubdivisionScale(2)=0.010000
         Acceleration=(Z=-100.000000)
         StartLocationRange=(Y=(Min=-200.000000,Max=200.000000))
         StartLocationPolarRange=(Y=(Max=65535.000000),Z=(Min=100.000000,Max=400.000000))
         RotationOffset=(Yaw=16384)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000))
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Max=-300.000000))
         StartVelocityRadialRange=(Min=100.000000,Max=100.000000)
         VelocityLossRange=(X=(Min=0.700000,Max=1.000000),Y=(Min=0.700000,Max=1.000000),Z=(Min=0.700000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_All
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter75'
     AutoDestroy=True
     Tag="HavokFenceDust"
     bNoDelete=False
     bUnlit=False
     bDirectional=True
}
