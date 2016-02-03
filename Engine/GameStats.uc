// ====================================================================
//  Class:  Engine.GameStats
//  Parent: Engine.Info
//
//  the GameStats object is used to send individual stat events to the
//  stats server.  Each game should spawn a GameStats object if it 
//  wishes to have stat logging.
//
// ====================================================================

class GameStats extends Info
		Native;

var FileLog TempLog;		
var GameReplicationInfo GRI;

native final function string GetStatsIdentifier( Controller C );
native final function string GetMapFileName();	// Returns the name of the current map

event PostBeginPlay()
{
	Super.PostBeginPlay();

	TempLog = spawn(class 'FileLog');
	if (TempLog!=None)
	{
		TempLog.OpenLog("Stats");
		log("Output Game stats to: STATS.TXT");
	}
	else
	{
		log("Could not spawn Temporary Stats log");
		Destroy();
	}
	
}

event Destroyed()
{

	if (TempLog!=None) 
		TempLog.Destroy();
	
	Super.Destroyed();	
}

function Logf(string LogString)
{
	If (TempLog!=None)
		TempLog.Logf(LogString);
}

function string TimeStamp()
{
	return ""$Level.TimeSeconds;
}

function string Header()
{

	// Add code to get the Server ID from the GRI
	
	return "<GameID>"$chr(9)$TimeStamp()$chr(9);	

}

function String FullTimeDate()
{
	return ""$Level.Year$"."$Level.Month$"."$Level.Day$"@"$Level.Hour$":"$Level.Minute$":"$Level.Second;
} 

// Stat Logging functions

function NewGame()
{
	local string out,tmp;
	local int i;
	local mutator MyMutie;
	local GameRules MyRules;

	GRI = Level.Game.GameReplicationInfo;
	out = Header()$"NewGame"$chr(9);
	out = out$FullTimeDate()$Chr(9);
	out = out$GetMapFileName()$Chr(9);
	out = out$Level.Title$chr(9);
	out = out$Level.Author$chr(9);
	out = out$Level.Game.Class$chr(9);
	out = out$Level.Game.GameName$chr(9);
	
	tmp = "";
	i = 0;
	foreach AllActors(class'Mutator',MyMutie)
	{
		if (tmp!="")
			tmp=tmp$"|"$MyMutie.Class;
		else
	 		tmp=""$MyMutie.Class;

		i++;
	}		

	if (i>0)
		out = out$"Mutators="$tmp$chr(9);
	
	tmp = "";
	i = 0;
	foreach AllActors(class 'GameRules',MyRules)
	{
		if (tmp!="")
			tmp=tmp$"|"$MyRules.Class;
		else
			tmp=""$MyRules.Class;
			
		i++;
	}		
	
	if (i>0)
		out = out$"Rules="$tmp$chr(9);


	//!! 
	//out=out$"GameRules="$level.Game.GetRules();
	Logf(Out);	// Store it
				
}		

function StartGame()
{
	logf(Header()$"StartGame");
}

// Send stats for the end of the game

function EndGame(string Reason)
{
	local string out;
	local int i,j;
	local GameReplicationInfo GRI;
	local array<PlayerReplicationInfo> PRIs;
	local PlayerReplicationInfo PRI,t;

	out = Header()$"EndGame"$Chr(9)$Reason;

	GRI = Level.Game.GameReplicationInfo;

	// Quick cascade sort.
	
	for (i=0;i<GRI.PRIArray.Length;i++)
	{
		PRIs.Length = PRIs.Length+1;
		PRI = GRI.PRIArray[i];
		for (j=0;j<Pris.Length-1;j++)
		{
			if (PRIs[j].Score < PRI.Score)
			{
				t = PRIs[j];
				PRIs[j] = PRI;
				PRI = t;
			}
		}
		PRIs[j] = PRI;
	}
		
	
	Out = out$chr(9)$"Scoreboard";		
	for (i=0;i<PRIs.Length;i++)
	{
		out= out$chr(9)$PRIs[i].RetrivePlayerName()$Chr(9)$PRIs[i].Team.TeamIndex$Chr(9)$PRIs[i].Score;
	}
		
	logf(Out);
}	

// Connect Events get fired every time a player connects or leaves from a server

function ConnectEvent(string ConEvent, PlayerReplicationInfo Who)
{
	logf(Header()$ConEvent$Chr(9)$Controller(Who.Owner).PlayerNum$Chr(9)$Who.RetrivePlayerName()$Chr(9)$GetStatsIdentifier(Controller(Who.Owner)));
}

// Scoring Events occur when a player's score changes

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	logf(Header()$"Score"$chr(9)$Who.RetrivePlayerName()$chr(9)$Points$chr(9)$Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	logf(Header()$"TeamScore"$Chr(9)$Team$Chr(9)$Points$Chr(9)$Desc);
}
// Kill Events occur when a player is killed

function KillEvent(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local string out;
	
	out = Header()$"Kill"$Chr(9);
	
	if (Killer!=None)
		out = out$Killer.RetrivePlayerName()$chr(9)$GetItemName(string(Controller(Killer.Owner).Pawn.Weapon))$Chr(9);
	else
		out = out$"None"$chr(9)$"None"$Chr(9);
		
	out = out$Victim.RetrivePlayerName()$chr(9)$GetItemName(string(Controller(Victim.Owner).Pawn.Weapon))$Chr(9);
	out = out$GetItemName(string(Damage))$Chr(9);

	if ( PlayerController(Victim.Owner)!= None && PlayerController(Victim.Owner).bIsTyping)
		out = out$"Typing";
	else
		out = out$"None";
	
	
	logf(Out);
}

// Special Events are everything else regarding the player

function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	Logf( Header()$"PSpecial"$chr(9)$Who.RetrivePlayerName()$chr(9)$Desc );
}

// Special events regarding the game

function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local string out;
	if (Who != None)
		out = Who.RetrivePlayerName()$Chr(9);
	else
		Out = "None"$chr(9);
		
	logf( Header()$"GSpecial"$chr(9)$GEvent$Chr(9)$Out$Desc);
}

defaultproperties
{
}
