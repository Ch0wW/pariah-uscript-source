class AssassinShockwave extends Shroud
	placeable;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter55
         UseDirectionAs=PTDU_Forward
         MaxParticles=300
         InitialParticlesPerSecond=50000.000000
         WarmupTicksPerSecond=60.000000
         RelativeWarmupTime=1.000000
         Texture=Texture'PariahWeaponEffectsTextures.SWIG.blue_corona3'
         ColorScale(0)=(Color=(G=255))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         MaxCollisions=(Min=1.000000,Max=1.000000)
         StartLocationOffset=(Z=-50.000000)
         SphereRadiusRange=(Min=320.000000,Max=320.000000)
         StartLocationPolarRange=(X=(Min=65535.000000),Y=(Min=22000.000000,Max=15000.000000),Z=(Min=320.000000,Max=320.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=-2000.000000,Max=-2500.000000)
         StartLocationShape=PTLS_Polar
         UseRotationFrom=PTRS_Actor
         GetVelocityDirectionFrom=PTVD_AddRadial
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter55'
     Tag="AssassinShockwave"
     bNoDelete=False
     bDirectional=True
}
