class SpecialTimedScene extends TimedTrigger;

var(Events) const editconst Name hStartTimer;
var(Events) const editconst Name hEndTimer;


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(RandomExtraTime != 0)
	{
		RandomExtraTime = 0;

		log("SpecialTimedScene "$self$" had RandomExtraTime, which has now been set to zero.  Please don't use random extra time with timed scenes.", 'Warning');
	}
}

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hStartTimer:
		StartTrigger(sender, instigator);
		StartScene();
		break;
	case hEndTimer:
		ForceEndTrigger(realevent);
		EndScene();
		break;
	}
}

function StartScene()
{
	local Controller c;
	local SinglePlayerController spc;
		
	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(c.IsA('SinglePlayerController'))
		{
			spc = SinglePlayerController(c);
			spc.StartTimedScene(Level.TimeSeconds, Level.TimeSeconds + TriggerTimeSeconds);
		}
	}
}

function EndScene()
{
	local Controller c;
	local SinglePlayerController spc;

	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(c.IsA('SinglePlayerController'))
		{
			spc = SinglePlayerController(c);

			spc.EndTimedScene();
		}
	}
}


function ForceEndTrigger( name Event )
{
	if(DebugLogging)
		log("SpecialTimedScene "$self$" was forced to end by event "$Event$", resetting.");
	
	Reset();

}

function EndTrigger( Actor Other, Pawn EventInstigator )
{
	if(!Untriggerable) 
	{
		if(DebugLogging) log("SpecialTimedScene "$self$"  can't be untriggered, Untriggerable is not set to true.");
		return;
	}
	
	if(DebugLogging)
		log("SpecialTimedScene "$self$" was UnTriggered by Tag "$Tag$", resetting.");

	EndScene();

	Reset();

}


event Timer()
{
	if(DebugLogging)
		log("Timed Trigger "$self$" timer event.  Triggering Event "$Event);
	TriggerEvent(Event, self, None);
	
	DisableTrigger();
	bRunning=False;

	EndScene();	
}

defaultproperties
{
     hStartTimer="StartTimer"
     hEndTimer="EndTimer"
     bHasHandlers=True
}
