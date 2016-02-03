class VGVehicle extends KPawnArt
	abstract
	native;

#exec OBJ LOAD FILE=..\Textures\PariahVehicleEffectsTextures.utx

var() localized string VehicleName;

// for native access
var const name VehicleDyingStateName;
var const name DelayingDeathStateName;

// for playing the tire slip sound a minimum time slice - mjm
var float   PlayedTireSlipTimeStamp;
var float   MinimumTireSlipTimeStamp;

//AI
var enum EVehicleType
{
     VT_UnSpecified,
     VT_Wheeled,
     VT_Hover,
     VT_Turret
} VehicleType;

// Brought up from VGCarParent so AI can use all subclasses

var float					Brake;				// between 0 and 1
var bool					bBrake;				//if true, brakes should be applied (regardless of throttle);
var (VGSteering) float		MaxSteerAngle;		// Unreal degrees
var float					maxCarSpeed;		//The maximum speed of the car currently being driven.
var float					minTurnRadius;

var transient bool bWillWalk;	//Used during pathfind, truth indicates that the car should include paths that are walk only.
//AI Stuck?
var float StuckLimit;
var float StuckTimer;
var vector StuckLocation;
//New Stuck behaviour
var float ThrottleTime;  //time we begain throttling
var int StuckCount;	//How many times have we been stuck this move?
var float StuckTime; //At what time did we get stuck?

//Extra MoveToward params for use by AI in vehicles
struct native vehMoveTowardParamsStruct
{
	var float approachDist;
	var bool bThrottleForAim;
	var float weaponProjectileSpeed;
	var bool bReverse;
	var bool bAvoidFire;
	var bool bExtraMoveTime;
	var byte AvoidFireSign;
};

var vehMoveTowardParamsStruct vehMoveTowardParams;


// Driver is the current driver for this vehicle if any
var	VGPawn			Driver;
var Weapon			SavedWeapon;	// rider's personal weapon
var Weapon			RiderWeapon;	// weapon for the passenger to control (not on all vehicles)
var bool			bWeaponsNeedOrientation;

var float			ForwardVel; // Component of cars velocity in its forward direction.
var const vector    WorldUp;    // vehicle up vector in world space

var (VGVehicle) float	ChassisMass;

var (VGVehicle) vector	ChassisCOMOffset;
var (VGVehicle) float	ChassisFriction;

var (VGVehicle) float	InAirDownForce;	// extra down force exerted while vehicle is in the air

var (VGVehicle) vector	ExitPos[4];		// Position (rel to vehicle) to put player on exiting.
var (VGVehicle) vector	DrivePos;		// Position (rel to vehicle) to put player on entering.

var (VGVehicle) float		FlipTorque;
var (VGVehicle) float		FlipTime;
var (VGVehicle) float		FlipTimeScale;
var (VGVehicle) float		bJustFlipped;
var (VGVehicle) const float	LastWorldZ; //cmr ugh
var float					InvertedTime;
var float					ClearInvertedTimeDelay;

var	float				TurboTimeLeft;
var(VGVehicle) float	TurboMultiplier;
var(VGVehicle) float	TurboTime;

// generic controls (set by controller, used by concrete derived classes)
var float				Steering; // between -1 and 1
var float				Throttle; // between -1 and 1
var float				Turn;	  // caused by X mouse movement

// Used to prevent triggering sounds continuously
var float				UntilNextImpact;

// If this is true this is a template vehicle which is used when spawning
// new vehicles
//
var (VGVehicle) bool	bTemplate;			// this vehicle is a template
var (VGVehicle) bool	bClassTemplate;		// this vehicle is a template for this vehicle class

var bool				bHandBrake;			// set by VehiclePlayer
var bool				bIsDriven;			// this vehicle is currently being driven
var bool				bWasDriven;			// used to determine when DriverEntered/DriverExited should be called
var	bool				bIsLocked;			// Lock the vehicle so nobody can drive it
var bool				bTurboButton;
var bool				bFreezeOnContact;	// freeze vehicle when it hits the ground
var bool				bContactMade;
var bool				bWaitingForEnterSound;
var bool				bWasAwake;
var (VGVehicle) bool	HideDriver;			// hide driver while driving
var (VGVehicle) bool	ChassisKeepUpright;
var (VGVehicle)	float	UprightStiffness;
var (VGVehicle)	float	UprightDamping;

// repackaging
var	(VGVehicle)	name	DrivingAnim, DrivingAnimR, DrivingAnimL;

var class<VehiclePickup>		DroppedPickupClass;

// Shadows and headlights

var(VGHeadLight) const bool		bEnableLights;
var(VGHeadLight) const bool		bEnableHeadLightProjector;
var(VGHeadLight) const bool		bEnableHeadLightEmitter;
var(VGShadow) const bool		bEnableShadow;
var(VGTailLight) const bool		bEnableBrakeTailLights;
var(VGTailLight) const bool		bEnableBackupTailLights;
var(VGTailLight) const bool		bEnableDrivingTailLights;

var(VGHeadLight) vector					LightOffset;
var(VGHeadLight) float					LightSeparation;
var(VGHeadLight) rotator				LightRotation;

// taillight - indicates if you are braking/reversing
var Actor					TailLights[2];
var (VGTailLight) vector	TailLightOffset;
var (VGTailLight) float		TailLightSeparation;
var (VGTailLight) byte		TailLightBrakeHue;
var (VGTailLight) byte		TailLightBrakeSaturation;
var (VGTailLight) byte		TailLightBrakeBrightness;
var (VGTailLight) byte		TailLightBackupHue;
var (VGTailLight) byte		TailLightBackupSaturation;
var (VGTailLight) byte		TailLightBackupBrightness;
var (VGTailLight) byte		TailLightDrivingHue;
var (VGTailLight) byte		TailLightDrivingSaturation;
var (VGTailLight) byte		TailLightDrivingBrightness;

var (VGHeadLight) byte		HeadLightHue;
var (VGHeadLight) byte		HeadLightSaturation;
var (VGHeadLight) byte		HeadLightBrightness;
var (VGHeadLight) float		HeadLightProjectorDistance;
var (VGHeadlight) float		HeadLightReattachDistance;

var(VGShadow) vector					ShadowOffset;
var(VGShadow) rotator					ShadowRot;
var(VGShadow) class<xShadowProjector>	ShadowClass;
var(VGShadow) Material					ShadowTexture;
var(VGShadow) float						ShadowDrawScale;
var(VGShadow) float						ShadowProjectorDistance;
var(VGShadow) float						ShadowReattachDistance;

var(VGGenShadow) bool					bGenerateVehicleShadow;
var ShadowProjector						GeneratedVehicleShadow;
var(VGGenShadow) StaticMesh				GeneratedVehicleShadowMesh;	// use this for shadows instead of full blown vehicle
var(VGGenShadow) float					GeneratedShadowFOVMult;
var(VGGenShadow) float					GeneratedShadowMaxTraceDistance;
var(VGGenShadow) bool					bGeneratedShadowUseSunlightDir;
var(VGGenShadow) vector					GeneratedShadowLightDir;
var(VGGenShadow) float					GeneratedShadowLightDistance;
var(VGGenShadow) float					GeneratedShadowCullDistance;
var(VGGenShadow) float					GeneratedShadowStartFadeDistance;
var(VGGenShadow) byte					GeneratedShadowDarkness;

var Emitter					DeathEmitter;
var(VGVehicle) vector		DeathEmitterOffset;

var	Emitter						ImpactEmitter;
var class<VehicleImpactEffect>	ImpactEffect;
var (VGVehicle) float			ImpactEffectThreshold;
var float						ImpactEffectThresholdSqr;

const	ImpactEffectLifeSpan = 0.5;
const	ImpactEffectTimerSlot = 0;

var array<Actor>				VehicleActors;


//weapon locations/rotations
const	MaxWeaponMounts = 4;
var (VGVehicle)		int			WeaponMounts;
var	(DefaultWeapon) string		DefaultWeaponName;
var (WeaponMount)	Name		WeaponMountName[MaxWeaponMounts];

// camera parameters used by VehiclePlayer
//
var (VGCamera) float	campitch;
var (VGCamera) float	camdist;
var (VGCamera) float	camheight;
var (VGCamera) float	caminterpyawspeed;

var (VGSteering) float	LookAngleForMaxSteer;	// used when looksteer steering is enabled
var (VGSteering) float	LookSteerMinPitch;		// really camera parameters related to looksteer steering
var (VGSteering) float	LookSteerMaxPitch;

// Sounds
//
var (VGSounds) sound	EnterVehicleSound;
var (VGSounds) sound	ExitVehicleSound;
var (VGSounds) sound	TurboSound;
var (VGSounds) sound	EngineSound;
var (VGSounds) sound	HitSound;
var (VGSounds) sound	DeathSound;
var (VGSounds) byte		EnterVehicleSoundVolume;
var (VGSounds) byte		ExitVehicleSoundVolume;
var (VGSounds) byte		TurboSoundVolume;
var (VGSounds) byte		EngineSoundPitch;
var (VGSounds) byte		EngineSoundVolume;
var (VGSounds) byte		HitSoundMaxVolume;
var (VGSounds) byte		DeathSoundVolume;
var (VGSounds) byte		MasterVehicleSoundVolume;
var (VGSounds) float	HitSoundMinImpactThreshold;
var (VGSounds) float	HitSoundMaxImpactThreshold;

var (VGSounds) float	EngineSoundPitchScale;
var (VGSounds) float	EngineSoundVolumeScale;
var (VGSounds) float	ReverseSoundPitchScale;
var (VGSounds) float	ReverseSoundVolumeScale;
var (VGSounds) float	ReverseSoundMinVelocity;
var (VGSounds) sound	ReverseSound;
var (VGSounds) byte		ReverseSoundPitch;
var (VGSounds) byte		ReverseSoundVolume;

struct native EngineSoundParameter
{
	var () sound	Sound;
	var () sound	SwitchUpSound;
	var () sound	SwitchDownSound;
	var () byte		Pitch;
	var () byte		Volume;
	var () byte		SwitchUpVolume;
	var () byte		SwitchDownVolume;
	var () float	PitchScale;
	var () float	VolumeScale;
	var () float	MaxSoundScale;
};
var (VGSounds) array<EngineSoundParameter>	EngineMultiSounds;
var transient int							CurEngineMultiSound;

var (VGSounds) enum EngineSoundScaleSource
{
	ESS_EngineRPS,
	ESS_EngineTorque,
	ESS_WheelRPS,
	ESS_VehicleSpeed
} EngineSoundScaler;

// these are here so they can be shared between karma and havok vehicles
var (VGSounds) sound		TireSlipSound;
var (VGSounds) sound		TireImpactSound;
var (VGSounds) const float	TireSlipSoundMinSlipVel;
var (VGSounds) const float	TireSlipSoundMaxSlipVel;
var (VGSounds) const byte	TireSlipSoundMaxVolume;
var (VGSounds) byte			TireImpactSoundMaxVolume;
var (VGSounds) float		TireImpactSoundMinImpactThreshold;
var (VGSounds) float		TireImpactSoundMaxImpactThreshold;

var Pawn SavedKiller;

var float DeltaTimeSum;

enum EPhysicsAttachType
{
	KSA_BallAndSocket,
	KSA_Hinge,
	KSA_Prismatic
};

var enum EDriverState
{
	DS_Team0,
	DS_Team1,
	DS_NoDriver
}DriverState;

// Support for attaching skeletons to vehicles
struct native AttachedSkelInfo
{
	var () EPhysicsAttachType	AttachType;
	var () mesh					SkeletonMesh;
	var () string				SkeletonAssetName;
	var () vector				AttachOffset;
	var () rotator				AttachRotation;
	var () float				AttachStiffness;
	var () float				AttachDamping;
};
var (VGAttachments) export editinline array<AttachedSkelInfo>		SkelAttachments;

var (VGAttachments) export editinline array<VGDamageablePartInfo>	DamageableParts;
var array<VGDamageablePart>											CreatedDamageableParts;

// this array of damage info corresponds to the CreatedDamageableParts array
// - it is separated out because it needs to be replicated to clients in net play
// - it also needs to be fixed size since dynamic arrays aren't replicated right now
//
const MaxDamageableParts = 18;

struct native DamageablePartDamage
{
	var float	ImpactDamage;
	var float	OtherDamage;
	var byte	Revision;	// increased when damage is changed
};
var DamageablePartDamage	PartDamage[MaxDamageableParts];			// this is replicated
var byte					LastPartDamageRev[MaxDamageableParts];	// this isn't replicated

var (VGVehicle) float MinRamSpeed;
var (VGVehicle) float MaxRamSpeed;
var (VGVehicle) float RammingDamage;
var	(VGVehicle) float RammingDamageMultiplier;
var	(VGVehicle) float RammingVelocityMultiplier;
var				Powerups	Affector;
var	(VGVehicle)	vector		BatteringRamOffset;
var	(VGVehicle)	rotator		BatteringRamRotation;

var (VGVehicle) float RammingTimeout;

var bool bDeliverRammingDamage;
var float RammingDamageAmount;
var Actor RammingDamageTarget;
var vector RamLocation, RamVelocity;

var (VGVehicle) bool bNeedsPlayerOwner;
var VGPawn PlayerOwner;
var float UnownedTime;
var float TimeTillDeath;

var bool bUntouched;
var VehicleStart myStart;


// various overlay Material effects
var Material	LockedEffectMaterial;


// CMR - DelayDied saved variables (no use otherwise, so don't use them)
var Controller DelayedKiller;
var class<DamageType> DelayedDamageType;
var bool bDelayingDeath;	// for networking

//MH This is the mesh to be displayed in the vehicle selection menu
var StaticMesh MenuStaticMesh;

var bool				bServerTakeControlRequest;	// if true, server will take control the next tick
var bool				bServerTakeControl;			// this is set to true if server should take control of vehicle
var bool				bServerWasControlling;		// used to determine first frame after server takes control
var transient float		ServerControlCountdown;
var config float		MaxAllowableServerError;	// max allowable error between client and server before server takes over	

//cmr -- passenger stuff

var() float		MaxEnterDistance;

const MAXDRIVERENTRIES=2;

var() Name			DriverPointName;
var() array<Name>	DriverEntryNames;

var Vector DriverEntryPoints[MAXDRIVERENTRIES];
var Name DriverEntryAnims[MAXDRIVERENTRIES];
var Name DriverExitAnim;
var byte DriverEntryPointCount;
var array<EntryPoint>	DriverEntryPointActors;

var byte DriverEnteringFromIndex;

const MAXPASSENGERS=3;

var() array<Name>	PassengerPointNames;
var() array<Name>	PassengerPointEntryNames;
var Vector PassengerEntryPoints[MAXPASSENGERS];
var Name PassengerEntryAnims[MAXPASSENGERS];
var Vector	PassengerPoints[MAXPASSENGERS];
var array<EntryPoint>	PassengerEntryPointActors;

var () name	RiderAnims[MAXPASSENGERS];
var () byte	IsGunnerSpot[MAXPASSENGERS];
var Name GunnerExitAnim;

struct native PassengerCamInfo
{
	var bool bUse3rdPerson;
	var bool bLimitYaw;
	var int CenterYaw;
	var int MaxYaw;
};

var PassengerCamInfo PassengerCameras[MAXPASSENGERS];

//not on client
var byte PassengerPointsUsed[MAXPASSENGERS];
var byte PassengerPointCount;
var Pawn Passengers[MAXPASSENGERS];
var byte SpawnedByTeam;


//--- cmr

// --- Single player changes CMR

var(SinglePlayer) bool bIndestructible;
var(SinglePlayer) array<string> DefaultWeapons;


// --- CMR

// rj@bb ---
// attached static meshes
enum ASMUpVectorSource
{
	ASMU_None,
	ASMU_Base,
	ASMU_Target,
	ASMU_Actor
};

enum ASMOffsetMode
{
	ASMO_Default,
	ASMO_UseBaseRotation,
	ASMO_UseTargetRotation,
	ASMO_UseActorRotation
};

struct native AttachedStaticMesh
{
	var() StaticMesh		StaticMesh;

	// if this is > 0, this is the maximum distance from the viewer for which this mesh will be
	// rendered
	// - this distance is relative to the vehicle
	//
	var() float				MaxRenderDistSquared;

	// these determine where to place the static mesh
	var() int				BaseIndex;		// index into AttachedStaticMeshes - 1 based
	var() Actor				BaseActor;		// only used if BaseIndex == 0
	var() vector			BaseOffset;
	var int		BaseRevision;	// last revision of whatever was used for base

	// this determines how to orient the static mesh if UseBaseRotation is True
	var() rotator			BaseRotation;

	// these determine how to orient the static mesh if UseBaseRotation is False
	var() int				TargetIndex;	// index into AttachedStaticMeshes - 1 based
	var() Actor				TargetActor;	// only used if TargetIndex == 0
	var() vector			TargetOffset;
	var int		TargetRevision;	// last revision of whatever was used for target

	var() ASMUpVectorSource	UpVectorFrom;
	var() ASMOffsetMode		BaseOffsetMode;
	var() ASMOffsetMode		TargetOffsetMode;

	var() vector			DrawScale;

	var vector	Location;
	var rotator	Rotation;
	var int		Revision;
	var Matrix	LocalToWorld;
	var Matrix	WorldToLocal;
	var float		Determinant;

	// put all bools together for better packing
	var() bool				Unused;					// turn this on if this slot becomes unused
	var() bool				UseBaseRotation;		// if true, ignore target stuff and use BaseRotation for orientation
	var() bool				BaseIsAbsolute;			// if true, ignore base stuff and use BaseOffset as absolute location
	var() bool				AlwaysUpdatePosition;	// location/rotation always needs update even when mesh isn't rendered
	var bool				PositionChanged;		// internal use - the position/rotation has been modified
	var bool				PositionChecked;		// internal use - a check was made to see if position needed update
	var bool				BaseOffsetChanged;		// internal use - the base offset/rotation was changed
};
var array<AttachedStaticMesh>	AttachedStaticMeshes;
// --- rj@bb

struct native EffectInfo
{
	var () bool											OnWhenCarEmpty;
	var () vector										Location;
	var () export editinline array<VehicleEffectInfo>	Effects;
	var array<Emitter>									Emitters;
};
var (VGVehicleEffects) export editinline array<EffectInfo>			CarEffects;

var int nEMPHitCount;	// number of times vehicle has been hit with an EMP (only reenable when it hits zero)
var float fEMPTime;
var float fEMPTimer;

// the number of bodies that make up this vehicle
// - this includes the vehicle plus all bodies connected via non-contact constraints
// - external classes should use GetNumBodies()
//
var private transient int			NumBodies;

// put this here so havok and karma vehicles can use it
//
enum VGDecoPieceLocation
{
	SPL_Chassis,			// relative to chassis
	SPL_ChassisWheelPos,	// relative to this wheel's position on the chassis
	SPL_Wheel,				// wheel associated with this suspension piece
	SPL_Piece0,				// other suspension pieces
	SPL_Piece1,
	SPL_Piece2,
	SPL_Wheel0,				// relative to the specified wheel
	SPL_Wheel1,
	SPL_Wheel2,
	SPL_Wheel3,
};

struct native VGDecoPiece
{
	var () VGDecoPieceLocation	Base;
	var () vector				BaseOffset;
	var () VGDecoPieceLocation	Target;
	var () vector				TargetOffset;
	var () StaticMesh			StaticMesh;
};

struct native VGDecoAssemblyInfo
{
	var () export array<VGDecoPiece>	DecoPieces;
	var () float						MaxDrawDistance;
};

var (VGBrakes) float	ExitBrakeTime;			// when driver exits, this is how long it takes for brakes to come on fully
var float				CurExitBrakeTime;		// length of time driver has been out of car

var class<VehicleSavedMove>	 SavedMoveClass;	// for vehicle networking

// stuff for setting on fire
var ParticleSmallFire Fire;
var float burningTime;
var float maxBurningTime;
var float lastFireDamageTime;
var float fireDamageFreq;
var int fireDamagePerInterval;
var array<float> fireDecreaseAt;
var Pawn FireInstigator;
var class<DamageType> BurnDamageType;

var(VGDestruction) bool  bCauseHurtOnDestruction;
var(VGDestruction) float DestructionHurtDamage;
var(VGDestruction) float DestructionHurtRadius;
var(VGDestruction) float DestructionHurtMomentum;
var(VGDestruction) class<DamageType> DestructionHurtDamageType;

var(SingleplayerEvents) name DriverEnterEvent, DriverExitEvent, RiderEnterEvent, RiderExitEvent, FlipEvent, DestroyEvent;

enum EPlayerVehicleAction
{
	PVA_Driver,
	PVA_Rider,
	PVA_Gunner,
	PVA_Flip,
	PVA_None
};

var(VGVehicle) float StopEngineSoundSpeed; // jjs - speed below which engine sound is turned off (stalls)

// classes to preload if this class is instantiated
//
var array<string>	PreLoadClasses;

replication
{
	unreliable if ( Role == ROLE_Authority )
		UnownedTime, bIsDriven, InvertedTime, bDelayingDeath, PartDamage, RiderWeapon, SavedWeapon, bBrake;
	unreliable if ( Role == ROLE_Authority )
		Driver, DriverState, PassengerPointsUsed, Passengers, bIsLocked, Fire;
	unreliable if ( Role == ROLE_Authority && bNetInitial )
		PassengerPoints,PassengerPointCount;
	reliable if ( Role == ROLE_Authority )
		ClientServerTakingControl, ClientServerRelinquishingControl, ClientEndRide;
}

native final function EPlayerVehicleAction GetPlayerVehicleAction(Pawn Candidate);

simulated event UpdateRiderEffects()
{
	if(Driver != None)
	{
		Driver.PawnSteering = Steering;
	}
}

simulated event ClientServerTakingControl()
{
	GLog( RJ3, "VGVehicle::ClientServerTakingControl" );
}

simulated event ClientServerRelinquishingControl()
{
	GLog( RJ3, "VGVehicle::ClientServerRelinquishingControl" );
}

event ServerTakingControl()
{
	GLog( RJ3, "ServerTakingControl" );
	ClientServerTakingControl();
}

event ServerRelinquishingControl()
{
	GLog( RJ3, "ServerRelinquishingControl" );
	ClientServerRelinquishingControl();
}

function ChangedWeapon()
{
    local Weapon OldWeapon;

    ServerChangedWeapon(Weapon, PendingWeapon);

    if (Role < ROLE_Authority)
	{
        OldWeapon = Weapon;
        Weapon = PendingWeapon;
		PendingWeapon = None;

        //if (Weapon != None)
		//    Weapon.BringUp(OldWeapon);
    }
}


simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if ( bTemplate && Owner == None )
	{
		bIgnoreOutOfWorld = True;
		SetPhysics( PHYS_None );
	}
	else
	{
		// make sure it isn't used as a template
		//
		bTemplate=False;
		bClassTemplate=False;

		bHidden=False;
		InitializeVehicle();
		KPawnArtUpdateParams();	// make sure params are up to date


		// cmr ---
		if(Level.Game != None && Level.Game.IsA('SinglePlayer'))
		{
			if(!(Owner!=None && Owner.IsA('VehicleMarker'))) //cmr -- ARGH.  four bajillion ways of adding weapons to vehicles, this SUCKS.
			{
				SetupVehicleWeapons();
/*				for(i=0;i<DefaultWeapons.Length;i++)
				{
					if(DefaultWeapons[i] != "")
					{
						GiveWeapon(DefaultWeapons[i]);
						c++;
					}
				}
				if(c==0)
				{
					GiveWeapon("VehicleWeapons.Puncher");
				}*/
			}

			//don't need an owner in single player.
			bNeedsPlayerOwner=False;
			CheckCurrentWeapon();
		}
		// --- cmr
//		else if(Level.Game == none)
//			SetupVehicleWeaponOrientation();
	}
}

simulated function SetOverlayMaterial(Material mat,optional bool bTimed,optional float time,optional bool bOverride,optional bool bRevert)
{
	local int i;

	Super.SetOverlayMaterial(mat,bTimed,time,bOverride,bRevert);
	for(i=0;i<VehicleActors.Length;i++)
	{
		if(VehicleActors[i] != none)
			VehicleActors[i].SetOverlayMaterial(mat,bTimed,time,bOverride,bRevert);
	}
}

simulated function RemoveOverlayMaterial()
{
	local int i;

	Super.RemoveOverlayMaterial();
	for(i=0;i<VehicleActors.Length;i++)
	{
		if(VehicleActors[i] != none)
			VehicleActors[i].RemoveOverlayMaterial();
	}
}

simulated function LockVehicle()
{
	bIsLocked=true;
	SetOverlayMaterial(LockedEffectMaterial,false,0.0,true);
}

simulated function UnlockVehicle()
{
	bIsLocked=false;
	RemoveOverlayMaterial();
}

//no tossing of weapons for vehicles
function TossWeapon(vector TossVel)
{
}

//XJ default weapon stuff
function GiveDefaultWeapon()
{
}
/////////



function AttachTo(Actor A, vector offset, rotator rotation)
{
	A.SetBase(self);
	A.SetRelativeLocation(offset);
	A.SetRelativeRotation(rotation);
}

simulated function InitializeVehicle()
{
	local int i;
	//local vector v;
	local rotator r;
	local int ei, ve;
	local rotator NoRot;
	local Vector v;


	AddLightTag( 'VEHICLE' );
	if ( Level.bVehiclesExclusivelyLit )
	{
		bMatchLightTags=True;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		CreateLights();
		if( bEnableShadow )
		{
			if ( !IsOnConsole() )
			{
				// force generated shadows on PC, since they are so cool! (rj)
				//
				bGenerateVehicleShadow=true;
			}
			CreateShadow();
		}

		// square impact effect threshold for faster checks in KImpact
		//
		ImpactEffectThresholdSqr = ImpactEffectThreshold * ImpactEffectThreshold;

		for ( ei = 0; ei < CarEffects.Length; ei++ )
		{
			for ( ve = 0; ve < CarEffects[ei].Effects.Length; ve++ )
			{
				if ( ve == CarEffects[ei].Emitters.Length )
				{
					CarEffects[ei].Emitters.Length = CarEffects[ei].Emitters.Length + 1;
					CarEffects[ei].Effects[ve].CreateEmitterAt(
						self,
						CarEffects[ei].Location,
						NoRot,
						CarEffects[ei].Emitters[ve]
						);
						AddVehicleActor( CarEffects[ei].Emitters[ve] );
				}
			}
		}
	}

	//get driver entry points

	if(DriverEntryNames.Length > 0)
	{
		DriverEntryPointCount = DriverEntryNames.Length;
		for(i=0;i<DriverEntryNames.Length;i++)
		{
			GetAttachPoint(DriverEntryNames[i],v,r);
			DriverEntryPoints[i] = v;
			DriverEntryPointActors[i] = spawn(class'EntryPoint', self, ,Location + (v>>Rotation) );
			AttachTo( DriverEntryPointActors[i], v, Rot(0,0,0));
			DriverEntryPointActors[i].SetOwner(self);
		}
	}

	//get passenger points
	if(PassengerPointNames.Length > 0)
	{
		PassengerPointCount = PassengerPointNames.Length;
		for(i=0;i<PassengerPointCount;i++)
		{
			GetAttachPoint(PassengerPointNames[i],PassengerPoints[i],r);
		}
	}

	if(PassengerPointEntryNames.Length > 0)
	{
		for(i=0;i<PassengerPointEntryNames.Length;i++)
		{
			GetAttachPoint(PassengerPointEntryNames[i],v,r);
			PassengerEntryPoints[i] = v;
			PassengerEntryPointActors[i] = spawn(class'EntryPoint', self, ,Location + (v>>Rotation) );
			AttachTo(PassengerEntryPointActors[i], v, Rot(0,0,0));
			PassengerEntryPointActors[i].SetOwner(self);
		}
	}

	// create damageable parts
	//
	for ( i = 0; i < DamageableParts.Length; ++i )
	{
		CreateDamageablePart( DamageableParts[i] );
	}

	InitializeAILookUps();
}

simulated function CreateDamageablePart(
	VGDamageablePartInfo Info
)
{
	local VGDamageablePart	 part;
	local int				 i;

	if ( Info != None )
	{
		part = spawn( class'VGDamageablePart', self );
		part.InitializePart( self, Info );
		i = CreatedDamageableParts.Length;
		CreatedDamageableParts.Length = i + 1;
		CreatedDamageableParts[i] = part;
		if ( Role == ROLE_Authority )
		{
			assert( i < MaxDamageableParts );
			PartDamage[i].OtherDamage = 0;
			PartDamage[i].ImpactDamage = 0;
			PartDamage[i].Revision = 0;
		}
		LastPartDamageRev[i] = 0;
	}
}

simulated function AddCarEffect( vector Loc, array<VehicleEffectInfo> Effects )
{
	local int	e;

	e = CarEffects.Length;
	CarEffects.Length = e + 1;
	CarEffects[e].Location = Loc;
	CarEffects[e].Effects = Effects;
}

simulated function AddVehicleActor( Actor part )
{
	VehicleActors.Length = VehicleActors.Length + 1;
	VehicleActors[VehicleActors.Length - 1] = part;
	part.AddLightTag( 'VEHICLE' );
	if ( Level.bVehiclesExclusivelyLit )
	{
		part.bMatchLightTags=True;
	}

	// only add actor to generated vehicle shadow if there isn't a shadow mesh
	//
	if ( GeneratedVehicleShadow != None && GeneratedVehicleShadowMesh == None )
	{
		GeneratedVehicleShadow.AddExtraShadowActor( part );
	}
}

simulated function int NewAttachedStaticMesh()
{
	local int i;

	for ( i = 0; i < AttachedStaticMeshes.Length; ++i )
	{
		if ( AttachedStaticMeshes[i].Unused )
		{
			AttachedStaticMeshes[i].Unused = False;
			return i;
		}
	}
	AttachedStaticMeshes.Length = i + 1;
	return i;
}

simulated function int AddAttachedStaticMesh( AttachedStaticMesh asm )
{
	local int i;

	i = NewAttachedStaticMesh();
	AttachedStaticMeshes[i] = asm;
	return i;
}

function Pawn GetHolder()
{
	return Driver;
}

function HoldGameObject(Decoration gameObj)
{
	Driver.HoldGameObject(gameObj);
}

simulated event Destroyed()
{
	local int i;

	glog( RJ2, "VGVehicle::Destroyed() called" );

	// destroy generated shadow before vehicle actors so there is no chance it references deleted actors
	//
	if ( GeneratedVehicleShadow != None )
	{
		GeneratedVehicleShadow.Destroy();
		GeneratedVehicleShadow = None;
	}

	for ( i = VehicleActors.Length - 1; i >= 0; i-- )
	{
		if ( VehicleActors[i] != None )
		{
			VehicleActors[i].Destroy();
		}
	}
	VehicleActors.Length = 0;

	if(DeathEmitter != None)
	{
		DeathEmitter.Destroy();
		DeathEmitter = None;
	}

	if(Fire != none)
		Fire.Destroy();

	if(RiderWeapon != none)
	{
		RiderWeapon.Destroy();
		RiderWeapon = none;
	}

	for( i = 0; i < CreatedDamageableParts.Length; ++i)
	{
	    if(CreatedDamageableParts[i] != None)
	    {
	        CreatedDamageableParts[i].Destroy();
	    }
	}
	
	if(DestroyEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
	{
	    log("firing off event "$DestroyEvent);
        TriggerEvent(DestroyEvent, self, Driver);
	}

	Super.Destroyed();
}

simulated function CreateLights()
{
	local vector RotX, RotY, RotZ;
	local Actor act;
	local rotator rot;
	local xDynamicProjector proj;
    GetAxes(Rotation,RotX,RotY,RotZ);

	if ( bEnableLights )
	{
		act = spawn(class'AutoHeadLight', self,,Location + LightOffset.X * RotX + (LightOffset.Y+LightSeparation) * RotY + LightOffset.Z * RotZ, Rotation + LightRotation);
		act.SetBase(self);
		AddVehicleActor( act );
		act.LightHue = HeadLightHue;
		act.LightSaturation = 255 - HeadLightSaturation;
		act.CoronaBrightness = HeadLightBrightness;

		if ( LightSeparation > 0 )
		{
			act = spawn(class'AutoHeadLight', self,,Location + LightOffset.X * RotX + (LightOffset.Y-LightSeparation) * RotY + LightOffset.Z * RotZ ,Rotation + LightRotation);
			act.SetBase(self);
			AddVehicleActor( act );
			act.LightHue = HeadLightHue;
			act.LightSaturation = 255 - HeadLightSaturation;
			act.CoronaBrightness = HeadLightBrightness;
		}
	}
	if ( bEnableHeadLightEmitter )
	{
		rot.Pitch = -1000;
		act = spawn(class'HeadlightEmitter', self,,Location + LightOffset.X * RotX + (LightOffset.Y+LightSeparation) * RotY + LightOffset.Z * RotZ, Rotation + rot);
		act.SetBase(self);
		AddVehicleActor( act );

		if ( LightSeparation > 0 )
		{
			act = spawn(class'HeadlightEmitter', self,,Location + LightOffset.X * RotX + (LightOffset.Y-LightSeparation) * RotY + LightOffset.Z * RotZ ,Rotation + rot);
			act.SetBase(self);
			AddVehicleActor( act );
		}
	}
	if ( bEnableHeadLightProjector )
	{
		proj = spawn(class'AutoHeadLightProjector', self,,Location + LightOffset.X*RotX + LightOffset.Y*RotY + LightOffset.Z*RotZ, Rotation + LightRotation);
		proj.SetBase(self);
		AddVehicleActor( proj );
		proj.MaxTraceDistance = HeadLightProjectorDistance;
		proj.ReattachMinDistChange = HeadLightReattachDistance * HeadLightReattachDistance;	// it's dist squared
		proj.ReattachMaxDistChange = 4 * proj.ReattachMinDistChange;
	}

	if ( bEnableBrakeTailLights || bEnableBackupTailLights || bEnableDrivingTailLights )
	{
		TailLights[0] = spawn(class'TailLight', self,, Location + TaillightOffset.X * RotX + (TaillightOffset.Y+TailLightSeparation) * RotY + TaillightOffset.Z * RotZ);
		TailLights[0].SetBase(self);
		AddVehicleActor( TailLights[0] );

		if ( TailLightSeparation > 0 )
		{
			TailLights[1] = spawn(class'TailLight', self,, Location + TaillightOffset.X * RotX + (TaillightOffset.Y-TailLightSeparation) * RotY + TaillightOffset.Z * RotZ);
			TailLights[1].SetBase(self);
			AddVehicleActor( TailLights[1] );
		}
	}
}

simulated function CreateShadow()
{
	local xShadowProjector VehicleShadow;
	local vector RotX, RotY, RotZ;
	local ShadowProjector GVehicleShadow;
	local Light l, Sun;
	local vector LightDir;
	local float Brightness;
	local int i;
	local VGVehicleShadowProxy proxy;

	// don't bother with shadows if all we got is assy blob shadows
	//
	if ( bGenerateVehicleShadow && UsingHighDetailShadows() )
	{
		// try to find a sunlight
		//
		if ( bGeneratedShadowUseSunlightDir )
		{
			Brightness = 0;
			foreach AllActors(class'Light', l)
			{
				if ( l.LightEffect == LE_Sunlight && l.LightBrightness > Brightness )
				{
					Brightness = l.LightBrightness;
					Sun = l;
				}
			}
			if ( Sun != None )
			{
				LightDir = vect(1,0,0);
				LightDir = LightDir >> Sun.Rotation;
				LightDir *= GeneratedShadowLightDir;	// use it as a multiplier
				glog( RJ, "Using Sun "$Sun$" with light direction "$LightDir );
			}
			else
			{
				LightDir = vect(0,0,-1);
				glog( RJ, "Couldn't find sunlight - using light direction "$LightDir );
			}
		}
		else
		{
			LightDir = GeneratedShadowLightDir;
			glog( RJ, "Using light direction "$LightDir );
		}
		GVehicleShadow = Spawn(class'ShadowProjector',Self,'',Location);
		GVehicleShadow.ShadowActor = self;
		GVehicleShadow.bBlobShadow = False;
		GVehicleShadow.LightDirection = -LightDir;
		GVehicleShadow.LightDistance = GeneratedShadowLightDistance;
		GVehicleShadow.MaxTraceDistance = GeneratedShadowMaxTraceDistance;
		GVehicleShadow.CullDistance = GeneratedShadowCullDistance;
		GVehicleShadow.bOwnerNoSee = False;

		if ( GeneratedVehicleShadowMesh != None )
		{
			// create proxy shadow actor
			//
			proxy = Spawn( class'VGVehicleShadowProxy', self, , Location );
			proxy.SetStaticMesh( GeneratedVehicleShadowMesh );
			AddVehicleActor( proxy );
			GVehicleShadow.ShadowActorProxy = proxy;
		}
		else
		{
			// add all vehicle actors that want to cast a shadow
			//
			for ( i = 0; i < VehicleActors.Length; i++ )
			{
				if ( VehicleActors[i] != None )
				{
					GVehicleShadow.AddExtraShadowActor( VehicleActors[i] );
				}
			}
		}
		GVehicleShadow.InitShadow( GeneratedShadowFOVMult, GeneratedShadowDarkness, GeneratedShadowStartFadeDistance );

		// don't add GVehicleShadow to vehicle actors list since it refers to other vehicle actors
		// so we want to control when it gets destroyed
		//
		GeneratedVehicleShadow = GVehicleShadow;
	}
	else
	{
		GetAxes(Rotation,RotX,RotY,RotZ);
		if ( ShadowClass != None &&
			(ShadowClass != class'xShadowProjector' || ShadowTexture != None) )
		{
			VehicleShadow = Spawn(ShadowClass,self,,Location + ShadowOffset.X * RotX + ShadowOffset.Y * RotY + ShadowOffset.Z * RotZ, Rotation + ShadowRot);
			if ( ShadowTexture != None )
			{
				VehicleShadow.ProjTexture = ShadowTexture;
			}
			if ( ShadowDrawScale > 0 )
			{
				VehicleShadow.SetDrawScale( ShadowDrawScale );
			}
			VehicleShadow.SetBase(self);
			AddVehicleActor( VehicleShadow );
			VehicleShadow.MaxTraceDistance = ShadowProjectorDistance;
			VehicleShadow.ReattachMinDistChange = ShadowReattachDistance * ShadowReattachDistance;	// it's dist squared
		}
	}
}


simulated function PlayTakeHit(vector ToSource, int Damage, class<DamageType> DamageType)
{
    if ( Controller != None )
        CalcDamageDir(ToSource, Damage);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector Momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int p;
	local float PartImpactDamage, PartOtherDamage;


	if(instigatedby != Driver) //filter out damage caused by driver.
	{
		if(instigatedBy != None && instigatedBy.IsA('VGPawn') && VGPawn(instigatedBy).RiddenVehicle==self)
		{
			return;
		}

		for ( p = 0; p < CreatedDamageableParts.Length; p++ )
		{
			if ( CreatedDamageableParts[p] != None &&
				 CreatedDamageableParts[p].VehicleDamage(
						Damage, instigatedBy, hitlocation, Momentum, damageType, PartImpactDamage, PartOtherDamage
					) )
			{
				PartDamage[p].ImpactDamage += PartImpactDamage;
				PartDamage[p].OtherDamage += PartOtherDamage;
				PartDamage[p].Revision++;
			}
		}
		Spawn(class'xListHitVehicle',,,HitLocation,rotator(-Momentum));
		Super.TakeDamage(Damage, instigatedBy, hitlocation, Momentum, damageType, ProjOwner, bSplashDamage);
		Health=FMax(Health, 0);
	}
}

simulated event PlayVehicleSoundEffect(
	sound	TheSound,
	byte	Volume,
	byte	Pitch
)
{
	local float	 v, p;

	v = Volume * MasterVehicleSoundVolume / 65025.0;	// 65025=255*255
	p = Pitch / 64.0;
	PlaySound( TheSound, , v, , , p );
}

simulated function ImpactEvent(actor other, vector pos, vector impactVel, vector impactNorm, Material HitMaterial)
{
//	local ParticleEmitter Emitter;
	local float ImpactMagnitudeSqr, ImpactMagnitude;
	local byte volume;
	local vector vCol;
	local float fCol;

	if ( other != None && other.IsA('VGVehicle') )
	{
		if(!bDeliverRammingDamage)
		{
			vCol = Normal(other.Location - Location);

			//fCol is magnitude of velocity facing in collision direction (plus the relative velocity of the other, so nudging at high speeds doesn't do damage.)
			fCol = (Velocity dot vCol) + (other.Velocity dot (-vCol));

			if(fCol>MinRamSpeed)
			{
				fCol = FMin(fCol, MaxRamSpeed);

				RammingDamageAmount = ((fCol-MinRamSpeed)/(MaxRamSpeed-MinRamSpeed))*RammingDamage*RammingDamageMultiplier;
				bDeliverRammingDamage = True;
				RammingDamageTarget = other;
				RamLocation = pos;
				RamVelocity = impactVel*RammingVelocityMultiplier;
				//other.TakeDamage(damage, self, pos, vel, class'RammingDamage');
			}

		}
		if ( Controller != None )
			Controller.NotifyBump(other);
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// only play hit sound when hitting something other than world
		//
		ImpactMagnitudeSqr = impactVel Dot impactVel;
		if( HitSound != None && UntilNextImpact < 0 && other != None &&
			ImpactMagnitudeSqr >= Square( HitSoundMinImpactThreshold ) )
		{
			ImpactMagnitude = Sqrt( ImpactMagnitudeSqr );
			if ( ImpactMagnitude > HitSoundMaxImpactThreshold )
			{
				ImpactMagnitude = HitSoundMaxImpactThreshold;
			}
			if ( HitSoundMaxImpactThreshold != HitSoundMinImpactThreshold )
			{
				volume = HitSoundMaxVolume *
					(ImpactMagnitude - HitSoundMinImpactThreshold) /
					(HitSoundMaxImpactThreshold - HitSoundMinImpactThreshold);
			}
			else
			{
				volume = HitSoundMaxVolume;
			}

			PlayVehicleSoundEffect( HitSound, volume, 64 );

			// hack to stop the sound repeating rapidly on impacts
			UntilNextImpact = GetSoundDuration(HitSound);
		}

		if ( ImpactEmitter == None && ImpactEffect != None && ImpactMagnitudeSqr >= ImpactEffectThresholdSqr && !Level.bDropDetail )
		{
			ImpactEmitter = Emitter(ImpactEffect.static.SpawnHitEffect(other, pos, impactNorm, self, HitMaterial));
			if( ImpactEmitter != None )
			{
				ImpactEmitter.LifeSpan = ImpactEffectLifeSpan;
				SetMultiTimer( ImpactEffectTimerSlot, ImpactEffectLifeSpan, false );
			}
		}
	}
}

function MultiTimer( int id )
{
	switch ( id )
	{
	case ImpactEffectTimerSlot:
		ImpactEmitter = None;
		break;
	default:
		Super.MultiTimer( id );
		break;
	}
}

function Timer()
{
	if ( bWaitingForEnterSound )
	{
		AmbientSound = EngineSound;
		bWaitingForEnterSound = False;
	}
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;

	Super.DisplayDebug( Canvas, YL, YPos );
	//DefaultWeapon.DisplayDebug(Canvas,YL,YPos);

	Canvas.DrawColor.R = 255;
	T="ForwardVel="$ForwardVel;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Throttle = "$Throttle$" Steering = "$Steering);
	YPos += YL;
	Canvas.SetPos(4,YPos);


	if ( Driver != None && Driver.Controller != None )
	{
		Driver.Controller.DisplayDebug(Canvas,YL,YPos);
	}
}

simulated function DrawVehicleStats( canvas Canvas, optional int indent )
{
}

event GotoDelayingDeath()
{
	GotoState('DelayingDeath');
}

native function ResetStuck();

event TickVehicleEffects( float Delta );

function StartFlip()
{
	local vector	 worldUp;

	worldUp = vect(0, 0, 1) >> Rotation;
	if ( worldUp.Z < 0.3 )
	{
		InvertedTime = FlipTime;
	}
}

// this function is called by this vehicle's controller to adjust the
// vehicle state on the client at the given time stamp since the controller
// determined that it doesn't match with the server's idea of where vehicle
// should be at that time
// - override in derived classes
// - only called on server
event AdjustClientVehicleState(
	float			TimeStamp
)
{
}

// this function is called by this vehicle's controller to adjust the
// vehicle state on the server since the controller has determined that
// it's a good time to let the server know what's happening
// - override in derived classes
// - only called on client
// - Move has already been carried out
//
event AdjustServerVehicleState(
	VehicleSavedMove	Move
)
{
}

// this function is called by this vehicle's controller when it need to replay a move that
// was previously carried out
// - override in derived classes
// - only called on client
// - Move will be carried out after this function so this function should set things
//   up with the vehicle so that it will move the same way as it when this move was
//   first carried out
//
function SetupForMoveReplay(
	VehicleSavedMove	Move
)
{
}

// this function is called by this vehicle's controller when it needs to autonomously move the
// vehicle
// - override in derived classes
//
function MoveVehicleAutonomous(
	float	DeltaTime
)
{
}

// this function should be overridden to send vehicle state to clients
// - only called on a server
//
event SendVehicleState()
{
}

simulated native function WakeVehicle();
simulated native function FreezeVehicle();

event DeliverRammingDamage()
{
	RammingDamageTarget.TakeDamage(RammingDamageAmount, self, RamLocation, RamVelocity, class'RammingDamage');
	bDeliverRammingDamage=False;
	if(Affector != none)
		Affector.FireEffect();
}

event SelfDestruct()
{
	TakeDamage(1000, self, Location, vect(0,0,0), class'SelfDestructDamage');
}

simulated function FreezeOnContact()
{
	bFreezeOnContact = True;
}

simulated event bool IsInContact()
{
	local bool bInContact;

	// not quite right; this returns true if it was in contact
	// since the last time this was called or since vehicle creating
	//
	bInContact = bContactMade;
	bContactMade = False;
	return bInContact;
}

function bool FreePassengerPoint()
{
	local int i;

	for(i=0; i< PassengerPointCount; i++)
	{
		if(PassengerPointsUsed[i]==0)
		{
			return True;
		}
	}
	return False;
}

function bool GetDriverEntryPoint(out EntryPoint ep)
{
	if(!bIsDriving)
	{
		ep = DriverEntryPointActors[0]; //cmr -- 0 is always valid, this is a quick fix. Eventually need to check for best.
		return true;
	}
	return false;
}

function bool GetPassengerEntryPoint(out EntryPoint ep)
{
	local int i;
	for(i=0;i<PassengerPointCount;i++)
	{
		if( !(PassengerPointsUsed[i]==1) )
		{
			ep = PassengerEntryPointActors[i];
			return true;
		}
	}
	return false;
}

simulated function Vector GetWorldDriverEntryPosition(int index)
{
	if(index >= DriverEntryPointCount)
	{
		log("CHARLESERROR: tried to query driver entry point out of range");
		return Vect(0,0,0);
	}


	return Location + (DriverEntryPoints[index]>>Rotation);
}


simulated function Vector GetWorldPassengerEntryPosition(int index)
{
	if(index >= PassengerPointCount)
	{
		log("CHARLESERROR: tried to query passenger entry point out of range");
		return Vect(0,0,0);
	}

	return Location + (PassengerEntryPoints[index]>>Rotation);
}

function bool HasPassengers()
{
	local int i;

	for(i=0; i< PassengerPointCount; i++)
	{
		if(PassengerPointsUsed[i]==1)
		{
			return True;
		}
	}
	return False;
}

function TryToRide( Pawn aPawn, optional bool bTeleport)
{
	local float dist;
	TryToRideByIndex(aPawn, GetClosestPassengerPoint(aPawn.Location, dist), bTeleport);
}

function TryToRideByIndex( Pawn aPawn, int closest, optional bool bTeleport)
{
	local VGPawn	passenger;
	local int n;
	local Rotator r;

	//log("CHARLES:  TryToRide called");

	if(!bTeleport && VSize(Velocity) > 100)
	{
		if(aPawn.Controller.IsA('PlayerController'))
			PlayerController(aPawn.Controller).ReceiveLocalizedMessage(class'PlayerInfoMessage', 4);

		return;

	}
	else if(closest == -1)
	{
		//no spot given
		return;
	}

	if ( Role < ROLE_Authority )
	{
		warn( "CHARLES: "$self$"::TryToRide("$aPawn$") CALLED ON CLIENT!!!" );
	}


	//okay, let the player ride
	passenger=VGPawn(aPawn);
	Passengers[closest]=passenger;
	passenger.RiddenVehicle=self;
	passenger.SetHavokCharacterCollisions( false );	// turn off any havok-character collisions while in vehicle
	log("setting rideranim to "$RiderAnims[closest]$" from "$closest);
	passenger.RiderAnim = RiderAnims[closest];

	//cmr -- end the zoom shit

	if(IsGunnerSpot[closest] == 1)
	{
		passenger.bIsGunner = true;
		passenger.SnapAnimAction = true;
		passenger.SetAnimAction(PassengerEntryAnims[closest]);
		passenger.bPlayingEnterExitAnim = true;
	}

	passenger.RiddenVehicleSpot=closest;
	PassengerPointsUsed[closest]=1;
	aPawn.Controller.bIsRidingVehicle = True;
	//aPawn.Controller.bUseRiderCamera = PassengerCameras[closest].bUse3rdPerson;
	if(PassengerCameras[closest].bUse3rdPerson && aPawn.Controller.IsA('VehiclePlayer'))
	{
		PlayerController(passenger.Controller).ClientEndZoom();
		VehiclePlayer(aPawn.Controller).SetViewTarget(self);
		VehiclePlayer(aPawn.Controller).SetRiderCamStuff(self, true);
	}

	if(PassengerCameras[closest].bLimitYaw && aPawn.Controller.IsA('VehiclePlayer'))
	{
		VehiclePlayer(aPawn.Controller).SetRiderCamYawLimit( PassengerCameras[closest].CenterYaw, PassengerCameras[closest].MaxYaw);
	}

	aPawn.SetLocation(Location);
	aPawn.SetPhysics(PHYS_RidingBase);
	aPawn.SetCollisionSize(aPawn.default.CollisionRadius, 50);
	aPawn.bDontRotateWithBase=True;

	aPawn.SetBase(self);
	aPawn.SetRelativeLocation(PassengerPoints[closest]);
	if(IsGunnerSpot[closest]==1)
		aPawn.SetRelativeRotation(r);

	if(RiderEnterEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
	{
		log("firing off event "$RiderEnterEvent);
		TriggerEvent(RiderEnterEvent, self, aPawn);
	}


	if(RiderWeapon != none && IsGunnerSpot[closest]==1)
	{
		// this vehicle has a rider controlled weapon so place it under the control of the rider
		//first, hide the pawn's current weapon

		SavedWeapon = aPawn.Weapon;
		VGPawn(aPawn).SavedWeapon = aPawn.Weapon;

		if(aPawn.Weapon.ThirdPersonActor != None) {
			aPawn.Weapon.HolderDied();
			aPawn.Weapon.DetachFromPawn(aPawn);
		}

		RiderWeapon.Instigator = aPawn;
		RiderWeapon.ThirdPersonActor.Instigator = aPawn;
		RiderWeapon.SetOwner(aPawn);

		aPawn.Weapon = RiderWeapon;

		if(RiderWeapon.ThirdPersonActor != none) {
			RiderWeapon.ThirdPersonActor.Instigator = aPawn;
			RiderWeapon.ThirdPersonActor.SetOwner(RiderWeapon);
		}

		// make sure the rider weapon has ammo
		for(n = 0; n < RiderWeapon.NUM_FIRE_MODES; n++)
		{
			if(RiderWeapon.FireMode[n] != none)
			{
				RiderWeapon.FireMode[n].Instigator = aPawn;
				RiderWeapon.GiveAmmo(n);
			}
		}

		RiderWeapon.ClientState = WS_ReadyToFire;
		RiderWeapon.GotoState('');
		VGPawn(aPawn).ClientVehicleWeaponStuff(RiderWeapon);

	}

	if(Level.Game.bTeamGame==True)
	{
		if(aPawn.Controller != none && aPawn.Controller.PlayerReplicationInfo.Team.TeamIndex != SpawnedByTeam)
		{
			Level.Game.TakeVehicleFrom(SpawnedByTeam);
			SpawnedByTeam = aPawn.Controller.PlayerReplicationInfo.Team.TeamIndex;
		}
	}

	Level.Game.EnteredVehicle(aPawn.Controller, aPawn, self );

	if(DriveController(aPawn.Controller) != None)
	{
		DriveController(aPawn.Controller).BeginRiding(self);
	}

//	if(Role == ROLE_Authority)
//	ClientSetRide(aPawn);
}

simulated function ClientSetRide(Pawn aPawn)
{
	local int n;

	if(RiderWeapon != none) {
		// this vehicle has a rider controlled weapon so place it under the control of the rider
		RiderWeapon.Instigator = aPawn;
		if(aPawn.Weapon != RiderWeapon)
			SavedWeapon = aPawn.Weapon;
		aPawn.Weapon = RiderWeapon;

		if(RiderWeapon.ThirdPersonActor != none)
			RiderWeapon.ThirdPersonActor.Instigator = aPawn;

		// make sure the rider weapon has ammo
		for(n = 0; n < RiderWeapon.NUM_FIRE_MODES; n++) {
			if(RiderWeapon.FireMode[n] != none) {
				RiderWeapon.FireMode[n].Instigator = aPawn;
				RiderWeapon.GiveAmmo(n);
			}
		}

		RiderWeapon.ClientState = WS_ReadyToFire;
		RiderWeapon.GotoState('');
		RiderWeapon.SetOwner(aPawn);
	}
}

function int GetClosestDrivePointDist(vector PawnPos, out float outdist)
{
	local int i;
	local int closest;
	local float dist,neardist;


	neardist=1000000;
	closest = -1;

	for(i=0; i < DriverEntryPointCount; i++)
	{
		dist = VSize((Location+(DriverEntryPoints[i]>>Rotation)) - PawnPos);

		if(dist < neardist)
		{
			neardist = dist;
			closest = i;
		}
	}

	//log("Found closest passenger point... which is "$PassengerPointEntryNames[closest]$" / "$PassengerPointNames[closest]);

	outdist = neardist;
	return closest;

}

function int GetClosestPassengerPoint(vector PawnPos, out float outdist)
{
	local int i;
	local int closest;
	local float dist,neardist;


	neardist=1000000;
	closest = -1;

	for(i=0; i < PassengerPointCount; i++)
	{
		if(PassengerPointsUsed[i]==1) continue;

		if(PassengerPointEntryNames.Length > 0)
		{
			dist = VSize((Location+(PassengerEntryPoints[i]>>Rotation)) - PawnPos);
		}
		else
			dist = VSize((Location+(PassengerPoints[i]>>Rotation)) - PawnPos);
		if(dist < neardist)
		{
			neardist = dist;
			closest = i;
		}
	}

	//log("Found closest passenger point... which is "$PassengerPointEntryNames[closest]$" / "$PassengerPointNames[closest]);

	outdist = neardist;
	return closest;

}

event KickEveryoneOut()
{
	NotifyFlip();

	DriverExits();
	TriggerEvent(FlipEvent, self, None);

	EndRideAll();
}

function NotifyFlip()
{
	local int i;

	if(Controller!=None)
		Controller.NotifyVehicleFlip(self);

	for(i=0;i<MAXPASSENGERS;i++)
	{

		if(Passengers[i] != None)
		{
			if(Passengers[i].Controller != None)
				Passengers[i].Controller.NotifyVehicleFlip(self);
		}
	}

}

simulated function ClientEndRide(VGPawn p)
{
	if(RiderWeapon != none && IsGunnerSpot[p.RiddenVehicleSpot]==1) {
		RiderWeapon.Instigator = self;
		if(RiderWeapon.ThirdPersonActor != none)
			RiderWeapon.ThirdPersonActor.Instigator = self;
	}

	if(SavedWeapon != none && IsGunnerSpot[p.RiddenVehicleSpot]==1)
		Pawn(SavedWeapon.Owner).Weapon = SavedWeapon;

	if(p.Controller.IsA('VehiclePlayer') && IsGunnerSpot[p.RiddenVehicleSpot]==1 && VGPawn(SavedWeapon.Owner) == p) {
		VehiclePlayer(p.Controller).bUse3rdPersonCam = false;
		VehiclePlayer(p.Controller).bBehindView = false;
	}

	SavedWeapon = none;
}

function EndRide( VGPawn p )
{
	local int i;
	local vector v, OutPos;

	local actor a;
	local vector extent, startchk, endchk, hitloc, hitnorm;
	local vgvehicle oldride;
	local vector randvel;

//	log("*** End Ride for "$p);
	if(RiderWeapon != none && IsGunnerSpot[p.RiddenVehicleSpot]==1) {
		RiderWeapon.Instigator = none;
//		RiderWeapon.Instigator.Controller = none;
		if(RiderWeapon.ThirdPersonActor != none) {
			RiderWeapon.ThirdPersonActor.Instigator = none;
//			RiderWeapon.ThirdPersonActor.Instigator.Controller = none;

//			log("No more rider weapon controller!!!");
		}

		RiderWeapon.SetOwner(self);
		RiderWeapon.HolderDied();
	}

	if(SavedWeapon != none && IsGunnerSpot[p.RiddenVehicleSpot]==1)
	{
		p.Weapon = SavedWeapon;
		p.ClientEndRideVehicle(SavedWeapon);
		SavedWeapon.SetOwner(p);
		//show weapon again
		p.Weapon.AttachToPawn(p);
        p.Controller.Restart();
		p.SetCollisionSize(p.Default.CollisionRadius, p.Default.CollisionHeight);
	}

	if(p.Controller.IsA('VehiclePlayer') && IsGunnerSpot[p.RiddenVehicleSpot]==1 && VGPawn(SavedWeapon.Owner) == p) {
		VehiclePlayer(p.Controller).bUse3rdPersonCam = false;
		VehiclePlayer(p.Controller).bBehindView = false;
	}

	if( IsGunnerSpot[p.RiddenVehicleSpot]==1 )
		SavedWeapon = none;

	for(i=0;i<PassengerPointCount;i++)
	{
		if(Passengers[i]==p)
		{
			Passengers[i]=None;
			PassengerPointsUsed[i]=0;
			oldride = p.RiddenVehicle;
			p.RiddenVehicle=None;
			p.bIsGunner = false;

			//set an exit position relative to the center of vehicle
			v=(PassengerPoints[i]>>Rotation);
			v.z=0;

			if(p.ExitByAnimPos != Vect(0,0,0) )
			{
				log("GETTING OUT BY ANIM AT "$P.ExitByAnimPos);
				OutPos = p.ExitByAnimPos;
				p.ExitByAnimPos=Vect(0,0,0);
			}
			else
			{
				OutPos = Location + (PassengerPoints[i]>>Rotation) + Normal(v)*250.0 ;
			}

			//do a trace to make sure outpos is still valid

			startchk = p.Location;
			endchk = OutPos;

			extent.X = p.default.CollisionRadius;
			extent.Y = p.default.CollisionRadius;
			extent.Z = p.default.CollisionHeight;

			a = Trace(hitloc, hitnorm, endchk, startchk, true, extent);

			if(a != None) //shit, we hit something, need to do something different for exit pos.  Halo just bumps the player upwards of the vehicle... sounds good
			{
				//first try and put character just on top of vehicle
				startchk = Location + Vect(0,0,500);
				endchk = Location;
				a=p.Trace(hitloc, hitnorm, endchk, startchk, true, extent);

				if(a != None && a == self)//woot on top of vehicle
				{
					OutPos = hitloc + Vect(0,0,20);
				}
				else //fallback
				{

					OutPos = Location + Vect(0,0,300);
				}
				randvel=VRand();
				randvel.z=0;
				randvel = Normal(randvel)*50.0;
			}

			p.SetLocation( OutPos );
			p.Velocity+=randvel;

			p.bDontRotateWithBase=False;

			// restore any havok-character collision
			p.SetHavokCharacterCollisions( p.UseHavokCharacterCollision() );
			p.SetCollisionSize(p.Default.CollisionRadius, p.Default.CollisionHeight);
//			if(Role == ROLE_Authority)
//				ClientEndRide(p);

			//reset camera
			if(/*p.Controller.bUseRiderCamera &&*/ p.Controller.IsA('VehiclePlayer'))
			{
				VehiclePlayer(p.Controller).SetRiderCamStuff(p, false);
				VehiclePlayer(p.Controller).SetRiderCamYawLimit(0,0);
				//might need this
				//p.Controller.bUseRiderCamera = false;
				//might need to reset viewtarget
			}

			if(RiderExitEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
			{
				log("firing off event "$RiderExitEvent);
				TriggerEvent(RiderExitEvent, self, p);
			}


			return;
		}
	}
	assert(False);

}

function EndRideAll()
{
	local int i;
	local vector v;
	local VGPawn p;

//	log("*** EndRideAll");
	if(RiderWeapon != none) {
		RiderWeapon.Instigator = self;
		if(RiderWeapon.ThirdPersonActor != none)
			RiderWeapon.ThirdPersonActor.Instigator = self;

		RiderWeapon.SetOwner(self);
		RiderWeapon.HolderDied();
	}

	if(SavedWeapon != none)
	{
		p = VGPawn(SavedWeapon.Owner);
		p.Weapon = SavedWeapon;
		p.ClientEndRideVehicle(SavedWeapon);
		SavedWeapon.SetOwner(p);
		p.Weapon.AttachToPawn(p);
		p.Controller.Restart();
		p.SetCollisionSize(p.Default.CollisionRadius, p.Default.CollisionHeight);
	}

	for(i=0;i<PassengerPointCount;i++)
	{
		p=VGPawn(Passengers[i]);
		if(p!=None)
		{
			p.Controller.NotifyVehicleFlip(self); // hack for special vehicle scene

			Passengers[i]=None;
			PassengerPointsUsed[i]=0;
			p.RiddenVehicle=None;
			p.bIsGunner=false;

			//set an exit position relative to the center of vehicle
			v=(PassengerPoints[i]>>Rotation);
			v.z=0;

			p.SetLocation( Location + (PassengerPoints[i]>>Rotation) + Normal(v)*150.0 );
			p.bDontRotateWithBase=False;

			// restore any havok-character collision
			p.SetHavokCharacterCollisions( p.UseHavokCharacterCollision() );

			if(p.Controller.IsA('VehiclePlayer') && VGPawn(SavedWeapon.Owner) == p) {
				VehiclePlayer(p.Controller).bUse3rdPersonCam = false;
				VehiclePlayer(p.Controller).bBehindView = false;
			}

			if(p.Controller.IsA('VehiclePlayer'))
			{
				VehiclePlayer(p.Controller).SetRiderCamStuff(p, false);
				VehiclePlayer(p.Controller).SetRiderCamYawLimit(0,0);

			}

		}
	}

	SavedWeapon = none;
}

function TryToDrive( Pawn aPawn, optional int EntryIndex )
{
	local Controller C;
	local Actor RWOwner;	// owner of the rider weapon

	if ( Role < ROLE_Authority )
	{
		warn( "RON: "$self$"::TryToDrive("$aPawn$") CALLED ON CLIENT!!!" );
	}

	if ( VGPawn(aPawn) == None )
	{
		warn( "RON: Non-VGPawn "$aPawn$" trying to drive VGVehicle" );
		return;
	}
	C = aPawn.Controller;

	// need to save the current rider weapon 'cause possess/unpossess seems to cause it to be reset
	if(RiderWeapon != none)
		RWOwner = RiderWeapon.Owner;

    //if ( !bIsDriven && (C != None) && !bIsLocked &&
	//	 ( (C.bIsPlayer && aPawn.IsHumanControlled()) || DriveController(C) != None ) )
    if ( !bIsDriven && (C != None) && !bIsLocked &&
		 ( (C.bIsPlayer && aPawn.IsHumanControlled()) || ScriptedController(C) != None ) )
	{

		bBrake=false;
		DriverEnteringFromIndex = EntryIndex;

		Driver = VGPawn(aPawn);
		if(Driver.Weapon != none)
		{
			Driver.Weapon.HolderDied();
			Driver.Weapon.DetachFromPawn(Driver);
		}
		if ( C.IsA('PlayerController') )
		{
			PlayerController(C).UnPossess();
			Driver.SetOwner(C);	//keep relevant!!
		}
		else if ( C.IsA('DriveController') && C.GetStateName() != 'Scripting' )
		{
			DriveController(C).Unpossess();
		}
		C.Possess( self );
		if(Level.Game.bTeamGame==True)
		{
			if(C.PlayerReplicationInfo.Team.TeamIndex != SpawnedByTeam)
			{
				Level.Game.TakeVehicleFrom(SpawnedByTeam);
				SpawnedByTeam = C.PlayerReplicationInfo.Team.TeamIndex;
			}
		}
		Driver.SetDrivenVehicle(self);
		SetPlayerOwner(Driver);
		RemoveOverlayMaterial();

		Level.Game.EnteredVehicle( C, aPawn, self );
    }

	if(RiderWeapon != none) {
		RiderWeapon.SetOwner(RWOwner);
		if(!RWOwner.IsA('VGVehicle') )
			// if the rider weapon is being used we need to make sure the rider can still use it... stupid possess/unpossess
			ClientSetRide(Pawn(RWOwner) );
	}
	VehicleWeaponAttachment(Weapon.ThirdPersonActor).SetTracking(true);

}



function SetPlayerOwner(VGPawn Player)
{
	local VGVehicle lastowned;

	if(Player == PlayerOwner || !bNeedsPlayerOwner)
	{
		return;
	}

 	if(Player == None)
 	{
 		ClearPlayerOwner();
 		return;
 	}


	//log("CHARLES:  Setting PlayerOwner for Vehicle "$Name$" to "$Player.Name);

	//see if the player owns a vehicle, and if so, unown it.
	if(Player.OwnedVehicle != None)
	{
		//set vehicles owner to none
		Player.OwnedVehicle.ClearPlayerOwner();
		lastowned = Player.OwnedVehicle;
		Player.OwnedVehicle = None;
	}

	if(lastowned == None)
	{
		//log("CHARLESERROR: Player "$Player.Name$" didn't own a vehicle.");
	}

	//see if a player owns this vehicle
	if(PlayerOwner!=None)
	{
		//log("CHARLES: Vehicle "$Name$" is currently owned by Player "$PlayerOwner.Name);
		//yup, someone does.  They get the player's last owned vehicle.
		PlayerOwner.OwnedVehicle = lastowned;
		if(lastowned != none)
			lastowned.PlayerOwner = PlayerOwner;
		//log("CHARLES: Player "$PlayerOwner.Name$" now owns Vehicle "$lastowned.Name);
	}

	PlayerOwner = Player;
	Player.OwnedVehicle = self;

	bUntouched = False;

	//log("CHARLES: Vehicle "$Name$" is now owned by Player "$PlayerOwner.Name);
}

function ClearPlayerOwner()
{
	if(!bNeedsPlayerOwner) return;
	//if(PlayerOwner!=None) log("CHARLES:  PlayerOwner for Vehicle "$Name$" was "$PlayerOwner.Name);
	PlayerOwner = None;
	UnownedTime=0.0;
}

function DriverExits()
{
	local VGPawn SaveDriver;
	local Controller C;
	local int ei, ve;

	// stop all effects that are only on when vehicle occupied
	//
	for ( ei = 0; ei < CarEffects.Length; ei++ )
	{
		if ( !CarEffects[ei].OnWhenCarEmpty )
		{
			for ( ve = 0; ve < CarEffects[ei].Emitters.Length; ve++ )
			{
				CarEffects[ei].Effects[ve].StopEmitter( self, CarEffects[ei].Emitters[ve] );
			}
		}
	}

	Driver.ClientEndRideVehicle(None);

	C = Controller;
	if ( C != None )
	{
		if(Driver.Weapon!=None)
		{
			Driver.Weapon.AttachToPawn(Driver);
		}

		if ( Weapon != None )
		{
			//Weapon.GotoState('Idle');
			Weapon.HolderDied();
			if(DefaultWeapon != None)
				DefaultWeapon.HolderDied();
		}
		SaveDriver = Driver;
		C.UnPossess();
		C.Possess( SaveDriver );

		SaveDriver.SetDrivenVehicle(None);
		Level.Game.ExitedVehicle( C, SaveDriver, self );
	}
	Weapon.ThirdPersonActor.Instigator.Controller = none;
}

event Bump( Actor Other )
{
	local Vector vDiff, vNudge;
	local float side, end;
	local rotator fudge;

	fudge.yaw = 65535 / 4;

	if(ROLE == ROLE_Authority)
	{
		if(Other.IsA('VGPawn') && VSize(Velocity) > 150)
		{
			vDiff = Normal(Other.Location - Location);

			side = Vector(Rotation + fudge) dot vDiff;

			end = Vector(Rotation) dot vDiff;

			if(end > 0.68)
			{

				if(side >= 0.0) //right side
				{
					vNudge= (Vector(Rotation) cross Vect(0,0,1)) * -10;
				}
				else //left side
				{
					vNudge= (Vector(Rotation) cross Vect(0,0,1)) * 10;
				}
			}

			Other.SetLocation(Other.Location + vNudge);
		}
	}
}



event bool EncroachingOn(Actor Other)
{
	if(Other!=None && Other.IsA('VGPawn') && Other == PlayerOwner && VGPawn(Other).RiddenVehicle!=self)
	{
		return True;
	}

	if(Other!= None && Other.IsA('VGPawn')) //we are running over a character, take some damage
	{
//	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
//							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)


	//	TakeDamage(30, Pawn(Other), Other.Location, Vect(0,0,0), class'RammingDamage');
	}

	return False;
}

event EncroachedBy(Actor Other)
{
//	log(Name$" Was encroached by "$Other.name);
}

//In network games the vehicle's weapons may not be relevant
//when a player gets into the vehicle, need to set them up.
simulated function InitVehicleWeapons()
{
	local Actor inv;
	//local Weapon weap;
	//local WeaponAttachment attach;
	inv = Inventory;
	while(inv != none)
	{
		inv.SetOwner(self);
		inv.Instigator = self;
		if(inv.IsA('Weapon'))
		{
			Weapon(inv).CreateFireModes();
			Weapon(inv).ClientWeaponSet(false);
		}
		inv = inv.Inventory;
	}
	if(DefaultWeapon != none)
	{
		DefaultWeapon.SetOwner(self);
		DefaultWeapon.Instigator = self;
		DefaultWeapon.CreateFireModes();
		DefaultWeapon.ClientDefaultWeaponSet();
	}

	if(RiderWeapon !=  none) {
		RiderWeapon.SetOwner(self);
		RiderWeapon.Instigator = none;
		RiderWeapon.CreateFireModes();
		RiderWeapon.ClientState = WS_ReadyToFire;
	}

	//checking all the weapons.
	/*
	foreach AllActors(class'Weapon',weap)
	{
		log("XJ: Weapon: "$weap$" Owner: "$weap.Owner$" Instigator: "$weap.Instigator$" FireMode: "$weap.FireMode[0]);
	}
	foreach AllActors(class'WeaponAttachment',attach)
	{
		log("XJ: Attachment: "$attach$" Owner: "$attach.Owner$" Instigator: "$attach.Instigator);
	}
	log("XJ: End AllActor checks");
	*/
}

simulated final function BeginControlOfVehicle( Controller C )
{
	local Vector NewDrivePos;
	local Rotator DriveRot;

	glog( RJ2, "BeginControlOfVehicle("$C$") called" );
	InitVehicleWeapons();

	if ( Role == ROLE_Authority )
	{
        assert( Driver != None );
		assert( !bIsDriven );
		bIsDriven = true;

		if( C.PlayerReplicationInfo == None || C.PlayerReplicationInfo.Team == None || C.PlayerReplicationInfo.Team.TeamIndex==0)
			DriverState = DS_Team0;
		else DriverState = DS_Team1;

		Driver.bDriver = True;
		//TODO:  Fix these driver collision changes.  They probably aren't good in the long run.
		Driver.SetCollision(False, False, False);
		Driver.bCollideWorld = False;
		//Driver.bPhysicsAnimUpdate = False;
		Driver.Velocity = vect(0,0,0);
		Driver.SetPhysics(PHYS_RidingBase);
		Driver.bIsDriving = True;
		Driver.bReplicateMovement=False;
		//Driver.bForceBaseRep=True;
		//Driver.bForcePhysicsRep=True;
		//Driver.RemoteRole = ROLE_DumbProxy;

		if ( HideDriver )
		{
			Driver.SetDrawType(DT_None);
			//Driver.SetRotation(Rotation);
			Driver.SetLocation(Location);
			Driver.SetBase(self);
			//Driver.SetRelativeLocation(Vect(0,0,0));
		}
		else
		{
			// this needs to be fixed (rj@bb)
			// - it doesn't work properly right now in networked games
			// - I think we need to create a special non-pawn actor for the in vehicle
			//   driver
			//   - this actor would be created when driver enters and destroyed when
			//     driver leaves
			//   - in networked games it would only be created on clients
			//
			Driver.SetLocation(Location);
			Driver.SetBase(self);
			Driver.DriverAnim = DrivingAnim;
			Driver.DriverAnimR = DrivingAnimR;
			Driver.DriverAnimL = DrivingAnimL;
			Driver.SnapAnimAction = true;
			Driver.SetAnimAction(DriverEntryAnims[DriverEnteringFromIndex]);
			Driver.bPlayingEnterExitAnim=true;

			if(!GetAttachPoint(DriverPointName,NewDrivePos,DriveRot))
			{
				Driver.DrivenVehicleSpot=Vect(200, 0, 250);
				Driver.SetRelativeLocation(Vect(200,0,250));
			}
			else
			{
				NewDrivePos += Vect(0,0,93);
				//log("FOUND DRIVEPOS: "$NewDrivePos);
				Driver.DrivenVehicleSpot= NewDrivePos;
				Driver.SetRelativeLocation(NewDrivePos);
			}

			if(Driver.PlayerShadow != None)
			{
				Driver.PlayerShadow.bHiddenEd = True;
			}

			Driver.SetRotation(Rotation);
		}

		Driver.ExitByAnimPos=Vect(0,0,0);
		// set inverted time to be flip time so that it will immediately start righting itself
		//
		StartFlip();

		Driver.SetHavokCharacterCollisions( false );	// turn off any havok-character collisions while in vehicle

		if(DriverEnterEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
		{
			log("firing off event "$DriverEnterEvent);
			TriggerEvent(DriverEnterEvent, self, Driver);
		}


	}
}

final function EndControlOfVehicle( Controller C )
{
	local rotator r;

	glog( RJ2, "EndControlOfVehicle("$C$") called" );

	if ( Role == ROLE_Authority )
	{
		assert( bIsDriven );
		assert( Driver != None );

		Throttle=0;
		Steering=0;
		bIsDriven = false;

		if(DriverExitEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
		{
			log("firing off event "$DriverExitEvent);
			TriggerEvent(DriverExitEvent, self, Driver);
		}

		DriverState=DS_NoDriver;

		Driver.bDriver = False;
		//TODO:  Fix these driver collision changes.  They probably aren't good in the long run.
		Driver.bPhysicsAnimUpdate = Driver.Default.bPhysicsAnimUpdate;
		Driver.bCollideWorld = True;
		Driver.bIsDriving = False;
		Driver.SetCollision(True, True, True);
		Driver.bReplicateMovement=True;
		//Driver.SetAnimAction(DriverExitAnim);

		if ( HideDriver )
		{
			Driver.SetDrawType(DT_Mesh);
			Driver.SetBase(None);
			r.yaw = Rotation.yaw;
			Driver.SetRotation(r);
		}
		else
		{
			// as mentioned above the animated driver in car scenario needs to be fixed (rj@bb)
			//
			Driver.SetBase(None);
			//Driver.SetWalkingAnims();
			r.yaw = Rotation.yaw;
			Driver.SetRotation(r);
			if(Driver.PlayerShadow != None)
			{
				Driver.PlayerShadow.bHiddenEd = False;
			}
		}

        if ( Driver.bPlayedDeath )
        {
            log( "RJ: Driver"@Driver@" ending control of vehicle"@self@" is dead!" );
        }
        else
        {
		    if(!IsDead()) SetGoodExitPos();

		    Driver.Acceleration = vect(0, 0, 24000);
		    Driver.SetPhysics(PHYS_Falling);

		    Driver.SetHavokCharacterCollisions( Driver.UseHavokCharacterCollision() );
        }
	}
	Driver = None;
}

// called on driver entering vehicle
simulated event DriverEntered()
{
	local float duration;

	glog( RJ2, "DriverEntered() called" );

	// start engine sound after any enter vehicle sound has completed
	//
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SoundPitch = EngineSoundPitch;
		SoundVolume = int(EngineSoundVolume) * int(MasterVehicleSoundVolume) / 255;
		if ( EnterVehicleSound != None )
		{
			PlayVehicleSoundEffect( EnterVehicleSound, EnterVehicleSoundVolume, 64 );
			bWaitingForEnterSound = True;
			duration = GetSoundDuration( EnterVehicleSound );
			if ( duration < 0.05 )
			{
				duration = 0.1;	// xbox hack - GetSoundDuration() always returns 0 on lin builds
			}
			else
			{
				duration -= 0.05;
			}
			SetTimer( duration, False );
		}
		else
		{
			bWaitingForEnterSound = False;
			AmbientSound = EngineSound;
		}
	}
	else
	{
	    bWaitingForEnterSound = False;
		AmbientSound = EngineSound;
	}
}

// called on driver leaving vehicle
simulated event DriverExited()
{
	glog( RJ2, "DriverExited() called" );

	bWaitingForEnterSound=True;
	AmbientSound=None;
	if ( ExitVehicleSound != None )
	{
		PlayVehicleSoundEffect( ExitVehicleSound, ExitVehicleSoundVolume, 64 );
	}
}

function bool CheckExtentsTo(Pawn test, Vector startchk, Vector endchk)
{
	local vector hitloc, hitnorm, extent;
	local actor a;


	extent.X = test.default.CollisionRadius;
	extent.Y = test.default.CollisionRadius;
	extent.Z = test.default.CollisionHeight;

	//startchk = test.Location;

	a = test.Trace(hitloc, hitnorm, startchk, endchk, true, extent, , ,true);

	if(a != None) //oh snap, hit something in between driver and outpos.
	{
		log("I hit "$a$" on my trace");
		if(a == self && SafetyCheck(test, endchk))
		{
			return true;
		}
		return false;
	}


	return true;
}

function bool SafetyCheck(Pawn test, Vector endchk)
{
	local vector hitloc, hitnorm, extent, startchk;
	local actor a;


	extent.X = test.default.CollisionRadius;
	extent.Y = test.default.CollisionRadius;
	extent.Z = test.default.CollisionHeight;

	startchk = test.Location;

	a = Trace(hitloc, hitnorm, endchk, startchk, true, extent, , ,true);

	if( a != None && a.IsA('TerrainInfo') ) //oh snap, hit something in between driver and outpos.
	{
		log("Safety Check hit "$a);
		return false;
	}

	return true;
}

function bool CheckExitSpot(optional bool bIsGunner, optional byte RideSpot)
{
	local vector startchk, endchk, hitloc, hitnorm, extent;
	local actor a, test;

	if(Role!=ROLE_Authority) return false;

	if(!bIsGunner)
	{
		if(Driver == None || DriverExitAnim=='')
			return false;

		test=Driver;
		endchk=(DriverEntryPoints[0]>>Rotation) + Location;
	}
	else
	{
		if(IsGunnerSpot[RideSpot]==0 || Passengers[RideSpot]==None || GunnerExitAnim=='')
			return false;

		test=Passengers[RideSpot];

		endchk=(PassengerEntryPoints[RideSpot]>>Rotation) + Location;

		//log("going to "$endchk$" which should be "$PassengerEntryPoints[RideSpot]);
	}

	startchk = test.Location;

	extent.X = test.default.CollisionRadius;
	extent.Y = test.default.CollisionRadius;
	extent.Z = test.default.CollisionHeight;

	a = Trace(hitloc, hitnorm, endchk, startchk, true, extent);

	if(a != None) //oh snap, hit something in between driver and outpos.
	{
		//log("I hit "$a$" on my trace");
		VGPawn(test).ExitByAnimPos = Vect(0,0,0);
		return false;
	}


	//log now make sure there is a little more room (so player doesn't conceivably get stuck in a place he can't get out of somehow.
	startchk = endchk + Vect(0,0,30);

	a = test.Trace(hitloc, hitnorm, endchk, startchk, true, extent);
	if(None == a)
	{
		VGPawn(test).ExitByAnimPos = endchk;
		return true;
	}
	else //just assume that it's unsafe
	{
		//log("I hit "$a$" on my extent trace");
		VGPawn(test).ExitByAnimPos = Vect(0,0,0);
		return false;
	}
}


//find a valid exit position (quick line check validates the point).
function SetGoodExitPos()
{
	local int i;
	local Vector P;

	if(Driver.ExitByAnimPos != Vect(0,0,0))
	{
		if(CheckExtentsTo(Driver, Location, Driver.ExitByAnimPos))
		{
     		if(Driver.SetLocation(Driver.ExitByAnimPos))
    		{
        		log("SetGoodExitPos() by anim" @ Driver.ExitByAnimPos @ Location );
    		    return;
    		}
		}
	}
	
	for(i=0;i<4;i++)
	{
	    P = Location + (ExitPos[i]>>Rotation);
	
		if(CheckExtentsTo(Driver, Location, P))
		{
			if(Driver.SetLocation(P))
			{
        		log("SetGoodExitPos() by proper exit" @ i);
				return;
			}
		}
	}
	
	for(i=0;i<4;i++)
	{
	    P = Location + (ExitPos[i]);
	    
		if(CheckExtentsTo(Driver, Location, P))
		{
			if(Driver.SetLocation(P))
			{
    	    	log("SetGoodExitPos() by absolute exit" @ i);
				return;
			}
		}
	}

	p = Location;
	for ( i = 0; i < 50; ++i )
	{
		if( Driver.SetLocation(p) )
		{
			`log("SetGoodExitPos() falling back to vehicle location + "$i$" pawn heights :(");
			return;
		}
		p.Z += Driver.default.CollisionHeight;
	}

    log("SetGoodExitPos() could not find an exit pos!", 'Error');
}

// this is called to determine what forces we want applied to vehicle
native function bool ApplyVehicleForce(out vector Force, out vector Torque);

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	glog( RJ2, "VGVehicle::Died() called - Killer = "$Killer );

	if(Killer != None)
		SavedKiller = Killer.Pawn;
	else
		SavedKiller = None;
	Super.Died(Killer, damageType, HitLocation);
}
function DelayDied(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	glog( RJ2, "VGVehicle::DelayDied() called - Killer = "$Killer );

	DelayedKiller=Killer;
	DelayedDamageType=damageType;

	GotoState('DelayingDeath');
}

state DelayingDeath
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	function Landed(vector HitNormal)
	{
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	simulated function BeginState()
	{
		glog( RJ2, GetStateName()$"::BeginState() called" );
		bDelayingDeath=True;
		SetTimer(3.0, false);
		Throttle=0;
		Steering=0;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			DeathEmitter=Spawn(class'VehicleEffects.VehicleDeathFire',self);
			DeathEmitter.SetBase(self);
			DeathEmitter.SetRelativeLocation(DeathEmitterOffset);
		}
		if( CarBot(Controller) != None )
		{
			CarBot(Controller).CarDying();
		}
	}

	simulated function Timer()
	{
		if ( Role == ROLE_Authority )
		{
			Died(DelayedKiller, DelayedDamageType, Vect(0,0,0));
			DelayedKiller=None;
			DelayedDamageType=None;
		}
	}
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local VehiclePickup tempPickup;

	glog( RJ2, "VGVehicle:PlayDying("$DamageType$") enter bTearOff="$bTearOff );

	EndRideAll();

	if(Level.NetMode != NM_Client)
	{
		if(Level.Game.bTeamGame)
			Level.Game.RegenVehicle(SpawnedByTeam);
		else
			Level.Game.RegenVehicle(0);

		myStart.VehicleDied();

		/*
		if(Level.Game.bTeamGame)
		{
			Level.Game.GameReplicationInfo.VehicleCount[SpawnedByTeam] = Max(Level.Game.GameReplicationInfo.VehicleCount[Controller.PlayerReplicationInfo.Team.TeamIndex] - 1, 0);
		}
		else
		{
			Level.Game.GameReplicationInfo.VehicleCount[0] = Max(Level.Game.GameReplicationInfo.VehicleCount[0] - 1, 0);
		}
		*/
	}

	fEMPTimer = 0;
	bPlayedDeath = True;
	bTearOff = True;
	bCanTeleport = False;
	bReplicateMovement = False;
	log("Dying!");
	GotoState('VehicleDying');

	if(Level.NetMode == NM_Client)
		return;
	if(DroppedPickupClass != none)
	{
		tempPickup = spawn(DroppedPickupClass,,,Location,rot(0,0,0));
		tempPickup.bPickupOnce = true;
		tempPickup.InitDroppedPickupFor(None);
	}
}

function KillOccupant(Pawn Target)
{
	if(Target == None)
	{
		return;
	}
    if(Target.bPlayedDeath)
    {
        log( "RJ: trying to KillOccupant("@Target@" who is already dead!" );
    }
    else
    {
		//this is fucked, it only happens on the client, need to fix this shit sometime.
		Target.GotoState('PlayerWalking');
		Target.SetPhysics(PHYS_Falling);
		Target.bPhysicsAnimUpdate = Target.Default.bPhysicsAnimUpdate;
		Target.bCollideWorld = True;
		Target.SetCollision(True, True, True);
		if(Target.IsA('VGPawn'))
		{
            VGPawn(Target).RiddenVehicle = None;
		    VGPawn(Target).SetHavokCharacterCollisions( VGPawn(Target).UseHavokCharacterCollision() );
        }
		Target.bIsGunner = false;
		Target.SetBase(None);
		Target.Controller.bIsRidingVehicle = false;
        if(Target.Controller.IsA('VehiclePlayer'))
		{
			VehiclePlayer(Target.Controller).SetRiderCamStuff(Target, false);
			VehiclePlayer(Target.Controller).SetRiderCamYawLimit(0,0);
		}
		Target.TakeDamage(1200, SavedKiller, Target.Location, ((Velocity*0.8) + Vect(0,0,1000))*Target.mass, class'DriverDamage');
    }
}

state VehicleDying
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

	function Landed(vector HitNormal)
	{
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	simulated function KillDriver()
	{
		//log("XXXX - KillDriver() Called for "$self$" with driver "$Driver);
		local int i;
		local Controller C;
		local Pawn TempDriver;

		if(Controller != None && Driver != None)
		{
		    C = Controller;
		    TempDriver = Driver;
			C.UnPossess();
			C.Possess(TempDriver);
		}
		KillOccupant(TempDriver);
		Driver = None;
		for(i = 0; i < PassengerPointCount; i++)
		{
			KillOccupant(Passengers[i]);
			Passengers[i] = None;
		}
		SavedKiller = None;
	}

	simulated function FinalDeath()
	{
		local int i;
		local VGPawn passenger;

		glog( RJ2, GetStateName()$"::FinalDeath() called" );

		if ( GeneratedVehicleShadow != None )
		{
			GeneratedVehicleShadow.Shutdown();
		}

		//caution!! bTearOff has been set Authority is now the client!!!!!
		EndRideAll();
		if (Level.NetMode != NM_Client) //( Role == ROLE_Authority )
		{
			for(i=0;i<MAXPASSENGERS;i++)
			{
				if(PassengerPointsUsed[i]==1) //damage this driver and throw him clear
				{
					passenger = VGPawn(Passengers[i]);
					if(passenger==None) continue;  //just to be safe!

					passenger.RiddenVehicle=None;
					passenger.bIsGunner=false;

					passenger.SetBase(None);
					passenger.SetPhysics(PHYS_Falling);
					passenger.bDontRotateWithBase=False;

					passenger.Controller.bIsRidingVehicle=False;


					if( DriveController(passenger.Controller) != None)
						DriveController(passenger.Controller).EndRiding();


					PassengerPointsUsed[i]=0;
					Passengers[i]=None;

					// restore any havok-character collision
					passenger.SetHavokCharacterCollisions( passenger.UseHavokCharacterCollision() );

					if( passenger.Controller.IsA('VehiclePlayer'))
					{
						VehiclePlayer(passenger.Controller).SetRiderCamStuff(passenger, false);
						VehiclePlayer(passenger.Controller).SetRiderCamYawLimit(0,0);

					}					
					passenger.TakeDamage(1500, SavedKiller, Location, ((Velocity*0.8) + ( passenger.Location - Location ) * 5.0)*passenger.mass, class'DriverDamage');
				}
			}
			if ( bCauseHurtOnDestruction )
			{
				`log( "RJ: calling HurtRadius("@DestructionHurtDamage@","@DestructionHurtRadius@","@DestructionHurtDamageType@","@DestructionHurtMomentum@")" );
				HurtRadius(DestructionHurtDamage, DestructionHurtRadius, DestructionHurtDamageType, DestructionHurtMomentum, Location );
			}
		}

		if ( Level.NetMode != NM_DedicatedServer && PlayerCanSeeMe() )
		{
			DoVehicleDeathEffects();
		}

		if(Fire != none) {
			Fire.Destroy();
			Fire = none;
		}

		if(RiderWeapon != none) {
			RiderWeapon.Destroy();
			RiderWeapon = none;
		}
	}

	simulated function Timer()
	{
//		log("timer calling finaldeath");
		FinalDeath();
	}

	simulated function BeginState()
	{
		local Emitter	ExplRay;
		glog( RJ2, GetStateName()$"::BeginState() called bTearOff="$bTearOff );

		glog( RJ2, GetStateName()$"::BeginState() calling KillDriver and setting timer for FinalDeath" );

		if ( Level.NetMode != NM_DedicatedServer && PlayerCanSeeMe() )
		{
			log("Spawning rays");
			ExplRay = spawn(class'VehicleEffects.DavidVehicleExplosionRays',,,Location);
			ExplRay.SetBase(self);
		}

		if(Level.NetMode != NM_Client)
		{
			KillDriver();
		}
		if(IsA('VGHavokWaspSP')) // blow up right now you bitch
		{
		    FinalDeath();
		    Destroy();
        }
        else
        {
		    SetTimer(0.5,false);
		    LifeSpan = 1.0;
        }
	}
}

simulated function EMPHit(bool bEnhanced)
{
	if(!bPlayedDeath) {
		if(!bIsLocked) {
			KickEveryoneOut();
			LockVehicle();
		}

		if(!bEnhanced)
			fEMPTime = 2;	// disable for 2 seconds
		else
			fEMPTime = 5;

		fEMPTimer = 0;
		log("VGV:  EMPHit; EMPTime = "$fEMPTime$"; Role = "$Role$", RemoteRole = "$RemoteRole);
	}
}

state EMPEffect
{
	simulated function BeginState()
	{
		// EMP effect lasts for 10 seconds
		SetTimer(fEMPTime, false);
	}

	simulated function EndState()
	{
		log("Leaving EMPEffect");
		SetTimer(0, false);
		UnlockVehicle();
	}

	// reset the timer if hit again
//	simulated function EMPHit(float EMPTime)
//	{
//		fEMPTime = EMPTime;
//		SetTimer(fEMPTime, false);
//		log("VGV:  EMPEffect.EMPHit; EMPTime = "$EMPTime$"; Role = "$Role$", RemoteRole = "$RemoteRole);
//	}

	simulated function Timer()
	{
		local int i;

		for(i=0;i<VehicleActors.Length;i++)
		{
			if(VehicleActors[i] != none) {
				VehicleActors[i].OverlayMaterial = none;
				VehicleActors[i].RevertOverlayMaterial = none;
				VehicleActors[i].bRevertOverlay = false;
				VehicleActors[i].bUseOverlayTimer = false;
				VehicleActors[i].OverlayTimer = 0;
			}
		}
		UnlockVehicle();
		log("VGV:  EMPEffect.Timer; Role = "$Role$", RemoteRole = "$RemoteRole);
		if(!bPlayedDeath)
			GotoState('');
	}
}

simulated function DoVehicleDeathEffects()
{
	// set EMP hit count back to zero and make sure it's reenabled
	nEMPHitCount = 0;
	SetTimer(0, false);
	UnlockVehicle();
	if(Fire != none) {
		bOnFire = false;
		Fire.Destroy();
		Fire = none;
	}

	if(RiderWeapon != none) {
		RiderWeapon.Destroy();
		RiderWeapon = none;
	}

	PlayVehicleSoundEffect( DeathSound, DeathSoundVolume, 64 );
}

native function bool IsDead();

function bool IsDrivable()
{
	return !( bisDriven || bIsLocked || IsDead() || bDelayingDeath);
}

// get number of bodies connected to vehicle (i.e. wheels)
simulated native function int GetNumBodies();

// other classes should call this if they feel they may have changed the
// number of bodies connected to this vehicle
//
simulated function InvalidateNumBodies()
{
	NumBodies = 0;
}

// this is here so it can be used by both karma and havok vehicles
//
native function PlayTireImpactSound( vector impactVel, vector impactNorm );

native function UpdateTireSlipSound( float SlipAmount, Actor SoundActor );

simulated function GetDecoPieceRef(
	VGDecoPieceLocation	PieceLocation,
	int					AssemblyIndex,
	array<int>			PieceAsmIndices,	// existing piece attached static mesh indices
	out int				RefAsmIndex,		// index into existing attached static meshes
	out Actor			RefActor,
	out vector			offset
)
{
	switch ( PieceLocation )
	{
	case SPL_Chassis:
		RefAsmIndex = 0;
		RefActor = None;
		break;
	case SPL_Piece0:
		if ( PieceAsmIndices.Length > 0 )
		{
			RefAsmIndex = PieceAsmIndices[0];
		}
		else
		{
			RefAsmIndex = 0;
		}
		RefActor = None;
		break;
	case SPL_Piece1:
		if ( PieceAsmIndices.Length > 1 )
		{
			RefAsmIndex = PieceAsmIndices[1];
		}
		else
		{
			RefAsmIndex = 0;
		}
		RefActor = None;
		break;
	case SPL_Piece2:
		if ( PieceAsmIndices.Length > 2 )
		{
			RefAsmIndex = PieceAsmIndices[2];
		}
		else
		{
			RefAsmIndex = 0;
		}
		RefActor = None;
		break;
	default:
		RefAsmIndex = 0;
		RefActor = None;
	}
}

simulated function bool UseDecoPieceLocationForRotation( VGDecoPieceLocation loc )
{
	return !(loc == SPL_Wheel || loc == SPL_Wheel0 || loc == SPL_Wheel1 || loc == SPL_Wheel2 || loc == SPL_Wheel3);
}

simulated function CreateDecoAssembly(
	VGDecoAssemblyInfo			Info,
	int							AssemblyIndex,
	out array<int>				AttachedStaticMeshIndices
)
{
	local int					p;
	local VGDecoPiece			piece;
	local AttachedStaticMesh	asm;
	local float					MaxRenderDistSquared;
	local bool					bTargetUseRotation, bBaseUseRotation;

	MaxRenderDistSquared = Square(Info.MaxDrawDistance);
	for ( p = 0; p < Info.DecoPieces.Length; p++ )
	{
		piece = Info.DecoPieces[p];
		asm.StaticMesh = piece.StaticMesh;
		asm.MaxRenderDistSquared = MaxRenderDistSquared;

		// setup base
		//
		asm.BaseOffset = piece.BaseOffset;
		GetDecoPieceRef( piece.Base, AssemblyIndex, AttachedStaticMeshIndices, asm.BaseIndex, asm.BaseActor, asm.BaseOffset );
		bBaseUseRotation = UseDecoPieceLocationForRotation( piece.Base );

		// setup target
		//
		asm.TargetOffset = piece.TargetOffset;
		GetDecoPieceRef( piece.Target, AssemblyIndex, AttachedStaticMeshIndices, asm.TargetIndex, asm.TargetActor, asm.TargetOffset );
		bTargetUseRotation = UseDecoPieceLocationForRotation( piece.Target );

		// determine where upvector and rotations should come from
		//
		asm.UpVectorFrom = ASMU_None;
		asm.TargetOffsetMode = ASMO_Default;
		asm.BaseOffsetMode = ASMO_Default;
		if ( piece.Base == SPL_Chassis || piece.Base == SPL_ChassisWheelPos )
		{
			asm.UpVectorFrom = ASMU_Base;
			if ( !bTargetUseRotation )
			{
				// use chassis rotation to determine target offset
				//
				asm.TargetOffsetMode = ASMO_UseBaseRotation;
			}
		}
		else if ( piece.Target == SPL_Chassis || piece.Target == SPL_ChassisWheelPos)
		{
			asm.UpVectorFrom = ASMU_Target;
			if ( !bBaseUseRotation )
			{
				// use chassis rotation to determine base offset
				//
				asm.BaseOffsetMode = ASMO_UseTargetRotation;
			}
		}
		else if ( !bBaseUseRotation && !bTargetUseRotation )
		{
			asm.UpVectorFrom = ASMU_Actor;
			asm.BaseOffsetMode = ASMO_UseActorRotation;
			asm.TargetOffsetMode = ASMO_UseActorRotation;
		}

		// add it to our our vehicle and save the index
		//
		AttachedStaticMeshIndices.Length = p + 1;
		AttachedStaticMeshIndices[p] = AddAttachedStaticMesh( asm ) + 1;
	}
}

// don't do anything when FaceRotation is called
simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
}

// tastes like burninating!
simulated function Tick(float dt)
{
	Super.Tick(dt);

	// need to make sure that vehicle weapons are placed properly because otherwise on replication they assume that the vehile
	// is at rotation=(0,0,0) which more often than not it isn't
	if(Level.NetMode == NM_Client)
		SetupVehicleWeaponOrientation();

	// if burning, take damage
	if(bOnFire) {
		burningTime += dt;
		if(burningTime >= maxBurningTime) {
			bOnFire = false;
			Fire.Kill();
			FireInstigator = none;
			fireDamagePerInterval = 0;
		}
		else if( (burningTime-lastFireDamageTime) >= fireDamageFreq) {
			// still burninating... take damage
			lastFireDamageTime = burningTime;
			TakeDamage(fireDamagePerInterval, FireInstigator, Location, vect(0, 0, 0), BurnDamageType);
//			log("VGRN:  Yoink! ("$self$") for "$fireDamagePerInterval);
		}

		if(fireDecreaseAt.length > 0 && burningTime >= fireDecreaseAt[0]) {
			fireDamagePerInterval -= 5;
			if(fireDamagePerInterval < 0)
				fireDamagePerInterval = 0;

//			log("VGRN:  Less Burnination! ("$fireDamagePerInterval$", "$fireDecreaseAt[0]$")");
			fireDecreaseAt.Remove(0, 1);
		}
	}

	if(bIsLocked) {
		// this is just to make sure the material swapping gets done on the client side in a relatively prompt manner
		LockVehicle();

		fEMPTimer += dt;
		if(fEMPTimer > fEMPTime) {
			fEMPTimer = 0;
			UnlockVehicle();
			bIsLocked = false;
		}
	}
}

// burninate this vehicular device
simulated function SetOnFire()
{
	if(!bOnFire) {
		// burn!!
		bOnFire = true;
		Fire = spawn(class'ParticleSmallFire',self,,Location);
		if(Fire != none) {
			burningTime = 0;
			maxBurningTime = 5;
			fireDamagePerInterval = 5;
			lastFireDamageTime = -fireDamageFreq;
			fireDecreaseAt[0] = maxBurningTime;
//			log("VGRN:  Burninating the vehicles!");
			Fire.SetBase(self);
		}
	}
	else if(fireDamagePerInterval < 5) {
		// already on fire, do increased damage
		fireDecreaseAt[fireDamagePerInterval] = burningTime+5;
		fireDamagePerInterval += 5;
		maxBurningTime = burningTime+5;
//		log("VGRN:  More Burnination! ("$fireDamagePerInterval$", "$maxBurningTime$")");
	}
}

event Touch(Actor Other)
{
	Super.Touch(Other);

//	log("VGVehicle:  touch other = "$Other);
}

simulated function SetupVehicleWeaponOrientation()
{
	if(bWeaponsNeedOrientation && Weapon != none) {
		if(Weapon != none && Weapon.ThirdPersonActor != none)
			Weapon.AttachToPawn(self);

		if(RiderWeapon != none && RiderWeapon.ThirdPersonActor != none)
			RiderWeapon.AttachToPawn(self);

		bWeaponsNeedOrientation = false;
	}
}

// helper function for setting up vehicle weapons (putting it here so we don't have to duplicate it all over the place)
simulated function SetupVehicleWeapons()
{
//	local Weapon bogieGunR;
	local class<Weapon> WeaponClass;
	local int c;

	// setup vehicle weapons... different action for each vehicle type;  this would be
	// better placed in the actual vehicle classes, I think, but for now I'll just put them here
	if(IsA('VGHavokBogieSP') || IsA('VGHavokBogieMP') ) {
//		log("setting up weapons for "$self);
		if(RiderWeapon == none) {
			WeaponClass = class<Weapon>(DynamicLoadObject("VehicleWeapons.BogieLauncher", class'Class') );
			RiderWeapon = Spawn(WeaponClass, self,, Location, Rotation);
			log("---> riderWeapon = "$RiderWeapon);
			if(RiderWeapon != none) {
				RiderWeapon.SetPhysics(PHYS_RidingBase);

				RiderWeapon.AttachToPawn(self);
//				log("mv.rw = "$RiderWeapon);
			}

			GiveWeapon("VehicleWeapons.BogieGun");
		}

		// add the bogie's side guns - first the master gun that controls the second one
//		log("gave weapon to "$self);
		c = 1;
	}
	else if(IsA('VGHavokDozerSP') || IsA('VGHavokDozerMP') ) {
//		log("setting up weapons for "$self);
		GiveWeapon("VehicleWeapons.DozerLauncher");
		c = 1;
//		log("gave weapon to "$self);
	}
	else if(IsA('VGHavokWaspSP') || IsA('VGHavokWaspMP') ) {
//		log("setting up weapons for "$self);
		GiveWeapon("VehicleWeapons.Puncher");
		c = 1;
//		log("gave weapon to "$self);
	}
	else if(IsA('VGHavokDartSP') || IsA('VGHavokDartMP') ) {
		GiveWeapon("VehicleWeapons.DartGun");
		c = 1;
	}
	else if(IsA('VGHavokSabreSP') || IsA('VGHavokSabreMP') ) {
		if(RiderWeapon == none) {
			WeaponClass = class<Weapon>(DynamicLoadObject("VehicleWeapons.DartGun", class'Class') );
			RiderWeapon = Spawn(WeaponClass, self,, Location, Rotation);
			if(RiderWeapon != none) {
				RiderWeapon.SetPhysics(PHYS_RidingBase);
				RiderWeapon.AttachToPawn(self);
			}

			//GiveWeapon("VehicleWeapons.SabreGun");
		}
		c = 1;
	}
	else if(IsA('VGHavokChugborSP') || IsA('VGHavokChugborMP') ) {
		GiveWeapon("VehicleWeapons.DartGun");
		c = 1;
	}

	if(c==0)
	{
		GiveWeapon("VehicleWeapons.Puncher");
	}

	CheckCurrentWeapon();
}

event PreLoadData()
{
	local int c;

	Super.PreLoadData();

	for ( c = 0; c < PreLoadClasses.Length; c++ )
	{
		PreLoad( DynamicLoadObject( PreLoadClasses[c], class'Class') );
	}
}

//===========
// AI Related
//===========

function StopMoving()
{
	bBrake = true;
	Steering = 0;
	Throttle = 0;
}

function ResetVehMoveTowardParams()
{
	vehMoveTowardParams.approachDist = 0;
	vehMoveTowardParams.bThrottleForAim = false;
	vehMoveTowardParams.weaponProjectileSpeed = 0;
	vehMoveTowardParams.bReverse = false;
	vehMoveTowardParams.bAvoidFire = false;
	vehMoveTowardParams.bExtraMoveTime = false;
	vehMoveTowardParams.AvoidFireSign = 0;
}

function SetVehMoveTowardParams(optional float approachDist,
							 optional bool throttleForAim,
							 optional float weaponProjectileSpeed,
							 optional bool bReverse,
							 optional bool bAvoidFire)
{
	vehMoveTowardParams.approachDist = approachDist*approachDist;
	vehMoveTowardParams.bThrottleForAim = throttleForAim;
	vehMoveTowardParams.weaponProjectileSpeed = weaponProjectileSpeed;
	vehMoveTowardParams.bReverse = bReverse;
	vehMoveTowardParams.bAvoidFire = bAvoidFire;
	if( bAvoidFire )
	{
		vehMoveTowardParams.bExtraMoveTime = true;
		vehMoveTowardParams.AvoidFireSign = 255 * FRand();
	}
}

function bool IsMobile()
{
    return (VehicleType == VT_Wheeled ||
                VehicleType == VT_Hover);
}

function InitializeAILookUps()
{
	maxCarSpeed = getMaxSpeed();
	minTurnRadius = getTurningRadius();
}

//should be overridden for each type of vehicle (motorcycle, car etc)
function float getTurningRadius()
{
	return 0;
}

function float getMaxSpeed()
{
	return 3000;
}

defaultproperties
{
     MinimumTireSlipTimeStamp=0.500000
     StuckLimit=1.000000
     ChassisMass=1.000000
     ChassisFriction=0.250000
     FlipTime=100000.000000
     TurboMultiplier=2.000000
     TurboTime=3.000000
     HeadLightProjectorDistance=1200.000000
     HeadLightReattachDistance=300.000000
     ShadowProjectorDistance=200.000000
     ShadowReattachDistance=300.000000
     GeneratedShadowMaxTraceDistance=2000.000000
     GeneratedShadowLightDistance=2000.000000
     GeneratedShadowCullDistance=4000.000000
     GeneratedShadowStartFadeDistance=2000.000000
     ImpactEffectThreshold=50.000000
     campitch=500.000000
     camdist=800.000000
     camheight=250.000000
     caminterpyawspeed=10.000000
     LookAngleForMaxSteer=4096.000000
     LookSteerMinPitch=-8192.000000
     LookSteerMaxPitch=1000.000000
     HitSoundMinImpactThreshold=10.000000
     HitSoundMaxImpactThreshold=10.000000
     TireImpactSoundMinImpactThreshold=250.000000
     TireImpactSoundMaxImpactThreshold=1000.000000
     MinRamSpeed=2000.000000
     MaxRamSpeed=3000.000000
     RammingDamage=20.000000
     RammingDamageMultiplier=1.000000
     RammingVelocityMultiplier=1.000000
     TimeTillDeath=30.000000
     MaxAllowableServerError=500.000000
     MaxEnterDistance=450.000000
     ExitBrakeTime=1.000000
     fireDamageFreq=1.000000
     DestructionHurtDamage=75.000000
     DestructionHurtRadius=512.000000
     DestructionHurtMomentum=1024.000000
     LockedEffectMaterial=Shader'NoonTextures.VehicleFX.Vehicle_Repel'
     VehicleDyingStateName="VehicleDying"
     DelayingDeathStateName="DelayingDeath"
     DrivingAnim="Idle_Character02"
     DriverPointName="Driver"
     ShadowClass=Class'Engine.xShadowProjector'
     ImpactEffect=Class'VehicleEffects.VehicleImpactEffect'
     SavedMoveClass=Class'VehicleGame.VehicleSavedMove'
     BurnDamageType=Class'VehicleGame.VGBurningDamage'
     DestructionHurtDamageType=Class'VehicleGame.VehicleExplDamage'
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     ExitPos(0)=(Y=-250.000000,Z=100.000000)
     ExitPos(1)=(Y=250.000000,Z=100.000000)
     ExitPos(2)=(X=350.000000,Z=100.000000)
     ExitPos(3)=(X=-350.000000,Z=100.000000)
     LightRotation=(Pitch=-6000)
     ShadowRot=(Pitch=-16384)
     GeneratedShadowLightDir=(X=1.000000,Y=1.000000,Z=2.000000)
     VehicleName="Unnamed Vehicle"
     TailLightBrakeSaturation=255
     TailLightBrakeBrightness=255
     TailLightBackupBrightness=255
     TailLightDrivingSaturation=255
     TailLightDrivingBrightness=128
     HeadLightHue=150
     HeadLightSaturation=45
     HeadLightBrightness=255
     EnterVehicleSoundVolume=255
     ExitVehicleSoundVolume=255
     TurboSoundVolume=255
     EngineSoundPitch=64
     EngineSoundVolume=255
     HitSoundMaxVolume=255
     MasterVehicleSoundVolume=128
     TireImpactSoundMaxVolume=255
     DriverState=DS_NoDriver
     bWeaponsNeedOrientation=True
     bWaitingForEnterSound=True
     bEnableHeadLightEmitter=True
     bGeneratedShadowUseSunlightDir=True
     bNeedsPlayerOwner=True
     bCauseHurtOnDestruction=True
     Health=300
     SightRadius=12000.000000
     GroundSpeed=10000.000000
     LandMovementState="PlayerInVehicle"
     WaterMovementState="PlayerInVehicle"
     bCanBeBaseForPawns=True
     bCanPickupInventory=True
     bUseCompressedPosition=False
     bCanHoldGameObjects=False
     SoundRadius=255.000000
     TransientSoundRadius=255.000000
     KarmaEncroachSpeed=1200.000000
     Physics=PHYS_None
     AmbientGlow=20
     bAcceptsProjectors=False
     bReplicateMovement=False
     bDestroyInPainVolume=True
     bNeedPreLoad=True
}
