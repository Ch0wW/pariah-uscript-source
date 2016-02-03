Class FragRiffleMuzzleFlash extends AltMuzzleFlash;

function Destroyed()
{
//	log("*** The End Comes... ***");
	Super.Destroyed();
}

function StartFlash()
{
}

function StopFlash()
{
}

defaultproperties
{
     numEmitters=3
     bOnceOnly=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitter397
         MaxParticles=4
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-1.800000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.circle_flashyellow'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=30.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSpinRange=(X=(Max=10.000000),Y=(Max=10.000000))
         StartSizeRange=(X=(Min=3.500000,Max=6.000000))
         LifetimeRange=(Min=0.050000,Max=0.050000)
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter397'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter45
         MaxParticles=12
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-0.200000
         InitialParticlesPerSecond=230.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.bullet_slug_glowing'
         Acceleration=(Z=-200.000000)
         StartLocationRange=(Z=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=1.100000,Max=2.000000))
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=500.000000,Max=1000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-50.000000,Max=100.000000))
         CoordinateSystem=PTCS_Relative
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter45'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
