class C12BigExpl extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter344
         MaxParticles=1
         InitialParticlesPerSecond=2100.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.Flash'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=211,R=243))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=9.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
         Acceleration=(Y=2000.000000)
         StartLocationRange=(Z=(Min=350.000000,Max=350.000000))
         LifetimeRange=(Min=0.170000,Max=0.170000)
         StartVelocityRange=(X=(Min=10500.000000,Max=12000.000000))
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter344'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter23
         MaxParticles=7
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.810000
         FadeInEndTime=0.050000
         InitialParticlesPerSecond=2000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.explo4x4'
         ColorScale(0)=(Color=(B=45,G=109,R=140))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
         SizeScale(0)=(RelativeSize=16.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Y=2000.000000)
         StartLocationRange=(X=(Min=-600.000000,Max=600.000000),Y=(Min=-600.000000,Max=600.000000),Z=(Min=-600.000000,Max=600.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         StartLocationPolarRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000),Y=(Min=-0.100000,Max=0.100000),Z=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=37.000000,Max=60.000000),Y=(Min=37.000000,Max=60.000000),Z=(Min=37.000000,Max=65.000000))
         LifetimeRange=(Min=6.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         StartVelocityRadialRange=(Min=-190.000000,Max=190.000000)
         EffectAxis=PTEA_PositiveZ
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter23'
     LifeSpan=7.500000
     Tag="Emitter"
     bNoDelete=False
}
