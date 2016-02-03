//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native nativereplication;

// also replicate here player class and skins and any other seldom changed stuff
var float				Score;			// Player's current score.
var float				Deaths;			// Number of player's deaths.
var float				Specials;       // Number of player's headshots, etc.
var float				Kills;			// Number of player's kills.
var bool                bLiveStatsPosted;

// XJ The threat this player represents to others
var float				ThreatLevel;

var Decoration			HasFlag;
var int					Ping;
// gam ---
var Volume				PlayerVolume;
var ZoneInfo            PlayerZone;
// --- gam
var int					NumLives;

var private string		PlayerName;		// Player name, or blank if none.
var string				CharacterName, OldCharacterName;
var string				OldName, PreviousName;		// Temporary value.
var int					PlayerID;		// Unique id number.
var TeamInfo			Team;			// Player Team
var int					TeamID;			// Player position in team.
var class<VoicePack>	VoiceType;
var bool				bAdmin;			// Player logged in as Administrator
var bool				bIsFemale;
var bool				bIsSpectator;
var bool				bOnlySpectator;
var bool				bWaitingPlayer;
var bool				bReadyToPlay;
var bool				bOutOfLives;
var bool				bBot;

// Time elapsed.
var int					StartTime;
var float               PlayTime;       // jjs - total time actually running around and shooting

// amb --- 
// Coop stuff
var bool                bCoopGame;
var byte                CharSelection;
 				
// sjs --- vote throttle
var transient float     NextVoteCallTime;   // time when this player may call another vote
var float               VoteCallThrottle;   // delay seconds the player must wait until they can all another vote
// --- sjs

var bool                bIsPassTarget;
var localized String    StringSpectating;
var localized String	StringUnknown;
var localized String	StringGuest;

// AsP --- 
var byte Health; 
var byte Shield;
//-- AsP

// gam --- needed for XLive players list
var String xuid;
var String Gamertag;
var bool bIsGuest;
var int GuestNum;
var bool bHasVoice;
var bool bIsTalking; // Specifically NOT replicated; stuffed by local audio system!
var int Skill;
// --- gam

var PlayerStats         Stats; // sjs - not replicated, but filled by RPC instead

// jij ---
var int VoiceChannel;
// --- jij

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == Role_Authority) )
		Score, Deaths, Specials, Kills, HasFlag, PlayerVolume, PlayerZone,
		PlayerName, Team, TeamID, VoiceType, bIsFemale, bAdmin, 
		bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
		bOutOfLives, bIsPassTarget, CharacterName,
		xuid, Gamertag, bIsGuest, GuestNum, bHasVoice, Skill, VoiceChannel, // gam, jij
		ThreatLevel;	// XJ
	reliable if ( bNetDirty && (!bNetOwner || bDemoRecording) && (Role == Role_Authority) )
		Ping; 

    // AsP ---
    unreliable if ( bNetDirty && (Role == Role_Authority) )
        Health, Shield, PlayTime;
    // --- AsP

	reliable if ( bNetInitial && (Role == Role_Authority) )
		bBot;

    // amb --- 
    reliable if ( bCoopGame && bNetInitial && (Role == Role_Authority) )
		bCoopGame, PlayerID;
    // --- amb
}

function PostBeginPlay()
{
    // amb ---
    if (AIController(Owner) != None)
        bBot = true;
    if (Level.Game.IsCoopGame())
        bCoopGame = true;
    // --- amb
    StartTime = Level.TimeSeconds;
	Timer();
	SetTimer(2.f, true);
}

simulated function PostNetBeginPlay()
{
	local GameReplicationInfo GRI;

	ForEach DynamicActors(class'GameReplicationInfo',GRI)
	{
		GRI.AddPRI(self);
		break;
	}
}

simulated function Destroyed()
{
	local GameReplicationInfo GRI;
	
	ForEach DynamicActors(class'GameReplicationInfo',GRI)
        GRI.RemovePRI(self);
        
    if( Stats != None )
        Stats.Destroy();

    Super.Destroyed();
}

function SetCharacterName(string S)
{
	CharacterName = S;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
	Deaths = 0;
    Kills = 0;
    Specials = 0;
	HasFlag = None;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
    PlayTime = 0.0;
	ThreatLevel = 0.0;
}

simulated event string GetLivePlayerName()
{
    if( bBot )
    {
        return( PlayerName );
    }

    if( Gamertag == "" )
    {
        log(PlayerName @ "has no Gamertag and is in a Live game!", 'Error');    
        return("");
    }
    
    if( bIsGuest )
    {
        return( ReplaceSubString( ReplaceSubString( StringGuest, "<GAMERTAG>", Gamertag ), "<GUESTNUM>", String(GuestNum) ) );
    }
    else
    {
        return( Gamertag );
    }
}

simulated function String GetPrivatePlayerName()
{
    return PlayerName;
}

simulated function string RetrivePlayerName()
{
    if( Level.GetAuthMode() == AM_Live )
    {
        return( GetLivePlayerName() );
    }
    else
    {
        return PlayerName;
    }
}

simulated function string GetLocationName()
{
    if( ( PlayerVolume == None ) && ( PlayerZone == None ) )
        return StringSpectating;
    
	if( ( PlayerVolume != None ) && ( PlayerVolume.LocationName != "" ) )
		return PlayerVolume.LocationName;
	else if( PlayerZone != None && ( PlayerZone.LocationName != "" )  )
		return PlayerZone.LocationName;
    else
        return StringUnknown;
}

event UpdateCharacter();
simulated function LoadPlayer();

function UpdatePlayerLocation()
{
    local Volume V, Best;
    local Pawn P;
    local Controller C;
    
    C = Controller(Owner);

    if( C != None )
        P = C.Pawn;
    
    if( P == None )
    {
        PlayerVolume = None;
        PlayerZone = None;
        return;
    }
    
    if ( PlayerZone != P.Region.Zone )
		PlayerZone = P.Region.Zone;

    foreach P.TouchingActors( class'Volume', V )
    {
        if( V.LocationName == "") 
            continue;
        
        if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
            continue;
            
        if( V.Encompasses(P) )
            Best = V;
    }
    if ( PlayerVolume != Best )
		PlayerVolume = Best;
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( Team != None )
		Canvas.DrawText("     PlayerName "$PlayerName$" Team "$Team.RetrivePlayerName()$" has flag "$HasFlag);
	else
		Canvas.DrawText("     PlayerName "$PlayerName$" NO Team");
}
 					
function Timer()
{
    local Controller C;

    C = Controller(Owner);

    if( (C != None) && (C.Pawn != None) )
    {
        Health = byte( C.Pawn.Health );
        Shield = byte( C.Pawn.GetShieldStrength() );
    }

	UpdatePlayerLocation();
    
	if( !bBot && Level.NetMode != NM_StandAlone )
		Ping = int(C.ConsoleCommand("GETPING"));

    if( bBot && !C.IsInState('Dead') )
        PlayTime += 2.0 / Level.TimeDilation;
}

function SetPlayerName(string S)
{
    log("PRI SetPlayerName: "$S);
	OldName = PlayerName;
	PlayerName = S;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;	
	bWaitingPlayer = B;
}

// amb ---
function int GetPlayerRecordIndex();
// --- amb

defaultproperties
{
     Skill=50
     StringSpectating="Spectating"
     StringUnknown="Unknown"
     StringGuest="<GAMERTAG> Guest <GUESTNUM>"
     CharSelection=255
     bIsGuest=True
}
