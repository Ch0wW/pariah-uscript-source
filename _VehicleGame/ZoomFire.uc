class ZoomFire extends VGWeaponFire;

// mjm - completely useless, but has to exist or you won't be able to zoom

simulated function bool AllowFire()
{
    return true;
}

defaultproperties
{
     FireRate=0.100000
     BotRefireRate=0.300000
     FireAnim="aim_ready"
     bUseForceFeedback=False
     bFireOnRelease=True
     bModeExclusive=False
}
