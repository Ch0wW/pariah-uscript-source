class VGHavokHovercraft extends VGHavokRaycastVehicle
	abstract
	hidecategories(VGBrakes,VGEngine,VGSteering,VGTransmission)
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

var()	float				HoverStrength;
var()	float				HoverCompressionDamping;
var()	float				HoverReboundDamping;
var()	float				HoverDist;

var()	float				MaxThrust;
var()	float				MaxSteerTorque;
var()	float				ForwardDampFactor;
var()	float				VacantForwardDampFactor;
var()	float				LateralDampFactor;
var()	float				SteerDampFactor;
var()	float				PitchTorqueFactor;
var()	float				PitchDampFactor;
var()	float				BankTorqueFactor;
var()	float				BankDampFactor;
var()	float				UprightTorqueFactor;

var()	float				StopThreshold;

var()	bool				bBrakeLinearDampingApplied;
var()	float				BrakeLinearDamping;

struct native RepulsorInfo
{
	var () name	 AttachPoint;
	var () bool	 bCreateEmitters;
	var int		 WheelsIndex;
};

var () array<RepulsorInfo>	Repulsors;

simulated function InitializeVehicle()
{
	local int		a;
	local vector	loc;
	local rotator	rot;

	for ( a = 0; a < Repulsors.Length; a++ )
	{
		if ( GetAttachPoint( Repulsors[a].AttachPoint, loc, rot ) )
		{
			Repulsors[a].WheelsIndex = AddWheel( a, None );
		}
	}
	KPawnArtUpdateParams();

	// now create the repulsors/wheels
	Super.InitializeVehicle();
}

simulated function KPawnArtUpdateParams()
{
	local vector	DirCS, HardpointCS;
	local int		r;
	local rotator	rot;

	for ( r = 0; r < Repulsors.Length; ++r )
	{
		if ( GetAttachPoint( Repulsors[r].AttachPoint, HardpointCS, rot ) )
		{
			DirCS=vector(rot);
			UpdateWheelData(
				Repulsors[r].WheelsIndex,
				HoverDist / 3,				// radius
				10,							// width
				10,							// mass
				0, 0, 0,					// friction
				1,							// forcefeedback multiplier
				0, 0
			);
			UpdateSuspensionData(
				Repulsors[r].WheelsIndex,
				HardpointCS, DirCS,
				2 * HoverDist / 3,
				HoverStrength, HoverCompressionDamping, HoverReboundDamping, 
				True
			);
			UpdateBrakingData(
				Repulsors[r].WheelsIndex,
				False,
				0, 0
			);
			UpdateEmitterData(
				Repulsors[r].WheelsIndex,
				True, Repulsors[r].bCreateEmitters
			);
		}
	}
	Super.KPawnArtUpdateParams();
}

defaultproperties
{
     HoverStrength=20.000000
     HoverCompressionDamping=1.000000
     HoverReboundDamping=0.500000
     HoverDist=130.000000
     MaxThrust=20000.000000
     MaxSteerTorque=10000.000000
     ForwardDampFactor=13.000000
     VacantForwardDampFactor=50.000000
     LateralDampFactor=100.000000
     SteerDampFactor=10000.000000
     BankTorqueFactor=20000.000000
     BankDampFactor=10000.000000
     UprightTorqueFactor=40000.000000
     StopThreshold=100.000000
     BrakeLinearDamping=0.900000
     NormalSpinDamping=0.000000
     FrictionEqualizer=0.000000
     TorqueRollFactor=1.000000
     TorquePitchFactor=1.000000
     TorqueYawFactor=1.000000
     ExtraSteerTorqueFactor=0.000000
     ChassisUnitInertiaRoll=1.000000
     GearRatios(0)=2.000000
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     VehicleType=VT_Hover
}
