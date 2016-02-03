class DartGunAttachment extends VehicleWeaponAttachment;//WeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

var	float		CurrentRoll;
var	MuzzleFlash	MuzParticles;
var	()	float	Offset;
var int			Barrel;

/*
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LinkSkelAnim(MeshAnimation'Puncher');
}
*/

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

			if(Barrel == 0) {
				MuzFlash.SetRelativeLocation(vect(0, 30, 0) );
				Barrel = 1;
			}
			else {
				MuzFlash.SetRelativeLocation(vect(0, -30, 0) );
				Barrel = 0;
			}

//			if(MuzParticles == None)
//			{
//				MuzParticles = Spawn(class'DavidPuncherMuzzle');
//				AttachToWeaponAttachment(MuzParticles, MuzzleRef);
//			}
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
//	MuzParticles.Flash(mode);
    //if (bFlashLight && !Level.bDropDetail && Level.bHighDetailMode)
    //    bDynamicLight = true;
}
/*
simulated function Timer()
{
	AmbientSound = None;
}
*/

defaultproperties
{
     offset=30.000000
     YawMax=16384.000000
     YawMin=-16384.000000
     PitchMax=2500.000000
     PitchMin=-1500.000000
     MuzzleOffset=(X=20.000000,Z=12.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.DartGun'
     DrawType=DT_Mesh
}
