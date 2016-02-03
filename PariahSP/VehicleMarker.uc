class VehicleMarker extends SinglePlayerTriggers
	placeable;

var() class<VGVehicle> VehicleClass;
var() class<VehicleWeapon> Weapons[3];
var() Name	TagForVehicle;
var() Name VehicleDriverExitEvent;
var() Name VehicleDriverEnterEvent;
var() Name VehicleRiderEnterEvent;
var() Name VehicleRiderExitEvent;
var() Name VehicleFlipEvent;
var() Name VehicleDestroyEvent;

function Trigger( actor Other, pawn EventInstigator )
{
	local VGVehicle Vehicle;

	if(DebugLogging)
		log("VehicleMarker "$self$" was triggered by tag "$Tag$" and is spawning a vehicle");
	Vehicle = spawn(VehicleClass,self,,Location,Rotation);

	if(Vehicle==None)
	{
		log("VehicleMarker "$self$" Failed to Spawn Vehicle");
		return;
	}

	Vehicle.SetupVehicleWeapons();

	if( TagForVehicle != '')
		Vehicle.Tag = TagForVehicle;

    Vehicle.DriverExitEvent = VehicleDriverExitEvent;
    Vehicle.DriverEnterEvent = VehicleDriverEnterEvent;
	Vehicle.RiderEnterEvent = VehicleRiderEnterEvent;
	Vehicle.RiderExitEvent = VehicleRiderExitEvent;
	Vehicle.FlipEvent = VehicleFlipEvent;
	Vehicle.DestroyEvent = VehicleDestroyEvent;
}

event PreLoadData()
{
	Super.PreLoadData();
	PreLoad( VehicleClass );
}

defaultproperties
{
     bDirectional=True
     bNeedPreLoad=True
}
