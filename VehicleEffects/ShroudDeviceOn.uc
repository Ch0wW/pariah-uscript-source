class ShroudDeviceOn extends Characters;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter66
         MaxParticles=15
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.700000)
         ColorScale(3)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.550000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.600000,RelativeSize=2.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Y=-80.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=170.000000,Max=200.000000),Z=(Min=-50.000000,Max=50.000000))
         StartSizeRange=(X=(Min=4.000000,Max=8.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Y=(Min=80.000000,Max=100.000000))
         StartVelocityRadialRange=(Min=-60.000000,Max=-60.000000)
         CoordinateSystem=PTCS_Relative
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter66'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter67
         MaxParticles=15
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.700000)
         ColorScale(3)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.550000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.600000,RelativeSize=2.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Y=-80.000000)
         StartLocationOffset=(Y=-75.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-170.000000,Max=-200.000000),Z=(Min=-50.000000,Max=50.000000))
         StartSizeRange=(X=(Min=4.000000,Max=8.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(Y=(Min=80.000000,Max=100.000000))
         StartVelocityRadialRange=(Min=-80.000000,Max=-80.000000)
         CoordinateSystem=PTCS_Relative
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter67'
     Tag="ShroudDeviceOn"
     bNoDelete=False
     bDirectional=True
}
