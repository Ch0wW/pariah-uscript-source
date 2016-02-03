class VGRocketLauncherFire extends VGProjectileFire;

#exec OBJ LOAD File="DC_MiscAmbience.uax"

const FLASHING_TIME = 0.3;
var() Name AltFireAnim;
var() float AltFireAnimRate;

// damage parameters
var (Damage) float SplashDamage;
var (Damage) float DamageRadius;
var (Damage) float MomentumTransfer;
var bool LastFire;

function CheckAcquireLock()
{
    local VGRocketLauncher rl;
    local vector HitLocation, HitNormal, X, Y, Z, projStart;
    local actor HitActor;
    
    rl = VGRocketLauncher(Weapon);
        
    GetAxes(Instigator.Controller.Rotation, X,Y,Z);
    projStart = GetFireStart(X,Y,Z);
    HitActor = Trace(HitLocation, HitNormal, projStart + X * 10000, projStart, true);
    if(HitActor != None && rl.CanLockOnTo(HitActor))
    {
        rl.AddLockOn(HitActor);
    }   
}

event ModeHoldFire()
{
    Super.ModeHoldFire();
	Weapon.Instigator.PlayOwnedSound(Sound'PariahWeaponSounds.RocketClick');
}

function UpdateLight(float dt)
{
	local float MuzzleLightIntensity;

    //If the light has been turned on
	if( !PersonalWeapon(Weapon).bTurnedOnDynLight || PlayerController(Instigator.Controller).MuzzleFlashLight == None)
	{
	    return;
	}
	//If it has been on for FLASHING_TIME, turn it off
	if( PersonalWeapon(Weapon).LightIntensityTimer > FLASHING_TIME )
	{
		PersonalWeapon(Weapon).bTurnedOnDynLight = false;
		PersonalWeapon(Weapon).LightIntensityTimer = 0;
		PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
	}
	else
	{	
		MuzzleLightIntensity = 800 - PersonalWeapon(Weapon).LightIntensityTimer *2500 ;
		PersonalWeapon(Weapon).LightIntensityTimer += dt;
		PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
		PlayerController(Instigator.Controller).MuzzleFlashLight.LightSaturation = 255;
	}
}

function ModeTick(float dt)
{
	if(LastFire == false && bIsFiring)
	{
	    LastFire = true;
	}
	
	if(Instigator.IsLocallyControlled())
    {
	    if(bIsFiring)
	    {
	        AmbientSound = Sound'DC_MiscAmbience.Weapons.RL_WarningD';
        }
        else
        {
            AmbientSound = None;
        }
	}
	
	if(bIsFiring && VGRocketLauncher(Weapon).ShouldCheckLockOn())
	{
	    CheckAcquireLock();
	}

    UpdateLight(dt);
    
	Super.ModeTick(dt);
}

simulated function Vector GetSpringForce()
{
    return((vect(1,0.4,0) + VRand() * 0.2) * spring_force_applied);
}

function PlayFiring()
{
    if (VGRocketLauncher(Weapon).HasLocks())
    {
		Weapon.PlayAnim(AltFireAnim, AltFireAnimRate, TweenTime);
    }
    else
    {
        Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    }

	ClientPlayForceFeedback(FireForce);  // jdf
    LastFire = false;
    FireCount++;
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RedRocket rr;

    if(Weapon.Role < ROLE_Authority) return None;

	rr = RedRocket(VGRocketLauncher(Weapon).SpawnProjectile(Start, Dir));
	//Turn on the weapon dynamic light and pop shells (not if it is a bot though)
	if( Instigator.Controller.IsA('PlayerController') )
		PersonalWeapon(Weapon).bTurnedOnDynLight = true;
	if ( rr != None )
	{
		rr.SetParams(VehicleDamage, PersonDamage, SplashDamage, DamageRadius, MomentumTransfer);
	}

    return rr;
}

state Reload
{
	simulated function BeginState()
	{
        bIsFiring = false;
        HoldTime = 0;
	}
	simulated function EndState()
	{
	}

	simulated function ModeTick(float dt)
    {
        UpdateLight(dt);
        AmbientSound = None;
 	}

    function bool AllowFire()
    {
        return false;
    }
}

function PlayFireEnd()
{
}

defaultproperties
{
     AltFireAnimRate=1.000000
     SplashDamage=100.000000
     DamageRadius=550.000000
     MomentumTransfer=5000.000000
     AltFireAnim="AltFire"
     ProjSpawnOffset=(X=60.000000,Y=25.000000,Z=-12.000000)
     VehicleDamage=150
     PersonDamage=40
     spring_mass=1.400000
     spring_stiffness=70.000000
     spring_damping=15.200000
     spring_force_applied=800.000000
     bAnimateThird=False
     UseSpringImpulse=True
     AmmoPerFire=1
     TweenTime=0.010000
     FireRate=3.500000
     MaxHoldTime=2.000000
     BotRefireRate=0.700000
     WarnTargetPct=0.900000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireSound=Sound'PariahWeaponSounds.hit.Soulrocket'
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGRocketLauncherAmmo'
     ProjectileClass=Class'VehicleWeapons.RedRocket'
     FireForce="VGRocketLauncherFire"
     bFireOnRelease=True
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     SoundPitch=96
}
