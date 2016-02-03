class MutWECPoints extends Mutator;

function PostBeginPlay()
{
	local WECPointRules G;
	
	Super.PostBeginPlay();
	G = spawn(class'WECPointRules');
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else    
		Level.Game.GameRulesModifiers.AddGameRules(G);
}	
	

defaultproperties
{
     SinglePlayerValue=1.000000
     FriendlyName="WECPoints"
     Description="Get extra points for killing WECed up fools."
     TeamBias=ETB_All
     OnByDefault=True
}
