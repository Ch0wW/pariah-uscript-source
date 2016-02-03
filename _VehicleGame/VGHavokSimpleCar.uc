class VGHavokSimpleCar extends VGHavokRaycastVehicle
	hidecategories(VGWheels)
	abstract;

var () float		FrontWheelAlong;
var () float		FrontWheelAcross;
var () float		FrontWheelVert;
var () float		FrontWheelRadius;
var () float		FrontWheelWidth;
var () float		FrontWheelTiretrackOffset;
var () float		FrontWheelMass;
var () StaticMesh	FrontWheelMesh;
var () float		FrontWheelFriction;
var () float		FrontWheelViscosityFriction;
var () float		FrontWheelMaxFriction;
var () float		FrontWheelForceFeedbackMultiplier;
var () float		FrontSuspStrength;
var () float		FrontSuspCompressionDamping;
var () float		FrontSuspRelaxationDamping;
var () float		FrontSuspLength;
var () float		FrontMaxBrakingTorque;
var () float		FrontMinPedalInputToBlock;

var () float		RearWheelAlong;
var () float		RearWheelAcross;
var () float		RearWheelVert;
var () float		RearWheelRadius;
var () float		RearWheelWidth;
var () float		RearWheelTiretrackOffset;
var () float		RearWheelMass;
var () StaticMesh	RearWheelMesh;
var () float		RearWheelFriction;
var () float		RearWheelViscosityFriction;
var () float		RearWheelMaxFriction;
var () float		RearWheelForceFeedbackMultiplier;
var () float		RearSuspStrength;
var () float		RearSuspCompressionDamping;
var () float		RearSuspRelaxationDamping;
var () float		RearSuspLength;
var () float		RearMaxBrakingTorque;
var () float		RearMinPedalInputToBlock;

var () int			FrontLeftSuspIndex;
var () int			FrontRightSuspIndex;
var () int			RearLeftSuspIndex;
var () int			RearRightSuspIndex;

// index of wheels in VGHavokRaycastVehicle::Wheels Array
var int				flIndex, frIndex, rlIndex, rrIndex;

var () float	TorqueSplit;     // front/rear drive torque split. 1 is fully RWD, 0 is fully FWD. 0.5 is standard 4WD.
var () bool		FourWheelSteering;

simulated function InitializeVehicle()
{
	// Add front left tire
	//
	flIndex = AddWheel( 0, FrontWheelMesh );
	Wheels[flIndex].SuspensionIndex = FrontLeftSuspIndex;
	Wheels[flIndex].NegateSuspOffsetY = True;	// flip suspension on left side

	// Add front right tire
	//
	frIndex = AddWheel( 0, FrontWheelMesh );
	Wheels[frIndex].SuspensionIndex = FrontRightSuspIndex;
	Wheels[frIndex].FlipMeshInY = True;		// flip tire mesh on right side

	// Add rear left tire
	//
	rlIndex = AddWheel( 1, RearWheelMesh );
	Wheels[rlIndex].SuspensionIndex = RearLeftSuspIndex;
	Wheels[rlIndex].NegateSuspOffsetY = True;	// flip suspension on left side

	// Add rear right tire
	//
	rrIndex = AddWheel( 1, RearWheelMesh );
	Wheels[rrIndex].SuspensionIndex = RearRightSuspIndex;
	Wheels[rrIndex].FlipMeshInY = True;		// flip tire mesh on right side

	UpdateWheelsData();

	// now create them
	//
	Super.InitializeVehicle();
}

simulated function UpdateWheelsData()
{
	local vector DirCS, HardpointCS;

	// front left tire
	//
	DirCS = vect(0,0,-1);
	HardpointCS.Y = -FrontWheelAcross;
	HardpointCS.X = FrontWheelAlong;
	HardpointCS.Z = FrontWheelVert;
	UpdateWheelData(
		flIndex, FrontWheelRadius, FrontWheelWidth, FrontWheelMass,
		FrontWheelFriction, FrontWheelViscosityFriction, FrontWheelMaxFriction, FrontWheelForceFeedbackMultiplier,
		0.5 * (1-TorqueSplit), -FrontWheelTiretrackOffset );
	UpdateSuspensionData( flIndex, HardpointCS, DirCS, FrontSuspLength, FrontSuspStrength, FrontSuspCompressionDamping, FrontSuspRelaxationDamping, False );
	UpdateBrakingData( flIndex, False, FrontMaxBrakingTorque, FrontMinPedalInputToBlock );

	// front right tire
	//
	HardpointCS.Y = FrontWheelAcross;
	UpdateWheelData(
		frIndex, FrontWheelRadius, FrontWheelWidth, FrontWheelMass,
		FrontWheelFriction, FrontWheelViscosityFriction, FrontWheelMaxFriction, FrontWheelForceFeedbackMultiplier,
		0.5 * (1-TorqueSplit), FrontWheelTiretrackOffset );
	UpdateSuspensionData( frIndex, HardpointCS, DirCS, FrontSuspLength, FrontSuspStrength, FrontSuspCompressionDamping, FrontSuspRelaxationDamping, False );
	UpdateBrakingData( frIndex, False, FrontMaxBrakingTorque, FrontMinPedalInputToBlock );

	// rear left tire
	//
	HardpointCS.Y = -RearWheelAcross;
	HardpointCS.X = RearWheelAlong;
	HardpointCS.Z = RearWheelVert;
	UpdateWheelData(
		rlIndex, RearWheelRadius, RearWheelWidth, RearWheelMass,
		RearWheelFriction, RearWheelViscosityFriction, RearWheelMaxFriction, RearWheelForceFeedbackMultiplier,
		0.5 * TorqueSplit, -RearWheelTiretrackOffset );
	UpdateSuspensionData( rlIndex, HardpointCS, DirCS, RearSuspLength, RearSuspStrength, RearSuspCompressionDamping, RearSuspRelaxationDamping, !FourWheelSteering );
	UpdateBrakingData( rlIndex, True, RearMaxBrakingTorque, RearMinPedalInputToBlock );

	// rear right tire
	//
	HardpointCS.Y = RearWheelAcross;
	UpdateWheelData(
		rrIndex, RearWheelRadius, RearWheelWidth, RearWheelMass,
		RearWheelFriction, RearWheelViscosityFriction, RearWheelMaxFriction, RearWheelForceFeedbackMultiplier,
		0.5 * TorqueSplit, RearWheelTiretrackOffset );
	UpdateSuspensionData( rrIndex, HardpointCS, DirCS, RearSuspLength, RearSuspStrength, RearSuspCompressionDamping, RearSuspRelaxationDamping, !FourWheelSteering );
	UpdateBrakingData( rrIndex, True, RearMaxBrakingTorque, RearMinPedalInputToBlock );
}

simulated function KPawnArtUpdateParams()
{
	UpdateWheelsData();

	Super.KPawnArtUpdateParams();
}

//should be overridden for each type of car (motorcycle, car etc)
function float getTurningRadius()
{
	local float unreal2Rad;
	unreal2Rad = MaxSteerAngle * PI / 32767.5;
	return tan(1.57 - unreal2Rad) * (FrontWheelAlong - RearWheelAlong);
}

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.DavidVehicleExplosionShrapnel',,,Location);
}

defaultproperties
{
     FrontWheelFriction=1.000000
     RearWheelFriction=1.000000
     TorqueSplit=0.500000
     GearRatios(0)=2.000000
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     VehicleType=VT_Wheeled
}
