// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors
// are allowed to exist in this game type, and who may enter the game.  While the
// GameInfo class is the public interface, much of this functionality is delegated
// to several classes to allow easy modification of specific game components.  These
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.
// A GameInfo actor is instantiated when the level is initialized for gameplay (in
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by
// (in order) either the DefaultGameType if specified in the LevelInfo, or the
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless
// its a network game in which case the DefaultServerGame entry is used.
//
//=============================================================================
class GameInfo extends Info
    native;

//------------------------------------------------------------------------------
// Structs for reporting server state data

struct native export KeyValuePair
{
	var() string Key;
	var() string Value;
};

struct long native export PlayerResponseLine
{
	var() int PlayerNum;
	var() string PlayerName;
	var() int Ping;
	var() byte Score;
};

struct long native export ServerResponseLine
{
    // Ping returns (synthetic):
	var() int Ping;
	var() string IP;
	var() int QueryPort;

    // Master Server returns these, as well as IP & QueryPort:
    // Also the results of QI_Parameters:
	var() int ServerID;
	var() int Port;
	var() string ServerName;
	var() string MapName;
	var() string GameType;
	var() byte CurrentPlayers;
	var() byte MaxPlayers;
	var() byte bDedicated;
	var() byte bPrivate;

	var() array<KeyValuePair>       ServerInfo; // Returned from QI_ServerInfo
	var() array<PlayerResponseLine> PlayerInfo; // Returned from QI_PlayerInfo
};

//-----------------------------------------------------------------------------
// Variables.

var() globalconfig float        Difficulty;
var() bool                      bRestartLevel;            // Level should be restarted when player dies
var() bool                      bPauseable;               // Whether the game is pauseable.
var() config bool               bWeaponStay		"PI:Weapons Stay:Game:1:60:Check";		// Whether or not weapons stay when picked up.
var() bool                      bCanChangeSkin;           // Allow player to change skins in game.
var() bool                      bTeamGame;                // This is a team game.
var() bool                      bGameEnded;               // set when game ends
var() bool                      bOverTime;
var() bool						bAllowOverTime;	//cmr -- disable the overtime stuff, since some gametypes might not want it
var() localized bool            bAlternateMode;
var() bool                      bCanViewOthers;
var() bool                      bDelayedStart;
var() bool                      bWaitingToStartMatch;
var() globalconfig bool         bChangeLevels		"PI:Use Map Rotation:Server:0:10:Check";
var() bool                      bPracticeMode;            // passed in by URL, overrides map list use.
var() bool                      bAlreadyChanged;
var() globalconfig bool         bStartUpLocked	"PI:Startup Locked:Rules:1:10:Check"; // gam
var() transient bool            bLocked;                  // gam
var() globalconfig bool         bNoBots			"PI:No Bots In Game:Bots:0:10:Check:Xb"; // gam
var() globalconfig bool         bAttractAlwaysFirstPerson;// jjs
var() globalconfig int          NumMusicFiles;            // amb: hack-a-hack
var() bool						bSinglePlayer;            // CMR: to differentiate in code
var() bool                      bMenuLevel;               // gam -- so we can quickly decide if we're in MenuLevel (ie: PreCacheGame sets this)

var()   globalconfig int        GoreLevel			"PI:Gore Level:Game:0:120:Select;0;Full Gore;1;Reduced Gore";  // 0=Normal, increasing values=less gore
var()   globalconfig bool       bGreenGore;
                                                        // (cosine of max error to correct)
var()   float                   GameSpeed			"PI:Game Speed:Game:0:80:Text;8";                // Scale applied to game rate.
var()   float                   StartTime;

var()   string                  DefaultPlayerClassName;

// user interface
var()   string                  ScoreBoardType;           // Type of class<Menu> to use for scoreboards. (gam)
var()   string                  BotMenuType;              // Type of bot menu to display.
var()   string                  RulesMenuType;            // Type of rules menu to display.
var()   string                  SettingsMenuType;         // Type of settings menu to display.
var()   string                  GameUMenuType;            // Type of Game dropdown to display.
var()   string                  MultiplayerUMenuType;     // Type of Multiplayer dropdown to display.
var()   string                  GameOptionsMenuType;      // Type of options dropdown to display.
var()   config string           HUDType;                  // HUD class this game uses. (gam)
var()   string                  MapListType;              // Maplist this game uses.
var()   string                  MapPrefix;                // Prefix characters for names of maps for this game type.
var()   string                  BeaconName;               // Identifying string used for finding LAN servers.
var()   string                  PersonalStatsDisplayType; // Type of class<Menu> to use for PersonalStats. (gam)

var()   globalconfig int        MaxSpectators		"PI:Max Spectators:Server:1:30:Text;3";            // Maximum number of spectators.
var()   int                     NumSpectators;            // Current number of spectators.
var()   globalconfig int        MaxPlayers		"PI:Max Players:Server:0:31:Text;3";
var()   int                     NumPlayers;               // number of human players
// gam: Xbox Live! ---
var()   globalconfig int        NumReservedSlots;         // number of spaces to keep for invited players
var()   int                     NumInvitedPlayers;        // number of invited players connected
// --- gam
var()   int                     NumBots;                  // number of non-human players (AI controlled but participating as a player)
var()   int                     CurrentID;
var() localized string          DefaultPlayerName;
var() localized string          GameName;
var() float					    FearCostFallOff;			// how fast the FearCost in NavigationPoints falls off
var() class<AvoidMarker>        FearMarkerClass;        //What kind of AvoidMarker should be spawned for delay weapons.

// gam --- moved from up from derived classes for native love
var() config int MaxPlayersOnDedicated;
var() config int MaxPlayersOnListen;
var() config int GoalScore			"PI:Goal Score:Rules:0:40:Text;3";
var() config int MinGoalScore;
var() config int MaxLives				"PI:Number of Lives:Rules:0:30:Text;3";	// max number of lives for match, unless overruled by level's GameDetails
var() config int TimeLimit;          // time limit in minutes
var() config int RemainingRounds;

// Message classes.
var() class<LocalMessage>       DeathMessageClass;
var() class<GameMessage>        GameMessageClass;

//-------------------------------------
// GameInfo components
var() string MutatorClass;
var() Mutator BaseMutator;                // linked list of Mutators (for modifying actors as they enter the game)
var() globalconfig string AccessControlClass;
var() AccessControl AccessControl;        // AccessControl controls whether players can enter and/or become admins
var() GameRules GameRulesModifiers;       // linked list of modifier classes which affect game rules
var() string BroadcastHandlerClass;
var() BroadcastHandler BroadcastHandler;  // handles message (text and localized) broadcasts

var() class<PlayerController> PlayerControllerClass;  // type of player controller to spawn for players logging in
var() string PlayerControllerClassName;

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var() GameReplicationInfo GameReplicationInfo;


// Stats - jmw

var() bool                        bLoggingGame;           // Does this gametype log?
var() globalconfig bool			bEnableStatLogging;		// If True, games will log
var() GameStats                   GameStats;				// Holds the GameStats actor
var() class<GameStats>			GameStatsClass;			// Type of GameStats actor to spawn

// jij ---
// Voice chatters & channels

const MAX_CHATTERS = 8;

struct VoiceChannel
{
    var() PlayerController Chatter[MAX_CHATTERS];
	var() XboxAddr xbAddr[MAX_CHATTERS];
	var() int PortNo[MAX_CHATTERS];
    var() int NumChatters;
};
var() array<VoiceChannel> VoiceChannels;
var() int NumVoiceChannels;
// --- jij

var() class<PlayerStats>          PlayerStatsClass; // gam

// amb ---
var() CoopInfo    CoopInfo;
var() string      CoopInfoClassName;
// --- amb

// sjs ---
var() Name              VoteTypes[8];
var() localized string  VoteTypeStrings[8];
var() float             VoteLifeTime;       // seconds a called vote lasts for
// sjs --- supported vote names for this gametype

// Cheat Protection

var() class<Security> 			SecurityClass;

// gam --- For menus.
var() String ScreenshotName;
var() String DecoTextName;
var() String Acronym;
var() int ListPriority;
var() bool bCustomMaps;
// --- gam

var() bool bShowHints;

var PlayerStart LastPlayerStart;	// BB

// cmr ---
var byte Vehicle0Regen[5];
var byte Vehicle1Regen[5];
var byte VehicleRegenTime; //in seconds
// --- cmr

// rj --- moved here from GameProfile
const cNumDifficultyLevels  = 4;

var float               DifficultyLevels[cNumDifficultyLevels];
var localized string    DifficultyNames[cNumDifficultyLevels];
// --- rj

var localized string    StringDedicated;

// localized PlayInfo descriptions & extra info
var private localized string GIPropsDisplayText[11];
var private localized string GIPropsExtras;

native final static function	LoadMapList(string MapPrefix, out array<string> Maps);

//------------------------------------------------------------------------------
// Engine notifications.

function PreBeginPlay()
{
    StartTime = 0;
    SetGameSpeed(GameSpeed);
    GameReplicationInfo = Spawn(GameReplicationInfoClass);
    InitGameReplicationInfo();

    bLocked = bStartUpLocked; // gam
}

function Destroyed()
{
    log("GameReplicationInfo.Destroy()");
    GameReplicationInfo.Destroy();
    Super.Destroyed();
}

function string FindPlayerByID( int PlayerID )
{
    local int i;

    for( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
    {
        if( GameReplicationInfo.PRIArray[i].PlayerID == PlayerID )
            return GameReplicationInfo.PRIArray[i].RetrivePlayerName();
    }
    return "";
}

function ChangeMap(int ContextID) // sjs
{
    local MapList myList;
    local class<MapList> ML;
    local string MapName;

	if( MapListType != "" )
	{
		ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
		myList = spawn(ML);
		MapName = myList.MapEntries[ContextID].MapName;
		myList.Destroy();
	}

    if( MapName == "" )
    {
        return;
    }

    Level.ServerTravel(MapName, false);
}

function Mute(string PlayerName) // sjs - implement
{

}

function QueueBringForward(PlayerController Target, PlayerController Other);

function bool ExecuteVote( Name VoteType, int ContextID ) // possibly override this and VoteTypes in derived classes
{
    log("Got ExecuteVote: "$VoteType$" "$ContextID,'Voting');
    switch( VoteType )
    {
        case 'RestartGame':
            RestartGame();
            break;
        case 'ChangeMap':
            ChangeMap(ContextID);
            break;
        case 'StartMatch':
            if( bWaitingToStartMatch )
            {
                StartMatch();
            }
            break;
        case 'KickPlayer':
            SessionKickBan( FindPlayerByID(ContextID) );
            break;
        case 'MutePlayer':
            Mute( FindPlayerByID(ContextID) );
            break;
        default:
            log("ExecuteVote: Unknown VoteType",'Voting');
            return false;
    }
    return false;
}

function PostBeginPlay()
{
    if ( bAlternateMode )
        GoreLevel = 2;
    InitLogging();
    Super.PostBeginPlay();
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    Super.Reset();
    bGameEnded = false;
    bOverTime = false;
    bWaitingToStartMatch = true;
    InitGameReplicationInfo();
}

/* InitLogging()
Set up statistics logging
*/
function InitLogging()
{

    if ( !bEnableStatLogging || !bLoggingGame || (Level.NetMode == NM_Standalone) )
        return;

	GameStats = spawn(GameStatsClass);
	if (GameStats!=None)
	{
		GameStats.NewGame();
	}
}

function Timer()
{
//	local NavigationPoint N;
	local int i;

	if( BroadcastHandler != None ) // gam
        BroadcastHandler.UpdateSentText();

	// jim: Don't use FearCost.  Takes 1.6ms on Wasteland (every second)
    //for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
//		N.FearCost *= FearCostFallOff;

	// cmr ---
	if( bTeamGame )
	{
		for(i=0;i<5;i++)
		{
			if(Vehicle0Regen[i] != 0)
			{
				Vehicle0Regen[i]--;
				if(Vehicle0Regen[i]==0)
				{
					GameReplicationInfo.VehicleCount[0] = Max(GameReplicationInfo.VehicleCount[0]-1, 0);
				}
			}
			if(Vehicle1Regen[i] != 0)
			{
				Vehicle1Regen[i]--;
				if(Vehicle1Regen[i]==0)
				{
					GameReplicationInfo.VehicleCount[1] = Max(GameReplicationInfo.VehicleCount[1]-1, 0);
				}
			}

		}
	}
	// --- cmr
}



// cmr ---

function ResetVehicleCounts()
{
	//GameReplicationInfo.VehicleCount[0]=0;
	//GameReplicationInfo.VehicleCount[1]=0;


	//Vehicle0Regen[0]=0;
	//Vehicle0Regen[1]=0;
	//Vehicle0Regen[2]=0;
	//Vehicle0Regen[3]=0;
	//Vehicle0Regen[4]=0;

	//Vehicle1Regen[0]=0;
	//Vehicle1Regen[1]=0;
	//Vehicle1Regen[2]=0;
	//Vehicle1Regen[3]=0;
	//Vehicle1Regen[4]=0;
}

function bool VehicleAvailable(byte Team)
{
	//local byte OtherTeam;
	//
	////log(Team);

	//if(Team > 1)
	//{
	//	log("CHARLES SAYS HEY LEVEL DESIGNER, YOU MOST LIKELY HAVE A VEHICLE PAD WITH A TEAM INDEX GREATER THAN 1. TEAMS ARE 0 AND 1");
	//	Team=0;
	//}

	//if(Team==1)
	//	OtherTeam=0;
	//else
	//	OtherTeam=1;
	//
	//if(bTeamGame)
	//{
	//	if(GameReplicationInfo.VehicleCount[Team] < Level.VehiclesPerTeam &&
	//		(GameReplicationInfo.VehicleCount[Team] + GameReplicationInfo.VehicleCount[OtherTeam] < Level.VehiclesPerTeam*2))
	//		return True;
	//	else
	//		return False;
	//}
	//else
	//{
	//	if(GameReplicationInfo.VehicleCount[0] < Level.VehiclesPerTeam*2)
	//		return True;
	//	else
	//		return False;
	//}

	return False;
}

//called when someone grabs a vehicle that belongs to the other team
function TakeVehicleFrom(byte Team)
{
	//local byte OtherTeam;
	//assert(GameReplicationInfo.VehicleCount[Team] > 0);

	//if(Team==1)
	//	OtherTeam=0;
	//else
	//	OtherTeam=1;

	////log("CHARLES:  Took vehilce from team "$Team$" (has "$GameReplicationInfo.VehicleCount[Team]$" vehicles) and gave to team "$OtherTeam$" (has "$GameReplicationInfo.VehicleCount[OtherTeam]$" vehicles");

	//GameReplicationInfo.VehicleCount[Team]-=1;

	//GameReplicationInfo.VehicleCount[OtherTeam]+=1;
}

function RegenVehicle(byte Team)
{
	//local int i, lowest, lowesttime;

	//log("regenvehicle "$team);
	//if(VehicleRegenTime==0)
	//{
	//	GameReplicationInfo.VehicleCount[Team] = Max(GameReplicationInfo.VehicleCount[Team]-1, 0);
	//	return;
	//}
	//
	//if(Team==0)
	//{
	//	//find an empty spot
	//	for(i=0;i<5;i++)
	//	{
	//		if(Vehicle0Regen[i]==0)
	//		{
	//			Vehicle0Regen[i]=VehicleRegenTime;
	//			return;
	//		}
	//		else if(Vehicle0Regen[i] < lowesttime)
	//		{
	//			lowest=i;
	//		}
	//	}
	//	//if we are here, all the spots are full, push out the closest vehicle and reset time
	//	GameReplicationInfo.VehicleCount[0] = Max(GameReplicationInfo.VehicleCount[0]-1, 0);
	//	Vehicle0Regen[lowest]=VehicleRegenTime;
	//}
	//else
	//{
	//	//find an empty spot
	//	for(i=0;i<5;i++)
	//	{
	//		if(Vehicle1Regen[i]==0)
	//		{
	//			Vehicle1Regen[i]=VehicleRegenTime;
	//			return;
	//		}
	//		else if(Vehicle1Regen[i] < lowesttime)
	//		{
	//			lowest=i;
	//		}
	//	}
	//	//if we are here, all the spots are full, push out the closest vehicle and reset time
	//	GameReplicationInfo.VehicleCount[1] = Max(GameReplicationInfo.VehicleCount[1]-1, 0);
	//	Vehicle1Regen[lowest]=VehicleRegenTime;
	//}

}

// Called when game shutsdown.
event GameEnding()
{
    EndLogging("serverquit");
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
    local MapList myList;
    local class<MapList> ML;

    GameReplicationInfo.bTeamGame = bTeamGame;
    GameReplicationInfo.GameName = GameName;
    GameReplicationInfo.GameClass = string(Class);
    GameReplicationInfo.CoopInfo = CoopInfo; //amb
    GameReplicationInfo.Difficulty = Difficulty; // gam
    GameReplicationInfo.bOvertime = false;

	//cmr --
	ResetVehicleCounts();
	// -- cmr

    // sjs --- get entire map list for voting purposes
    if( MapListType != "" )
    {
        ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
        myList = spawn(ML);
        myList.GetAllMaps(GameReplicationInfo.MapCycle);
        myList.Destroy();
    }
    // --- sjs
}

native function string GetNetworkNumber();

//------------------------------------------------------------------------------
// Server/Game Querying.

function GetServerInfo( out ServerResponseLine ServerState )
{
	ServerState.ServerName		= GameReplicationInfo.ServerName;
	ServerState.MapName			= Left(string(Level), InStr(string(Level), "."));
	ServerState.GameType		= Mid( string(Class), InStr(string(Class), ".")+1);
	ServerState.CurrentPlayers	= NumPlayers;
	ServerState.MaxPlayers		= MaxPlayers;
	ServerState.IP				= ""; // filled in at the other end.
	ServerState.Port			= GetServerPort();
	
	if( Level.IsCustomMap() )
	{
    	ServerState.MapName = ServerState.MapName $ "?custommap=" $ Level.GetCustomMap();
	}

	ServerState.ServerInfo.Length = 0;
	ServerState.PlayerInfo.Length = 0;
}

function GetServerDetails( out ServerResponseLine ServerState )
{
	local int i;
	local Mutator M;

	i = ServerState.ServerInfo.Length;

	if( Level.NetMode == NM_DedicatedServer )
	{
	    ServerState.bDedicated = 1;
	}
	else
	{
	    ServerState.bDedicated = 0;
	}

    if( AccessControl.HasGamePassword() )
    {
	    ServerState.bPrivate = 1;
    }
	else
	{
	    ServerState.bPrivate = 0;
	}

	// adminname
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "adminname";
	ServerState.ServerInfo[i++].Value = GameReplicationInfo.AdminName;

	// adminemail
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "adminemail";
	ServerState.ServerInfo[i++].Value = GameReplicationInfo.AdminEmail;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "initialwecs";
	ServerState.ServerInfo[i++].Value = String(int(GetURLOption("StartWECCount")));

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		M.GetServerDetails(ServerState);
}

function GetServerPlayers( out ServerResponseLine ServerState )
{
    local Mutator M;
	local Controller C;
	local PlayerReplicationInfo PRI;
	local int i;

	i = ServerState.PlayerInfo.Length;

	for( C=Level.ControllerList;C!=None;C=C.NextController )
    {
		PRI = C.PlayerReplicationInfo;
		if( PRI != None && !PRI.bBot )
        {
			ServerState.PlayerInfo.Length = i+1;
			ServerState.PlayerInfo[i].PlayerNum  = C.PlayerNum;
			ServerState.PlayerInfo[i].PlayerName = Left(PRI.RetrivePlayerName(), 32);
			ServerState.PlayerInfo[i].Score		 = Clamp(PRI.Score, 0, 255);
			ServerState.PlayerInfo[i].Ping		 = PRI.Ping;
			i++;
        }
    }

	// Ask the mutators if they have anything to add.
	for (M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		M.GetServerPlayers(ServerState);
}

//------------------------------------------------------------------------------
// Misc.

// Return the server's port number.
function int GetServerPort()
{
    local string S;
    local int i;

    // Figure out the server's port.
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    assert(i>=0);
    return int(Mid(S,i+1));
}

function bool SetPause(BOOL bPause, PlayerController P)
{
    log("A - SetPause" @ bPause @ P);

    if(P == None || P.PlayerReplicationInfo == None)
    {
        return(false);
    }

    log("B - SetPause" @ bPause @ P);
    
    // can't toggle paused state while cinematic or matinee is playing
    if(!Level.IsPausable())
    {
        return(false);
    }

    log("C - SetPause" @ bPause @ P);

    if(bPauseable || P.IsA('Admin') || Level.Netmode == NM_Standalone)
    {
        log("D - SetPause" @ bPause @ P);
    
        if(bPause)
        {
            if(Level.Pauser == None)
            {
                // not paused, set new pauser
                Level.Pauser = P.PlayerReplicationInfo;
                log("Not paused, set new pauser to" @ Level.Pauser);
                return(true);
            }
            else if(Level.Pauser != P.PlayerReplicationInfo)
            {
                if(Level.QueuedPauser == None)
                {
                    // already paused by someone else, queue up pause request
                    Level.QueuedPauser = P.PlayerReplicationInfo;
                    log(Level.Pauser @ "is already pausing, queue up pause request for" @ Level.QueuedPauser);
                    return(true);
                }
                else if(Level.QueuedPauser != P.PlayerReplicationInfo)
                {
                    // already have a queued pauser
                    warn(p@" is trying to pause and pausing queue is full!");
                }
                else
                {
                    warn(p@"(current queued pauser) is trying to re-pause!");
                }
            }
            else
            {
                warn(p@"(current pauser) is trying to re-pause!");
            }
        }
        else
        {
            if(Level.Pauser == P.PlayerReplicationInfo)
            {
                // this is the pauser, unpause or set next pauser
                log(Level.Pauser @ "is done pausing, set next pauser to" @ Level.QueuedPauser);
                Level.Pauser = Level.QueuedPauser;
                Level.QueuedPauser = None;
            }
            else if(Level.QueuedPauser == P.PlayerReplicationInfo)
            {
                // the queued pauser reverts their pause attempt while still paused by the initial pauser
                log(Level.QueuedPauser @ "reverts their pause attempt while still paused by" @ Level.Pauser);
                Level.QueuedPauser = None;
            }
            else
            {
                warn(p@"(non-pauser) is trying to un-pause!");
            }
        }
    }
    
    log("E - SetPause" @ bPause @ P);
    
    return(false);
}

//------------------------------------------------------------------------------
// Voice chat.
// jij ---
function InitializeVoiceChannels()
{
    local int i,j;

    log("Voice --- Initializing " $ NumVoiceChannels $ " voice channels.");

    VoiceChannels.Insert(0,NumVoiceChannels);

    // initialize each channel
    for(i = 0; i < VoiceChannels.Length; i++)
    {
        VoiceChannels[i].NumChatters = 0;

        // initialize each chatter ring slot
        for(j = 0; j < MAX_CHATTERS; j++)
            VoiceChannels[i].Chatter[j] = None;
    }
}

function JoinBestVoiceChannel( PlayerController Client, XboxAddr xbAddr, int PortNo, bool InfoValid )
{
    local int i,j;

    // find the first non-full voice channel
    for(i = 0; i < VoiceChannels.Length; i++)
    {
        if (VoiceChannels[i].NumChatters < MAX_CHATTERS && IsVoiceChannelValid(Client,i))
            break;
    }

    if (i == VoiceChannels.Length)
    {
        // should never happen since 4 chatters/channel * (min.) 8 channels = 32 chatters, and max 16 players/game
        log("Voice --- All voice channels are full.");
        assert(false);
        return;
    }

    if (!InfoValid)
    {
        if (Client.VoiceChannel < 0)
            return;

        // find this player in their current channel
        for(j = 0; j < MAX_CHATTERS; j++)
        {
            if (VoiceChannels[Client.VoiceChannel].Chatter[j] == Client)
            {
                xbAddr = VoiceChannels[Client.VoiceChannel].xbAddr[j];
                PortNo = VoiceChannels[Client.VoiceChannel].PortNo[j];
                break;
            }
        }

        if (j == MAX_CHATTERS)
            return;
    }

    if (Client.bHasVoice && Client.VoiceChannel >= 0)
        LeaveVoiceChannel(Client,xbAddr,PortNo,Client.VoiceChannel,true);

    for(j = 0; j < MAX_CHATTERS; j++)
    {
        if (VoiceChannels[i].Chatter[j] == None)
        {
            VoiceChannels[i].Chatter[j] = Client;
            VoiceChannels[i].xbAddr[j] = xbAddr;
            VoiceChannels[i].PortNo[j] = PortNo;
            VoiceChannels[i].NumChatters++;
            break;
        }
    }

    // tell this player about everyone else in the channel, and tell everyone else in the channel about this player
    for(j = 0; j < MAX_CHATTERS; j++)
    {
        if (VoiceChannels[i].Chatter[j] == Client)
            continue;

        if (VoiceChannels[i].Chatter[j] != None)
        {
            Client.ClientChangeVoiceChatter( VoiceChannels[i].XbAddr[j], VoiceChannels[i].PortNo[j], true );
            VoiceChannels[i].Chatter[j].ClientChangeVoiceChatter( XbAddr, PortNo, true );
        }
    }

    Client.VoiceChannel = i;
    Client.PlayerReplicationInfo.VoiceChannel = i;
    Client.ClientChangeChannel(i);
}

function LeaveVoiceChannel( PlayerController Client, XboxAddr xbAddr, int PortNo, int Channel, bool InfoValid )
{
    local int i;

    if (Channel < 0)
        Channel = Client.VoiceChannel;
    if (Channel < 0)
        return;

    for(i = 0; i < MAX_CHATTERS; i++)
    {
        if (VoiceChannels[Channel].Chatter[i] == Client)
        {
            VoiceChannels[Channel].Chatter[i] = None;
            VoiceChannels[Channel].NumChatters--;

            if (!InfoValid)
            {
                xbAddr = VoiceChannels[Channel].xbAddr[i];
                PortNo = VoiceChannels[Channel].PortNo[i];
            }

            break;
        }
    }

    if (i == MAX_CHATTERS)
        return;

    // tell this player about everyone else in the channel, and tell everyone else in the channel
    // about this player
    for(i = 0; i < MAX_CHATTERS; i++)
    {
        if (VoiceChannels[Channel].Chatter[i] != None)
        {
            if( InfoValid )
                Client.ClientChangeVoiceChatter( VoiceChannels[Channel].XbAddr[i], VoiceChannels[Channel].PortNo[i], false );
            VoiceChannels[Channel].Chatter[i].ClientChangeVoiceChatter( XbAddr, PortNo, false );
        }
    }

    Client.VoiceChannel = -1;
    Client.PlayerReplicationInfo.VoiceChannel = -1;

    if( InfoValid )
        Client.ClientChangeChannel(-1);
}

function bool IsVoiceChannelValid(PlayerController Client, int Channel)
{
    // in non-team games, a player may join any channel
    return true;
}

function bool JoinVoiceChannel( PlayerController Client, XboxAddr xbAddr, int PortNo, int Channel, bool InfoValid )
{
    local int i;

    // fail on invalid channel requests
    if (Channel < 0 || Channel >= VoiceChannels.Length)
        return false;

    // fail if the requested channel is full
    if (VoiceChannels[Channel].NumChatters == MAX_CHATTERS)
        return false;

    // fail if game conditions prevent this player to join this channel
    if (!IsVoiceChannelValid(Client,Channel))
        return false;

    if (!InfoValid)
    {
        if (Client.VoiceChannel < 0)
            return false;

        // find this player in their current channel
        for(i = 0; i < MAX_CHATTERS; i++)
        {
            if (VoiceChannels[Client.VoiceChannel].Chatter[i] == Client)
            {
                xbAddr = VoiceChannels[Client.VoiceChannel].xbAddr[i];
                PortNo = VoiceChannels[Client.VoiceChannel].PortNo[i];
                break;
            }
        }

        if (i == MAX_CHATTERS)
            return false;
    }

    // leave the channel the player is currently in
    if (Client.bHasVoice && Client.VoiceChannel >= 0)
        LeaveVoiceChannel(Client,xbAddr,PortNo,Client.VoiceChannel,true);

    // join the new channel
    for(i = 0; i < MAX_CHATTERS; i++)
    {
        if (VoiceChannels[Channel].Chatter[i] == None)
        {
            VoiceChannels[Channel].Chatter[i] = Client;
            VoiceChannels[Channel].xbAddr[i] = xbAddr;
            VoiceChannels[Channel].PortNo[i] = PortNo;
            VoiceChannels[Channel].NumChatters++;
            break;
        }
    }

    // tell this player about everyone else in the channel, and tell everyone else in the channel about this player
    for(i = 0; i < MAX_CHATTERS; i++)
    {
        if (VoiceChannels[Channel].Chatter[i] == Client)
            continue;

        if (VoiceChannels[Channel].Chatter[i] != None)
        {
            Client.ClientChangeVoiceChatter( VoiceChannels[Channel].XbAddr[i], VoiceChannels[Channel].PortNo[i], true );
            VoiceChannels[Channel].Chatter[i].ClientChangeVoiceChatter( XbAddr, PortNo, true );
        }
    }

    Client.VoiceChannel = Channel;
    Client.PlayerReplicationInfo.VoiceChannel = Channel;

    Client.ClientChangeChannel(Channel);

    return true;
}
// --- jij

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
    // gam --- made GameSpeed not a config var.
    GameSpeed = FMax(T, 0.1);
    Level.TimeDilation = GameSpeed;
    SetTimer(Level.TimeDilation, true);
}

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
    local actor A;
    local zoneinfo Z;

    if( !Level.bHighDetailMode )
    {
        foreach DynamicActors(class'Actor', A)
        {
            if( A.bHighDetail && !A.bGameRelevant )
                A.Destroy();
        }
    }
    foreach AllActors(class'ZoneInfo', Z)
        Z.LinkToSkybox();
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
static function bool GrabOption( out string Options, out string Result )
{
    if( Left(Options,1)=="?" )
    {
        // Get result.
        Result = Mid(Options,1);
        if( InStr(Result,"?")>=0 )
            Result = Left( Result, InStr(Result,"?") );

        // Update options.
        Options = Mid(Options,1);
        if( InStr(Options,"?")>=0 )
            Options = Mid( Options, InStr(Options,"?") );
        else
            Options = "";

        return true;
    }
    else return false;
}

//
// Break up a key=value pair into its key and value.
//
static function GetKeyValue( string Pair, out string Key, out string Value )
{
    if( InStr(Pair,"=")>=0 )
    {
        Key   = Left(Pair,InStr(Pair,"="));
        Value = Mid(Pair,InStr(Pair,"=")+1);
    }
    else
    {
        Key   = Pair;
        Value = "";
    }
}

/* ParseOption()
 Find an option in the options string and return it.
*/
static function string ParseOption( string Options, string InKey )
{
    local string Pair, Key, Value;
    while( GrabOption( Options, Pair ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return Value;
    }
    return "";
}

static simulated function String ParseToken(out String Str)
{
    local String Ret;
    local int len;

    Ret = "";
    len = 0;

	// Skip spaces and tabs.
	while( Left(Str,1)==" " || Asc(Left(Str,1))==9 )
		Str = Mid(Str, 1);

	if( Asc(Left(Str,1)) == 34 )
	{
		// Get quoted String.
		Str = Mid(Str, 1);
		while( Str!="" && Asc(Left(Str,1))!=34 )
		{
			Ret = Ret $ Mid(Str,0,1);
            Str = Mid(Str, 1);
		}
		if( Asc(Left(Str,1))==34 )
			Str = Mid(Str, 1);
	}
	else
	{
		// Get unquoted String.
		for( len=0; (Str!="" && Left(Str,1)!=" " && Asc(Left(Str,1))!=9); Str = Mid(Str, 1) )
            Ret = Ret $ Mid(Str,0,1);
	}

	return Ret;
}

event PostInitGame( string Options, out string Error ) // sjs!
{
    local Actor A;
    local string InOpt, LeftOpt;
    local int pos;

    log( "PostInitGame:" @ Options );

    if (GetCurrentGameProfile() != None)
    {
        // setup co-op game
        if (IsCoopGame())
            CreateCoopInfo();
    }

    // add mutators
    InOpt = ParseOption( Options, "Mutators");
    if ( InOpt != "" )
    {
        log("Mutators"@InOpt);
        while ( InOpt != "" )
        {
            pos = InStr(InOpt,",");
            if ( pos > 0 )
            {
                LeftOpt = Left(InOpt, pos);
                InOpt = Right(InOpt, Len(InOpt) - pos - 1);
            }
            else
            {
                LeftOpt = InOpt;
                InOpt = "";
            }
            log("Add mutator "$LeftOpt);
            AddMutator(LeftOpt, true); // amb.   -- MC: Added true for bUserAdded
        }
    }

    // filter all actors for replacement
    if( Level.NetMode != NM_Client )
    {
        foreach AllActors(class'Actor', A )
        {
    	    if( !A.bGameRelevant && !Level.Game.BaseMutator.CheckRelevance(A) )
            {
		        A.Destroy();
            }
        }
    }
}

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string Error )
{
    local string InOpt, LeftOpt;
    local int pos;
    local class<AccessControl> ACClass;
    local class<GameRules> GRClass;
    local class<BroadcastHandler> BHClass;

    log( "InitGame:" @ Options );

    MaxPlayers = Min( 32,GetIntOption( Options, "MaxPlayers", MaxPlayers ));
    NumReservedSlots = Min( 32,GetIntOption( Options, "ReservedSlots", NumReservedSlots ));

    Difficulty = GetFloatOption(Options, "Difficulty", Difficulty);

    bPracticeMode = bool( ParseOption( Options, "PracticeMode") );

    InOpt = ParseOption( Options, "GameSpeed");
    if( InOpt != "" )
    {
        log("GameSpeed"@InOpt);
        SetGameSpeed(float(InOpt));
    }

    if( BaseMutator == None )
        AddMutator(MutatorClass); //amb

	assert( BroadcastHandlerClass != "" );
    BHClass = class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass,Class'Class'));
    BroadcastHandler = spawn(BHClass);

    InOpt = ParseOption( Options, "AccessControl");
    if( InOpt != "" )
        ACClass = class<AccessControl>(DynamicLoadObject(InOpt, class'Class'));
    if ( ACClass != None )
        AccessControl = Spawn(ACClass);
    else
    {
		if( AccessControlClass != "" )
			ACClass = class<AccessControl>(DynamicLoadObject(AccessControlClass, class'Class'));
		if (ACClass == None)
			ACClass = class'Engine.AccessControl';

        AccessControl = Spawn(ACClass);
    }

    InOpt = ParseOption( Options, "AdminPassword");
    if( InOpt!="" )
        AccessControl.SetAdminPassword(InOpt);

    InOpt = ParseOption( Options, "GameRules");
    if ( InOpt != "" )
    {
        log("Game Rules"@InOpt);
        while ( InOpt != "" )
        {
            pos = InStr(InOpt,",");
            if ( pos > 0 )
            {
                LeftOpt = Left(InOpt, pos);
                InOpt = Right(InOpt, Len(InOpt) - pos - 1);
            }
            else
            {
                LeftOpt = InOpt;
                InOpt = "";
            }
            log("Add game rules "$LeftOpt);
			if(LeftOpt != "")
				GRClass = class<GameRules>(DynamicLoadObject(LeftOpt, class'Class'));
            if ( GRClass != None )
            {
                if ( GameRulesModifiers == None )
                    GameRulesModifiers = Spawn(GRClass);
                else
                    GameRulesModifiers.AddGameRules(Spawn(GRClass));
            }
        }
    }

    log("Base Mutator is "$BaseMutator);
    InOpt = ParseOption( Options, "GamePassword");
    if( InOpt != "" )
    {
        AccessControl.SetGamePassWord(InOpt);
        log( "GamePassword" @ InOpt );
    }

    // jjs -
    InOpt = ParseOption( Options, "Hints");
    if( InOpt != "" )
    {
        bShowHints = true;
        log( "Hints" @ InOpt );
    }
    // - sjj

    // jij ---
    InitializeVoiceChannels();
    // --- jij

    InOpt = ParseOption(Options, "DemoRec");
    if(InOpt != "")
    {
        Log( Level.ConsoleCommand("DemoRec"@InOpt) );   
    }
    else
    {
        InOpt = ParseOption(Options, "DemoPlay");
        if(InOpt != "")
        {
            Log( Level.ConsoleCommand("DemoPlay"@InOpt) );   
        }
    }
}

// amb ---
function AddMutator(string mutname, optional bool bUserAdded)
{
    local class<Mutator> mutClass;
    local Mutator mut;

	if(mutname!="")
	{
		mutClass = class<Mutator>(DynamicLoadObject(mutname, class'Class'));
	}
    if (mutClass == None)
        return;

    mut = Spawn(mutClass);
	// mc, beware of mut being none
	if (mut == None)
		return;

	// Meant to verify if this mutator was from Command Line parameters or added from other Actors
	mut.bUserAdded = bUserAdded;

    if (BaseMutator == None)
        BaseMutator = mut;
    else
        BaseMutator.AddMutator(mut);
}

function bool IsCoopGame()
{
    return (GetCurrentGameProfile() != None) && (CoopInfo != None) && (Level.NetMode == NM_ListenServer);
}

function CreateCoopInfo()
{
    local class<CoopInfo> coopInfoClass;
	assert(CoopInfoClassName!="");
    coopInfoClass = class<CoopInfo>(DynamicLoadObject(CoopInfoClassName, class'Class'));
    CoopInfo = spawn(coopInfoClass);
}
// --- amb


//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{
    // gam ---
    local String BeaconText;
    local String MapName;
    local PlayerController PC;
    local String HostName;

    if( IsOnConsole() )
    {
        HostName = StringDedicated;
    }
    else
    {
        HostName = Level.ComputerName;
    }

    foreach DynamicActors( class'PlayerController', PC )
    {
        if( (NetConnection(PC.Player) == None) && (PC.PlayerReplicationInfo != None) )
        {
            HostName = PC.PlayerReplicationInfo.RetrivePlayerName();
            break;
        }
    }

	MapName = String(Level);
	MapName = Left( MapName, InStr(MapName, ".") );

    BeaconText =
        "###" @
        "\"" $ HostName $ "\""  @
        Class @
        Acronym @
        "\"" $ MapName $ "\"" @
        NumPlayers @
        MaxPlayers @
        int(AccessControl.HasGamePassword()) @
        "\"" $ Level.GetCustomMap() $ "\"" @
        "###";

    return( BeaconText );
    // --- gam
}

/*
	Make this a template function so LobbyGame can provide teamindex from lobby menu
*/
function int TeamIndex(PlayerController P)
{
	if ( P != None && P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != None )
	{
		return P.PlayerReplicationInfo.Team.TeamIndex;
	}
	else
	{
		return 0;
	}
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
    local playercontroller P, LocalPlayer;
    local string ClientURL, S;

    EndLogging("mapchange");

    // Notify clients we're switching level and give them time to receive.
    // We call PreClientTravel directly on any local PlayerPawns (ie listen server)

    ClientURL = ExpandRelativeURL(URL); // gam --- this may fuck us right up but I can't see why...
    ClientURL = ClientURL $ "?XTRAVEL" $ ConsoleCommand("XLIVE CLIENT_TRAVEL"); // sjs

    log("ProcessServerTravel setting ClientTravel:"@ClientURL);

    foreach DynamicActors( class'PlayerController', P )
    {
        if( NetConnection( P.Player)!=None )
        {
            S = ClientURL $ "?Team="$TeamIndex(P);

            log( "Sending" @ P.PlayerReplicationInfo.RetrivePlayerName() @ "to" @ S );

            P.ClientTravel( S, TRAVEL_Relative, bItems );
        }
        else
        {
            LocalPlayer = P;
            P.PreClientTravel();
        }
    }

    if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
        Level.NextURL = Level.NextURL$"?Skin="$LocalPlayer.GetDefaultURL("Skin")
                     $"?Face="$LocalPlayer.GetDefaultURL("Face")
                     $"?Team="$TeamIndex(LocalPlayer) //LocalPlayer.PlayerReplicationInfo.Team.TeamIndex // gam
                     $"?Name="$LocalPlayer.GetDefaultURL("Name")
                     $"?Class="$LocalPlayer.GetDefaultURL("Class")
                     $"?Character="$LocalPlayer.GetDefaultURL("Character"); //amb

    // Switch immediately if not networking.
    if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        Level.NextSwitchCountdown = 0.0;
}

native final function bool PreServerTravel(); // gam

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
    string Options,
    string Address,
    string PlayerID,
    out string Error,
    out string FailCode
)
{
    local bool bSpectator;

    bSpectator = bool(ParseOption( Options, "SpectatorOnly" ));
    AccessControl.PreLogin(Options, Address, PlayerID, Error, FailCode, bSpectator);
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
    local string InOpt;

    InOpt = ParseOption( Options, ParseString );
    if ( InOpt != "" )
    {
        log(ParseString@InOpt);
        return int(InOpt);
    }
    return CurrentValue;
}

function float GetFloatOption(string Options, string ParseString, float CurrentValue)
{
    local string InOpt;

    InOpt = ParseOption( Options, ParseString );
    if ( InOpt != "" )
    {
        log(ParseString@InOpt);
        return float(InOpt);
    }
    return CurrentValue;
}

simulated function GetPublicPrivateSlots( out int PublicSlotsFilled, out int PublicSlotsAvailable, out int PrivateSlotsFilled, out int PrivateSlotsAvailable )
{
    PrivateSlotsFilled = Min( NumInvitedPlayers, NumReservedSlots );
    PrivateSlotsAvailable = NumReservedSlots - PrivateSlotsFilled;

    PublicSlotsFilled = NumPlayers - PrivateSlotsFilled;
    PublicSlotsAvailable = MaxPlayers - (NumReservedSlots + PublicSlotsFilled);
}

// gam ---
event bool AtCapacity( bool bSpectator, bool bInvited )
{
    local int PublicSlotsFilled, PublicSlotsAvailable;
    local int PrivateSlotsFilled, PrivateSlotsAvailable;

    GetPublicPrivateSlots( PublicSlotsFilled, PublicSlotsAvailable, PrivateSlotsFilled, PrivateSlotsAvailable );

    if( Level.NetMode == NM_Standalone )
        return false;

    if( bSpectator )
        return( (NumSpectators >= MaxSpectators) && ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );

    if( bInvited )
        return( (PrivateSlotsAvailable <= 0) && (PublicSlotsAvailable <= 0) );
    else
        return( PublicSlotsAvailable <= 0 );
}

function UpdateCapacity()
{
    local int PublicSlotsFilled, PublicSlotsAvailable;
    local int PrivateSlotsFilled, PrivateSlotsAvailable;

    if( GameReplicationInfo == None )
        return;

    GetPublicPrivateSlots( PublicSlotsFilled, PublicSlotsAvailable, PrivateSlotsFilled, PrivateSlotsAvailable );
    
    log("Updating capacity:");
    log("Public Slots Filled:" @ PublicSlotsFilled);
    log("Public Slots Available:" @ PublicSlotsAvailable);
    log("Private Slots Filled:" @ PrivateSlotsFilled);
    log("Private Slots Available:" @ PrivateSlotsAvailable);

    GameReplicationInfo.bJoinable = !AtCapacity(false,false);
    GameReplicationInfo.bInvitable = !AtCapacity(false,true);

    if( GameReplicationInfo.bJoinable )
        log("Game is joinable");
    else
        log("Game is not joinable");
        
    if( GameReplicationInfo.bInvitable )
        log("Game is invitable");
    else
        log("Game is not invitable");
}

function PostLinearize()
{
    UpdateCapacity();
    Super.PostLinearize();
}

// --- gam

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local NavigationPoint   StartSpot;
    local PlayerController  NewPlayer;
    local Pawn              TestPawn;
    local string            InName, InAdminName, InPassword, InChecksum, InClass, InCharacter; //amb
    local byte              InTeam;
    local bool              bSpectator, bAdmin, bInvited;

    log(self@" Login: opts="$Options);
    
    bSpectator = bool(ParseOption( Options, "SpectatorOnly" ));
	bAdmin = AccessControl.CheckOptionsAdmin(Options);

	// gam ---
    bInvited = bAdmin || bool(ParseOption( Options, "WasInvited" ) );

    if( bInvited )
        log( "Logging in invited player." );
    // --- gam

    // Make sure there is capacity except for admins. (This might have changed since the PreLogin call).
    if ( !bAdmin && AtCapacity(bSpectator, bInvited) ) // gam
    {
        log(self@" AtCapacity??");
        Error=GameMessageClass.Default.MaxedOutMessage;
        return None;
    }

	// If admin, force spectate mode if the server already full of reg. players
	if ( bAdmin && AtCapacity(false,true))
		bSpectator = true;

    BaseMutator.ModifyLogin(Portal, Options);

	InName	   = Left(ParseOption(Options, "Name"), 20);
    InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
    InAdminName= ParseOption ( Options, "AdminName");
    InPassword = ParseOption ( Options, "Password" );
    InChecksum = ParseOption ( Options, "Checksum" );

    log( "Login:" @ InName );
    if( InPassword != "" )
        log( "Password"@InPassword );

    // Try to match up to existing unoccupied player in level,
    // for savegames and coop level switching.
    if(IsA('SinglePlayer')) // sjs - temp hack, still need to handle split clashes.
    {
	    glog( SG, "Looking for save-game pawn "$InName, true ); // sjs[sg] - moved higher
        ForEach DynamicActors(class'Pawn', TestPawn )
        {
		    glog( SG, "checking pawn "$TestPawn$" with owner "$TestPawn.OwnerName$" and controller "$TestPawn.Controller@NewPlayer); 
            if 
            ( 
                TestPawn != None && 
                PlayerController(TestPawn.Controller) != None && 
                PlayerController(TestPawn.Controller).Player == None && 
                TestPawn.Health > 0 &&
                int(TestPawn.OwnerName) == int(PlayerController(TestPawn.Controller).IsSharingScreen())
            )
            {
			    log( "Hooked into save-game pawn "$TestPawn$" with owner "$TestPawn.OwnerName$" and controller "$TestPawn.Controller); // sjs[sg]
                TestPawn.SetRotation(TestPawn.Controller.Rotation);
                TestPawn.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
                TestPawn.PlayWaiting();
			    bWaitingToStartMatch = True;	// rj[sg]
			    bDelayedStart = False;			// rj[sg]
                return PlayerController(TestPawn.Controller);
            }
        }
    }

    // Pick a team (if need teams)
    InTeam = PickTeam(InTeam);

	// Find a start spot.
    StartSpot = FindPlayerStart( None, InTeam, Portal );

    if( StartSpot == None )
    {
        Error = GameMessageClass.Default.FailedPlaceMessage;
        return None;
    }

    // Init player's administrative privileges and log it
    if (AccessControl.AdminLogin(NewPlayer, InAdminName, InPassword))
    {
		AccessControl.AdminEntered(NewPlayer, InAdminName);
    }

    if ( PlayerControllerClass == None )
	{
		assert(PlayerControllerClassName!="");
        PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));
	}

    NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);

    // Handle spawn failure.
    if( NewPlayer == None )
    {
        log("Couldn't spawn player controller of class "$PlayerControllerClass);
        Error = GameMessageClass.Default.FailedSpawnMessage;
        return None;
    }

    NewPlayer.StartSpot = StartSpot;

    // Init player's name
    if( InName=="" )
        InName=DefaultPlayerName;
    //if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
        ChangeName( NewPlayer, InName, false );

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// Apply security to this controller

	NewPlayer.PlayerSecurity = spawn(SecurityClass); // sjs[sg]
	if (NewPlayer.PlayerSecurity==None)
	{
		log("Could not spawn security for player "$NewPlayer,'Security');
	}

    NewPlayer.GotoState('Spectating');

    if ( bSpectator )
    {
        NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
        NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
        NumSpectators++;
        return NewPlayer;
    }

    // Change player's team.
    if ( !ChangeTeam(newPlayer, InTeam) )
    {
        Error = GameMessageClass.Default.FailedTeamMessage;
        return None;
    }

    // Set the player's ID.
    NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

    InClass = ParseOption( Options, "Class" );
    // amb ---

	// cmr ---
	//if (InClass == "")
    //    InClass = DefaultPlayerClassName;
	// --- cmr

	InCharacter = GetCharacterClass(NewPlayer.PlayerReplicationInfo.Team);

	if(InCharacter == "")
	{
		InCharacter = ParseOption(Options, "Character");
	}

	NewPlayer.SetPawnClass(InClass, InCharacter, DefaultPlayerClassName);
    // --- amb

    NumPlayers++;

    // gam ---
    newPlayer.bWasInvited = bInvited;
    // --- gam

    if( newPlayer.bWasInvited )
    {
        log( "NumInvitedPlayers++" );
        NumInvitedPlayers++;
    }
    // --- gam

    // amb ---
    if (IsCoopGame())
        CoopInfo.AdjustPlayerCount();
    // --- amb

    // if delayed start, don't give a pawn to the player yet
    // Normal for multiplayer games
    if ( bDelayedStart )
    {
        NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;
    }

    return newPlayer;
}

function string GetCharacterClass(TeamInfo MyTeam)
{
	local int r;

	r=Rand(2);
	switch(r)
	{
	case 0: 
		return "DMPLAYERA";
		break;
	case 1: 
		return "DMPLAYERB";
		break;
	}
}

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
    local Controller P, Next;
    local Actor A;


	if (GameStats!=None)
		GameStats.StartGame();

    // tell all actors the game is starting
    ForEach AllActors(class'Actor', A)
        A.MatchStarting();

    // start human players first
	glog( SG, "Start human players" );
    for ( P = Level.ControllerList; P!=None; P=P.nextController )
        if ( P.IsA('PlayerController') && (P.Pawn == None) )
        {
            if ( bGameEnded )
                return; // telefrag ended the game with ridiculous frag limit
            else if ( PlayerController(P).CanRestartPlayer()  ) //amb
                RestartPlayer(P);
            SendStartMessage(PlayerController(P));
        }

    // start AI players
	glog( SG, "Start AI players" );
    for ( P = Level.ControllerList; P!=None; P=Next )
    {
        Next = P.nextController; // It's possible that this controller will destroy itself.
        if ( P.bIsPlayer && !P.IsA('PlayerController') && (P.Pawn == None) )
        {
			if ( Level.NetMode == NM_Standalone )
				RestartPlayer(P);
        	else
				P.GotoState('Dead','MPStart');
		}
    }

    bWaitingToStartMatch = false;
}

//
// Restart a player.
//
function RestartPlayer( Controller aPlayer )
{
	local NavigationPoint startSpot;
	local int TeamNum;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;

	glog( SG, "RestartPlayer("$aPlayer$")" );

    if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

	startSpot = FindPlayerStart(aPlayer, TeamNum);
	aPlayer.StartSpot = startSpot;

	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return;
	}

	SpawnPlayerPawn(aPlayer);

	if(aPlayer.Pawn==None) //cmr - this sometimes happens (safely, it appears).  Handle it.
		return;
	aPlayer.Pawn.PlayTeleportEffect(true, true);
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	AddDefaultInventory(aPlayer.Pawn);

	//cmr ---
	aPlayer.NotifyRestarted();
	//--- cmr
	TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
}

function SpawnPlayerPawn(Controller aPlayer)
{
	local class<Pawn> DefaultPlayerClass;

	if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
		BaseMutator.PlayerChangedClass(aPlayer);

	if ( aPlayer.PawnClass != None ) {
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,aPlayer.StartSpot.Location,aPlayer.StartSpot.Rotation);
	}

    if( aPlayer.Pawn==None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(DefaultPlayerClass,,,aPlayer.StartSpot.Location,aPlayer.StartSpot.Rotation);
		if(aPlayer.pawn==None)
		{
			log("Spawn of "$DefaultPlayerClass$" for player "$aPlayer$" failed");
		}
    }
    if ( aPlayer.Pawn == None )
    {
        log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$aPlayer.StartSpot);
        aPlayer.GotoState('Dead');
        return;
    }
    aPlayer.Pawn.Anchor = aPlayer.StartSpot;
	aPlayer.Pawn.LastStartSpot = PlayerStart(aPlayer.StartSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;
}

// gam ---
function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    local PlayerController PC;
    local String PawnClassName;
    local class<Pawn> PawnClass;

    PC = PlayerController( C );

    if( PC != None )
    {
        PawnClassName = PC.GetDefaultURL( "Class" );
		if ( PawnClassName != "" )
			PawnClass = class<Pawn>( DynamicLoadObject( PawnClassName, class'Class') );

        if( PawnClass != None )
            return( PawnClass );
    }

	assert(DefaultPlayerClassName!="");
    return( class<Pawn>( DynamicLoadObject( DefaultPlayerClassName, class'Class' ) ) );
}
// --- gam

function SendStartMessage(PlayerController P)
{
    P.ClearProgressMessages();
}


//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( PlayerController NewPlayer )
{
    local bool locallyControlled;

    // gam ---
    local class<HUD> HudClass;
    local class<Menu> ScoreboardClass;
    local class<Menu> PersonalStatsClass;
    // --- gam
    local String SongName;

	glog( SG, "PostLogin("$NewPlayer$")" );

	UpdateCapacity();

    // Log player's login.
	if (GameStats!=None)
		GameStats.ConnectEvent("Connect",NewPlayer.PlayerReplicationInfo);

    if ( !bDelayedStart )
    {
        // start match, or let player enter, immediately
        bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
        if ( bWaitingToStartMatch )
            StartMatch();
        else if( NewPlayer.CanRestartPlayer() )  //cmr
            RestartPlayer(newPlayer);
        bRestartLevel = Default.bRestartLevel;
    }

    // gam ---
    SongName = Level.Song;

    if( SongName == "" )
        SongName = "Level"$(Rand(NumMusicFiles) + 1);

    if( SongName != "None" )
        NewPlayer.ClientSetMusic( SongName, MTRAN_Fade );
    // --- gam

    // tell client what hud and scoreboard to use

    // gam ---
    if( HUDType == "" )
        log( "No HUDType specified in GameInfo", 'Log' );
    else
    {
        HudClass = class<HUD>(DynamicLoadObject(HUDType, class'Class'));

        if( HudClass == None )
            log( "Can't find HUD class "$HUDType, 'Error' );
    }

    if( ScoreBoardType == "" )
        log( "No ScoreBoardType specified in GameInfo", 'Log' );
    else
    {
        ScoreboardClass = class<Menu>(DynamicLoadObject(ScoreBoardType, class'Class'));

        if( ScoreboardClass == None )
            log( "Can't find ScoreBoard class "$ScoreBoardType, 'Error' );
    }

    if( PersonalStatsDisplayType == "" )
        log( "No PersonalStatsDisplayType specified in GameInfo", 'Log' );
    else
    {
        PersonalStatsClass = class<Menu>(DynamicLoadObject(PersonalStatsDisplayType, class'Class'));

        if( PersonalStatsClass == None )
            log( "Can't find PersonalStatsDisplay class "$PersonalStatsClass, 'Error' );
    }

	NewPlayer.ClientSetHUD( HudClass, ScoreboardClass, PersonalStatsClass );
    // --- gam

	NewPlayer.RequestForceFeedbackProperties(); // jdf

    if ( NewPlayer.Pawn != None )
        NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);

    // gam ---
    if( NewPlayer.PlayerReplicationInfo == None )
        log( "Can't set gamertag/xuid yet -- no PRI!!!", 'Error' );
    else
    {
        NewPlayer.PlayerReplicationInfo.Gamertag = NewPlayer.Gamertag;
        NewPlayer.PlayerReplicationInfo.xuid = NewPlayer.xuid;
        NewPlayer.PlayerReplicationInfo.Skill = NewPlayer.Skill;
        NewPlayer.PlayerReplicationInfo.bIsGuest = NewPlayer.bIsGuest;
        NewPlayer.PlayerReplicationInfo.GuestNum = NewPlayer.GuestNum;
    }
    // --- gam

    locallyControlled = ( Viewport(NewPlayer.Player) != None );
    
    // If we are a server, broadcast a welcome message.
    if( !NewPlayer.bMigratedWithServer && !locallyControlled && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
    {
        BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);
    }

    UpdateCapacity();
}

//
// Player exits.
//
function Logout( Controller Exiting )
{
    local bool bMessage;
	local PlayerController PC;
    local XBoxAddr xbAddr; // jij
    local int PortNo; // jij

    bMessage = true;

    PC = PlayerController(Exiting); // gam

    if ( PC != None )
    {
		if ( AccessControl.AdminLogout( PC ) )
			AccessControl.AdminExited( PC );

        if ( PC.PlayerReplicationInfo.bOnlySpectator )
        {
            bMessage = false;
            if ( Level.NetMode == NM_DedicatedServer )
                NumSpectators--;
        }
        else
        {
            NumPlayers--;

            // gam ---
            if( PC.bWasInvited )
                NumInvitedPlayers--;
            // --- gam

            // amb ---
            if (IsCoopGame())
                CoopInfo.AdjustPlayerCount();
            // --- amb
        }

		// jij ---
		if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
        {
            if (PC.bHasVoice && PC.VoiceChannel >= 0)
                LeaveVoiceChannel(PC,xbAddr,PortNo,PC.VoiceChannel,false);
        }
        // --- jij
    }
    
    if( bMessage && !bGameEnded && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
        BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

	if ( GameStats!=None)
		GameStats.ConnectEvent("Disconnect",Exiting.PlayerReplicationInfo);

	UpdateCapacity();
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
    //default accept all inventory except default weapon (spawned explicitly)
}

// amb ---
function AddGameSpecificInventory(Pawn p)
{
    local Weapon newWeapon;
    local class<Weapon> WeapClass;
    local Inventory Inv;

    // Spawn default weapon.
    WeapClass = BaseMutator.GetDefaultWeapon();
    if( (WeapClass!=None) && (p.FindInventoryType(WeapClass)==None) )
    {
        newWeapon = Spawn(WeapClass,,,p.Location);
        if( newWeapon != None )
        {
            Inv = None;
            // search pawn's inventory for a bCanThrowWeapon==false, if we find one, don't call Bringup
            for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
            {
                if ( Inv.IsA('Weapon') && Weapon(Inv).bCanThrow==false )
                    break;
            }
            newWeapon.GiveTo(p);
            newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
            //if( Inv == None )
            //    newWeapon.BringUp();
        }
    }
}
// --- amb

//
// Spawn any default inventory for the player.
//
function AddDefaultInventory( pawn PlayerPawn )
{
    local Weapon newWeapon;
    local class<Weapon> WeapClass;

    // Spawn default weapon.
    WeapClass = BaseMutator.GetDefaultWeapon();
    if( (WeapClass!=None) && (PlayerPawn.FindInventoryType(WeapClass)==None) )
    {
        newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
        if( newWeapon != None )
        {
            newWeapon.GiveTo(PlayerPawn);
            //newWeapon.BringUp();
            newWeapon.bCanThrow = false; // don't allow default weapon to be thrown out
        }
    }
    SetPlayerDefaults(PlayerPawn);
}

/* SetPlayerDefaults()
 first make sure pawn properties are back to default, then give mutators an opportunity
 to modify them
*/
function SetPlayerDefaults(Pawn PlayerPawn)
{
    PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
    PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
    BaseMutator.ModifyPlayer(PlayerPawn);
}

function EnteredVehicle( Controller C, Pawn Driver, Pawn Vehicle );
function ExitedVehicle( Controller C, Pawn Driver, Pawn Vehicle );


function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
    local Controller C;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
        C.NotifyKilled(Killer, Killed, KilledPawn);
}

function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	// cmr - filter out killed notifications for vehicles (prevents double messages)

	if(Killed == None)
	{
		//log("A controllerless pawn was killed... returning");
		return;
	}

	if( !KilledPawn.IsA('VGVehicle')	)
	{
		if ( Killed.bIsPlayer )
		{
			Killed.PlayerReplicationInfo.Deaths += 1;
			BroadcastDeathMessage(Killer, Killed, damageType);

			if (GameStats!=None)
			{
				if (Killer!=None)
					GameStats.KillEvent(Killer.PlayerReplicationInfo,Killed.PlayerReplicationInfo, DamageType);
				else
					GameStats.KillEvent(None,Killed.PlayerReplicationInfo, DamageType);
			}


			// gam ---
			if( Killer != None )
				Killer.PlayerReplicationInfo.Stats.RegisterKill( Killed, DamageType );

			if( Killed != None )
				Killed.PlayerReplicationInfo.Stats.RegisterDeath( Killer, DamageType );
			// --- gam

		}

		//log("GameInfo::Killed... killer="$GetPlayerName(killer)$", killed="$GetPlayerName(killed));

		ScoreKill(Killer, Killed);
    }
	DiscardInventory(KilledPawn);

	// cmr - filter out killed notifications for vehicles (prevents double messages)
	//if(!KilledPawn.IsA('VGVehicle'))
		NotifyKilled(Killer,Killed,KilledPawn);
}

function string GetPlayerName(Controller c)
{
    if (c==None)
        return "None Controller";
    if (c.PlayerReplicationInfo == None)
        return "None PRI";
    return c.PlayerReplicationInfo.RetrivePlayerName();
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    if ( GameRulesModifiers == None )
        return false;
    return GameRulesModifiers.PreventDeath(Killed,Killer, damageType,HitLocation);
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
    if ( (Killer == Other) || (Killer == None) )
        BroadcastLocalized(self,DeathMessageClass, 1, None, Other.PlayerReplicationInfo, damageType);
    else
        BroadcastLocalized(self,DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, damageType);
}


// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage );

function Kick( string S )
{
    AccessControl.Kick(S);
}

function SessionKickBan( string S ) // sjs
{
    AccessControl.SessionKickBan( S );
}

function KickBan( string S )
{
    AccessControl.KickBan(S);
}

function bool IsOnTeam(Controller Other, int TeamNum)
{
    if ( bTeamGame && (Other != None)
        && (Other.PlayerReplicationInfo.Team != None)
        && (Other.PlayerReplicationInfo.Team.TeamIndex == TeamNum) )
        return true;
    return false;
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    return true;
}

/* Use reduce damage for teamplay modifications, etc.
*/
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional out int bPlayHitEffects )
{
    local int OriginalDamage;
    local armor FirstArmor;

    OriginalDamage = Damage;

    if( injured.PhysicsVolume.bNeutralZone )
        Damage = 0;
    else if ( injured.InGodMode() || injured.IsMatineeProtected()) // God mode
        return 0;
    else if ( (injured.Inventory != None) && (damage > 0) ) //then check if carrying armor
    {
        FirstArmor = injured.inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
        while( (FirstArmor != None) && (Damage > 0) )
        {
            Damage = FirstArmor.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
            FirstArmor = FirstArmor.nextArmor;
        }
    }

    BaseMutator.EventNotify(injured, instigatedBy, 'Damage', Damage); // sjs

    if ( GameRulesModifiers != None )
        return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

    return Damage;
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( Pickup Other )
{
    if( Level.NetMode == NM_StandAlone )
        return false;

    return Other.ReSpawnTime!=0.0;
}

/* Called when pawn has a chance to pick Item up (i.e. when
   the pawn touches a weapon pickup). Should return true if
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup Item )
{
    local byte bAllowPickup;
	local bool bPickup;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, Item, bAllowPickup) )
	{
		bPickup = bAllowPickup == 1;
	}

    if ( Other.Inventory == None )
	{
		bPickup = true;
	}
    else
	{
		bPickup = !Other.Inventory.HandlePickupQuery(Item);
	}
	if ( !bPickup )
	{
		Other.HandlePickupRefused( Item );
	}
    return bPickup;
}

/* Discard a player's inventory after he dies.
*/
function DiscardInventory( Pawn Other )
{
	/*local Inventory Inv;

    while( Inventory != None )
    {
        Inv = Inventory;
        Inv.Destroy();
    }*/
}

/* Try to change a player's name.
*/
function ChangeName( Controller Other, coerce string S, bool bNameChange )
{
    if( S == "" )
        return;

    Other.PlayerReplicationInfo.SetPlayerName(S);
    if( bNameChange && (PlayerController(Other) != None) )
        BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );
}

/* Return whether a team change is allowed.
*/
function bool ChangeTeam(Controller Other, int N)
{
    return true;
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte Current)
{
    return Current;
}

/* Send a player to a URL.
*/
function SendPlayer( PlayerController aPlayer, string URL )
{
    aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

/* Restart the game.
*/
function RestartGame()
{
    local string NextMap;
    local MapList myList;

    if( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
	{
		return;
	}

    log("RestartGame, bPracticeMode:"@bPracticeMode);

    // these server travels should all be relative to the current URL
    if( !bPracticeMode && bChangeLevels && !bAlreadyChanged && (MapListType != "") )
    {
		// open a the nextmap actor for this game type and get the next map
        bAlreadyChanged = true;
        myList = GetMapList(MapListType);
		if (MyList != None)
		{
			NextMap = myList.GetNextMap();
			myList.Destroy();
		}
        if ( NextMap == "" )
            NextMap = GetMapName(MapPrefix, NextMap,1);

        if ( NextMap != "" )
        {
			Level.ServerTravel(NextMap, false);
            return;
        }
    }
    Level.ServerTravel( "?Restart", false );
}

function MapList GetMapList(string MapListType)
{
    local class<MapList> MapListClass;

	if (MapListType != "")
	{
        MapListClass = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
		if (MapListClass != None)
			return Spawn(MapListClass);
	}
	return None;
}

//==========================================================================
// Message broadcasting functions (handled by the BroadCastHandler)

event Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
    BroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
    BroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

/*
 Broadcast a localized message to all players.
 Most message deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event BroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    BroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

//==========================================================================

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller P;

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
        return false;

    // all player cameras focus on winner or final scene (picked by gamerules)
    for ( P=Level.ControllerList; P!=None; P=P.NextController )
        P.ClientGameEnded();
    return true;
}

/* End of game.
*/
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
    local String MapName;

    // don't end game if not really ready
    if ( !CheckEndGame(Winner, Reason) )
    {
		if(bAllowOvertime)
		{
			bOverTime = true;
			GameReplicationInfo.bOverTime = true;
		}
        return;
    }

    GameReplicationInfo.EndGameStats();

    bGameEnded = true;

    TriggerEvent('EndGame', self, None);
    EndLogging(Reason);
    // sjs   
    MapName = Left( GetURLMap(), 1 );
    if(Level.GetAuthMode() == AM_Live && !(MapName ~= "X"))
    {
        ConsoleCommand("XLIVE STAT_DHM_WRITE");
    }
}

function EndLogging(string Reason)
{
	if (GameStats == None)
		return;

	GameStats.EndGame(Reason);
	GameStats.Destroy();
	GameStats = None;
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

    // always pick StartSpot at start of match
    if ( (Player != None) && (Player.StartSpot != None)
        && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
    {
        return Player.StartSpot;
    }

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel;

    // use InTeam if player doesn't have a team yet
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
    {
		if ( Player.PlayerReplicationInfo.Team != None ) {
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
		}
		else {
            Team = 0;
		}
    }
	else {
        Team = InTeam;
	}

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		NewRating = RatePlayerStart(N,InTeam,Player);
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;
		}
	}

	if ( BestStart == None )
	{
		log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");
		foreach AllActors( class 'NavigationPoint', N )
		{
			NewRating = RatePlayerStart(N,0,Player);
			if ( NewRating > BestRating )
			{
				BestRating = NewRating;
				BestStart = N;
			}
		}
	}
//    LastPlayerStart = PlayerStart(BestStart);
	return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start
default implementation is for single player game
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;
	local Pawn apawn;

	P = PlayerStart(N);

    if ( P != None )
	{
	    ForEach VisibleCollidingActors(class'Pawn', apawn, 1000, P.Location)
			return -2000;

//		if(P == LastPlayerStart)
//            return -1000;
        if ( P.bSinglePlayerStart )
		{
			if ( P.bEnabled )
				return 1000;
			return 20;
		}
		return 10;
	}
	return 0;
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
    if ( Scorer != None )
    {
        Scorer.Score += Score;
        /*
        if ( Scorer.Team != None )
            Scorer.Team.Score += Score;
        */
    }
    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreObjective(Scorer,Score);

    CheckScore(Scorer);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;
}

function DeathPenalty(Controller c)
{
    c.PlayerReplicationInfo.Score -= 1;
}

function KillPoint(Controller c)
{
    c.PlayerReplicationInfo.Kills += 1;
    c.PlayerReplicationInfo.Score += 1;
}
function ScoreKill(Controller Killer, Controller Other)
{
    if( (killer == Other) || (killer == None) )
	{
		DeathPenalty(Other);
		if (GameStats!=None)
			GameStats.ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
	}
    else if ( killer.PlayerReplicationInfo != None )
	{
		KillPoint(Killer);
		if (GameStats!=None)
			GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
	}

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

    if (Killer != None) //amb
        CheckScore(Killer.PlayerReplicationInfo);
}

function bool TooManyBots(Controller botToRemove) //amb
{
    return false;
}

function string FindTeamDesignation(actor A)	// Should be subclassed in various team games
{
	return "";
}

// - Given a %X var() return the value.

function string ParseChatPercVar(Controller Who, string Cmd)
{
	// Pass along to Mutators

	if (BaseMutator!=None)
		Cmd = BaseMutator.ParseChatPercVar(Who,Cmd);

	if (Who!=None)
		Cmd = Who.ParseChatPercVar(Cmd);

	return Cmd;
}

// - Parse out % vars for various messages

function string ParseMessageString(Controller Who, String Message)
{
	return Message;
}

function bool IsLookingAt(Controller C, Actor Target)
{
    local Vector V, TraceStart;
    local float Dist;

    TraceStart = C.Pawn.Location + C.Pawn.EyePosition();
    V = Target.Location - TraceStart;
    Dist = VSize(V);
    if (Dist < 1500.0 && Dist > 0 && FastTrace(Target.Location, TraceStart))
    {
        if (V dot Vector(C.Pawn.Rotation) > 0.92 * Dist)
        {
            return true;
        }
    }
    return false;
}

function ReviewJumpSpots();
function EvaluateHint(name EventName, Actor Target);
function CheckHints(PlayerController PC);

// rj --- moved here from GameProfile
static simulated function int GetNumDifficultyLevels()
{
    return cNumDifficultyLevels;
}

static simulated function string GetDifficultyName(int i)
{
    return default.DifficultyNames[i];
}

static simulated function int GetDifficultyLevelIndex(float difficulty)
{
    local int i;

    for (i=1; i < cNumDifficultyLevels; ++i)
        if (difficulty < default.DifficultyLevels[i])
            break;

    return i-1;
}

static simulated function float GetDifficultyLevel(int i)
{
    return default.DifficultyLevels[i];
}
// --- rj

simulated function SaveGame(string description);
function SaveProgress();
function bool RestoreRespawnState(Pawn inPawn);

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local class<Mutator>	mutClass;
	local int i;
	local string diff;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	for ( i = 0; i < GetNumDifficultyLevels(); i++ )
	{
		if ( i > 0 )
		{
			diff = diff $ ";";
		}
		diff = diff $ GetDifficultyLevel(i) $ ";" $ GetDifficultyName(i);
	}
	i=0;
	PlayInfo.AddSetting("Bots",   "Difficulty",			default.GIPropsDisplayText[i++], 0, 50, "Select", diff, "Xb");
	PlayInfo.AddSetting("Game",   "bWeaponStay",        default.GIPropsDisplayText[i++], 1, 60, "Check");
	PlayInfo.AddSetting("Server", "bChangeLevels",      default.GIPropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("Game",   "GoreLevel",          default.GIPropsDisplayText[i++], 0, 120, "Select", default.GIPropsExtras);
	PlayInfo.AddSetting("Game",   "GameSpeed",          default.GIPropsDisplayText[i++], 0, 80, "Text", "8;0.1:3.5");
	PlayInfo.AddSetting("Server", "MaxSpectators",      default.GIPropsDisplayText[i++], 1, 30, "Text", "3;0:32");
	PlayInfo.AddSetting("Server", "MaxPlayers",         default.GIPropsDisplayText[i++], 0, 31, "Text", "3;0:32");
	PlayInfo.AddSetting("Rules",  "GoalScore",          default.GIPropsDisplayText[i++], 0, 31, "Text", "3;0:999");
	PlayInfo.AddSetting("Rules",  "MaxLives",           default.GIPropsDisplayText[i++], 0, 32, "Text", "3;0:999");
	PlayInfo.AddSetting("Rules",  "TimeLimit",          default.GIPropsDisplayText[i++], 0, 33, "Text", "3;0:999");
	PlayInfo.AddSetting("Server", "bEnableStatLogging", default.GIPropsDisplayText[i++], 0, 10, "Check");

	// Add GRI's PIData
	if (default.GameReplicationInfoClass != None)
	{
		default.GameReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	if (default.MutatorClass != "")
		mutClass=class<Mutator>(DynamicLoadObject(default.MutatorClass, class'Class'));
}

defaultproperties
{
     NumMusicFiles=13
     MaxSpectators=2
     MaxPlayers=32
     MaxPlayersOnDedicated=16
     MaxPlayersOnListen=8
     NumVoiceChannels=6
     GameSpeed=1.000000
     FearCostFallOff=0.950000
     VoteLifeTime=30.000000
     DifficultyLevels(1)=2.500000
     DifficultyLevels(2)=5.000000
     DifficultyLevels(3)=7.000000
     VoteTypes(0)="RestartGame"
     VoteTypes(1)="ChangeMap"
     VoteTypes(2)="StartMatch"
     VoteTypes(3)="KickPlayer"
     VoteTypes(4)="MutePlayer"
     FearMarkerClass=Class'Engine.AvoidMarker'
     DeathMessageClass=Class'Engine.LocalMessage'
     GameMessageClass=Class'Engine.GameMessage'
     GameReplicationInfoClass=Class'Engine.GameReplicationInfo'
     GameStatsClass=Class'Engine.GameStats'
     PlayerStatsClass=Class'Engine.PlayerStats'
     SecurityClass=Class'Engine.Security'
     HUDType="XInterfaceHuds.HudADeathmatch"
     PersonalStatsDisplayType="XInterfaceHuds.OverlayPlayerStats"
     DefaultPlayerName="Player"
     GameName="Game"
     MutatorClass="Engine.Mutator"
     AccessControlClass="Engine.AccessControl"
     BroadcastHandlerClass="Engine.BroadcastHandler"
     PlayerControllerClassName="Engine.debug"
     CoopInfoClassName="Engine.CoopInfo"
     VoteTypeStrings(0)="Restart Game"
     VoteTypeStrings(1)="Change Map"
     VoteTypeStrings(2)="Start Match"
     VoteTypeStrings(3)="Kick Player"
     VoteTypeStrings(4)="Mute Player"
     Acronym="???"
     DifficultyNames(0)="Just a Flesh Wound"
     DifficultyNames(1)="Damage Control"
     DifficultyNames(2)="Heroic Measures"
     DifficultyNames(3)="Flatlined"
     StringDedicated="Dedicated"
     GIPropsDisplayText(0)="Bots Skill"
     GIPropsDisplayText(1)="Weapons Stay"
     GIPropsDisplayText(2)="Use Map Rotation"
     GIPropsDisplayText(3)="Gore Level"
     GIPropsDisplayText(4)="Game Speed"
     GIPropsDisplayText(5)="Max Spectators"
     GIPropsDisplayText(6)="Max Players"
     GIPropsDisplayText(7)="Goal Score"
     GIPropsDisplayText(8)="Max Lives"
     GIPropsDisplayText(9)="Time Limit"
     GIPropsDisplayText(10)="World Stats Logging"
     GIPropsExtras="0;Full Gore;1;Reduced Gore"
     bRestartLevel=True
     bPauseable=True
     bCanChangeSkin=True
     bAllowOverTime=True
     bCanViewOthers=True
     bDelayedStart=True
     bChangeLevels=True
     bStartUpLocked=True
}
