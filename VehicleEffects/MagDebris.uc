class MagDebris extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter469
         MaxParticles=30
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeInEndTime=0.100000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.bullet_slug'
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.800000)
         Acceleration=(Z=500.000000)
         StartColorRange=(X=(Min=200.000000),Y=(Min=200.000000),Z=(Min=200.000000))
         StartLocationOffset=(Z=-700.000000)
         SphereRadiusRange=(Min=300.000000,Max=300.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=1.000000,Max=9.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRadialRange=(Min=-700.000000,Max=-700.000000)
         AddVelocityMultiplierRange=(X=(Min=0.000000,Max=0.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_Regular
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeIn=True
         AutoReset=True
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter469'
     LifeSpan=6.000000
     Tag="Emitter"
     Physics=PHYS_Trailer
     bNoDelete=False
}
