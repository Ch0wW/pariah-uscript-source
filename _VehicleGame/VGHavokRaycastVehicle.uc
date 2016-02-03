class VGHavokRaycastVehicle extends VGHavokVehicle
	abstract
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const transient int		VehicleData;		// native use data

struct native RaycastWheelInfo
{
	var () int					Axle;				// the axle the wheel belongs to
	var () float				Radius;				// radius of the wheel
	var () float				Width;				// width of wheel
	var () float				Mass;				// mass of the wheel

	/// The friction coefficient of the wheel (will be multiplied
	/// with the friction value of the landscape to get the final
	/// value).  Realistic values go from 0.5f to 1.0f, however to
	/// get good game play, values up to 4.0f make sense.
	var () float				Friction;

	// this is used for programatically overriding wheel friction
	//
	var float					FrictionOverride;

	/// An extra velocity dependent friction factor addon this
	/// factor allows to increase the friction if the car slides.
	/// Note: this is unrealistic for driving on roads however make
	/// sense in some off road environments.
	/// It also allows to tweak the car for better handling.
	/// Values between 0.0f and 0.1f are reasonable.
	var () float				ViscosityFriction;

		/// Clips the final friction. formula: resulting friction = max( wheelsFriction +
	/// slipVelocity * wheelsViscosityFriction, wheelsMaxFriction). Values between
	/// wheelsFriction and wheelsFriction* 2.0f are reasonable.
	var () float				MaxFriction;

	/// The calculated suspension force is scaled by this constant before it is applied
	/// to any dynamic body the vehcile is driving on. Usually this should be set to
	/// 1.0.
	var () float				ForceFeedbackMultiplier;

	/// The maximum torque the wheel can apply when braking
	var () float				MaxBrakingTorque;

	/// The min amount of braking from the driver that could cause the wheel to block (range [0..1])
	var () float				MinPedalInputToBlock;

	/// A point within the chassis where the suspension of the wheel is attached to.
	var () vector				HardpointCS;

	/// the direction of the suspension (in Chassis Space).
	var () vector				DirectionCS;

	/// the length of the suspension
	var () float				Length;

	/// The strenght [N/m] of the suspension at each wheel.
	var () float				Strength;

	/// The damping force [N/(m/sec)] of the suspension at each wheel under compression.
	var () float				DampingCompression;

	/// The damping force [N/(m/sec)] of the suspension at each wheel under relaxation (rebound).
	var () float				DampingRelaxation;

	var () float				TorqueRatio;		// fraction of total torque applied to this tire

	var () float				TiretrackWidthOffset;	// use this to offset the tiretrack to the right (or left if negative)

	var () bool					SteeringLocked;
	var () bool					UsedByHandbrake;
	var () bool					FlipMeshInY;

	var () bool					bDontCreateEmitters;			// if true, don't create emitters for this wheel
	var () bool					bMoveEmittersToContactPoint;	// normally they get moved to wheel center

	var () bool					NegateSuspOffsetY;
	var () int					SuspensionIndex;			// index into Suspensions

	var () StaticMesh			Mesh;
	var int						AttachedMeshIndex;		// index of wheel mesh in vehicles attached meshes
	var array<Emitter>			Emitters;

	var array<int>				SuspensionAttachedMeshIndices;	// indices into vehicles attached meshes

	// current wheel information updated at runtime
	var const transient bool			IsInContact;					// is wheel in contact with anything
	var const transient bool			WheelLocked;					// is wheel locked (by handbrake for example)
	var const transient float			CurBrakingTorque;				// braking torque applied at a specific wheel
	var const transient float			CurEngineTorque;				// engine torque transmitted to the particular wheel
	var const transient int				CurSteeringAngle;				// current steering angle
	var const transient float			ContactFriction;				// friction coefficient at point of contact
	var const transient int				SpinVelocity;					// spin velocity of wheel
	var const transient int				SpinAngle;						// spin angle of wheel
	var const transient float			SkidEnergy;						// energy density lost when skidding
	var const transient float			SideForce;						// side force at wheel
	var const transient float			ForwardSlipVelocity;			// slip velocity in forward direction
	var const transient vector			ContactPoint;					// contact point in world space
	var const transient vector			ContactNormal;					// contact normal in world space
	var const transient ESurfaceTypes	ContactSurfaceType;				// contact surface type
};

var (VGWheels) export array<RaycastWheelInfo>			Wheels;
var (VGWheels) export editinline array<TireEffectInfo>	TireEffects;
var (VGSuspension) export array<VGDecoAssemblyInfo>		Suspensions;

struct native TiretrackInfo
{
	var () array<ESurfaceTypes>	Surfaces;
	var () bool					bExclusive;		// if true, this applies to all surfaces EXCEPT the ones in surfaces
	var () float				MinSkidEnergy;
	var () float				MaxSkidEnergy;
	var () Material				Material;
};

var (VGTiretracks) export editinline array<TiretrackInfo>	Tiretracks;
var (VGTiretracks) int										TiretrackPoints;
var (VGTiretracks) float									TiretrackMinInterval;
var (VGTiretracks) float									TiretrackParameterScale;
var (VGTiretracks) float									TiretrackHeightOffset;	// use this to offset the tiretrack up

var (VGSteering) float			MaxSpeedFullSteeringAngle;	// The maximum speed (unreal units/sec) at which the vehicle will still be able to reach MaxSteerAngle

var transient float				CurSteeringAngle;			// current main steering angle

var (VGEngine) float			MinRPM;						// The minimum RPM of the engine
var (VGEngine) float			OptRPM;						// The optimum RPM, where the gross torque of the engine is maximal
var (VGEngine) float			MaxRPM;						// The maximum RPM of the engine
var (VGEngine) float			MaxTorque;					// The maximum gross torque the engine can supply at the optimal RPM.
															// This value is also the base for the following "factor" values
var (VGEngine) float			TorqueFactorAtMinRPM;		// Defines the gross torque at the min rpm as a factor to the MaxTorque
var (VGEngine) float			TorqueFactorAtMaxRPM;		// Defines the gross torque at the max rpm as a factor to the MaxTorque
var (VGEngine) float			ResistanceFactorAtMinRPM;	// Defines the engine resistance torque at the min RPM as a factor of MaxTorque
var (VGEngine) float			ResistanceFactorAtOptRPM;	// Defines the engine resistance torque at the opt RPM as a factor of MaxTorque
var (VGEngine) float			ResistanceFactorAtMaxRPM;	// Defines the engine resistance torque at the max RPM as a factor of MaxTorque
var (VGEngine) float			ClutchSlipRPM;				// An extra RPM for the engine in case the clutch is slipping at low speeds

var const transient float		CurTorque;					// torque currently being applied by engine
var const transient float		CurRPM;						// current RPM at which engine is working

var (VGTransmission) float		DownshiftRPM;				// The RPM at which the transmission shifts down a gear
var (VGTransmission) float		UpshiftRPM;					// The RPM at which the transmission shift up a gear
var (VGTransmission) float		PrimaryTransmissionRatio;	// The transmission ratio regardless of gear. It is an extra factor for the total transmission ratio
var (VGTransmission) float		ClutchDelayTime;			// The time needed (in seconds) to shift a gear
var (VGTransmission) float		ReverseGearRatio;			// The gear ratio for the reverse gear
var (VGTransmission) array<float> GearRatios;					// gear ratios...also determines the number of gears

var const transient int			CurGear;
var const transient float		CurTransmissionTorque;		// torque transmitted by the transmission.
var const transient float		CurTransmissionRPM;			// current RPM inside transmission
var const transient bool		bIsReversing;				// is true if vehicle is reversing

var (VGBrakes) float			MinTimeToLockWheels;		// The minimum time in seconds the driver should maintain a pedal input higher
															// than MinPedalInputToBlock before the wheel locks.
var (VGBrakes) float			AutoBrakeSpeed;				// if speed drops below this, turn on brakes
var (VGBrakes) bool				bUseHandbrakeForBrake;

var (VGAerodynamics) float		FrontalArea;				// The frontal area of the vehicle, in Unreal Units squared
var (VGAerodynamics) float		DragCoefficient;			// The aerodynamics drag coefficient of the vehicle.
															// It depends on the shape of the vehicle. Values around 0.3 are realistic.
															// This value is quite important for the characteristics of the vehicle as
															// it greatly influences the maximum speed it can reach.
var (VGAerodynamics) float		LiftCoefficient;			// The aerodynamics lift coefficient of the car. For normal cars, it's
															// usually slightly positive, but racing cars have usually negative values,
															// due to the use of spoilers and so on. Values between –0.5f and 0.5 are usually good.
var (VGAerodynamics) vector		ExtraGravity;				// An extra, non-physical "gravity" force to be applied to the chassis.
															// Adding this extra force has the effect of accelerating the subjective time of the driver.

// There are two sets of spin damping:
// - one used when vehicle has been in the air longer than InAirSpinDampingTime seconds
// - one used when vehicle is on the ground
//
var (VGAngDamping) float			InAirSpinDampingTime;			// How long vehicle is in air before in air spin damping is used
var (VGAngDamping) float			InAirNormalSpinDamping;			// A damping of the chassis angular velocity in normal mode
var (VGAngDamping) float			InAirCollisionSpinDamping;		// A damping of the chassis angular velocity in collision mode
var (VGAngDamping) float			InAirCollisionAngVelThreshold;	// If the chassis angular velocity is higher than this value, use InAirCollisionSpinDamping
var (VGAngDamping) float			NormalSpinDamping;				// A damping of the chassis angular velocity in normal mode
var (VGAngDamping) float			CollisionSpinDamping;			// A damping of the chassis angular velocity in collision mode
var (VGAngDamping) float			CollisionAngVelThreshold;		// If the chassis angular velocity is higher than this value, use CollisionSpinDamping

var float							InAirTime;
var const bool						bWasInAirSpinDamping;

var (VGInput) float					InputDeadZone;			// Input values less than this are ignored
var (VGInput) float					InputSlopeChangePoint;
var (VGInput) float					InputInitialSlope;		// The initial slope used for input values > InputDeadZone and
															// < InputSlopeChangePoint. Used for small steering angles.
var (VGInput) bool					bAutoReverse;			// If true, the car will start reversing when the brake is applied and the car is stopped.

var (VGLinDamping) float			MinSpeedForExtraLinearDamping;	// minimum speed required before extra linear damping is added
var (VGLinDamping) float			ExtraLinearDamping;				// initial amount of extra linear damping
var (VGLinDamping) float			ExtraLinearDampingRate;			// how quickly extra linear damping increases as speed increases
var (VGLinDamping) float			InAirExtraLinearDampingTime;	// how long vehicle is in air before in air extra linear damping is used
var (VGLinDamping) float			InAirExtraLinearDamping;		// how much linear damping to add when in the air
var const bool						bExtraLinearDampingApplied;

// Specifies how the effect of dynamic load distribution is averaged with static load distribution.
// A value of 0.0f doesn't do any averaging (dynamic load distribution is fully taken into account).
// A value of 1.0f doesn't take dynamic load distribution, and the car behaves always as if it was in static load distribution.
// Values between 0.0f and 1.0f give a certain amount of both.
var (VGRaycastVehicle) float		FrictionEqualizer;

// Scales the torques applied by the simulation at the roll axis by the given factor.
var (VGRaycastVehicle) float		TorqueRollFactor;

// Scales the torques applied by the simulation at the pitch axis by the given factor.
var (VGRaycastVehicle) float		TorquePitchFactor;

// Scales the torques applied by the simulation at the yaw axis by the given factor.
var (VGRaycastVehicle) float		TorqueYawFactor;

// An extra torque which is applied to the car when steering is pointing left or right.
// Note: some coordinate systems require negative values.
var (VGRaycastVehicle) float		ExtraSteerTorqueFactor;

// The rotation inertia in yaw direction for a car of the mass 1.0f kilo
var (VGRaycastVehicle) float		ChassisUnitInertiaYaw;

// The rotation inertia in roll direction for a car of the mass 1.0f kilo
var (VGRaycastVehicle) float		ChassisUnitInertiaRoll;

// The rotation inertia in pitch direction for a car of the mass 1.0f kilo
var (VGRaycastVehicle) float		ChassisUnitInertiaPitch;

/// To avoid sliding at slow speeds or when the handbrake is turned on, we
/// introduced a positional friction model (since havok 2.2.1) 			into the
/// vehicle friction solver. 			This extra friction is particular usefull for
/// slow driving cars. To avoid letting this friction influence fast cars, you can
/// set 			maxVelocityForPositionalFriction to the maximum velocity, up to which
/// you want this extra algorithm to be activated. 			defines up to which speed
/// the positional friction model will be used.
var (VGRaycastVehicle) float		MaxVelocityForPositionalFriction;

var (VGSounds) sound				ShiftUpSound;
var (VGSounds) sound				ShiftDownSound;
var (VGSounds) byte					ShiftUpSoundVolume;
var (VGSounds) byte					ShiftDownSoundVolume;
var const int						ShiftSoundGear;

var (VGVehicle) int					UprightMaxLeanAngle;	// unreal units

var Actor							TireSoundActor;

var const transient int				UpdatingEmittersForWheel;	// yuck

var float							OutputBrake;
var const bool						bWasBraking;

var (VGRaycastVehicle) float		HitImpulseScale;			// scale hit impulses
var (VGRaycastVehicle) float		HitImpulseRadialScale;		// 0 - impulse will be straight up, 1 - no change, > 1 impulse will be more radial
var (VGRaycastVehicle) float		MaxHitImpulse;				// maximum hit impulse
var (VGRaycastVehicle) float		HitImpulseSpinScale;		// scale the amount of spin imparted by the hit impulse
var (VGRaycastVehicle) float		HitImpulseLinearDamping;	// linear damping used after a major hit impulse
var (VGRaycastVehicle) float		HitImpulseAngularDamping;	// angular damping used after a major hit impulse
var bool							bMajorHitFlippingEnhance;	// :-)
var float							HitImpulseDelay;
var bool							bStillInAirAfterHitImpulse;


var (VGVehicle) float				FlipDropHeight;
var (VGVehicle) float				FlipDamping;

var bool							bUseFrictionOverride;
var const bool						bZeroFrictionOverride;
var const bool						bWasOverridingFriction;

// if this is true, impulses are applied to vehicle when it's taking damage
//
var bool							bApplyTakeDamageImpulse;

var bool							bIgnoreVehicleExplosions;

// Networking

// this is a struct representing the low level driving state
// that needs to get replicated
//
struct native VGHavokRaycastVehicleControlState
{
	var byte	Throttle;
	var byte	Steering;
	var byte	Brake;
	var byte	Flags;
};

var VGHavokRaycastVehicleControlState	ControlState;

struct native VGHavokRaycastVehicleState
{
	// all parameters needed to totally describe chassis state
	//
	var Vector								ChassisPosition;
	var Quat								ChassisQuaternion;
	var Vector								ChassisLinVel;
	var Vector								ChassisAngVel;
};

var KRigidBodyState				ChassisState;
var VGHavokRaycastVehicleState	RaycastVehicleState;				// This is replicated to the car, and processed to update all the parts.
var byte						bStateToggle;						// toggled whenever a new state is received and should be processed
var byte						bLastStateToggle;
var bool						bStateHasBeenUpdated;				// true if RaycastVehicleState has been updated
var bool						bNewRaycastVehicleStateChassis;		// there is new chassis info in RaycastVehicleState
var bool						bRaycastVehicleStateChassisValid;
var bool						bNewChassisState;					// indicates there is new data processed, and chassis state should be updated.
var float						LastNetUpdateTime;					// last time server set car update to clients
var bool						bReplayingMove;
var config float				MaxNetUpdateInterval;
var config float				MinNetUpdateInterval;

// used for debugging
var private transient bool		bControlStateUnpacked;
var private transient bool		bNewChassisStateLog;
var private transient bool		bStateLog;

replication
{
	unreliable if ( !bNetOwner && Role==ROLE_Authority  )
		ControlState, RaycastVehicleState, bStateToggle, bStateLog;

	reliable if ( Role == ROLE_Authority )
		ClientAdjustRaycastVehicleState, ClientApplyHitImpulse, bStateHasBeenUpdated;

	reliable if ( Role < ROLE_Authority )
		ServerRaycastVehicleMove;
}

// this is a replicated function called from AdjustClientVehicleState on the server
native event ClientAdjustRaycastVehicleState
(
	bool			bLog,
	float			TimeStamp,
	Vector			NewLoc,
	Quat			NewQuat,
	Vector			NewLinVel,
	Vector			NewAngVel
);

// this is a replicated function that is called on server
//
native event ServerRaycastVehicleMove(
	bool								bLog,
	float								TimeStamp,
	bool								NewbPressedJump,
	VGHavokRaycastVehicleState			NewChassis,
	VGHavokRaycastVehicleControlState	NewCarControlState
);

// move replays currently not supported
function SetupForMoveReplay(
	VehicleSavedMove	Move
)
{
}

// only used for move replays which aren't supported
function MoveVehicleAutonomous(
	float	DeltaTime
)
{
}

simulated function InitializeVehicle()
{
	local int		w, e, ami;

	Super.InitializeVehicle();

	// create any wheel meshs
	//
	for ( w = 0; w < Wheels.Length; w++ )
	{
		if ( Wheels[w].Mesh != None )
		{
			ami = NewAttachedStaticMesh();
			Wheels[w].AttachedMeshIndex = ami;
			AttachedStaticMeshes[ami].UseBaseRotation = True;
			AttachedStaticMeshes[ami].BaseIsAbsolute = True;
			AttachedStaticMeshes[ami].StaticMesh = Wheels[w].Mesh;
			if ( Wheels[w].FlipMeshInY )
			{
				AttachedStaticMeshes[ami].DrawScale = vect(1,-1,1);
			}
		}

		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( !Wheels[w].bDontCreateEmitters )
			{
				Wheels[w].Emitters.Length = TireEffects.Length;
				for ( e = 0; e < TireEffects.Length; e++ )
				{
					TireEffects[e].CreateEmitter( self, Wheels[w].Emitters[e] );
					Wheels[w].Emitters[e].SetBase( None );	// we move it in vehicle tick
					AddVehicleActor( Wheels[w].Emitters[e] );
				}
			}

			CreateSuspension( w );
		}
	}

	// create actor for tire sounds
	//
	TireSoundActor = spawn(class'TireAmbientSound',self);
	TireSoundActor.SetBase( self );
	AddVehicleActor( TireSoundActor );
}

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
		if ( Wheels[AssemblyIndex].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		break;
	case SPL_ChassisWheelPos:
		RefAsmIndex = 0;
		RefActor = None;
		if ( Wheels[AssemblyIndex].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		offset += Wheels[AssemblyIndex].HardpointCS;
		break;
	case SPL_Wheel:
		if ( Wheels[AssemblyIndex].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		RefAsmIndex = Wheels[AssemblyIndex].AttachedMeshIndex + 1;
		RefActor = None;
		break;
	case SPL_Wheel0:
		if ( Wheels[0].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		RefAsmIndex = Wheels[0].AttachedMeshIndex + 1;
		RefActor = None;
		break;
	case SPL_Wheel1:
		if ( Wheels[1].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		RefAsmIndex = Wheels[1].AttachedMeshIndex + 1;
		RefActor = None;
		break;
	case SPL_Wheel2:
		if ( Wheels[2].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		RefAsmIndex = Wheels[2].AttachedMeshIndex + 1;
		RefActor = None;
		break;
	case SPL_Wheel3:
		if ( Wheels[3].NegateSuspOffsetY )
		{
			offset.Y = -offset.Y;
		}
		RefAsmIndex = Wheels[3].AttachedMeshIndex + 1;
		RefActor = None;
		break;
	default:
		Super.GetDecoPieceRef(
			PieceLocation, AssemblyIndex, PieceAsmIndices,
			RefAsmIndex, RefActor, offset
		);
		break;
	}
}

simulated function CreateSuspension(
	int		whichTire
)
{
	local int					s;

	s = Wheels[whichTire].SuspensionIndex;
	if ( s >= 0 && s < Suspensions.Length )
	{
		CreateDecoAssembly( Suspensions[s], whichTire, Wheels[whichTire].SuspensionAttachedMeshIndices );
	}
}

simulated function KPawnArtUpdateParams()
{
	local int w, si, ami;

	// regenerate suspension pieces
	for ( w = 0; w < Wheels.Length; w++ )
	{
		// mark old suspension pieces as unused
		//
		for ( si = 0; si < Wheels[w].SuspensionAttachedMeshIndices.Length; si++ )
		{
			ami = Wheels[w].SuspensionAttachedMeshIndices[si] - 1;	// CreateDecoAssembly increments the index when they are created
			if ( ami >= 0 )
			{
				AttachedStaticMeshes[ami].Unused = True;
			}
		}
		Wheels[w].SuspensionAttachedMeshIndices.Length = 0;
	}
	for ( w = 0; w < Wheels.Length; w++ )
	{
		CreateSuspension( w );
	}

	Super.KPawnArtUpdateParams();
}

simulated function int AddWheel(
	int				Axle,
	StaticMesh		Mesh
)
{
	local int	w;

	w = Wheels.Length;
	Wheels.Length = w + 1;
	Wheels[w].Axle = Axle;
	Wheels[w].Mesh = Mesh;
	return w;
}


simulated function UpdateEmitterData(
	int			w,
	bool		bMoveEmittersToContactPoint,
	bool		bCreateEmitters
)
{
	Wheels[w].bMoveEmittersToContactPoint = bMoveEmittersToContactPoint;
	Wheels[w].bDontCreateEmitters = !bCreateEmitters;
}

simulated function UpdateWheelData(
	int			w,
	float		Radius,
	float		Width,
	float		Mass,
	float		Friction,
	float		ViscosityFriction,
	float		MaxFriction,
	float		ForceFeedbackMultiplier,
	float		TorqueRatio,
	float		TiretrackOffset
)
{
	Wheels[w].Radius = Radius;
	Wheels[w].Width = Width;
	Wheels[w].Mass = Mass;
	Wheels[w].Friction = Friction;
	Wheels[w].ViscosityFriction = ViscosityFriction;
	Wheels[w].MaxFriction = MaxFriction;
	Wheels[w].ForceFeedbackMultiplier = ForceFeedbackMultiplier;
	Wheels[w].TorqueRatio = TorqueRatio;
	Wheels[w].TiretrackWidthOffset = TiretrackOffset;
}

simulated function UpdateSuspensionData(
	int			w,
	vector		HardpointCS,
	vector		DirectionCS,
	float		Length,
	float		Strength,
	float		DampingCompression,
	float		DampingRelaxation,
	bool		SteeringLocked
)
{
	Wheels[w].HardpointCS = HardpointCS;
	Wheels[w].DirectionCS = DirectionCS;
	Wheels[w].Length = Length;
	Wheels[w].Strength = Strength;
	Wheels[w].DampingCompression = DampingCompression;
	Wheels[w].DampingRelaxation = DampingRelaxation;
	Wheels[w].SteeringLocked = SteeringLocked;
}

simulated function UpdateBrakingData(
	int		w,
	bool	UsedByHandbrake,
	float	MaxBrakingTorque,
	float	MinPedalInputToBlock
)
{
	Wheels[w].MaxBrakingTorque = MaxBrakingTorque;
	Wheels[w].MinPedalInputToBlock = MinPedalInputToBlock;
	Wheels[w].UsedByHandbrake = UsedByHandbrake;
}

simulated native function ApplyHitImpulse( vector HitImpulse, vector HitLoc, bool bMajorHit );

simulated function ClientApplyHitImpulse( float HitImpulseX, float HitImpulseY, float HitImpulseZ, vector HitLocation, bool bMajorHit )
{
	local vector HitImpulse;

	HitImpulse.X = HitImpulseX;
	HitImpulse.Y = HitImpulseY;
	HitImpulse.Z = HitImpulseZ;
	ApplyHitImpulse( HitImpulse, HitLocation, bMajorHit );
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local vector Impulse;

	if ( !bIgnoreVehicleExplosions || !ClassIsChildOf( damageType, class'VehicleExplDamage' ) )
	{
		//`log( "RJ: TakeDamage("$Damage$","$instigatedBy$","$damageType$")" );
		if( Role == ROLE_Authority && bApplyTakeDamageImpulse && damageType.static.GetHavokVehicleHitImpulse( momentum, Impulse ) )
		{
			//`log( "RJ: TakeDamage applying impulse="$Impulse );
			if ( RemoteRole == ROLE_AutonomousProxy && !bServerTakeControl )
			{
				ClientApplyHitImpulse( Impulse.X, Impulse.Y, Impulse.Z, hitlocation, bSplashDamage );
			}
			ApplyHitImpulse( Impulse, hitlocation, bSplashDamage );
		}
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType, ProjOwner, bSplashDamage);
	}
}

simulated native function bool IsInContact();

simulated function DrawVehicleStats( canvas Canvas, optional int indent )
{
	local VGHavokRaycastVehicle	Car;
	local float					left, cl;
	local float					ypos;
	local float					xl, yl;
	local float					f;
	local int					i, cg, t0;
	local string				s;
	local byte					red, grn, blu;

	Car = self;

	if ( indent <= 0 )
	{
		left = 20;
	}
	else
	{
		left = indent;
	}
	Canvas.Font = Canvas.SmallFont;
	red=255;
	grn=255;
	blu=0;
	Canvas.SetDrawColor(red, grn, blu);

	Canvas.StrLen("TEST", xl, yl);
	ypos = Canvas.ClipY - 5 * yl;

	i = (Car.ForwardVel * 60 * 60) * 1.8288 / 165 / 1000;	// kph assuming 165 units == 6 ft == 1.8288m
	s = i$" kph (";
	i = Car.ForwardVel;
	s = s$i$" units/sec)/";
	cg = Car.CurGear;
	if ( Car.bIsReversing )
	{
		cg = -1;
	}
	switch ( cg )
	{
	case -1:
		s = s$"R";
		break;
	default:
		i = cg + 1;
		s = s$i;
	}
	if ( Car.TurboTimeLeft > 0 )
	{
		i = Car.TurboTimeLeft * 1000;
		s = s$" T="$i$"ms";
	}
	Canvas.SetPos( left, ypos );
	Canvas.DrawText( s );
	ypos -= yl;

	// draw slip info
	//
	cl = left;
	s = "Skid: ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	for ( i = 0; i < Car.Wheels.Length; i++ )
	{
		t0 = Car.Wheels[i].SkidEnergy;
		s = "["$i$":"$t0$"]";
		Canvas.SetPos( cl, ypos );
		Canvas.DrawText( s );
		Canvas.StrLen( s, xl, f );
		cl += xl;
	}
	ypos -= yl;

	// draw braking info
	//
	cl = left;
	s = "Brakes: ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	for ( i = 0; i < Car.Wheels.Length; i++ )
	{
		t0 = Car.Wheels[i].CurBrakingTorque;
		s = "["$i$":"$t0$"]";
		if ( Car.Wheels[i].WheelLocked )
		{
			Canvas.SetDrawColor( 255, 0, 0 );
		}
		Canvas.SetPos( cl, ypos );
		Canvas.DrawText( s );
		Canvas.StrLen( s, xl, f );
		cl += xl;
		if ( Car.Wheels[i].WheelLocked )
		{
			Canvas.SetDrawColor( red, grn, blu );
		}
	}
	ypos -= yl;

	// draw steering info
	//
	cl = left;
	t0 = CurSteeringAngle * 0.0054931640625;
	s = "Steering: "$t0$" ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	for ( i = 0; i < Car.Wheels.Length; i++ )
	{
		t0 = Car.Wheels[i].CurSteeringAngle * 0.0054931640625;
		s = "["$i$":"$t0$"]";
		if ( !Car.Wheels[i].IsInContact )
		{
			Canvas.SetDrawColor( 255, 0, 0 );
		}
		Canvas.SetPos( cl, ypos );
		Canvas.DrawText( s );
		Canvas.StrLen( s, xl, f );
		cl += xl;
		if ( !Car.Wheels[i].IsInContact )
		{
			Canvas.SetDrawColor( red, grn, blu );
		}
	}
	ypos -= yl;

	// draw engine info
	//
	cl = left;
	i = Car.CurRPM;
	s = "Engine: "$i$"rpm";
	i = Car.CurTorque;
	s = s$"->Tq="$i$" ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	for ( i = 0; i < Car.Wheels.Length; i++ )
	{
		t0 = Car.Wheels[i].CurEngineTorque;
		s = "["$i$":"$t0$"]";
		Canvas.SetPos( cl, ypos );
		Canvas.DrawText( s );
		Canvas.StrLen( s, xl, f );
		cl += xl;
	}
	ypos -= yl;

	// draw gearing info
	//
	cl = left;
	i = Car.CurTransmissionRPM;
	s = "Trans: "$i$"rpm";
	i = Car.CurTransmissionTorque;
	s = s$"->Tq="$i$" ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	for ( i = 0; i < Car.GearRatios.Length; i++ )
	{
		s = "["$i+1$":R="$Car.GearRatios[i]$"]";

		if ( i == cg )
		{
			Canvas.SetDrawColor( 255, 0, 0 );
		}
		Canvas.SetPos( cl, ypos );
		Canvas.DrawText( s );
		Canvas.StrLen( s, xl, f );
		cl += xl;
		if ( i == cg )
		{
			Canvas.SetDrawColor( red, grn, blu );
		}
	}
	s = " Up="$Car.UpshiftRPM$"rpm,Dn="$Car.DownshiftRPM$"rpm ";
	Canvas.SetPos( cl, ypos );
	Canvas.DrawText( s );
	Canvas.StrLen( s, xl, f );
	cl += xl;
	ypos -= yl;

	if ( GeneratedVehicleShadow != None && GeneratedVehicleShadow.ShadowTexture != None )
	{
		Canvas.SetPos( 10, 10 );
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.DrawTile(GeneratedVehicleShadow.ShadowTexture, 128, 128, 0, 0, 128, 128);
	}
}

event HImpact( actor other, vector pos, vector impactVel, vector impactNorm, Material HitMaterial )
{
	InAirTime = 0;
	if ( HitImpulseDelay <= 0 )
	{
		bStillInAirAfterHitImpulse = False;
	}

	Super.HImpact( other, pos, impactVel, impactNorm, HitMaterial );
}

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.FlameRingProjector',,,Location, Rotation + rot(-16384,0,0));
	spawn(class'VehicleEffects.VehicleExplosionMark',,,Location, Rotation + rot(-16384,0,0));
}

defaultproperties
{
     TiretrackPoints=256
     UprightMaxLeanAngle=1000
     TiretrackMinInterval=50.000000
     TiretrackParameterScale=100.000000
     TiretrackHeightOffset=2.000000
     MaxSpeedFullSteeringAngle=2000.000000
     MinRPM=1000.000000
     OptRPM=5500.000000
     MaxRPM=7500.000000
     MaxTorque=500.000000
     TorqueFactorAtMinRPM=0.800000
     TorqueFactorAtMaxRPM=0.800000
     ResistanceFactorAtMinRPM=0.050000
     ResistanceFactorAtOptRPM=0.100000
     ResistanceFactorAtMaxRPM=0.300000
     ClutchSlipRPM=2000.000000
     DownshiftRPM=3500.000000
     UpshiftRPM=6500.000000
     PrimaryTransmissionRatio=5.500000
     ReverseGearRatio=1.000000
     MinTimeToLockWheels=1000.000000
     AutoBrakeSpeed=400.000000
     FrontalArea=5000.000000
     DragCoefficient=0.450000
     LiftCoefficient=-0.300000
     InAirSpinDampingTime=0.200000
     NormalSpinDamping=1.000000
     CollisionAngVelThreshold=4.000000
     InputSlopeChangePoint=0.700000
     InputInitialSlope=0.500000
     FrictionEqualizer=0.500000
     TorqueRollFactor=0.250000
     TorquePitchFactor=0.500000
     TorqueYawFactor=0.350000
     ExtraSteerTorqueFactor=0.500000
     ChassisUnitInertiaYaw=1.000000
     ChassisUnitInertiaRoll=0.400000
     ChassisUnitInertiaPitch=1.000000
     MaxVelocityForPositionalFriction=200.000000
     HitImpulseScale=1.000000
     HitImpulseRadialScale=1.000000
     HitImpulseSpinScale=1.000000
     FlipDropHeight=500.000000
     FlipDamping=0.500000
     MaxNetUpdateInterval=1.000000
     MinNetUpdateInterval=0.100000
     GearRatios(0)=2.000000
     bUseHandbrakeForBrake=True
     bAutoReverse=True
     bApplyTakeDamageImpulse=True
     MaxSteerAngle=4096.000000
     FlipTorque=10.000000
     SavedMoveClass=Class'VehicleGame.HavokRaycastVehicleSavedMove'
     DefaultWeapons(0)="VehicleWeapons.Puncher"
}
