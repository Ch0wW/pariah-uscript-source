class VGACTION_HopOnVehicle extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local VGVehicle vehToRide;
	local VGPawn p;
	
	if( C.Pawn == None || VGPawn(C.Pawn) == None)
	{ 
		warn("VGACTION EnterVehicle called on non VGPawn");
		C.bBroken = true;
	}

	p = VGPawn(C.Pawn);
	vehToRide = p.PotentialVehicle;
	 
    vehToRide.TryToRide(p, true);

	return false;
}

defaultproperties
{
     ActionString="HopOnVehicle"
}
