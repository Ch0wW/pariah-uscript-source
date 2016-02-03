// This is a server-browser helper function; it would be in XInterfaceMP if that package were native.

class ServerList extends Info
    native exportstructs;
    
struct ServerResponseLineEx extends GameInfo.ServerResponseLine
{
    var() String GameTypeAcronym;
    var() String LongMapName;

    var() byte bCustom;
    var() byte bTeamGame;
    var() byte bFavourite;
};

struct long StoredServer
{
	var() string IP;
	var() int QueryPort;
	var() int ServerID;
	var() int Port;
	var() string ServerName;
};

var() config Array<StoredServer> Favourites;
var() config Array<StoredServer> Recent;
var config int MaxRecentServers;

const SSF_Ascending = 1;
const SSF_Descending = -1;

enum EServerSortField
{
    SSF_Name,
    SSF_Map,
    SSF_GameType,
    SSF_CurrentPlayers,
    SSF_Ping
};

struct native export ServerSortKey
{
    var() EServerSortField Field;
    var() int              SortDirection; // direction is FName cocked for case
};

var() Array<GameInfo.ServerResponseLine>    PendingPing;
var() Array<GameInfo.ServerResponseLine>    BeingPinged;
var() Array<GameInfo.ServerResponseLine>    TimedOut;
var() Array<ServerResponseLineEx>           Pinged;

var() GameInfo.ServerResponseLine PingedServer; // Scratch because you can't pass local structs to native function.

var() Array<String>     PorkAdjectives;
var() Array<String>     PorkNouns;
var() Array<String>     PorkMaps;
var() int               PorkServers;
var() int               TotalPorkServers;

native simulated function SetServerSortKey( out Array<ServerSortKey> SortKeys );
native simulated function int AddPingedServer(); // Returns insertion point
native simulated function UpdatePingedServer( int ServerID, bool TimedOut ); // Finds the pinged server in the pinged list and updates it.

// This is required because UnrealScript's 20x faster than java code doesn't handle polymorphic structs very well.
native simulated function SendFullPing( MasterServerClient MSC, int SelectedPosition );

// This one implicitly takes the last server off of the PendingPing list and moves it to the BeingPinged list.
native simulated function SendAutoPing( MasterServerClient MSC, bool DoFullPing );

delegate PorkReceivedPingInfo( int ServerID, MasterServerClient.EPingCause PingCause, GameInfo.ServerResponseLine s );

simulated function int Num()
{
    return(Pinged.Length);
}

simulated function Pork()
{
    TotalPorkServers += 200;
    SetTimer( 0.01, true );
}

simulated function LoadFavourites()
{
    local int i;

    Reset();
    
    for( i = 0; i < Favourites.Length; ++i )
    {
        PendingPing[i].IP = Favourites[i].IP;
        PendingPing[i].QueryPort = Favourites[i].QueryPort;
        PendingPing[i].ServerID = Favourites[i].ServerID;
        PendingPing[i].Port = Favourites[i].Port;
        PendingPing[i].ServerName = Favourites[i].ServerName;
    }
}

simulated function LoadRecent()
{
    local int i;

    Reset();
    
    for( i = 0; i < Recent.Length; ++i )
    {
        PendingPing[i].IP = Recent[i].IP;
        PendingPing[i].QueryPort = Recent[i].QueryPort;
        PendingPing[i].ServerID = Recent[i].ServerID;
        PendingPing[i].Port = Recent[i].Port;
        PendingPing[i].ServerName = Recent[i].ServerName;
    }
}

simulated function Reset()
{
    PendingPing.Remove( 0, PendingPing.Length );
    BeingPinged.Remove( 0, BeingPinged.Length );
    TimedOut.Remove( 0, TimedOut.Length );
    Pinged.Remove( 0, Pinged.Length );

    PorkServers = 0;
    TotalPorkServers = 0;
    SetTimer(0, false);
}

simulated function ClearPendingPings()
{
    local int i;
    
    if( BeingPinged.Length > 0 )
    {
        for( i = 0; i < BeingPinged.Length; ++i )
        {
            TimedOut[TimedOut.Length] = BeingPinged[i];
        }
        
        BeingPinged.Remove( 0, BeingPinged.Length );
    }
    
    if( PendingPing.Length > 0 )
    {
        for( i = 0; i < PendingPing.Length; ++i )
        {
            TimedOut[TimedOut.Length] = PendingPing[i];
        }
        
        PendingPing.Remove( 0, PendingPing.Length );
    }
        
    PorkServers = 0;
    TotalPorkServers = 0;
    SetTimer(0, false);
}

simulated function AddRecent( ServerList.ServerResponseLineEx Server )
{
    local int i;

    for( i = 0; i < Recent.Length; ++i )
    {
        if( (Recent[i].IP == Server.IP) && (Recent[i].Port == Server.Port) )
        {
            Recent.Remove(i, 1);
            break;
        }
    }
    
    if( Recent.Length > MaxRecentServers )
    {
        Recent.Remove(0, 1);
    }

    i = Recent.Length;
    Recent[i].IP = Server.IP;
    Recent[i].QueryPort = Server.QueryPort;
    Recent[i].ServerID = Server.ServerID;
    Recent[i].Port = Server.Port;
    Recent[i].ServerName = Server.ServerName;

    SaveConfig();
}

static simulated function bool IsFavourite( String IP, int Port )
{
    local int i;

    for( i = 0; i < default.Favourites.Length; ++i )
    {
        if( (default.Favourites[i].IP == IP) && (default.Favourites[i].Port == Port) )
        {
            return(true);
        }
    }

    return(false);
}

simulated function AddFavourite( out ServerList.ServerResponseLineEx Server )
{
    local int i;

    Server.bFavourite = 1;

    for( i = 0; i < Favourites.Length; ++i )
    {
        if( (Favourites[i].IP == Server.IP) && (Favourites[i].Port == Server.Port) )
        {
            Favourites.Remove(i, 1);
            break;
        }
    }

    i = Favourites.Length;
    Favourites[i].IP = Server.IP;
    Favourites[i].QueryPort = Server.QueryPort;
    Favourites[i].ServerID = Server.ServerID;
    Favourites[i].Port = Server.Port;
    Favourites[i].ServerName = Server.ServerName;

    SaveConfig();
}

simulated function DelFavourite( out ServerList.ServerResponseLineEx Server )
{
    local int i;

    Server.bFavourite = 0;

    for( i = 0; i < Favourites.Length; ++i )
    {
        if( (Favourites[i].IP == Server.IP) && (Favourites[i].Port == Server.Port) )
        {
            Favourites.Remove(i, 1);
            break;
        }
    }   

    SaveConfig();
}

native simulated function RefreshServer( out ServerList.ServerResponseLineEx Server );

simulated function Timer()
{
    local int i, j, si;
    local GameInfo.ServerResponseLine Server;
    
    if( PorkServers == TotalPorkServers )
    {
        return;
    }
    
    for( i = Rand(Min(5,PorkServers)); i >= 0; --i )
    {
        Server.ServerInfo.Remove( 0, Server.ServerInfo.Length );
    
        Server.ServerId = Rand(100000);
        Server.IP = "10.1." $ Rand(255) $ "." $ Rand(255);
        Server.Port = 8000 + Rand(1000);
        Server.QueryPort = 8000 + Rand(1000);
        Server.ServerName = PorkNouns[Rand(PorkNouns.Length)];
        
        for( j = Rand(5); j >= 0; --j )
        {
            Server.ServerName = PorkAdjectives[Rand(PorkAdjectives.Length)] @ Server.ServerName;
        }
        
        Server.MapName = PorkMaps[Rand(PorkMaps.Length)];
        
        if( InStr( Server.MapName, "DM-" ) == 0 )
        {
            Server.GameType = "xDeathMatch";
        }
        else
        {
            Server.GameType = "xCTFGame";
        }
        
        Server.MaxPlayers = 4 + Rand(28);
        Server.CurrentPlayers = Rand(Server.MaxPlayers + 1);
        Server.Ping = 20 + Rand(200);
        
        for( j = 0; j < Server.CurrentPlayers; ++j )
        {
            Server.PlayerInfo[j].PlayerNum = j;
            Server.PlayerInfo[j].PlayerName = PorkAdjectives[Rand(PorkAdjectives.Length)] @ "Bob";
            Server.PlayerInfo[j].Ping = 20 + Rand(200);
            Server.PlayerInfo[j].Score = Rand(50);
        }
        
        if( Rand(100) < 25 )
        {
            Server.bDedicated = 1;
        }
        else
        {
            Server.bDedicated = 0;
        }
    
        if( Rand(100) < 10 )
        {
	        Server.bPrivate = 1;
        }
        else
        {
	        Server.bPrivate = 0;
        }
        
        if( Rand(100) < 50 )
        {
            si = Server.ServerInfo.Length;
	        Server.ServerInfo[si].Key = "friendlyfire";
	        Server.ServerInfo[si].Value = "true";
        }
        else
        {
            si = Server.ServerInfo.Length;
	        Server.ServerInfo[si].Key = "friendlyfire";
	        Server.ServerInfo[si].Value = "false";
        }

        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "goalscore";
	    Server.ServerInfo[si].Value = String(Rand(10));

        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "timelimit";
	    Server.ServerInfo[si].Value = String(Rand(12) * 5);

        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "initialbots";
	    Server.ServerInfo[si].Value = String(Rand(16) / 4);
       
        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "initialwecs";
	    Server.ServerInfo[si].Value = String(Rand(16) / 4);
        
        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "adminname";
	    Server.ServerInfo[si].Value = PorkAdjectives[Rand(PorkAdjectives.Length)] @ "Bob";
        
        si = Server.ServerInfo.Length;
	    Server.ServerInfo[si].Key = "adminemail";
	    Server.ServerInfo[si].Value = PorkAdjectives[Rand(PorkAdjectives.Length)] $ "bob@" $ PorkAdjectives[Rand(PorkAdjectives.Length)] $ PorkNouns[Rand(PorkNouns.Length)] $ ".com" ;
        
        BeingPinged[BeingPinged.Length] = Server;
        PorkReceivedPingInfo( Server.ServerId, PC_AutoPing, Server );

        if( ++PorkServers == TotalPorkServers )
        {
            SetTimer( 0, false );
            return;
        }
    }
}

defaultproperties
{
     MaxRecentServers=32
     PorkAdjectives(0)="Super"
     PorkAdjectives(1)="Mega"
     PorkAdjectives(2)="Wicked"
     PorkAdjectives(3)="Poison"
     PorkAdjectives(4)="Rusty"
     PorkAdjectives(5)="Smashing"
     PorkAdjectives(6)="Fiery"
     PorkAdjectives(7)="Liquid"
     PorkAdjectives(8)="Raging"
     PorkAdjectives(9)="Unholy"
     PorkAdjectives(10)="Reeking"
     PorkAdjectives(11)="Dirty"
     PorkAdjectives(12)="Dusty"
     PorkAdjectives(13)="Dry"
     PorkAdjectives(14)="Burning"
     PorkAdjectives(15)="Silent"
     PorkAdjectives(16)="Screaming"
     PorkAdjectives(17)="Eyeless"
     PorkAdjectives(18)="Dark"
     PorkNouns(0)="Fields"
     PorkNouns(1)="Death"
     PorkNouns(2)="Carnage"
     PorkNouns(3)="Blunder"
     PorkNouns(4)="Trap"
     PorkNouns(5)="Pit"
     PorkNouns(6)="Prison"
     PorkNouns(7)="Wreckage"
     PorkNouns(8)="Pools"
     PorkNouns(9)="Arena"
     PorkNouns(10)="Prosthetics"
     PorkNouns(11)="Scissors"
     PorkNouns(12)="Boom"
     PorkNouns(13)="Oblivion"
     PorkNouns(14)="Soil"
     PorkNouns(15)="Alpha"
     PorkNouns(16)="Blade"
     PorkMaps(0)="CTF-CanyonRaider"
     PorkMaps(1)="CTF-Recoil"
     PorkMaps(2)="CTF-RiverBed"
     PorkMaps(3)="CTF-Survivor"
     PorkMaps(4)="CTF-Train"
     PorkMaps(5)="CTF-Wasteland"
     PorkMaps(6)="DM-AudioTest"
     PorkMaps(7)="DM-BreakDown"
     PorkMaps(8)="DM-Downloadable"
     PorkMaps(9)="DM-MistGully"
     PorkMaps(10)="DM-Scavenger"
     PorkMaps(11)="DM-Soak"
     PorkMaps(12)="DM-Twisted"
}
