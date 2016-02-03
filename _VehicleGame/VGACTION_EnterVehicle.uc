class VGACTION_EnterVehicle extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local VGVehicle vehToDrive;
	local VGPawn p;
	
	if( C.Pawn == None || VGPawn(C.Pawn) == None)
	{ 
		warn("VGACTION EnterVehicle called on non VGPawn");
		C.bBroken = true;
	}
	p = VGPawn(C.Pawn);
	vehToDrive = p.PotentialVehicle;
	
	if( !C.IsA('DriveController') )
	{
		//VGPawn(C.Pawn).SetDrivenVehicle(vehToDrive);
		//vehToDrive.SetPlayerOwner(vehToDrive.Driver);
		
        vehToDrive.Driver = p;
		vehToDrive.BeginControlOfVehicle(C);
		vehToDrive.Weapon.BringUp();
        C.TakeControlOf(vehToDrive);
		vehToDrive.Driver.Unpossessed();
	}
	else
	{
		//p.SetDrivenVehicle(vehToDrive);
		//vehToDrive.SetPlayerOwner(vehToDrive.Driver);
		//vehToDrive.BeginControlOfVehicle(C);
		vehToDrive.Driver = p;
		C.TakeControlOf(vehToDrive);
		vehToDrive.Driver.Unpossessed();
	}
	
	return false;
}

defaultproperties
{
     ActionString="EnterVehicle"
}
