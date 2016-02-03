class GrenadePoison extends GrenadeProjectile;

var VGRocketRadiationArea RadArea;
var float gasTimer;

replication {
	reliable if(Role == ROLE_Authority)
		RadArea, GasTimer;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	gasTimer = 0;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(bPowerUp) {
		RadArea = Spawn(class'VGRocketRadiationAreaPower',,, HitLocation+HitNormal*ExploWallOut);
	}
	else
		RadArea = Spawn(class'VGRocketRadiationArea',,, HitLocation+HitNormal*ExploWallOut);

	if(RadArea != none) {
		RadArea.Instigator = Instigator;
		RadArea.SetBase(self);
	}
}

simulated function Tick(float dt)
{
	Super.Tick(dt);

	// the grenades has "exploded" and started spewing gas, but keep the grenade around
	// until the gas is done
	gasTimer += dt;
	if(gasTimer >= 15)
		Destroy();
	else if(gasTimer >= 10) {
		Style = STY_Alpha;
		AdjustAlphaFade( (1-((gasTimer-10)/5))*255);
	}
}

defaultproperties
{
     VehicleDamage=0
     PersonDamage=0
     SplashDamage=0.000000
     MomentumTransfer=0.000000
}
