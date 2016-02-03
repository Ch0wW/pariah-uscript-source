class KeeperWeaponFire extends VGInstantFire;

event ModeHoldFire()
{
	local KeeperWeaponChargeEffect chargeEffect;

	Super.ModeHoldFire();

    // init the effect here
	chargeEffect = Spawn(class'KeeperWeaponChargeEffect');
	if(chargeEffect != none) {
		if(Weapon.Owner.IsA('SPPawnShroudKeeperDrone') ) {
			Weapon.Owner.AttachToBone(chargeEffect, 'FX1');
			Weapon.Owner.AttachToBone(Weapon, 'FX1');
		}
	}
}

event ModeDoFire()
{
	Super.ModeDoFire();
}

function DoTrace(Vector Start, Rotator Dir)
{
	local Coords boneCoord;

	if(Weapon.Owner.IsA('SPPawnShroudKeeperDrone') ) {
		boneCoord = Weapon.Owner.GetBoneCoords('FX1');
		Start = boneCoord.Origin;
		Dir = Weapon.Owner.Rotation;//Weapon.Owner.GetBoneRotation('FX1');
	}

	Super.DoTrace(Start, Dir);
}

simulated function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local KeeperWeaponFireEffect beam;

	beam = Spawn(class'KeeperWeaponFireEffect',,, Start, Dir);//rotator(HitLocation-Start) );
}

defaultproperties
{
     Momentum=5000.000000
     DamageType=Class'VehicleWeapons.PlasmaGunDamage'
     VehicleDamage=2
     PersonDamage=2
     AmmoPerFire=1
     FireRate=0.150000
     Spread=0.060000
     FireSound=Sound'KeepersAndDrones.Keeper.KeeperFireA'
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     SpreadStyle=SS_Random
     bFireOnRelease=True
}
