class PlayerPlasmaGunAttachment extends PersonalWeaponAttachment;

var() vector MuzzOffset;

simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

//	if(MuzFlash != none)
//		MuzFlash.SetRelativeLocation(MuzzOffset );
	if(AltMuzFlash != none) 
	{  
		AltMuzFlash.SetRelativeLocation(MuzzOffset);

	    if ( FlashCount > 0 )
		    SetTimer(0.2, false);   //Set timer to turn off muz flash as done in VGassaultattachment
	}
}


simulated function Timer()   // Turn off MusFlashing if you hit reload while holding trigger.
{
	if(AltMuzFlash != none)
		AltMuzFlash.StopFlash();
}

defaultproperties
{
     MuzzOffset=(X=70.000000,Y=-20.500000,Z=-10.000000)
     AltMuzFlashClass=Class'VehicleEffects.PlayerPlasmaGunMuzzleFlash'
     bHeavy=True
     bFlashForPrimary=True
     WeaponType=EWT_PlasmaGun
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.PlasmaGun_3rd'
     RelativeLocation=(X=37.000000,Y=-10.500000,Z=-6.000000)
     RelativeRotation=(Pitch=200,Yaw=-500,Roll=-16384)
}
