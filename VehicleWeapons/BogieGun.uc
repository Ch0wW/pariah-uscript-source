//=============================================================================
// Bogie driver controlled weapon
//=============================================================================
class BogieGun extends VehicleWeapon;

//var Actor ThirdPersonActor2;	// second third person actor for the gun
var BogieGunR	slaveGun;
var int fireSeq;

replication
{
	reliable if(Role == ROLE_Authority)
		slaveGun;
}

simulated function AttachToPawn(Pawn P) 
{
	Super.AttachToPawn(P);

	if(slaveGun != none)
		slaveGun.AttachToPawn(P);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	local int m;

	Super.BringUp(PrevWeapon);
	if(IsA('BogieGunR') )//|| Role < Role_Authority)
		return;

	if(slaveGun == none) {
		// create the slave gun here... I don't really like this solution, but it seems the simplest way
		slaveGun = Spawn(class'BogieGunR', Owner);
//		if(slaveGun != none) {

//			slaveGun.ThirdPersonActor.SetOwner(slaveGun);
//		}
//	}
	
//	log("Instigator = "$Instigator);

	if(slaveGun != none) {
		// set up fire modes and such
		slaveGun.SetPhysics(PHYS_RidingBase);
		slaveGun.Instigator = Instigator;
		slaveGun.AttachToPawn(Pawn(Owner) );
		slaveGun.CreateFireModes();
		slaveGun.FireMode[0].InitEffects();

		for (m = 0; m < NUM_FIRE_MODES; m++) {
	        if(slaveGun.FireMode[m] != None) {
	            slaveGun.FireMode[m].Instigator = slaveGun.Instigator;

//				    if(WeaponPickup(Pickup) != None)
//						slaveGun.FireMode[m].DroppedAmmoCount = WeaponPickup(Pickup).AmmoAmount[m];

	            slaveGun.GiveAmmo(m);
			}
		}

		slaveGun.ClientState = WS_ReadyToFire;
	}
	}
	BogieGunFire(FireMode[0]).BringUp();

	slaveGun.SetOwner(Pawn(Owner) );
}

/*simulated function Tick(float dt)
{
	if(slaveGun != none && !IsA('BogieGunR') ) {
		slaveGun.SetOwner(Pawn(Owner) );
		slaveGun.Instigator = Instigator;
	}

	Super.Tick(dt);
}*/

simulated event ClientStartFire(int Mode)
{
	Super.ClientStartFire(Mode);
	if(slaveGun != none)
		slaveGun.ClientStartFire(Mode);
}

simulated event ClientStopFire(int Mode)
{
	Super.ClientStopFire(Mode);
	if(slaveGun != none)
		slaveGun.ClientStopFire(Mode);
}

event ServerStartFire(byte Mode)
{
	Super.ServerStartFire(Mode);
	if(slaveGun != none)
		slaveGun.ServerStartFire(Mode);
}

function ServerStopFire(byte Mode)
{
	Super.ServerStopFire(Mode);
	if(slaveGun != none)
		slaveGun.ServerStopFire(Mode);
}

/*simulated function bool StartFire(int Mode)
{
	Super.StartFire(Mode);
	if(slaveGun != none)
		slaveGun.StartFire(Mode);
}*/

simulated event StopFire(int Mode)
{
	Super.StopFire(Mode);
	if(slaveGun != none)
		slaveGun.StopFire(Mode);
}

simulated function AnimEnd(int channel)
{
	Super.AnimEnd(channel);
	if(slaveGun != none)
		slaveGun.AnimEnd(channel);
}

simulated function PlayIdle()
{
	Super.PlayIdle();
//	if(slaveGun != none)
//		slaveGun.PlayIdle();
}

simulated function Destroyed()
{
	Super.Destroyed();
	if(slaveGun != none) {
		slaveGun.Destroy();
		slaveGun = none;
	}
}

simulated function bool StartFire(int mode)
{
    local bool bStart;

    bStart = Super.StartFire(mode);
//    log(self$" StartFire ("$mode$"), bStart="$bStart);

	if (bStart && !IsA('BogieGunR') ) {
		if(FireMode[mode] != none)
			FireMode[mode].StartFiring();
		if(slaveGun != none) {
//			slaveGun.StartFire(mode);
//			slaveGun.FireMode[mode].StartFiring();
			slaveGun.FireMode[mode].GotoState('Firing');
		}

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

//simulated function BringUp(optional Weapon PrevWeapon)
//{
//	PuncherFire(FireMode[0]).BringUp();
//	Super.BringUp(PrevWeapon);
//}

simulated function ReturnToIdle()
{
    local int mode;

    for (mode=0; mode<NUM_FIRE_MODES; mode++)
    {
        if (FireMode[mode] != None)
        {
			BogieGunFire(FireMode[mode]).PutDown();
            //FireMode[mode].GotoState('Idle');
        }
    }  
}

defaultproperties
{
     WeaponMountName(0)="WP1"
     AIRating=0.400000
     CurrentRating=0.400000
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.BogieGunFire'
     bCanThrow=False
     bAutoTarget=True
     bIndependantPitch=True
     PickupClass=Class'VehicleWeapons.PuncherPickup'
     AttachmentClass=Class'VehicleWeapons.BogieGunAttachmentL'
     ItemName="BogieGun"
     BarIndex=1
}
