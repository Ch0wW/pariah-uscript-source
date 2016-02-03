class VGACTION_ExitVehicle extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local VGVehicle Car;
	local VGPawn driver;

	if( C.Pawn == None || VGVehicle(C.Pawn) == None)
	{ 
		warn("VGACTION ExitVehicle called when not driving VGVehicle");
		C.bBroken = true;
		return false;
	}

	car = VGVehicle(C.Pawn);
	driver = car.Driver;

	car.EndControlOfVehicle( C );
	if( C.IsA('DriveController') )
	{
		DriveController(C).ResetCar();
	}
	driver.SetDrivenVehicle(None);

	C.TakeControlOf(driver);
	driver.SetMovementPhysics(); 
	if (driver.Physics == PHYS_Walking)
			driver.SetPhysics(PHYS_Falling);

	car.UnPossessed();
	car.bBrake = false;
    
	driver.Level.Game.ExitedVehicle( C, driver, car );
	
	return false;
}

defaultproperties
{
     ActionString="ExitVehicle"
}
