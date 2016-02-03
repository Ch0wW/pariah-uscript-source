class SpecialVehicleScene extends SinglePlayerTriggers
	placeable;


var(Events) const editconst Name hStartScene;
var(Events) const editconst Name hEndScene;

var() bool bKillPlayerOnFlip;

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hStartScene:
		StartScene();
		break;
	case hEndScene:
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
			spc.bInSpecialVehicleScene = true;
			spc.bkillonflip = bKillPlayerOnFlip;

            spc.bStartInVehicle = true;
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

			spc.bInSpecialVehicleScene = false;
			spc.bkillonflip = false;
		}
	}
}

defaultproperties
{
     hStartScene="StartScene"
     hEndScene="EndScene"
     bKillPlayerOnFlip=True
     bHasHandlers=True
}
