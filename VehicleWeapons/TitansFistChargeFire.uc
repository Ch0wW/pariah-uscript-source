class TitansFistChargeFire extends VGInstantFire;

var() float ChargeTime;

event ModeHoldFire()
{
	Super.ModeHoldFire();
	GotoState('Charge');
}

// weapon charging state
state Charge
{
	simulated function BeginState()
	{
		
	}
 
	simulated function EndState()
	{
	
	}
 
	simulated function Tick( float dt )
	{
		ChargeTime += dt;
		ClientPlayForceFeedback(FireForce);
	}
	
	event ModeDoFire()
	{
	    // stop

	}
}

defaultproperties
{
     Momentum=28000.000000
     HitEffectClass=Class'VehicleWeapons.VGTitanHitEffects'
     PersonDamage=2
     bAnimateThird=False
     AmmoPerFire=1
     FireRate=2.000000
     BotRefireRate=0.990000
     FireSound=Sound'PariahWeaponSounds.hit.TF_Fire9'
     FireLoopAnim="PreFire"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Random
     bFireOnRelease=True
}
