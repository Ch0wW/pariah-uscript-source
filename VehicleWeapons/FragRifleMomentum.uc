class FragRifleMomentum extends VGInstantFire;

const CORK_EMIT_TIME = 0.2;
const FLASHING_TIME = 0.2;

var() class<Emitter> ExplosionClass;
var() class<Emitter> ExplosionClassMP;

var FragRifleMuzzleFlash FlashEffect;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Level.Game == none || !Level.Game.bSinglePlayer) {
		// use multiplayer effect rather than single player
		ExplosionClass = ExplosionClassMP;
	}
}

function ModeTick( float dt )
{
	local float trueDelta;
	local float MuzzleLightIntensity;

	trueDelta = Level.TimeSeconds - LastHeatTime;

	//If the light has been turned on
	if(PersonalWeapon(Weapon) != none && PersonalWeapon(Weapon).bTurnedOnDynLight)
	{
		//If it has been on for FLASHING_TIME, turn it off
		if( PersonalWeapon(Weapon).LightIntensityTimer > FLASHING_TIME )
		{
			PersonalWeapon(Weapon).bTurnedOnDynLight = false;
			PersonalWeapon(Weapon).LightIntensityTimer = 0;
			if(PlayerController(Instigator.Controller).MuzzleFlashLight != none)
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
		}
		else
		{	
			PersonalWeapon(Weapon).LightIntensityTimer += dt;
			MuzzleLightIntensity = 300 * SeeSaw( 2.0/ FLASHING_TIME, PersonalWeapon(Weapon).LightIntensityTimer );
			if(PlayerController(Instigator.Controller).MuzzleFlashLight != none)
				PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
		}
	}

	Super.ModeTick(dt);
}

function ModeDoFire()
{
	local bool bAllowed;

	bAllowed = AllowFire();
	Super.ModeDoFire();

	if(bAllowed) {
		//Turn on the weapon dynamic light (not if it is a bot though)
		if( Instigator.Controller.IsA('PlayerController') )
			PersonalWeapon(Weapon).bTurnedOnDynLight = true;

		if(FlashEffect != none) {
			FlashEffect.StartFlash();
		}
	}
}

function DoFireEffect()
{                    
	Super.DoFireEffect();

	//Turn on the weapon dynamic light and pop shells (not if it is a bot though)
	if( Instigator.Controller.IsA('PlayerController') )
	{
		PersonalWeapon(Weapon).bTurnedOnDynLight = true;
	}
}

function StopFiring()
{
	local FragRifleAttachment Attachment;
    Attachment = FragRifleAttachment(Weapon.ThirdPersonActor);

	Super.StopFiring();
}


function DrawMuzzleFlash(Canvas Canvas)
{
    Super.DrawMuzzleFlash(Canvas);
}

simulated function WECLevelUp(int level)
{
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
	local Material HitMat;
	local Material.ESurfaceTypes HitSurfaceType;

	X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

    if ( Other != None && Other != Instigator )
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle'))
			{
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			else
			{
				Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			if(Other.IsA('StaticMeshActor') && HitEffectClass != None && HitEffectProb >= FRand() )
			{
				HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 2 );
			}
        }
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
            {
                HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 2 );
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
	simulated function ModeTick(float dt)
    {
//		if(Weapon.Ammo[0].CheckReload() )
//			Weapon.DoReload();
	}
}

defaultproperties
{
     ExplosionClass=Class'VehicleEffects.VGAssaultExplosion'
     Momentum=1000.000000
     DamageType=Class'VehicleWeapons.FragRifleDamageMomentum'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=6
     PersonDamage=6
     bAnimateThird=False
     AmmoPerFire=1
     RecoilPitch=400
     FireRate=1.000000
     RecoilTime=0.300000
     BotRefireRate=0.990000
     Spread=0.100000
     MaxFireNoiseDist=2500.000000
     FireSound=Sound'PariahWeaponSounds.hit.FR_Fire3'
     ReloadSound=Sound'PariahWeaponSounds.FR_Reload'
     FireLoopAnim="None"
     AmmoClass=Class'VehicleWeapons.FragRifleAmmo'
     FireForce="VGAssaultRifleFire"
     SpreadStyle=SS_Line
     bWaitForRelease=True
}
