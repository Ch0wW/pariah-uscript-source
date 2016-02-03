class PlayerTurretDummyWeapon extends VehicleWeapon;

var PlayerTurret Turret;
var sound        sndTurretSpinUp;
var sound        sndTurretSpinDown;

replication
{
	reliable if(Role == ROLE_Authority)
		Turret;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
}

simulated function SetTurret(Pawn T)
{
    Turret = PlayerTurret(T);
    PlayerTurretDummyWeaponFire(FireMode[0]).Turret = Turret;
}

simulated function bool StartFire(int mode)
{
    local bool bStart;

    PlayOwnedSound(sndTurretSpinUp, SLOT_Misc, TransientSoundVolume, , 3000);
    bStart = Super.StartFire(mode);

	if(bStart) {
        FireMode[mode].StartFiring();
	}

    return bStart;
}

simulated event StopFire(int mode)
{
    PlayOwnedSound(sndTurretSpinDown, SLOT_Misc, TransientSoundVolume, , 3000);
    Super.StopFire(mode);
}


simulated function vector GetTurretTarget()
{
	return PlayerTurretDummyWeaponFire(FireMode[0]).GetTurretTarget();
}

defaultproperties
{
     sndTurretSpinUp=Sound'PlayerTurretSounds.Spinning.TrainTurretStartUp'
     sndTurretSpinDown=Sound'PlayerTurretSounds.Spinning.TrainTurretShutDown'
     FireModeClass(0)=Class'VehicleWeapons.PlayerTurretDummyWeaponFire'
     bOnlyTargetVehicles=False
     bCanThrow=False
     bIsVehicleWeapon=False
     InventoryGroup=26
     bOnlyRelevantToOwner=False
}
