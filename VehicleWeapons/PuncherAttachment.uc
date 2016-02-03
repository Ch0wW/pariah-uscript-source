class PuncherAttachment extends VehicleWeaponAttachment;//WeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

var	float		CurrentRoll;
var	MuzzleFlash	MuzParticles;
/*
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LinkSkelAnim(MeshAnimation'Puncher');
}
*/
simulated function RollBarrel(float dt, float speed)
{
	local rotator r;
	//RollSpeed = 145635.55;	// gun has 3 barrels so RollSpeed = 1/3 rotation * firerate
	CurrentRoll += dt*speed;
	CurrentRoll = CurrentRoll % 65536.f;
	r.Roll = int(CurrentRoll);
	SetBoneRotation('Barrels', r, 0, 1.0);
//	log("PA Rot = "$Rotation);
}

simulated function StopBarrel()
{
//	CurrentRoll = 0.0;
//	SetBoneRotation('Barrels01', rot(0,0,0), 0, 1.0);
}

simulated event ThirdPersonEffects()
{
    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

    if (FlashCount == 0)
    {
        bDynamicLight = false;
    }
    if (FlashCount > 0 && MuzFlashClass != None)
    {
        if (FiringMode == 0 && bFlashForPrimary || FiringMode == 1 && bFlashForAlt)
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
            FlashFlash(FiringMode);
			/*
			if ( Instigator.Role < ROLE_AutonomousProxy )
			{
				AmbientSound = Sound'SM-chapter03sounds.TurretOneSecondLoopB';
				SetTimer(0.2, false);
			}
			*/
        }
    }
}

simulated function FlashFlash(byte mode)
{
    MuzFlash.Flash(mode);
	MuzParticles.Flash(mode);
    //if (bFlashLight && !Level.bDropDetail && Level.bHighDetailMode)
    //    bDynamicLight = true;
}
/*
simulated function Timer()
{
	AmbientSound = None;
}
*/
/*
//XJ: horrible brute force method for now
simulated function Tick(float dt)
{
    local rotator r;
	local float RollSpeed;

	if(Instigator == none || Instigator.Controller == none)
		return;

	if(Instigator.Controller.bFire == 1)
	{
		RollSpeed = 145635.55;	// gun has 3 barrels so RollSpeed = 1/3 rotation * firerate
		CurrentRoll += dt*RollSpeed;
		CurrentRoll = CurrentRoll % 65536.f;
		r.Roll = int(CurrentRoll);
		SetBoneRotation('Barrels', r, 0, 1.0);
	}
	else
	{
		r.Roll = 0;
		SetBoneRotation('Barrels', r, 0, 1.0);
	}
}
*/

defaultproperties
{
     YawMax=16384.000000
     YawMin=-16384.000000
     PitchMax=2500.000000
     PitchMin=-2500.000000
     MuzFlashClass=Class'VehicleEffects.MachinegunMuzzleFlash'
     MuzzleOffset=(X=100.000000,Z=12.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.WaspGun'
     DrawType=DT_Mesh
}
