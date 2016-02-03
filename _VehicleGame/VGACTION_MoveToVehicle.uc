class VGACTION_MoveToVehicle extends LatentScriptedAction;

var(Action) name VehicleTag;	// tag of destination - if none, then use the ScriptedSequence

enum ERole
{
	R_Driver,
	R_Passenger
};

var(Action) ERole Role;

var EntryPoint EntrySpot;

function bool MoveToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	
	if ( EntrySpot != None )
	{
		return EntrySpot;
	}

	if( !InitEntrySpotForRole(C) )
	{
		warn("Vehicle cannot accomodate this pawn");
		return None;
	}

	return EntrySpot;
}

function bool InitEntrySpotForRole(ScriptedController C)
{
	local EntryPoint ep;
	local VGVehicle veh;
	
	if ( VehicleTag == '' )
	{
		warn("No VehicleTag set!");
		return false;
	}

	ForEach C.AllActors(class'VGVehicle',veh,VehicleTag)
		break;

	if(veh == None)
	{
		warn("No Vehicle for tag:"@VehicleTag);
		return false;
	}
	else
	{
		VGPawn(C.Pawn).PotentialVehicle = veh;
	}

	switch(Role)
	{
	case R_Driver:
		veh.GetDriverEntryPoint(ep);
		break;
	case R_Passenger:
		veh.GetPassengerEntryPoint(ep);
		break;
	}

	if( ep == None)
		return false;
	
	EntrySpot = ep;
	return true;
}

function string GetActionString()
{	
	switch(Role)
	{
	case R_Driver:
		return ActionString@"Driver";
	case R_Passenger:
		return ActionString@"Passenger";
	}
}

defaultproperties
{
     ActionString="Move to vehicle as"
     bValidForTrigger=False
}
