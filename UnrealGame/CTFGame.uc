//=============================================================================
// CTFGame.
//=============================================================================
class CTFGame extends TeamGame
	config;

var sound CaptureSound[2];
var sound ReturnSounds[2];
var sound DroppedSounds[2];

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
	{
		if ( !CTFSquadAI(Bot(B).Squad).FriendlyFlag.bHome && (Numbots <= 16) )
			return FRand();
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	}
	return FRand();
}

function SetTeamStuff()
{
	local CTFFlag F;

    Super.SetTeamStuff();

	// associate flags with teams
	ForEach AllActors(Class'CTFFlag',F)
	{
		F.Team = Teams[F.TeamNum];
		F.Team.Flag = F;
		CTFTeamAI(F.Team.AI).FriendlyFlag = F;
		if ( F.TeamNum == 0 )
			CTFTeamAI(Teams[1].AI).EnemyFlag = F;
		else
			CTFTeamAI(Teams[0].AI).EnemyFlag = F;
	}
}

function Logout(Controller Exiting)
{
	if ( Exiting.PlayerReplicationInfo.HasFlag != None )
		CTFFlag(Exiting.PlayerReplicationInfo.HasFlag).SendHome();	
	Super.Logout(Exiting);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local CTFFlag BestFlag;
	local Controller P, NextC;
	local PlayerController Player;
    local float EndTimeDelay;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( Teams[1].Score == Teams[0].Score )
	{
		BroadcastLocalizedMessage(GameMessageClass, 0);
		return false;
	}		

	BestFlag = CTFTeamAI(UnrealTeamInfo(Winner.Team).AI).FriendlyFlag;
	GameReplicationInfo.Winner = Winner.Team;

    EndTimeDelay = 3.0;

    if( IsOnConsole() ) // sjs
        EndTimeDelay = 15.0;

	EndTime = Level.TimeSeconds + EndTimeDelay;
	for ( P=Level.ControllerList; P!=None; P=NextC )
	{
	    NextC = P.nextController;
		P.GotoState('GameEnded');
		Player = PlayerController(P);
		if ( Player != None )
		{
			Player.ClientSetBehindView(true);
			Player.SetViewTarget(BestFlag.HomeBase);
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Winner.Team));
			Player.ClientGameEnded();
		}
	}
	BestFlag.HomeBase.bHidden = false;
	BestFlag.bHidden = true;

	return true;
}

function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local Controller TeamMate;
	local float Dist,oppDist;
	

	if ( Scorer.PlayerReplicationInfo.Team == theFlag.Team )
	{
		Dist = vsize(TheFlag.location - TheFlag.HomeBase.Location);
		
		if (TheFlag.TeamNum==0)
			oppDist = vsize(TheFlag.Location - CTFFlag(Teams[1].Flag).HomeBase.Location);
		else
  			oppDist = vsize(TheFlag.Location - CTFFlag(Teams[0].Flag).HomeBase.Location); 
	
		if (GameStats!=None)
			GameStats.GameEvent("flag_returned",""$theFlag.Team.TeamIndex,Scorer.PlayerReplicationInfo);

		BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag );

		for ( TeamMate=Level.ControllerList; TeamMate!=None; TeamMate=TeamMate.NextController )
		{
			if ( TeamMate.IsA('PlayerController') )
				PlayerController(TeamMate).PlayAnnouncement(ReturnSounds[theFlag.Team.TeamIndex],2,true); // jij
		}
		
		if (Dist>1024)
		{
			// figure out who's closer
				
			if (Dist<=oppDist)	// In your team's zone
			{
				Scorer.PlayerReplicationInfo.Score += 3;
				
				if (GameStats!=None)
					GameStats.ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_ret_friendly");
			}
			else
			{
				Scorer.PlayerReplicationInfo.Score += 3;
				
				if (GameStats!=None)
					GameStats.ScoreEvent(Scorer.PlayerReplicationInfo,3,"flag_ret_enemy");
				
				/*if (oppDist<=1024)	// Denial
				{
  					Scorer.PlayerReplicationInfo.Score += 2;
					if (GameStats!=None)
						GameStats.ScoreEvent(Scorer.PlayerReplicationInfo,2,"flag_denial");
				}*/
					
			}					
		} 
		
		return;
	}

	// Figure out Team based scoring.

	/*if (TheFlag.FirstTouch!=None)	// Original Player to Touch it gets 5
	{
		if (GameStats!=None)
			GameStats.ScoreEvent(TheFlag.FirstTouch.PlayerReplicationInfo,5,"flag_cap_1st_touch");

		TheFlag.FirstTouch.PlayerReplicationInfo.Score += 5;
	}*/
		
	// Guy who caps gets 5
	
	Scorer.PlayerReplicationInfo.Score += 5;
    if (Scorer.PlayerReplicationInfo.Stats != None)
        Scorer.PlayerReplicationInfo.Stats.GoalScores++;

	if (GameStats!=None)
		GameStats.ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_cap_final");

    if (TheFlag.Assists[0]!=None && TheFlag.Assists[0]!=Scorer)
    {
        TheFlag.Assists[0].PlayerReplicationInfo.Score += 3;

        if (TheFlag.Assists[0].PlayerReplicationInfo.Stats != None)
            TheFlag.Assists[0].PlayerReplicationInfo.Stats.Assists++;
    }

	// Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points 

	/*numtouch=0;	
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None && TheFlag.Assists[i]!=Scorer)
			numtouch = numtouch + 1.0;
	}
	
	ppp = 20.0 / numtouch;
	if (ppp<1.0)
		ppp = 1.0;

	if (ppp>5.0)
		ppp = 5.0;
		
	for (i=0;i<TheFlag.Assists.length;i++)
	{
		if (TheFlag.Assists[i]!=None && TheFlag.Assists[i]!=Scorer)
		{
			if (GameStats!=None)
				GameStats.ScoreEvent(TheFlag.Assists[i].PlayerReplicationInfo,ppp,"flag_cap_assist");

			TheFlag.Assists[i].PlayerReplicationInfo.Score += int(ppp);
		}
	}*/

	// Apply the team score

	Scorer.PlayerReplicationInfo.Team.Score += 1.0;
	if (GameStats!=None)
		GameStats.TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex,1,"flag_cap");	
	
	for ( TeamMate=Level.ControllerList; TeamMate!=None; TeamMate=TeamMate.NextController )
	{
		if ( TeamMate.IsA('PlayerController') )
			PlayerController(TeamMate).PlayAnnouncement(CaptureSound[Scorer.PlayerReplicationInfo.Team.TeamIndex],2,true);
	}

	if (GameStats!=None)
		GameStats.GameEvent("flag_captured",""$theflag.Team.TeamIndex,Scorer.PlayerReplicationInfo);
	
	BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag );
	TriggerEvent(theFlag.HomeBase.Event,theFlag.HomeBase, Scorer.Pawn);

	CheckScore(Scorer.PlayerReplicationInfo);

    if ( bOverTime )
    {
		EndGame(Scorer.PlayerReplicationInfo,"timelimit");
    }
}

function DiscardInventory( Pawn Other )
{
    local Controller TeamMate; // jij

	if ( Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.HasFlag != None)
	{
		CTFFlag(Other.PlayerReplicationInfo.HasFlag).Drop(0.5 * Other.Velocity);

		for ( TeamMate=Level.ControllerList; TeamMate!=None; TeamMate=TeamMate.NextController )
	    {
			if ( TeamMate.IsA('PlayerController') )
				PlayerController(TeamMate).PlayAnnouncement(DroppedSounds[Other.PlayerReplicationInfo.Team.TeamIndex],2,true);
	    }
	}
	
	Super.DiscardInventory(Other);
	
}


function bool CriticalPlayer(Controller Other)
{
	
	if (Other.PlayerReplicationInfo.HasFlag != None)
		return true;
	
	return Super.CriticalPlayer(Other);
}
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional out int bPlayHitEffects  )
{
	/*if ( (instigatedBy != None) && injured.IsPlayerPawn() && instigatedBy.IsPlayerPawn()
		&& (injured.PlayerReplicationInfo.Team != instigatedBy.PlayerReplicationInfo.Team)
		&& !injured.IsHumanControlled() 
		&& ((injured.health < 35) || (injured.PlayerReplicationInfo.HasFlag != None)) )
			injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM', 0.25);
    */
	return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

function string FindTeamDesignation(actor A)	// Should be subclassed in various team games
{
	local float dist[2];		// Holds the distances

	dist[0] = vsize(a.location - GameReplicationInfo.Teams[0].Flag.Location);
	dist[1] = vsize(a.location - GameReplicationInfo.Teams[1].Flag.Location);

	if (dist[0] < dist[1])
	{
		return GameReplicationInfo.Teams[0].RetrivePlayerName();
	}
	else
	{	
		return GameReplicationInfo.Teams[1].RetrivePlayerName();
	}
	
}

defaultproperties
{
     TeamAIType(0)=Class'UnrealGame.CTFTeamAI'
     TeamAIType(1)=Class'UnrealGame.CTFTeamAI'
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     bScoreVictimsTarget=True
     BotNames(0)="Stubbs"
     BotNames(1)="Stockton"
     BotNames(2)="Raphael"
     BotNames(3)="Jahal"
     BotNames(4)="Noah"
     BotNames(5)="Greo"
     BotNames(6)="Mick"
     BotNames(7)="Howie"
     BotNames(8)="Tonklin"
     BotNames(9)="Jones"
     BotNames(10)="Eddy"
     BotNames(11)="Garren"
     BotNames(12)="Mitchel"
     BotNames(13)="Jayton"
     BotNames(14)="Jared"
     BotNames(15)="Aaron"
     BotNames(16)="Lance"
     BotNames(17)="Morgan"
     MaxPlayersOnDedicated=10
     MaxPlayersOnListen=6
     GoalScore=5
     MaxLives=0
     MapPrefix="CTF"
     BeaconName="CTF"
     GameName="Capture the Flag"
}
