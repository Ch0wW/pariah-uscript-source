Class VGAssaultExplosion extends Emitter;

#exec OBJ LOAD FILE=..\Sounds\PariahWeaponSounds.uax

simulated function PostBeginPlay()
{
	PlaySound(sound'PariahWeaponSounds.SmallExplosion',,,,,,, false);	
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter35
         MaxParticles=2
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         InitialParticlesPerSecond=250.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.James.ExploOrange'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         AutoResetTimeRange=(Min=0.500000,Max=0.500000)
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=30.000000,Max=40.000000))
         LifetimeRange=(Min=0.300000,Max=0.400000)
         StartVelocityRange=(Z=(Min=500.000000,Max=500.000000))
         VelocityLossRange=(Z=(Min=2.000000,Max=3.000000))
         DrawStyle=PTDS_Brighten
         GetVelocityDirectionFrom=PTVD_StartPositionAndOwner
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseRevolution=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter35'
     AutoDestroy=True
     DrawScale=0.200000
     RemoteRole=ROLE_SimulatedProxy
     bNoDelete=False
     bNetTemporary=True
}
