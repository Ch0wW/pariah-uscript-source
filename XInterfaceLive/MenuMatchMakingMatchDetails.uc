class MenuMatchMakingMatchDetails extends MenuTemplateTitledBXA;

// Args: [QUICK_MATCH | OPTI_MATCH]

struct ServerInfo
{
    // From Matchmaking server:
    var() String HostName;
    var() String MapName;
    var() String GameType;
    var() int Dedicated;
    var() int NumPlayers;
    var() int MaxPlayers;
    var() int AverageSkill;
    var() int BandwidthUsage;
    var() int bIsCustomMap;
    var() String CustomMapName;

    // Connection info:
    var() String URLAppend;

    // Sythesized:
    var() String ShortName;
    var() String LongName;
    var() String GameName;
    var() String GameAcronym;
    
    // Updated:
    var() int Ping;
};

const OPTION_COUNT = 8;

var() MenuText      Labels[OPTION_COUNT];
var() MenuText      Values[OPTION_COUNT];

var() Array<ServerInfo> Servers;
var() int CurrentServer;
var() localized String PingLabels[5];
var() bool DoingProbes;

var() bool FakePings;

simulated function Init( String Args )
{
    Super.Init( Args );

    if( Args ~= "OPTI_MATCH" )
    {
        HideXButton( 1 );
    }
    else
    {
        ParseServerList( Servers, PlayerController(Owner) );
        class'MenuMatchMakingMatchDetails'.static.BeginServerProbes(self, Servers);
        ShowNextServer();
        SetTimer(1.0, true);
        DoingProbes = true; 
        
        if( Servers.Length < 2 )
            HideXButton( 1 );
    }

    LayoutArray( Labels[0], 'DetailLabelsLayout' );
    LayoutArray( Values[0], 'DetailValuesLayout' );
}

simulated function Timer()
{
    class'MenuMatchMakingMatchDetails'.static.RefreshServerProbes(self, Servers);
    if( Servers.Length == 0 )
        return;
    ShowServer( Servers[CurrentServer] );
}

simulated function Destroyed()
{
    if( DoingProbes )
    {
        class'MenuMatchMakingMatchDetails'.static.EndServerProbe(self);
    }
    Super.Destroyed();
}

static simulated function BeginServerProbes( MenuBase menu, out Array<ServerInfo> Servers )
{
    local string ProbeString;
    local int i;

    for( i=0; i<Servers.Length; i++ )
    {
        if( Servers[i].URLAppend != "" )
            ProbeString = ProbeString @ "0.0.0.1" $ Servers[i].URLAppend;
    }
    menu.ConsoleCommand("XLIVE QOS_LOOKUP"@ProbeString);
}

static simulated function bool RefreshServerProbes( MenuBase menu, out Array<ServerInfo> Servers )
{
    local string ProbeResponse;
    local int i, p;
    local bool Dirty;

    ProbeResponse = menu.ConsoleCommand("XLIVE QOS_REFRESH_RESULTS");

    for( i=0; i<Servers.Length; i++ )
    {
        p = int(ParseToken(ProbeResponse));

        if( default.FakePings )
        {
            if( Servers[i].Ping < 0 )
                p = Clamp(Rand(100) - 90, -1, 100);
            else
                p = Servers[i].Ping;
        }
        
        if( Servers[i].Ping != p )
        {
            Servers[i].Ping = p;
            Dirty = true;
        }
    }
    
    return Dirty;
}

static simulated function EndServerProbe(MenuBase menu)
{
    menu.ConsoleCommand("XLIVE QOS_RELEASE");
}

static simulated function bool InOrder( out ServerInfo A, out ServerInfo B, PlayerController PC )
{
    local int ASkillDistance, BSkillDistance;

    if( A.Dedicated > B.Dedicated )
        return true;

    if( A.Dedicated < B.Dedicated )
        return false;

    if( (A.NumPlayers != 0) && (B.NumPlayers == 0) )
        return true;

    if( (A.NumPlayers == 0) && (B.NumPlayers != 0) )
        return false;

    if( (A.NumPlayers == 0) && (B.NumPlayers == 0) )
        return true;

    ASkillDistance = Abs( PC.Skill - A.AverageSkill );
    BSkillDistance = Abs( PC.Skill - B.AverageSkill );
    
    if( ASkillDistance < BSkillDistance )
        return true;
    
    if( ASkillDistance > BSkillDistance )
        return false;
    
    return true;
}

static simulated function SortList( out Array<ServerInfo> Servers, PlayerController PC )
{
    local int i, j;
    local ServerInfo tmp;

    for (i=0; i<Servers.Length-1; i++)
    {
        for (j=i+1; j<Servers.Length; j++)
        {
           if( !InOrder( Servers[i], Servers[j], PC ) )
            {
                tmp = Servers[i];
                Servers[i] = Servers[j];
                Servers[j] = tmp;
            }
        }
    }
}


static simulated function ParseServerList( out Array<ServerInfo> Servers, PlayerController PC )
{
    local int Count;
    local int i, j;
    local String ServerLine, S;

    local Array<xUtil.GameTypeRecord> GameTypeRecords;
    local Array<xUtil.MapRecord> MapRecords;

    class'xUtil'.static.GetGameTypeList( GameTypeRecords );
    class'xUtil'.static.GetMapList( MapRecords, true, false );

    Count = int( PC.ConsoleCommand("XLIVE GETQUERYCOUNT") );

    Servers.Length = 0;

    for( i = 0; i < Count; i++ )
    {
        ServerLine = PC.ConsoleCommand("XLIVE GETQUERYRESULTS" @ i );

        Servers[i].HostName = ParseToken(ServerLine);
        Servers[i].MapName = ParseToken(ServerLine);
        Servers[i].GameType = ParseToken(ServerLine);
        Servers[i].Dedicated = int(ParseToken(ServerLine));
        Servers[i].NumPlayers = int(ParseToken(ServerLine));
        Servers[i].MaxPlayers = int(ParseToken(ServerLine));
        Servers[i].AverageSkill = int(ParseToken(ServerLine));
        Servers[i].BandwidthUsage = int(ParseToken(ServerLine));
        Servers[i].bIsCustomMap = int(ParseToken(ServerLine));
        Servers[i].CustomMapName = ParseToken(ServerLine);
        Servers[i].URLAppend = ParseToken(ServerLine);
        
        assert( Servers[i].URLAppend != "###" );
        
        S = ParseToken(ServerLine);

        if( S != "###" )
        {
            log("Expected ### got:"@ S, 'Error' );
            break;
        }
        
        if( Servers[i].bIsCustomMap == 0 )
        {
            Servers[i].LongName = Servers[i].MapName;

            for( j = 0; j < MapRecords.Length; j++ )
            {
                if( MapRecords[j].MapName ~= Servers[i].MapName )
                {
                    Servers[i].LongName = MapRecords[j].LongName;
                    break;
                }
            }
            
            if( j >= MapRecords.Length )
            {
                log("Could not find map record for" @ Servers[i].MapName);
            }
            
            j = InStr( Servers[i].MapName, "-" );

            if( (j < 0) || (j > 5) )
                j = 0;
            else
                j++;

            Servers[i].ShortName = Right( Servers[i].MapName, Len(Servers[i].MapName) - j );
        }
        else
        {
            Servers[i].LongName = GetMapDisplayName( Servers[i].CustomMapName );
            Servers[i].ShortName = Servers[i].LongName;
        }

        Servers[i].GameName = Servers[i].GameType;
        Servers[i].GameAcronym = "???";

        for( j = 0; j < GameTypeRecords.Length; j++ )
        {
            if( GameTypeRecords[j].ClassName ~= Servers[i].GameType )
            {
                Servers[i].GameName = GameTypeRecords[j].GameName;
                Servers[i].GameAcronym = GameTypeRecords[j].Acronym;
                break;
            }
        }

        Servers[i].Ping = -1; // unknown
    }
    
    log("Sorting server list based on skill of"@PC.Skill);
    SortList( Servers, PC );
}

simulated function string PingFriendlyName(int Ping)
{
    if( Ping == -1 )
        return PingLabels[0]; // no ping reply
    else if( Ping < 50 )
        return PingLabels[1];
    else if( Ping < 100 )
        return PingLabels[2];
    else if( Ping < 250 )
        return PingLabels[3];
    return PingLabels[4];
}

simulated function ShowServer( ServerInfo S )
{
    local int i;
    
    if( Args ~= "OPTI_MATCH" )
    {
        Servers.Length = 1;
        Servers[0] = S;
        CurrentServer = 0;
    }
    
    Values[i++].Text = S.HostName;
    Values[i++].Text = S.LongName;
    
    if( S.bIsCustomMap > 0 )
        Values[i++].Text = StringYes;
    else
        Values[i++].Text = StringNo;
    
    Values[i++].Text = S.GameName;
    
    Values[i++].Text = String( S.NumPlayers ) $ "/" $ String( S.MaxPlayers );
    
    if( S.Dedicated > 0 )
        Values[i++].Text = StringYes;
    else
        Values[i++].Text = StringNo;
    
    Values[i++].Text = PingFriendlyName(S.Ping);

    if( S.NumPlayers == 0 )
    {
        Labels[i].bHidden = 1;
        Values[i].bHidden = 1;
    }
    else
    {
        Labels[i].bHidden = 0;
        Values[i].bHidden = 0;
    }

    if( S.AverageSkill < 25 )
        Values[i++].Text = class'GameInfo'.default.DifficultyNames[0];
    else if( S.AverageSkill < 50 )
        Values[i++].Text = class'GameInfo'.default.DifficultyNames[1];
    else if( S.AverageSkill < 75 )
        Values[i++].Text = class'GameInfo'.default.DifficultyNames[2];
    else
        Values[i++].Text = class'GameInfo'.default.DifficultyNames[3];
        
    Assert( i == ArrayCount(Values) );

    LayoutArray( Labels[0], 'DetailLabelsLayout' );
    LayoutArray( Values[0], 'DetailValuesLayout' );
}

simulated function ShowNextServer()
{
    if( Servers.Length == 0 )
        return;
    
    CurrentServer = (CurrentServer + 1) % Servers.Length;
    ShowServer( Servers[CurrentServer] );
}

static simulated function RandomizeServer( out ServerInfo S )
{
    S.HostName = "BOB" $ String( Rand(1000) );

    switch( Rand(2) )
    {
        case 0:
            S.MapName = "DM-TEST";
            S.LongName = "DM TEST";
            
            switch( Rand(2) )
            {
                case 0:
                    S.GameType = "xDeathMatch";
                    S.GameName = "Deathmatch";
                    break;

                case 1:
                    S.GameType = "xTeamGame";
                    S.GameName = "Team Deathmatch";
                    break;
            }                    
            S.GameAcronym = "DM";
            break;
            
        case 1:
            S.MapName = "CTF-TEST";
            S.LongName = "CTF TEST";
            S.GameType = "xCTFGame";
            S.GameName = "Capture the Flag";
            S.GameAcronym = "CTF";
            break;
    }

    S.Dedicated = Rand(2);

    S.MaxPlayers = Rand( 13 ) + 4;
    S.NumPlayers = Rand( S.MaxPlayers + 1 );

    S.Ping = Rand(200) + 20;
}

simulated exec function Pork()
{
    local int i;
    local ServerInfo S;

    Servers.Remove( 0, Servers.Length );
    
    for( i = 0; i < 25; i++ )
    {
        RandomizeServer( S );
        Servers[i] = S;
    }
    ShowNextServer();
}

simulated function HandleInputBack()
{
    if( Args ~= "OPTI_MATCH" )
        CloseMenu();
    else
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
}

simulated function OnAButton()
{
    local string URL;

    if( IsOnConsole() && bool(ConsoleCommand("XLIVE NEEDMAP " $ Servers[CurrentServer].MapName ) ) )
    {
        // we don't have the map being hosted! it must be content downloaded before we can play on this server at this time!
        CallMenuClass( "XInterfaceMP.MenuMissingMap", Servers[CurrentServer].MapName );
        return;            
    }        

    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceLive.MenuLiveMain";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();

    class'VignetteConnecting'.default.ServerName = Servers[CurrentServer].HostName;
    class'VignetteConnecting'.static.StaticSaveConfig();

    URL = "0.0.0.1";
    URL = URL $ Servers[CurrentServer].URLAppend;
    URL = URL $ "?Game=" $ Servers[CurrentServer].GameType;

    log("URL:"@URL);

    // confirm you want to join despite network conditions...
    if( Servers[CurrentServer].Ping >= class'MenuMatchMakingAvailableMatches'.default.PingWarningThreshold || Servers[CurrentServer].Ping==-1 )
    {
        CallMenuClass( "XInterfaceLive.MenuBadNetworkConfirm", URL );
        return;
    }

    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function OnXButton()
{
    ShowNextServer();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    
    return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Labels(0)=(Text="Host name:",Style="DetailLabel")
     Labels(1)=(Text="Map:")
     Labels(2)=(Text="Custom:")
     Labels(3)=(Text="Game type:")
     Labels(4)=(Text="Players:")
     Labels(5)=(Text="Dedicated server:")
     Labels(6)=(Text="Speed:")
     Labels(7)=(Text="Average skill:")
     Values(0)=(Style="DetailValue")
     PingLabels(0)="?"
     PingLabels(1)="Excellent"
     PingLabels(2)="Good"
     PingLabels(3)="Fair"
     PingLabels(4)="Poor"
     XLabel=(Text="Find Another")
     MenuTitle=(Text="Match Details")
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
}
