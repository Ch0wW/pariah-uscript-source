class PlayerPlasmaBlastBig extends Emitter
	placeable;
	
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
	PlaySound(Sound'PariahWeaponSounds.PlasmaBallExplode',SLOT_Misc,5.0);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter478
         MaxParticles=32
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         Texture=Texture'EmitterTextures.MultiFrame.Effect_D'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=16.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         SphereRadiusRange=(Min=18.000000,Max=18.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-1.000000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(Y=(Min=9.000000,Max=12.000000),Z=(Min=9.000000,Max=12.000000))
         LifetimeRange=(Min=0.700000,Max=0.700000)
         StartVelocityRadialRange=(Min=250.000000,Max=400.000000)
         VelocityLossRange=(X=(Min=6.000000,Max=6.000000),Y=(Min=6.000000,Max=6.000000),Z=(Min=6.000000,Max=6.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_Brighten
         GetVelocityDirectionFrom=PTVD_AddRadial
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter478'
     Tag="Lightning"
     bNoDelete=False
}
