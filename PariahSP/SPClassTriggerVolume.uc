class SPClassTriggerVolume extends ClassTriggerVolume;

// single player version of ClassTriggerVolume which can also detect if the TriggerClass is 
// driving or riding a vehicle that enters the volume

var() bool bCheckVehicleDriver;
var() bool bCheckVehiclePassengers;

event Touch(Actor Other)
{
	local VGVehicle	vehicle;
	local int i;

	if( bTriggerOnlyOnce && bTriggered )
	{
		return;
	}

    if( Other.Class == TriggeringClass )
	{
		TriggerEvent(Event, self, Pawn(Other));
		bTriggered=True;
	}
	else if ( bCheckVehicleDriver || bCheckVehiclePassengers )
	{
		vehicle = VGVehicle( Other );
		if ( vehicle != None )
		{
			if ( bCheckVehicleDriver && vehicle.Driver != None && vehicle.Driver.Class == TriggeringClass )
			{
				TriggerEvent(Event, self, vehicle.Driver );
				bTriggered=True;
			}
			else if ( bCheckVehiclePassengers )
			{
				for( i=0; i < vehicle.MAXPASSENGERS; i++)
				{
					if( vehicle.Passengers[i] != None && vehicle.Passengers[i].Class == TriggeringClass )
					{
						TriggerEvent(Event, self, vehicle.Passengers[i]);
						bTriggered=True;
						break;
					}
				}
			}
		}
	}
}

defaultproperties
{
     bCheckVehicleDriver=True
     bCheckVehiclePassengers=True
}
