class BotFragRifleFire extends FragRifleFireTrace;

function Tick( float dt )
{
	Super.ModeTick(dt);
}

defaultproperties
{
     TracesPerFire=4
     PersonDamage=15
     FireSound=Sound'PariahWeaponSounds.AI_Weapons.AI_FragRifle'
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
}
