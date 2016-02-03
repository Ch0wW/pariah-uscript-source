//=============================================================================
// Pawn, the base class of all actors that can be controlled by players or AI.
//
// Pawns are the physical representations of players and creatures in a level.  
// Pawns have a mesh, collision, and physics.  Pawns can take damage, make sounds, 
// and hold weapons and other inventory.  In short, they are responsible for all 
// physical interaction between the player or AI and the world.
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Pawn extends Actor 
	abstract
	native
	placeable
	nativereplication
	exportstructs;

#exec Texture Import File=Textures\Pawn.pcx Name=S_Pawn Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// Pawn variables.

var Controller Controller;
//var VGAmmoPoolManager AmmoPool;			// each player gets their very own ammo pool (mthorne)
var bool bNoOverheat;

// cache net relevancy test
var float NetRelevancyTime;
var playerController LastRealViewer;
var actor LastViewer;

// Physics related flags.
var bool		bJustLanded;		// used by eyeheight adjustment
var bool		bUpAndOut;			// used by swimming 
var bool		bIsWalking;			// currently walking (can't jump, affects animations)
var bool		bWarping;			// Set when travelling through warpzone (so shouldn't telefrag)
var bool		bWantsToCrouch;		// if true crouched (physics will automatically reduce collision height to CrouchHeight)
var const bool	bIsCrouched;		// set by physics to specify that pawn is currently crouched
var bool		bIsDriving; //CMR - albhalbhalbhabhalbhalh
var bool		bIsGunner; //CMR - same as above but if gunner
var const bool	bTryToUncrouch;		// when auto-crouch during movement, continually try to uncrouch
var() bool		bCanCrouch;			// if true, this pawn is capable of crouching
var bool		bCrawler;			// crawling - pitch and roll based on surface pawn is on
var const bool	bReducedSpeed;		// used by movement natives
var bool        bCanFall;           //mh Falling can be ok.. jumping rarely looks good, so seperate them
var bool		bJumpCapable;
var	bool		bCanJump;			// movement capabilities - used by AI
var	bool 		bCanWalk;
var	bool		bCanSwim;
var	bool		bCanFly;
var	bool		bCanClimbLadders;
var	bool		bCanStrafe;
var	bool		bCanDoubleJump;
var	bool		bAvoidLedges;		// don't get too close to ledges
var	bool		bStopAtLedges;		// if bAvoidLedges and bStopAtLedges, Pawn doesn't try to walk along the edge at all
var	bool		bNoJumpAdjust;		// set to tell controller not to modify velocity of a jump/fall	
var	bool		bCountJumps;		// if true, inventory wants message whenever this pawn jumps
var const bool	bSimulateGravity;	// simulate gravity for this pawn on network clients when predicting position (true if pawn is walking or falling)
var	bool		bUpdateEyeheight;	// if true, UpdateEyeheight will get called every tick
var	bool		bIgnoreForces;		// if true, not affected by external forces
var const bool	bNoVelocityUpdate;	// used by C++ physics
var	bool		bCanWalkOffLedges;	// Can still fall off ledges, even when walking (for Player Controlled pawns)
var bool		bSteadyFiring;		// used for third person weapon anims/effects
var bool		bCanBeBaseForPawns;	// all your 'base', are belong to us
var bool		bClientCollision;	// used on clients when temporarily turning off collision
var const bool	bSimGravityDisabled;	// used on network clients
var bool		bShouldBounce;		// should bounce when hits the ground
var const float LastFallHeight;		//cmr -- for new falling damage
var const int   SafeFallHeight;
var const float MaxFallHeight;


const KILLDAMAGE=200;

enum ERace
{
	R_NPC,
	R_Guard,
	R_Clan,
	R_Shroud,
	R_Prisoner,
};
var ERace race;

// Havok character collision event
struct HavokCharacterObjectInteractionEvent
{
	var vector  Position;
	var vector  Normal;
	var float   ObjectImpulse;
	var float   Timestep;
	var float	ProjectedVelocity;
	var float	ObjectMass;
	var actor	Body;
};

// Havok character collision output
struct HavokCharacterObjectInteractionResult
{
	var vector  ObjectImpulse;
	var vector  ImpulsePosition;
	var vector  CharacterImpulse;
};

var(Havok) const bool	bHavokCharacterCollisions;				// Does this pawn Collision Cylinder collide with Havok and generate events? Will create a Havok Character Control proxy if so.
var(Havok) float		HavokCharacterCollisionExtraRadius;		// radius of Havok proxy extra than that of Unreal to allow Havok first go ;)

// used by dead pawns (for bodies landing and changing collision box)
var		bool	bThumped;		
var		bool	bInvulnerableBody;

// AI related flags
var		bool	bIsFemale;
var		bool	bAutoActivate;			// if true, automatically activate Powerups which have their bAutoActivate==true
var		bool	bCanPickupInventory;	// if true, will pickup inventory when touching pickup actors
var		bool	bUpdatingDisplay;		// to avoid infinite recursion through inventory setdisplay
var		bool	bAmbientCreature;		// AIs will ignore me
var(AI) bool	bLOSHearing;			// can hear sounds from line-of-sight sources (which are close enough to hear)
										// bLOSHearing=true is like UT/Unreal hearing
var(AI) bool	bSameZoneHearing;		// can hear any sound in same zone (if close enough to hear)
var(AI) bool	bAdjacentZoneHearing;	// can hear any sound in adjacent zone (if close enough to hear)
var(AI) bool	bMuffledHearing;		// can hear sounds through walls (but muffled - sound distance increased to double plus 4x the distance through walls
var(AI) bool	bAroundCornerHearing;	// Hear sounds around one corner (slightly more expensive, and bLOSHearing must also be true)
var(AI) bool	bDontPossess;			// if true, Pawn won't be possessed at game start
var		bool	bAutoFire;				// used for third person weapon anims/effects
var		bool	bRollToDesired;			// Update roll when turning to desired rotation (normally false)
var		bool	bIgnorePlayFiring;		// if true, ignore the next PlayFiring() call (used by AnimNotify_FireWeapon)

var		bool	bCachedRelevant;		// network relevancy caching flag
var		bool	bUseCompressedPosition;	// use compressed position in networking - true unless want to replicate roll, or very high velocities
var		bool    bSpecialCalcView;		// If true, the Controller controlling this pawn will call 'SpecialCalcView' to find camera pos.

var		byte	FlashCount;				// used for third person weapon anims/effects
// AI basics.
var 	byte	Visibility;			//How visible is the pawn? 0=invisible, 128=normal, 255=highly visible 
var		float	DesiredSpeed;
var		float	MaxDesiredSpeed;
var(AI) name	AIScriptTag;		// tag of AIScript which should be associated with this pawn
var(AI) float	HearingThreshold;	// max distance at which a makenoise(1.0) loudness sound can be heard
var(AI)	float	Alertness;			// -1 to 1 ->Used within specific states for varying reaction to stimuli 
var(AI)	float	SightRadius;		// Maximum seeing distance.
var(AI)	float	PeripheralVision;	// Cosine of limits of peripheral vision.
var()	float	SkillModifier;			// skill modifier (same scale as game difficulty)	
var const float	AvgPhysicsTime;		// Physics updating time monitoring (for AI monitoring reaching destinations)
var		float	MeleeRange;			// Max range for melee attack (not including collision radii)
var NavigationPoint Anchor;			// current nearest path;
var const NavigationPoint LastAnchor;		// recent nearest path
var		float	FindAnchorFailedTime;	// last time a FindPath() attempt failed to find an anchor.
var		float	LastValidAnchorTime;	// last time a valid anchor was found
var		float	DestinationOffset;	// used to vary destination over NavigationPoints
var		float	NextPathRadius;		// radius of next path in route
var		vector	SerpentineDir;		// serpentine direction
var		float	SerpentineDist;
var		float	SerpentineTime;		// how long to stay straight before strafing again
var const float	UncrouchTime;		// when auto-crouch during movement, continually try to uncrouch once this decrements to zero
var     bool    bAccurateMoveTo;

// Movement.
var float   GroundSpeed;    // The maximum ground speed.
var float   WaterSpeed;     // The maximum swimming speed.
var float   AirSpeed;		// The maximum flying speed.
var float	LadderSpeed;	// Ladder climbing speed
var float	AccelRate;		// max acceleration rate
var float	JumpZ;      	// vertical acceleration w/ jump
var float   AirControl;		// amount of AirControl available to the pawn
var float	WalkingPct;		// pct. of running speed that walking speed is
var float	CrouchedPct;	// pct. of running speed that crouched walking speed is
var float	MaxFallSpeed;	// max speed pawn can land without taking damage (also limits what paths AI can use)
var float	FatalFallSpeed;	// speed at which falling is fatal
var vector	ConstantAcceleration;	// acceleration added to pawn when falling
var bool	bFlyingBrake;   // cmr:  allows you to slow a flying actor smoothly.  
var float	FlyingBrakeAmount; //cmr to complement the above.
var bool	bDontReduceSpeed; //cmr for MoveToward()
var bool	bDontScaleAnimSpeedByVel; //cmr

//xmatt--
var Spline_Cubic spline;
var array<SplineCtrPt> CtrPts;
var float SplineTimer;
var vector PrevPosition;
var float SplineSpeed;
//--xmatt

// Player info.
var	string			OwnerName;		// Name of owning player (for save games, coop)
var travel Weapon	Weapon;			// The pawn's current weapon.
var	travel Weapon	DefaultWeapon;	// XJ: DefaultWeapon for vehicles need it here to access it in engine scripts
var Weapon			PendingWeapon;	// Will become weapon once current weapon is put down
var travel Powerups	SelectedItem;	// currently selected inventory item
var float      		BaseEyeHeight; 	// Base eye height above collision center.
var float        	EyeHeight;     	// Current eye height, adjusted for bobbing and stairs.
var	const vector	Floor;			// Normal of floor pawn is standing on (only used by PHYS_Spider and PHYS_Walking)
var float			SplashTime;		// time of last splash
var float			CrouchHeight;	// CollisionHeight when crouching
var float			CrouchRadius;	// CollisionRadius when crouching
var float			OldZ;			// Old Z Location - used for eyeheight smoothing
var PhysicsVolume	HeadVolume;		// physics volume of head
var float           HealthMax;      // amb FIXME - MOVE TO XPAWN
var travel int      Health;         // Health: 100 = normal maximum
var	float			BreathTime;		// used for getting BreathTimer() messages (for no air, etc.)
var float			UnderWaterTime; // how much time pawn can go without air (in seconds)
var	float			LastPainTime;	// last time pawn played a takehit animation (updated in PlayHit())
var class<DamageType> ReducedDamageType; // which damagetype this creature is protected from (used by AI)
var byte            ViewPitch;      // jjs - something to replicate so we can see which way remote clients are looking
var byte			ViewYaw;		// cmr - same as above, but needed for rider torso twisting
var float			HeadScale;
var bool			bDriver;		//BB will be replaced by a driving state later on
var bool			bDelayDied;     //BB to intercept the Died() call, and do stuff yourself manually before calling Died()
var vector			AutoAimOffset;	// XJ: where the auto aim routine should target on this pawn

var bool			bCanHoldGameObjects; //CMR: in order to filter vehicles out from carrying flags. 

// Sound and noise management
// remember location and position of last noises propagated
var const 	vector 		noise1spot;
var const 	float 		noise1time;
var const	pawn		noise1other;
var const	float		noise1loudness;
var const 	vector 		noise2spot;
var const 	float 		noise2time;
var const	pawn		noise2other;
var const	float		noise2loudness;
var			float		LastPainSound;

// view bob
var				globalconfig float Bob;
var				globalconfig bool bWeaponBob; // gam
var				float				LandBob, AppliedBob;
var				float bobtime;
var				vector			WalkBob;
var bool bNoLower; //For minied but can't put it somewhere believe me

var float SoundDampening;
var float DamageScaling;

var localized  string MenuName; // Name used for this pawn type in menus (e.g. player selection) 

// shadow decal
var Projector Shadow;

// blood effect
var class<Effects> BloodEffect;
var class<Effects> LowDetailBlood;
var class<Effects> LowGoreBlood;

var class<AIController> ControllerClass;	// default class to use when pawn is controlled by AI (can be modified by an AIScript)

var float CarcassCollisionHeight;	// collision height of dead body lying on the ground
var PlayerReplicationInfo PlayerReplicationInfo;

var LadderVolume OnLadder;		// ladder currently being climbed

var name LandMovementState;		// PlayerControllerState to use when moving on land or air
var name WaterMovementState;	// PlayerControllerState to use when moving in water

var PlayerStart LastStartSpot;	// used to avoid spawn camping
var float LastStartTime;

// Animation status
var name AnimAction;			// use for replicating anims 
var bool SnapAnimAction;		// cmr -- for use with above;

// Animation updating by physics FIXME - this should be handled as an animation object
// Note that animation channels 2 through 11 are used for animation updating
var vector TakeHitLocation;		// location of last hit (for playing hit/death anims)
var class<DamageType> HitDamageType;	// damage type of last hit (for playing hit/death anims)
var vector TearOffMomentum;		// momentum to apply when torn off (bTearOff == true)
var bool bTearOffSplashDamage;	// momentum was causeed by splash damage
var bool bPhysicsAnimUpdate;	
var bool bWasCrouched;
var bool bWasWalking;
var bool bWasOnGround;
var bool bInitializeAnimation;
var bool bPlayedDeath;
var EPhysics OldPhysics;
var byte CurrentRiderTwist;  //cmr -- oh jesus.  This is so that I can manually reverse rotate a rider in the physRiding()

// jjs - physics based animation stuff
var bool bIsIdle;           // true when standing still on the ground, Physics can be used for determining other states
var bool bWaitForAnim;      // true if the pawn is playing an important non-looping animation (eg. landing/dodge) and doesn't feel like being interrupted

var float OldRotYaw;			// used for determining if pawn is turning
var vector OldAcceleration;
var float BaseMovementRate;		// FIXME - temp - used for scaling movement
var(anim) name MovementAnims[4];		// Forward, Back, Left, Right
var name TurnLeftAnim;
var name TurnRightAnim;			// turning anims when standing in place (scaled by turn speed)
var(AnimTweaks) float BlendChangeTime;	// time to blend between movement animations
var float MovementBlendStartTime;	// used for delaying the start of run blending
var float ForwardStrafeBias;	// bias of strafe blending in forward direction
var float BackwardStrafeBias;	// bias of strafe blending in backward direction

var float DodgeSpeedFactor; // dodge speed moved here so animation knows the diff between a jump and a dodge
var float DodgeSpeedZ;

var const int OldAnimDir;
var const Vector OldVelocity;
var const bool bReverseRun;
var float SlideTime;
var float IdleTime;

var(anim) name SwimAnims[4];      // 0=forward, 1=backwards, 2=left, 3=right
var(anim) name CrouchAnims[4];
var(anim) name WalkAnims[4];
var(anim) name AirAnims[4];
var(anim) name TakeoffAnims[4];
var(anim) name LandAnims[4];
var(anim) name SlideAnims[4];
var(anim) name DoubleJumpAnims[4];
var(anim) name DodgeAnims[4];
var(anim) name AirStillAnim;
var(anim) name TakeoffStillAnim;
var(anim) name LandStillAnim;
var(anim) name CrouchTurnRightAnim;
var(anim) name CrouchTurnLeftAnim;
var(anim) name IdleCrouchAnim;
var(anim) name IdleSwimAnim;
var(anim) name IdleWeaponAnim;    // WeaponAttachment code will set this one

var(anim) name HitAnims[2];

var(anim) name DriverAnim;  // cmr (set in script derived class, per vehicle)
var(anim) name DriverAnimR;  // cmr (set in script derived class, per vehicle)
var(anim) name DriverAnimL;  // cmr (set in script derived class, per vehicle)
var(anim) name RiderAnim; //cmr

var(anim) name SprintAnim; //cmr for forward sprint

var bool bPlayingEnterExitAnim;//cmr for stoping driver/passenger from exiting before entry is complete. 
var bool bUseDriverTurnAnims;
var float PawnSteering; 
var bool bDoTorsoTwist;
var bool bAnimateTurn;  //cmr
var const int  FootRot;     // torso twisting/looking stuff
var const bool FootTurning;
var const bool FootStill;
var const int  TurnDir;
var bool bDoStrafeRun;
var const int  StrafeRunRot;
var Rotator DesiredRotationOffset;
var name RootBone;
var name HeadBone;
var name SpineBone1;
var name SpineBone2;

//cmr -- moved from xpawn in order to share with vehicles

const DamageDirFront = 0;
const DamageDirRight = 1;
const DamageDirLeft  = 2;
const DamageDirBehind = 3;
var() float DamageDirReduction;
var() float DamageDirLimit;

// -- cmr

// xPawn replicated properties - moved here to take advantage of native replication
const DamageDirMax = 4;

var(Shield) transient float ShieldStrength;          // current shielding (having been activated)
var() byte  DamageDirIntensity[DamageDirMax];

struct HitFXData
{
    var() Name    Bone;
    var() class<DamageType> damtype;
    var() bool bSever;
    var() Rotator rotDir;
};

var() HitFXData HitFx[8];
var transient int   HitFxTicker;

var transient CompressedPosition PawnPosition;
var transient bool bInvis;

var bool bIsJumping;

// stuff for setting the pawn on fire in response to the burning flak bits
var bool bOnFire;

// number of rockets currently seeking this target; rockets seek the closest target with the fewest other rockest seeking it
//var int numSeeking;

var bool bJustDodged;

var bool bMatineeProtected;

//cmr -- moved up for hud nativization

var Enum EDashState
{
	DSX_Normal,
	DSX_Dashing,
	DSX_Resting,
}DashState;



replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
        bSimulateGravity, bIsCrouched, bIsWalking, PlayerReplicationInfo, AnimAction, SnapAnimAction, HitDamageType, TakeHitLocation,HeadScale;
	reliable if( bTearOff && bNetDirty && (Role==ROLE_Authority) )
		TearOffMomentum, bTearOffSplashDamage;	
	reliable if ( !bNetOwner && (Role==ROLE_Authority) ) 
        bSteadyFiring, ViewPitch, ViewYaw; // - jjs
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
         Controller,SelectedItem, HealthMax; // sjs - test! move rates were here!
	reliable if( bNetDirty && Role==ROLE_Authority )
         Health, GroundSpeed, WaterSpeed, AirSpeed, AccelRate, JumpZ, AirControl, bOnFire, bDelayDied; // sjs test!
	reliable if(Role < ROLE_Authority)
		/*Health,*/ GiveHealth, DemandRespawn, Revive;	// need to send health to the server or the healing tool doesn't work properly...
    unreliable if ( !bNetOwner && Role==ROLE_Authority )
		PawnPosition;
	reliable if(Role == ROLE_Authority)
		Weapon, ClientRevive, ClientDelayDied, bPlayingEnterExitAnim;
//	reliable if(Role == ROLE_Authority)
//		ClientSetOnFire;	// set the client on fire
       
    // xPawn replicated properties - moved here to take advantage of native replication
    reliable if (Role==ROLE_Authority)
        ShieldStrength, HitFx, HitFxTicker, bInvis, DriverAnim, DriverAnimR, DriverAnimL, RiderAnim, bIsDriving, bIsGunner;

	// replicated functions sent to server by owning client
	reliable if( Role<ROLE_Authority )
		ServerChangedWeapon;//, SetOnFire;
	// XJ replicate the default weapon
	unreliable if (  bNetDirty &&/* bNetOwner &&*/ (Role==ROLE_Authority))
		DefaultWeapon;//, Weapon;
	unreliable if (Role==ROLE_Authority && bNetDirty)
		DashState;
	unreliable if (bNetInitial || bNetDirty)
		IdleWeaponAnim;
}

simulated native function SetTwistLook( int twist, int look );
simulated native function int Get4WayDirection( );
simulated event SetHeadScale(float NewScale);

native function bool ReachedDestination(Actor Goal);

native simulated function AddControlPt( vector position, vector tangent ); //xmatt
native simulated function DrawSplineListPath(); //xmatt

simulated event int GetRiderYaw();

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( (Controller == None) || Controller.bIsPlayer )
		Destroy();
	else
		Super.Reset();
}

// If returns false, do normal calview anyway
function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation );

function String RetrivePlayerName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.RetrivePlayerName();
	return MenuName;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	MakeNoise(1.0);
}

/* PossessedBy()
 Pawn is possessed by Controller
*/
function PossessedBy(Controller C)
{
	Controller = C;
	NetPriority = 3;

	if ( C.PlayerReplicationInfo != None )
	{
		PlayerReplicationInfo = C.PlayerReplicationInfo;
	}
	if ( C.IsA('PlayerController') )
	{
		if ( Level.NetMode != NM_Standalone )
			RemoteRole = ROLE_AutonomousProxy;
		BecomeViewTarget();
		OwnerName = string(PlayerController(C).Player.SplitIndex);
	}
	else
		RemoteRole = Default.RemoteRole;

	SetOwner(Controller);	// for network replication
	BaseEyeHeight = default.BaseEyeHeight;
	EyeHeight = default.BaseEyeHeight;

	ChangeAnimation();
}

function UnPossessed()
{	
	PlayerReplicationInfo = None;
	SetOwner(None);
	Controller = None;
}

/* PointOfView()
called by controller when possessing this pawn
false = 1st person, true = 3rd person
*/
simulated function bool PointOfView()
{
	return false;
}

function BecomeViewTarget()
{
	bUpdateEyeHeight = true;
}

function DropToGround()
{
	bCollideWorld = True;
	bInterpolating = false;
	if ( Health > 0 )
	{
		SetCollision(true,true,true);
		SetPhysics(PHYS_Falling);
		AmbientSound = None;
		if ( IsHumanControlled() )
			Controller.GotoState(LandMovementState);
	}
}

function bool CanGrabLadder()
{
	return ( bCanClimbLadders 
			&& (Controller != None)
			&& (Physics != PHYS_Ladder)
			&& ((Physics != Phys_Falling) || (abs(Velocity.Z) <= JumpZ)) );
}

event SetWalking(bool bNewIsWalking)
{
	if ( bNewIsWalking != bIsWalking )
	{
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

function bool CanSplash()
{
	if ( (Level.TimeSeconds - SplashTime > 0.25)
		&& ((Physics == PHYS_Falling) || (Physics == PHYS_Flying))
		&& (Abs(Velocity.Z) > 100) )
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
}

function EndClimbLadder(LadderVolume OldLadder)
{
	if ( Controller != None )
		Controller.EndClimbLadder();
	if ( Physics == PHYS_Ladder )
		SetPhysics(PHYS_Falling);
}

function ClimbLadder(LadderVolume L)
{
	OnLadder = L;
	SetPhysics(PHYS_Ladder);
	if ( IsHumanControlled() )
	{
		Controller.GotoState('PlayerClimbing');
	}
	SetRotation(OnLadder.WallDir);
}

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);

	Canvas.DrawText("Animation Action "$AnimAction$" Health "$Health);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("EyeHeight "$Eyeheight$" BaseEyeHeight "$BaseEyeHeight$" Physics Anim "$bPhysicsAnimUpdate);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Controller.DisplayDebug(Canvas,YL,YPos);

	if ( Weapon == None )
	{
		Canvas.SetDrawColor(0,255,0);
		Canvas.DrawText("NO WEAPON");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Weapon.DisplayDebug(Canvas,YL,YPos);
}
		 		
//
// Compute offset for drawing an inventory item.
//
simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;

	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/(Weapon.DisplayFOV) * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() ); // amb - fixed wep fov
	if ( !IsLocallyControlled() )
		DrawOffset.Z += BaseEyeHeight;
	else
	{	
		DrawOffset.Z += EyeHeight;
        // gam ---
        if( bWeaponBob )
		    DrawOffset += WeaponBob(Inv.BobDamping);
        // --- gam
//		log("CDO:  DrawOffset = "$DrawOffset$", LandBob = "$LandBob);
        DrawOffset += CameraShake(); //amb
	}
	return DrawOffset;
}
	
// amb ---
function vector CameraShake()
{
    local vector x, y, z, shakevect;
    local PlayerController pc;

    pc = PlayerController(Controller);
    
    if (pc == None)
        return shakevect;

    GetAxes(pc.Rotation, x, y, z);

    shakevect = pc.ShakeOffset.X * x +
                pc.ShakeOffset.Y * y +
                pc.ShakeOffset.Z * z;

    return shakevect;
}
// --- amb

function vector ModifiedPlayerViewOffset(inventory Inv)
{
	return Inv.PlayerViewOffset;
}

function vector WeaponBob(float BobDamping)
{
	Local Vector WBob;

	WBob = BobDamping * WalkBob;
	//XJ remove additional Z bob
	//WBob.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	return WBob;
}

function CheckBob(float DeltaTime, vector Y)
{
	local float Speed2D, time;

    // gam ---
    if( !bWeaponBob )
    {
		BobTime = 0;
		WalkBob = Vect(0,0,0);
        return;
    }
    // --- gam

	if (Physics == PHYS_Walking )
	{
		Speed2D = VSize(Velocity);
		if ( Speed2D < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);

		time = 4.4*BobTime;
		if(Weapon != none && Weapon.bExtraDamping)
			time = (Exp(abs(sin(time) ) )-1)/(Exp(1)-1);

		WalkBob = Y * Bob * Speed2D * abs(sin(time) );
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime) );

		if ( Speed2D > 10 ) {
			time = 8.8*BobTime;
			if(Weapon != none && Weapon.bExtraDamping)
				time = (Exp(abs(sin(time) ) )-1)/(Exp(1)-1);
//				time = abs(sin(time) );

			WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * abs(sin(time) );
		}
		if ( LandBob > 0.01 && !bIsJumping)
		{
			AppliedBob += FMin(1, 16 * deltatime) * LandBob;
			LandBob *= (1 - 8*Deltatime);
		}

		WalkBob.Y *= 2;
		WalkBob.Z = -WalkBob.Z*2;

//		WalkBob.Z = AppliedBob;
//		log("Pawn.CheckBob:  WalkBob.Z = "$WalkBob.Z$", bJustLanded = "$bJustLanded);
//		bIsJumping = false;
	}
	else if ( Physics == PHYS_Swimming )
	{
		Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
//		bIsJumping = true;
	}
}

/**
 * Called by bots or weapons to indicate a bullet that "whizzed by"
 */
function NotifyBulletMiss( vector Location, int style );
	
//***************************************
// Interface to Pawn's Controller

// return true if controlled by a Player (AI or human)
simulated function bool IsPlayerPawn()
{
	return ( (Controller != None) && Controller.bIsPlayer );
}

// return true if controlled by a real live human
simulated function bool IsHumanControlled()
{
	return ( PlayerController(Controller) != None );
}

// return true if controlled by local (not network) player
simulated function bool IsLocallyControlled()
{
	if ( Level.NetMode == NM_Standalone )
		return true;
	if ( Controller == None )
		return false;
	if ( PlayerController(Controller) == None )
		return true;

	return ( Viewport(PlayerController(Controller).Player) != None );
}

// return true if viewing this pawn in first person pov. useful for determining what and where to spawn effects
simulated function bool IsFirstPerson()
{
    local PlayerController PC;
    if ( Controller == None )
        return false;
    PC = PlayerController(Controller);
    return ( PC != None && !PC.bBehindView && Viewport(PC.Player) != None );
}

simulated function rotator GetViewRotation()
{
	if ( Controller == None )
		return Rotation;
	return Controller.GetViewRotation();
}

simulated function SetViewRotation(rotator NewRotation )
{
	if ( Controller != None )
		Controller.SetRotation(NewRotation);
}

final function bool InGodMode()
{
	return ( (Controller != None) && Controller.bGodMode );
}

final function bool IsMatineeProtected()
{
	return bMatineeProtected;
}

function bool NearMoveTarget()
{
	if ( (Controller == None) || (Controller.MoveTarget == None) )
		return false;

	return ReachedDestination(Controller.MoveTarget);
}

simulated final function bool PressingFire()
{
	return ( (Controller != None) && (Controller.bFire != 0) );
}

simulated final function bool PressingAltFire()
{
	return ( (Controller != None) && (Controller.bAltFire != 0) );
}

function Actor GetMoveTarget()
{	
	if ( Controller == None )
		return None;

	return Controller.MoveTarget;
}

function SetMoveTarget(Actor NewTarget )
{
	if ( Controller != None )
		Controller.MoveTarget = NewTarget;
}

function bool LineOfSightTo(actor Other)
{
	return ( (Controller != None) && Controller.LineOfSightTo(Other) );
} 

simulated final function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	if ( Controller == None )
		return Rotation;

	return Controller.AdjustAim(FiredAmmunition, projStart, aimerror);
}

//XJ: auto aiming
simulated final function rotator AutoAim(vector projStart, Weapon FiredWeapon)
{
	if ( Controller == None )
		return Rotation;

	return Controller.AutoAim(projStart, FiredWeapon);
}

function Actor ShootSpecial(Actor A)
{
	if ( !Controller.bCanDoSpecial || (Weapon == None) )
		return None;

	Controller.FireWeaponAt(A);
	Controller.bFire = 0;
	return A;
}

/* return a value (typically 0 to 1) adjusting pawn's perceived strength if under some special influence (like berserk)
*/
function float AdjustedStrength()
{
	return 0;
}

function HandlePickup(Pickup pick, optional int Amount)
{
	MakeNoise(0.2);
	if ( Controller != None )
		Controller.HandlePickup(pick, Amount);
}

function HandlePickupRefused( Pickup item )
{
}

function ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ReceiveLocalizedMessage( Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type )
{
	if ( PlayerController(Controller) != None )
		PlayerController(Controller).ClientMessage( S, Type );
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Controller != None )
		Controller.Trigger(Other, EventInstigator);
}

//***************************************

function bool CanTrigger(Trigger T)
{
	return true;
}

// amb ---
function CreateInventory(string InventoryClassName)
{
}
// --- amb

// cmr --  functions to abstract game object stuff from unrealpawn so vehicles can use it
function HoldGameObject(Decoration GameObj);

//use this function to get the true gameobject holder (so vehicles can return their driver)
function Pawn GetHolder()
{
	return self;
}

// -- cmr

// cmr -- use this function to get a PRI when the pawn might potentially be driving a vehicle (and thus not have a PRI)
function PlayerReplicationInfo GetRealPRI()
{
	return PlayerReplicationInfo;
}

function GiveWeapon(string aClassName, optional bool bNoInventory )
{
	local class<Weapon> WeaponClass;

	if(aClassName=="") 
	{
		return;
	}

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	GiveWeaponByClass(WeaponClass,bNoInventory);
}

// cmr -- want to be able to give a weapon using a class instead of a string

function GiveWeaponByClass(class<Weapon> WeaponClass, optional bool bNoInventory)
{
	local Weapon NewWeapon;

	if( FindInventoryType(WeaponClass) != None )
		return;
	newWeapon = Spawn(WeaponClass);
	if( newWeapon != None ) {
		newWeapon.GiveTo(self, None, bNoInventory);
		newWeapon.PlaceInLoadout(self);
	}
}
// --- cmr


function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	Texture = NewTexture;
	bUnlit = bLighting;
	if ( Weapon != None )
		Weapon.SetDisplayProperties(Style, Texture, bUnlit);

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	if ( Weapon != None )
		Weapon.SetDefaultDisplayProperties();

	if ( !bUpdatingDisplay && (Inventory != None) )
	{
		bUpdatingDisplay = true;
		Inventory.SetOwnerDisplay();
	}
	bUpdatingDisplay = false;
}

function FinishedInterpolation()
{
	DropToGround();
}

function JumpOutOfWater(vector jumpDir)
{
	Falling();
	Velocity = jumpDir * WaterSpeed;
	Acceleration = jumpDir * AccelRate;
	velocity.Z = FMax(380,JumpZ); //set here so physics uses this for remainder of tick
	bUpAndOut = true;
}

event FellOutOfWorld(eKillZType KillType)
{
	if ( Role < ROLE_Authority )
		return;
	Health = -1;
	SetPhysics(PHYS_None);
	Weapon = None;
	if ( KillType == KILLZ_Suicide )
		Died( None, class'Suicided', Location );	
	else
		Died(None, class'Gibbed', Location);
}

/* ShouldCrouch()
Controller is requesting that pawn crouch
*/
function ShouldCrouch(bool Crouch)
{
	bWantsToCrouch = Crouch;
}

// Stub events called when physics actually allows crouch to begin or end
// use these for changing the animation (if script controlled)
event EndCrouch(float HeightAdjust)
{   
	if(!bUpdateEyeHeight)
         EyeHeight += HeightAdjust;
	OldZ += HeightAdjust;
	BaseEyeHeight = Default.BaseEyeHeight;
	
}

event StartCrouch(float HeightAdjust)
{
    if(!bUpdateEyeHeight)
        EyeHeight -= HeightAdjust;
	OldZ -= HeightAdjust;
	BaseEyeHeight = 0.8 * CrouchHeight;
}

function RestartPlayer();
function AddVelocity( vector NewVelocity)
{
	if ( bIgnoreForces )
		return;
	if ( (Physics == PHYS_Walking)
		|| (((Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) && (NewVelocity.Z > Default.JumpZ)) )
		SetPhysics(PHYS_Falling);
	if ( (Velocity.Z > 380) && (NewVelocity.Z > 0) )
		NewVelocity.Z *= 0.5;
	Velocity += NewVelocity;
}

function KilledBy( pawn EventInstigator )
{
	local Controller Killer;

	Health = 0;
	if ( EventInstigator != None )
		Killer = EventInstigator.Controller;
	Died( Killer, class'Suicided', Location );
}

function TakeFallingDamage()
{
	local float Shake;

	if(bJustDodged && IsHumanControlled()) {
        // for some reason, when dodging, the velocity upon landing is only about 1/10th of an equivalent fall when jumping
		Velocity *= 10;
		bJustDodged = false;
	}
    	
	if(Velocity.Z < -0.5 * MaxFallSpeed)
	{
		MakeNoise(FMin(2.0,-0.5 * Velocity.Z/(FMax(JumpZ, 150.0))));

		if (Velocity.Z < -1 * MaxFallSpeed)
		{
			if ( Role == ROLE_Authority )
			{
				if(Velocity.Z < -FatalFallSpeed)
					// instant kill at sufficiently high speed
					shake = 150;
				else {
					// calculate amount of falling damage
					shake = -(Velocity.Z+MaxFallSpeed)/(FatalFallSpeed-MaxFallSpeed);
					shake = 20*(1-shake)+100*shake;
				}

				TakeDamage(shake, none, Location, vect(0, 0, 0), class'Fell');
//				TakeDamage(-50 * ((Velocity.Z + MaxFallSpeed)*1.5 )/MaxFallSpeed, None, Location, vect(0,0,0), class'Fell');
			}
		}
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
            Controller.DamageShake(Shake);
		}
	}
	else if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
}

function ClientReStart()
{
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();
}

function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetLocation(NewLocation, NewRotation);
}

function ClientSetRotation( rotator NewRotation )
{
	if ( Controller != None )
		Controller.ClientSetRotation(NewRotation);
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if ( Physics == PHYS_Ladder )
		SetRotation(OnLadder.Walldir);
	else
	{
		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
			NewRotation.Pitch = 0;

		SetRotation(NewRotation);
	}
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Controller != None )
		Controller.ClientDying(DamageType, HitLocation);
}

function printrot(rotator r)
{
	log("yaw = "$r.yaw$" pitch = "$r.pitch$" roll = "$r.roll);
}

exec function boneinfo()
{
	log("root rotation is ");
	printrot(GetRootRotation());
	log("pelvis rotation is ");
		printrot(GetBoneRotation('Bip01 pelvis'));
	log("that other rotation is ");
	printrot(GetBoneRotation('Bip01'));
	log("=======================");
}
// jij ---


//=============================================================================
// UDamage stub. FIXME MOVE TO XPAWN
function float EnableUDamage(float amount);

//=============================================================================
// Shield stubs. FIXME MOVE TO XPAWN
function float GetShieldStrengthMax();
function float GetShieldStrength();
function bool AddShieldStrength(int amount);

//=============================================================================
// Inventory related functions.

// amb ---
// check before throwing
simulated function bool CanThrowWeapon()
{
    return (Weapon != None && Weapon.CanThrow());
}

// toss out a weapon
function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;

	Weapon.bTossedOut = true;
	Weapon.velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y); 
}	
// --- amb

// The player/bot wants to select next item
exec function NextItem()
{
	if (SelectedItem==None) {
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	if (SelectedItem.Inventory!=None)
		SelectedItem = SelectedItem.Inventory.SelectNext(); 
	else
		SelectedItem = Inventory.SelectNext();

	if ( SelectedItem == None )
		SelectedItem = Inventory.SelectNext();
}

// FindInventoryType()
// returns the inventory item of the requested class
// if it exists in this pawn's inventory 

function Inventory FindInventoryType( class DesiredClass )
{
	local Inventory Inv;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		if ( Inv.class == DesiredClass )
			return Inv;
	return None;
} 

// Add Item to this pawn's inventory. 
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local actor Last;

	Last = self;
	
	// The item should not have been destroyed if we get here.
	if (NewItem ==None )
		log("tried to add none inventory to "$self);

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( Inv == NewItem )
			return false;
		Last = Inv;
	}

	// Add to back of inventory chain (so minimizes net replication effect).
	NewItem.SetOwner(Self);
	NewItem.Inventory = None;
	Last.Inventory = NewItem;

	if ( Controller != None )
		Controller.NotifyAddInventory(NewItem);
	return true;
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	// If this item is in our inventory chain, unlink it.
	local actor Link;

	if ( Item == Weapon )
		Weapon = None;
	if ( Item == SelectedItem )
		SelectedItem = None;
	for( Link = Self; Link!=None; Link=Link.Inventory )
	{
		if( Link.Inventory == Item )
		{
			Link.Inventory = Item.Inventory;
			Item.Inventory = None;
			break;
		}
	}
	Item.SetOwner(None);
}

// Just changed to pendingWeapon
function ChangedWeapon()
{
    local Weapon OldWeapon;

    if(Weapon != None && Weapon.IsA('VehicleWeapon') )
		// if the player is currently using a vehicle weapon that means they're operating the rider
		// controlled weapon of a vehicle so we don't want to be chaning weapons
		return;

    ServerChangedWeapon(Weapon, PendingWeapon);

    if (Role < ROLE_Authority)
	{
        OldWeapon = Weapon;
        Weapon = PendingWeapon;
		PendingWeapon = None;
		
        if (Weapon != None)
		    Weapon.BringUp(OldWeapon);
    }
}

function name GetWeaponBoneFor(Inventory I)
{
	//return 'righthand';
	return 'weapon_bone';
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
    Weapon = NewWeapon;

    //if (PendingWeapon != None && Level.NetMode == NM_DedicatedServer)
    //    log("Warning: Server somehow got a pending weapon"@PendingWeapon);

    PendingWeapon = None;

	if ( OldWeapon != None )
	{
		OldWeapon.SetDefaultDisplayProperties();
		OldWeapon.DetachFromPawn(self);		
        OldWeapon.GotoState('Hidden');
	}

	if ( Weapon != None )
	{
		Weapon.AttachToPawn(self);
		Weapon.BringUp(OldWeapon);
        PlayWeaponSwitch(NewWeapon);
		
		if(Controller!=None)
			Controller.CalculateThreatLevel();
	}

    Inventory.OwnerEvent('ChangedWeapon'); // tell inventory that weapon changed (in case any effect was being applied)
}

//check if pawn is holding a weapon, if not check it's inventory for best weapon
function CheckCurrentWeapon()
{
	local float rating;

	if ( Inventory == None || Weapon != none)
		return;

    if ( (PendingWeapon == None) )
    {
	    PendingWeapon = Inventory.RecommendWeapon(rating);
	    if ( PendingWeapon == Weapon )
		    PendingWeapon = None;
	    if ( PendingWeapon == None )
    		return;
    }

	if ( Weapon == None )
		ChangedWeapon();
	else if ( Weapon != PendingWeapon )
    {
		Weapon.PutDown();
    }
}


//==============
// Encroachment
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;
		
	if ( ((Controller == None) || !Controller.bIsPlayer || bWarping) && (Pawn(Other) != None) )
		return true;
		
	return false;
}

event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None )
		gibbedBy(Other);
}

function gibbedBy(actor Other)
{
	local Controller Killer;

	if ( Role < ROLE_Authority )
		return;
	if ( Pawn(Other) != None )
		Killer = Pawn(Other).Controller;

	if(Other.IsA('VGVehicle'))
	{
		Died(Killer, class'RunOver', Location);		
		return;
	}

	Died(Killer, class'Gibbed', Location);
}

//Base change - if new base is pawn or decoration, damage based on relative mass and old velocity
// Also, non-players will jump off pawns immediately
function JumpOffPawn()
{
	//cmr make sure the random vector is completely sideways so it always pushes you off 
	//(conceivably, a random vector with z zeroed out could push you almost not at all in a horizontal direction)
	local vector vr;
	vr = VRand();
	vr.z = 0;
	vr = Normal(vr);

	Velocity += (200 + CollisionRadius) * vr;
	Velocity.Z = 200 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	if ( Controller != None )
	{
		Controller.SetFall();
	}
}

singular event BaseChange()
{
	local float decorMass;
	local Pawn P;
	local Vector LandingVelocity;
	local float MaxStompDamage;
	local float MaxStompVelocity;
	local float CappedVelocity;
	local float StompSpeed;

	if ( bInterpolating || bDriver )
		return;

    P = Pawn(Base);


	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if ( P != None )
    {
	    // Pawns can only set base to non-pawns, or pawns which specifically allow it.
	    // Otherwise we do some damage and jump off.

        if ( !P.bCanBeBaseForPawns )
        {
            LandingVelocity = Velocity;

            JumpOffPawn();

            // gam ---
            if( P.IsA('xPawn') )
            {
                MaxStompDamage = (HealthMax * 0.5);
                MaxStompVelocity = 1000.f;
                CappedVelocity = FMin( Abs(LandingVelocity.Z), MaxStompVelocity );
                StompSpeed = CappedVelocity / MaxStompVelocity;

                log("MaxStompDamage:" @ MaxStompDamage );
                log("CappedVelocity:" @ CappedVelocity );
                log("StompSpeed:" @ StompSpeed );
                
                P.TakeDamage( MaxStompDamage * StompSpeed , Self, Location, 0.5 * Velocity, class'DamTypeStomped' );
            }
            else if(! (self.IsA('VGPawn') && P.IsA('VGVehicle')))	// BB
            {
                P.TakeDamage( (1-Velocity.Z/400)* Mass/P.Mass, Self, Location, 0.5 * Velocity, class'Crushed' );
            }
            // --- gam
            
        }
    }
    else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
    {
        decorMass = FMax(Decoration(Base).Mass, 1);
        Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
    }
}

event UpdateEyeHeight( float DeltaTime )
{
	local float smooth, MaxEyeHeight;
	local float OldEyeHeight;
	local Actor HitActor;
	local vector HitLocation,HitNormal;

	if ( Controller == None )
	{
		//cmr -- don't set it to zero, it's only ever used by controlled pawns anyway.
		//EyeHeight = 0;  
		return;
	}

	if ( bTearOff )
	{
		EyeHeight = 0;
		bUpdateEyeHeight = false;
		return;
	}
	HitActor = trace(HitLocation,HitNormal,Location + (CollisionHeight + MAXSTEPHEIGHT) * vect(0,0,1),
					Location + CollisionHeight * vect(0,0,1),true);
	if ( HitActor == None )
		MaxEyeHeight = CollisionHeight + MAXSTEPHEIGHT;
	else
		MaxEyeHeight = HitLocation.Z - Location.Z;
							
	// smooth up/down stairs
	smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
	If( Controller.WantsSmoothedView() )
	{
		OldEyeHeight = EyeHeight;
		EyeHeight = FClamp((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
							-0.5 * CollisionHeight, MaxEyeheight);
	}
	else
	{
		bJustLanded = false;
		EyeHeight = FMin(EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth, MaxEyeHeight);
	}
	Controller.AdjustView(DeltaTime);
}

/* EyePosition()
Called by PlayerController to determine camera position in first person view.  Returns
the offset from the Pawn's location at which to place the camera
*/
function vector EyePosition()
{
	return EyeHeight * vect(0,0,1) + WalkBob;
}

//=============================================================================

simulated event Destroyed()
{
	local Inventory Inv;

	if ( Shadow != None )
		Shadow.Destroy();
	if ( Controller != None && bPlayedDeath==True) // cmr - only call pawndied if the pawn actually died.  This might have undesirable effects if the pawn you control gets destroyed without death.
	{
		//log("CHARLES: Pawndied called from Pawn::Destroyed()");
		Controller.PawnDied(self);
	}
	if ( Role < ROLE_Authority )
		return;
		
	if ( Level.NetMode == NM_Client )
		return;

    while( Inventory != None )
    {
        Inv = Inventory;
        Inv.Destroy();
    }

	Weapon = None;
	Inventory = None;
	Super.Destroyed();
}

//=============================================================================
//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	Super.PreBeginPlay();
	Instigator = self;
	DesiredRotation = Rotation;
	if ( bDeleteMe==1 )
		return;

	if ( BaseEyeHeight == 0 )
		BaseEyeHeight = 0.8 * CollisionHeight;
	EyeHeight = BaseEyeHeight;

	if ( menuname == "" )
		menuname = GetItemName(string(class));
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SplashTime = 0;
	EyeHeight = default.BaseEyeHeight;
	OldRotYaw = Rotation.Yaw;

	// create the ammo pool
//	if(AmmoPool == none) {
//	    AmmoPool = Spawn(class'VGAmmoPoolManager', self);
//		log("created ammo pool, Role = "$Role$", RemoteRole = "$RemoteRole$", bNetOwner = "$bNetOwner);
//	}

	// temporarily allow network players to fully regen ammo until the ammo stations are complete
//	if(Level.Game == none || !Level.Game.bSinglePlayer) {
//		ammoRechargeMax = 100;
//		ammoRechargeFreq = 0.3;
//	}
}

event SetInitialState()
{
	// do this in SetInitialState() instead of PostBeginPlay() since SetInitialState() isn't called
	// for actors loaded from a save game
	//

	local AIScript A;

	// automatically add controller to pawns which were placed in level
	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
	if ( Level.bStartup && (Health > 0) && !bDontPossess )
	{
		// check if I have an AI Script
		if ( AIScriptTag != '' )
		{
			ForEach AllActors(class'AIScript',A,AIScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				A.SpawnControllerFor(self);
				if ( Controller != None )
					return;
			}
		}
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);
			AIController(Controller).Skill += SkillModifier;
		}
	}
	Super.SetInitialState();
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	if ( Role == ROLE_Authority )
		return;
	if ( Controller != None )
	{
		Controller.Pawn = self;
		bUpdateEyeHeight = true;
	} 

	if ( (PlayerReplicationInfo != None) 
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(Controller);
	PlayWaiting();

	// create the ammo pool
//	if(AmmoPool == none) {
//	    AmmoPool = Spawn(class'VGAmmoPoolManager', self);
//		log("created ammo pool, Role = "$Role$", RemoteRole = "$RemoteRole$", bNetOwner = "$bNetOwner);
//	}
}

simulated function SetMesh()
{
    // amb --- mesh is already set
    if (Mesh != None)
        return;
    // --- amb

	LinkMesh( default.mesh );
}

function Gasp();
function SetMovementPhysics();

//mh abstract out so vehicles can be stopped
function StopMoving()
{
	Acceleration = vect(0,0,0);
}

function bool GiveHealth(int HealAmount, int HealMax)
{
	if (Health < HealMax) 
	{
		Health = Min(HealMax, Health + HealAmount);
        return true;
	}
    return false;
}

//cmr -- moved here from xpawn in order to share with vehicles

function CalcDamageDir(vector hitRay, int damage)
{
    local vector x, y, z;
    local float dotx, doty;

    if(Controller == None)
    {
        return;
    }
    GetUnAxes(Controller.Rotation, x, y, z);
    
    dotx = hitRay dot x;
    doty = hitRay dot y;
    
    //log("CalcDamageDir: " @ hitRay @ dotx @ doty @ damage);
    
    if(Abs(dotx) >= Abs(doty))
    {
        if (dotx > 0.f)
        {
            //log("front");
            UpdateDamageDirIntensity(DamageDirFront, damage);
        }
        else
        {
            //log("back");
            UpdateDamageDirIntensity(DamageDirBehind, damage);
        }
    }
    else
    {
        if (doty < 0)
        {
            //log("right");
            UpdateDamageDirIntensity(DamageDirRight, damage);
        }
        else if (doty > 0)
        {
            //log("left");
            UpdateDamageDirIntensity(DamageDirLeft, damage);
        }
    }
}

function UpdateDamageDirIntensity(int i, int damage)
{
    DamageDirIntensity[i] = Clamp(DamageDirIntensity[i] + (120), 0, 255);
}
//-- cmr

function DidDamageTo(Pawn Other);


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	local vector dVel;

	if ( Role < ROLE_Authority )
	{
		return;
	}

	if(instigatedBy != None)
		instigatedBy.DidDamageTo(self);

	if ( damagetype == None )
		warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None && (Controller==None || Controller.bIsRidingVehicle==False))
		SetMovementPhysics();
	
	if(self.IsA('xPawn'))
	{
		actualDamage = damage; // FIXME reducedamage being called by XPawn / Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	}
	else
	{
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	}

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
		return;
	
	if ( Health <= 0 )
	{
		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
        
        if (Killer == None)
            Killer = ProjOwner;

        //log("Pawn::TakeDamage... instigatedBy="$instigatedBy);
        //log("Pawn::TakeDamage... instigatedBy.Controller="$instigatedBy.Controller);
        //log("Pawn::TakeDamage... ProjOwner="$ProjOwner);
        //log("Pawn::TakeDamage... Killer="$Killer);

		if ( bPhysicsAnimUpdate )
		{
			TearOffMomentum = momentum;
			bTearOffSplashDamage = bSplashDamage;
		}

		if(bDelayDied || (damageType.default.bFreezes && !IsHumanControlled() ) ) {
			DelayDied(Killer, damageType, HitLocation);
		}
		else {
			Died(Killer, damageType, HitLocation);
		}

//		if(!bDelayDied)
//			Died(Killer, damageType, HitLocation);
//		else
//			DelayDied(Killer, damageType, HitLocation);
	}
	else
	{
		//XJ: don't move pawn unless there is a lot of momentum
		//RJ: modified this so it doesn't change momentum, intializes a new var
		if ( momentum != Vect(0,0,0) )
		{
			if( VSize(momentum) > 2000.0 )
			{
				dVel = momentum;
				if (Physics == PHYS_Walking)
					dVel.Z = FMax(dVel.Z, 0.4 * VSize(dVel));
				if( ( instigatedBy != None ) && ( instigatedBy == self ) )
					dVel *= 0.6;
				dVel = dVel/Mass;
			}
		}

		if(dVel != vect(0,0,0))
		{
			AddVelocity( dVel ); 
		}
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}
	MakeNoise(1.0); 
}

// CMR - If you use DelayDied, you MUST make sure to call Died() yourself, when you are done.  
function DelayDied(Controller Killer, class<DamageType> damageType, vector HitLocation);


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Inventory Inv; // gam
    local Vector TossVel;

	if ( bDeleteMe==1 )
		return; //already destroyed

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}

	Health = Min(0, Health);

    // amb ---
    if (Weapon != None)
    {
        Weapon.HolderDied();
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
        TossWeapon(TossVel);
    }
    // --- amb

    if(Controller != None)
		Controller.WasKilledBy(Killer);
	Level.Game.Killed(Killer, Controller, self, damageType);
    
	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	Velocity.Z *= 1.3;
	//if ( IsHumanControlled() )
	//	PlayerController(Controller).ForceDeathUpdate();
    //if ( (DamageType != None) && DamageType.default.bAlwaysGibs )
	//	ChunkUp( Rotation, DamageType.default.GibPerterbation );
	//else
	//{
		if ( !IsLocallyControlled() )
			ClientDying(DamageType, HitLocation);
		PlayDying(DamageType, HitLocation);
	//}

    // gam --- Hasten GC

    while( Inventory != None )
    {
        Inv = Inventory;
        Inv.Destroy();
    }

    // --- gam
}

event Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	if ( Controller != None )
		Controller.SetFall();
}

event HitWall(vector HitNormal, actor Wall);

event Landed(vector HitNormal)
{
//	LandBob = FMin(50, abs(0.055*Velocity.Z) )*0.5;
	LandBob = FMin(50, 0.055*Velocity.Z);
//	log("Landed! LandBob = "$LandBob);
	NewTakeFallingDamage();
	if ( Health > 0 )
		PlayLanded(Velocity.Z);
	bJustLanded = true;
}


function NewTakeFallingDamage()
{
	local float diff, damage, a, b;
	local bool bLogFallingDamage;

	bLogFallingDamage=false;

	if(Location.Z > LastFallHeight) //jumped up on something, no damage
	{
		if(bLogFallingDamage) log("no fall "$Location.Z$" vs "$LastFallHeight);
		return;
	}
	if(bLogFallingDamage) log("landed at "$Location.Z);

	diff = LastFallHeight - Location.Z;

	if(bLogFallingDamage) log("Fell "$diff$" units, from "$LastFallHeight);
	if(diff < SafeFallHeight) //safe distance, no damage
	{
		if(bLogFallingDamage) log("safe distance ("$SafeFallHeight$")");
		return;
	}

	if(diff > MaxFallHeight) //kill
	{
		if(bLogFallingDamage) log("kill distance ("$MaxFallHeight$")");
		TakeDamage(KILLDAMAGE, none, Location, vect(0, 0, 0), class'Fell');	
	}
	else //scale damage based on dist between safe and max
	{
		a = diff - SafeFallHeight;
		b = MaxFallHeight - SafeFallHeight;
		damage = (A / b) * 100.0;
		if(bLogFallingDamage) log("Taking damage "$damage$" ratio "$ a $" / "$ b );
		TakeDamage( damage, none, Location, vect(0,0,0), class'Fell');
	}


}


event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (Level.NetMode == NM_Client) || (Controller == None) )
		return;
	if ( HeadVolume.bWaterVolume )
	{
		if (!newHeadVolume.bWaterVolume)
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume.bWaterVolume )
		BreathTime = UnderWaterTime;
}

function bool TouchingWaterVolume()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bWaterVolume )
			return true;
			
	return false;
}

//Pain timer just expired.
//Check what zone I'm in (and which parts are)
//based on that cause damage, and reset BreathTime

function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamageType != ReducedDamageType) 
			&& (V.DamagePerSec > 0) )
			return true;
	return false;
}
	
event BreathTimer()
{
	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
	TakeDrowningDamage();
	if ( Health > 0 )
		BreathTime = 2.0;
}

function TakeDrowningDamage();		

function bool CheckWaterJump(out vector WallNormal)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

	checkpoint = vector(Rotation);
	checkpoint.Z = 0.0;
	checkNorm = Normal(checkpoint);
	checkPoint = Location + CollisionRadius * checkNorm;
	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
	if ( (HitActor != None) && (Pawn(HitActor) == None) )
	{
		WallNormal = -1 * HitNormal;
		start = Location;
		start.Z += 1.1 * MAXSTEPHEIGHT;
		checkPoint = start + 2 * CollisionRadius * checkNorm;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
		if (HitActor == None)
			return true;
	}

	return false;
}

function DoDoubleJump( bool bUpdating );
function bool CanDoubleJump();

//Player Jumped
function bool DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.Difficulty > 2.f) )
				MakeNoise(0.1 * Level.Game.Difficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
		{
			if(AirBase == None)
			{
				Velocity += Base.Velocity; 
			}

		}
		SetPhysics(PHYS_Falling);
        return true;
	}
    return false;
}

/* PlayMoverHitSound()
Mover Hit me, play appropriate sound if any
*/
function PlayMoverHitSound();

function PlayDyingSound();

function PlayHit(float Damage, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	local vector BloodOffset, Mo, HitNormal;
	local class<Effects> DesiredEffect;
	local class<Emitter> DesiredEmitter;
	local class<xEmitter> DesiredxEmitter;
	local class<xEmitterList> DesiredxEmitterList;

	if ( (Damage <= 0) && Controller != None && !Controller.bGodMode )
		return;
		
	if (Damage >= DamageType.Default.DamageThreshold) //spawn some blood
	{
		HitNormal = Normal(HitLocation - Location);
	
		// Play any set effect
		if ( EffectIsRelevant(Location,true) )
		{	
			DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode));

			if ( DesiredEffect != None )
			{
				BloodOffset = 0.2 * CollisionRadius * HitNormal;
				BloodOffset.Z = BloodOffset.Z * 0.5;

				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
			}

			// Spawn any preset emitter
			
			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode)); 		
			if (DesiredEmitter != None)
            {
				spawn(DesiredEmitter,,,HitLocation+HitNormal, Rotator(HitNormal));
			} 
			// XJ: xEmitter support
			DesiredxEmitter = DamageType.Static.GetPawnDamagexEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode)); 		
			if (DesiredxEmitter != None)
				spawn(DesiredxEmitter,,,HitLocation+HitNormal, Rotator(HitNormal)); 
			DesiredxEmitterList = DamageType.Static.GetPawnDamagexEmitterList(HitLocation, Damage, Momentum, self, (Level.bDropDetail || !Level.bHighDetailMode)); 		
			if (DesiredxEmitterList != None)
				spawn(DesiredxEmitterList,,,HitLocation+HitNormal, Rotator(HitNormal));
		}		
	}
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}
	
	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		PlayTakeHit(HitLocation,Damage,damageType);
		LastPainTime = Level.TimeSeconds;
	}
}

/* 
Pawn was killed - detach any controller, and die
*/

// blow up into little pieces (implemented in subclass)		

simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation, optional Controller Killer, optional vector HitLocation  ) // gam
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}
	destroy();
}

State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}

	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
	{
	}

	event FellOutOfWorld(eKillZType KillType)
	{
		if ( KillType != KILLZ_Suicide )
			Destroy();
	}

	function Timer()
	{
		if ( !PlayerCanSeeMe() )
			Destroy();
		else
			SetTimer(2.0, false);	
	}

	function Landed(vector HitNormal)
	{
		local rotator finalRot;

		LandBob = FMin(50, abs(0.055*Velocity.Z) ); 
		if( Velocity.Z < -500 )
			TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , class'Crushed');

		finalRot = Rotation;
		finalRot.Roll = 0;
		finalRot.Pitch = 0;
		setRotation(finalRot);
		if(Physics != PHYS_Karma)
			SetPhysics(PHYS_None);

		SetCollision(true, false, false);

		if ( !IsAnimating(0) )
			LieStill();
	}

	// prone body should have low height, wider radius
	function ReduceCylinder()
	{
		local float OldHeight, OldRadius;
		local vector OldLocation;

		SetCollision(True,False,False);
		OldHeight = CollisionHeight;
		OldRadius = CollisionRadius;
		SetCollisionSize(1.5 * Default.CollisionRadius, CarcassCollisionHeight);
		PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight); // FIXME - changing prepivot isn't safe w/ static meshes
		OldLocation = Location;
		if ( !SetLocation(OldLocation - PrePivot) )
		{
			SetCollisionSize(OldRadius, CollisionHeight);
			if ( !SetLocation(OldLocation - PrePivot) )
			{
				SetCollisionSize(CollisionRadius, OldHeight);
				SetCollision(false, false, false);
				PrePivot = vect(0,0,0);
				if ( !SetLocation(OldLocation) )
					ChunkUp( Rotation, 1.0 ); // gam
			}
		}
		PrePivot = PrePivot + vect(0,0,3);
	}

	function LandThump()
	{
		// animation notify - play sound if actually landed, and animation also shows it
		if ( Physics == PHYS_None)
			bThumped = true;
	}

	event AnimEnd(int Channel)
	{
		if ( Channel != 0 )
			return;
		if ( Physics == PHYS_None )
			LieStill();
		else if ( PhysicsVolume.bWaterVolume )
		{
			bThumped = true;
			LieStill();
		}
	}

	function LieStill()
	{
		if ( !bThumped )
			LandThump();
		if ( CollisionHeight != CarcassCollisionHeight )
			ReduceCylinder();
	}

	singular function BaseChange()
	{
		if( base == None )
			SetPhysics(PHYS_Falling);
		else if ( Pawn(base) != None ) // don't let corpse ride around on someone's head
        	ChunkUp( Rotation, 1.0 ); // gam
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		if(Physics != PHYS_Karma)
			SetPhysics(PHYS_Falling);

		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;
		Velocity += 3 * momentum/(Mass + 200);
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( ((Damage > 30) || !IsAnimating()) && (Health < -80) )
        	ChunkUp( Rotation, DamageType.default.GibPerterbation ); // gam
	}

	function BeginState()
	{
		if ( (LastStartSpot != None) && (LastStartTime - Level.TimeSeconds < 6) )
			LastStartSpot.LastSpawnCampTime = Level.TimeSeconds;
		if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(12.0, false);
		
		if(Physics != PHYS_Karma)
			SetPhysics(PHYS_Falling);
		
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
	}

Begin:
	Sleep(0.2);
	bInvulnerableBody = false;
}

//=============================================================================
// Animation interface for controllers

simulated event SetAnimAction(name NewAction);

/* PlayXXX() function called by controller to play transient animation actions 
*/
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if(self.IsA('VGVehicle') == True)
		GotoState('VehicleDying');
	else GotoState('Dying');

	if ( bPhysicsAnimUpdate )
	{
		bReplicateMovement = false;
		bTearOff = true;
		Velocity += TearOffMomentum;
		if(Physics!=PHYS_Karma)
			SetPhysics(PHYS_Falling);
	}
	bPlayedDeath = true;
}

simulated function PlayFiring(optional float Rate, optional byte FiringMode);
function PlayWeaponSwitch(Weapon NewWeapon);
simulated event StopPlayFiring()
{
	bSteadyFiring = false;
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local Sound DesiredSound;

	if (Damage==0)
		return;
	// 		
	// Play a hit sound according to the DamageType
	// XJ: added Pawn parameter so we can get vehicle sounds too
 	DesiredSound = DamageType.Static.GetPawnDamageSound(self);
	if (DesiredSound != None)
		PlayOwnedSound(DesiredSound,SLOT_Misc,1.0);
}

//=============================================================================
// Pawn internal animation functions

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
}

// Animation group checks (usually implemented in subclass)

function bool CannotJumpNow()
{
	return false;
}

simulated event PlayJump();
simulated event PlayFalling();
simulated function PlayMoving();
simulated function PlayWaiting();

function PlayLanded(float impactVel)
{
	if ( !bPhysicsAnimUpdate )
		PlayLandingAnimation(impactvel);
}

simulated event PlayLandingAnimation(float ImpactVel);

function PlayVictoryAnimation();

// amb ---
simulated function float RateWeapon(Weapon w)
{
    if (Controller != None)
        return Controller.RateWeapon(w);
    else
        return 0.0;
}

simulated function bool IsControlled()
{
    return Controller != None;
}
// --- amb

// (mthorne) start burninating the pawn; used by the napalm rockets, must be overridden in whichever
// subclasses can be ignited (currently VGVehicle and VGPawn)
simulated function SetOnFire()
{
	log("Pawn.SetOnFire:  this method shouldn't be called...");
}

//simulated function ClientSetOnFire(float burnTime, float maxBurnTime)
//{
//}

// if on fire, spread to other actors
event Touch(Actor Other)
{
	Super.Touch(Other);

	if(Other.IsA('Pawn') ) { //&& !(bOnFire && Pawn(Other).bOnFire) )
		if(bOnFire && !Pawn(Other).bOnFire)
			// other needs to be set on fire
			Pawn(Other).SetOnFire();
		else if(!bOnFire && Pawn(Other).bOnFire)
			// self needs to be set on fire
			SetOnFire();
	}
}

// return true if you want to change the deafult output as given in res, based on the input data
// by default, just do whatever Havok thinks is best, so we can actually just return false.
event bool HavokCharacterCollision(HavokCharacterObjectInteractionEvent data, out HavokCharacterObjectInteractionResult res);

// use this to turn havok-character collision on/off
//
native function SetHavokCharacterCollisions( bool bEnable );

// functions for handling ammo pool stuff... modified for new ammo system (6/13/2004)
simulated function AddEnergy(float dt)
{
	local Inventory inv;

	if(ROLE == ROLE_Authority) 
	{
        // go through each weapon in inventory and regen its ammo... each type of ammo maintains its own regen rate
		for(inv = Inventory; inv != none; inv = inv.Inventory) 
		{
			if(inv.IsA('Weapon') )
			{
				Weapon(inv).Ammo[0].Regen(dt);
            }
		}
	}
}

// overridden by those classes that actually have a blur effect that needs to be stopped for some reaons (such as when a matine starts)
simulated function StopBlur()
{
}

// each class that reacts to EMP (ie, can be disabled by the plasma gun) needs to override this lovely method
function EMPHit(bool bEnhanced)
{
}

// tell us that we want to be respawned - NOW!; needs to be overriden to do anything useful
simulated function DemandRespawn()
{
}

simulated function Revive(optional Pawn RevivedBy)
{
}

simulated function ClientRevive()
{
}

simulated function ClientDelayDied()
{
}

// jim:
function bool HasHelmet()
{
    return false;
}

exec function EditWeapon(optional int mode)
{
	if(mode < 0 || mode > 1)
		mode = 0;

	if(Weapon != none)
		ConsoleCommand("editactor CLASS="$Weapon.FireModeClass[mode]$" "$Weapon.FireModeClass[mode].Name);
}

defaultproperties
{
     SafeFallHeight=300
     Health=100
     MaxFallHeight=1200.000000
     HavokCharacterCollisionExtraRadius=1.000000
     DesiredSpeed=1.000000
     MaxDesiredSpeed=1.000000
     HearingThreshold=2800.000000
     SightRadius=5000.000000
     AvgPhysicsTime=0.100000
     GroundSpeed=440.000000
     WaterSpeed=300.000000
     AirSpeed=440.000000
     LadderSpeed=200.000000
     AccelRate=2048.000000
     JumpZ=420.000000
     AirControl=0.050000
     WalkingPct=0.500000
     CrouchedPct=0.500000
     MaxFallSpeed=1000.000000
     FatalFallSpeed=1500.000000
     FlyingBrakeAmount=4.000000
     BaseEyeHeight=64.000000
     EyeHeight=54.000000
     CrouchHeight=40.000000
     CrouchRadius=34.000000
     HealthMax=100.000000
     noise1time=-10.000000
     noise2time=-10.000000
     Bob=0.008000
     SoundDampening=1.000000
     DamageScaling=1.000000
     CarcassCollisionHeight=23.000000
     BaseMovementRate=525.000000
     BlendChangeTime=0.250000
     DamageDirReduction=30.000000
     DamageDirLimit=0.500000
     LandMovementState="PlayerWalking"
     WaterMovementState="PlayerSwimming"
     ControllerClass=Class'Engine.AIController'
     Visibility=128
     bNoOverheat=True
     bCanFall=True
     bJumpCapable=True
     bCanJump=True
     bCanWalk=True
     bLOSHearing=True
     bUseCompressedPosition=True
     bCanHoldGameObjects=True
     bWeaponBob=True
     bAnimateTurn=True
     SoundRadius=9.000000
     CollisionRadius=34.000000
     CollisionHeight=78.000000
     NetPriority=2.000000
     Texture=Texture'Engine.S_Pawn'
     RotationRate=(Pitch=4096,Yaw=20000,Roll=3072)
     DrawType=DT_Mesh
     RemoteRole=ROLE_SimulatedProxy
     SoundVolume=240
     bStasis=True
     bUpdateSimulatedPosition=True
     bTravel=True
     bShouldBaseAtStartup=True
     bOwnerNoSee=True
     bCanTeleport=True
     bDisturbFluidSurface=True
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bRotateToDesired=True
     bNoRepMesh=True
     bDirectional=True
}
