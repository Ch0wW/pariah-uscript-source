Class bulldog_muzzlesmoke_1st extends Emitter;

function StartSmoke()
{
	Emitters[0].Trigger();
	Emitters[0].ParticlesPerSecond = 10.0;
	Emitters[0].Disabled = false;
}

function StopSmoke()
{
	Emitters[0].ParticlesPerSecond = 0.0;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter396
         MaxParticles=6
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         FadeOutStartTime=-2.000000
         FadeInEndTime=0.500000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=2.000000,RelativeSize=3.250000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=7.000000,Max=5.000000),Y=(Min=200.000000,Max=200.000000),Z=(Min=200.000000,Max=200.000000))
         LifetimeRange=(Min=0.000000,Max=2.000000)
         StartVelocityRange=(Y=(Min=-15.000000,Max=-11.000000),Z=(Min=80.000000,Max=120.000000))
         VelocityLossRange=(Y=(Min=1.000000,Max=0.500000),Z=(Min=1.500000,Max=3.000000))
         AddVelocityMultiplierRange=(Z=(Min=-10.000000,Max=-20.000000))
         DrawStyle=PTDS_Darken
         FadeOut=True
         RespawnDeadParticles=False
         Disabled=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
         ResetOnTrigger=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter396'
     TimeTillResetRange=(Min=1.000000,Max=3.000000)
     Tag="Emitter"
     bNoDelete=False
     bDirectional=True
}
