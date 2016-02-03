Class DropshipTurretSlowShot extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter406
         MaxParticles=40
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=1.000000
         FadeInEndTime=0.050000
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=2.000000
         Texture=Texture'PariahWeaponEffectsTextures.Rocket.blue_flame'
         ColorScale(0)=(Color=(B=221,G=244,R=255,A=2))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=34,G=157,R=249,A=128))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=36,G=124,R=244,A=255))
         SizeScale(0)=(RelativeSize=1.700000)
         SizeScale(1)=(RelativeTime=0.800000,RelativeSize=1.400000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.300000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=15.000000,Max=25.000000),Y=(Min=15.000000,Max=25.000000),Z=(Min=15.000000,Max=20.000000))
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=-200.000000,Max=-325.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter406'
     Tag="ParticleRocketTrailFlameSmall"
     Skins(0)=Texture'PariahWeaponEffectsTextures.Rocket.blue_flare'
     Physics=PHYS_Trailer
     bNoDelete=False
     bTrailerSameRotation=True
     bDirectional=True
}
