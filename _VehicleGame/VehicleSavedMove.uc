//=============================================================================
// VehicleSavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
//=============================================================================
class VehicleSavedMove extends Info
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

var VehicleSavedMove	NextMove;		// Next move in linked list.
var float				TimeStamp;		// Time of this move.
var float				Delta;			// Distance moved.
var float				Throttle;
var float				Steering;
var float				Turn;
var bool				bHandBrake;
var bool				bTurboButton;
var bool				bPressedJump;
var vector				SavedLocation, SavedVelocity;


event function PostUpdate( VehiclePlayer VP )
{
}

event SetControlState( VGVehicle v )
{
}

defaultproperties
{
}
