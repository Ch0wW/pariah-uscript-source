class BarrelLeak extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=BarrelLeakSpriteEmitter19
         UseDirectionAs=PTDU_Up
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=1.000000
         FadeInEndTime=0.010000
         ParticlesPerSecond=16.000000
         InitialParticlesPerSecond=16.000000
         Texture=Texture'PariahVehicleWeaponTextures.Puncher.DirtDust'
         Acceleration=(Z=-400.000000)
         StartAlphaRange=(Min=20.000000,Max=20.000000)
         StartLocationRange=(Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=6.000000,Max=12.000000),Y=(Min=25.000000,Max=40.000000),Z=(Min=6.000000,Max=12.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=-155.000000,Max=-130.000000))
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.BarrelLeakSpriteEmitter19'
     PostEffectsType=PTFT_Distortion
     bNoDelete=False
}
