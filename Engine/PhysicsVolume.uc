//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
	native
	nativereplication;

var()		bool		bPainCausing;	 // Zone causes pain.
var()		vector		ZoneVelocity;
var()		vector		Gravity;
var()		float		GroundFriction;
var()		float		TerminalVelocity;
var()		float		DamagePerSec;
var() class<DamageType>	DamageType;
var()		int			Priority;	// determines which PhysicsVolume takes precedence if they overlap
var() sound  EntrySound;	//only if waterzone
var() sound  ExitSound;		// only if waterzone
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() float  FluidFriction;
var() vector ViewFlash, ViewFog;

// these emitters will be attached to the intersection of the actor's vertical centerline and the volume
//
var() class<Emitter>	SurfaceEmitter;					// emitter to attach to moving actor in volume
var() class<Emitter>	SurfaceIdleEmitter;				// emitter to attach to actor that isn't moving
var() sound				SurfaceEntrySound;				// similar to EntrySound, but applies to all PhysicsVolumes
var() float				SurfaceEntrySoundVelocityScale;

var()		bool	bDestructive; // Destroys most actors which enter it.
var()		bool	bNoInventory;
var()		bool	bMoveProjectiles;// this velocity zone should impart velocity to projectiles and effects
var()		bool	bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()		bool	bNeutralZone; // Players can't take damage in this zone.
var()		bool	bWaterVolume;
var	Info PainTimer;

// Distance Fog
var(VolumeFog) bool   bDistanceFog;	// There is distance fog in this physicsvolume.
var(VolumeFog) color DistanceFogColor;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;
var(VolumeFog) float DistanceFogBlendTime;

// Karma
var(Karma)	   float KExtraLinearDamping; // Extra damping applied to Karma actors in this volume.
var(Karma)	   float KExtraAngularDamping;
var(Karma)	   float KBuoyancy;			  // How buoyant Karma things are in this volume (if bWaterVolume true). Multiplied by Actors KarmaParams->KBuoyancy.

var PhysicsVolume NextPhysicsVolume;

// sjs ---
var/*(Weather)*/ Name   WeatherTag;     // match this to a weather effect placed in the level

var/*(Wind)*/	bool	bWindActive;
var/*(Wind)*/	float	WindStrength;
var/*(Wind)*/	bool	bWindDirectional;
var/*(Wind)*/	float	WindCone;
var/*(Wind)*/	float	WindDeviation;	// 0-1
var/*(Wind)*/	float	WindClampOdds;	// 0-1
// --- sjs

simulated function Destroyed()
{
	Level.RemovePhysicsVolume(self);
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Level.AddPhysicsVolume(self);

	if ( Role < ROLE_Authority )
		return;
	if ( bPainCausing )
		PainTimer = Spawn(class'VolumeTimer', self);
}

/* Called when an actor in this PhysicsVolume changes its physics mode
*/
event PhysicsChangedFor(Actor Other);

event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);

event PawnEnteredVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		TriggerEvent(Event,self, Other);
}

event PawnLeavingVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		UntriggerEvent(Event,self, Other);
}

/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local actor A;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
			return;

		ForEach TouchingActors(class'Actor', A)
			CausePainTo(A);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	// turn zone damage on and off
	if (DamagePerSec != 0)
	{
		bPainCausing = !bPainCausing;
		if ( bPainCausing && (PainTimer == None) )
			PainTimer = spawn(class'VolumeTimer', self);
	}
}

event touch(Actor Other)
{
	local float Vol;

	Super.Touch(Other);
	if ( Other == None )
	{
		return;
	}
	if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
	{
		Other.LifeSpan = 1.5;
		return;
	}
	if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
	{
		if ( Other.Physics == PHYS_Projectile )
			Other.Velocity += ZoneVelocity;
		else if ( Other.IsA('Effects') && (Other.Physics == PHYS_None) )
		{
			Other.SetPhysics(PHYS_Projectile);
			Other.Velocity += ZoneVelocity;
		}
	}
	if ( bPainCausing )
	{
		if ( Other.bDestroyInPainVolume )
		{
			Other.Destroy();
			return;
		}
		CausePainTo(Other);
	}
	if ( Other.CanSplash() )
	{
		if ( bWaterVolume )
		{
			PlayEntrySplash(Other);
		}
		if ( SurfaceEntrySound != None )
		{
			if ( SurfaceEntrySoundVelocityScale != 0 )
			{
				Vol = FClamp( Other.Velocity.Z * SurfaceEntrySoundVelocityScale, 0.1, 1.0 ); 
			}
			else
			{
				Vol = 1;
			}
			`log( "RJ: vel.z = "$Other.Velocity.Z$" playing "$SurfaceEntrySound$" at volume "$Vol * TransientSoundVolume );
			Other.PlaySound( SurfaceEntrySound, SLOT_Interact, Vol * TransientSoundVolume );
		}
	}
}

function PlayEntrySplash(Actor Other)
{
	local float SplashSize;
	local actor splash;

	splashSize = FClamp(0.00003 * Other.Mass * (250 - 0.5 * FMax(-600,Other.Velocity.Z)), 0.1, 1.0 );
	if( EntrySound != None )
	{
		PlaySound(EntrySound, SLOT_Interact, splashSize);
		if ( Other.Instigator != None )
			MakeNoise(SplashSize);
	}
	if( EntryActor != None )
	{
		splash = Spawn(EntryActor); 
		if ( splash != None )
			splash.SetDrawScale(splashSize);
	}
}

event untouch(Actor Other)
{
	if ( bWaterVolume && Other.CanSplash() )
		PlayExitSplash(Other);
}

function PlayExitSplash(Actor Other)
{
	local float SplashSize;
	local actor splash;

	splashSize = FClamp(0.003 * Other.Mass, 0.1, 1.0 );
	if( ExitSound != None )
		PlaySound(ExitSound, SLOT_Interact, splashSize);
	if( ExitActor != None )
	{
		splash = Spawn(ExitActor); 
		if ( splash != None )
			splash.SetDrawScale(splashSize);
	}
}

function CausePainTo(Actor Other)
{
	local float depth;
	local Pawn P;

	// FIXMEZONE figure out depth of actor, and base pain on that!!!
	depth = 1;
	P = Pawn(Other);

	if ( DamagePerSec > 0 )
	{
		Other.TakeDamage(int(DamagePerSec * depth), None, Location, vect(0,0,0), DamageType); 
		if ( (P != None) && (P.Controller != None) )
			P.Controller.PawnIsInPain(self);
	}	
	else
	{
		if ( (P != None) && (P.Health < P.Default.Health) )
			P.Health = Min(P.Default.Health, P.Health - depth * DamagePerSec);
	}
}

defaultproperties
{
     GroundFriction=8.000000
     TerminalVelocity=2500.000000
     FluidFriction=0.300000
     DistanceFogBlendTime=5.000000
     KBuoyancy=1.000000
     Gravity=(Z=-950.000000)
     bAlwaysRelevant=True
}
