class GasBarrelInteriorGas extends Environmental;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter338
         MaxParticles=15
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.900000
         FadeInEndTime=0.100000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=30.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.green_smoke'
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-25.000000,Max=35.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         RevolutionsPerSecondRange=(Z=(Min=-0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=30.000000,Max=30.000000))
         LifetimeRange=(Min=15.000000,Max=15.000000)
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         AutoDestroy=True
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter338'
     Tag="GasBarrelInteriorGas"
     bNoDelete=False
     bUnlit=False
}
