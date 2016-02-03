/**
 * Entry Point
 * Spawned by the VGACTION_MoveToVehicle to mark where a bot should stand to get in a vehicle
**/

class EntryPoint extends Triggers
	notplaceable
	native;

event Touch( Actor Other )
{
    if(Pawn(Other) != None && Pawn(Other).Controller != None)
    {
        Pawn(Other).Controller.Touch(self);
    }
}

defaultproperties
{
     RemoteRole=ROLE_None
}
