class VGWeaponFire extends WeaponFire;

var	()	float	RecoilStrength;
var	()	bool	bAnimateThird;	//animations will affect the third person model, for vehicles.
var(Damage) int	VehicleDamage;
var(Damage) int PersonDamage;

var	float					HudBarValue;	//how full is the bar on the hud

var float					HeatTime;
var float					LastHeatTime;
var float					CoolFactor;
var bool					bOverheated;
var ()	float				MaxHeatTime;	//how long till overheat
var	()	float				MaxCoolTime;	//how long to cool down
var bool					bNoAutoAim;		//Can turn off auto-aim that way

var Emitter overheatEmitter;	// overheating effect for weapons
var () class<Emitter> overheatEmitterClass;
var () class<Emitter> overheatEmitterClassMP;
var() float SpreadAttenuate;

var() bool  UseSpringImpulse;
var() float spring_mass;
var() float spring_stiffness;
var() float spring_damping;
var() float spring_force_applied;

simulated function Destroyed()
{
	Super.Destroyed();
	if(overheatEmitter != none)
		overheatEmitter.Kill();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(MaxCoolTime > 0)
		CoolFactor = MaxHeatTime/MaxCoolTime;

	if(Level.Game == none || !Level.Game.bSinglePlayer) {
		if(overheatEmitterClassMP != none)
			overheatEmitterClass = overheatEmitterClassMP;
	}
}

function bool CheckAnim(name Sequence)
{
	if (Weapon.ThirdPersonActor != none && Weapon.ThirdPersonActor.DrawType == DT_Mesh && Weapon.ThirdPersonActor.HasAnim(Sequence))
		return true;
	return false;
}

function StartBerserk()
{
    FireRate = default.FireRate * 0.7;
    FireAnimRate = default.FireAnimRate * 0.7;
}

function StopBerserk()
{
    FireRate = default.FireRate;
    FireAnimRate = default.FireAnimRate;
}


function PlayPreFire()
{
	if(bAnimateThird)
	{
		if (CheckAnim(PreFireAnim))
		{
			VehicleWeapon(Weapon).PlayThirdAnim(PreFireAnim, PreFireAnimRate, TweenTime);
			VehicleWeapon(Weapon).PlayOwnedSound(PreFireSound,,TransientSoundVolume,,,,false);
			ClientPlayForceFeedback(PreFireForce);
		}
		return;
	}
	Super.PlayPreFire();
}

function PlayFiring()
{
	if(bAnimateThird)
	{
		if (FireCount > 0)
		{
			if (CheckAnim(FireLoopAnim))
			{
				VehicleWeapon(Weapon).LoopThirdAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
			}
			else if(CheckAnim(FireAnim))
			{
				VehicleWeapon(Weapon).PlayThirdAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
		else if(CheckAnim(FireAnim))
		{
			VehicleWeapon(Weapon).PlayThirdAnim(FireAnim, FireAnimRate, TweenTime);
		}
		ClientPlayForceFeedback(FireForce);  // jdf
		FireCount++;
		return;
	}
	Super.PlayFiring();
}

function PlayFireEnd()
{
	if(bAnimateThird)
	{
		if (CheckAnim(FireEndAnim))
		{			
			VehicleWeapon(Weapon).PlayThirdAnim(FireEndAnim, FireEndAnimRate, TweenTime);
			Weapon.StopOwnedSound(FireSound);
			Weapon.PlaySound(FireEndSound,SLOT_Interact,TransientSoundVolume,,,,false);
		}
		return;
	}
	Super.PlayFireEnd();
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
	//to be backwards compatible with older AI classes (and Warfare codebase)
	if( CarBot(Instigator.Controller) == None && AIController(Instigator.Controller) != None)
		return Super.AdjustAim(Start, InAimError);

	return Instigator.AutoAim(Start,Weapon);
}

simulated function Vector GetSpringForce()
{
    return(VRand() * 300);
}

function PlayAmbientSound(Sound aSound)
{
    if (Weapon == None)
        return;

    Weapon.AmbientSound = aSound;
}

simulated function SetCamSpring()
{
	local PlayerController PC;
	if(!Instigator.Controller.IsA('PlayerController'))
	{
	    return;
	}
	PC = PlayerController(Instigator.Controller);
    PC.bNewCamShake = UseSpringImpulse;
    if(UseSpringImpulse)
    {
	    PC.Vertical_cam_spring.spring_m = spring_mass;
	    PC.Vertical_cam_spring.spring_k = spring_stiffness;
	    PC.Vertical_cam_spring.spring_d = spring_damping;
    }
}

function ModeDoFire()
{
    local PlayerController PC;
    
	Super.ModeDoFire();
	if(RecoilStrength > 0)
	{
		Weapon.Owner.HAddImpulse(-Vector(Weapon.ThirdPersonActor.Rotation)*RecoilStrength, Weapon.ThirdPersonActor.Location);
    }
    
    if(UseSpringImpulse && Instigator.Controller.IsA('PlayerController'))
    {
        PC = PlayerController(Instigator.Controller);
	    if( PC != None )
	    {
		    PC.AddSpringForce(GetSpringForce());
	    }
    }
}

// ...check to see if we need to reload the current weapon
simulated function ModeTick(float dt)
{
	// first do the super class modetick, this should ensure that modedofire gets called before we do our own thing
	Super.ModeTick(dt);
	
    if(Weapon.Ammo[0] != none && Weapon.Ammo[0].AmmoAmount < 0) 
    {
		PlayFiring();
		Weapon.Ammo[0].AmmoAmount = 0;
    }
}

function float MaxRange()
{
	return 10000;
}

defaultproperties
{
     overheatEmitterClass=Class'VehicleEffects.DavidTB3Exhaust'
     overheatEmitterClassMP=Class'VehicleEffects.DavidTB3Exhaust'
     bAnimateThird=True
     TransientSoundVolume=1.000000
}
