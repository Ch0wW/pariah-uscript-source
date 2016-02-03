class BotFlameThrowerAltFire extends VGProjectileFire;

simulated function bool AllowFire()
{
	return true;
}

defaultproperties
{
     AmmoPerFire=1
     FireRate=1.000000
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     ProjectileClass=Class'VehicleWeapons.BotFireball'
     bSplashDamage=True
}
