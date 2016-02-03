//=============================================================================
// DamageType, the base class of all damagetypes.
// this and its subclasses are never spawned, just used as information holders
//=============================================================================
class DamageType extends Actor
	native
	abstract;


// Used to describe the type of damage.

const DAMAGE_None      		= 0;
const DAMAGE_Light     		= 1;
const DAMAGE_Medium	   		= 2;
const DAMAGE_Heavy     		= 4;
const DAMAGE_Fatal     		= 8;
const DAMAGE_Explosive 		= 16;
const DAMAGE_Energy	   		= 32;
const DAMAGE_ArmorKiller	= 64;

// Description of a type of damage.
var() localized string		DeathString;	 					// string to describe death by this type of damage
var() localized string		DestroyString;
var() localized string		FemaleSuicide, MaleSuicide;
var() float					ViewFlash;    					// View flash to play.
var() vector				ViewFog;      					// View fog to play.
var() class<effects>		DamageEffect; 					// Special effect.
var() string				DamageWeaponName; 				// weapon that caused this damage
var() bool					bArmorStops;					// does regular armor provide protection against this damage
var() bool					bInstantHit;					// done by trace hit weapon
var() bool					bFastInstantHit;				// done by fast repeating trace hit weapon
var() float					GibModifier;

// these effects should be none if should use the pawn's blood effects
var() class<Effects>		PawnDamageEffect;	// effect to spawn when pawns are damaged by this damagetype
var() class<Emitter>		PawnDamageEmitter;	// effect to spawn when pawns are damaged by this damagetype
var() class<xEmitter>		PawnDamagexEmitter;
// low detail version
var() class<Effects>		PawnDamageEffectLow;
var() class<Emitter>		PawnDamageEmitterLow;
var() class<xEmitter>		PawnDamagexEmitterLow;

// vehicle effects
var() class<Effects>		VehicleDamageEffect;
var() class<Emitter>		VehicleDamageEmitter;
var() class<xEmitter>		VehicleDamagexEmitter;
//low detail
var() class<Effects>		VehicleDamageEffectLow;
var() class<Emitter>		VehicleDamageEmitterLow;
var() class<xEmitter>		VehicleDamagexEmitterLow;

//list's do their own LOD
var() class<xEmitterList>	PawnDamagexEmitterList;
var() class<xEmitterList>	VehicleDamagexEmitterList;

//sound effects
var() array<Sound>			PawnDamageSounds;	// Sound Effect to Play when Damage occurs
var() array<Sound>			VehicleDamageSounds;

/*
//don't think we'll be using low gore?!?!
var() class<Effects>		LowGoreDamageEffect; 	// effect to spawn when low gore
var() class<Emitter>		LowGoreDamageEmitter;	// Emitter to use when it's low gore
var() array<Sound>			LowGoreDamageSounds;	// Sound Effects to play with Damage occurs with low gore
*/

var() float					FlashScale;		//for flashing victim's screen
var() vector				FlashFog;

var() int					DamageDesc;			// Describes the damage
var() int					DamageThreshold;	// How much damage much occur before playing effects

var() vector				DamageKick;

var() Material              DamageOverlayMaterial;    // sjs - for changing player's shader when hit
var() float                 DamageOverlayTime;        // sjs - timing for this

// gam ---
var() class<Weapon>         WeaponClass;

var() bool                  bAlwaysGibs;
var() float                 GibPerterbation;    // When gibbing, the chunks will fly off in random directions.

var() bool                  bLocationalHit;

var() bool                  bAlwaysSevers;
var() bool                  bSpecial;

var() bool                  bDetonatesGoop;
var() bool                  bSkeletize;         // swap model to skeleton
// --- gam

// sjs --- optional message to xmit to victim/killer
var() class<LocalMessage>   KillerMessage;
var() int                   KillerMessageIndex;
var() class<LocalMessage>   VictimMessage;
var() int                   VictimMessageIndex;
// --- sjs

var(Havok)	float			HavokHitImpulseScale;
var(Havok)	bool			bHavokHitNormalizeMomentum;
var(Havok)	float			HavokVehicleHitImpulseScale;
var(Havok)	bool			bHavokVehicleHitNormalizeMomentum;

var() bool					bFreezes;	// flag to indicate that this type of damage freezes the victim

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	return Default.DeathString;
}

static function string DestroyMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	return Default.DestroyString;
}

static function string SuicideMessage(PlayerReplicationInfo Victim)
{
	if ( Victim.bIsFemale )
		return Default.FemaleSuicide;
	else
		return Default.MaleSuicide;
}

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	// XJ
	if(Victim.IsA('VGVehicle'))
	{
		if ( bLowDetail )	//check for other low detail situations also
		{
			if ( Default.VehicleDamageEffectLow != None )
				return Default.VehicleDamageEffectLow;
			else
				return Victim.LowDetailBlood;
		}
		if(Default.VehicleDamageEffect != none)
			return Default.VehicleDamageEffect;
		else		//don't think we have a blood effect for vehicles?!?!
			return Victim.BloodEffect;
	}
	else
	{
        // jim: No blood with GoreLevel > 0
        if ( class'GameInfo'.default.GoreLevel > 0 )
        {
            return None;
        }

		if ( bLowDetail )	//check for other low detail situations also
		{
			if ( Default.PawnDamageEffectLow != None )
				return Default.PawnDamageEffectLow;
			else
				return Victim.LowDetailBlood;
		}
		if ( Default.PawnDamageEffect != None )
			return Default.PawnDamageEffect;
		else
			return Victim.BloodEffect;
	}
	//
	/*
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if ( Default.LowGoreDamageEffect != None )
			return Default.LowGoreDamageEffect;
		else
			return Victim.LowGoreBlood;
	}
	*/
}

static function class<Emitter> GetPawnDamageEmitter( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	// XJ
	if(Victim.IsA('VGVehicle'))
	{
		if(bLowDetail)	//other low detail?!?!
		{
			return Default.VehicleDamageEmitterLow;
		}
		return Default.VehicleDamageEmitter;
	}
	else
	{
        // jim: No blood with GoreLevel > 0
        if ( class'GameInfo'.default.GoreLevel > 0 )
        {
            return None;
        }

		if(bLowDetail)	//other low detail?!?!
		{
			return Default.PawnDamageEmitterLow;
		}
		return Default.PawnDamageEmitter;
	}
	//
	/*
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if ( Default.LowGoreDamageEmitter != None )
			return Default.LowGoreDamageEmitter;
		else
			return none;
	}
	*/
}

static function class<xEmitter> GetPawnDamagexEmitter( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if(Victim.IsA('VGVehicle'))
	{
		if ( bLowDetail )	//other low details?!?!
		{
			return Default.VehicleDamagexEmitterLow;
		}
		//check for low detail
		return Default.VehicleDamagexEmitter;
	}
	else
	{
        // jim: No blood with GoreLevel > 0
        if ( class'GameInfo'.default.GoreLevel > 0 )
        {
            return None;
        }

		//check for low detail
		if ( bLowDetail )	//other low details?!?!
		{
			return Default.PawnDamagexEmitterLow;
		}
		return Default.PawnDamagexEmitter;
	}
}

static function class<xEmitterList> GetPawnDamagexEmitterList( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if(Victim.IsA('VGVehicle'))
	{
		//check for low detail
		return Default.VehicleDamagexEmitterList;
	}
	else
	{
        // jim: No blood with GoreLevel > 0
        if ( class'GameInfo'.default.GoreLevel > 0 )
        {
            return None;
        }

		return Default.PawnDamagexEmitterList;
	}
}

static function Sound GetPawnDamageSound(Pawn Victim)
{
	// XJ
	if(Victim.IsA('VGVehicle'))
	{
		if(Default.VehicleDamageSounds.Length>0)
			return Default.VehicleDamageSounds[Rand(Default.VehicleDamageSounds.Length)];
		else
			return none;
	}
	//
	/*
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		if (Default.LowGoreDamageSounds.Length>0)
			return Default.LowGoreDamageSounds[Rand(Default.LowGoreDamageSounds.Length)];
		else
			return none;
	}*/
	else
	{
		if (Default.PawnDamageSounds.Length>0)
			return Default.PawnDamageSounds[Rand(Default.PawnDamageSounds.Length)];
		else
			return none;
	}
}

static function bool IsOfType(int Description)
{
	local int result;

	result = Description & Default.DamageDesc;
	return (result == Description);
}

// gam ---
static function GetHitEffects( out class<xEmitter> HitEffects[4], int VictemHealth );
// --- gam


static function bool GetHavokHitImpulse( vector momentum, out vector impulse )
{
	local float	 f;

	if( default.HavokHitImpulseScale > 0 )
	{
		if ( default.bHavokHitNormalizeMomentum )
		{
			f = VSize( momentum );
			if ( f < 0.01 )
			{
				return False;
			}
			momentum /= f;
		}
		else
		{
			f = momentum Dot momentum;
			if ( f < 0.0001 )
			{
				return False;
			}
		}
		impulse = momentum * default.HavokHitImpulseScale;
		return True;
	}

	return False;
}

static function bool GetHavokVehicleHitImpulse( vector momentum, out vector impulse )
{
	local float	 f;

	if( default.HavokVehicleHitImpulseScale > 0 )
	{
		if ( default.bHavokVehicleHitNormalizeMomentum )
		{
			f = VSize( momentum );
			if ( f < 0.01 )
			{
				return False;
			}
			momentum /= f;
		}
		else
		{
			f = momentum Dot momentum;
			if ( f < 0.0001 )
			{
				return False;
			}
		}
		impulse = momentum * default.HavokVehicleHitImpulseScale;
		return True;
	}

	return False;
}

defaultproperties
{
     DamageDesc=1
     GibModifier=1.000000
     FlashScale=-0.019000
     GibPerterbation=0.060000
     HavokHitImpulseScale=10.000000
     HavokVehicleHitImpulseScale=10.000000
     FlashFog=(X=26.500000,Y=4.500000,Z=4.500000)
     DeathString="%o was killed by %k."
     DestroyString="%o's vehicle was destroyed by %k."
     FemaleSuicide="%o killed herself."
     MaleSuicide="%o killed himself."
     bArmorStops=True
     bLocationalHit=True
}
