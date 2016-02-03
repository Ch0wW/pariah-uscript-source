class shipthruster_dirteffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         MaxParticles=30
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.500000
         FadeInEndTime=2.000000
         ParticlesPerSecond=15.000000
         InitialParticlesPerSecond=25.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.brown_smoke'
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=25.000000)
         Acceleration=(Z=-500.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=20.000000,Max=20.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         StartSizeRange=(X=(Min=8.000000,Max=9.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=500.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=2.000000,Max=10.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter21'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
