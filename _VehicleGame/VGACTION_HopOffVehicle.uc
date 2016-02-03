class VGACTION_HopOffVehicle extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local VGPawn p;
	
	if( C.Pawn == None || VGPawn(C.Pawn) == None)
	{ 
		warn("VGACTION EnterVehicle called on non VGPawn");
		C.bBroken = true;
	}
    p = VGPawn(C.Pawn);

    p.RiddenVehicle.EndRide(p);
	C.bIsRidingVehicle=False;
	p.SetPhysics(PHYS_Falling);
	p.SetBase(None);

    return false;
}

defaultproperties
{
     ActionString="HopOffVehicle"
}
