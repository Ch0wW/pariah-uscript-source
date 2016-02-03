class ShroudBlade_Fire extends Shroud;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter89
         MaxParticles=40
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.200000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=15.000000
         Texture=Texture'PariahCharacterTextures.ShroudAssasin.Explo4x4orange'
         ColorScale(0)=(Color=(B=26,G=140,R=255,A=128))
         ColorScale(1)=(RelativeTime=2.000000,Color=(B=147,G=234,R=255,A=102))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=1.400000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=0.200000)
         SpinsPerSecondRange=(X=(Max=0.700000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         RotationDampingFactorRange=(X=(Min=50.000000,Max=50.000000))
         RevolutionsPerSecondRange=(X=(Max=2.000000),Y=(Max=0.200000),Z=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=4.500000,Max=5.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         LifetimeRange=(Min=1.500000,Max=1.700000)
         StartVelocityRange=(X=(Min=35.000000,Max=40.000000))
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Normal
         DrawStyle=PTDS_Brighten
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter89'
     Skins(0)=Texture'PariahWeaponEffectsTextures.Rocket.RocketFlareZ'
     bNoDelete=False
     bDirectional=True
}
