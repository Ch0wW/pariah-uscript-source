Class HoverVehicleDirtDust extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter456
         MaxParticles=50
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=4.000000
         FadeInEndTime=0.200000
         ParticlesPerSecond=50.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.brown_smoke'
         SizeScale(0)=(RelativeTime=0.000001,RelativeSize=30.000000)
         SizeScale(1)=(RelativeTime=5.000000,RelativeSize=60.000000)
         Acceleration=(Z=-500.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=-120.000000,Max=120.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-10.000000,Max=-10.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.140000))
         StartSizeRange=(X=(Min=5.000000,Max=6.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=500.000000,Max=800.000000))
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter456'
     Tag="HoverVehicleDirtDust"
     bNoDelete=False
     bUnlit=False
}
