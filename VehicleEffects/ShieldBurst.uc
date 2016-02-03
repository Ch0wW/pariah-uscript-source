Class ShieldBurst extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         MaxParticles=7
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=5.000000
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EmitterTextures2.Smokes.smoke_mt'
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=101.000000))
         SpinCCWorCW=(X=0.040000,Y=0.040000,Z=0.040000)
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000),Y=(Min=-0.050000,Max=0.050000))
         StartSizeRange=(X=(Min=320.000000,Max=700.000000),Y=(Min=320.000000,Max=600.000000))
         LifetimeRange=(Min=9.000000,Max=13.000000)
         StartVelocityRange=(Z=(Max=100.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter14'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter470
         MaxParticles=3
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahVehicleWeaponTextures.Puncher.DirtDust'
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=20.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=30.000000)
         StartLocationRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter470'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter471
         MaxParticles=1
         InitialParticlesPerSecond=2100.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.FlashRound'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=255,G=211,R=243))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=9.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=50.000000)
         StartSizeRange=(X=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=0.170000,Max=0.170000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter471'
     LifeSpan=8.000000
     Tag="Emitter"
     bNoDelete=False
}
