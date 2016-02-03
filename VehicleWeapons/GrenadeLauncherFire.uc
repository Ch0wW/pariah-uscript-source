class GrenadeLauncherFire extends VGProjectileFire;

const FLASHING_TIME = 0.20;

var (Damage) float SplashDamage;
var (Damage) float DamageRadius;
var (Damage) float MomentumTransfer;
var (Damage) int PoisonVehicleDamage;
var (Damage) int PoisonPersonDamage;
var (Damage) float PoisonSplashDamage;
var (Damage) float PoisonDamageRadius;
var (Damage) float PoisonMomentumTransfer;
var (Damage) int StickyVehicleDamage;
var (Damage) int StickyPersonDamage;
var (Damage) float StickySplashDamage;
var (Damage) int MagVehicleDamage;
var (Damage) int MagPersonDamage;
var (Damage) float MagSplashDamage;

// override SpawnProjectile so that we can boost the grenade power if that WEC upgrade has been obtained
function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;
	local GrenadeProjectile gp;

	Spawn(class'VehicleEffects.GrenadeMuzzFlash', self,, Start, Dir); // <- die

    p = GrenadeLauncher(weapon).SpawnProjectile(Start, Dir);
	gp = GrenadeProjectile(p);
	if(gp != none) {
		if(gp.IsA('GrenadePoison') )
			gp.SetParams(PoisonVehicleDamage, PoisonPersonDamage, PoisonSplashDamage, PoisonDamageRadius, MomentumTransfer);
		else if(gp.IsA('GrenadeSticky') )
			gp.SetParams(StickyVehicleDamage, StickyPersonDamage, StickySplashDamage, DamageRadius, MomentumTransfer);
		else if(gp.IsA('GrenadeMag') )
			gp.SetParams(MagVehicleDamage, MagPersonDamage, MagSplashDamage, DamageRadius, MomentumTransfer);
		else if(gp.IsA('GrenadeProjectile') )
			gp.SetParams(VehicleDamage, PersonDamage, SplashDamage, DamageRadius, MomentumTransfer);
	}

	return p;
}

function Tick( float dt )
{
	local float MuzzleLightIntensity;
	
	LastHeatTime = Level.TimeSeconds;

	//If the light has been turned on
	if(PersonalWeapon(Weapon) != none && PersonalWeapon(Weapon).bTurnedOnDynLight)
	{
		//If it has been on for FLASHING_TIME, turn it off
		if( PersonalWeapon(Weapon).LightIntensityTimer > FLASHING_TIME )
		{
			PersonalWeapon(Weapon).bTurnedOnDynLight = false;
			PersonalWeapon(Weapon).LightIntensityTimer = 0;
			if(PlayerController(Instigator.Controller) != none && PlayerController(Instigator.Controller).MuzzleFlashLight != none)
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
		}
		else
		{	
			PersonalWeapon(Weapon).LightIntensityTimer += dt;
			MuzzleLightIntensity = 500;  // * SeeSaw( 2.0/ FLASHING_TIME, PersonalWeapon(Weapon).LightIntensityTimer );
			if(PlayerController(Instigator.Controller) != none && PlayerController(Instigator.Controller).MuzzleFlashLight != none)
			{
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightHue = 80;
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightSaturation = 55;
			}
		}
	}

	Super.Tick(dt);
}

function PlayFiring()
{
	Super.PlayFiring();
	GrenadeLauncher(Weapon).PlayFiring();
}

function StopFiring()
{
	Super.StopFiring();
    if(Instigator.IsLocallyControlled())
    {
	    GrenadeLauncher(Weapon).CheckDetonator();
    }
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

	event ModeDoFire()
	{
	}

	event ModeHoldFire() {}
}

simulated function bool AllowFire()
{
	return (Instigator.Health > 0 && Weapon.Ammo[ThisModeNum] != None && Weapon.Ammo[ThisModeNum].AmmoAmount >= AmmoPerFire);
}

defaultproperties
{
     StickyVehicleDamage=20
     StickyPersonDamage=20
     MagVehicleDamage=20
     MagPersonDamage=20
     SplashDamage=100.000000
     DamageRadius=550.000000
     MomentumTransfer=4000.000000
     StickySplashDamage=100.000000
     MagSplashDamage=100.000000
     ProjSpawnOffset=(X=70.000000,Y=14.000000,Z=-22.000000)
     VehicleDamage=50
     PersonDamage=20
     MaxHeatTime=2.000000
     MaxCoolTime=5.000000
     bAnimateThird=False
     AmmoPerFire=1
     RecoilPitch=1000
     TweenTime=0.000000
     FireRate=1.200000
     RecoilTime=0.800000
     BotRefireRate=0.700000
     AutoAim=0.950000
     MaxFireNoiseDist=2000.000000
     FireSound=Sound'PariahWeaponSounds.GL_Fire'
     PreFireAnim="None"
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.GrenadeLauncherAmmo'
     FireForce="GrenadeLauncherFire"
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
}
