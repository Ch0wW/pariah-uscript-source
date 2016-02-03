Class SniperRifleMuzzleFlash extends Emitter;

function StartFlash()
{
	Emitters[0].Trigger();
	Emitters[1].Trigger();
	Emitters[0].Trigger();
	Emitters[1].Trigger();
	Emitters[0].Disabled = false;
	Emitters[1].Disabled = false;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter472
         MaxParticles=25
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=-1.800000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         SizeScale(0)=(RelativeTime=0.050000,RelativeSize=6.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(X=800.000000,Y=9.000000,Z=350.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Max=30.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-2.000000,Max=2.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=2.500000,Max=3.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=150.000000,Max=500.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-250.000000,Max=250.000000))
         VelocityLossRange=(X=(Min=8.000000,Max=20.000000),Y=(Min=-0.200000,Max=0.500000),Z=(Min=20.000000,Max=20.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         FadeOut=True
         RespawnDeadParticles=False
         Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ResetOnTrigger=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter472'
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_muzzle_flash'
         UseMeshBlendMode=False
         RenderTwoSided=True
         MaxParticles=1
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.bulldog_muzzle_1'
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.350000,Max=0.350000),Z=(Min=0.800000,Max=0.900000))
         LifetimeRange=(Min=0.050000,Max=0.050000)
         CoordinateSystem=PTCS_Relative
         FadeOut=True
         RespawnDeadParticles=False
         Disabled=True
         ResetOnTrigger=True
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter0'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
