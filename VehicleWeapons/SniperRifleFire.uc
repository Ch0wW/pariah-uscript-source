class SniperRifleFire extends VGInstantFire;

const FLASHING_TIME = 0.15;

var float       LastFireTime;

var ()  float               HeadShotRadius;
var ()  float               HeadShotDamage;
var ()  class<Emitter>      SmokeEffectClass;
var     Emitter             SmokeEffect;
var    bool                 bZoomed;            // are we zoomed?
var    bool                 bOneShotKill;       // allow one-shot kill when zoomed
var    bool                 bWasFiring;
var SniperRifleMuzzleFlash FlashEffect;

// upgrades to the assault rifle
var Actor LaserTarget;
var StaticMesh LaserTargetMesh;

// for increasing spread
var float MinSpread, MaxSpread;

function Destroyed()
{
    Super.Destroyed();
    if(SmokeEffect != none)
        SmokeEffect.Kill();
    if(FlashEffect != none)
        FlashEffect.Destroy();
    if(LaserTarget != none)
        LaserTarget.Destroy();
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
        FlashEffect = Spawn(class'VehicleEffects.SniperRifleMuzzleFlash', self);
    if(FlashEffect != none) {
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
}

function FlashMuzzleFlash()
{
    Super.FlashMuzzleFlash();
}

function PlayPreFire()
{
    if( bUseForceFeedback )
    {
        ClientPlayForceFeedback(PreFireForce);
    }
}

function PlayStartHold() {}

simulated function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator Aim;
    local vector X,Y,Z;

    if(Level.NetMode == NM_Client)
        return;

    if(Instigator.Controller.IsA('PlayerController') ) {
        // if controlled by the player we need to check if we're zoomed
        if(PlayerController(Instigator.Controller).bZoomed) {
            // handle zoomed firing
            PersonalWeapon(Weapon).bTurnedOnDynLight = true;

            MakeFireNoise();

            GetAxes(Instigator.Rotation,X,Y,Z);
            StartTrace = Weapon.GetFireStart(X,Y,Z);
            Aim = Instigator.Controller.Rotation;

            DoTrace(StartTrace, Aim);
        }
        else
            Super.DoFireEffect();
    }
    else
        Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local Material HitMat;
    local float damageAmount;
    local Material.ESurfaceTypes HitSurfaceType;

    X = Vector(Dir);
//  Start.Z -= 15;
    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat, true);

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
                damageAmount = PersonDamage;

                if(bZoomed) 
                {
                    if(Other != none) 
                    {
                        // check for head shot
                        if(abs(HitLocation.Z-Other.Location.Z) > 0.5 * Other.CollisionHeight && Other.IsA('VGPawn') ) 
                        {
                            if(bOneShotKill)
                            {
                                damageAmount = 150;
                            }
                            else
                            {
                                damageAmount = 110;
                            }
                        }
                        else if(bOneShotKill)
                        {
                            damageAmount = 80;
                        }
                    }
                }

                if(InStr(GetMeshName(), "Keeper") >= 0) {
                    // keepers count as vehicles rather than people
                    if(bOneShotKill && bZoomed)
                        damageAmount = 100;
                    else
                        damageAmount = VehicleDamage;
                }

                Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
            }

            if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand() )
            {
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
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
					if(PersonalWeapon(Weapon).WecLevel > 2)
					{
					    Spawn(class'VehicleEffects.RedImpactScorch',,,HitLocation+HitNormal*3.0,Rotator(HitNormal));
                    }
				}
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
				{
					if(Level.Game != None && Level.Game.bSinglePlayer && HitSurfaceType == EST_HeatPipes)
					{
						class'SteamDamageArea'.static.SpawnDamageArea(Weapon.Owner, HitLocation, HitNormal);
					}
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
					if(PersonalWeapon(Weapon).WecLevel > 2)
					{
					    Spawn(class'VehicleEffects.RedImpactScorch',,,HitLocation+HitNormal*3.0,Rotator(HitNormal));
                    }
				}
            }
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    if(bZoomed) {
        Start.Z -= 15;
        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, 0);
    }

    SniperRifle(Weapon).LastHitLocation = HitLocation;
}


simulated function WECLevelUp(int level)
{
    switch(Level)
    {
    case 1: // enhanced vision
        bOneShotKill = true;
        PersonDamage = 50;
        break;
    case 2: // extra clip
        break;
    case 3:
        PersonDamage = 100;
        break;
    }
}

function RestoreView(float dt)
{
}

function ModeTick( float dt )
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
            if(PlayerController(Instigator.Controller).MuzzleFlashLight != none)
                PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = 0;
        }
        else
        {   
            PersonalWeapon(Weapon).LightIntensityTimer += dt;
            MuzzleLightIntensity = 700 ;
            if(PlayerController(Instigator.Controller).MuzzleFlashLight != none)
            {
                PlayerController(Instigator.Controller).MuzzleFlashLight.LightBrightness = MuzzleLightIntensity;
                PlayerController(Instigator.Controller).MuzzleFlashLight.LightSaturation = 255;
            }
        }
    }

    Super.ModeTick(dt);
}

simulated function Vector GetSpringForce()
{
    return(vect(1,0,0) * ((0.8 + 0.1 * FRand()) * spring_force_applied));
}

function ModeDoFire()
{
    if( AllowFire() )
    {
        //Turn on the weapon dynamic light (not if it is a bot though)
        if( Instigator.Controller.IsA('PlayerController') )
            PersonalWeapon(Weapon).bTurnedOnDynLight = true;
            
        if(FlashEffect != none)
            FlashEffect.StartFlash();
    }
    Super.ModeDoFire();
}

state Reload
{
    simulated function BeginState()
    {
    }
    simulated function EndState()
    {
        NextFireTime = Level.TimeSeconds;
		if(Weapon.ClientState != WS_Lowered)
			Weapon.LoopAnim(Weapon.IdleAnim, Weapon.IdleAnimRate, TweenTime);
    }

    function PlayFireEnd() {}

    event ModeDoFire(){}
    event ModeHoldFire() {}

    simulated function ModeTick(float dt)
    {
    }
}

// set the zoom-mode firing parameters
simulated function SetZoomParameters()
{
    bZoomed = true;
}

// reset to normal mode firing parameters
simulated function SetNormalParameters()
{
    bZoomed = false;
}

simulated function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local SniperTrail snipe;
    snipe = Spawn(class'SniperTrail',,, Start, rotator(HitLocation-Start) );
}

function PlayFireEnd()
{
}

defaultproperties
{
     HeadShotRadius=12.000000
     HeadShotDamage=100.000000
     MinSpread=0.025000
     MaxSpread=0.160000
     LaserTargetMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_lazer_target'
     SmokeEffectClass=Class'VehicleEffects.bulldog_muzzlesmoke_1st'
     TraceRange=25000.000000
     Momentum=500.000000
     DamageType=Class'VehicleWeapons.SniperRifleDamage'
     HitEffectClass=Class'VehicleWeapons.SniperHitEffects'
     VehicleDamage=80
     PersonDamage=40
     spring_mass=1.400000
     spring_stiffness=90.000000
     spring_damping=9.200000
     spring_force_applied=500.000000
     bAnimateThird=False
     UseSpringImpulse=True
     AmmoPerFire=1
     RecoilPitch=1000
     TweenTime=0.010000
     FireRate=1.400000
     RecoilTime=1.000000
     BotRefireRate=0.990000
     aimerror=500.000000
     Spread=0.060000
     MaxFireNoiseDist=2500.000000
     FireSound=Sound'NewWeaponSounds.SniperRifle.SniperFireB'
     PreFireAnim="None"
     FireAnim="Fire01"
     AmmoClass=Class'VehicleWeapons.SniperRifleAmmo'
     FireForce="SniperRifleFire"
     PreFireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Line
     bModeExclusive=False
}
