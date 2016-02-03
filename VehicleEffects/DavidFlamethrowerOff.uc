class DavidFlamethrowerOff extends AltMuzzleFlash;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter258
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseDirectionAs=PTDU_Up
         MaxParticles=5
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         FadeOutStartTime=0.050000
         FadeInEndTime=0.050000
         SizeScaleRepeats=1.000000
         ParticlesPerSecond=12.000000
         OwnerBaseVelocityTransferAmount=1.000000
         Texture=Texture'EmitterTextures.MultiFrame.Flame_effect'
         ColorScale(0)=(Color=(B=255,G=120,R=120))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=130,G=211,R=255))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Acceleration=(X=100.000000)
         StartLocationOffset=(Z=3.200000)
         StartSizeRange=(X=(Min=3.500000,Max=3.500000),Y=(Min=5.000000,Max=5.000000),Z=(Min=4.000000,Max=4.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         GetVelocityDirectionFrom=PTVD_OwnerAndStartPosition
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         UseSizeScale=True
         UseRegularSizeScale=False
         BlendBetweenSubdivisions=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter258'
     Tag="FlamethrowerOff"
     bNoDelete=False
     bDirectional=True
}
