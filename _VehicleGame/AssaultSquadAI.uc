class AssaultSquadAI extends SquadAI;

//Override to set a false first objective so it will become the previous objective
function Initialize(UnrealTeamInfo T, GameObjective O, Controller C)
{
	SquadObjective = AssaultTeamAI(T.AI).FindInitialLastObjective(T);
	Super.Initialize(T, O, C);
}

function bool ShouldDefend(GameObjective O)
{
	local AssaultSpawn aSpawn;
	if(SquadObjective.DefenderTeamIndex == Team.TeamIndex) 
		return true;

	aSpawn = AssaultSpawn(SquadObjective);
	if((aSpawn != None) && (aSpawn.CapturePRI != None) && (Team.TeamIndex == aSpawn.CapturePRI.Team.TeamIndex))
		return true;

	return false;

}
function name GetOrders()
{
	local name NewOrders;
	
	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && AssaultTeamAI(Team.AI).StayFreelance(self) )
		NewOrders = 'Freelance';
	else if ( (SquadObjective != None) && ShouldDefend(SquadObjective))
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
		CurrentOrders = NewOrders;
	return CurrentOrders;
}

defaultproperties
{
}
