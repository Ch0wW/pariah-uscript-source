class GrenadeDetonatorFire extends VGInstantFire;

simulated function bool AllowFire()
{
	return true;
}

function DoFireEffect()
{
	Super.DoFireEffect();
	GrenadeDetonator(Weapon).ClientGotoFired();
	GotoState('Fired');
}

state Fired
{
Begin:
	// detonate the grenade here, presuming there is one
	Weapon.PlayAnim(FireAnim, 1.0);
	Sleep(0.1);
	GrenadeDetonator(Weapon).launcher.DetonateGrenades();
	Sleep(0.3);
	GotoState('');
}

function PlayFiring()
{
    Super.PlayFiring();
	if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}
}

defaultproperties
{
     AmmoPerFire=1
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="GrenadeDetonator"
}
