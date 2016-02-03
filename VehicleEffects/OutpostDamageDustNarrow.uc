class OutpostDamageDustNarrow extends David;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter375
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseDirectionAs=PTDU_Normal
         MaxParticles=2
         FadeOutStartTime=1.100000
         FadeInEndTime=0.300000
         InitialParticlesPerSecond=5.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.waterfall_1'
         ColorScale(0)=(Color=(B=101,G=122,R=135,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=72,G=77,R=80,A=255))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.950000,RelativeSize=0.900000)
         Acceleration=(Z=-75.000000)
         StartLocationRange=(X=(Max=10.000000),Y=(Min=-20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=75.000000),Y=(Max=150.000000))
         LifetimeRange=(Min=1.500000,Max=2.000000)
         StartVelocityRange=(Z=(Min=-50.000000,Max=-200.000000))
         VelocityLossRange=(Z=(Max=0.500000))
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Offset
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter375'
     AutoDestroy=True
     Tag="OutpostDamageDustNarrow"
     bNoDelete=False
     bDirectional=True
}
