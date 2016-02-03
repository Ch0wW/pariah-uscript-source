class HealingToolFire extends VGInstantFire;

#exec LOAD FILE="PariahWeaponSounds.uax"

const MAX_HEALING_DIST = 180;

var() Name PreFireAnimB;
var() Name FireLoopAnimB;
var() Name FireEndAnimB;
var() float FireAnimRateB;

// motion bluring effect for extended healing
var transient bool    bMotionBluring;
var float   MotionBlurAccum;
var float   MotionBlurDecay;
var float   ChargeSoundTime;

var Pawn HealingTarget;
var int HealthPerDischarge;
var float BlurAmount;
var Sound ChargingSound;
var Sound InjectSound;

function Destroyed()
{
	StopBlur();
	AmbientSound = None;
	Super.Destroyed();
}

function Pawn FindHealingTarget()
{
    local VGPawn TraceTarget;
	local Vector Start, HitLoc, HitNorm, End;
	local Vector X, Y, Z;
    local Rotator Aim;

    // target self if wounded
    if(Instigator != None && Instigator.Health < Instigator.HealthMax)
        return Instigator;

    // trace out for target
	GetAxes(Weapon.ThirdPersonActor.Rotation, X, Y, Z);
	Start = Weapon.GetFireStart(X, Y, Z);
	Aim = AdjustAim(Start, AimError);

	X = Vector(Aim);
	End = Start + MAX_HEALING_DIST*X;

	TraceTarget = VGPawn(Trace(HitLoc, HitNorm, End, Start, true) );
	if(TraceTarget != None) 
	{
		if(CanTarget(TraceTarget)) 
		{
			if(TraceTarget.Health < TraceTarget.HealthMax) 
			{
				return TraceTarget;
			}
		}
    }

    return None;
}

function StartFire()
{
    HealingTarget = FindHealingTarget();
    ChargeSoundTime = 0.0;
}

event ModeDoFire()
{
    if(HealingTarget != None)
    {
        if(HealingTarget.Health < HealingTarget.HealthMax)
        {
            Super.ModeDoFire();
        }
    }
}

function DoFireEffect()
{
    if(HealingTarget != None)
    {
        ApplyHealth();

        // bring up tool if target is full health
        if(HealingTarget.Health >= HealingTarget.HealthMax)
        {
            if(Instigator.IsLocallyControlled())
            {
                PlayFireEnd();
            }
            HealingTarget = None;
        }
    }
    ChargeSoundTime = 0.0;
}

simulated function ModeTick(float dt)
{
    Super.ModeTick(dt);
    if(HealingTarget != None && HealingTarget.Health >= HealingTarget.HealthMax)
    {
        if(Instigator.IsLocallyControlled())
        {
            PlayFireEnd();
        }
        HealingTarget = None;
    }
}

function bool CanTarget(Pawn P)
{
	if(P == none || P == Instigator)
		return false;

	if(P.IsA('MostlyDeadPawn') )
		return false;

	if(Level.Game != None && Level.Game.bSinglePlayer && !P.IsA('SPPlayerPawn'))
	{
		return false;
	}

    if(P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)
        return false;

    return true;
}

function StopBlur()
{
	local MotionBlurPostFXStage fbe;

	if(bMotionBluring) 
	{
		fbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage(Level);
		bMotionBluring = false;
		fbe.PopMotionBlurState();
	}
}

function Tick(float dt)
{
	local MotionBlurPostFXStage fbe;
	local float blurFactor;
	
	if(bMotionBluring) 
	{
		// adjust motion bluring effect
		fbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage(Level);
		BlurAmount -= dt;
		if(BlurAmount > 0) 
		{
			blurFactor = FClamp(BlurAmount * 0.5, 0, 0.9);
			fbe.SetMotionBlurParams(true, 1-blurFactor, blurFactor);
		}
		else
		{
			bMotionBluring = false;
			fbe.PopMotionBlurState();
			BlurAmount = 0;
		}
	}

    if(HealingTarget != None && !IsInState('Reload'))
    {
        ChargeSoundTime += dt;
        if(ChargeSoundTime > FireRate) ChargeSoundTime = FireRate;
        SoundPitch = 64 + 48*ChargeSoundTime/FireRate;
    }

	Super.Tick(dt);
}

function DoTrace(Vector Start, Rotator Dir)
{
}

function ApplyHealth()
{
    SoundPitch = 64;
    ApplyBlur(2.0);
  	Weapon.PlayOwnedSound(InjectSound);

    if(bUseForceFeedback)
	{
	    ClientPlayForceFeedback(FireForce);
	}

    if(Weapon.Role == ROLE_Authority)
    {
        HealingTarget.Health += HealthPerDischarge;
        if(HealingTarget.Health > HealingTarget.HealthMax)
        {
            // overdose or just clamp?
            HealingTarget.Health = HealingTarget.HealthMax;
        }
    }
}

function ApplyBlur(float Blur)
{
    local MotionBlurPostFXStage fbe;
    local float blurFactor;

    if (!Instigator.IsLocallyControlled())
    {
        return;
    }

    BlurAmount += Blur;
    BlurAmount = FClamp(BlurAmount, 0.0, 10.0);
    
    fbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage(Level);
    if(fbe != none) 
    {
		if(!bMotionBluring)
		{
		    bMotionBluring = true;
			fbe.PushMotionBlurState();
			blurFactor = FClamp(BlurAmount, 0, 0.9);
			fbe.SetMotionBlurParams(true, 1-blurFactor, blurFactor);
		}
		bMotionBluring = true;
    }
}

function PlayFiring()
{
}

function PlayPreFire()
{
    if(HealingTarget != None)
    {
		if(HealingTarget != Instigator)
			Weapon.PlayAnim(PreFireAnimB, PreFireAnimRate, TweenTime);
		else
	        Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, TweenTime);
        Weapon.PlayOwnedSound(PreFireSound,, TransientSoundVolume,,,, false);
		AmbientSound = ChargingSound;
    }
}

function PlayFireEnd()
{
    local name Anim;
    local float frame, rate;

    if(HealingTarget != None)
    {
        Weapon.GetAnimParams( 0, Anim, frame, rate );
        if(Anim != Weapon.IdleAnim)
        {
		    if(HealingTarget != Instigator)
			    Weapon.PlayAnim(FireEndAnimB, FireEndAnimRate, TweenTime);
		    else
			    Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, TweenTime);
            Weapon.PlaySound(FireEndSound, SLOT_Interact, TransientSoundVolume,,,, false);
        }
    }
	AmbientSound = None;
}


state Reload
{
	function EndState()
	{
        NextFireTime = Level.TimeSeconds + FireRate;
        if(Instigator.IsLocallyControlled())
        {
            if(bIsFiring)
            {
                PlayPreFire();
            }
            else
            {
                if(Weapon.ClientState != WS_Lowered)
					Weapon.LoopAnim(Weapon.IdleAnim, Weapon.IdleAnimRate, TweenTime);
            }
        }
	}
	
	function BeginState()
	{
        AmbientSound = None;
        ChargeSoundTime = 0.0;
	}

    event ModeDoFire(){}
    event ModeHoldFire() {}

    function PlayFireEnd() {}
}

defaultproperties
{
     HealthPerDischarge=25
     FireAnimRateB=0.250000
     ChargingSound=Sound'PariahWeaponSounds.hit.HealingToolLoopA'
     InjectSound=Sound'PariahWeaponSounds.hit.HealingToolInjection'
     PreFireAnimB="FirePreB"
     FireLoopAnimB="FireLoopB"
     FireEndAnimB="FireEndB"
     Momentum=100.000000
     DamageType=Class'VehicleWeapons.HealingToolDamage'
     bAnimateThird=False
     AmmoPerFire=1
     FireAnimRate=0.500000
     FireEndAnimRate=3.000000
     PreFireTime=2.000000
     FireRate=2.000000
     BotRefireRate=0.990000
     PreFireSound=Sound'PariahWeaponSounds.hit.HT_Fire'
     FireSound=Sound'PariahWeaponSounds.hit.HT_FireEnd'
     PreFireAnim="FirePre"
     AmmoClass=Class'VehicleWeapons.HealingToolAmmo'
     FireForce="HealingToolFire"
     SoundVolume=255
}
