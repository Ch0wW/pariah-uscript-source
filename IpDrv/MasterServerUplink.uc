class MasterServerUplink extends MasterServerLink
    config
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EServerToMaster
{
	STM_ClientResponse,
	STM_GameState,
	STM_Stats,
	STM_ClientDisconnectFailed,
	STM_MD5Version,
};

enum EMasterToServer
{
	MTS_ClientChallenge,
	MTS_ClientAuthFailed,
	MTS_Shutdown,
	MTS_MatchID,
	MTS_MD5Update,
};

enum EHeartbeatType
{
	HB_QueryInterface,
	HB_GamePort,
	HB_GamespyQueryPort,
};

// MD5 data coming from the master server.
struct native export MD5UpdateData
{
	var string Guid;
	var string MD5;
	var INT Revision;
};

var GameInfo.ServerResponseLine ServerState;
var MasterServerGameStats GameStats;
var UdpLink	GamespyQueryLink;
var const int MatchID;
var float ReconnectTime;
var bool bReconnectPending;

// config
var globalconfig bool DoUplink;
var globalconfig bool UplinkToGamespy;
var globalconfig bool SendStats;
var globalconfig bool ServerBehindNAT;
var globalconfig bool DoLANBroadcast;

// sorry, no code for you!
native function Reconnect();

event PostBeginPlay()
{
	local UdpGamespyQuery  GamespyQuery;
	local UdpGamespyUplink GamespyUplink;
	local UdpLink Link;

	if( DoUplink )
	{
		// if we're uplinking to gamespy, also spawn the gamespy actors.
		if( UplinkToGamespy )
		{
			// make sure any existing ones are shutdown
			foreach AllObjects( class'UdpLink', Link )
			{
				if ( Link.IsA('UdpGamespyQuery') || Link.IsA('UdpGamespyUplink') )
				{
					`log( "Shutting down gamespy link:"@Link );
					Link.Shutdown();
				}
			}

			GamespyQuery = Spawn( class'UdpGamespyQuery' );
			
			// FMasterServerUplink needs this for NAT.
			GamespyQueryLink = GamespyQuery;

			GamespyUplink = Spawn( class'UdpGamespyUplink' );
		}

		// If we're sending stats, 
		if( SendStats )
		{
			foreach AllActors(class'MasterServerGameStats', GameStats )
			{
				if( GameStats.Uplink == None )
					GameStats.Uplink = Self;
				else
					GameStats = None;
				break;
			}		
			if( GameStats == None )
				Log("MasterServerUplink: MasterServerGameStats not found - stats uploading disabled.");
		}
	}

	Reconnect();
}

// Called when the connection to the master server fails or doesn't connect.
event ConnectionFailed( bool bShouldReconnect )
{
	Log("Master server connection failed");
	bReconnectPending = bShouldReconnect;
	ReconnectTime = 0;
}

// Called when we should refresh the game state
event Refresh()
{
	Level.Game.GetServerInfo(ServerState);
	Level.Game.GetServerDetails(ServerState);
	Level.Game.GetServerPlayers(ServerState);
}

// Call to log a stat line
native event bool LogStatLine( string StatLine );

// Handle disconnection.
simulated function Tick( float Delta )
{
	Super.Tick(Delta);
	ReconnectTime = ReconnectTime + Delta;
	if( bReconnectPending )
	{
		if( ReconnectTime > 10.0 )
		{
			Log("Attempting to reconnect to master server");
			bReconnectPending = False;
			Reconnect();
		}
	}
}

defaultproperties
{
     DoUplink=True
     UplinkToGamespy=True
     SendStats=True
}
