class PlayerPlasmaBlast extends Emitter
	placeable;
	
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
	PlaySound(Sound'PariahWeaponSounds.PlasmaBallExplode',SLOT_Misc,5.0);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter444
         MaxParticles=25
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         Texture=Texture'EmitterTextures.MultiFrame.Effect_D'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartAlphaRange=(Min=150.000000,Max=150.000000)
         SphereRadiusRange=(Min=5.000000,Max=5.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-1.000000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=3.500000,Max=5.000000),Z=(Min=3.500000,Max=5.000000))
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRadialRange=(Min=100.000000,Max=200.000000)
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter444'
     Tag="Lightning"
     bNoDelete=False
}
