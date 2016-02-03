class TagLocatorScene extends SinglePlayerTriggers
	placeable;


var(Events) const editconst Name hEnable;
var(Events) const editconst Name hDisable;


var() name LocatePawnTag;

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hEnable:
		EnableLocator();
		break;
	case hDisable:
		DisableLocator();
		break;
	}
}

function EnableLocator()
{
	local Controller c;
	local SinglePlayerController spc;
	local actor p;
		
	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(c.IsA('SinglePlayerController'))
		{
			spc = SinglePlayerController(c);
			spc.bEnableTagLocator = true;
		}
	}

	//now find and set the locator pawn
						
	ForEach	AllActors(class'Actor', p, LocatePawnTag)
	{
		spc.LocatorPawn = p;
		break;
	}
}

function DisableLocator()
{
	local Controller c;
	local SinglePlayerController spc;

	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(c.IsA('SinglePlayerController'))
		{
			spc = SinglePlayerController(c);
			spc.bEnableTagLocator = false;
			spc.LocatorPawn = None;
		}
	}
}

defaultproperties
{
     hEnable="EnableLocator"
     hDisable="DisableLocator"
     bHasHandlers=True
}
