Class FragRifleMuzzleFlash extends Emitter;

function StartFlash()
{
	Emitters[0].Trigger();
	Emitters[1].Trigger();
	Emitters[0].Trigger();
	Emitters[1].Trigger();
	Emitters[0].Disabled = false;
	Emitters[1].Disabled = false;
	if(WeaponFire(Owner).Weapon.GetWecLevel() > 1)
	{
		 Emitters[2].Trigger();
		 Emitters[2].Disabled = false;

//        Spawn(class'FlakMuzSparks',,,Location,Rotation);
    }
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter467
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
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter467'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter473
         MaxParticles=4
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-1.800000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.circle_flashyellow'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSpinRange=(X=(Max=10.000000),Y=(Max=10.000000))
         StartSizeRange=(X=(Min=3.500000,Max=6.000000))
         LifetimeRange=(Min=0.050000,Max=0.050000)
         CoordinateSystem=PTCS_Relative
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
     Emitters(1)=SpriteEmitter'VehicleEffects.SpriteEmitter473'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter399
         MaxParticles=26
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=0.300000
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'PariahWeaponEffectsTextures.FragRifle.FragFlak'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=140,G=140,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(Z=-190.000000)
         StartLocationRange=(X=(Max=20.000000))
         SphereRadiusRange=(Min=-2.000000,Max=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=29.000000,Max=45.000000),Y=(Min=20.000000,Max=50.000000),Z=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=0.100000,Max=0.150000)
         StartVelocityRange=(X=(Min=200.000000,Max=1900.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Min=4.000000,Max=5.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         CoordinateSystem=PTCS_Relative
         UseColorScale=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         Disabled=True
         SpinParticles=True
         UseRevolution=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ResetOnTrigger=True
     End Object
     Emitters(2)=SpriteEmitter'VehicleEffects.SpriteEmitter399'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
