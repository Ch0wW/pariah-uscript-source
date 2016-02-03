class VGRocketLauncherAttachment extends PersonalWeaponAttachment;

var() vector MuzzOffset;

//var() class<AltMuzzleFlash> PuffMuzFlashClass;
//var AltMuzzleFlash PuffMuzFlash;


//simulated event ThirdPersonEffects()
//{
//	local Vector CPos;
//	local Rotator CRot;
//	local AltMuzzleFlash PM;

 //   Super.ThirdPersonEffects();

//	if (GetAttachPoint( 'FX1', CPos, CRot ))
//	{
//		PM=Spawn(PuffMuzFlashClass);
//		PM.SetBase(Self);
//		PM.SetRelativeLocation(CPos);
//		PM.SetRelativeRotation(CRot);
//	}
//}

defaultproperties
{
     MuzzOffset=(Y=-7.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     WeaponType=EWT_RocketLauncher
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.RocketLauncher_3rd'
     RelativeLocation=(X=-1.000000,Y=-2.000000,Z=-7.000000)
     RelativeRotation=(Pitch=-3000,Yaw=5000,Roll=-19000)
}
