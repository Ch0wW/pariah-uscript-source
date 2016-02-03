class GrenadeLauncherAttachment extends PersonalWeaponAttachment;//VGWeaponAttachment;//WeaponAttachment;

var() vector MuzzOffset;

//simulated event ThirdPersonEffects()     //Muzzflash is spawned with Grenade itself to create
//{											// the first person and 3rd person muz flash at same time.
//	Super.ThirdPersonEffects();				// since no code seems to exist for 1st person muz flash. jds
//
//	if(MuzFlash != none)
//		MuzFlash.SetRelativeLocation(MuzzOffset );
//
//}

defaultproperties
{
     MuzzOffset=(X=90.000000,Y=-20.500000,Z=-10.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     WeaponType=EWT_GrenadeLauncher
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.GrenadeLauncher_3rd'
     RelativeLocation=(X=35.000000,Y=-5.000000,Z=-2.000000)
     RelativeRotation=(Pitch=-500,Yaw=-800,Roll=-16384)
}
