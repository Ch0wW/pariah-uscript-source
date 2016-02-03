Class assault_silenced_muzzlepuff extends Emitter;

function StartPuff()
{
	Emitters[0].Trigger();
	Emitters[0].ParticlesPerSecond = 20.0;
	Emitters[0].Disabled = false;
}

function StopPuff()
{
	Emitters[0].ParticlesPerSecond = 0.0;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter403
         MaxParticles=15
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=-0.100000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(X=200.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         StartSizeRange=(X=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=0.700000,Max=0.800000)
         StartVelocityRange=(X=(Min=450.000000,Max=580.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=14.000000))
         VelocityLossRange=(X=(Min=20.000000,Max=25.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-2.000000,Max=2.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         FadeOut=True
         RespawnDeadParticles=False
         Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ResetOnTrigger=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter403'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
}
