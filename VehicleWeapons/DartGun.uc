//=============================================================================
// Dart Gun
//=============================================================================
class DartGun extends VehicleWeapon;

simulated function bool StartFire(int mode)
{
    local bool bStart;

    bStart = Super.StartFire(mode);
    //log(self$" StartFire ("$mode$"), bStart="$bStart);

	if (bStart) {
        FireMode[mode].StartFiring();

//		ThirdPersonActor = PuncherFire(FireMode[0]).Attachment;
	}

    return bStart;
}

// Allow fire modes to return to idle on weapon switch (server)
simulated function DetachFromPawn(Pawn P)
{
    ReturnToIdle();
    Super.DetachFromPawn(P);
}

// Allow fire modes to return to idle on weapon switch (client)
simulated function bool PutDown()
{
	PuncherFire(FireMode[0]).PutDown();
    return Super.PutDown();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if(PuncherFire(FireMode[0]) != none)
		PuncherFire(FireMode[0]).BringUp();
	Super.BringUp(PrevWeapon);
}

simulated function ReturnToIdle()
{
    local int mode;

    for (mode=0; mode<NUM_FIRE_MODES; mode++)
    {
        if (FireMode[mode] != None)
        {
			PuncherFire(FireMode[mode]).PutDown();
            //FireMode[mode].GotoState('Idle');
        }
    }  
}

defaultproperties
{
     WeaponMountName(0)="WP3"
     AIRating=0.400000
     CurrentRating=0.400000
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.DartGunFire'
     bCanThrow=False
     bAutoTarget=True
     PickupClass=Class'VehicleWeapons.DartGunPickup'
     AttachmentClass=Class'VehicleWeapons.DartGunAttachment'
     ItemName="DartGun"
     BarIndex=1
}
