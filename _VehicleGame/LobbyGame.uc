class LobbyGame extends GameInfo;

var int DEFAULTMAXPLAYERS;
var int maxSlots;
var String launchArgs;

event InitGame( string Options, out string Error )
{
	local String s, sGameType;
	log( "Options= " $ Options );
    Super.InitGame( Options, Error );
    log( "Enabling gamepad input merging (in menu subsystem).", 'Log' );

	launchArgs = Options;

	s = ParseOption(Options, "MaxPlayers");
	if(s == "")
		maxSlots = DEFAULTMAXPLAYERS;
	else
		maxSlots = int(s);

	sGameType = ParseOption( Options, "GAMETYPE");
	
	if ( sGameType ~= "XGame.xDeathMatch" ) // ugly hack of death
	{
		bTeamGame = false;
	
	}
	else{
		bTeamGame = true;
	}
}

event PostBeginPlay()
{
	local int i;
	local LobbyGRI lgri;
	
	Super.PostBeginPlay();

	
	lgri = LobbyGRI(GameReplicationInfo);
	for(i = 0; i < maxSlots; i++)
	{
		lgri.PlayerSlots[i] = None;
	}
	lgri.maxSlots = maxSlots;	
	lgri.launchArgs = launchArgs;
	lgri.bTeamGame = bTeamGame;

}

event PostLogin( PlayerController NewPlayer )
{
	local LobbyGRI lgri;
	
	lgri = LobbyGRI(GameReplicationInfo);
	lgri.AddPlayer(NewPlayer.PlayerReplicationInfo);

	NewPlayer.GotoState('WaitingInLobby');
}

function Logout( Controller Exiting )
{
	local LobbyGRI lgri;
	lgri = LobbyGRI(GameReplicationInfo);
	lgri.RemovePlayer(Exiting.PlayerReplicationInfo);

	Super.Logout(Exiting);

}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint N;
	//we don't actually care about a startspot
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		return N;
	}
}

event string GetBeaconText()
{
	// gam ---
	local String BeaconText;
    local String MapName;
    local PlayerController PC;
    local String HostName;
	local String GameType;
	local String MaxLaunchPlayers;

    HostName = Level.ComputerName;

    foreach DynamicActors( class'PlayerController', PC )
    {
        if( (NetConnection(PC.Player) == None) && (PC.PlayerReplicationInfo != None) )
        {
            HostName = PC.PlayerReplicationInfo.RetrivePlayerName();
            break;
        }
    }

	// mh ---
    //MapName = String(Level);
    //MapName = Left( MapName, InStr(MapName, ".") );
	MapName = ParseOption(launchArgs, "MAP"); //xmatt_change
	Acronym = Left(MapName, InStr(MapName, "-") );
	MaxLaunchPlayers = ParseOption(launchArgs, "MaxPlayers");
	GameType = ParseOption(launchArgs, "GAMETYPE");
	
	// --- mh
    BeaconText = 
        "###" @
        "\"" $ HostName $ "\""  @
        GameType @
        Acronym @
        "\"" $ MapName $ "\"" @
        NumPlayers @
        MaxLaunchPlayers @
		true @	//using this bool as an indication that we're going to the lobby.
		Level.GetCustomMap() @ //to indicate the server is running a custom map (xmatt)
        "###";
	
    return( BeaconText );        
    // --- gam
}

/*
	Overridden to use the teams from the Lobby Menu instead of current PRI.TeamInfo
*/
function int TeamIndex(PlayerController P)
{
	local int i;
	local LobbyGRI lgri;
	lgri = LobbyGRI(GameReplicationInfo);
	
	for(i = 0; i < maxSlots; i++)
	{
		if(lgri.PlayerSlots[i] == P.PlayerReplicationInfo)
		{
			return i%2;
		}
	}
	return 255;
}

defaultproperties
{
     DEFAULTMAXPLAYERS=8
     GameReplicationInfoClass=Class'VehicleGame.LobbyGRI'
     HUDType="Engine.HUD"
     PlayerControllerClassName="VehicleGame.LobbyPlayer"
     bPauseable=False
}
