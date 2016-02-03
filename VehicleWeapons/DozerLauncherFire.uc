class DozerLauncherFire extends VGProjectileFire;

var (Damage) float FireDelay;
var BogieRocket rocket;
var DozerLauncher launcher;
var Coords StartProj;
var Rotator AimRot;
var float YawVar, PitchVar;	// maximum yaw and pitch variance for the grenades

simulated function bool AllowFire()
{
    return (Instigator != none && Instigator.Health > 0);
}

function DoFireEffect()
{
	launcher = DozerLauncher(Weapon);

    Instigator.MakeNoise(1.0);

	if(Instigator.IsLocallyControlled() )
    {
		GotoState('Firing');
	}
}

state Firing
{
Begin:
	// spawn N projectiles, from alternating barrels at a Y second delay time between each shot

//    if(Level.NetMode == NM_Client)
//		launcher.ServerAnim(FireAnim);

	StartProj = Weapon.ThirdPersonActor.GetBoneCoords('FX1');
	AimRot = VehiclePlayer(Instigator.Controller).LastCamRotation;
	AimRot.yaw += RandRange(-YawVar, YawVar*0.5);
	AimRot.pitch += RandRange(0, PitchVar);
	launcher.SpawnRocket(StartProj.Origin, AimRot.yaw, AimRot.pitch);
	Sleep(FireDelay);

	// number two
	StartProj = Weapon.ThirdPersonActor.GetBoneCoords('FX2');
	AimRot = VehiclePlayer(Instigator.Controller).LastCamRotation;
	AimRot.yaw += RandRange(-YawVar*0.5, YawVar);
	AimRot.pitch += RandRange(0, PitchVar);
	launcher.SpawnRocket(StartProj.Origin, AimRot.yaw, AimRot.pitch);
	Sleep(FireDelay);

	GotoState('');
}

defaultproperties
{
     FireDelay=0.250000
     YawVar=500.000000
     PitchVar=500.000000
     bNoAutoAim=True
     AmmoPerFire=1
     TweenTime=0.090000
     FireRate=2.000000
     BotRefireRate=0.700000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="SwarmFire"
}
