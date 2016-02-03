class LevelGameRules extends Info;

var() bool bOnlyObjectivesWin;	// game only won by satisfying level objectives
var() int	GoalScore; 
var() int	TimeLimit;			// time limit in minutes
var() int MaxLives;				// max number of lives for match
var() int Rounds;				// number of rounds to play
var() int RecommendedNumPlayers[2];	// number of players recommended for team (bots will fill out in single player)
var() string DefaultRosters[2];
var() string DefaultDMRoster;
var   UnrealTeamInfo Rosters[2];
var   DMRoster DMRoster;

function PreBeginPlay()
{
}

function int GetNumRounds(int DefaultValue)
{
	if ( Rounds < 0 )
		return DefaultValue;

	return Rounds;
}

function int GetGoalScore(int DefaultValue)
{
	if ( GoalScore < 0 )
		return DefaultValue;

	return GoalScore;
}

function int GetTimeLimit(int DefaultValue)
{
	if ( TimeLimit < 0 )
		return DefaultValue;

	return TimeLimit;
}

function int GetMaxLives(int DefaultValue)
{
	if ( MaxLives < 0 )
		return DefaultValue;

	return MaxLives;
}

function UnrealTeamInfo GetRoster(int i)
{
	local UnrealTeamInfo R;

	if ( Rosters[i] == None )
	{
		// first look for Roster in level
		ForEach AllActors(class'UnrealTeamInfo', R)
		{
			if ( R.TeamAlliance == i )
			{
				if ( Rosters[i] == None )
					Rosters[i] = R;
				else
				{
					warn(R$" is duplicate roster");
					R.Destroy();
				}
			}
		}

		// if not found, spawn default roster
		if ( Rosters[i] == None )
		{
			assert(DefaultRosters[i]!="");
			Rosters[i] = spawn(class<UnrealTeamInfo>(DynamicLoadObject(DefaultRosters[i],class'Class')));
		}
	}
	Rosters[i].TeamIndex = i;
	Rosters[i].DesiredTeamSize = RecommendedNumPlayers[i];
	return Rosters[i];
}

function DMRoster GetDMRoster()
{
	if ( DMRoster == None )
	{
		DMRoster = DMRoster(Rosters[0]);
		if ( DMRoster == None )
		{
			assert(DefaultDMRoster!="");
			DMRoster = spawn(class<DMRoster>(DynamicLoadObject(DefaultDMRoster,class'Class')));
		}
	}
	return DMRoster;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	Level.Game.EndGame(EventInstigator.PlayerReplicationInfo,"triggered");
} 

function CleanRosters()
{
    if (DMRoster != None)
        DMRoster.Cleanup();
    if (Rosters[0] != None)
        Rosters[0].Cleanup();
    if (Rosters[1] != None)
        Rosters[1].Cleanup();
}

defaultproperties
{
     GoalScore=-1
     TimeLimit=-1
     MaxLives=-1
     Rounds=-1
     RecommendedNumPlayers(0)=4
     RecommendedNumPlayers(1)=4
     bOnlyObjectivesWin=True
     Event="EndGame"
}
