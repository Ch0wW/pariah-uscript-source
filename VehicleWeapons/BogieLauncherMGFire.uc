class BogieLauncherMGFire extends VGInstantFire;

function bool AllowFire()
{
    local VehiclePlayer VP;
    
    VP = VehiclePlayer(Instigator.Controller);

    if( (VP != None) && VP.bExitingByAnimation )
        return false;

    return Super.AllowFire();
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
	local BogieLauncher launcher;
	local rotator rot;

	launcher = BogieLauncher(Weapon);

    rot = launcher.GetAimRot(VehiclePlayer(Instigator.Controller));

    return rot;
}

defaultproperties
{
     Momentum=1024.000000
     DamageType=Class'VehicleWeapons.PuncherDamage'
     HitEffectClass=Class'VehicleWeapons.VGHitEffect'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=20
     PersonDamage=75
     MaxHeatTime=5.500000
     MaxCoolTime=4.000000
     AmmoPerFire=1
     FireRate=0.120000
     BotRefireRate=0.990000
     aimerror=800.000000
     Spread=0.030000
     FireLoopAnim="Fire"
     FireEndAnim="Idle"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     SpreadStyle=SS_Random
     bPawnRapidFireAnim=True
     SoundRadius=200.000000
     SoundVolume=200
}
