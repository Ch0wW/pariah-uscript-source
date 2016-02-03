class SpecialBotCombatScene extends SinglePlayerTriggers
	placeable;


var(Events) const editconst Name hStartScene;
var(Events) const editconst Name hEndScene;

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
	SinglePlayer(Level.Game).bSpecialBotCombatScene=true;
}

function EndScene()
{
	SinglePlayer(Level.Game).bSpecialBotCombatScene=false;
}

defaultproperties
{
     hStartScene="StartScene"
     hEndScene="EndScene"
     bHasHandlers=True
}
