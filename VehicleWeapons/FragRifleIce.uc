class FragRifleIce extends VGProjectileFire;

simulated function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
//    local Projectile p;
//	local int n;

	if(Level.NetMode == NM_Client)
		return none;

	//Turn on the weapon dynamic light (not if it is a bot though)
//	if( Instigator.Controller.IsA('PlayerController') )
//		PersonalWeapon(Weapon).bTurnedOnDynLight = true;

    return Super.SpawnProjectile(Start, Dir);
}

function PlayFiring()
{
    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
        {
            Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
        }
        else
        {
			FragRifle(Weapon).PlayFireAnim(FireAnim, FireAnimRate, TweenTime);
        }
    }
    else
    {
			FragRifle(Weapon).PlayFireAnim(FireAnim, FireAnimRate, TweenTime);
    }
    if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}
    FireCount++;
}

state Reload
{
	simulated function BeginState()
	{
	}
	simulated function EndState()
	{
		NextFireTime = Level.TimeSeconds;
	}

	event ModeDoFire(){}
	simulated function ModeTick(float dt)
    {
	}
}

defaultproperties
{
     ProjSpawnOffset=(X=25.000000,Y=31.000000,Z=6.000000)
     bAnimateThird=False
     bNoAutoAim=True
     AmmoPerFire=1
     RecoilPitch=600
     FireRate=1.500000
     RecoilTime=0.500000
     BotRefireRate=0.700000
     WarnTargetPct=0.900000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireSound=Sound'PariahWeaponSounds.rocketlaunch_fire'
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.FragRifleAmmo'
     ProjectileClass=Class'VehicleWeapons.FragRifleIceShard'
     FireForce="VGRocketLauncherFire"
}
