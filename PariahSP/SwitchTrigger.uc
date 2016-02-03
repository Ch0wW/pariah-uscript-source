class SwitchTrigger extends SinglePlayerTriggers;

#exec Texture Import File=Textures\switchtrigger.pcx Name=SwitchTriggerIcon Mips=Off MASKED=1


var() Array<Name> OnEvents;
var() Array<Name> OffEvents;

var(Events) const editconst Name hToggle,hSetOn,hSetOff,hDoEvents;

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent )
{
	switch(handler)
	{
	case hToggle:
		Toggle();
		break;
	case hSetOn:
		if(DebugLogging)
			log("Trigger "$self$"has been Set to On");
		GotoState('On');
		break;
	case hSetOff:
		if(DebugLogging)
			log("Trigger "$self$"has been Set to Off");
		GotoState('Off');
		break;
	case hDoEvents:
		DoEvents( sender, instigator );
		break;
	}
	
}

function Toggle();
function DoEvents(Actor sender, Pawn instigator);

Auto State On
{
	function Toggle()
	{
		if(DebugLogging)
			log("Trigger "$self$"has been Toggled to Off");
		GotoState('Off');
	}

	function DoEvents( Actor sender, Pawn instigator )
	{
		local int i;
		if(DebugLogging)
			log("Trigger "$self$"is doing OnEvents");

		for(i=0;i<OnEvents.Length;i++)
		{
			if(OnEvents[i]!='')
			{
				if(DebugLogging)
					log("    Calling event "$OnEvents[i]);

				TriggerEvent(OnEvents[i], sender, instigator);
			}
		}
	}
}


State Off
{

	function Toggle()
	{
		if(DebugLogging)
			log("Trigger "$self$"has been Toggled to On");
		GotoState('On');
	}

	function DoEvents( Actor sender, Pawn instigator )
	{
		local int i;

		if(DebugLogging)
			log("Trigger "$self$"is doing OffEvents");

		for(i=0;i<OffEvents.Length;i++)
		{
			if(OnEvents[i]!='')
			{
				if(DebugLogging)
					log("    Calling event "$OffEvents[i]);

				TriggerEvent(OffEvents[i], sender, instigator);
			}
		}
	}
}

defaultproperties
{
     hToggle="Toggle"
     hSetOn="SETON"
     hSetOff="SETOFF"
     hDoEvents="DoEvents"
     DebugLogging=True
     Texture=Texture'PariahSP.SwitchTriggerIcon'
     bHasHandlers=True
}
