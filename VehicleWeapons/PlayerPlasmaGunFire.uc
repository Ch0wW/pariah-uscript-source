class PlayerPlasmaGunFire extends VGProjectileFire;

var		float	FlashingTime; //Weapon dynamic light flash time 
var ()  Sound	ChargingSound;

var PlasmaChargeEffect chargeEffect;	// effect for charging the plasma gun

var bool bEnhanced;

// damage values
var	(Damage) float SplashDamage;	//amount of splash damage, set to 0 for none
var	(Damage) float DamageRadius;        
var (Damage) float MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var (Damage) float MaxVehicleDamage;
var (Damage) float MaxPersonDamage;
var (Damage) float MaxSplashDamage;
var (Damage) float MaxDamageRadius;
var (Damage) int ChainVehicleDamage;
var (Damage) int ChainPersonDamage;
var (Damage) float ChainSplashDamage;
var (Damage) float ChainDamageRadius;

var () int ShotsPerHold;
var int ShotsThisHold;
var float CoolOff;
var float CoolOffTime;
var float PreChargeTime;
var float ChargeTime;
var float ChargeUpAccum;

simulated function PostBeginPlay()
{
	//The flashing time must consider the firing rate
	FlashingTime = 0.8 * FireRate;
	Super.PostBeginPlay();
}

function InitEffects()
{
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'FX1');

	// spawn the charging effect if there is none already
	if(chargeEffect == none)
	{
		chargeEffect = spawn(class'PlasmaChargeEffect');
		if(chargeEffect != none) 
		{
			Weapon.AttachToBone(chargeEffect, 'EMPLens');
			chargeEffect.SetRelativeLocation(vect(-1.9, -5.5, -5) );
            ChargeEffect.bHidden = true;
		}
	}
}

simulated function bool AllowFire()
{
    if(ShotsThisHold >= ShotsPerHold || CoolOff > 0.0)
    {
        return(false);
    }
    return(Super.AllowFire());
}

simulated function Vector GetSpringForce()
{
	local Vector kick;
	if(!AllowFire())
	{
	    return(vect(0,0,0));
	}
	kick.X = 0.2 + 0.4 * FRand();
	kick.Y = 0.3 + 0.6 * FRand();
	kick.Z = 0;
    return(kick * spring_force_applied);
}

simulated function UpdateChargeUp(float dt)
{
    if(HoldTime <= PreChargeTime)
    {
        dt = -dt;
    }

    ChargeUpAccum = FClamp(ChargeUpAccum + dt/(ChargeTime - PreChargeTime), 0.0, 1.0);
    if(ChargeUpAccum <= 0)
    {
        Weapon.AmbientSound = None;
    }
    else
    {
        Weapon.AmbientSound = ChargingSound;
    }
    Weapon.SoundVolume = ChargeUpAccum * 128;
    Weapon.SoundPitch = 8.0 + ChargeUpAccum * 64.0;
    if(chargeEffect != None)
    {
        chargeEffect.SetChargeScale(ChargeUpAccum);
    }
}

simulated function FireSpecialBlob()
{
    local Sound S;

    S = FireSound;
    FireSound = Sound'PariahWeaponSounds.PlasmaRifleFireA';
    ShotsThisHold = 0;
    ChargeUpAccum = 0.0; 
    CoolOff = 0.0;
    Super.ModeDoFire();
    ShotsThisHold = 0;
    if (Weapon.Ammo[0] != None && Weapon.Role == ROLE_Authority)
    {
        Weapon.Ammo[0].UseAmmo(AmmoClip(Weapon.Ammo[0]).RemainingMagAmmo, true);
    }
    CoolOff = CoolOffTime;
    FireSound = S;
}

simulated function ModeTick(float dt)
{
	local float MuzzleLightIntensity;
    local PersonalWeapon PWeapon;
    
    PWeapon = PersonalWeapon(Weapon);

	if(!IsFiring())
    {
        if(ShotsThisHold > 0)
        {
            ShotsThisHold = 0;
            CoolOff = CoolOffTime;
        }
        if(HoldTime >= ChargeTime && PWeapon.WECLevel >= 1)
        {
            FireSpecialBlob();
        }
        HoldTime = 0.0;
    }
    
    if(IsFiring() && ShotsThisHold > 0)
    {
        if(PWeapon.WECLevel >= 1 && HoldTime < ChargeTime && HoldTime + dt >= ChargeTime)
        {
            // ready!
            Weapon.PlayOwnedSound(Sound'PariahWeaponSounds.PR_ReloadPartE');
        }
        HoldTime = FClamp(HoldTime + dt, 0.0, ChargeTime);
    }
    
    if(PWeapon.WECLevel >= 1)
    {
        UpdateChargeUp(dt);
    }
    
    if(CoolOff > 0.0)
    {
        CoolOff -= dt;
    }

	//If the light has been turned on
	if( PWeapon.bTurnedOnDynLight )
	{
		//If it has been on for FLASHING_TIME, turn it off
		if( PWeapon.LightIntensityTimer > FlashingTime )
		{
			PWeapon.bTurnedOnDynLight = false;
			PWeapon.LightIntensityTimer = 0;
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
		}
		else
		{
			PWeapon.LightIntensityTimer += dt;
			MuzzleLightIntensity = 600; // * SeeSaw( 2.0 / FlashingTime, PWeapon.LightIntensityTimer );
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightHue = 155;
			PlayerController(Instigator.Controller).MuzzleFlashLight.LightSaturation = 55;
		}
	}
	Super.ModeTick(dt);
}

simulated function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;
	local PlayerPlasma pp;
	
	ShotsThisHold++;

    p = PlayerPlasmaGun(weapon).SpawnProjectile(Start, Dir);

	pp = PlayerPlasma(p);
	if(pp == none)
		return none;

	if(pp.IsA('PlayerPlasmaBall') )
		pp.SetParams(ChainVehicleDamage, ChainPersonDamage, ChainSplashDamage, ChainDamageRadius, MaxVehicleDamage, MaxPersonDamage, MaxSplashDamage, MaxDamageRadius, MomentumTransfer);
	else if(pp.IsA('PlayerPlasma') )
		pp.SetParams(VehicleDamage, PersonDamage, SplashDamage, DamageRadius, MaxVehicleDamage, MaxPersonDamage, MaxSplashDamage, MaxDamageRadius, MomentumTransfer);

	return p;
}

state Reload
{
    simulated function bool AllowFire()
    {
        return true;
    }

	simulated function BeginState()
	{
        NextFireTime = Level.TimeSeconds + 4.5;
	}

	simulated function EndState()
	{
		NextFireTime = Level.TimeSeconds;
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if(chargeEffect != none) 
	{
		chargeEffect.Destroy();
		chargeEffect = none;
	}
}

defaultproperties
{
     ChainVehicleDamage=20
     ChainPersonDamage=15
     ShotsPerHold=3
     SplashDamage=8.000000
     DamageRadius=240.000000
     MomentumTransfer=1000.000000
     MaxVehicleDamage=50.000000
     MaxPersonDamage=40.000000
     MaxSplashDamage=30.000000
     MaxDamageRadius=400.000000
     ChainSplashDamage=12.000000
     ChainDamageRadius=100.000000
     CoolOffTime=0.250000
     PreChargeTime=0.750000
     ChargeTime=1.500000
     ChargingSound=Sound'PariahWeaponSounds.hit.PlasmaRifleChargeFireA'
     ProjSpawnOffset=(Y=10.000000,Z=-10.000000)
     VehicleDamage=16
     PersonDamage=8
     MaxHeatTime=5.000000
     MaxCoolTime=3.500000
     spring_mass=2.000000
     spring_stiffness=50.000000
     spring_damping=7.000000
     spring_force_applied=80.000000
     bAnimateThird=False
     bNoAutoAim=True
     UseSpringImpulse=True
     AmmoPerFire=1
     FireAnimRate=0.750000
     TweenTime=0.010000
     FireRate=0.100000
     BotRefireRate=0.700000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireSound=Sound'PariahWeaponSounds.AI_Weapons.PR_Fire'
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.PlayerPlasmaGunAmmo'
     ProjectileClass=Class'VehicleWeapons.PlayerPlasma'
     FlashEmitterClass=Class'VehicleEffects.PlasmaMuzzleFlash'
     FireForce="PlayerPlasmaGunFire"
}
