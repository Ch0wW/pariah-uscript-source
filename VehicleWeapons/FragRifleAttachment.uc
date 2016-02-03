class FragRifleAttachment extends PersonalWeaponAttachment;

var PlayerRailGunShield3rd PlayerRailGunShield3rd;

var() vector MuzzOffset;

var() class<AltMuzzleFlash> AltMuzPuffClass;
var AltMuzzleFlash AltMuzPuff;


replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        PlayerRailGunShield3rd;
}

simulated function Destroyed()
{
    if (PlayerRailGunShield3rd != None)
        PlayerRailGunShield3rd.Destroy();

    Super.Destroyed();
}

function InitFor(Inventory I)
{
    Super.InitFor(I);

    PlayerRailGunShield3rd = Spawn(class'PlayerRailGunShield3rd', I.Instigator);
    PlayerRailGunShield3rd.SetBase(I.Instigator);
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();

	if(AltMuzFlash!=none && FlashCount>0)
	{
		AltMuzFlash.SetRelativeLocation(MuzzOffset );
//		AltMuzPuff = Spawn(AltMuzPuffClass);
//		AltMuzPuff.SetLocation(AltMuzFlash.Location);    //Do this so smoke puff isn't locked to end of barrel.
	}
}

defaultproperties
{
     AltMuzPuffClass=Class'VehicleEffects.FragRiffleMuzzleSmoke'
     MuzzOffset=(X=110.000000,Y=-4.000000)
     AltMuzFlashClass=Class'VehicleEffects.FragRiffleMuzzleFlash'
     bHeavy=True
     bFlashForPrimary=True
     WeaponType=EWT_FragRifle
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.FragRifle_3rd'
     RelativeLocation=(X=51.000000,Y=4.500000,Z=-4.000000)
     RelativeRotation=(Pitch=-600,Yaw=-400,Roll=-16000)
}
