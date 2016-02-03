class SniperRifleAttachment extends PersonalWeaponAttachment;//VGWeaponAttachment;//WeaponAttachment;

// upgrades to the assault rifle
var Actor LaserTarget;
var StaticMesh LaserTargetMesh;

var		xEmitter			TrailEffect;
var ()	class<xEmitter>		TrailEffectClass;

var		vector LastHitLocation;
var		int TracerCount;
//var		VGAssaultRifle  WeaponOwner;

var() vector MuzzOffset;

replication
{
	reliable if(Role == ROLE_Authority)
		LastHitLocation;
//		ThirdPersonTracer, TrailEffect;
//	reliable if(Role == ROLE_Authority)
//		LaserTarget, LaserTargetMesh, Silencer, SilencerMesh;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

//	log("*****");
//	if(TrailEffectClass != none && TrailEffect == none)
//		TrailEffect = Spawn(class'AssaultBulletTrail', self);
//	if(TrailEffect != none) {
//		AttachToWeaponAttachment(TrailEffect, MuzzleRef);
//		TrailEffect.SetRelativeLocation(MuzzleOffset);
//		TrailEffect.bHidden = true;
//		TrailEffect.bPaused = true;
//		TrailEffect.mRegen = true;
//	}
}

simulated function Destroyed()
{
	if(TrailEffect != none)
		TrailEffect.Destroy();
	if(LaserTarget != none)
		LaserTarget.Destroy();

	Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();
	if(MuzFlash != none)
		MuzFlash.SetRelativeLocation(MuzzOffset );
}

simulated function Timer()
{
    AmbientSound = None;
}

simulated function ThirdPersonTracer(vector HitLocation)
{
//	log("Gyah!");
//	AttachToWeaponAttachment(TrailEffect, MuzzleRef);
//	TrailEffect.SetRelativeLocation(vect(5, 0, 0) );
//	TrailEffect.mSpawnVecA = HitLocation;
//	TrailEffect.mStartParticles++;
//	LastHitLocation = HitLocation;
}

defaultproperties
{
     LaserTargetMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_lazer_target'
     TrailEffectClass=Class'VehicleWeapons.AssaultBulletTrail'
     MuzzOffset=(X=107.000000,Y=-20.000000,Z=-5.000000)
     SFXRef1="FX1"
     SFXRef2="FX1"
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     bRapidFire=True
     bFlashForPrimary=True
     bFlashLight=True
     WeaponType=EWT_SniperRifle
     SoundRadius=200.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.SniperRifle_3rd'
     RelativeLocation=(X=33.000000,Y=-9.000000,Z=-4.000000)
     RelativeRotation=(Pitch=-200,Yaw=-550,Roll=-16384)
     SoundVolume=200
     bAlwaysRelevant=True
}
