//=============================================================================
// VehicleSavedMove specific to Havok raycast vehicles
//=============================================================================
class HavokRaycastVehicleSavedMove extends VehicleSavedMove
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var float	Brake;

event PostUpdate(
	VehiclePlayer VP
)
{
	local VGHavokRaycastVehicle	v;

	if ( VP.Pawn != None )
	{
		SavedLocation = VP.Pawn.Location;
		SavedVelocity = VP.Pawn.Velocity;
		v = VGHavokRaycastVehicle( VP.Pawn );
		Brake = VGHavokRaycastVehicle( VP.Pawn ).OutputBrake;
	}
}

defaultproperties
{
}
