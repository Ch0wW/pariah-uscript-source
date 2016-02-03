class C12GenSpark extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter360
         UseDirectionAs=PTDU_Right
         MaxParticles=40
         TextureUSubdivisions=1
         TextureVSubdivisions=2
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.weld_spark'
         ColorScale(0)=(RelativeTime=0.500000,Color=(B=94,G=139,R=234))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.100000)
         Acceleration=(Z=-3800.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SphereRadiusRange=(Min=10.000000,Max=10.000000)
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=50.000000),Y=(Min=25.000000,Max=10.000000))
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=-1000.000000,Max=-2000.000000),Y=(Min=-900.000000,Max=900.000000),Z=(Min=-900.000000,Max=900.000000))
         VelocityLossRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         UseColorScale=True
         FadeOut=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter360'
     LifeSpan=7.500000
     Tag="Emitter"
     RemoteRole=ROLE_DumbProxy
     bNoDelete=False
     bNetTemporary=True
     bDirectional=True
}
