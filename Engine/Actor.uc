//=============================================================================
// Actor: The base class of all actors.
// Actor is the base class of all gameplay objects.  
// A large number of properties, behaviors and interfaces are implemented in Actor, including:
//
// -	Display 
// -	Animation
// -	Physics and world interaction
// -	Making sounds
// -	Networking properties
// -	Actor creation and destruction
// -	Triggering and timers
// -	Actor iterator functions
// -	Message broadcasting
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
	native
	nativereplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off MASKED=1


//WD: begin
//-----------------------------------------------------------------------------
// Lighting.

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
    LE_Negative, // sjs
	LE_Sunlight,
	LE_QuadraticNonIncidence
} LightEffect;

// Lighting info.
var(LightColor) float
	LightBrightness;
var(Lighting) float
	LightRadius;
var(LightColor) byte
	LightHue,
	LightSaturation;
var(Lighting) byte
	LightPeriod,
	LightPhase,
	LightCone,
	CoronaBrightness;

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Manual,
	PHYS_Projectile,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_Ladder,
	PHYS_RootMotion,
	PHYS_RootMotionWithPhysics,
    PHYS_Karma,
    PHYS_KarmaRagDoll,
    PHYS_Hovering,
    PHYS_CinMotion,
	PHYS_RidingBase,
	PHYS_Havok,
	PHYS_HavokSkeleton
} Physics;

// Drawing effect.
var(Display) const enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
	DT_StaticMesh,
	DT_DrawType,
	DT_Particle,
	DT_AntiPortal,
	DT_FluidSurface
} DrawType;

enum ENetRole
{
	ROLE_None,              // No role at all.
	ROLE_DumbProxy,			// Dumb proxy of this actor.
	ROLE_SimulatedProxy,	// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,	// Locally autonomous proxy of this actor.
	ROLE_Authority,			// Authoritative control over the actor.
};
var ENetRole RemoteRole;

var(Display) const StaticMesh StaticMesh;		// StaticMesh if DrawType=DT_StaticMesh

// Owner.
var const Actor			 Owner;			 // Owner actor.
var const Actor          Base;           // Actor we're standing on.

var const Actor AirBase; //cmr -- for keeping track of a mover which is influencing an actor while not actually based

var bool bDontRotateWithBase;

struct ActorRenderDataPtr { var int Ptr; };
struct LightRenderDataPtr { var int Ptr; };

var const transient native ActorRenderDataPtr	ActorRenderData;
var const native LightRenderDataPtr	LightRenderData;
var const native int				RenderRevision;

enum EFilterState
{
	FS_Maybe,
	FS_Yes,
	FS_No
};

var const native EFilterState	StaticFilterState;

struct BatchReference
{
	var int	BatchIndex,
			ElementIndex;
};

var const native array<BatchReference>	StaticSectionBatches;

var(Display) const name	ForcedVisibilityZoneTag; // jim: Makes the visibility code treat the actor as if it was in the zone with the given tag.


// Lighting.
var(Lighting) bool	     bSpecialLit;			// Only affects special-lit surfaces.
var(Lighting) bool	     bActorShadows;			// Light casts actor shadows.
var(Lighting) bool	     bCorona;			   // Light uses Skin as a corona.
var(Lighting) bool       bCoronaAttenuation;	//Corona shrinks with distance. (BB)
var(Lighting) bool       bAttenByLife;			// sjs - attenuate light by diminishing lifespan
var(Lighting) bool		 bLightingVisibility;	// Calculate lighting visibility for this actor with line checks.
var bool				 bLightChanged;			// Recalculate this light's lighting now.

// mechanism which allows
// - surfaces to restrict which lights they are affected by and
//   vice-versa
//   - if bMatchLightTags is on for a surface it will only be
//     affected by lights that have a light tag that matches one
//     of it's light tags
//   - if bMatchLightTags is on for a light it will only affect
//     surfaces that have a light tag that matches one of it's light tags
// - RJ@BB
var(Lighting) bool			bMatchLightTags;


//WD: end

// Flags.
var			  const bool	bStatic;			// Does not move or change over time. Don't let L.D.s change this - screws up net play
var(Advanced)		bool	bHidden;			// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;			// Cannot be deleted during play.
var transient const bool	bTicked;			// Actor has been updated.
var(Lighting)		bool	bDynamicLight;		// This light is dynamic.
var					bool	bTimerLoop;			// Timer loops (else is one-shot).
var					bool    bOnlyOwnerSee;		// Only owner can see this actor.
var(Advanced)		bool    bHighDetail;		// Only show up on high-detail.
var					bool	bOnlyDrawIfAttached;	// don't draw this actor if not attached (useful for net clients where attached actors and their bases' replication may not be synched)
var(Advanced)		bool	bStasis;			// In StandAlone games, turn off if not in a recently rendered zone turned off if  bStasis  and physics = PHYS_None or PHYS_Rotating.
var					bool	bTrailerAllowRotation; // If PHYS_Trailer and want independent rotation control.
var					bool	bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.
var					bool	bTrailerPrePivot;	// If PHYS_Trailer and true, offset from owner by PrePivot.
var(Collision) 	    bool	bWorldGeometry;		// Collision and Physics treats this actor as world geometry
var(Display)		bool    bAcceptsProjectors;	// Projectors can project onto this actor
var					bool	bOrientOnSlope;		// when landing, orient base on slope of floor
var			  const	bool	bOnlyAffectPawns;	// Optimisation - only test ovelap against pawns. Used for influences etc.
var(Display)		bool	bDisableSorting;	// Manual override for translucent material sorting.

var					bool    bShowOctreeNodes;
var					bool    bWasSNFiltered;      // Mainly for debugging - the way this actor was inserted into Octree.

// Networking flags
var			  const	bool	bNetTemporary;				// Tear-off simulation in network play.
var					bool	bOnlyRelevantToOwner;			// this actor is only relevant to its owner.
var transient const	bool	bNetDirty;					// set when any attribute is assigned a value in unrealscript, reset when the actor is replicated
var					bool	bAlwaysRelevant;			// Always relevant for network.
var					bool	bReplicateInstigator;		// Replicate instigator to client (used by bNetTemporary projectiles).
var					bool	bReplicateMovement;			// if true, replicate movement/location related properties
var					bool	bSkipActorPropertyReplication; // if true, don't replicate actor class variables for this actor
var					bool	bUpdateSimulatedPosition;	// if true, update velocity/location after initialization for simulated proxies
var					bool	bTearOff;					// if true, this actor is no longer replicated to new clients, and 
														// is "torn off" (becomes a ROLE_Authority) on clients to which it was being replicated.
var					bool	bOnlyDirtyReplication;		// if true, only replicate actor if bNetDirty is true - useful if no C++ changed attributes (such as physics) 
														// bOnlyDirtyReplication only used with bAlwaysRelevant actors
var					bool	bReplicateAnimations;		// Should replicate SimAnim
var const           bool    bNetInitialRotation;        // sjs - Should replicate initial rotation
var					bool	bCompressedPosition;		// used by networking code to flag compressed position replication

var					bool	bNoSave;					// don't save this actor during save game - rj

// Net variables.
var ENetRole Role;

var transient const Level	XLevel;			// Level object.
var				float       TimerRate;		// Timer event, 0=no timer.
var(Advanced)	float		LifeSpan;		// How old the object lives before dying, 0=forever.
var(Display)	Material	OverlayMaterial; // sjs - shader/material effect to use with skin
var(Display) const mesh		Mesh;			// Mesh if DrawType=DT_Mesh.
var(Display)	BYTE		bAffectedByEnhancedVision; //Is this actor affected by the enhanced vision (sjs - now a bitmask for what skins to override with heat)
//var(Display)	Texture		EnhancedVisionTexture; //Colors used to render enhanced vision
var const transient int		NetTag;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

// jij ---
struct native export XboxAddr
{
    var int ina;
    var int inaOnline;
    var int wPortOnline;
    var byte abEnet[6];
    var byte abOnline[20];
    var String Gamertag;
};
// --- jij

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var transient float		LastRenderTime;	// last time this actor was rendered.
var const PointRegion     Region;        // Region this actor is in.
var transient array<int>  Leaves;		 // BSP leaves this actor is in.
var Pawn                  Instigator;    // Pawn responsible for damage caused by this actor.
var(Sound) sound          AmbientSound;  // Ambient sound effect.
var Inventory             Inventory;     // Inventory chain.
var		const	float       TimerCounter;	// Counts up until it reaches TimerRate.
var transient MeshInstance MeshInstance;	// Mesh instance.
var(Display) float		  LODBias;
var(Object) name InitialState;
var(Object) name Group;

// Event handling
//
// The event this actor causes.
var(Events) name Event; 
// Associates a handler name with an event, for use by TriggerEx()
struct native export EventHandlerMapping {
    var() Name EventName;
    var() Name HandledBy;
};
// Actor's tag name.
var(Events) name Tag;   
// An alternative list of event names this actor reacts to.
// This is intended to be more intuitive than "tag", and allow
// more freedom in choosing event names.
var(Events) array<EventHandlerMapping> EventBindings;
// Decides whether to call TriggerEx (true) or just Trigger (false)
// for this actor.  Actor subclasses may override this.
var(Events) editconst const bool bHasHandlers;

// Internal.
var const array<Actor>    Touching;		 // List of touching actors.
var const transient array<int>  OctreeNodes;// Array of nodes of the octree Actor is currently in. Internal use only.
var const transient Box	  OctreeBox;     // Actor bounding box cached when added to Octree. Internal use only.
var const transient vector OctreeBoxCenter;
var const transient vector OctreeBoxRadii;
var const actor           Deleted;       // Next actor in just-deleted chain.
var const float           LatentFloat;   // Internal latent function use.

// Internal tags.
var const native int CollisionTag;
var const transient int JoinedTag;

// The actor's position and rotation.
var const	PhysicsVolume	PhysicsVolume;	// physics volume this actor is currently in
var(Movement) const vector	Location;		// Actor's location; use Move to set.
var(Movement) const rotator Rotation;		// Rotation.
var(Movement) vector		Velocity;		// Velocity.
var			  vector        Acceleration;	// Acceleration.

// Attachment related variables
var(Movement)	name	AttachTag;
var const array<Actor>  Attached;			// array of actors attached to this actor.
var const vector		RelativeLocation;	// location relative to base/bone (valid if base exists)
var const rotator		RelativeRotation;	// rotation relative to base/bone (valid if base exists)
var const name			AttachmentBone;		// name of bone to which actor is attached (if attached to center of base, =='')

var(Movement) const bool bHardAttach;       // Uses 'hard' attachment code. bBlockActor and bBlockPlayer must also be false.
											// This actor cannot then move relative to base (setlocation etc.).
											// Dont set while currently based on something!
											// 
var const     Matrix    HardRelMatrix;		// Transform of actor in base's ref frame. Doesn't change after SetBase.

var const bool			bDontFailAttachedMove; //cmr -- forcing attached things to always update position, and not fail. EVER.

// Projectors
struct ProjectorRenderInfoPtr { var int Ptr; };	// Hack to to fool C++ header generation...
struct StaticMeshProjectorRenderInfoPtr { var int Ptr; };
var const native array<ProjectorRenderInfoPtr> Projectors;// Projected textures on this actor
var const native array<StaticMeshProjectorRenderInfoPtr>	StaticMeshProjectors;

//-----------------------------------------------------------------------------
// Display properties.

var(Display) Material		Texture;			// Sprite texture.if DrawType=DT_Sprite
var StaticMeshInstance		StaticMeshInstance; // Contains per-instance static mesh data, like static lighting data.
var const export model		Brush;				// Brush if DrawType=DT_Brush.
var(Display) const float	DrawScale;			// Scaling factor, 1.0=normal size.
var(Display) const vector	DrawScale3D;		// Scaling vector, (1.0,1.0,1.0)=normal size.
var(Display) vector			PrePivot;			// Offset from box center for drawing.
var(Display) array<Material> Skins;				// Multiple skin support - not replicated (use SetSkin() to modify)
var(Display) byte			AmbientGlow;		// Ambient brightness, or 255=pulsing.
var(Display) byte           MaxLights;          // Limit to hardware lights active on this primitive.
var(Display) ConvexVolume	AntiPortal;			// Convex volume used for DT_AntiPortal

// sjs ---
var(Display) Material       UV2Texture;
var(Display) enum EUV2Mode
{
    UVM_MacroTexture,
    UVM_LightMap,
    UVM_Skin,
} UV2Mode;

var(Collision) enum ESurfaceTypes // !! - must mirror with Material.uc in order for BSP geom surface's to match
{
	EST_Default,
	EST_Rock,
	EST_Dirt,
	EST_Metal,
	EST_Wood,
	EST_Plant,
	EST_Flesh,
    EST_Ice,
    EST_Snow,
    EST_Water,
    EST_Glass,
	EST_Wet,
	EST_Stone,
	EST_Sand,
	EST_ThinDefault,
	EST_ThinRock,
	EST_ThinDirt,
	EST_ThinMetal,
	EST_ThinWood,
	EST_ThinPlant,
	EST_ThinFlesh,
    EST_ThinIce,
    EST_ThinSnow,
    EST_ThinWater,
    EST_ThinGlass,
	EST_ThinWet,
	EST_ThinStone,
	EST_ThinSand,
	EST_HeatPipes,
    EST_Concrete
} SurfaceType;

var(Display) float          CullDistance;       // sjs 0 == no distance cull, < 0 only drawn at distance > 0 cull at distance
var(Display) float			ScaleGlow;			// sjs - may it never ever die
// --- sjs

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_Alpha,
	STY_Additive,
	STY_Subtractive,
	STY_Particle,
	STY_AlphaZ,
} Style;

// Display.
var(Display)  bool      bUnlit;					// Lights don't affect actor.
var(Display)  bool      bShadowCast;			// Casts static shadows.
var(Display)  bool		bStaticLighting;		// Uses raytraced lighting.
var(Display)  bool		bUseLightingFromBase;	// Use Unlit/AmbientGlow from Base

// Advanced.
var			  bool		bHurtEntry;				// keep HurtRadius from being reentrant
var(Advanced) bool		bGameRelevant;			// Always relevant for game
var(Advanced) bool		bCollideWhenPlacing;	// This actor collides with the world when placing.
var			  bool		bTravel;				// Actor is capable of travelling among servers.
var(Advanced) bool		bMovable;				// Actor can be moved.
var			  bool		bDestroyInPainVolume;	// destroy this actor if it enters a pain volume
var(Advanced) bool		bShouldBaseAtStartup;	// if true, find base for this actor at level startup, if collides with world and PHYS_None or PHYS_Rotating
var			  bool		bPendingDelete;			// set when actor is about to be deleted (since endstate and other functions called 
												// during deletion process before bDeleteMe is set).
var					bool	bAnimByOwner;		// Animation dictated by owner.
var 				bool	bOwnerNoSee;		// Everything but the owner can see this actor.
var(Advanced)		bool	bCanTeleport;		// This actor can be teleported.
var					bool	bClientAnim;		// Don't replicate any animations - animation done client-side
var					bool    bDisturbFluidSurface; // Cause ripples when in contact with FluidSurface.
var			  const	bool	bAlwaysTick;		// Update even when players-only.

//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
//var(Sound) float        SoundRadius;			// Radius of ambient sound.
var	float		        SoundRadius;			// Radius of ambient sound. XJ remove editor access!!
var(Sound) byte         SoundVolume;			// Volume of ambient sound.
var(Sound) byte         SoundPitch;				// Sound pitch shift, 64.0=none.

// Sound occlusion
enum ESoundOcclusion
{
	OCCLUSION_Default,
	OCCLUSION_None,
	OCCLUSION_BSP,
	OCCLUSION_StaticMeshes,
};

var(Sound) ESoundOcclusion SoundOcclusion;		// Sound occlusion approach.

// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};

// Regular sounds.
var(Sound) float TransientSoundVolume;	// default sound volume for regular sounds (can be overridden in playsound)
//var(Sound) float TransientSoundRadius;	// default sound radius for regular sounds (can be overridden in playsound)
var float		TransientSoundRadius;	// XJ remove editor access!!
//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) const float CollisionRadius;		// Radius of collision cyllinder.
var(Collision) const float CollisionHeight;		// Half-height cyllinder.

// Collision flags.
var(Collision) const bool bCollideActors;		// Collides with other actors.
var(Collision) bool       bCollideWorld;		// Collides with the world.
var(Collision) bool       bBlockActors;			// Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;		// Blocks other player actors.
var(Collision) bool       bProjTarget;			// Projectiles should potentially target this actor.
var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
var(Collision) bool       bAutoAlignToTerrain;  // Auto-align to terrain in the editor
var(Collision) bool		  bUseCylinderCollision;// Force axis aligned cylinder collision (useful for static mesh pickups, etc.)
var(Collision) bool       bCheckOverlapWithBox; // CMR - This only affects actors who use a static mesh for collision, and need accurate touch/untouch calls.  Serves no other purpose.
var(Collision) const bool bBlockKarma;			// Block actors being simulated with Karma.
var(Collision) bool		  bDisableKarmaEncroacher;	// BB: If true, this actor won't be a Karma encroacher
var(Collision) const float KarmaEncroachSpeed;		// BB: Speed at which a karma actor triggers an encroach on another actor (until then it just pushes).

// jjs -
var(Display)        bool    bAlwaysFaceCamera;          // actor will be rendered always facing the camera like a sprite
// - jjs

// jij ---
var(Advanced)       bool    bNetNotify;                 // actor wishes to be notified of replication events
// --- jij

// rj@bb ---
// - similar to bNetNotify but this controls whether PostNetReplicate() should be called
var bool					bReplicateNotify;
// --- rj@bb

// gam ---
var private         bool    bDestroyPropagatedFully;    // Used to detect failure to call Super.Destroyed()
// --- gam

var(Lighting) float		 CoronaDrawScale;//for when you want to specify corona size independently from the actor it's part of.
var(Lighting) float		 CoronaFadeMultiplier;//for fading out coronas faster.  Larger number makes them fade out faster, smaller=slower.  (BB)

//-----------------------------------------------------------------------------
// Physics.

// Options.
var			  bool		  bIgnoreOutOfWorld; // Don't destroy if enters zone zero
var(Movement) bool        bBounce;           // Bounces when hits ground fast.
var(Movement) bool		  bFixedRotationDir; // Fixed direction of rotation.
var(Movement) bool		  bRotateToDesired;  // Rotate to DesiredRotation.
var           bool        bInterpolating;    // Performing interpolating.
var			  const bool  bJustTeleported;   // Used by engine physics - not valid for scripts.

var				bool		bIgnoresPauseTime;	//XJ Actor won't be paused
var				float		PauseTime;			//XJ Actor won't update until this time.
var				bool		bPaused;			// actor is paused and won't be ticked until the flag is set to false
												// this is so that actors in the actor pool that aren't currently active aren't
												// eating up processing time

// Physics properties.
var(Movement) float       Mass;				// Mass of this actor.
var(Movement) float       Buoyancy;			// Water buoyancy.
var(Movement) rotator	  RotationRate;		// Change in rotation per second.
var(Movement) rotator     DesiredRotation;	// Physics will smoothly rotate actor to this rotation if bRotateToDesired.
var			  Actor		  PendingTouch;		// Actor touched during move which wants to add an effect after the movement completes 
var       const vector    ColLocation;		// Actor's old location one move ago. Only for debugging
  
var(Events)     Name    ExcludeTag[8];      // sjs - multipurpose exclusion tag for excluding lights, projectors, rendering actors, blocking weather

var(Lighting) array<name>	LightTags;			// rj@bb - light tags - see bMatchLightTags above
var(Lighting) array<name>	LightExcludeTags;
var(Lighting) array<class>	LightClassTags;
var(Lighting) array<class>	LightClassExcludeTags;

const MAXSTEPHEIGHT = 35.0; // Maximum step height walkable by pawns
const MINFLOORZ = 0.7; // minimum z value for floor normal (if less, not a walkable floor)
					   // 0.7 ~= 45 degree angle for floor
					   
// ifdef WITH_KARMA

//XJ: Karma Momentum conversion factor
const KMOMENTUMCONVERSION = 20.0;

// Used to avoid compression
struct KRBVec
{
	var float	X, Y, Z;
};

struct KRigidBodyState
{
	var KRBVec	Position;
	var Quat	Quaternion;
	var KRBVec	LinVel;
	var KRBVec	AngVel;
};
					   
var const native int KStepTag;

// endif

// ifdef WITH_HAVOK
var(Havok) export editinline HavokParamsCollision HParams;	// parameters for Havok Collision/Dynamics
// endif

//-----------------------------------------------------------------------------
// Animation replication (can be used to replicate channel 0 anims for dumb proxies)
struct AnimRep
{
	var name AnimSequence; 
	var bool bAnimLoop;	
	var byte AnimRate;		// note that with compression, max replicated animrate is 4.0
	var byte AnimFrame;
	var byte TweenRate;		// note that with compression, max replicated tweentime is 4 seconds
};
// only replicated if bReplicateAnimations is true
// rj: this is also used to store the currently running anim in save games
var AnimRep		  SimAnim;		   

//-----------------------------------------------------------------------------
// Forces.

enum EForceType
{
	FT_None,
	FT_DragAlong,
    FT_Constant,
};

var (Force) EForceType	ForceType;
var (Force)	float		ForceRadius;
var (Force) float		ForceScale;
var (Force) float       ForceNoise; // sjs - 0.0 - 1.0


//-----------------------------------------------------------------------------
// Networking.

// Network control.
var float NetPriority; // Higher priorities means update it more frequently.
var float NetUpdateFrequency; // How many seconds between net updates.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoRecording;// True we are currently recording a client-side demo
var const bool bRepClientDemo;		// True if remote client is recording demo
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.
var const bool bDemoOwner;			// Demo recording driver owns this actor.
var bool	   bNoRepMesh;			// don't replicate mesh

//Editing flags
var(Advanced) bool        bHiddenEd;     // Is hidden during editing.
var(Advanced) bool        bHiddenEdGroup;// Is hidden by the group brower.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.
var	bool				  bObsolete;	 // actor is obsolete - warn level designers to remove it
var (Collision) bool	  bPathColliding;// this actor should collide (if bWorldGeometry && bBlockActors is true) during path building (ignored if bStatic is true, as actor will always collide during path building)
var transient bool		  bPathTemp;	 // Internal/path building
var	bool				  bScriptInitialized; // set to prevent re-initializing of actors spawned during level startup
var(Advanced) bool        bLockLocation; // Prevent the actor from being moved in the editor.
var const bool            bNeedPreLoad;

// ifdef WITH_KARMA
var transient bool									bK829CompCheck;	// horrible flag used for BB 829 backwards compatibility			

// these structs needs to be synchronized with the C++ version in KTypes.h
//
struct KCollisionSphere
{
	var float	Radius;
	var vector	Location;
};
struct KCollisionBox
{
	var float	X;
	var float	Y;
	var float	Z;
	var vector	Location;
	var rotator	Rotation;
};
struct KCollisionCylinder
{
	var float	Radius;
	var float	Height;
	var vector	Location;
	var rotator	Rotation;
};
struct KCollisionHull
{
	var array<vector> VertexData;
	var vector	Location;
	var rotator	Rotation;
};
struct KCollisionGeom
{
	var array<KCollisionSphere>		CollisionSpheres;
	var array<KCollisionBox>		CollisionBoxs;
	var array<KCollisionCylinder>	CollisionCylinders;
	var array<KCollisionHull>		CollisionHulls;
};

// this is also used for Havok HHandleImpact
struct KContactParams
{
	var float	Friction;
	var float	Restitution;
	var float	Softness;		// unused by Havok
	var float	Adhesion;		// unused by Havok
	var byte	bAcceptContact;
};

// endif

var class<LocalMessage> MessageClass;

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};


// double click move direction.
enum EDoubleClickDir
{
	DCLICK_None,
	DCLICK_Left,
	DCLICK_Right,
	DCLICK_Forward,
	DCLICK_Back,
	DCLICK_Active,
	DCLICK_Done
};

enum eKillZType
{
	KILLZ_None,
	KILLZ_Lava,
	KILLZ_Suicide
};

var(Display) float       OverlayTimer;          // sjs - set by server
var(Display) transient float       ClientOverlayTimer;    // sjs - client inital time count
var(Display) transient float       ClientOverlayCounter;  // sjs - current secs left to show overlay effect

// XJ Additional Overlay stuff stolen from DE
var(Display)	Material			RevertOverlayMaterial;	// XJ - when we want to go back to an old overlay
var(Display)	bool				bRevertOverlay;			// XJ - are we going to revert?
var(Display)	bool				bUseOverlayTimer;		// XJ - use a timer??

// XJ: Style stuff
var	array<Modifier>			StyleModifier;		// XJ: array of the modifier

// rj ---
var bool							bHasPostFXSkins;	// if true
														// - this actor has special skins that should be used if this
														//   actor is rendered during the post processing stage
														// - this actor will be rendered during normal actor rendering 
														// - the GetPostFXSkins() should return the skins to use during
														//	 post processing stage

// Xbox hack flags to allow SW skinning on selected actors 
//
var const bool						bNeedSWSkinning;	// this actor's mesh will need SW skinning on the xbox
var bool							bForceSWSkinning;	// hack flag to force SW skinning on the xbox for this actor
// --- rj

// cmr --- bools for forcing the replication through, regardless of other stuff
var bool bForceBaseRep;
var bool bForcePhysicsRep;
// --- cmr

// cmr ---
// TODO: REMOVE THESE BEFORE SHIP.  THEY ARE HANDY FOR DEBUGGING AND USED FOR NOTHING ELSE.
var bool bDebugFlag;
var bool bDebugFlag2;
// --- cmr

// mh ---
//Multi-Timer
struct native export timerStruct
{
    var int     slotID;
    var float   TimerRate;
    var float   TimerCounter;
    var byte    bLooping;
};

var	array<timerStruct>   MultiTimers;	
// --- mh


var bool bUsable;
//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Location
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement
					&& Physics != PHYS_RidingBase
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Location;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& Physics != PHYS_RidingBase
					&& ((DrawType == DT_Mesh) || (DrawType == DT_StaticMesh))
					&& (((RemoteRole == ROLE_AutonomousProxy) && bNetInitial)
						|| ((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition) && ((Base == None) || Base.bWorldGeometry))
						|| ((RemoteRole == ROLE_DumbProxy) && ((Base == None) || Base.bWorldGeometry))) )
		Rotation;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& ( RemoteRole<=ROLE_SimulatedProxy || (RemoteRole==ROLE_AutonomousProxy && bForceBaseRep) ) )
		Base,bOnlyDrawIfAttached;

	
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
  				&& ( (RemoteRole<=ROLE_SimulatedProxy || (RemoteRole==ROLE_AutonomousProxy && bForceBaseRep )) && (Base != None) && !Base.bWorldGeometry))
  		RelativeRotation, RelativeLocation, AttachmentBone;
  

	// Physics
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (((RemoteRole == ROLE_SimulatedProxy) && (bNetInitial || bUpdateSimulatedPosition))
						|| ((RemoteRole == ROLE_DumbProxy) && (Physics == PHYS_Falling))) )
		Velocity;

	unreliable if(( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (((RemoteRole == ROLE_SimulatedProxy) && bNetInitial) || (RemoteRole == ROLE_DumbProxy))) || bForcePhysicsRep )
		Physics;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && bReplicateMovement 
					&& (RemoteRole <= ROLE_SimulatedProxy) && (Physics == PHYS_Rotating) )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Ambient sound.
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) )
		AmbientSound;

	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && (!bNetOwner || !bClientAnim) 
					&& (AmbientSound!=None) )
		SoundRadius, SoundVolume, SoundPitch;

	// Animation. 
	unreliable if( (!bSkipActorPropertyReplication || bNetInitial) 
				&& (Role==ROLE_Authority) && (DrawType==DT_Mesh) && bReplicateAnimations )
		SimAnim;

	reliable if ( /*(!bSkipActorPropertyReplication || bNetInitial) &&*/ (Role==ROLE_Authority) )
		bHidden, bPaused;

	// Properties changed using accessor functions (Owner, rendering, and collision)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty )
		Owner, DrawScale, DrawType, bCollideActors,bCollideWorld,bOnlyOwnerSee,Texture,Style;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) && bNetDirty 
					&& (bCollideActors || bCollideWorld) )
		bProjTarget, bBlockActors, bBlockPlayers, CollisionRadius, CollisionHeight;

	// Properties changed only when spawning or in script (relationships, rendering, lighting)
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) )
		Role,RemoteRole,bNetOwner,LightType,bTearOff;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && bNetOwner )
		Inventory;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && bReplicateInstigator )
		Instigator;

    //amb ---
    unreliable if (bNetDirty && Role==ROLE_Authority)
		OverlayMaterial, OverlayTimer;
    // --- amb

	// Infrequently changed mesh properties
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (DrawType == DT_Mesh) )
		AmbientGlow,bUnlit,PrePivot;

	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && !bNoRepMesh && (DrawType == DT_Mesh) )
		Mesh;
		
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
				&& bNetDirty && (DrawType == DT_StaticMesh) )
		StaticMesh;

	// Infrequently changed lighting properties.
	unreliable if ( (!bSkipActorPropertyReplication || bNetInitial) && (Role==ROLE_Authority) 
					&& bNetDirty && (LightType != LT_None) )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase, bSpecialLit;

	// replicated functions
	unreliable if( bDemoRecording )
		DemoPlaySound;
}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

native final function PlayerController GetViewportPlayerController();

// Game profile fun
simulated native final function GameProfile GetCurrentGameProfile();

simulated function UpdateGameProfile()
{
    // StopWatch();
    if(!bool(ConsoleCommand("LOADSAVE UPDATE_GAME_PROFILE")))
    {
        warn("Cannot update game profile");
    }
    // StopWatch("UPDATE_GAME_PROFILE", true);
}

simulated function UpdatePlayerProfile()
{
    //StopWatch();
    if(!bool(ConsoleCommand("LOADSAVE UPDATE_PLAYER_PROFILE")))
    {
        warn("Cannot update player profile");
    }
    //StopWatch("UPDATE_PLAYER_PROFILE", true);
}


// Latent functions.
native(256) final latent function Sleep( float Seconds );
native(270) final latent function WaitForNotification( optional float TimeoutInSeconds );
native(271) final function Notify( );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight );
native final function SetDrawScale(float NewScale);
native final function SetDrawScale3D(vector NewScale3D);
native final function SetStaticMesh(StaticMesh NewStaticMesh);
native final function SetDrawType(EDrawType NewDrawType);

// Movement.
native(266) final function bool Move( vector Delta );
native(267) final function bool SetLocation( vector NewLocation );
native(299) final function bool SetRotation( rotator NewRotation );

native final function bool GetAttachPoint( Name AttachPoint, out vector AttachLocation, out Rotator AttachRotation );

// SetRelativeRotation() sets the rotation relative to the actor's base
native final function bool SetRelativeRotation( rotator NewRotation );
native final function bool SetRelativeLocation( vector NewLocation );

native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase, optional vector NewFloor );
native(272) final function SetOwner( actor NewOwner );

//=============================================================================
// Animation.

native final function string GetMeshName();

// Animation functions.
native(259) final function bool PlayAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(260) final function bool LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional int Channel );
native(294) final function bool TweenAnim( name Sequence, float Time, optional int Channel );
native(282) final function bool IsAnimating(optional int Channel);
native(261) final latent function FinishAnim(optional int Channel);
native(263) final function bool HasAnim( name Sequence );
native final function StopAnimating( optional bool ClearAllButBase );
native final function FreezeAnimAt( float Time, optional int Channel);
native final function SetAnimFrame( float Time, optional int Channel, optional int UnitFlag );

native final function bool IsTweening(int Channel);
native final function AnimStopLooping(optional int Channel); // jjs

// ifdef WITH_LIPSINC
native final function PlayLIPSincAnim(
	name                    LIPSincAnimName,
	optional float		Volume,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Not3D    //cmr -- for playing based on camera, not an actor in the world. 
    );

native final function StopLIPSincAnim();

native final function bool HasLIPSincAnim( name LIPSincAnimName );
native final function bool IsPlayingLIPSincAnim();
native final function string CurrentLIPSincAnim();

// LIPSinc Animation notifications.
event LIPSincAnimEnd();
// endif

// Animation notifications.
event AnimEnd( int Channel );
native final function EnableChannelNotify ( int Channel, int Switch );
native final function int GetNotifyChannel();

// Skeletal animation.
simulated native final function LinkSkelAnim( MeshAnimation Anim, optional mesh NewMesh );
simulated native final function LinkMesh( mesh NewMesh, optional bool bKeepAnim );

native final function AnimBlendParams( int Stage, optional float BlendAlpha, optional float InTime, optional float OutTime, optional name BoneName, optional bool bGlobalPose);
native final function AnimBlendToAlpha( int Stage, float TargetAlpha, float TimeInterval );

/*
  note: origin of the frame returned is in WORLD coords (ks)
*/
native final function coords  GetBoneCoords(   name BoneName );
native final function rotator GetBoneRotation( name BoneName, optional int Space );

native final function vector  GetRootLocation();
native final function rotator GetRootRotation();
native final function vector  GetRootLocationDelta();
native final function rotator GetRootRotationDelta();

native final function bool  AttachToBone( actor Attachment, name BoneName );
native final function bool  DetachFromBone( actor Attachment );

native final function LockRootMotion( int Lock );
native final function SetBoneScale( int Slot, optional float BoneScale, optional name BoneName );

/*
	SetBoneDirection
	
	params: Space
				0 BoneTurn is in LOCAL coordinates
				1 BoneTurn is in WORLD coordinates
	note: function desc added by xmatt because. Lazy ass-clingers that don't explain they functions
		  should be ass-sabotaged and throwned to the lions (xmatt)
*/
native final function SetBoneDirection( name BoneName, rotator BoneTurn, optional vector BoneTrans, optional float Alpha, optional int Space );
native final function SetBoneLocation( name BoneName, optional vector BoneTrans, optional float Alpha );
native final simulated function SetBoneRotation( name BoneName, optional rotator BoneTurn, optional int Space, optional float Alpha );
native final function GetAnimParams( int Channel, out name OutSeqName, out float OutAnimFrame, out float OutAnimRate );
native final function bool AnimIsInGroup( int Channel, name GroupName );  
native final function Name GetClosestBone( Vector loc, Vector ray, out float boneDist, optional Name BiasBone, optional float BiasDistance ); // sjs
// gam ---
native final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native final function string GetUrlOption(string Option);
// --- gam

//=========================================================================
// Rendering.

native final function plane GetRenderBoundingSphere();
native final function DrawDebugLine( vector LineStart, vector LineEnd, byte R, byte G, byte B); // SLOW! Use for debugging only!
native final function DrawDebugArrow( vector LineStart, vector LineEnd, byte R, byte G, byte B); //xmatt
native final function DrawDebugCircle( vector Location, float radius, optional vector X, optional vector Y, optional byte R, optional byte G, optional byte B );
native final function PIXMarker(string name);

// use this function to change an actor's skin
//
native final function SetSkin( int s, Material m ); 

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

native final function OnlyAffectPawns(bool B);

// ifdef WITH_KARMA



native final function KSetBlockKarma( bool newBlock );

// #ifdef WITH_HAVOK
native final function HSetMass( float mass );
native final function HSetCOM( vector COM );
native final function HSetFriction( float friction );
native final function HSetRestitution( float rest );
native final function HSetDampingProps( float lindamp, float angdamp );
native final function HWake();
native final function bool HIsAwake();
native final function HFreeze();
native final function HAddImpulse( vector Impulse, vector Position, optional name BoneName );
native final function HSetRBVel( vector Velocity, optional vector AngVelocity, optional bool AddToCurrent );
native final function HSetSkelVel( vector Velocity, optional vector AngVelocity, optional bool AddToCurrent );
native final function name HGetLastTracedBone();
native final function HGetRigidBodyState(out KRigidBodyState RBstate);
native final function bool HIsRagdollAvailable();
native final function HMakeRagdollAvailable();

// This is called from inside C++ at the appropriate time to update state of Havok rigid body.
// If you return true, newState will be set into the rigid body. Return false and it will do nothing.
event bool HUpdateState(out KRigidBodyState newState);

// event called when Havok actor hits with impact velocity over it's HParam's ImpactThreshold
event HImpact(actor Other, vector pos, vector impactVel, vector impactNorm, Material HitMaterial); 

// event called just before sim to allow user to apply force and torque to actor
// NOTE: you should ONLY put numbers into Force and Torque during this event!!!!
event bool HApplyForce(out vector Force, out vector Torque);

// event called when PHYS_Havok actor makes a contact
// - return true if contact was handled and results are in contact parameters
//
event bool HHandleContact(actor Other, vector pos, vector impactVel, vector impactNorm, out KContactParams params );

// tell actor to update any havok skeleton based on actor's HParams
//
native function HUpdateSkeleton();

// endif

event PreSaveGame();
event PostSaveGame();
event PostLoadGame();

// Useful function for plotting data to real-time graph on screen.
native final function GraphData(string DataName, float DataValue, optional float MinValue, optional int SmoothLevel );
native final function RemoveGraphData(string DataName);

// Timing
native final function Clock(out float time);
native final function UnClock(out float time);

//=========================================================================
// Music

native final function int PlayMusic( string Song, float FadeInTime );
native final function StopMusic( int SongHandle, float FadeOutTime );
native final function StopAllMusic( float FadeOutTime );

//=========================================================================
// Editor Hook

//An object has a chance to return a string that will be used in addition 
// to it's Group field for editor Group-management
event String SuggestedGroup();

//=========================================================================
// Engine notification functions.

//
// Major notifications.
//

event PreLoadData(); // IF YOU USE THIS YOU MUST SET bNeedPreLoad=true IN YOUR DEFAULTPROPERTIES!!!

static simulated function StaticPreLoadData()
{
    local int i;

    for( i = 0; i < default.Skins.Length; i++ )
        PreLoad(default.Skins[i]);

    PreLoad(default.Mesh);
    PreLoad(default.UV2Texture);
}


event PreNetDestroy(); //CMR -- currently only called for the controller and pawn, for some cleanup further down the chain with vehicles.
// gam ---
event Destroyed()
{
    assert( !bDestroyPropagatedFully );
    bDestroyPropagatedFully = true;
}
// --- gam

event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );
simulated event PostNetReceive(); // jij

// called at same point as PostNetReceive but not subject to that damn probe crap - rj@bb
// - bReplicateNotify needs to be on for this to get triggered
// - only triggered when Role != ROLE_Authority
simulated event PostNetReplicate();

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
// when bHasHandlers is true, this method handles events instead of Trigger()
event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) {
    // idiom is to call super.TriggerEx(...) if you don't recognize the 
    // handler.  If it gets all the way up to Actor, then the event isn't
    // going to get handled at all
    Warn( "Unrecognized event for handler [" $ handler $ "] received by [" 
             $ self $ "], (from [" $ sender $ "], instigated by [" 
             $ instigator $ "]" );
}
// old skool triggers
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
/**
 * Helper functions, use MarkTime()/TimeElapsed() to clean up silly Level.TimeSeconds-1.0 code
 **/
function MarkTime(out float time) { time = Level.TimeSeconds; }
function bool TimeElapsed(float markedTime, float timeDuration)
{
	return (Level.TimeSeconds - markedTime) >= timeDuration;
}

event Timer();
event MultiTimer(int slotID);
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event PhysicsVolumeChange( PhysicsVolume NewVolume );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event FinishedInterpolation()
{
	bInterpolating = false;
}
event SceneManagerEvent( name theevent, name SecondaryEvent )
{

}

event EndedRotation();			// called when rotation completes
function UsedBy( Pawn user ); // called if this Actor was touching a Pawn who pressed Use

event FellOutOfWorld(eKillZType KillType)
{
	SetPhysics(PHYS_None);
	Destroy();
}	

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage);

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
// EDIT (mthorne): allow trace to ignore skyboxes (so weapons don't appear to hit thin air)
//                 the default is to include skyboxes in the trace (Dec 19/2003)
//
native(277) final function Actor Trace
(
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart,
	optional bool   bTraceActors,
	optional vector Extent,
	optional out material Material,
	optional bool   bWeaponFire,
	optional bool   bDoPointChecks // HACK
);

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector          TraceEnd,
	optional vector TraceStart
);

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation,
	optional Actor    Template
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

// Same as Trace except it only traces for volumes
//
native function Actor VolumeTrace( 
	out vector      HitLocation,
	out vector      HitNormal,
	vector          TraceEnd,
	optional vector TraceStart
);

// Networking - called on client when actor is torn off (bTearOff==true)
event TornOff();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
native(280) final function SetTimer( float NewTimerRate, bool bLoop );
native(285) final function SetMultiTimer( int slotID, float NewTimerRate, bool bLoop );


//=============================================================================
// Sound functions.

/* Play a sound effect.
*/
native(264) final function PlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate,
    optional bool		SuppressInstigator
);

/* play a sound effect, but don't propagate to a remote owner
 (he is playing the sound clientside)
 */
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

/* StopOwnedSound

	Desc: Stop a sound effect
 */
native simulated final function StopOwnedSound
(
	sound				Sound
);

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch,
	optional bool		Attenuate
);

/* Get a sound duration.
*/
native final function float GetSoundDuration( sound Sound );

native final function SetVoiceBias(bool bSet, float Scale);

//=============================================================================
// Force Feedback.
// jdf ---
native(566) final function PlayFeedbackEffect( String EffectName );
native(567) final function StopFeedbackEffect( optional String EffectName ); // Pass no parameter or "" to stop all
native(568) final function bool ForceFeedbackSupported();
// --- jdf

//=============================================================================
// AI functions.

/* Inform other creatures that you've made a noise
 they might hear (they are sent a HearNoise message)
 Senders of MakeNoise should have an instigator if they are not pawns.
*/
native(512) final function MakeNoise( float Loudness, optional float maxdist );

/* PlayerCanSeeMe returns true if any player (server) or the local player (standalone
or client) has a line of sight to actor's location.
*/
native(532) final function bool PlayerCanSeeMe();

native final function vector SuggestFallVelocity(vector Destination, vector Start, float MaxZ, float MaxXYSpeed);
 
//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string ExpandRelativeURL(string URL); // gam
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
native final function bool GetCacheEntry( int Num, out string GUID, out string Filename );
native final function bool MoveCacheEntry( string GUID, optional string NewFilename );  

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

/* AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow
*/
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* DynamicActors() only iterates through the non-static actors on the list (still relatively slow, bu
 much better than AllActors).  This should be used in most cases and replaces AllActors in most of 
 Epic's game code. 
*/
native(313) final iterator function DynamicActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag );

/* ChildActors() returns all actors owned by this actor.  Slow like AllActors()
*/
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );

/* BasedActors() returns all actors based on the current actor (slow, like AllActors)
*/
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );

/* TouchingActors() returns all actors touching the current actor (fast)
*/
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );

/* TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
*/
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent );

/* RadiusActors() returns all actors within a give radius.  Slow like AllActors().  Use CollidingActors() or VisibleCollidingActors() instead if desired actor types are visible
(not bHidden) and in the collision hash (bCollideActors is true)
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* VisibleActors() returns all visible actors within a radius.  Slow like AllActors().  Use VisibleCollidingActors() instead if desired actor types are 
in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );

/* VisibleCollidingActors() returns visible (not bHidden) colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() since it uses the collision hash
*/
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bIgnoreHidden );

/* CollidingActors() returns colliding (bCollideActors==true) actors within a certain radius.
Much faster than AllActors() for reasonably small radii since it uses the collision hash
*/
native(321) final iterator function CollidingActors ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

/* DynamicRadiusActors() returns all Dynamic actors within a given radius. As slow as DynamicActors().
*/
native		final iterator function DynamicRadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc );

//=============================================================================
// Color functions
native(549) static final operator(20) color -     ( color A, color B );
native(550) static final operator(16) color *     ( float A, color B );
native(551) static final operator(20) color +     ( color A, color B );
native(552) static final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

/* RenderOverlays()
called by player's hud to request drawing of actor specific overlays onto canvas
*/
function RenderOverlays(Canvas Canvas);
	
// RenderTexture
event RenderTexture(ScriptedTexture Tex);

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.BaseMutator.CheckRelevance(Self) )
		Destroy();
}

//
// Broadcast a localized message to all players.
// Most message deal with 0 to 2 related PRIs.
// The LocalMessage class defines how the PRI's and optional actor are used.
//
event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Level.Game.BroadcastLocalized( self, MessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Called immediately after gameplay begins.
//
event PostBeginPlay();

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	bScriptInitialized = true;
	if( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

event PostLinearize(); // sjs -- after lin

// called after PostBeginPlay.  On a net client, PostNetBeginPlay() is spawned after replicated variables have been initialized to
// their replicated values
event PostNetBeginPlay();

function UpdatePrecacheMaterials();

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated final function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Controller ProjOwner )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
    local vector DamageLoc; // sjs
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Victims.Role == ROLE_Authority) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			
			if((FMax(0.0, dist - Victims.CollisionRadius)) < (DamageRadius/2.0))
			{
				damageScale = 1;
			}
			else
			{
				damageScale = 1 - FMax(0.0,( FMax(0.0, dist - Victims.CollisionRadius) - DamageRadius/2.0) /(DamageRadius/2.0));
			}

            if( Victims.DrawType!=DT_FluidSurface ) // sjs - for proper fluid plings
                DamageLoc = Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir;
            else
                DamageLoc = HitLocation;
			
			if(Victims.IsA('Pawn') && Pawn(Victims).Controller != None)
			{
				Pawn(Victims).Controller.DamageShake(100);
			}

			/*
			ScriptLog: WTF:  Scale=-0.030356 dist=227.678238 damageradius=220.000000 collisionradius=1.000000
			ScriptLog: WTF:  Scale=-0.122869 dist=347.031219 damageradius=220.000000 collisionradius=100.000000

			
			if(damageScale < 0)
			{
				log("WTF:  Scale="$damagescale$" dist="$dist$" damageradius="$damageradius$" collisionradius="$Victims.CollisionRadius);
			}
			*/
			//temporary fix for the above issue
			if(damagescale > 0)
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					DamageLoc,
					(damageScale * Momentum * dir),
					DamageType,
					ProjOwner,
					true
				);
		} 
	}
	bHurtEntry = false;
}

// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

// Called by PlayerController when this actor becomes its ViewTarget.
//
function BecomeViewTarget();

// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

// Returns the human readable string representation of an object.
//
simulated function String RetrivePlayerName()
{
	return GetItemName(string(class));
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, Material NewTexture, bool bLighting )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
}

// Get localized message string associated with this actor
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "";
}

function MatchStarting(); // called when gameplay actually starts

function String GetDebugName()
{
	return GetItemName(string(self));
}

/* DisplayDebug()
list important actor variable on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
the ShowDebug exec is used
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;
	local int i;
	local Actor A;
	local name anim;
	local float frame,rate;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,0,0);
	T = GetDebugName();
	if ( bDeleteMe == 1)
		T = T$" DELETED (bDeleteMe == 1)";

	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,255);

	if ( Level.NetMode != NM_Standalone )
	{
		// networking attributes
		T = "ROLE ";
		Switch(Role)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		T = T$" REMOTE ROLE ";
		Switch(RemoteRole)
		{
			case ROLE_None: T=T$"None"; break;
			case ROLE_DumbProxy: T=T$"DumbProxy"; break;
			case ROLE_SimulatedProxy: T=T$"SimulatedProxy"; break;
			case ROLE_AutonomousProxy: T=T$"AutonomousProxy"; break;
			case ROLE_Authority: T=T$"Authority"; break;
		}
		if ( bTearOff )
			T = T$" Tear Off";
		Canvas.DrawText(T);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	T = "Physics ";
	Switch(PHYSICS)
	{
		case PHYS_None: T=T$"None"; break;
		case PHYS_Walking: T=T$"Walking"; break;
		case PHYS_Falling: T=T$"Falling"; break;
		case PHYS_Swimming: T=T$"Swimming"; break;
		case PHYS_Flying: T=T$"Flying"; break;
		case PHYS_Rotating: T=T$"Rotating"; break;
		case PHYS_Projectile: T=T$"Projectile"; break;
		case PHYS_Interpolating: T=T$"Interpolating"; break;
		case PHYS_MovingBrush: T=T$"MovingBrush"; break;
		case PHYS_Spider: T=T$"Spider"; break;
		case PHYS_Trailer: T=T$"Trailer"; break;
		case PHYS_Ladder: T=T$"Ladder"; break;
	}
	T = T$" in physicsvolume "$GetItemName(string(PhysicsVolume))$" on base "$GetItemName(string(Base));
	if ( bBounce )
		T = T$" - will bounce";
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Location: "$Location$" Rotation "$Rotation);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Velocity: "$Velocity$" Speed "$VSize(Velocity));
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Acceleration: "$Acceleration);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 0;
	Canvas.DrawText("Collision Radius "$CollisionRadius$" Height "$CollisionHeight);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Collides with Actors "$bCollideActors$", world "$bCollideWorld$", proj. target "$bProjTarget);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Blocks Actors "$bBlockActors$", players "$bBlockPlayers);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Touching ";
	ForEach TouchingActors(class'Actor', A)
		T = T$GetItemName(string(A))$" ";
	if ( T == "Touching ")
		T = "Touching nothing";
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawColor.R = 0;
	T = "Rendered: ";
	Switch(Style)
	{
		case STY_None: T=T; break;
		case STY_Normal: T=T$"Normal"; break;
		case STY_Masked: T=T$"Masked"; break;
		case STY_Translucent: T=T$"Translucent"; break;
		case STY_Modulated: T=T$"Modulated"; break;
		case STY_Alpha: T=T$"Alpha"; break;
	}		

	Switch(DrawType)
	{
		case DT_None: T=T$" None"; break;
		case DT_Sprite: T=T$" Sprite "; break;
		case DT_Mesh: T=T$" Mesh "; break;
		case DT_Brush: T=T$" Brush "; break;
		case DT_RopeSprite: T=T$" RopeSprite "; break;
		case DT_VerticalSprite: T=T$" VerticalSprite "; break;
		case DT_Terraform: T=T$" Terraform "; break;
		case DT_SpriteAnimOnce: T=T$" SpriteAnimOnce "; break;
		case DT_StaticMesh: T=T$" StaticMesh "; break;
	}

	if ( DrawType == DT_Mesh )
	{
		T = T$GetItemName(string(Mesh));
		if ( Skins.length > 0 )
		{
			T = T$" skins: ";
			for ( i=0; i<Skins.length; i++ )
			{
				if ( skins[i] == None )
					break;
				else
					T =T$GetItemName(string(skins[i]))$", ";
			}
		}

		Canvas.DrawText(T);
		YPos += YL;
		Canvas.SetPos(4,YPos);
		
		// mesh animation
		GetAnimParams(0,Anim,frame,rate);
        T = "AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		if ( bAnimByOwner )
			T= T$" Anim by Owner";
        GetAnimParams(1,Anim,frame,rate);
		T = T$"AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
		
	}
	else if ( (DrawType == DT_Sprite) || (DrawType == DT_SpriteAnimOnce) )
		T = T$Texture;
	else if ( DrawType == DT_Brush )
		T = T$Brush;
		
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	
	Canvas.DrawColor.B = 255;	
	Canvas.DrawText("Tag: "$Tag$" Event: "$Event$" STATE: "$GetStateName());
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Instigator "$GetItemName(string(Instigator))$" Owner "$GetItemName(string(Owner)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	Canvas.DrawText("Timer: "$TimerCounter$" LifeSpan "$LifeSpan$" AmbientSound "$AmbientSound);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

// NearSpot() returns true is spot is within collision cylinder
simulated final function bool NearSpot(vector Spot)
{
	local vector Dir;

	Dir = Location - Spot;
	
	if ( abs(Dir.Z) > CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius );
}

simulated final function bool TouchingActor(Actor A)
{
	local vector Dir;

	Dir = Location - A.Location;
	
	if ( abs(Dir.Z) > CollisionHeight + A.CollisionHeight )
		return false;

	Dir.Z = 0;
	return ( VSize(Dir) <= CollisionRadius + A.CollisionRadius );
}

simulated function PrepareForMatinee();
simulated function RecoverFromMatinee();

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/	
simulated function StartInterpolation()
{
	GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset();

// add an event binding to the end of the list
simulated function AppendEventBinding(Name eventName, Name handler)
{
    local int len;
    len = EventBindings.Length;
    EventBindings.Length = len + 1;
    EventBindings[len].EventName = eventName;
    EventBindings[len].HandledBy = handler;
}

/* 
Trigger an event
*/
event TriggerEvent( Name eventName, Actor sender, Pawn instigator )
{
    //@@@ this method should be made native for efficiency purposes
    local Actor a;
    local int i, numHandlers;
    local Name handler;
    local bool matched;

	//@@@ FOR SOME REASON THIS PREVENTS A CRASH
	a=a;

	if ( eventName == '' ) return;

	//log( "RJ: TriggerEvent("$eventName$","$sender$","$instigator$") called" );

    ForEach DynamicActors( class 'Actor', a ) {
        // check for extended handlers first...
        numHandlers = a.eventBindings.length;
        matched     = false;
        handler     = '';
        for ( i = 0; i < numHandlers; ++i ) {
            if ( a.eventBindings[i].eventName == eventName ) {
                matched = true;
                handler = a.eventBindings[i].handledBy;
                break;
            }
        }
        // fall back to checking the tag...
        if ( !matched ) {
            if ( a.Tag == eventName ) {
                handler = eventName;
                matched = true;
            }
        }
        // dispatch the event to matching actors...
        if ( matched ) {
            if ( a.bHasHandlers ) {
                a.TriggerEx( sender, instigator, handler, eventName );
            }
            else {
		        a.Trigger( sender, instigator );
            }
        }
    } // end ForEach
}

/*
Untrigger an event
*/
function UntriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
	local Actor A;

	if ( EventName == '' )
		return;

	ForEach DynamicActors( class 'Actor', A, EventName )
		A.Untrigger(Other, EventInstigator);
}

function bool IsInVolume(Volume aVolume)
{
	local Volume V;
	
	ForEach TouchingActors(class'Volume',V)
		if ( V == aVolume )
			return true;
	return false;
}
	 
function bool IsInPain()
{
	local PhysicsVolume V;

	ForEach TouchingActors(class'PhysicsVolume',V)
		if ( V.bPainCausing && (V.DamagePerSec > 0) )
			return true;
	return false;
}

function PlayTeleportEffect(bool bOut, bool bSound);

function bool CanSplash()
{
	return false;
}

function vector GetCollisionExtent()
{
	local vector Extent;

	Extent = CollisionRadius * vect(1,1,0);
	Extent.Z = CollisionHeight;
	return Extent;
}

// amb ---
simulated function PRIArrayUpdated();
// --- amb

simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated )
{
	local PlayerController P;
	local bool bResult;
	
	if ( Level.NetMode == NM_DedicatedServer )
		bResult = bForceDedicated;
	else if ( Level.NetMode == NM_Client )
		bResult = true;
	else if ( (Instigator != None) && Instigator.IsHumanControlled() )
		bResult =  true;
	else if ( SpawnLocation == Location )
		bResult = ( Level.TimeSeconds - LastRenderTime < 3 );
	else if ( (Instigator != None) && (Level.TimeSeconds - Instigator.LastRenderTime < 3) )
		bResult = true;
	else
	{	
		P = Level.GetLocalPlayerController();
		if ( P == None )
			bResult = false;
		else 
			bResult = ( (Vector(P.Rotation) Dot (SpawnLocation - P.ViewTarget.Location)) > 0.0 );
	}
	return bResult;
}

function PlayerController FindPlayer(bool bNeedsPawn)
{
    local Controller c;
    local PlayerController pc;
    for ( c=Level.ControllerList; c!=None; c=c.NextController )
    {
        pc = PlayerController(c);
        if (pc != None && (!bNeedsPawn || pc.Pawn != None))
            return pc;
    }
    return None;
}

// XJ: Style copying materials to skins
native final function CopyMaterialsToSkins();

simulated function CreateStyle(class<Modifier> modifier) //starting with just fading
{
	local int i;

	if(Skins.Length == 0)
	{
		CopyMaterialsToSkins();
    }
	for(i = 0;i < Skins.Length;i++)
	{
		if (Skins[i] == none)
			break;
		StyleModifier[i] = new modifier;
		StyleModifier[i].Material = Skins[i];
		SetSkin(i,StyleModifier[i]);
	}
}

native function RemoveStyle();

function AdjustAlphaFade(byte Amount)
{
	local int i;

	for(i = 0;i < StyleModifier.Length;i++)
	{
		ColorModifier(StyleModifier[i]).Color.A = Amount;
	}
}

//XJ: Overlay
// sjs ---
simulated function SetOverlayMaterial(Material mat,optional bool bTimed,optional float time,optional bool bOverride,optional bool bRevert)
{
    if (OverlayMaterial == None || OverlayMaterial == mat || bOverride)
    {
		if(bRevert && RevertOverlayMaterial == none) //don't override the revert material!!
			RevertOverlayMaterial = OverlayMaterial;
		bRevertOverlay = bRevert;
        OverlayMaterial = mat;
		bUseOverlayTimer = bTimed;
        OverlayTimer = time;
    }
}
// --- sjs
// XJ: This will totally remove all overlays, it will not revert any.
simulated function RemoveOverlayMaterial()
{
	OverlayMaterial = none;
	RevertOverlayMaterial = none;
	bRevertOverlay = false;
	bUseOverlayTimer = false;
	OverlayTimer = 0;
}

// rj@bb ---

// this one will always log but it doesn't trigger the log group
// - if bCreate is true, it will create the log group if it doesn't exist yet
//
native simulated function bool GLog( string Group, string Msg, optional bool bCreate );

// this one will log if a certain amount of time has passed since the last time
// this log group was active
//
native simulated function bool ILog( string Group, string Msg, optional float Delta, optional bool bCreate );

// this one will always log and it will trigger this log group
//
native simulated function bool TLog( string Group, string Msg, optional bool bCreate );

// this one will log if the log group is active...it needs to have been triggered
// by ILog or TLog
//
native simulated function bool FLog( string Group, string Msg, optional bool bTrigger );

exec function TglLogGroup( string GroupName )
{
	if ( Level.LogGroupNameToIndex( GroupName ) >= 0 )
	{
		Level.RemoveLogGroup( GroupName );
	}
	else
	{
		Level.AddLogGroup( GroupName );
	}
}

// const some possible log group names associated with BB developers
const RJ = "RJ";
const RJ1 = "RJ1";
const RJ2 = "RJ2";
const RJ3 = "RJ3";
const MH = "MIKE";
const CMR = "CHARLES";
const XJ = "XJ";

// const some possible log group names associated with functionality
const SG = "SG";			// save game
const VN = "VN";			// vehicle networking
const VN1 = "VN1";			// vehicle networking - 1

// --- rj@bb

// rj@bb ---
simulated function AddLightTag( name Tag )
{
	LightTags.Length = LightTags.Length + 1;
	LightTags[LightTags.Length - 1] = Tag;
}
// --- rj@bb

simulated function bool	IsPaused()
{
	return PauseTime > Level.TimeSeconds;
}

native function bool UsingHighDetailShadows();

// if bHasPostFXSkins is true, this event should be defined to return the
// skins to use during post processing
//
event GetPostFXSkins( out array<Material> PostFXSkins );

defaultproperties
{
     LODBias=1.000000
     DrawScale=1.000000
     ScaleGlow=1.000000
     SoundRadius=512.000000
     TransientSoundVolume=0.600000
     TransientSoundRadius=512.000000
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     KarmaEncroachSpeed=1000.000000
     CoronaFadeMultiplier=3.000000
     Mass=100.000000
     ForceNoise=0.500000
     NetPriority=1.000000
     NetUpdateFrequency=100.000000
     Texture=Texture'Engine.S_Actor'
     MessageClass=Class'Engine.LocalMessage'
     DrawScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     CoronaBrightness=255
     DrawType=DT_Sprite
     RemoteRole=ROLE_DumbProxy
     Role=ROLE_Authority
     MaxLights=4
     Style=STY_Normal
     SoundVolume=128
     SoundPitch=64
     bLightingVisibility=True
     bAcceptsProjectors=True
     bReplicateMovement=True
     bMovable=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
     bJustTeleported=True
}
