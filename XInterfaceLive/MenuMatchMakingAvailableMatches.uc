class MenuMatchMakingAvailableMatches extends MenuTemplateTitledBXA
    DependsOn(MenuMatchMakingMatchDetails);

const SERVER_COLUMN_COUNT = 5;
const SERVER_ROW_COUNT = 10;

const SC_Server = 0;
const SC_Map    = 1;
const SC_Game   = 2;
const SC_Full   = 3;
const SC_Ping   = 4;

const PING_TIMEOUT = 60.f; // in UC this was 15, bit us in the ass and forced a post-launch schema change to get working once there were many servers up

var() MenuSprite        ServerListBorder;
var() MenuSprite        ServerListHeaderBorder;
var() MenuSprite        ServerListScrollBorder;
var() MenuText          ServerListHeadings[SERVER_COLUMN_COUNT];
var() MenuStringList    ServerListColumns[SERVER_COLUMN_COUNT];
var() MenuButtonSprite  ServerListArrows[2];
var() MenuScrollBar     ServerListScrollBar;
var() MenuActiveWidget  ServerListPageUp, ServerListPageDown;
var() MenuScrollArea    ServerScrollArea;

var() MenuText			PleaseWaitText;

var() localized string  PingFriendly[5];

var() Array<MenuMatchMakingMatchDetails.ServerInfo> Servers;
var() int               PingWarningThreshold; // warn about bad network if server ping >=

var() bool              OnlyShowPinged;

var() float             PingTimeout;

var string mLang;

simulated function Init( String Args )
{
    mLang = ConsoleCommand("GET_LANGUAGE");

    Super.Init(Args);
    RefreshServerList();
    GotoState('WaitingToStartQuery');
    
    PleaseWaitText.Text = class'MenuMatchMakingQuery'.default.PleaseWaitText.Text;
}

// TCR: We must make sure they don't hammer the servers.
state WaitingToStartQuery
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 1.0, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds > PlayerController(Owner).NextMatchmakingQueryTime )
            GotoState('WaitingForResults');
    }

    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions");
    }
}

state WaitingForResults
{
    simulated function BeginState()
    {
        Servers.Length = 0;
        RefreshServerList();
        PlayerController(Owner).NextMatchmakingQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenMatchmakingQueries;    


        if(GetPlatform() == MWP_PC )
        {
            GotoState('PingingServers');
            Pork();
        }

        ConsoleCommand("XLIVE RUN_QUERY_OPTI_MATCH" @ Args );
        SetTimer( 0.1, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        local String QueryState;
        local int ResultCount;
        
        QueryState = ConsoleCommand("XLIVE GETMATCHSTATE");
        
        if( QueryState == "QUERY" ) // Still waiting.
            return;

        if( QueryState != "QUERYRESULTS" )
        {
            SetTimer( 0, false );
            GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatch");
            OverlayErrorMessageBox("");
            return;
        }
        
        ResultCount = int( ConsoleCommand("XLIVE GETQUERYCOUNT") );

        if( ResultCount != 0 )
            GotoState('PingingServers');
        else
        {
            SetTimer( 0, false );
            GotoMenuClass("XInterfaceLive.MenuMatchMakingNoMatches", "OPTI_MATCH" );
        }
    }

    simulated function HandleInputBack()
    {
        ConsoleCommand("XLIVE CANCEL_QUERY" );
        SetTimer( 0, false );
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions");
    }
}

state PingingServers
{
    simulated function BeginState()
    {
        class'MenuMatchMakingMatchDetails'.static.ParseServerList( Servers, PlayerController(Owner) );
        class'MenuMatchMakingMatchDetails'.static.BeginServerProbes(self, Servers);
        SetTimer( 0.5, true );
        
        PingTimeout = Level.TimeSeconds + PING_TIMEOUT;

        if( !OnlyShowPinged )
            RefreshServerList();
    }

    simulated function EndState()
    {
        class'MenuMatchMakingMatchDetails'.static.EndServerProbe(self);
        SetTimer( 0, false );
    }

    simulated function Destroyed()
    {
        class'MenuMatchMakingMatchDetails'.static.EndServerProbe(self);
        Super.Destroyed();
    }

    simulated function Timer()
    {
        if( class'MenuMatchMakingMatchDetails'.static.RefreshServerProbes(self, Servers) )
            RefreshServerList();

        if( (ServerListColumns[SC_Server].Items.Length <= 0) || (Level.TimeSeconds < PlayerController(Owner).NextMatchmakingQueryTime) )
            HideXButton( 1 );
        else
            HideXButton( 0 );

        if( OnlyShowPinged && (Level.TimeSeconds > PingTimeout) && (ServerListColumns[0].Items.Length == 0) )
        {
            SetTimer( 0, false );
            GotoMenuClass("XInterfaceLive.MenuMatchMakingNoMatches", "OPTI_MATCH" );
        }
    }

    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions");
    }

    simulated function ServerDetails()
    {
        local int i;
        
        local MenuMatchMakingMatchDetails M;
        
        for( i=0; i<ServerListColumns[0].Items.Length; i++ )
        {
            if ( ServerListColumns[0].Items[i].bHasFocus != 0 )
            {
                M = Spawn( class'MenuMatchMakingMatchDetails', Owner );
                CallMenu( M, "OPTI_MATCH" );
                M.ShowServer( Servers[ServerListColumns[0].Items[i].ContextId] );
                return;
            }
        }
    }

    simulated function OnXButton()
    {
        if( XButtonIcon.bHidden == 0 )
            GotoState('WaitingForResults');
    }
}

simulated function string PingFriendlyName(int Ping)
{
    if( Ping == -1 )
        return PingFriendly[0]; // no ping reply
    else if( Ping < 50 )
        return PingFriendly[1];
    else if( Ping < 100 )
        return PingFriendly[2];
    else if( Ping < 250 )
        return PingFriendly[3];
    return PingFriendly[4];
}

simulated function FocusOnServer( int i )
{
    local int NewPosition;
    
    if( ServerListColumns[0].Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, ServerListColumns[0].Items.Length - ServerListColumns[0].DisplayCount ) );
        ScrollServerListTo( NewPosition );
    }
    FocusOnWidget( ServerListColumns[0].Items[i] );
}

simulated function RefreshServerList()
{
    local int i, NewServerIndex;
    local int LastFocusID;
    
    LastFocusID = -1;
    
    for( i = 0; i < ServerListColumns[0].Items.Length; i++ )
    {
        if( ServerListColumns[0].Items[i].bHasFocus != 0 )
        {
            LastFocusID = ServerListColumns[0].Items[i].ContextId;
            break;
        }
    }
    
    SoundOnFocus = None;
    
    FocusOnNothing();

    for( i = 0; i < SERVER_COLUMN_COUNT; i++ )
        ServerListColumns[i].Items.Remove( 0, ServerListColumns[i].Items.Length );

    for( i = 0; i < Servers.Length; i++ )
    {
        if( OnlyShowPinged && (Servers[i].Ping < 0) )
            continue;
            
        NewServerIndex = ServerListColumns[SC_Server].Items.Length;
    
        ServerListColumns[SC_Server].Items[NewServerIndex].ContextId = i;
    
        ServerListColumns[SC_Server].Items[NewServerIndex].Blurred.Text = Servers[i].HostName;
        ServerListColumns[SC_Server].Items[NewServerIndex].Focused.Text = ServerListColumns[SC_Server].Items[NewServerIndex].Blurred.Text;

        ServerListColumns[SC_Map].Items[NewServerIndex].Blurred.Text = Servers[i].ShortName;
        ServerListColumns[SC_Map].Items[NewServerIndex].Focused.Text = ServerListColumns[SC_Map].Items[NewServerIndex].Blurred.Text;

        ServerListColumns[SC_Game].Items[NewServerIndex].Blurred.Text = class'MenuInternetServerList'.static.HumpFrenchie(mLang, Caps(Servers[i].GameAcronym));
        ServerListColumns[SC_Game].Items[NewServerIndex].Focused.Text = ServerListColumns[SC_Game].Items[NewServerIndex].Blurred.Text;

        ServerListColumns[SC_Full].Items[NewServerIndex].Blurred.Text = String( Servers[i].NumPlayers ) $ "  /  " $ String( Servers[i].MaxPlayers );
        ServerListColumns[SC_Full].Items[NewServerIndex].Focused.Text = ServerListColumns[SC_Full].Items[NewServerIndex].Blurred.Text;

        ServerListColumns[SC_Ping].Items[NewServerIndex].Blurred.Text = PingFriendlyName(Servers[i].Ping);
        ServerListColumns[SC_Ping].Items[NewServerIndex].Focused.Text = ServerListColumns[SC_Ping].Items[NewServerIndex].Blurred.Text;
    }

    for( i = 0; i < ArrayCount( ServerListColumns ); i++ )
    {
        ServerListColumns[i].DisplayCount = SERVER_ROW_COUNT;
        LayoutMenuStringList( ServerListColumns[i] );
    }
    
    SetListPosition( 0 );

    ServerListScrollBar.Position = ServerListColumns[0].Position;
    ServerListScrollBar.Length = ServerListColumns[0].Items.Length;
    ServerListScrollBar.DisplayCount = SERVER_ROW_COUNT;

    LayoutMenuScrollBarEx( ServerListScrollBar, ServerListPageUp, ServerListPageDown ); // Will trigger a redraw.

    if( ServerListColumns[SC_Server].Items.Length <= 0 )
    {
        PleaseWaitText.bHidden = 0;
        HideXButton( 1 );
        HideAButton( 1 );
    }
    else
    {
        PleaseWaitText.bHidden = 1;
        HideAButton( 0 );

        FocusOnServer(0);

        for( i = 0; i < ServerListColumns[0].Items.Length; i++ )
        {
            if( ServerListColumns[0].Items[i].ContextId == LastFocusID )
            {
                FocusOnServer(i);
                break;
            }
        }
    }
    
    SoundOnFocus = default.SoundOnFocus;
}

simulated exec function Pork()
{
    local int i;
    local MenuMatchMakingMatchDetails.ServerInfo S;

    Servers.Remove( 0, Servers.Length );

    for( i = 0; i < 25; i++ )
    {
        class'MenuMatchMakingMatchDetails'.static.RandomizeServer( S );
        Servers[i] = S;
    }
    
    OnlyShowPinged = false;
    
    RefreshServerList();
}

simulated function OnFocus( int ContextID )
{
    local int Column;
    local int Row;
    
    for( Row = ServerListColumns[0].Position; Row < Min( ServerListColumns[0].Position + ServerListColumns[0].DisplayCount, ServerListColumns[0].Items.Length ); Row++ )
    {
        if( ServerListColumns[0].Items[Row].ContextID == ContextID )
        {
            for( Column = 1; Column < SERVER_COLUMN_COUNT; Column++ )
                ServerListColumns[Column].Items[Row].Blurred.DrawColor = ServerListColumns[0].Items[Row].Focused.DrawColor;
            break;
        }    
    }
}

simulated function OnBlur( int ContextID )
{
    local int Column;
    local int Row;
    
    for( Row = ServerListColumns[0].Position; Row < Min( ServerListColumns[0].Position + ServerListColumns[0].DisplayCount, ServerListColumns[0].Items.Length ); Row++ )
    {
        if( ServerListColumns[0].Items[Row].ContextID == ContextID )
        {
            for( Column = 1; Column < SERVER_COLUMN_COUNT; Column++ )
                ServerListColumns[Column].Items[Row].Blurred.DrawColor = ServerListColumns[0].Items[Row].Blurred.DrawColor;
            break;
        }    
    }
}

simulated function SetListPosition( int NewPosition )
{
    local int i, j;
    
    for( i = 0; i < ArrayCount( ServerListColumns ); i++ )
    {
        if( ServerListColumns[i].Position != NewPosition )
        {
            ServerListColumns[i].Position = NewPosition;
            LayoutMenuStringList( ServerListColumns[i] );
        }
        
        if( i == 0 )
            continue;
            
        for( j = 0; j < ServerListColumns[i].Items.Length; j++ )
            ServerListColumns[i].Items[j].bDisabled = 1;
    }
}

simulated function UpdateScrollBar()
{
    local int Row, Column;

    SetListPosition( ServerListColumns[0].Position );
    
    for( Row = ServerListColumns[0].Position; Row < Min( ServerListColumns[0].Position + ServerListColumns[0].DisplayCount, ServerListColumns[0].Items.Length ); Row++ )
    {
        if( ServerListColumns[0].Items[Row].bHasFocus != 0 )
        {
            for( Column = 1; Column < SERVER_COLUMN_COUNT; Column++ )
                ServerListColumns[Column].Items[Row].Blurred.DrawColor = ServerListColumns[0].Items[Row].Focused.DrawColor;
            
            break;
        }    
    }

    ServerListScrollBar.Position = ServerListColumns[0].Position;
    ServerListScrollBar.Length = ServerListColumns[0].Items.Length;
    ServerListScrollBar.DisplayCount = ServerListColumns[0].DisplayCount;
    
    LayoutMenuScrollBarEx( ServerListScrollBar, ServerListPageUp, ServerListPageDown ); // Will trigger a redraw.
}

simulated function OnServerListScroll()
{
    SetListPosition( ServerListScrollBar.Position );
}


simulated function ScrollServerListTo( int NewPosition )
{
    if( ServerListScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, ServerListScrollBar.Length - ServerListScrollBar.DisplayCount ) );

    if( ServerListScrollBar.Position == NewPosition )
        return;
    
    ServerListScrollBar.Position = NewPosition;
    
    LayoutMenuScrollBar( ServerListScrollBar );
}

simulated function OnServerListScrollUp()
{
    ScrollServerListTo( ServerListScrollBar.Position - 1 );
}

simulated function OnServerListScrollDown()
{
    ScrollServerListTo( ServerListScrollBar.Position + 1 );
}

simulated function OnServerListPageUp()
{
    ScrollServerListTo( ServerListScrollBar.Position - ServerListScrollBar.DisplayCount );
}

simulated function OnServerListPageDown()
{
    ScrollServerListTo( ServerListScrollBar.Position + ServerListScrollBar.DisplayCount );
}

simulated function OnServerListScrollLinesUp( int Lines )
{
    ScrollServerListTo( ServerListScrollBar.Position - Lines );
}

simulated function OnServerListScrollLinesDown( int Lines )
{
    ScrollServerListTo( ServerListScrollBar.Position + Lines );
}

defaultproperties
{
     ServerListBorder=(DrawColor=(A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=0.934000,ScaleY=0.591000,Pass=1,Style="Border")
     ServerListHeaderBorder=(DrawColor=(A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.229000,ScaleX=0.935000,ScaleY=0.053300,Pass=2,Style="Border")
     ServerListScrollBorder=(DrawColor=(A=255),DrawPivot=DP_MiddleMiddle,PosX=0.947000,PosY=0.525000,ScaleX=0.040000,ScaleY=0.540000,Pass=2,Style="Border")
     ServerListHeadings(0)=(Text="Server",DrawPivot=DP_MiddleLeft,PosX=0.045000,PosY=0.233000,Pass=3,Style="SmallLabel")
     ServerListHeadings(1)=(Text="Map",DrawPivot=DP_MiddleLeft,PosX=0.400000)
     ServerListHeadings(2)=(Text="Game",DrawPivot=DP_MiddleRight,PosX=0.700000)
     ServerListHeadings(3)=(Text="Size",DrawPivot=DP_MiddleRight,PosX=0.820000)
     ServerListHeadings(4)=(Text="Speed",DrawPivot=DP_MiddleRight,PosX=0.936000)
     ServerListColumns(0)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.360000),BackgroundFocused=(PosX=-0.010000,PosY=-0.004000,ScaleX=0.892000,ScaleY=0.050000),OnFocus="OnFocus",OnBlur="OnBlur",OnSelect="ServerDetails"),PosX1=0.045000,PosY1=0.290000,PosX2=0.045000,PosY2=0.770000,OnScroll="UpdateScrollBar",Pass=2,Style="ServerInfoColumn")
     ServerListColumns(1)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.220000),bDisabled=1),PosX1=0.400000,PosX2=0.400000,OnScroll="DoNothing")
     ServerListColumns(2)=(Template=(Blurred=(DrawPivot=DP_MiddleRight,MaxSizeX=0.250000),bDisabled=1),PosX1=0.700000,PosX2=0.700000,OnScroll="DoNothing")
     ServerListColumns(3)=(Template=(Blurred=(DrawPivot=DP_MiddleRight,Kerning=-3,MaxSizeX=0.250000),bDisabled=1),PosX1=0.820000,PosX2=0.820000,OnScroll="DoNothing")
     ServerListColumns(4)=(Template=(Blurred=(DrawPivot=DP_MiddleRight,ScaleX=0.800000,ScaleY=0.800000,Kerning=1,MaxSizeX=0.250000),bDisabled=1),PosX1=0.915000,PosY1=0.298000,PosX2=0.915000,PosY2=0.778000,OnScroll="DoNothing")
     ServerListArrows(0)=(Blurred=(PosX=0.948000,PosY=0.270000),OnSelect="OnServerListScrollUp",Pass=3,Style="TitledStringListArrowUp")
     ServerListArrows(1)=(Blurred=(PosY=0.775500),OnSelect="OnServerListScrollDown",Style="TitledStringListArrowDown")
     ServerListScrollBar=(PosX1=0.947000,PosY1=0.310000,PosX2=0.947000,PosY2=0.745000,OnScroll="OnServerListScroll",Pass=3,Style="VerticalScrollBar")
     ServerListPageUp=(bIgnoreController=1,OnSelect="OnServerListPageUp",Pass=2)
     ServerListPageDown=(bIgnoreController=1,OnSelect="OnServerListPageDown",Pass=2)
     ServerScrollArea=(X1=0.029000,Y1=0.200000,X2=0.971000,Y2=0.800000,OnScrollTop="OnServerListTop",OnScrollPageUp="OnServerListPageUp",OnScrollLinesUp="OnServerListScrollLinesUp",OnScrollLinesDown="OnServerListScrollLinesDown",OnScrollPageDown="OnServerListPageDown",OnScrollBottom="OnServerListBottom")
     PleaseWaitText=(Style="MessageText")
     PingFriendly(0)="?"
     PingFriendly(1)="****"
     PingFriendly(2)="***"
     PingFriendly(3)="**"
     PingFriendly(4)="*"
     PingWarningThreshold=200
     OnlyShowPinged=True
     XLabel=(Text="Refresh",PosX=0.390000)
     MenuTitle=(Text="Available Matches")
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
