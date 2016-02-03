Class PlasmaSpark extends ChassisSparks;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter297
         ProjectionNormal=(Z=0.000000)
         UseDirectionAs=PTDU_Scale
         MaxParticles=5
         FadeOutStartTime=0.900000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'MannyTextures.Coronas.blue_corona2'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=-1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.400000)
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.600000,Max=0.700000))
         StartSizeRange=(X=(Min=5.000000,Max=7.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=70.000000),Y=(Min=-50.000000,Max=70.000000),Z=(Min=-250.000000,Max=-350.000000))
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter297'
     Tag="ChassisSparks"
}
