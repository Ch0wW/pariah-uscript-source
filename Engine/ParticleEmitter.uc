//=============================================================================
// ParticleEmitter: Base class for sub- emitters.
//
// make sure to keep structs in sync in UnParticleSystem.h
//=============================================================================

class ParticleEmitter extends Object
	abstract
	editinlinenew
	native;

enum EBlendMode
{
	BM_MODULATE,
	BM_MODULATE2X,
	BM_MODULATE4X,
	BM_ADD,
	BM_ADDSIGNED,
	BM_ADDSIGNED2X,
	BM_SUBTRACT,
	BM_ADDSMOOTH,
	BM_BLENDDIFFUSEALPHA,
	BM_BLENDTEXTUREALPHA,
	BM_BLENDFACTORALPHA,
	BM_BLENDTEXTUREALPHAPM,
	BM_BLENDCURRENTALPHA,
	BM_PREMODULATE,
	BM_MODULATEALPHA_ADDCOLOR,
	BM_MODULATEINVALPHA_ADDCOLOR,
	BM_MODULATEINVCOLOR_ADDALPHA,
	BM_HACK	
};

enum EParticleDrawStyle
{
	PTDS_Regular,
	PTDS_AlphaBlend,
	PTDS_Modulated,
	PTDS_Translucent,
	PTDS_AlphaModulate_MightNotFogCorrectly,
	PTDS_Darken,
	PTDS_Brighten
};

enum EParticleCoordinateSystem
{
	PTCS_Independent,
	PTCS_Relative,
	PTCS_Absolute,
	PTCS_RelativeStart // relative to starting location, doesn't move with base actor as happens with PTCS_Relative
};

enum EParticleRotationSource
{
	PTRS_None,
	PTRS_Actor,
	PTRS_Offset,
	PTRS_Normal
};

enum EParticleVelocityDirection
{
	PTVD_None,
	PTVD_StartPositionAndOwner,
	PTVD_OwnerAndStartPosition,
	PTVD_AddRadial,
	PTVD_GetFromOwnersBase
};

enum EParticleStartLocationShape
{
	PTLS_Box,
	PTLS_Sphere,
	PTLS_Polar,
	PTLS_All
};

enum EParticleEffectAxis
{
	PTEA_NegativeX,
	PTEA_PositiveZ
};

enum EParticleCollisionSound
{
	PTSC_None,
	PTSC_LinearGlobal,
	PTSC_LinearLocal,
	PTSC_Random
};

struct ParticleTimeScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () float	RelativeSize;
};

struct ParticleColorScale
{
	var () float	RelativeTime;		// always in range [0..1]
	var () color	Color;
};


struct Particle
{
	var vector	Location;
	var vector	OldLocation;
	var vector	Velocity;
	var vector	StartSize;
	var vector	SpinsPerSecond;
	var vector	StartSpin;
	var vector  RevolutionCenter;
	var vector  RevolutionsPerSecond;
	var vector	Size;
	var vector  StartLocation;
	var color	StartColor;
	var vector  ColorMultiplier;
	var color	Color;
	var float	Time;
	var float	MaxLifetime;
	var float	Mass;
	var int		HitCount;
	var int		Flags;
	var int		Subdivision;
};

struct ParticleSound
{
	var () sound	Sound;
	var () range	Radius;
	var () range	Pitch;
	var () int		Weight;
	var () range	Volume;
	var () range	Probability;
};

var (Acceleration)	vector						Acceleration;

var (Collision)		bool						UseCollision;
var (Collision)		vector						ExtentMultiplier;
var (Collision)		rangevector					DampingFactorRange;
var (Collision)		bool						UseCollisionPlanes;
var (Collision)		array<plane>				CollisionPlanes;
var	(Collision)		bool						UseMaxCollisions;
var (Collision)		range						MaxCollisions;
var (Collision)		int							SpawnFromOtherEmitter;
var (Collision)		int							SpawnAmount;
var (Collision)		rangevector					SpawnedVelocityScaleRange;
var (Collision)		bool						UseSpawnedVelocityScale;
var (Collision)		EParticleCollisionSound		CollisionSound;
var (Collision)		range						CollisionSoundIndex;
var (Collision)		range						CollisionSoundProbability;

var (Sound)			ParticleSound				ResetSound; //sound when the emitter is reset
var (Sound)			array<ParticleSound>		Sounds;

var (Color)			bool						UseColorScale;
var (Color)			array<ParticleColorScale>	ColorScale;
var (Color)			float						ColorScaleRepeats;
var (Color)			rangevector					ColorMultiplierRange;
var (Color)			rangevector					StartColorRange;	// R=X,G=Y,B=Z
var (Color)			range						StartAlphaRange;

var (Fading)		plane						FadeOutFactor;
var (Fading)		float						FadeOutStartTime;
var (Fading)		bool						FadeOut;
var (Fading)		plane						FadeInFactor;
var (Fading)		float						FadeInEndTime;
var (Fading)		bool						FadeIn;

var (Force)			bool						UseActorForces;

var (General)		EParticleCoordinateSystem	CoordinateSystem;
var (General)		const int					MaxParticles;
var (General)		bool						ResetAfterChange;
var (General)		EParticleEffectAxis			EffectAxis;
var (General)		Emitter.EEmitterDropDetail	RenderThrottle;


var (Local)			bool						RespawnDeadParticles;
var (Local)			bool						AutoDestroy;
var (Local)			bool						AutoReset;
var (Local)			bool						Disabled;
var (Local)			bool						DisableFogging;
var (Local)			range						AutoResetTimeRange;

var (Location)		vector						StartLocationOffset;
var (Location)		rangevector					StartLocationRange;
var (Location)		int							AddLocationFromOtherEmitter;
var (Location)		EParticleStartLocationShape StartLocationShape;
var (Location)		range						SphereRadiusRange;
var (Location)		rangevector					StartLocationPolarRange;
var (Location)		float						StartLocationScaleUpTime;
var (Location)		float						StartLocationScaleDownTime;

var (Mass)			range						StartMassRange;

var (Rendering)		int							AlphaRef;
var (Rendering)		bool						AlphaTest;
var (Rendering)		bool						AcceptsProjectors;
var (Rendering)		bool						ZTest;
var (Rendering)		bool						ZWrite;

var (Rotation)		EParticleRotationSource		UseRotationFrom;
var (Rotation)		bool						SpinParticles;
var (Rotation)		rotator						RotationOffset;
var (Rotation)		vector						SpinCCWorCW;
var (Rotation)		rangevector					SpinsPerSecondRange;
var (Rotation)		rangevector					StartSpinRange;
var (Rotation)		bool						DampRotation;
var (Rotation)		rangevector					RotationDampingFactorRange;
var (Rotation)		vector						RotationNormal;
var (Rotation)		bool						UseRevolution;
var (Rotation)		rangevector					RevolutionCenterOffsetRange;
var (Rotation)		rangevector					RevolutionsPerSecondRange;

var (Size)			bool						UseSizeScale;
var (Size)			bool						UseRegularSizeScale;
var (Size)			array<ParticleTimeScale>	SizeScale;
var (Size)			float						SizeScaleRepeats;
var (Size)			rangevector					StartSizeRange;
var (Size)			bool						UniformSize;

var (Spawning)		float						ParticlesPerSecond;
var (Spawning)		float						InitialParticlesPerSecond;
var (Spawning)		bool						AutomaticInitialSpawning;
var (Spawning)		EParticleCollisionSound		SpawningSound;
var (Spawning)		range						SpawningSoundIndex;
var (Spawning)		range						SpawningSoundProbability;
var (Spawning)		Emitter.EEmitterDropDetail	SpawnThrottle;

var (Texture)		EParticleDrawStyle			DrawStyle;
var (Texture)		texture						Texture;
var (Texture)		int							TextureUSubdivisions;
var (Texture)		int							TextureVSubdivisions;
var (Texture)		bool						BlendBetweenSubdivisions;
var	(Texture)		bool						UseSubdivisionScale;
var (Texture)		array<float>				SubdivisionScale;
var (Texture)		int							SubdivisionStart;
var (Texture)		int							SubdivisionEnd;
var (Texture)		bool						UseRandomSubdivision;

var (Tick)			float						SecondsBeforeInactive;
var (Tick)			float						MinSquaredVelocity;

var	(Time)			range						InitialTimeRange;
var (Time)			range						LifetimeRange;
var (Time)			range						InitialDelayRange;

var (Trigger)		bool						TriggerDisabled;
var (Trigger)		bool						ResetOnTrigger;

var (Velocity)		rangevector					StartVelocityRange;
var (Velocity)		range						StartVelocityRadialRange;
var (Velocity)		vector						MaxAbsVelocity;
var (Velocity)		rangevector					VelocityLossRange;
var (Velocity)		int							AddVelocityFromOtherEmitter;
var (Velocity)		rangevector					AddVelocityMultiplierRange;
var (Velocity)		EParticleVelocityDirection	GetVelocityDirectionFrom;
var (Velocity)		float						OwnerBaseVelocityTransferAmount;

var (Warmup)		float						WarmupTicksPerSecond;
var (Warmup)		float						RelativeWarmupTime;

var transient		emitter						Owner;
var	transient		bool						Initialized;
var transient		bool						Inactive;
var transient		float						InactiveTime;
var transient		array<Particle>				Particles;
var transient		int							ParticleIndex;			// index into circular list of particles
var transient		int							ActiveParticles;		// currently active particles
var transient		float						PPSFraction;			// used to keep track of fractional PPTick
var transient		box							BoundingBox;

var transient		vector						RealExtentMultiplier;
var	transient		bool						RealDisableFogging;
var transient		bool						AllParticlesDead;
var transient		bool						WarmedUp;
var	transient		int							OtherIndex;
var transient		float						InitialDelay;
var transient		vector						GlobalOffset;
var transient		float						TimeTillReset;
var transient		int							PS2Data;
var transient		int							MaxActiveParticles;
var transient		int							CurrentCollisionSoundIndex;
var transient		int							CurrentSpawningSoundIndex;
var transient		float						MaxSizeScale;
var transient		int							KillPending;
var transient		int							DeferredParticles;

var	transient		float						StartLocationScale;
var transient		float						StartLocationScaleTimeLeft;

native function SpawnParticle( int Amount );
native function Trigger();

defaultproperties
{
     SpawnFromOtherEmitter=-1
     MaxParticles=10
     AddLocationFromOtherEmitter=-1
     AddVelocityFromOtherEmitter=-1
     SecondsBeforeInactive=1.000000
     Texture=Texture'Engine.S_Emitter'
     ExtentMultiplier=(X=1.000000,Y=1.000000,Z=1.000000)
     DampingFactorRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     ColorMultiplierRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     StartColorRange=(X=(Min=255.000000,Max=255.000000),Y=(Min=255.000000,Max=255.000000),Z=(Min=255.000000,Max=255.000000))
     StartAlphaRange=(Min=255.000000,Max=255.000000)
     FadeOutFactor=(W=1.000000,X=1.000000,Y=1.000000,Z=1.000000)
     FadeInFactor=(W=1.000000,X=1.000000,Y=1.000000,Z=1.000000)
     StartMassRange=(Min=1.000000,Max=1.000000)
     SpinCCWorCW=(X=0.500000,Y=0.500000,Z=0.500000)
     StartSizeRange=(X=(Min=100.000000,Max=100.000000),Y=(Min=100.000000,Max=100.000000),Z=(Min=100.000000,Max=100.000000))
     LifetimeRange=(Min=4.000000,Max=4.000000)
     AddVelocityMultiplierRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     DrawStyle=PTDS_Translucent
     RespawnDeadParticles=True
     AlphaTest=True
     ZTest=True
     UseRegularSizeScale=True
     AutomaticInitialSpawning=True
     TriggerDisabled=True
}
