class TimedTrigger extends SinglePlayerTriggers;

#exec Texture Import File=Textures\ClockA.pcx Name=TimedIcon Mips=Off MASKED=1

var() int TriggerTimeSeconds;
var() float RandomExtraTime;
var() bool CanRepeat;
var() bool Interruptable; 
var() bool Untriggerable;

var bool bRunning;


function Reset()
{
	bRunning=False;
	SetTimer(0,False);
}



function Trigger( actor Other, pawn EventInstigator )
{
	StartTrigger(Other, EventInstigator);
}

function StartTrigger( actor Other, pawn EventInstigator )
{
	local float extratime;
	if(bRunning && !Interruptable)
	{
		//if(DebugLogging)
		//	log("Timed Trigger "$self$" was Triggered by Tag "$Tag$" but is running and not interruptable");
		return;
	}

	extratime = frand()*RandomExtraTime;

	if(DebugLogging)
		log("Timed Trigger "$self$" was Triggered by Tag "$Tag$" setting timer to "$TriggerTimeSeconds+ExtraTime$" seconds");

	bRunning=True;
	SetTimer(TriggerTimeSeconds + extratime, False);

}


function UnTrigger( actor Other, pawn EventInstigator)
{
	EndTrigger(Other, EventInstigator);
}

function EndTrigger( Actor Other, Pawn EventInstigator )
{
	if(!Untriggerable) 
	{
		if(DebugLogging) log("Timed Trigger "$self$"  can't be untriggered, Untriggerable is not set to true.");
		return;
	}
	
	if(DebugLogging)
		log("Timed Trigger "$self$" was UnTriggered by Tag "$Tag$", resetting.");
	
	Reset();

}

event Timer()
{
	if(DebugLogging)
		log("Timed Trigger "$self$" timer event.  Triggering Event "$Event);
	TriggerEvent(Event, self, None);
	
	if(!CanRepeat)
	{
		DisableTrigger();
	}

	bRunning=False;
}


//===================
// Default Properties
//===================

defaultproperties
{
     Texture=Texture'PariahSP.TimedIcon'
}
