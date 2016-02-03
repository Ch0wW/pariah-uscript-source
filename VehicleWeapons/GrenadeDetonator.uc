class GrenadeDetonator extends PersonalWeapon;

var GrenadeLauncher launcher;

replication
{
	reliable if(Role == ROLE_Authority)
		launcher, ClientGotoFired;
}

simulated function ClientGotoFired()
{
	FireMode[0].GotoState('Fired');
}

// skip the detonator when cycling the weapons
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon RecommendWeapon( out float rating )
{
    local Weapon Recommended;
    local float oldRating;

    rating = -2;

    if ( inventory != None )
    {
        Recommended = inventory.RecommendWeapon(oldRating);
        if ( (Recommended != None) && (oldRating > rating) )
        {
            rating = oldRating;
            return Recommended;
        }
    }
    return self;
}

simulated function bool HasAmmo()
{
    if ( launcher != None && launcher.HasLiveGrenades() )
    {
        return true;
    }
    return false;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	// check to see if we'd rather have the grenade launcher brought up instead
	launcher.CheckRevert();
}

simulated function Tick(float dt)
{
	if(Instigator != None && Instigator.Weapon == self && Instigator.IsLocallyControlled()) 
	{
		// check to see if we need to switch back to the launcher
    	launcher.CheckRevert();
	}
	Super.Tick(dt);
}

defaultproperties
{
     CrosshairIndex=-1
     SelectAnimRate=5.000000
     PutDownAnimRate=4.000000
     AIRating=-2.000000
     CurrentRating=-2.000000
     DisplayFOV=52.000000
     SelectAnim="Select"
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.GrenadeDetonatorFire'
     AttachmentClass=Class'VehicleWeapons.GrenadeDetonatorAttachment'
     PlayerViewOffset=(X=2.000000,Y=6.000000,Z=5.000000)
     InventoryGroup=20
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.GrenadeDetonator'
}
