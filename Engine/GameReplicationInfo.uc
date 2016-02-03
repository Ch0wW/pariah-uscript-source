//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication exportstructs;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
var bool bTeamGame;							// Assigned by GameInfo.
var bool bStopCountDown;
var bool bJoinable;                         // gam -- joinable by anybody
var bool bInvitable;                        // gam -- joinable by invite
var int  RemainingTime, ElapsedTime, RemainingMinute;
var float SecondCount;
var int GoalScore;
var int TimeLimit;
var bool bOverTime;

var byte VehicleCount[2]; //cmr
var byte ObjectiveDamage[2]; //cmr


var float Difficulty; // gam

var TeamInfo Teams[2];

var() globalconfig string ServerName		"PI:Server Name:Server:255:100:Text;40";		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName			"PI:Short Server Name:Server:255:101:Text;20";  // Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName			"PI:Admin Name:Server:255:102:Text;20";		// Name of the server admin.
var() globalconfig string AdminEmail		"PI:Admin E-Mail:Server:255:103:Text;20";// Email address of the server admin.
var() globalconfig int	  ServerRegion;		// Region of the game server.



var() globalconfig string MessageOfTheDay	"PI:Message of the day:Server:255:200:Text;40";

/* AsP --- In favour of a single string
var() globalconfig string MOTDLine1			"PI:Message of the day:Server:255:200:Text;40";		// Message
var() globalconfig string MOTDLine2			"PI:line 2:Server:255:201:Text;40";	// Of
var() globalconfig string MOTDLine3			"PI:line 3:Server:255:202:Text;40";	// The
var() globalconfig string MOTDLine4			"PI:line 4:Server:255:203:Text;40";	// Day
*/

var Actor Winner;			// set by gameinfo when game ends

var() byte TeamSymbolIndex[2];

var vector FlagPos[2];
// required as bAlwaysRelevant fails when based on pawns (regardless, this will be lighter weight)
enum GameObjectState
{
    GOS_Home,
    GOS_Dropped,
    GOS_Held,
    GOS_HeldRed,
    GOS_HeldBlue,
};
var() GameObjectState GameObjStates[2];

var const int MaxTeamSymbols; //amb

// amb ---
var CoopInfo CoopInfo;
var() array<PlayerReplicationInfo> PRIArray;
var() array<Actor> PRIArrayUsers;
// --- amb

var int MatchID; // jjs - for masterserver game stats

// sjs ---
struct VoteCast
{
    var int PlayerID;
    var int VoteID;
};

struct VoteData
{
    var Name    VoteType;
    var int     VoteID;
    var int     ContextID;
    var int     NumVotes;
    var float   Expires;
};

var() transient  VoteData          PendingVotes[12];
var transient int       VoteAutoIncrement;
var transient Array<VoteCast>   VoteTally;
var transient string    MapCycle;
// --- sjs

struct EndStatData
{
    var PlayerReplicationInfo PRI;
    var byte    StatId;
    var float   StatValue;
};

var EndStatData EndStats[3];

// mc - localized PlayInfo descriptions & extra info
var private localized string GRIPropsDisplayText[5];

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		RemainingMinute, bStopCountDown, bJoinable, bInvitable, Winner, Teams, GameObjStates, bOvertime, // gam, sjs, SATAN
        EndStats, FlagPos, ObjectiveDamage, VehicleCount;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		GameName, GameClass, bTeamGame, 
		RemainingTime, ElapsedTime,MessageOfTheDay, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, GoalScore, TimeLimit, TeamSymbolIndex, MapCycle, // sjs
        CoopInfo, Difficulty; //amb
}

simulated function PostNetBeginPlay()
{
	local PlayerReplicationInfo PRI;
	
    log("GRI PostNetBeginPlay!");

	ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
		AddPRI(PRI);

    RemainingMinute = 0;
}

function int BotsOnTeam( int num )
{
	local int i,ret;

	for(i=0;i<PRIArray.Length;i++)
	{
		if(PRIArray[i].Team.TeamIndex == num && PRIArray[i].bBot)
		{
			ret++;
		}
	}

	return ret;

}

function ExpireVote( int slot )
{
    local int i;

    for( i=0; i<VoteTally.Length; i++ )
    {
        if( VoteTally[i].VoteID == PendingVotes[slot].VoteID )
        {
            VoteTally[i] = VoteTally[VoteTally.Length-1];
            VoteTally.Length = VoteTally.Length-1;
        }
    }
    PendingVotes[slot].VoteType = 'None';
}

function CallVote( PlayerController CallingPlayer, Name VoteType, int ContextID ) // sjs
{
    local int i;
    local int slot;
    local VoteCast vc;

    // look for duplicates, if found, cast a vote for this item instead of calling a duplicate vote
    for( i=0; i<ArrayCount(PendingVotes); i++ )
    {
        if( PendingVotes[i].Expires < Level.TimeSeconds )
        {
            continue;
        }
        if( PendingVotes[i].VoteType == VoteType && PendingVotes[i].ContextID == ContextID )
        {
            CastVote(CallingPlayer, PendingVotes[i].VoteID);
            return;
        }
    }

    if( CallingPlayer.PlayerReplicationInfo.NextVoteCallTime > Level.TimeSeconds )
    {
        log("CallVote: Ignoring vote spam.",'Voting');
        return;
    }

    
    slot = -1;
    for( i=0; i<ArrayCount(PendingVotes); i++ )
    {
        if( PendingVotes[i].Expires < Level.TimeSeconds )
        {
            ExpireVote(i);
            slot = i;
            break;
        }
    }
    if( slot == -1 )
    {
        log("CallVote: No space available for vote.",'Voting');
        return;
    } 

    PendingVotes[slot].VoteType = VoteType;
    PendingVotes[slot].VoteID = VoteAutoIncrement++;
    PendingVotes[slot].ContextID = ContextID;
    PendingVotes[slot].NumVotes = 1;
    PendingVotes[slot].Expires = Level.TimeSeconds + Level.Game.VoteLifeTime;
    Level.Game.BroadcastLocalizedMessage( Level.Game.GameMessageClass, 9, CallingPlayer.PlayerReplicationInfo );
    if( EvaluateVote(slot)==false )
    {
        vc.PlayerID = CallingPlayer.PlayerReplicationInfo.PlayerID;
        vc.VoteID = PendingVotes[slot].VoteID;
        VoteTally[VoteTally.Length] = vc;
    }
}

function CastVote( PlayerController CallingPlayer, int VoteID )
{
    local int i;
    local int slot;
    local VoteCast vc;

    // check the vote is still valid
    slot = -1;
    for( i=0; i<ArrayCount(PendingVotes); i++ )
    {
        if( PendingVotes[i].VoteID == VoteID )
        {
            slot = i;
            break;
        }
    }
    if( slot == -1 )
    {
        log("CastVote: VoteID not found.",'Voting');
        return;
    }

    if( PendingVotes[slot].Expires < Level.TimeSeconds )
    {
        ExpireVote(slot);
        log("CastVote: Vote has expired.",'Voting');
        return;
    }

    // check the player hasn't already cast the same vote
    for( i=0; i<VoteTally.Length; i++ )
    {
        if( VoteTally[i].VoteID == PendingVotes[slot].VoteID &&
            VoteTally[i].PlayerID == CallingPlayer.PlayerReplicationInfo.PlayerID )
        {
            log("CastVote: Player has already voted for this vote.",'Voting');
            return;
        }
    }

    PendingVotes[slot].NumVotes++;
    if( EvaluateVote(slot)==false )
    {
        vc.PlayerID = CallingPlayer.PlayerReplicationInfo.PlayerID;
        vc.VoteID = PendingVotes[slot].VoteID;
        VoteTally[VoteTally.Length] = vc;
    }
}

function bool EvaluateVote( int slot ) // return true is vote passed
{
    local int i;
    local int NumHumans;

    // count humans
    NumHumans = 0;
    for( i=0; i<PRIArray.Length; i++ )
    {
        if( !PRIArray[i].bBot )
            NumHumans++;
    }
   
    if ( PendingVotes[slot].NumVotes < 1+(NumHumans/2) )
    {
        return false;
    }

    // trigger the vote event and expire it
    Level.Game.BroadcastLocalizedMessage( Level.Game.GameMessageClass, 10 );
    Level.Game.ExecuteVote( PendingVotes[slot].VoteType, PendingVotes[slot].ContextID );
    ExpireVote(slot);
    return true;
}

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MessageOfTheDay = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(1, true);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Winner = None;
    bOverTime = false;
}

simulated function Timer()
{
	if ( Level.NetMode == NM_Client )
	{
		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( (RemainingTime > 0) && !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}
}

// amb ---
simulated function AddPRI(PlayerReplicationInfo PRI)
{
    PRIArray[PRIArray.Length] = PRI;
    NotifyPRIUsers();
}

simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] == PRI)
            break;
    }

    if (i == PRIArray.Length)
    {
        log("GameReplicationInfo::RemovePRI() pri="$PRI$" not found.", 'Error');
        return;
    }

    PRIArray.Remove(i,1);
    NotifyPRIUsers();
}

simulated function AddPRIArrayUser(Actor priUser)
{
    PRIArrayUsers[PRIArrayUsers.Length] = priUser;
}

simulated function RemovePRIArrayUser(Actor priUser)
{
    local int i;

    for (i=0; i<PRIArrayUsers.Length; i++)
    {
        if (PRIArrayUsers[i] == priUser)
            break;
    }

    if (i == PRIArrayUsers.Length)
    {
        log("GameReplicationInfo::RemovePRIArrayUser() priUser="$priUser$" not found.", 'Error');
        return;
    }

    PRIArrayUsers.Remove(i,1);
}

// send an event to registered PRI users that the array has been updated
simulated function NotifyPRIUsers()
{
    local int i;

    for (i=0; i<PRIArrayUsers.Length; i++)
    {
        if( PRIArrayUsers[i] != None )
            PRIArrayUsers[i].PRIArrayUpdated();
    }
}

simulated function GetPRIArray(out array<PlayerReplicationInfo> pris)
{
    local int i;
    local int num;

    pris.Remove(0, pris.Length);
    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] != None)
            pris[num++] = PRIArray[i];
    }
}

simulated function float ScoreBoardDelay(PlayerController pc)
{
    return 3.f;
}

simulated function SetScoreBoardVisibility(PlayerController pc, bool bVisible)
{
    if (pc.myHUD == None)
        return;
    else if( !bVisible )
        pc.myHUD.HideOverlays();
    else if( !pc.myHUD.bShowScoreBoard )
        pc.myHUD.ShowScores();
}

simulated function PostLinearize()
{
    Super.PostLinearize();
    SetTeamSymbols();
}

simulated function SetTeamSymbols()
{
    local int r1, r2;
    local GameProfile gProfile;
    local Actor A; // jij

    assert(MaxTeamSymbols >= 2);

    gProfile = GetCurrentGameProfile();
    if (gProfile != None)
    {
		warn("RJ: SetTeamSymbols() called in SP??");
    }
    else
    {
        r1 = rand(MaxTeamSymbols);

        do 
        {
            r2 = rand(MaxTeamSymbols);
        } 
        until( r1 != r2 );

        TeamSymbolIndex[0] = r1;
        TeamSymbolIndex[1] = r2;

        log("Set random team symbols to "$TeamSymbolIndex[0]$" and "$TeamSymbolIndex[1]);
    }

    // jij ---
    // send an event to trigger actors so they know team symbols have been selected (yes, this is evil, LD's need
    // to go through all levels and make all monitors (not DOM monitors) and banners have the same tag...)
    if (Level.NetMode != NM_Client)
    {
        foreach AllActors(class'Actor', A, 'TeamSymbolUpdate')
            A.Trigger(self, None);
    }
    // --- jij
}

simulated function string GetDifficultyString()
{
    return class'GameInfo'.static.GetDifficultyName(class'GameInfo'.static.GetDifficultyLevelIndex(Difficulty));
}
// --- amb


// End game stats

function bool StatWeaponAccuracy(name WepClass, out EndStatData Stat)
{
    local PlayerReplicationInfo PRI;
    local PlayerStats PS;
    local int i;
    local int Accuracy;

    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
        PS = PRI.Stats;
        Accuracy = PS.GetWeaponClassAccuracy(WepClass);
        if ( PS != None && Accuracy > 40 && (Stat.PRI == None || Accuracy > Stat.StatValue) )
        {
            Stat.PRI = PRI;
            Stat.StatValue = Accuracy;
        }
    }
    return (Stat.PRI != None);
}

function bool StatWeaponSpecials(name WepClass, out EndStatData Stat)
{
    local PlayerReplicationInfo PRI;
    local PlayerStats PS;
    local int i;
    local int Specials;

    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
        PS = PRI.Stats;
        Specials = PS.GetWeaponClassSpecials(WepClass);
        if ( PS != None && Specials > 2 && (Stat.PRI == None || Specials > Stat.StatValue) )
        {
            Stat.PRI = PRI;
            Stat.StatValue = Specials;
        }
    }
    return (Stat.PRI != None);
}

function bool StatWeaponExclusive(name WepClass, out EndStatData Stat)
{
    local PlayerReplicationInfo PRI;
    local PlayerStats PS;
    local int i;
    local int Ex;

    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
        PS = PRI.Stats;
        Ex = PS.GetWeaponClassExclusive(WepClass);
        if ( PS != None && Ex >= 5 && (Stat.PRI == None || Ex > Stat.StatValue) )
        {
            Stat.PRI = PRI;
            Stat.StatValue = Ex;
        }
    }
    return (Stat.PRI != None);
}

function bool StatWeaponDeaths(name WepClass, out EndStatData Stat)
{
    local PlayerReplicationInfo PRI;
    local PlayerStats PS;
    local int i;
    local int Deaths;

    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
        PS = PRI.Stats;
        Deaths = PS.GetWeaponClassDeaths(WepClass);
        if ( PS != None && Deaths > 2 && (Stat.PRI == None || Deaths > Stat.StatValue) )
        {
            Stat.PRI = PRI;
            Stat.StatValue = Deaths;
        }
    }
    return (Stat.PRI != None);
}

function bool ValidForStats(PlayerReplicationInfo pri)
{
	return True;
}

function EndGameStats()
{
    local EndStatData TempStats[10];
    local float Rating[10];
    local PlayerReplicationInfo PRI, Best;
    local PlayerStats PS;
    local int i, s;
    local float BestFPM;
    local int BestSuicides;
    local int Deaths;
    local int BestFrags;
    local int BestEfficiency;
    local int BestMonsterKills;
    local int BestGoalScores;

    local int NumStats, BestStat;
    local float BestRating;

    // best frags-per-minute
    Best = None;
    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];

		if(!ValidForStats(PRI))
			continue;

        PS = PRI.Stats;

        PS.PlayTime = PRI.PlayTime;

        if ( PS != None && (Best == None || PS.FragsPerMinute() > BestFPM) )
        {
            Best = PRI;
            BestFPM = PS.FragsPerMinute();
        }
    }
    if (Best != None && BestFPM > 4.0)
    {
        TempStats[s].PRI = Best;
        TempStats[s].StatId = 0;
        TempStats[s].StatValue = BestFPM;
        Rating[s] = BestFPM / 15.0;
        s++;
    }

    // most suicides
    Best = None;
    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
		if(!ValidForStats(PRI))
			continue;

        PS = PRI.Stats;
        if ( PS != None && PS.Overall.Suicides > 4 && (Best == None || PS.Overall.Suicides > BestSuicides) )
        {
            Best = PRI;
            BestSuicides = PS.Overall.Suicides;
        }
    }
    if (Best != None)
    {
        TempStats[s].PRI = Best;
        TempStats[s].StatId = 2;
        TempStats[s].StatValue = BestSuicides;
        Rating[s] = float(BestSuicides-4) / 10.0;
        s++;
    }

    // no deaths
    Best = None;
    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
		if(!ValidForStats(PRI))
			continue;

        PS = PRI.Stats;

        if (PS == None)
            continue;

        Deaths = PS.Overall.Deaths + PS.Overall.Suicides;

        if ( Deaths == 0 && PS.Overall.Frags >= 5 && (Best == None || PS.Overall.Frags > BestFrags) )
        {
            Best = PRI;
            BestFrags = PS.Overall.Frags;
        }
    }
    if (Best != None)
    {
        TempStats[s].PRI = Best;
        TempStats[s].StatId = 3;
        TempStats[s].StatValue = 0;
        Rating[s] = float(BestFrags) / 15.0;
        s++;
    }
    else
    {
        // best efficiency (only if noone won invincibility)
        Best = None;
        for( i = 0; i < PRIArray.length; i++)   
        {
            PRI = PRIArray[i];
			if(!ValidForStats(PRI))
				continue;

            PS = PRI.Stats;

            if ( PS != None && (Best == None || PS.Efficiency > BestEfficiency) )
            {
                Best = PRI;
                BestEfficiency = PS.Efficiency;
            }
        }
        if (Best != None && BestEfficiency > 0)
        {
            TempStats[s].PRI = Best;
            TempStats[s].StatId = 1;
            TempStats[s].StatValue = BestEfficiency;
            Rating[s] = 0.1;
            s++;
        }
    }

    // best headshots
    if ( StatWeaponSpecials('SniperRifle', TempStats[s]) )
    {
        TempStats[s].StatId = 4;
        Rating[s] = TempStats[s].StatValue / 10.0;
        s++;
    }

    // best telefrags
    if ( StatWeaponSpecials('TransLauncher', TempStats[s]) )
    {
        TempStats[s].StatId = 5;
        Rating[s] = TempStats[s].StatValue / 10.0;
        s++;
    }

    // shock accuracy
    if ( StatWeaponAccuracy('ShockRifle', TempStats[s]) )
    {
        TempStats[s].StatId = 6;
        Rating[s] = TempStats[s].StatValue / 85.0;
        s++;
    }

    // rocket accuracy
    if ( StatWeaponAccuracy('RocketLauncher', TempStats[s]) )
    {
        TempStats[s].StatId = 7;
        Rating[s] = TempStats[s].StatValue / 85.0;
        s++;
    }

    // shield only
    if ( StatWeaponExclusive('ShieldGun', TempStats[s]) )
    {
        TempStats[s].StatId = 8;
        Rating[s] = TempStats[s].StatValue / 20.0;
        s++;
    }

    // monster kills
    Best = None;
    for( i = 0; i < PRIArray.length; i++)   
    {
        PRI = PRIArray[i];
        PS = PRI.Stats;

        if ( PS != None && PS.MonsterKills > 1 && (Best == None || PS.MonsterKills > BestMonsterKills) )
        {
            Best = PRI;
            BestMonsterKills = PS.MonsterKills;
        }
    }
    if (Best != None)
    {
        TempStats[s].PRI = Best;
        TempStats[s].StatId = 12;
        TempStats[s].StatValue = BestMonsterKills;
        Rating[s] = BestMonsterKills / 3.0;
        s++;
    }

    // goop magnet
    if ( StatWeaponDeaths('BioRifle', TempStats[s]) )
    {
        TempStats[s].StatId = 9;
        Rating[s] = TempStats[s].StatValue / 12.0;
        s++;
    }

    // goal scores
    if (GameClass ~= "xGame.xCTFGame")
    {
        Best = None;
        for( i = 0; i < PRIArray.length; i++)   
        {
            PRI = PRIArray[i];
            if(!ValidForStats(PRI))
				continue;

			PS = PRI.Stats;

            if ( PS != None && PS.GoalScores > 1 && (Best == None || PS.GoalScores > BestGoalScores) )
            {
                Best = PRI;
                BestGoalScores = PS.GoalScores;
            }
        }
        if (Best != None)
        {
            for( i = 0; i < PRIArray.length; i++) // only show stat if this player doesn't have the most points stat
            {
                if (PRIArray[i] != Best && PRIArray[i].Score > Best.Score && ValidForStats(PRIArray[i]))
                {
                    TempStats[s].PRI = Best;
                    TempStats[s].StatId = 10;
                    TempStats[s].StatValue = BestGoalScores;
                    Rating[s] = BestGoalScores / 4.0;
                    s++;
                    break;
                }
            }
        }
    }


    // find final 3
    NumStats = s;

    for (s=0; s<NumStats; s++)
    {
        if (Rating[s] > 1.0) Rating[s] = 1.0;
        if (Rating[s] > 0.0) Rating[s] += FRand()*0.2;
        //log("STAT"@TempStats[s].StatId@TempStats[s].StatValue@Rating[s]);
    }

    for (i=0; i<3; i++)
    {
        BestRating = 0.0;
        for (s=0; s<NumStats; s++)
        {
            if (Rating[s] > BestRating)
            {
                BestStat = s;
                BestRating = Rating[s];
            }
        }

        if (BestRating == 0.0)
            break;

        EndStats[i] = TempStats[BestStat];
        Rating[BestStat] = 0.0;

        for (s=0; s<NumStats; s++)
        {
            if (TempStats[s].PRI == TempStats[BestStat].PRI && Rating[s] > 0.0)
                Rating[s] *= 0.75;
        }
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting("Server",  "ServerName",		default.GRIPropsDisplayText[i++], 255, 100, "Text", "40");
	PlayInfo.AddSetting("Server",  "ShortName",			default.GRIPropsDisplayText[i++], 255, 101, "Text", "20");
	PlayInfo.AddSetting("Server",  "AdminName",			default.GRIPropsDisplayText[i++], 255, 102, "Text", "20");
	PlayInfo.AddSetting("Server",  "AdminEmail",		default.GRIPropsDisplayText[i++], 255, 103, "Text", "20");
	PlayInfo.AddSetting("Server",  "MessageOfTheDay",	default.GRIPropsDisplayText[i++], 254, 200, "Text", "40");
}

defaultproperties
{
     MaxTeamSymbols=47
     ServerName="Pariah"
     ShortName="Pariah"
     GRIPropsDisplayText(0)="Server Name"
     GRIPropsDisplayText(1)="Short Server Name"
     GRIPropsDisplayText(2)="Admin Name"
     GRIPropsDisplayText(3)="Admin E-Mail"
     GRIPropsDisplayText(4)="Message of the day"
     bStopCountDown=True
}
