class AssaultTeamAI extends TeamAI;

var Assault	AssaultGameInfo;

function GameObjective FindInitialLastObjective(UnrealTeamInfo T)
{
	local int neutralIdx;
	//Find and set the LastSquadObjective

	neutralIdx = AssaultGameInfo.NeutralSpawn.OrderIndex;
	if(T.TeamIndex == 0)
	{
		if(neutralIdx != 0 )
			return AssaultGameInfo.AssaultSpawns[neutralIdx - 1];
	}
	else if(T.TeamIndex == 1)
	{
		if(neutralIdx != AssaultGameInfo.NumSpawns-1 )
			return AssaultGameInfo.AssaultSpawns[neutralIdx + 1];
	}
	
	return None;
}

function SetObjectiveLists()
{
	local GameObjective O;

	ForEach AllActors(class'GameObjective',O)
	{	if ( O.bFirstObjective )
		{
			Objectives = O;
			break;
		}
	}

}

function GameObjective WhiteBase()
{
	
	local int i;

	for(i=0;i<AssaultGameInfo.WhiteAssaultObjectives.Length;i++)
	{
		if(AssaultGameInfo.WhiteAssaultObjectives[i].bDestroyed==False)
		{
			return AssaultGameInfo.WhiteAssaultObjectives[i];
		}
	}
	return AssaultGameInfo.WhiteAssaultObjectives[0];
}

function GameObjective BlackBase()
{
	local int i;

	for(i=0;i<AssaultGameInfo.BlackAssaultObjectives.Length;i++)
	{
		if(AssaultGameInfo.BlackAssaultObjectives[i].bDestroyed==False)
		{
			return AssaultGameInfo.BlackAssaultObjectives[i];
		}
	}
	return AssaultGameInfo.BlackAssaultObjectives[0];
}

function GameObjective AttackPoint()
{
	local AssaultSpawn assSpawn;

	assSpawn = AssaultGameInfo.NeutralSpawn;
	//is it a base?
	if(assSpawn.OrderIndex == 0)
	{
		return WhiteBase();
	}
	else if(assSpawn.OrderIndex == AssaultGameInfo.NumSpawns -1)
	{
		return BlackBase();
	}
	return assSpawn;
}

function GameObjective GetPriorityAttackObjective()
{
	local GameObjective gameObj;
	gameObj= AttackPoint();
	//log("GetPriorityAttackObjective: "@gameObj);
	return gameObj;
}

//Hmm, why would you ever leave guys behind to defend the front?  The neutral point decides the game
function GameObjective GetLeastDefendedObjective()
{
	local GameObjective gameObj;
	gameObj= AttackPoint();
	//log("GetLeastDefendedObjective: "@gameObj);
	return gameObj;
}

//We don't really have a "defense point"
function bool PutOnDefense(Bot B)
{
	PutOnOffense(B);
	return true;
	
}

function bool StayFreelance(SquadAI S)
{
/*	if ( (S.SquadObjective != None) 
		&& ((S.SquadObjective.DefenderTeamIndex != Team.TeamIndex) || DominationPending()) )
		return false;
	
	return (  (S.SquadObjective == None) || (S.SquadObjective.DefenderTeamIndex == Team.TeamIndex) ); 
*/
	return true;
}		

function ResetSquadObjectives()
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
	{
		FindNewObjectiveFor(S,true);
	}
}

defaultproperties
{
     OrderList(0)="ATTACK"
     SquadType=Class'VehicleGame.AssaultSquadAI'
}
