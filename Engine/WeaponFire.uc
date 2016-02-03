class WeaponFire extends Actor
    native;

var() Weapon Weapon;
var() int ThisModeNum;

var() Name PreFireAnim;
var() Name FireAnim;
var() Name FireLoopAnim;
var() Name FireEndAnim;
var() Name ReloadAnim;

var() float PreFireAnimRate;
var() float FireAnimRate;
var() float FireLoopAnimRate;
var() float FireEndAnimRate;
var() float ReloadAnimRate;
var() float TweenTime;

// sound //
var() Sound PreFireSound;
var() Sound FireSound;
var() Sound FireEndSound;
var() Sound ReloadSound;
var() Sound NoAmmoSound;

// jdf ---
// Force Feedback //
var() String FireForce;
var() String PreFireForce;
var() bool bUseForceFeedback;	// XJ not all firemodes use force feedback
// --- jdf

// timing //
var() float PreFireTime;       // seconds before first shot
var(Damage) float FireRate;          // seconds betewwn shots
var() bool  bFireOnRelease;    // if true, shot will be fired when button is released, HoldTime will be the time the button was held for
var() bool  bWaitForRelease;   // if true, fire button must be released between each shot
var() bool  bModeExclusive;    // if true, no other fire modes can be active at the same time as this one
var() float MaxHoldTime;
var() float HoldTime;

var   bool  bIsFiring;
var   float NextFireTime;
var   bool  bNowWaiting;
var   float ServerStartFireTime;
var   bool  bServerDelayStopFire;
var   bool  bServerDelayStartFire;

var   bool bAutoFire;

// ammo //
var() class<Ammunition> AmmoClass;
var() int AmmoPerFire;
var() int AmmoClipSize;
var() float Load;
var() int DroppedAmmoCount;

// camera shakes //
var() int RecoilPitch;
var() float RecoilTime;

// AI //
var() bool bSplashDamage;
var() bool bSplashJump;
var() bool bRecommendSplashDamage;
var() bool bTossed;
var() bool bLeadTarget;
var() bool bInstantHit;
var() class<Projectile> ProjectileClass;
var() float BotRefireRate;
var() float WarnTargetPct;

// muzzle flash & smoke //
var() class<xEmitter> FlashEmitterClass;
var() class<xEmitter> FlashEmitterClassMP;
var() xEmitter FlashEmitter;
var() bool bAttachFlashEmitter;
var() class<xEmitter> SmokeEmitterClass;
var() class<xEmitter> SmokeEmitterClassMP;
var() xEmitter SmokeEmitter;
var() bool bAttachSmokeEmitter;

// other useful stuff //
var() bool  bPawnRapidFireAnim; // for determining what anim the firer should play
var() bool  bReflective;
var() int ProjPerFire;
var() float AimError; // 0=none 1000=quite a bit
var() float Spread; // rotator units. no relation to AimError
var() enum ESpreadStyle
{
    SS_None,
    SS_Random,	// spread is max random angle deviation
    SS_Line,	// spread is angle between each projectile
	SS_Bell,		// spread simulates normal distribution (xmatt)
	SS_RadBased	// forces a fixed percentages of the points to be within a circle and two rings (xmatt)
} SpreadStyle;

var int FireCount;
var() float DamageAtten; // attenuate instant-hit/projectile damage by this multiplier
var() float AutoAim; // cos of the max angle


var float MaxFireNoiseDist; //cmr -- max distance for the firing noise of the weapon

function MakeFireNoise()
{
	if(Instigator != none)
		Instigator.MakeNoise(1.0, MaxFireNoiseDist);
}

simulated function PostBeginPlay()
{
    Load = AmmoPerFire;

    if (bFireOnRelease)
        bWaitForRelease = true;

    if (bWaitForRelease)
        bNowWaiting = true;

	if(Level.Game == none || !Level.Game.bSinglePlayer) {
		if(FlashEmitterClassMP != none)
			FlashEmitterClass = FlashEmitterClassMP;
		if(SmokeEmitterClassMP != none)
			SmokeEmitterClass = SmokeEmitterClassMP;
	}
}

simulated function Destroyed()
{
    DestroyEffects();
    Super.Destroyed();
}

simulated function DestroyEffects()
{
    if (FlashEmitter != None)
    {
        //log("Destroyed "$FlashEmitter);
        FlashEmitter.Destroy();
    }
    if (SmokeEmitter != None)
    {
        SmokeEmitter.Destroy();
    }
}

simulated function InitEffects()
{
    // don't even spawn on server
    if ( Level.NetMode == NM_DedicatedServer )
		return;
    if ( FlashEmitterClass != None && FlashEmitter == None )
    {
        FlashEmitter = Spawn(FlashEmitterClass);
    }

    if ( SmokeEmitterClass != None && SmokeEmitter == None )
    {
        SmokeEmitter = Spawn(SmokeEmitterClass);
    }
}

//simulated function ReInit()
//{
//}

function DoFireEffect()
{
}

function DrawMuzzleFlash(Canvas Canvas)
{
    // Draw smoke first
    if (SmokeEmitter != None && SmokeEmitter.Base != Weapon)
    {
        SmokeEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( SmokeEmitter, false, false, Weapon.DisplayFOV );
    }

    if (FlashEmitter != None && FlashEmitter.Base != Weapon)
    {
        FlashEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV ); 
    }
}

function FlashMuzzleFlash()
{
    if (FlashEmitter != None)
        FlashEmitter.Trigger(Weapon, Instigator);
}

function StartMuzzleSmoke()
{
    if ( !Level.bDropDetail && (SmokeEmitter != None) )
        SmokeEmitter.Trigger(Weapon, Instigator);
}

function ShakeView()
{
    local PlayerController P;

	if(Instigator == none)
		return;

    P = PlayerController(Instigator.Controller);
    if (P != None)
    {
        P.RecoilShake(RecoilPitch, RecoilTime);        
    }
}

// jdf ---
function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

	if(Instigator != none) {
	    PC = PlayerController(Instigator.Controller);
		if (PC != None && PC.bEnableWeaponForceFeedback )
		{
			PC.ClientPlayForceFeedback(EffectName);
		}
    }
}

function ClientStopForceFeedback( String EffectName )
{
    local PlayerController PC;

	if(Instigator != none) {
	    PC = PlayerController(Instigator.Controller);
		if (PC != None && PC.bEnableWeaponForceFeedback )
		{
			PC.ClientStopForceFeedback(EffectName);
		}
    }
}
// --- jdf

function Update(float dt)
{
}

function StartFiring()
{
}

function StopFiring()
{
}

function StartBerserk()
{
    FireRate = default.FireRate * 0.75;
    FireAnimRate = default.FireAnimRate * 0.75;
}

function StopBerserk()
{
    FireRate = default.FireRate;
    FireAnimRate = default.FireAnimRate;
}

function bool IsFiring()
{
	return bIsFiring;
}

event ModeTick(float dt);

event ModeDoFire()
{
    local AIController AIC;

    if (!AllowFire() )
        return;

    // Local Machine
    if( Instigator != none && Instigator.IsLocallyControlled() )
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    Weapon.PlayOwnedSound(FireSound, SLOT_None, TransientSoundVolume,false,,,false);

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    if (Weapon.Role == ROLE_Authority)
    {
        if (Weapon == None || Instigator == None)
            return;

        Instigator.Controller.PlayerReplicationInfo.Stats.RegisterShot( Weapon.class, ProjPerFire * int(Load) );

        AIC = AIController(Instigator.Controller);

        if ( AIC != None )
		{
			if(AIC.Pawn.DefaultWeapon == Weapon)
				AIC.DefaultWeaponFireAgain(BotRefireRate*Weapon.FireRateAtten, true);
			else
				AIC.WeaponFireAgain(BotRefireRate*Weapon.FireRateAtten, true);
		}

    }
	Load = AmmoPerFire;
	Weapon.ConsumeAmmo(ThisModeNum, Load);

	if(!Weapon.IsA('GrenadeLauncher') || Role == ROLE_Authority)
		DoFireEffect();
		
	if(!bFireOnRelease)
		Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate*Weapon.FireRateAtten;
        else
            NextFireTime = Level.TimeSeconds + FireRate*Weapon.FireRateAtten;
    }
    else
    {
        NextFireTime += FireRate*Weapon.FireRateAtten;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

	Load = AmmoPerFire;
    HoldTime = 0;

    if(Instigator != none && Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        if( Weapon.PutDown() )
            bIsFiring = false;
    }
}

event ModeHoldFire()
{
    if (Instigator != none && Instigator.IsLocallyControlled())
        PlayStartHold();
}


simulated function bool AllowFire()
{
	return (Instigator.Health > 0 && Weapon.Ammo[ThisModeNum] != None && Weapon.Ammo[ThisModeNum].AllowFire(AmmoPerFire));
}


//// client animation ////

function PlayPreFire()
{
    if (Weapon.HasAnim(PreFireAnim))
    {
        Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, TweenTime);
        Weapon.PlayOwnedSound(PreFireSound,,TransientSoundVolume,,,,false);
		if(bUseForceFeedback)	//XJ
		{
	        ClientPlayForceFeedback(PreFireForce);  // jdf
		}
    }
}

function PlayStartHold()
{
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
            Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
        }
    }
    else
    {
        Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    }
    if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}
    FireCount++;
}

function PlayFireEnd()
{
    if (Weapon.HasAnim(FireEndAnim))
    {    	
        Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, TweenTime);
        Weapon.StopOwnedSound(FireSound);
        Weapon.PlaySound(FireEndSound,SLOT_Interact,TransientSoundVolume,,,,false);
    }
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
    local Ammunition Ammo;

    // stuff Ammo with AI info
    Ammo = Weapon.Ammo[ThisModeNum];
    if (Ammo == None)
    {
        Log("warning:"@Weapon@self@"needs an ammo class for nefarious AI purposes");
        return Instigator.Rotation;
    }
    else
    {
        Ammo.bTossed = bTossed;
        Ammo.bTrySplash = bRecommendSplashDamage;
        Ammo.bLeadTarget = bLeadTarget;
        Ammo.bInstantHit = bInstantHit;
        Ammo.ProjectileClass = ProjectileClass;
		Ammo.WarnTargetPct = WarnTargetPct;
        Ammo.MaxRange = MaxRange(); //amb: for autoaim
        Ammo.AutoAim = AutoAim;
        return Instigator.AdjustAim(Ammo, Start, InAimError);
    }
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	if ( Instigator != None )
	{
		return Instigator.Location + Instigator.EyePosition();
	}
	else
	{
		return vect(0,0,0);
	}
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText("  FIREMODE "$GetItemName(string(self))$" Weapon "$Weapon$" Instigator "$Instigator);//$" IsFiring "$bIsFiring);
    YPos += YL;
    Canvas.SetPos(4,YPos);
/*
    Canvas.DrawText("  FireOnRelease "$bFireOnRelease$" HoldTime "$HoldTime$" MaxHoldTime "$MaxHoldTime);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    Canvas.DrawText("  NextFireTime "$NextFireTime$" NowWaiting "$bNowWaiting);
    YPos += YL;
    Canvas.SetPos(4,YPos);
*/
}

function float MaxRange()
{
	return 5000;
}

simulated function WECLevelUp(int level) {}

simulated function BeginReload()
{
    GotoState('Reload');
}

simulated function EndReload()
{
    GotoState('');
}

defaultproperties
{
     ProjPerFire=1
     PreFireAnimRate=1.000000
     FireAnimRate=1.000000
     FireLoopAnimRate=1.000000
     FireEndAnimRate=1.000000
     ReloadAnimRate=1.000000
     TweenTime=0.100000
     FireRate=0.500000
     BotRefireRate=0.950000
     aimerror=600.000000
     DamageAtten=1.000000
     AutoAim=0.920000
     PreFireAnim="PreFire"
     FireAnim="Fire"
     FireLoopAnim="FireLoop"
     FireEndAnim="FireEnd"
     ReloadAnim="Reload"
     bUseForceFeedback=True
     bModeExclusive=True
     bInstantHit=True
     RemoteRole=ROLE_None
     bHidden=True
}
