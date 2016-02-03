class AmmoClip extends Ammunition;

var travel byte RemainingMagAmmo;
var int MagAmount;

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		RemainingMagAmmo;
}

simulated function bool HasAmmo()
{
    if(RemainingMagAmmo > 0 || AmmoAmount > 0)
    {
        return(true);
    }
    return(false);
}

simulated function bool AllowFire(int Required)
{
    return(RemainingMagAmmo >= Required);
}

simulated function CompletedReload()
{
    local int PrevMagRemain;
    
    PrevMagRemain = RemainingMagAmmo;
    
    RemainingMagAmmo = Min(RemainingMagAmmo + AmmoAmount, MagAmount);
    
    AmmoAmount -= (RemainingMagAmmo - PrevMagRemain);
}

simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
    if (bAmountNeededIsMax && RemainingMagAmmo < AmountNeeded)
    {
        AmountNeeded = RemainingMagAmmo;
    }

	if (RemainingMagAmmo < AmountNeeded)
	{
        return false;   // Can't do it
    }

    RemainingMagAmmo -= AmountNeeded;
	if(RemainingMagAmmo <= 0 && AmmoAmount > 0) 
	{
	    Pawn(Owner).Weapon.DoReload();
		RemainingMagAmmo = 0;
	}
    
    if(Level.NetMode == NM_StandAlone || Level.NetMode == NM_ListenServer)
    {
        CheckOutOfAmmo();
    }
    return true;
}

simulated function CheckOutOfAmmo()
{
    if(AmmoAmount <= 0 && RemainingMagAmmo <= 0)
    {
        Pawn(Owner).Weapon.OutOfAmmo();
    }
}

simulated function bool CheckReload()
{
    if(RemainingMagAmmo == 0 && AmmoAmount > 0)
    {
        return true;
    }
	return false;
}

defaultproperties
{
     MagAmount=15
     RemainingMagAmmo=15
     NetPriority=0.500000
     NetUpdateFrequency=8.000000
}
