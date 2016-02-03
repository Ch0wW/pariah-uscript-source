class HealingToolAmmo extends AmmoClip;

function bool AddAmmo(int AmmoToAdd)
{
    local bool reload;
    if(AmmoToAdd > 0 && RemainingMagAmmo == 0)
        reload = true;
    Super.AddAmmo(AmmoToAdd);
    if(reload && AmmoAmount > 0 && Pawn(Owner).Weapon.IsA('HealingTool'))
    {
	    Pawn(Owner).Weapon.DoReload();
    }
	return true;
}

defaultproperties
{
     MagAmount=4
     RemainingMagAmmo=4
     MaxAmmo=4
     AmmoAmount=4
     InitialAmount=4
     PickupAmmo=1
}
