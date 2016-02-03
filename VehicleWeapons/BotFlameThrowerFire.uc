class BotFlameThrowerFire extends VGInstantFire;

var float		LastFireTime;

var DavidFlamethrower FlameEffect;
var DavidFlameThrowerOff GotALight;
var DavidFlameThrowerDistortion Distort;

function Destroyed()
{
	Super.Destroyed();

	if(FlameEffect != none) {		
        FlameEffect.Destroy();
		FlameEffect = none;
	}
	if(GotALight != none) {
		GotALight.Destroy();
		GotALight = none;
	}
	if(Distort != none) {
		Distort.Destroy();
		Distort = none;
	}
}

function InitEffects()
{
    Super.InitEffects();

	// init the flame thrower effect
	if(FlameEffect == none)
		FlameEffect = Spawn(class'VehicleEffects.DavidFlamethrower', self);
	if(FlameEffect != none) {
		Weapon.AttachToBone(FlameEffect, 'FX1');
		FlameEffect.SetRelativeLocation(vect(-2, 0, 4) );
		FlameEffect.bHidden = true;
		FlameEffect.bPaused = true;
	}
	// init the flame thrower distortion effect
//	if(Distort == none)
//		Distort = Spawn(class'VehicleEffects.DavidFlamethrowerDistortion', self);
	if(Distort != none) {
		Weapon.AttachToBone(Distort, 'FX1');
		Distort.SetRelativeLocation(vect(-2, 0, 4) );
		Distort.bHidden = true;
		Distort.bPaused = true;
	}

	// init the light effect (on when the flame thrower effect is off)
	if(GotALight == none)
		GotALight = Spawn(class'VehicleEffects.DavidFlameThrowerOff', self);
	if(GotALight != none) {
		Weapon.AttachToBone(GotALight, 'FX1');
		GotALight.SetRelativeLocation(vect(-2, 0, 4) );
	}
}

simulated function bool CanTarget(Pawn P)
{
	if(P == none || P == Instigator)
		return false;

	if(P.IsA('MostlyDeadPawn') )
		return false;

    return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;//, Target;
	local Material HitMat;
//	local Name boneName;
	local float damageAmount;//boneDist, //, closest;
	local Material.ESurfaceTypes HitSurfaceType;
	local int n;

	for(n = 0; n < 3; n++) {

	if(n == 1)
		Dir.Yaw -= 1500;
	if(n == 2)
		Dir.Yaw += 3000;

	X = Vector(Dir);
//	Start.Z -= 15;
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	if ( Other != None && Other != Instigator )
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle')) {
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			else {
				damageAmount = PersonDamage;

				if(InStr(GetMeshName(), "Keeper") >= 0)
					// keepers count as vehicles rather than people
					damageAmount = VehicleDamage;

				Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
			}

//			if(Other.IsA('StaticMeshActor') && HitEffectClass != None && HitEffectProb >= FRand() && !bExplosive) {
			if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand() ) {
//				HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
//				if(HitMat != none)
//					HitSurfaceType = HitMat.SurfaceType;
//				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
			}
		}
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
            {
//                HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
//				if(HitMat != none)
//					HitSurfaceType = HitMat.SurfaceType;
//				else
					HitSurfaceType = EST_Default;
				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
            }
        }
	}
	else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

	if(Other != none && Other.IsA('Pawn') ) {
		// set pawn on fire
		if(Other.IsA('VGPawn') )
			VGPawn(Other).FireInstigator = Instigator;
		Pawn(Other).SetOnFire();
	}

	}
}

simulated function ModeTick(float dt)
{
	local float trueDelta;

	trueDelta = Level.TimeSeconds - LastHeatTime;

	Super.ModeTick(dt);
}

function StartFiring()
{
	GotoState( 'Firing' );
	Weapon.Ammo[0].bRegen=false;
}

simulated state Firing
{
    simulated function BeginState()
    {
		Weapon.PlaySound(PreFireSound);

		if(FlameEffect != none) 
		{
			FlameEffect.bHidden = false;
			FlameEffect.bPaused = false;
		}
		if(Distort != none) 
		{
			Distort.bHidden = false;
			Distort.bPaused = false;
		}

		// disable the light effect
		if(GotALight != none) {
			GotALight.bHidden = true;
			GotALight.bPaused = true;
		}
	}

	function EndState()
	{
        Weapon.StopOwnedSound(FireSound);        
		Weapon.PlaySound(FireEndSound);

		if(FlameEffect != none) {
			FlameEffect.bHidden = true;
			FlameEffect.bPaused = true;
		}
		if(Distort != none) {
			Distort.bHidden = true;
			Distort.bPaused = true;
		}

		// turn the light back on, on, on!
		if(GotALight != none) {
			GotALight.bHidden = false;
			GotALight.bPaused = false;
		}
	}

    simulated function ModeTick(float dt)
    {
		local float trueDelta;

		trueDelta = Level.TimeSeconds - LastHeatTime;

        Super.ModeTick(dt);

	}
    function StopFiring()
    {
		GotoState('');
    }
}

simulated state Reload
{
	simulated function BeginState()
	{
		Weapon.PlayIdle();
	}
	
	function EndState()
	{
		NextFireTime = Level.TimeSeconds;
	}

	event ModeDoFire()
	{
		local AIController AIC;
		AIC = AIController(Instigator.Controller);

        if ( AIC != None )
		{
			AIC.StopFiring();
		}
	}
    simulated function ModeTick(float dt) {}
}

simulated function bool AllowFire()
{
	return true;
}

function PlayFireEnd()
{
    // Don't do anything stupid matt!
}

defaultproperties
{
     TraceRange=1000.000000
     Momentum=500.000000
     TracerFreq=0.000000
     DamageType=Class'VehicleWeapons.VGAssaultDamage'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     VehicleDamage=5
     PersonDamage=5
     MaxHeatTime=5.000000
     MaxCoolTime=3.000000
     bAnimateThird=False
     AmmoPerFire=1
     RecoilPitch=300
     FireRate=0.150000
     RecoilTime=0.200000
     BotRefireRate=0.990000
     aimerror=500.000000
     Spread=0.060000
     MaxFireNoiseDist=2500.000000
     PreFireSound=Sound'PariahWeaponSounds.hit.FlameThrowerIgnite'
     FireSound=Sound'PariahWeaponSounds.hit.FlameThrowerFireLoop'
     FireEndSound=Sound'PariahWeaponSounds.hit.FlameThrowerStop'
     PreFireAnim="None"
     FireAnim="FireLoop"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="VGAssaultRifleFire"
     PreFireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Random
     bModeExclusive=False
     bPawnRapidFireAnim=True
}
