class ClassTriggerVolume extends Volume;


var() class<Pawn> TriggeringClass;
var() bool bTriggerOnlyOnce;

var bool bTriggered;

event Touch(Actor Other)
{
	if(bTriggerOnlyOnce && bTriggered) return;

    if(Other.Class == TriggeringClass)
	{
		TriggerEvent(Event, self, Pawn(Other));
		bTriggered=True;
	}
}

defaultproperties
{
     bStatic=False
}
