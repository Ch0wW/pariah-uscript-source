/*
	TurretLookoutVolume
	
	Desc: Any type of pawn that enters it will get this volume to send an event
		  of an editable name. 
*/

class TurretLookoutVolume extends PhysicsVolume;

var(EventGroup) name InEvent;
var(EventGroup) name OutEvent;

simulated event PawnEnteredVolume( Pawn P )
{
	//log("PawnEnteredVolume");
	Super.PawnEnteredVolume( P );
	TriggerEvent(InEvent, self, P );
}

simulated event PawnLeavingVolume( Pawn P )
{
	//log("PawnLeavingVolume");
	Super.PawnLeavingVolume( P );
	TriggerEvent(OutEvent, self, P );
}

defaultproperties
{
     InEvent="PawnInTurretXVolume"
     OutEvent="PawnOutOfTurretXVolume"
}
