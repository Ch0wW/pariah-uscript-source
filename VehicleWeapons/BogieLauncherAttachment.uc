class BogieLauncherAttachment extends VehicleWeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

var	MuzzleFlash	MuzParticles;
var int MuzzleFlipper;
var Sound MGFireSound;

var float AimPitchMin, AimPitchMax;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated event ThirdPersonEffects()
{
    if (Level.NetMode == NM_DedicatedServer )
        return;

    if (FlashCount > 0)
    {
        if (FiringMode == 1)
        {
            if (MuzFlash == None)
            {
                MuzFlash = Spawn(MuzFlashClass);
				AttachToWeaponAttachment(MuzFlash, MuzzleRef);
            }
			if(MuzParticles == None)
			{
				MuzParticles = Spawn(class'DavidPuncherMuzzle');
				AttachToWeaponAttachment(MuzParticles, MuzzleRef);
			}

	        if(MuzFlash != None && MuzParticles != None)
            {
                if(MuzzleFlipper == 0)
                {
                    MuzzleFlipper = 1;
        		    MuzFlash.SetRelativeLocation(Vect(0,32,0));
        		    MuzParticles.SetRelativeLocation(Vect(0,32,0));
                }
                else
                {
                    MuzzleFlipper = 0;
        		    MuzFlash.SetRelativeLocation(Vect(0,-32,0));
        		    MuzParticles.SetRelativeLocation(Vect(0,-32,0));
                }
		        MuzFlash.Flash(0);
            	MuzParticles.Flash(0);

            	//Spawn(class'VehicleGame.Tracer', Owner,, MuzFlash.Location, GetBoneRotation(MuzzleRef));
            }

			PlaySound(MGFireSound, SLOT_None, 1.0, false, 512,, false);

        }
    }
}

simulated function Tick(float dt)
{
	// this is where movement of the vehicle weapon is handled
	// the Bogie Launcher is a rider controlled weapon so there are two cases:
	// 1) If the weapon's owner is a VGPawn, that means it's under control of a player
	//    and should be aimed where they are looking
	// 2) If the weapon's owner is a VGVehicle, there is no rider controlling the weapon
	//    and it should point where the vehicle it is attached to is pointing
	// Note that since this is an attachment class, the owner is technically the weapon
	// so when I say owner I really mean the owner of the owner

	local Pawn WeaponOwner;
	local rotator NewRotation;
	local float	YawDiff, PitchDiff;
	local float	MaxYawDiff, MaxPitchDiff;
    local bool bLocal;

    bLocal = (Owner != None && Owner.Instigator != None && Owner.Instigator.IsLocallyControlled());

    if(Role < ROLE_Authority && !bLocal)
    {
		// set the bone rotations using the value set on the server side
		SetRelativeRotation(NewRotation);
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = WBRYaw;
		SetBoneDirection('Weapon', NewRotation, vect(0, 0, 0), 1.0, 0);

		NewRotation.Roll = 0;
		NewRotation.Yaw = 0;
		NewRotation.Pitch = WBRPitch;
		SetBoneDirection('Pivot01', NewRotation, vect(0, 0, 0), 1.0, 0);

		return;
	}

    if(Owner == None)
		return;

    WeaponOwner = Owner.Instigator;

	if(WeaponOwner == none)
		return;

	if(WeaponOwner.IsA('VGPawn') && WeaponOwner.Controller != None && VGPawn(WeaponOwner).RiddenVehicle != None)
    {
        NewRotation = WeaponOwner.Controller.Rotation;
		NewRotation.Pitch += 1250;
        NewRotation.Roll = 0;
    }
    else
    {
		NewRotation = Base.Rotation;
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
    }

	NewRotation.Roll = 0;
	TargetTime += dt;

	YawDiff = (NewRotation.Yaw & 65535) - (AimRotation.Yaw & 65535);

	if (YawDiff < -32768) yawDiff += 65536;
	else if (YawDiff > 32768) YawDiff -= 65536;

	MaxYawDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
	if(Abs(YawDiff) > MaxYawDiff)
	{
		if(YawDiff > 0)
			YawDiff = MaxYawDiff;
		else
			YawDiff = -MaxYawDiff;
	}

	// now same thing for pitch
	PitchDiff = (NewRotation.Pitch & 65535) - (AimRotation.Pitch & 65535);

	if (PitchDiff < -32768) PitchDiff += 65536;
	else if (PitchDiff > 32768) PitchDiff -= 65536;

	MaxPitchDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
	if(Abs(PitchDiff) > MaxPitchDiff)
	{
		if(PitchDiff > 0)
			PitchDiff = MaxPitchDiff;
		else
			PitchDiff = -MaxPitchDiff;
	}

	AimRotation.Roll = Base.Rotation.Roll;
	AimRotation.Yaw += YawDiff;
	AimRotation.Pitch += PitchDiff;

	if(AimRotation.Pitch < AimPitchMin)
		AimRotation.Pitch = AimPitchMin;
	if(AimRotation.Pitch > AimPitchMax)
		AimRotation.Pitch = AimPitchMax;

	NewRotation.Yaw = Base.Rotation.Yaw-AimRotation.Yaw;
	NewRotation.Pitch = 0;
	NewRotation.Roll = 0;
	SetBoneDirection('Weapon', NewRotation, vect(0, 0, 0), 1.0, 0);
	WBRYaw = NewRotation.Yaw;

	NewRotation.Yaw = 0;
	NewRotation.Pitch = AimRotation.Pitch;

	if(NewRotation.Pitch < PitchMin)
		NewRotation.Pitch = PitchMin;
	if(NewRotation.Pitch > PitchMax)
		NewRotation.Pitch = PitchMax;

	SetBoneDirection('Pivot01', NewRotation, vect(0, 0, 0), 1.0, 0);
	WBRPitch = NewRotation.Pitch;
}

simulated function vector GetMuzzleLocation()
{
    local Rotator R;
    R.Yaw = AimRotation.Yaw;
	return (Vect(150,0,0) >> R) + Location;
}

simulated function Rotator GetAttachmentRotation()
{
    return AimRotation;
}

defaultproperties
{
     AimPitchMin=-3000.000000
     AimPitchMax=5000.000000
     MGFireSound=Sound'NewVehicleSounds.Weapons.WaspFireA'
     PitchMax=4500.000000
     PitchMin=-1000.000000
     MuzFlashClass=Class'VehicleEffects.MachinegunMuzzleFlash'
     MuzzleOffset=(X=100.000000,Z=20.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     bHasWeaponBone=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.BogieLauncher'
     DrawType=DT_Mesh
}
