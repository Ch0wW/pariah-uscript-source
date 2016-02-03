Class GrenadeMuzzFlash extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter18
         MaxParticles=12
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.300000
         FadeInEndTime=0.200000
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.explosions.Explo4x4Blue'
         ColorScale(0)=(Color=(B=80,G=209,R=181))
         ColorScale(1)=(RelativeTime=5.000000,Color=(B=94,G=247,R=242))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         Acceleration=(Z=40.000000)
         StartLocationRange=(X=(Max=50.000000),Y=(Min=-10.000000,Max=10.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartLocationPolarRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000),Y=(Min=-0.400000,Max=0.400000),Z=(Min=-0.400000,Max=0.400000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=5.000000,Max=10.000000),Z=(Min=5.000000,Max=10.000000))
         LifetimeRange=(Min=0.500000,Max=0.100000)
         StartVelocityRange=(X=(Min=10.000000,Max=200.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         StartVelocityRadialRange=(Min=-150.000000,Max=150.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         EffectAxis=PTEA_PositiveZ
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter18'
     AutoDestroy=True
     Tag="GrenadeMuzzExplosion"
     bNoDelete=False
}
