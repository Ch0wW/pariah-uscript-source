class BotGrenadeLauncherFire extends GrenadeLauncherFire;

var bool bCutOff;

function PrematurelyCutoffShot()
{
    bCutOff=true;
}
                                    
function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

	if(Instigator == none)
		return;

    //Instigator.MakeNoise(1.0);
	MakeFireNoise();
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
	StartProj = GetFireStart(X,Y,Z);

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }
    
	// Auto-aim or no auto aim
	if( bNoAutoAim && !Instigator.Controller.IsA('AIController')) {
        Other = Trace(HitLocation, HitNormal, StartTrace+10000*vector(Instigator.Controller.Rotation), StartTrace, true);
		if(Other != none) {
			Aim = Rotator(HitLocation-StartProj);
			if( (vector(Aim) dot vector(Instigator.Controller.Rotation) ) < 0) {
				// ok... so what's happening here is that if you walk up right beside another bot/player and fire, sometimes
				// the hitlocation is between the projectile start and the instigator which essentially results in firing
				// backwards - the other way to look at it is that we're trying to spawn the projectile inside the character
				// we're standing beside; this gets around the problem (or appears to)
				Aim = Instigator.Controller.Rotation;
				StartProj = HitLocation;
			}
		}
		else
			Aim = Instigator.Controller.Rotation;
	}
	else
    {
        Aim = AdjustAim(StartProj, AimError);
        if(bCutOff)
        {
            bCutOff = false;
            return;
        }

    }

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        for (p = 0; p < SpawnCount; p++)
        {
	        SpawnProjectile(StartProj, Aim);
		}
    }

    //Hackalicious
	//Super.DoFireEffect();
}

defaultproperties
{
     SplashDamage=25.000000
     PersonDamage=40
     FireSound=Sound'PariahWeaponSounds.AI_Weapons.AI_GrenadeLauncher'
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     ProjectileClass=Class'VehicleWeapons.BotGrenadeProjectile'
}
