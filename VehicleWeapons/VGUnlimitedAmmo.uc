class VGUnlimitedAmmo extends Ammunition;

//Unlimited!
simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
	return true;
}

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
     MaxAmmo=1
     AmmoAmount=1
     InitialAmount=1
     ItemName="Unlimited Ammo"
}
