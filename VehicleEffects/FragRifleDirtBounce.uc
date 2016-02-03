Class FragRifleDirtBounce extends ChassisSparks;

simulated function PostBeginPlay()
{
	local vector velMin, velMax, b1, b2, b3;
	local rangevector velRange;
	local rotator rot;

	Super.PostBeginPlay();

	b3 = vect(0, 0, 1);

	rot = Rotation-rotator(b3);

	b1 = vect(1, 0, 0) >> Rot;
	b2 = vect(0, 1, 0) >> Rot;
	b3 = vect(0, 0, 1) >> Rot;

	velMin = -25*(b1+b2)+300*b3;
	velMax = 25*(b1+b2)+400*b3;

	velRange.X.Min = velMin.X;
	velRange.Y.Min = velMin.Y;
	velRange.Z.Min = velMin.Z;

	velRange.X.Max = velMax.X;
	velRange.Y.Max = velMax.Y;
	velRange.Z.Max = velMax.Z;

	Emitters[0].StartVelocityRange = velRange;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter345
         ProjectionNormal=(Z=0.000000)
         MaxParticles=3
         FadeOutStartTime=1.000000
         InitialParticlesPerSecond=250.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.dirt_bounce'
         SizeScale(0)=(RelativeTime=2.000000,RelativeSize=-1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.400000)
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.500000))
         SpinsPerSecondRange=(X=(Min=1.000000,Max=3.000000))
         RotationDampingFactorRange=(X=(Min=20.000000,Max=20.000000))
         StartSizeRange=(X=(Min=1.500000,Max=2.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=25.000000),Y=(Min=-20.000000,Max=25.000000),Z=(Min=300.000000,Max=400.000000))
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter345'
     AutoReset=False
     Tag="ChassisSparks"
}
