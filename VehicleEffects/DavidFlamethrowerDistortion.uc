class DavidFlamethrowerDistortion extends AltMuzzleFlash;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter455
         MaxParticles=5
         Texture=Texture'DavidTextures.HeatDistortion.FlameDistortionMips'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.400000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationOffset=(X=70.000000)
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=1200.000000,Max=1500.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter455'
     PostEffectsType=PTFT_Distortion
     Tag="DavidFlamethrowerDistortion"
     bNoDelete=False
     bDirectional=True
}
