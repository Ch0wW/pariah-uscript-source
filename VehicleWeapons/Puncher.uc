//=============================================================================
// Assault Rifle
//=============================================================================
class Puncher extends VehicleWeapon;

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
     AutoAimFactor=1.000000
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.PuncherFire'
     bCanThrow=False
     bAutoTarget=True
     PickupClass=Class'VehicleWeapons.PuncherPickup'
     AttachmentClass=Class'VehicleWeapons.PuncherAttachment'
     ItemName="Puncher"
     BarIndex=1
}
