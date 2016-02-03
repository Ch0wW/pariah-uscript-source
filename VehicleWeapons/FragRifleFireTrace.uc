/*
	FragRifleFireTrace.uc
	Desc: the rifle shots move to their destination instantly
	Author: refurbishing by xmatt and further so by mthorne
*/

class FragRifleFireTrace extends VGInstantFire;

const CORK_EMIT_TIME = 0.2;
const FLASHING_TIME = 0.15;

var	bool	bMomentum;

var FragRifleMuzzleFlash FlashEffect;
var array<FragPiece> Concentrators;

function ModeTick( float dt )
{
	local float MuzzleLightIntensity;
	local PlayerController PC;

    if ( Weapon.ClientState == WS_Lowered )
    {
        return;
    }

	LastHeatTime = Level.TimeSeconds;

	//If the light has been turned on
	if(PersonalWeapon(Weapon) != none && PersonalWeapon(Weapon).bTurnedOnDynLight)
	{
	    PC = PlayerController(Instigator.Controller);
		//If it has been on for FLASHING_TIME, turn it off
		if( PersonalWeapon(Weapon).LightIntensityTimer > FLASHING_TIME )
		{
			PersonalWeapon(Weapon).bTurnedOnDynLight = false;
			PersonalWeapon(Weapon).LightIntensityTimer = 0;
			if(PC != None && PC.MuzzleFlashLight != none)
				PC.MuzzleFlashLight.LightBrightness = 0;
		}
		else
		{	
			MuzzleLightIntensity = 500 ; 
			PersonalWeapon(Weapon).LightIntensityTimer += dt;
			if(PC != None && PC.MuzzleFlashLight != none)
			{
				PC.MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
				PC.MuzzleFlashLight.LightSaturation = 255;
			}
		}
	}
	Super.ModeTick(dt);
}

function FireConcentrator()
{
    local Vector StartTrace;
    local Vector HitLocation;
    local Vector HitNormal;
    local Vector X,Y,Z;
    local Actor Other;
    local Vector End;
    local Material HitMat;
    local int i;
    local Rotator R;
    local bool didAttack;
    
    if(PersonalWeapon(Weapon).WecLevel < 2)
    {
        return;
    }
    
    // the to-hit trace always starts right in front of the eye
	R = Weapon.ThirdPersonActor.Rotation;
	if(Weapon.bIndependantPitch) 
	{
		R.Pitch += Weapon.RealPitch;
	}
	GetAxes( R, X, Y, Z );
	StartTrace = Weapon.GetFireStart( X, Y, Z );
    R = AdjustAim(StartTrace, AimError);
    
    End = StartTrace + 8000.0 * Vector(R);
    
    Other = Weapon.Instigator.Trace(HitLocation, HitNormal, End, StartTrace, true, , HitMat);

    if ( Other != None && Other != Instigator )
    {
		if(Other.bWorldGeometry)
        {
            // lay probe
            Concentrators.Length = Concentrators.Length + 1;
            if(PersonalWeapon(Weapon).WecLevel > 2)
            {
                Concentrators[Concentrators.Length - 1] = Spawn(class'TitaniumFragPiece',Weapon.Instigator,,HitLocation + HitNormal * 8.0,Rotator(HitNormal));
            }
            else
            {
                Concentrators[Concentrators.Length - 1] = Spawn(class'FragPiece',Weapon.Instigator,,HitLocation + HitNormal * 8.0,Rotator(HitNormal));
            }
            if(Concentrators[Concentrators.Length - 1] == None)
            {
                Concentrators.Length = Concentrators.Length - 1;
            }
        }
        else
        {
            // concentrate!
            for(i = 0; i < Concentrators.Length; ++i)
            {
                if(Concentrators[i] != None)
                {
                    didAttack = true;
                    Concentrators[i].Attack(HitLocation + 30.0 * Vector(R));
                }
            }
            if(didAttack)
            {
                // spawn pulse actor at hit location
            }
            Concentrators.Length = 0;
        }
    }
}

simulated function Vector GetSpringForce()
{
    return((vect(1.0,0.0,0.0) + ( VRand() * vect(0.2,0.2,0) )) * spring_force_applied);
}

function ModeDoFire()
{
	if( AllowFire() )
	{
		//Turn on the weapon dynamic light (not if it is a bot though)
		if( Instigator.Controller.IsA('PlayerController') )
			PersonalWeapon(Weapon).bTurnedOnDynLight = true;

		if( FlashEffect != none )
			FlashEffect.StartFlash();
	}
	Super.ModeDoFire();
}

function DoFireEffect()
{                    
	Super.DoFireEffect();

	//Turn on the weapon dynamic light and pop shells (not if it is a bot though)
	if( Instigator.Controller.IsA('PlayerController') )
	{
		PersonalWeapon(Weapon).bTurnedOnDynLight = true;
		FireConcentrator();
	}
}

function StopFiring()
{
	local FragRifleAttachment Attachment;
    Attachment = FragRifleAttachment(Weapon.ThirdPersonActor);
	Super.StopFiring();
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
	local Material HitMat;
	local Material.ESurfaceTypes HitSurfaceType;

	X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat, true);

    if ( Other != None && Other != Instigator )
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle'))
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			else
				Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*X, DamageType);
			if(Other.IsA('StaticMeshActor') && HitEffectClass != None && HitEffectProb >= FRand() )
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
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 2 );
				}
			}
        }
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
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
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 2 );
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


function InitEffects()
{
    Super.InitEffects();
    
	//Attach the muzzle flash
	if ( FlashEmitter != None )
		Weapon.AttachToBone( FlashEmitter, 'FX1' );
	
	if(FlashEffect == none)
		FlashEffect = Spawn(class'VehicleEffects.FragRifleMuzzleFlash', self);
	if(FlashEffect != none) {
		Weapon.AttachToBone(FlashEffect, 'FX1');
		FlashEffect.SetRelativeLocation(vect(-2, 0, 5) );
	}
}


simulated function Destroyed()
{
	if(FlashEffect != none) {
		FlashEffect.Destroy();
		FlashEffect = none;
	}

	Super.Destroyed();
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

	event ModeDoFire(){}
}

function PlayFiring()
{
    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
        {
            Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
        }
        else
        {
			FragRifle(Weapon).PlayFireAnim(FireAnim, FireAnimRate, TweenTime);
        }
    }
    else
    {
			FragRifle(Weapon).PlayFireAnim(FireAnim, FireAnimRate, TweenTime);
    }
    if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}
    FireCount++;
}

defaultproperties
{
     TracesPerFire=7
     Momentum=1000.000000
     DamageType=Class'VehicleWeapons.FragRifleDamage'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     VehicleDamage=20
     PersonDamage=20
     MaxHeatTime=4.500000
     MaxCoolTime=5.000000
     spring_mass=2.000000
     spring_stiffness=200.000000
     spring_damping=8.000000
     spring_force_applied=300.000000
     bAnimateThird=False
     UseSpringImpulse=True
     AmmoPerFire=1
     FireRate=1.000000
     BotRefireRate=0.990000
     Spread=0.100000
     MaxFireNoiseDist=2500.000000
     FireSound=Sound'PariahWeaponSounds.hit.FR_Fire3'
     ReloadSound=Sound'PariahWeaponSounds.FR_Reload'
     FireLoopAnim="None"
     AmmoClass=Class'VehicleWeapons.FragRifleAmmo'
     FireForce="FragRifle"
     SpreadStyle=SS_RadBased
     bWaitForRelease=True
}
