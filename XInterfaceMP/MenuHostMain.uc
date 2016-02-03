class MenuHostMain extends MenuTemplateTitledBA;

// Args: <LAN | SYSTEM_LINK | INTERNET | XBOX_LIVE>

struct HostGameSettings
{
    var() String GameType;
    
    var() transient editinline MapList Maps;
    var() transient Array<xUtil.MapRecord> MapRecords;
    var() transient xUtil.GameTypeRecord GameTypeRecord;

    var() int TimeLimit;    // Minutes
    var() int GoalScore;
    var() int InitialWECs;
    var() int bFriendlyFire;
};

struct HostServerSettings
{
    var() int bDedicatedServer;
    var() int MaxPlayers;
    var() int PrivateSlots; // Xbox Live only
    var() String GamePassword;  // PC only
    var() String AdminPassword;  // PC only
    var() int bEnableBots;
    var() float Difficulty; // Aka: Bot Skill
};

enum EHostMode
{
    HM_Lan,
    HM_Internet,
    HM_XboxLive
};

var() config Array<HostGameSettings> GameSettings;

var() int GameTypeIndex;

var() config HostServerSettings ServerSettings;

var() MenuButtonText Options[6];

var() EHostMode HostMode;

var() int MaxBandwidthPlayers;
var() bool WarnedMaxBandwidth;

var() localized string BandwidthWarningTitle;
var() localized string BandwidthWarningText;
var() localized String StringCreateMatch;

var() localized String CurrentGameTypeString;
var() localized String CurrentStartingMapString;
var() localized String ServerNameString;

var() MenuText Summary[8];
var() WidgetLayout SummaryLayout;
var() Color HighliteColor;

var() MenuText CurrentGameType[2];
var() MenuText CurrentStartingMap[2];

var() config String GameTypeName;

var() bool DenyCustomContent;

// Need to defer startup until we're actually logged in otherwise DenyCustomContent will get invalid results.

simulated function Init( String Args )
{
    Super.Init(Args);
    
    if( Args == "LAN" )
    {
        HostMode = HM_Lan;
    }
    else if( Args == "INTERNET" )
    {
        HostMode = HM_Internet;
    }
    else if( Args == "XBOX_LIVE" )
    {
        HostMode = HM_XboxLive;
        MenuTitle.Text = StringCreateMatch;
    }
    else
    {
        log("MenuHostMain didn't get a mode", 'Error');
        assert(false);
        HostMode = HM_Lan;
    }
    
    SetVisible('OnAdminSettings', !IsOnConsole());
    
    if( HostMode != HM_XboxLive )
    {
        GotoState('LoggedIn');
    }
    else
    { 
        GotoState('WaitingForLogin');
    }
}

auto state WaitingForLogin
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 0.33, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        if( ConsoleCommand("XLIVE GETAUTHSTATE") == "ONLINE" )
            GotoState('LoggedIn');
    }
    
    simulated function bool HandleInputGamePad( String ButtonName )
    {
        return(true);
    }
}

state LoggedIn
{
    simulated function BeginState()
    {
        Startup();
    }
}

simulated function Startup()
{
    local int i;
    
    DenyCustomContent = (HostMode == HM_XboxLive) && bool( ConsoleCommand("XLIVE DENY_CUSTOM_CONTENT") );
    
    LoadSettings();
    
    GameTypeIndex = -1;
    
    for( i = 0; i < GameSettings.Length; ++i )
    {
        if( DenyCustomContent && bool(GameSettings[i].GameTypeRecord.bCustomMaps) )
        {
            continue;
        }
    
        if( GameSettings[i].GameType == GameTypeName )
        {
           GameTypeIndex = i;
           break;
        }
    }
    
    if( GameTypeIndex < 0 )
    {
        for( i = 0; i < GameSettings.Length; ++i )
        {
            if( DenyCustomContent && bool(GameSettings[i].GameTypeRecord.bCustomMaps) )
            {
                continue;
            }
        
            GameTypeIndex = i;
            break;
        }
    }
    
    Assert( GameTypeIndex >= 0 );
    
    if( HostingLive() && !WarnedMaxBandwidth )
    {
        MaxBandwidthPlayers = int(ConsoleCommand("XLIVE GET_BANDWIDTH_PLAYER_COUNT"));
        
        if( MaxBandwidthPlayers == 0 )
        {
            MaxBandwidthPlayers = default.MaxBandwidthPlayers;
        }
        
        log("MaxBandwidthPlayers:" @ MaxBandwidthPlayers);

        ServerSettings.MaxPlayers = Min(ServerSettings.MaxPlayers, MaxBandwidthPlayers );
    }
        
    FocusOnWidget( Options[4] );
    Refresh();
}

simulated event bool IsLiveMenu()
{
    return(HostingLive() || Super.IsLiveMenu());
}

simulated function bool HostingLive()
{
    return( HostMode == HM_XboxLive );
}

simulated function bool HostingCustom()
{
    return(bool(GameSettings[GameTypeIndex].GameTypeRecord.bCustomMaps));
}

simulated function LoadSettings()
{
    local Array<xUtil.GameTypeRecord> GameTypeRecords;
    local int i, j;
    
    class'xUtil'.static.GetGameTypeList( GameTypeRecords );
    Assert( GameTypeRecords.Length != 0 );
    
    if( !IsOnConsole() )
    {
        for( i = 0; i < GameTypeRecords.Length; ++i )
        {
            GameTypeRecords[i].MaxPlayersOnListen = 16;
            GameTypeRecords[i].MaxPlayersOnDedicated = 32;
        }
    }
    
    // First find any game-types we're missing and load the data for each:
    
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        for( j = 0; j < GameSettings.Length; ++j )
        {
            if( GameTypeRecords[i].ClassName == GameSettings[j].GameType )
            {
                break;
            }
        }
        
        if( j == GameSettings.Length )
        {
            GameSettings[j].GameType = GameTypeRecords[i].ClassName;
            GameSettings[j].TimeLimit = GameTypeRecords[i].DefaultTimeLimit;
            GameSettings[j].GoalScore = GameTypeRecords[i].DefaultGoalScore;
            GameSettings[j].InitialWECs = 0;
            GameSettings[j].bFriendlyFire = 0;
        }
        
        GameSettings[j].GameTypeRecord = GameTypeRecords[i];
        
        LoadMapLists(GameSettings[j]);
    }

    // Find all game-types that have been deleted:
    
    for( j = 0; j < GameSettings.Length; ++j )
    {
        for( i = 0; i < GameTypeRecords.Length; ++i )
        {
            if( GameTypeRecords[i].ClassName == GameSettings[j].GameType )
            {
                break;
            }
        }
        
        if( i == GameTypeRecords.Length )
        {
            log("Removing" @ GameSettings[j].GameType @ "from the saved hosting configs." );
            GameSettings.Remove( j, 1 );
            --j;
        }
    }
}

simulated function bool MapExists( out HostGameSettings Settings, String MapName )
{
    local int i;
    
    for( i = 0; i < Settings.MapRecords.Length; ++i )
    {
        if( Settings.MapRecords[i].MapName ~= MapName )
        {
            return(true);
        }
    }
    return(false);
}

simulated function LoadMapLists(out HostGameSettings Settings)
{
    local class<MapList> MapListClass;
    local int i;
    local bool IsLive;

    MapListClass = class<MapList>( DynamicLoadObject( Settings.GameTypeRecord.MapListType, class'Class' ) );
    Assert(MapListClass != None);
    
    IsLive = false;
    if(HostMode == HM_XboxLive)
    {
        IsLive = true;
    }

	class'xUtil'.static.GetMapList( Settings.MapRecords, IsLive, false, Settings.GameTypeRecord.MapPrefix $ "-" );
    
	Settings.Maps = Spawn( MapListClass, self );
    Assert(Settings.Maps != None);

    if( Settings.MapRecords.Length == 0 )
    {
        log("No maps found for" @ Settings.GameType );
    }

    // Pass 1: automatically add any maps that are "new"
    for( i = 0; i < Settings.MapRecords.Length; ++i )
    {
        if( !Settings.Maps.MapIsKnown( Settings.MapRecords[i].MapName ) )
        {
            log("Adding" @ Settings.MapRecords[i].MapName @ "since it's new");
            Settings.Maps.AddMap( Settings.MapRecords[i].MapName, true, true );
        }
    }
    
    // Pass 2: Take out any maps that are not known (or are not allowed in this mode):
    for( i = 0; i < Settings.Maps.MapEntries.Length; ++i )
    {
        if( !MapExists( Settings, Settings.Maps.MapEntries[i].MapName ) )
        {
            log("Removing" @ Settings.Maps.MapEntries[i].MapName @ "since it no longer exists");
            Settings.Maps.MapEntries.Remove( i, 1 );
            --i;
        }
    }
    
    // Pass 3: If the map list is empty at this point, add them all by default!
    if( Settings.Maps.IsEmpty() )
    {
        log("Adding all" @ Settings.GameType @ "maps since the map list is empty!");

        for( i = 0; i < Settings.MapRecords.Length; ++i )
        {
            Settings.Maps.AddMap( Settings.MapRecords[i].MapName, true, false );
        }
        
        Settings.Maps.CurrentMapIndex = 0;
    }
}

simulated function SaveSettings()
{
    local int i;

    for( i = 0; i < GameSettings.Length; ++i )
    {
        GameSettings[i].Maps.SaveConfig();
    }

    GameTypeName = GameSettings[GameTypeIndex].GameType;
    
    SaveConfig();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );
    LayoutArray( Summary[0], 'SummaryLayout' );
}

simulated function HandleInputBack()
{
    local MenuInternetServerList M;

    SaveSettings();
    
    switch( HostMode )
    {
        case HM_Lan:
            M = Spawn( class'MenuInternetServerList', Owner );
            M.ListMode = SLM_Lan;
            GotoMenu( M );
            return;

        case HM_Internet:
            GotoMenuClass("XInterfaceMP.MenuInternetMain");
            return;
            
        case HM_XboxLive:
            GotoMenuClass("XInterfaceLive.MenuLiveMain");
            return;
    }
}

simulated function AddSummaryLine( out int Index, bool Highlite, String S )
{
    Assert( Index < ArrayCount(Summary) );
    
    Summary[Index].Text = S;
    
    if( Highlite )
    {
        Summary[Index].DrawColor = HighliteColor;
    }
    else
    {
        Summary[Index].DrawColor = Options[0].Blurred.DrawColor;
    }
    
    ++Index;
}

simulated function String GetFirstMapLongName()
{
    local String MapName;
    local int i;
    
    MapName = GameSettings[GameTypeIndex].Maps.GetFirstMap();
    
    for( i = 0; i < GameSettings[GameTypeIndex].MapRecords.Length; ++i )
    {
        if( GameSettings[GameTypeIndex].MapRecords[i].MapName ~= MapName )
        {
            return(GameSettings[GameTypeIndex].MapRecords[i].LongName);
        }
    }
    
    log( "Could not find map record for:" @ MapName, 'Error' );
    return(MapName);
}

simulated function Refresh()
{
    local int SummaryIndex;
    
    if( bool(ServerSettings.bDedicatedServer ) )
    {
        if( ServerSettings.MaxPlayers > GameSettings[GameTypeIndex].GameTypeRecord.MaxPlayersOnDedicated )
        {
            ServerSettings.MaxPlayers = GameSettings[GameTypeIndex].GameTypeRecord.MaxPlayersOnDedicated;
            log("Clamping MaxPlayers to GameType specific max of" @ ServerSettings.MaxPlayers);
        }
    }
    else
    {
        if( ServerSettings.MaxPlayers > GameSettings[GameTypeIndex].GameTypeRecord.MaxPlayersOnListen )
        {
            ServerSettings.MaxPlayers = GameSettings[GameTypeIndex].GameTypeRecord.MaxPlayersOnListen;
            log("Clamping MaxPlayers to GameType specific max of" @ ServerSettings.MaxPlayers);
        }
    }
    
    if( HostMode == HM_Internet )
    {
        AddSummaryLine( SummaryIndex, false, ServerNameString $ ":" );
        AddSummaryLine( SummaryIndex, true, class'GameReplicationInfo'.default.ServerName );

        AddSummaryLine( SummaryIndex, false, "_" );
    }

    AddSummaryLine( SummaryIndex, false, CurrentGameTypeString $ ":" );
    AddSummaryLine( SummaryIndex, true, GameSettings[GameTypeIndex].GameTypeRecord.GameName );

    AddSummaryLine( SummaryIndex, false, "_" );

    AddSummaryLine( SummaryIndex, false, CurrentStartingMapString $ ":" );
    AddSummaryLine( SummaryIndex, true, GetFirstMapLongName() );
}

simulated function OnGameType()
{
    CallMenuClass( "XInterfaceMP.MenuHostGameType" );
}

simulated function OnMapList()
{
    CallMenuClass( "XInterfaceMP.MenuHostMapList" );
}

simulated function OnGameSettings()
{
    CallMenuClass( "XInterfaceMP.MenuHostGameSettings" );
}

simulated function OnServerSettings()
{
    CallMenuClass( "XInterfaceMP.MenuHostServerSettings" );
}

simulated function OnAdminSettings()
{
    CallMenuClass( "XInterfaceMP.MenuHostAdmin" );
}

simulated function String GetGameSettingsURL( HostGameSettings Settings )
{
    local String URL;
 
    URL = URL $ "?game=" $ Settings.GameType;
    URL = URL $ "?TimeLimit=" $ Settings.TimeLimit;
    URL = URL $ "?GoalScore=" $ Settings.GoalScore;
    URL = URL $ "?StartWECCount=" $ Settings.InitialWECs;

    if( bool(Settings.GameTypeRecord.bTeamGame) )
    {
        if( bool(Settings.bFriendlyFire) )
        {
            URL = URL $ "?FriendlyFireScale=1";
        }
        else
        {
            URL = URL $ "?FriendlyFireScale=0";
        }
    }    
    return(URL);
}

simulated function String GetServerSettingsURL()
{
    local String URL;

    if( bool(ServerSettings.bDedicatedServer) )
    {
        URL = URL $ "?DedicatedServer=true";
    }
    else
    {
        URL = URL $ "?Listen";
    }
    
    if( HostMode == HM_Lan )
    {
        URL = URL $ "?LAN";
    }
    
    URL = URL $ "?MaxPlayers=" $ ServerSettings.MaxPlayers;
    
    if( HostingLive() )
    {
        URL = URL $ "?WasInvited=true"; // host is always invited
     
        if( bool(ServerSettings.bDedicatedServer) )
        {
            // No reserved slots for dedicated servers.
            URL = URL $ "?ReservedSlots=0";
        }
        else
        {
            URL = URL $ "?ReservedSlots=" $ ServerSettings.PrivateSlots;
        }
    }

    if( HostingCustom() )
    {
        URL = URL $ "?bAutoNumBots=false";
    }
    else
    {
        URL = URL $ "?bAutoNumBots=" $ bool(ServerSettings.bEnableBots);
        URL = URL $ "?Difficulty=" $ ServerSettings.Difficulty;
    }
    
    if( !IsOnConsole() )
    {
        if( ServerSettings.GamePassword != "" )
        {
            URL = URL $ "?GamePassword=" $ ServerSettings.GamePassword;
        }
        
        if( ServerSettings.AdminPassword != "" )
        {
            URL = URL $ "?AdminPassword=" $ ServerSettings.AdminPassword;
        }
    }
        
    return(URL);
}

simulated function OnBegin()
{
    local String URL;
    
    if( !ConfirmBandwidthOverride() )
    {
        return;
    }

    // Now we build the URL to end all URLS:

    URL = GameSettings[GameTypeIndex].Maps.GetFirstMap();

    URL = URL $ GetGameSettingsURL( GameSettings[GameTypeIndex] );
    URL = URL $ GetServerSettingsURL();
    
    log("URL:" @ Url);

    SaveSettings();

    class'VignetteConnecting'.default.ServerName = "";
    class'VignetteConnecting'.static.StaticSaveConfig();

    class'GameEngine'.default.DisconnectMenuClass = String(Class);
    class'GameEngine'.default.DisconnectMenuArgs = Args;
    class'GameEngine'.static.StaticSaveConfig();

	if(!IsOnConsole() && ServerSettings.bDedicatedServer == 1)
	{
		PlayerController(Owner).ConsoleCommand("relaunch"@URL@"-server -log=server.log");
	}
	else
	{
		PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
	}
}

simulated function bool ConfirmBandwidthOverride()
{
    if( WarnedMaxBandwidth || (ServerSettings.MaxPlayers <= MaxBandwidthPlayers) )
    {
        return(true);
    }
    
    CallMenuClass
    (
        "XInterface.MenuQuestionYesNo",
        MakeQuotedString(BandwidthWarningText) @ MakeQuotedString(BandwidthWarningTitle)
    );
    
    return(false);
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    local MenuQuestionYesNo Question;

    Question = MenuQuestionYesNo( ClosingMenu );
    
    if( Question != None )
    {
        if( Question.bSelectedYes )
        {
            WarnedMaxBandwidth = true;
            default.WarnedMaxBandwidth = true; // so it only happens once per session

            OnBegin();
        }
        else
        {
            ServerSettings.MaxPlayers = MaxBandwidthPlayers;
        }
        return(true);
    }
    
    return(false);
}

defaultproperties
{
     ServerSettings=(MaxPlayers=8,Difficulty=4.000000)
     Options(0)=(Blurred=(Text="Game Type"),HelpText="Change the game type.",OnSelect="OnGameType",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Map List"),HelpText="Select which maps to play.",OnSelect="OnMapList")
     Options(2)=(Blurred=(Text="Game Settings"),OnSelect="OnGameSettings")
     Options(3)=(Blurred=(Text="Server Settings"),OnSelect="OnServerSettings")
     Options(4)=(Blurred=(Text="Admin Settings"),OnSelect="OnAdminSettings",bHidden=1)
     Options(5)=(Blurred=(Text="Begin!"),HelpText="Start the match.",OnSelect="OnBegin")
     MaxBandwidthPlayers=16
     BandwidthWarningText="You have exceeded the maximum number of players your bandwidth can support.\n\nThis may result in poor quality games for players connecting to this server.\n\nAre you sure you want to override the player limit?"
     StringCreateMatch="Create Match"
     CurrentGameTypeString="Current Game Type"
     CurrentStartingMapString="Starting Map"
     ServerNameString="Server Name"
     Summary(0)=(MaxSizeX=0.450000,Style="NormalLabel")
     SummaryLayout=(PosX=0.500000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
     HighliteColor=(G=150,R=255,A=255)
     MenuTitle=(Text="Host Game")
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
