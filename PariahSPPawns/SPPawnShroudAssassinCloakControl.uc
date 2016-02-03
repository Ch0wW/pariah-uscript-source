class SPPawnShroudAssassinCloakControl extends SinglePlayerTriggers
	placeable;

var(Events) const editconst Name hCloakingOn;
var(Events) const editconst Name hCloakingOff;
var(Events) const editconst Name hCloakingAIControlled;

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hCloakingOn:
		UpdateCloaking( ACM_CloakingOn );
		break;
	case hCloakingOff:
		UpdateCloaking( ACM_CloakingOff );
		break;
	case hCloakingAIControlled:
		UpdateCloaking( ACM_CloakingAI );
		break;
	}
}

function UpdateCloaking( SinglePlayer.AssassinCloakMode mode )
{
	local SPPawnShroudAssassin	 assassin;

	foreach AllActors( class'SPPawnShroudAssassin', assassin )
	{
		assassin.CloakControl( mode );
	}

	// change single player cloak mode so any created assassins pick it up
	//
	SinglePlayer(Level.Game).AssassinCloakingMode = mode;
}

defaultproperties
{
     hCloakingOn="CloakOn"
     hCloakingOff="CloakOff"
     hCloakingAIControlled="CloakAI"
     bHasHandlers=True
}
