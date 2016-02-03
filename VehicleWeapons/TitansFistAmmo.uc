class TitansFistAmmo extends AmmoClip;

simulated function CheckOutOfAmmo()
{
}

simulated function bool CheckReload()
{
	return false;
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
	if(RemainingMagAmmo <= 0) 
	{
		RemainingMagAmmo = 0;
	}
    
    return true;
}

function bool AddAmmo(int AmmoToAdd)
{
	if (RemainingMagAmmo == MagAmount) 
		return false;

    RemainingMagAmmo = Min(RemainingMagAmmo + AmmoToAdd, MagAmount);
    return true;
}

simulated function bool HasAmmo()
{
    return(true);
}

defaultproperties
{
     MagAmount=100
     RemainingMagAmmo=100
     InitialAmount=0
     PickupAmmo=100
}
