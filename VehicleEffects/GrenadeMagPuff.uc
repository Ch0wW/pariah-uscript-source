class GrenadeMagPuff extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter416
         MaxParticles=7
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.300000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahVehicleWeaponTextures.Puncher.DirtDust'
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.010000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=-200.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=10.000000,Max=20.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=18.000000,Max=20.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=100.000000,Max=900.000000))
         VelocityLossRange=(Z=(Min=3.000000,Max=4.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter416'
     LifeSpan=1.500000
     Tag="Emitter"
     bNoDelete=False
}
