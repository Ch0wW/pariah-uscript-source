class VGAssaultAttachment extends PersonalWeaponAttachment;//VGWeaponAttachment;//WeaponAttachment;

// upgrades to the assault rifle
var Actor Silencer;
var StaticMesh SilencerMesh;

var Actor LaserTarget;
var StaticMesh LaserTargetMesh;

var		xEmitter			TrailEffect;
var ()	class<xEmitter>		TrailEffectClass;

var		int TracerCount;
var() vector MuzzOffset;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(TrailEffectClass != none && TrailEffect == none)
		TrailEffect = Spawn(class'AssaultBulletTrail', self);
	if(TrailEffect != none) {
		AttachToWeaponAttachment(TrailEffect, MuzzleRef);
		TrailEffect.SetRelativeLocation(MuzzOffset);
		TrailEffect.mRegen = true;
		TrailEffect.bPaused = true;
		TrailEffect.bHidden = true;
	}
}

simulated function Destroyed()
{
	if(TrailEffect != none)
		TrailEffect.Destroy();
	if(Silencer != none)
		Silencer.Destroy();
	if(LaserTarget != none)
		LaserTarget.Destroy();

	Super.Destroyed();
}

simulated function vector GuessLastHitLocation()
{
    local Vector Origin;
    
    Origin = Instigator.Location + vect(0,0,1) * Instigator.EyeHeight;
    Origin += vector(xPawn(Instigator).Rotation) * 1000.0;
    
    return(Origin);    
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();

    if ( Level.NetMode == NM_DedicatedServer )
        return;

	if(TrailEffect != none) {
		AttachToWeaponAttachment(TrailEffect, MuzzleRef);
		TrailEffect.SetRelativeLocation(MuzzOffset);
	}

	if(Silencer != none && MuzFlash != none) {
		AttachToWeaponAttachment(MuzFlash, MuzzleRef);
		MuzFlash.SetRelativeLocation(MuzzleOffset);
	}

	if(Silencer != none && AltMuzFlash != none) {
		AttachToWeaponAttachment(AltMuzFlash, MuzzleRef);
		AltMuzFlash.SetRelativeLocation(MuzzleOffset);
	}

    if ( FlashCount > 0 )
	{
        if ( Instigator.Role < ROLE_AutonomousProxy )
            AmbientSound = Sound'PariahWeaponSounds.soul_bulldog1';

        SetTimer(0.2, false);

		if(FlashCount > 1 && TrailEffect != none) 
		{
			TrailEffect.bPaused = false;
			TrailEffect.bHidden = false;
			TrailEffect.mSpawnVecA = GuessLastHitLocation();
			TrailEffect.mStartParticles++;
		}
    }
    else
    {
		TrailEffect.bPaused = true;
		TrailEffect.bHidden = true;
		if(AltMuzFlash != none)
			bulldog_muzzleflash_3rd(AltMuzFlash).StopFlash();
        AmbientSound = None;
        GotoState('');
    }

	if(AltMuzFlash != none)   
		AltMuzFlash.SetRelativeLocation(MuzzOffset);
}

simulated function Timer()
{
	TrailEffect.bPaused = true;
	TrailEffect.bHidden = true;
	if(AltMuzFlash != none)
		bulldog_muzzleflash_3rd(AltMuzFlash).StopFlash();

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
     SilencerMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_silencer'
     LaserTargetMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_lazer_target'
     TrailEffectClass=Class'VehicleWeapons.AssaultBulletTrail'
     MuzzOffset=(X=30.000000,Y=-22.000000,Z=-7.000000)
     SFXRef1="FX1"
     SFXRef2="FX1"
     AltMuzFlashClass=Class'VehicleEffects.bulldog_muzzleflash_3rd'
     MuzzleRotation=(Yaw=-1000)
     bRapidFire=True
     bFlashForPrimary=True
     bFlashLight=True
     WeaponType=EWT_Bulldog
     SoundRadius=200.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.Bulldog_3rd'
     RelativeLocation=(X=4.000000,Y=-5.000000,Z=-5.000000)
     RelativeRotation=(Pitch=1200,Yaw=-700,Roll=-16384)
     SoundVolume=200
     bAlwaysRelevant=True
}
