//=============================================================================
// SubActionTrigger:
//
// Fires off a trigger.
//=============================================================================
class SubActionTriggerActor extends MatSubAction
	native;

var(TriggerActor)	name	EventName;		// The event to trigger
var(TriggerActor)	name  SecondaryEvent;  //event the actor might use

defaultproperties
{
     Icon=Texture'Engine.SubActionTrigger'
     Desc="TriggerActor"
}
