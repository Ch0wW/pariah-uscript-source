class VGAssaultFire extends VGInstantFire;

var float		            LastFireTime;
var ()	Sound				WindDownSound;
var ()  class<Emitter>		SmokeEffectClass;
var		Emitter				SmokeEffect;
var		Emitter				PuffEffect;
var ()  class<Emitter>		PuffEffectClass;
var	   bool					bWasFiring;
var	   DavidPuncherFlash	FlashEffect;

// for increasing spread
var float MinSpread, MaxSpread;

function Destroyed()
{
	Super.Destroyed();
	if(SmokeEffect != none)
		SmokeEffect.Kill();
	if(FlashEffect != none)
		FlashEffect.Destroy();
	if(PuffEffect != none)
		PuffEffect.Kill();
}

simulated function Vector GetSpringForce()
{
    return(Normal((VRand() * vect(1,1,0))) * spring_force_applied * (1.0 + (SpreadAttenuate)));
}

function InitEffects()
{
    Super.InitEffects();
	if ( FlashEmitter != None ) 
	{
		Weapon.AttachToBone( FlashEmitter, 'FX1' );
		FlashEmitter.SetRelativeLocation(vect(5, 0, 4) );
	}

	if(FlashEffect == none)
		FlashEffect = Spawn(class'VehicleEffects.bulldog_muzzleflash_1st', self);
		
	if(FlashEffect != none) 
	{
		Weapon.AttachToBone(FlashEffect, 'FX1');
		FlashEffect.SetRelativeLocation(vect(-2, 0, 4) );
	}

	if(SmokeEffect == none && SmokeEffectClass != none)
		SmokeEffect = Spawn(SmokeEffectClass, self);
		
	if(SmokeEffect != none) 
	{
		Weapon.AttachToBone(SmokeEffect, 'FX1');
		SmokeEffect.SetRelativeLocation(vect(0, 0, 2.5) );
	}

	if(PuffEffect == none) 
	{
		PuffEffect = Spawn(PuffEffectClass, self);
		Weapon.AttachToBone(PuffEffect, 'FX1');
		PuffEffect.SetRelativeLocation(vect(10, 0, 4) );
	}
}

function PlayStartHold() {}
function PlayFiring() 
{
    if(bUseForceFeedback)
	    ClientPlayForceFeedback(FireForce); 
}

function PlayFireEnd() {}

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
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
	local Material HitMat;
	local float damageAmount;
	local Material.ESurfaceTypes HitSurfaceType;

	X = Vector(Dir);
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true, , HitMat, true);

    if ( Other != None && Other != Instigator )
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle')) 
			{
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
            else if( Other.IsA('SPPawnShroud') || Other.IsA('SPPawnShroudBlocker') )
            {
                //Brutal hack.. but there's no easy way from TakeDamage to get all the hit effect stuff
                //HitMat.SurfaceType = EST_Metal;
                HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal,
                                        Weapon.GetHitEffectOwner(),HitMat);
            }
			else 
			{
				damageAmount = PersonDamage;
				Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
			}

			if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand()) 
			{
                if(Weapon.Role == ROLE_Authority)
    				HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
				{
					if(Level.Game != None && Level.Game.bSinglePlayer && HitSurfaceType == EST_HeatPipes)
					{
						class'SteamDamageArea'.static.SpawnDamageArea(Weapon.Owner, HitLocation, HitNormal);
					}
					if(PersonalWeapon(Weapon).WecLevel > 2 && FRand() < 0.5)
					{
					    Spawn(class'VehicleEffects.RedImpactScorch',,,HitLocation+HitNormal*3.0,Rotator(HitNormal));
                    }
                    Level.QuickDecal(HitLocation, HitNormal, Other, 4.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
            }
        }
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand())
            {
                if(Weapon.Role == ROLE_Authority)
                    HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;
				if(Other.bStatic)
				{
					if(Level.Game != None && Level.Game.bSinglePlayer && HitSurfaceType == EST_HeatPipes)
					{
						class'SteamDamageArea'.static.SpawnDamageArea(Weapon.Owner, HitLocation, HitNormal);
					}
					if(PersonalWeapon(Weapon).WecLevel > 2 && FRand() < 0.5)
					{
					    Spawn(class'VehicleEffects.RedImpactScorch',,,HitLocation+HitNormal*3.0,Rotator(HitNormal));
                    }
                    Level.QuickDecal(HitLocation, HitNormal, Other, 4.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
            }
        }
	}
	else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }
}


simulated function BeginReload()
{
	If (PuffEffect!=None) 
	{
		Weapon.DetachFromBone(PuffEffect);
	}

    GotoState('Reload');
}


simulated function EndReload()
{
    if(bIsFiring)
    {
        Weapon.ServerStartFire(0);
        GotoState('Firing');
    }
    else
        GotoState('Idle');
}

auto state Idle
{
	event ModeDoFire()
	{
	}
	
    simulated function ModeTick(float dt)
    {
		local float trueDelta;
		
		HeatTime = FClamp(HeatTime - dt, 0.0, MaxHeatTime);
		SpreadAttenuate = HeatTime/MaxHeatTime;
		trueDelta = Level.TimeSeconds - LastHeatTime;
		if(!Pawn(Weapon.Owner).Controller.IsA('AIController') )
		{
			Spread = MinSpread*(1.0-(SpreadAttenuate * SpreadAttenuate))+MaxSpread*(SpreadAttenuate * SpreadAttenuate);
        }
		Super.ModeTick(dt);
	}
	
    function StartFiring()
    {
		GotoState( 'Firing' );
		Weapon.Ammo[0].bRegen=false;
	}

Begin:
	PlayAmbientSound(None);
	if(bWasFiring) 
	{
		Weapon.PlayAnim(FireEndAnim, 1, TweenTime);
		Sleep(0.3);
		Weapon.LoopAnim(Weapon.IdleAnim, Weapon.IdleAnimRate, TweenTime);
		bWasFiring = false;
	}
}


simulated state Firing
{
    simulated function BeginState()
    {
		bWasFiring = true;
		Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);

		// start up required effects
		if(SmokeEffect != none)
			bulldog_muzzlesmoke_1st(SmokeEffect).StartSmoke();

		if(FlashEffect != none)
			bulldog_muzzleflash_1st(FlashEffect).StartFlash();

		if(PuffEffect != none)
		{
			Weapon.AttachToBone(PuffEffect, 'FX1');
			PuffEffect.SetRelativeLocation(vect(10, 0, 4) );			
			assault_silenced_muzzlepuff(PuffEffect).StartPuff();
		}
	}

	function EndState()
	{
		local PlayerController PC;

		PlayAmbientSound(WindDownSound);
		PC = PlayerController(Instigator.Controller);
		if ( PC != None && PC.MuzzleFlashLight != None )
		{
			PC.MuzzleFlashLight.LightBrightness = 0;
		}
		PersonalWeapon(Weapon).LightIntensityTimer = 0;

		if(SmokeEffect != none) {
			bulldog_muzzlesmoke_1st(SmokeEffect).StopSmoke();
		}

		if(FlashEffect != none)
			bulldog_muzzleflash_1st(FlashEffect).StopFlash();

		if(PuffEffect != none)
			assault_silenced_muzzlepuff(PuffEffect).StopPuff();

		PlayAmbientSound(none);
	}

    simulated function ModeTick(float dt)
    {
		local float trueDelta;
		local float MuzzleLightIntensity;
		local PlayerController PC;
		
		trueDelta = Level.TimeSeconds - LastHeatTime;

		if( bIsFiring ) 
		{
			PC = PlayerController(Instigator.Controller);

			if ( PC != None && PC.MuzzleFlashLight != None )
			{
				//Change the intensity of the attached light
				PersonalWeapon(Weapon).LightIntensityTimer += dt;
				MuzzleLightIntensity = 700*SeeSaw( 10.0, PersonalWeapon(Weapon).LightIntensityTimer );
				PC.MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;			
				PC.MuzzleFlashLight.LightSaturation = 255;
			}
		}
		
        Super.ModeTick(dt);
        
        HeatTime = FClamp(HeatTime + dt, 0.0, MaxHeatTime);
		SpreadAttenuate = HeatTime/MaxHeatTime;

		// increase spread as firing continues
		if(!Pawn(Weapon.Owner).Controller.IsA('AIController') )
		{
			Spread = MinSpread*(1.0-(SpreadAttenuate * SpreadAttenuate))+MaxSpread*(SpreadAttenuate * SpreadAttenuate);
			if(PlayerController(Pawn(Weapon.Owner).Controller).bZoomed)
			{
				Spread *= 0.3;
			}
			if(Pawn(Weapon.Owner).bIsCrouched)
			{
			    Spread *= 0.5;
			}
		}
	}
    function StopFiring()
    {
		GotoState('Idle');
    }
}

simulated state Reload
{
	simulated function bool AllowFire()
	{
        return true;
    }

	simulated function BeginState()
	{
		bWasFiring = false;
	}
	
	function EndState()
	{
		NextFireTime = Level.TimeSeconds;
		if(Weapon.ClientState != WS_Lowered)
			Weapon.LoopAnim(Weapon.IdleAnim, Weapon.IdleAnimRate, TweenTime);
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
	
    simulated function ModeTick(float dt)
    {
        HeatTime = FClamp(HeatTime - dt, 0.0, MaxHeatTime);
		SpreadAttenuate = HeatTime/MaxHeatTime;
	}
}

defaultproperties
{
     MinSpread=0.050000
     MaxSpread=0.150000
     WindDownSound=Sound'PariahWeaponSounds.hit.AR_FireLoopEnd'
     SmokeEffectClass=Class'VehicleEffects.bulldog_muzzlesmoke_1st'
     PuffEffectClass=Class'VehicleEffects.assault_silenced_muzzlepuff'
     Momentum=500.000000
     TracerFreq=0.660000
     DamageType=Class'VehicleWeapons.VGAssaultDamage'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=10
     PersonDamage=16
     MaxHeatTime=2.000000
     MaxCoolTime=3.000000
     spring_mass=2.000000
     spring_stiffness=200.000000
     spring_damping=7.000000
     spring_force_applied=50.000000
     bAnimateThird=False
     UseSpringImpulse=True
     AmmoPerFire=1
     FireAnimRate=2.000000
     FireRate=0.100000
     BotRefireRate=0.990000
     aimerror=500.000000
     Spread=0.050000
     MaxFireNoiseDist=2500.000000
     FireSound=Sound'PariahWeaponSounds.hit.soul_bulldog1'
     PreFireAnim="None"
     FireAnim="FireLoop"
     AmmoClass=Class'VehicleWeapons.VGAssaultRifleAmmo'
     FireForce="VGAssaultRifleFire"
     PreFireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Random
     bModeExclusive=False
     bPawnRapidFireAnim=True
}
