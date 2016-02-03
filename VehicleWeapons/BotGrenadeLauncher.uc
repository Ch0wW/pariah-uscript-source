class BotGrenadeLauncher extends GrenadeLauncher;

//mh delicious

// moved this here from the grenadelauncherfire class to support new grenade launcher behaviour... it also conveniently
// seems to solve a replication issue with the detonator/launcher interaction which is a plus
simulated function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
	local GrenadeProjectile gp;//, gpTemp;
	local class<Projectile> ProjectileClass;

	if(Level.NetMode == NM_Client)
		return none;

    ProjectileClass = class'VehicleWeapons.BotGrenadeProjectile';
    p = Spawn(ProjectileClass,,, Start, Dir);

    if( p == None )
        return None;

	p.ProjOwner = Instigator.Controller;
    p.Damage = Ceil(p.Damage * FireMode[0].DamageAtten);
	p.Instigator = Instigator;

	gp = GrenadeProjectile(p);

	CurrentGrenades[CurrentGrenades.Length] = gp;

	//Turn on the weapon dynamic light (not if it is a bot though)
	if(Instigator.Controller.IsA('PlayerController') )
		bTurnedOnDynLight = true;

    return p;
}

defaultproperties
{
     FireModeClass(0)=Class'VehicleWeapons.BotGrenadeLauncherFire'
}
