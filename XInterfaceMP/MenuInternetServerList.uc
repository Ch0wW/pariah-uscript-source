class MenuInternetServerList extends MenuTemplateTitledBXYKWA;

// In order for this menu to be able to handle massive numbers of servers at a time
// the layout logic is somewhat unique:
//
// Since the servers trickle in a few at a time (and are inserted sorted into
// the master list) we only update the view when:
//
// 1) A new server was added which caused a change in the current view.
// 2) The user scrolls the list.

const SERVER_MAX_ROWS = 15;

const SC_Server = 0;
const SC_Map    = 1;
const SC_Game   = 2;
const SC_Full   = 3;
const SC_Ping   = 4;
const SC_MAX    = 5;

enum EServerListMode
{
    SLM_InstantAction,
    SLM_AdvancedSearchA,
    SLM_AdvancedSearchB,
    SLM_Favourites,
    SLM_Recent,
    SLM_Buddies,
    SLM_Lan
};

// Set by creator:
var() EServerListMode    ListMode;

var() MasterServerClient    MSC; 
var() editinline ServerList Servers;

struct long TextColumn
{
    var() MenuButtonText Items[SERVER_MAX_ROWS];
};

struct long IconColumn
{
    var() MenuSprite    Items[SERVER_MAX_ROWS];
};

var() MenuButtonText    ServerListHeadings[SC_MAX];
var() TextColumn        ServerListColumns[SC_MAX];
var() IconColumn        ServerIconColumns[4]; // Right to left!

var() Material          IconCustom;
var() Material          IconDedicated;
var() Material          IconPrivate;
var() Material          IconFavourite;

var() float             IconDX;
var() float             ServerMaxSizeXFudge;

var() MenuButtonSprite  ServerListArrows[2];
var() MenuScrollBar     ServerListScrollBar;
var() MenuActiveWidget  ServerListPageUp, ServerListPageDown;
var() MenuScrollArea    ServerScrollArea;

var() int               CurrentPosition;  // ie: pivot of window
var() int               SelectedPosition; // ie: -1 implies unset
var() int               HighliteRow; // ie: -1 implies unset

var() MenuText			MainMessage;

var() localized String  StringLookingForGames;
var() localized String  StringNoGamesFound;
var() localized String  StringDownloadingList;
var() localized String  StringPingingServers;
var() localized String  StringSearchCompleteSingle;
var() localized String  StringSearchComplete;
var() localized String  StringStop;
var() localized String  StringRefresh;
var() localized String  StringAddToFavourites;
var() localized String  StringRemoveFromFavourites;
var() localized String  StringHostGame;
var() localized String  StringDownloadingMOTD;

var() MenuText          ProgressText;

var() String            Lang;

var() int               DisplayCount;

var() WidgetLayout      ServerColumnLayout;
var() WidgetLayout      MapColumnLayout;
var() WidgetLayout      GameColumnLayout;
var() WidgetLayout      FullColumnLayout;
var() WidgetLayout      PingColumnLayout;

var() config Array<ServerList.ServerSortKey> SortKeys;

var() Color             SelectedColor;
var() Color             NormalBlurredColor;
var() Color             NormalFocusedColor;

var() int               MaxSimultaneousPings;

var() int               MaxPing;

var() float             TimeBetweenFatPings;

var() int               NextServerID;
var() float             LanBeaconTimeout;

var array<MasterServerClient.MOTDResponse>	MOTDResponses;
var bool									bForceMOTD;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    MSC = Spawn(class'MasterServerClient', Owner);
    Assert( MSC != None );
    
    MSC.OnQueryFinished = OnQueryFinished;
    MSC.OnReceivedServer = OnReceivedServer;

    MSC.OnReceivedPingInfo = OnReceivedPingInfo;
    MSC.OnPingTimeout = OnPingTimeout;
	MSC.OnReceivedMOTDData = OnReceivedMOTDData;

    Servers = Spawn(class'ServerList', Owner);
    Assert( Servers != None );
    
    Servers.PorkReceivedPingInfo = OnReceivedPingInfo;
}

simulated function Destroyed()
{
    if( MSC != None )
    {
	    MSC.Stop();
        MSC.Destroy();
    }
    
    if( Servers != None )
    {
        Servers.Destroy();
    }
    
    Super.Destroyed();
}

simulated function Init( String Args )
{
    Super.Init( Args );
    
    Lang = ConsoleCommand("GET_LANGUAGE");

    LayoutMenuScrollBarEx( ServerListScrollBar, ServerListPageUp, ServerListPageDown ); // Will trigger a OnScrollBarScroll

    NormalBlurredColor = ServerListColumns[0].Items[0].Blurred.DrawColor;
    NormalFocusedColor = ServerListColumns[0].Items[0].Focused.DrawColor;

    Servers.SetServerSortKey( SortKeys );
    GotoState('WaitingToStartQuery');
}

simulated function HandleInputBack()
{
    switch( ListMode )
    {
        case SLM_InstantAction:
            GotoMenuClass("XInterfaceMP.MenuInternetInstantAction");
            break;
            
        case SLM_AdvancedSearchA:
            GotoMenuClass("XInterfaceMP.MenuInternetAdvancedOptionsA");
            break;
            
        case SLM_AdvancedSearchB:
            GotoMenuClass("XInterfaceMP.MenuInternetAdvancedOptionsB");
            break;
        
        case SLM_Favourites:
        case SLM_Recent:
        case SLM_Buddies:
            GotoMenuClass("XInterfaceMP.MenuInternetMain");
            break;

        case SLM_Lan:
            GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
            break;
    }
}

simulated function AddQueryTerm(coerce string Key, MasterServerClient.EQueryType QueryType, coerce string Value )
{
	local int i;

	for ( i = 0; i < MSC.Query.Length; i++ )
	{
		if ( MSC.Query[i].Key ~= Key && MSC.Query[i].Value ~= Value && MSC.Query[i].QueryType == QueryType )
		{
		    log("Avoiding redundant AddQueryTerm("$Key$")", 'Error');
			return;
	    }
	}

    i = MSC.Query.Length;
    
	MSC.Query[i].Key		= Key;
	MSC.Query[i].Value		= Value;
	MSC.Query[i].QueryType	= QueryType;
}

// All of our delegates should be handled in specific states:

simulated function OnReceivedServer( GameInfo.ServerResponseLine s )
{
    log("Ignoring unexecpted OnReceivedServer()", 'Error');
}

simulated function OnQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
    log("Ignoring unexecpted OnQueryFinished()", 'Error');
}

simulated function OnReceivedPingInfo( int ServerID, MasterServerClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
    log("Ignoring unexecpted OnReceivedPingInfo()", 'Error');
}

simulated function OnPingTimeout( int ServerID, MasterServerClient.EPingCause PingCause )
{
    log("Ignoring unexecpted OnPingTimeout()", 'Error');
}

simulated function OnReceivedMOTDData( MasterServerClient.EMOTDResponse Command, string Value )
{
	log("Ignoring unexpected OnReceivedMOTDData("$Command$","$Value$")");
}


// First we throttle their abuse of the master server:
state WaitingToStartQuery
{
    simulated function BeginState()
    {
        MainMessage.bHidden = 0;
        MainMessage.Text = StringLookingForGames;
    
        ProgressText.bHidden = 1;
    
        XLabel.Text = StringStop;
        HideXButton(0);

        HideAButton(1);
        HideWButton(1);
        HideKButton(1);

        if( ListMode == SLM_Buddies )
        {
            HideYButton(0);
        }
        else if( ListMode == SLM_Lan )
        {
            YLabel.Text = StringHostGame;
            HideYButton(0);
        }
        else
        {
            HideYButton(1);
        }
        

        UnSetRowHighlite();

        CurrentPosition = 0;
        SelectedPosition = -1;
        HighliteRow = -1;
        
        PostEditChange();
        UpdateScrollBar();
        bDynamicLayoutDirty = true;
    
        if( ListMode == SLM_Lan )
        {
            TimeBetweenFatPings = 0.5;
            Servers.Reset();
            GotoState('BroadcastPing');
        }
        else if ( !MSC.MOTDQuerySent() || bForceMOTD )
        {
			bForceMOTD = false;
	        GotoState('GetMOTD');
        }
		else if( ListMode == SLM_Favourites )
        {
            Servers.LoadFavourites();
            GotoState('PingingServers');
        }
        else if( ListMode == SLM_Recent ) 
        {
            Servers.LoadRecent();
            GotoState('PingingServers');
        }
        else
        {
            Servers.Reset();
            SetTimer( 0.5, true );
            Timer();
        }
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds < PlayerController(Owner).NextMatchmakingQueryTime )
            return;

        PlayerController(Owner).NextMatchmakingQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenMatchmakingQueries;    

        GotoState('RunningQuery');
    }

    simulated function OnXButton()
    {
        log("Query stillborn");
        GotoState('PingingServers');
    }
    
    simulated function OnYButton()
    {
        SetTimer( 0, false );
        
        if( ListMode == SLM_Buddies )
        {
            GotoMenuClass("XInterfaceMP.MenuInternetManageBuddies", "");
        }
        else if( ListMode == SLM_Lan )
        {
            GotoMenuClass("XInterfaceMP.MenuHostMain", "LAN");
        }
    }

    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        global.HandleInputBack();
    }
}

state GetMOTD
{
    simulated function BeginState()
    {
        Assert( MSC != None );

        MSC.CancelPings();
        MSC.Stop();
        MSC.StartQuery( CTM_GetMOTD );
        
		MOTDResponses.Length = 0;
        ProgressText.bHidden = 0;
        ProgressText.Text = StringDownloadingMOTD $ "...";
    }    

	simulated function OnReceivedMOTDData( MasterServerClient.EMOTDResponse Command, string Value )
	{
		local int i;

		if ( Value != "" )
		{
			i = MOTDResponses.Length;
			MOTDResponses.Length = MOTDResponses.Length + 1;
			MOTDResponses[i].MR = Command;
			MOTDResponses[i].Value = Value;
		}
	}

	simulated function OnQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
    {
		local MenuInternetMOTD	mMOTD;
		local MenuInternetError	mError;
		local string			mErrorArg;
		local int				r;
        
		switch( ResponseInfo )
        {
            case RI_Success:
				if ( MOTDResponses.Length > 0 )
				{
					mMOTD = Spawn( class'MenuInternetMOTD', Owner );
					mMOTD.MOTDResponses = MOTDResponses;
					CallMenu( mMOTD );
				}

				if( ListMode == SLM_Favourites )
				{
					Servers.LoadFavourites();
					GotoState('PingingServers');
				}
				else if( ListMode == SLM_Recent ) 
				{
					Servers.LoadRecent();
					GotoState('PingingServers');
				}
				else
				{
					Servers.Reset();
					SetTimer( 0.1, true );
				}

                break;
            
            case RI_AuthenticationFailed:
                mErrorArg = "RI_AuthenticationFailed";
                break;
            
            case RI_ConnectionFailed:
                mErrorArg = "RI_ConnectionFailed";
                break;
            
            case RI_ConnectionTimeout:
                mErrorArg = "RI_ConnectionTimeout";
                break;
            
            case RI_MustUpgrade:
                mErrorArg = "RI_MustUpgrade";
                break;
            
            default:
				mErrorArg = "RI_Unknown";
                break;
        }
		if ( mErrorArg != "" )
		{
			mError = Spawn( class'MenuInternetError', Owner );
			for ( r = 0; r < MOTDResponses.Length; ++r )
			{
				if ( MOTDResponses[r].MR == MR_UpgradeURL )
				{
					mError.UpgradeURL = MOTDResponses[r].Value;
				}
			}
			GotoMenu( mError, mErrorArg );
		}
    }

	simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds < PlayerController(Owner).NextMatchmakingQueryTime )
            return;

        PlayerController(Owner).NextMatchmakingQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenMatchmakingQueries;    

        GotoState('RunningQuery');
    }
    
    simulated function OnXButton()
    {
        log("Query aborted");
        Servers.Reset();
        MSC.Stop();
        GotoState('PingingServers');
    }
    
    simulated function OnYButton()
    {
        MSC.Stop();
        
        if( ListMode == SLM_Buddies )
        {
            GotoMenuClass("XInterfaceMP.MenuInternetManageBuddies", "");
        }
        else if( ListMode == SLM_Lan )
        {
            GotoMenuClass("XInterfaceMP.MenuHostMain", "LAN");
        }
    }

    simulated function HandleInputBack()
    {
        MSC.Stop();
        global.HandleInputBack();
    }
}

// Now we wait for the query to come back. We'll get a rash of 
// OnReceivedServer() callbacks followed by OnQueryFinished()
// once we've got the intial list.

state RunningQuery
{
    simulated function BeginState()
    {
        Assert( MSC != None );

        MSC.CancelPings();
        MSC.Stop();
        MSC.StartQuery( CTM_Query );
        
		MOTDResponses.Length = 0;
        ProgressText.bHidden = 0;
        ProgressText.Text = StringDownloadingList $ "...";
    }    

    simulated function OnReceivedServer( GameInfo.ServerResponseLine s )
    {
        S.ServerID = NextServerID++;
        Servers.PendingPing[Servers.PendingPing.Length] = s;

        ProgressText.bHidden = 0;
        ProgressText.Text = StringDownloadingList $ ":" @ Servers.PendingPing.Length @ "/" @ MSC.ResultCount;
    }

	simulated function OnReceivedMOTDData( MasterServerClient.EMOTDResponse Command, string Value )
	{
		local int i;

		if ( Value != "" )
		{
			i = MOTDResponses.Length;
			MOTDResponses.Length = MOTDResponses.Length + 1;
			MOTDResponses[i].MR = Command;
			MOTDResponses[i].Value = Value;
		}
	}

	simulated function OnQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
    {
		local MenuInternetError	mError;
		local string			mErrorArg;
		local int				r;

		switch( ResponseInfo )
        {
            case RI_Success:
                log("Query succeeded:" @ MSC.ResultCount @ "matches found.");
                GotoState('PingingServers');
                break;
            
            case RI_AuthenticationFailed:
                mErrorArg = "RI_AuthenticationFailed";
                break;
            
            case RI_ConnectionFailed:
                mErrorArg = "RI_ConnectionFailed";
                break;
            
            case RI_ConnectionTimeout:
                mErrorArg = "RI_ConnectionTimeout";
                break;
            
            case RI_MustUpgrade:
                mErrorArg = "RI_MustUpgrade";
                break;
            
            default:
				mErrorArg = "RI_Unknown";
                break;
        }
		if ( mErrorArg != "" )
		{
			mError = Spawn( class'MenuInternetError', Owner );
			for ( r = 0; r < MOTDResponses.Length; ++r )
			{
				if ( MOTDResponses[r].MR == MR_UpgradeURL )
				{
					mError.UpgradeURL = MOTDResponses[r].Value;
				}
			}
			GotoMenu( mError, mErrorArg );
		}
    }
    
    simulated function OnXButton()
    {
        log("Query aborted");
        Servers.Reset();
        MSC.Stop();
        GotoState('PingingServers');
    }
    
    simulated function OnYButton()
    {
        MSC.Stop();
        
        if( ListMode == SLM_Buddies )
        {
            GotoMenuClass("XInterfaceMP.MenuInternetManageBuddies", "");
        }
        else if( ListMode == SLM_Lan )
        {
            GotoMenuClass("XInterfaceMP.MenuHostMain", "LAN");
        }
    }

    simulated function HandleInputBack()
    {
        MSC.Stop();
        global.HandleInputBack();
    }
}

state BroadcastPing
{
    simulated function BeginState()
    {
        Assert( MSC != None );

        MSC.CancelPings();
        MSC.Stop();

        MSC.bLANQuery = true;
	    MSC.BroadcastPingRequest();
        
        ProgressText.bHidden = 1;
        SetTimer( LanBeaconTimeout, false );
    }    

    simulated function OnReceivedPingInfo( int ServerID, MasterServerClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
    {
        S.ServerID = NextServerID++;
        Servers.PendingPing[Servers.PendingPing.Length] = s;
    }
    
    simulated function Timer()
    {
        GotoState('PingingServers');
    }
    
    simulated function OnXButton()
    {
        log("Query aborted");
        Servers.Reset();
        MSC.CancelPings();
        MSC.Stop();
        GotoState('PingingServers');
    }

    simulated function OnYButton()
    {
        MSC.Stop();
        SetTimer( 0, false );
        
        if( ListMode == SLM_Buddies )
        {
            GotoMenuClass("XInterfaceMP.MenuInternetManageBuddies", "");
        }
        else if( ListMode == SLM_Lan )
        {
            GotoMenuClass("XInterfaceMP.MenuHostMain", "LAN");
        }
    }

    simulated function HandleInputBack()
    {
        MSC.CancelPings();
        MSC.Stop();
        global.HandleInputBack();
    }
}

// This is where we're auto-pinging servers; if the user selects a server
// this will iniate a re-ping so we'll just stay in this state until they
// leave the menu or force a refresh.

state PingingServers
{
    simulated function BeginState()
    {
        ProgressText.bHidden = 0;
        ProgressText.Text = StringPingingServers $ "...";
        MaxSimultaneousPings = CalcMaxSimultaneousPings();
        SendAutoPings();
        UpdateProgress();
        SetTimer(TimeBetweenFatPings, true);
    }
    
    simulated function EndState()
    {
        SetTimer(0.f, false);
    }

    simulated function int CalcMaxSimultaneousPings()
    {
	    local int i;

		i = class'Player'.default.ConfiguredInternetSpeed;

		if ( i <= 2600 )
			return 10;

		if ( i <= 5000 )
			return 15;

		if ( i <= 10000 )
			return 20;

		if ( i <= 20000 )
			return 35;
    }
    
    simulated function Timer()
    {
        if( SelectedPosition < 0 )
        {
            return;
        }

        Servers.SendFullPing( MSC, SelectedPosition );
    }
    
    simulated function SendAutoPings()
    {
        local bool DoFullPing;
        
        while( (Servers.PendingPing.Length > 0) && (Servers.BeingPinged.Length < MaxSimultaneousPings) )
        {
            if( (ListMode == SLM_Favourites) || (ListMode == SLM_Recent) || (ListMode == SLM_Lan) )
            {
                doFullPing = true;
            }

            Servers.SendAutoPing( MSC, DoFullPing ); // Implicity moves a server from PendingPing -> BeingPinged
        }
    }
    
    simulated function OnReceivedPingInfo( int ServerID, MasterServerClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
    {
        Servers.PingedServer = s; // Scratch because you can't pass local structs to native function.
        
        if( PingCause == PC_AutoPing )
        {
            if( S.Ping <= MaxPing)
            {
                FinishAutoPing( ServerID, false );
            }
            else
            {
                FinishAutoPing( ServerID, true ); // Pretend it timed out.
            }
        }
        else if( PingCause == PC_Clicked )
        {
            Servers.UpdatePingedServer( ServerID, false );
        }
        else
        {
            log("Ignoring unexpected ping cause!", 'Error');
            return;
        }
        
        UpdateProgress();
        SendAutoPings();
    }

    simulated function OnPingTimeout( int ServerID, MasterServerClient.EPingCause PingCause )
    {
        if( PingCause == PC_AutoPing )
        {
            FinishAutoPing( ServerID, true );
        }
        else if( PingCause == PC_Clicked )
        {
            Servers.UpdatePingedServer( ServerID, true );
        }
        else
        {
            log("Ignoring unexpected ping cause!", 'Error');
        }
        
        UpdateProgress();
        SendAutoPings();
    }
    
    simulated function AddPingedServer()
    {
        local int InsertPoint;
        local int MaxPosition;

        InsertPoint = Servers.AddPingedServer();
        
        if( InsertPoint < 0 )
        {
            // This would happen if, strangely, this server already existed in the list (LAN browsing).
            return;
        }

        MaxPosition = Max( 0, Servers.Num() - DisplayCount );
            
        if( (InsertPoint <= SelectedPosition) && (CurrentPosition < MaxPosition) )
        {
            ++SelectedPosition;
            ++CurrentPosition;
        }
        else if( InsertPoint <= SelectedPosition )
        {
            ++SelectedPosition;
        }
        else if( (InsertPoint < CurrentPosition) && (CurrentPosition < MaxPosition) )
        {
            ++CurrentPosition;
        }

        if( Servers.Num() <= DisplayCount )
        {
            bDynamicLayoutDirty = true;
        }
        else if( (InsertPoint >= CurrentPosition) && ( InsertPoint < (CurrentPosition + DisplayCount)) )
        {
            bDynamicLayoutDirty = true;
        }

        // Update the scrollbar but muffle the callback so that we don't inadvertantly 
        // have it trigger a redraw or anything:
        
        ServerListScrollBar.OnScroll = '';
        UpdateScrollBar();
        ServerListScrollBar.OnScroll = 'OnScrollBarScroll';
    }
    
    simulated function FinishAutoPing( int ServerID, bool timedOut )
    {
        local int i;
        local bool addToPinged;
        
        for( i = 0; i < Servers.BeingPinged.Length; ++i )
        {
            if( Servers.BeingPinged[i].ServerId == ServerID )
            {
                if( timedOut )
                {
                    if( (ListMode == SLM_Favourites) || (ListMode == SLM_Recent) )
                    {
                        // Since this info isn't returned by OnPingTimeout
                        Servers.PingedServer = Servers.BeingPinged[i];
                        addToPinged = true;
                    }
                    else
                    {
                        Servers.TimedOut[Servers.TimedOut.Length] = Servers.BeingPinged[i];
                    }
                }
                else
                {
                    addToPinged = true;
                }
                
                Servers.BeingPinged.Remove( i, 1 );
                
                if( addToPinged )
                {
                    AddPingedServer();
                }
                
                return;
            }
        }
    }
    
    simulated function UpdateProgress()
    {
        local int pinged;
        local int pending;
        local int total;
        
        pinged = Servers.Pinged.Length + Servers.TimedOut.Length;
        pending = Servers.PendingPing.Length + Servers.BeingPinged.Length;
        total = pinged + pending;

        if( Servers.Pinged.Length > 0 )
        {
            MainMessage.bHidden = 1;
        }
            
        if( pinged != total )
        {
            // Still sending auto-pings:
            ProgressText.Text = StringPingingServers @ pinged $ "/" $ total;
        }
        else if( Servers.Pinged.Length == 0 )
        {
            MainMessage.Text = StringNoGamesFound;
            MainMessage.bHidden = 0;
            ProgressText.bHidden = 1;
        }
        else if( Servers.Pinged.Length == 1 )
        {
            ProgressText.Text = StringSearchCompleteSingle;
            ProgressText.bHidden = 0;
        }
        else if( Servers.Pinged.Length > 1 )
        {
            ProgressText.Text = ReplaceSubstring( StringSearchComplete, "<COUNT>", Servers.Pinged.Length );
            ProgressText.bHidden = 0;
        }
        
        if( pending > 0 )
        {
            XLabel.Text = StringStop;
            bDynamicLayoutDirty = true;
        }
        else
        {
            XLabel.Text = StringRefresh;
            bDynamicLayoutDirty = true;
        }
    }
    
    simulated function SelectRow( int SelectedRow )
    {
        global.SelectRow(SelectedRow);
    }
    
    simulated function OnXButton()
    {
        MSC.CancelPings();
        MSC.Stop();

        if( (Servers.PendingPing.Length + Servers.BeingPinged.Length) > 0 )
        {
            log("Pinging stopped");
            Servers.ClearPendingPings();
            Assert( (Servers.PendingPing.Length + Servers.BeingPinged.Length) == 0 );
            UpdateProgress();
        }
        else
        {
			bForceMOTD = true;
            GotoState('WaitingToStartQuery');
        }
    }
    
    simulated function OnWButton()
    {
        local MenuInternetServerDetails Details;
    
        Assert(SelectedPosition >= 0);
        Assert(SelectedPosition < Servers.Num());
        
        Details = Spawn( class'MenuInternetServerDetails', Owner );

        Details.Server = Servers.Pinged[SelectedPosition];
        Details.Servers = Servers;
        Details.bLANGame = (ListMode == SLM_LAN);
        
        CallMenu( Details );
    }
    
    simulated function OnAButton()
    {
        local MenuInternetServerJoin Join;
    
        Assert(SelectedPosition >= 0);
        Assert(SelectedPosition < Servers.Num());
        
        Join = Spawn( class'MenuInternetServerJoin', Owner );

        Join.Server = Servers.Pinged[SelectedPosition];
        Join.Servers = Servers;
        Join.bLANGame = (ListMode == SLM_LAN);
        
        CallMenu( Join );
    }
    
    simulated function OnKButton()
    {
        if( bool(Servers.Pinged[SelectedPosition].bFavourite) )
        {
            Servers.DelFavourite( Servers.Pinged[SelectedPosition] );
        }
        else
        {
            Servers.AddFavourite( Servers.Pinged[SelectedPosition] );
        }
        
        UpdateFavouritesButton();
    }
    
    simulated function OnYButton()
    {
        SetTimer( 0, false );
        MSC.Stop();
        
        if( ListMode == SLM_Buddies )
        {
            GotoMenuClass("XInterfaceMP.MenuInternetManageBuddies", "");
        }
        else if( ListMode == SLM_Lan )
        {
            GotoMenuClass("XInterfaceMP.MenuHostMain", "LAN");
        }
    }
    
    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        MSC.Stop();
        global.HandleInputBack();
    }
}

simulated static function string HumpFrenchie(string lang, string acronym)
{
    if(lang ~= "frt")
    {
        switch(acronym)
        {
            case "DM": 
            case "XDM":
                acronym = "CAM";
                break;
            case "TDM":
                acronym = "CAMPE";
                break;
            case "CTF":
                acronym = "CDD";
                break;
            case "AS":
                acronym = "ADF";
                break;
        }
    }
    return(acronym);
}

// From here on down it's all layout and control-related code:

simulated function FillInRow( int Row, int Server )
{
    ServerListColumns[SC_Server].Items[Row].ContextId = Row;

    ServerListColumns[SC_Server].Items[Row].OnUp = '';
    ServerListColumns[SC_Server].Items[Row].OnDown = '';

    ServerListColumns[SC_Server].Items[Row].Blurred.Text = Servers.Pinged[Server].ServerName;
    ServerListColumns[SC_Server].Items[Row].Focused.Text = Servers.Pinged[Server].ServerName;
    ServerListColumns[SC_Server].Items[Row].bHidden = 0;

    ServerListColumns[SC_Map].Items[Row].Blurred.Text = Servers.Pinged[Server].LongMapName;
    ServerListColumns[SC_Map].Items[Row].Focused.Text = Servers.Pinged[Server].LongMapName;
    ServerListColumns[SC_Map].Items[Row].bHidden = 0;

    ServerListColumns[SC_Game].Items[Row].Blurred.Text = HumpFrenchie(Lang, Caps(Servers.Pinged[Server].GameTypeAcronym));
    ServerListColumns[SC_Game].Items[Row].Focused.Text = ServerListColumns[SC_Game].Items[Row].Blurred.Text;
    ServerListColumns[SC_Game].Items[Row].bHidden = 0;

    ServerListColumns[SC_Full].Items[Row].Blurred.Text = String( Servers.Pinged[Server].CurrentPlayers ) $ "/" $ String( Servers.Pinged[Server].MaxPlayers );
    ServerListColumns[SC_Full].Items[Row].Focused.Text = ServerListColumns[SC_Full].Items[Row].Blurred.Text;
    ServerListColumns[SC_Full].Items[Row].bHidden = 0;

    if( Servers.Pinged[Server].Ping > 0 )
    {
        ServerListColumns[SC_Ping].Items[Row].Blurred.Text = String( Servers.Pinged[Server].Ping );
    }
    else
    {
        ServerListColumns[SC_Ping].Items[Row].Blurred.Text = "?";
    }
    
    ServerListColumns[SC_Ping].Items[Row].Focused.Text = ServerListColumns[SC_Ping].Items[Row].Blurred.Text;
    ServerListColumns[SC_Ping].Items[Row].bHidden = 0;
}

simulated function AddServerIcon( int Row, int Server, out int IconIndex, out float DX, Material IconMaterial )
{
    DX += IconDX;

    ServerIconColumns[IconIndex].Items[Row].bHidden = 0;
    ServerIconColumns[IconIndex].Items[Row].WidgetTexture = IconMaterial;
    
    ServerIconColumns[IconIndex].Items[Row].PosX = ServerListColumns[SC_Map].Items[Row].Blurred.PosX - DX;
    ServerIconColumns[IconIndex].Items[Row].PosY = ServerListColumns[SC_Map].Items[Row].Blurred.PosY;

    ++IconIndex;
}

simulated function AddServerIcons( int Row, int Server )
{
    local int IconIndex;
    local float DX;
    local float MaxSizeX;
    
    if( bool(Servers.Pinged[Server].bPrivate) )
    {
        AddServerIcon( Row, Server, IconIndex, DX, IconPrivate );
    }

    if( bool(Servers.Pinged[Server].bFavourite) )
    {
        AddServerIcon( Row, Server, IconIndex, DX, IconFavourite );
    }

    // It seems that these are a little poo :( Not really needed either! Let's disable for now.    
    //if( bool(Servers.Pinged[Server].bDedicated) )
    //{
    //    AddServerIcon( Row, Server, IconIndex, DX, IconDedicated );
    //}
    //
    //if( bool(Servers.Pinged[Server].bCustom) )
    //{
    //    AddServerIcon( Row, Server, IconIndex, DX, IconCustom );
    //}
    
    MaxSizeX = ServerListHeadings[SC_Map].Blurred.PosX - ServerListHeadings[SC_Server].Blurred.PosX;
    MaxSizeX -= DX;
    MaxSizeX -= ServerMaxSizeXFudge;

    ServerListColumns[SC_Server].Items[Row].Blurred.MaxSizeX = MaxSizeX;
    ServerListColumns[SC_Server].Items[Row].Focused.MaxSizeX = MaxSizeX;
    
    while( IconIndex < ArrayCount(ServerIconColumns) )
    {
        ServerIconColumns[IconIndex].Items[Row].bHidden = 1;
        ++IconIndex;
    }
}

simulated function SetRowHighlite( int row )
{
    local int col;

    UnSetRowHighlite();

    HighliteRow = row;

    ServerListColumns[0].Items[HighliteRow].Focused.DrawColor = SelectedColor;

    for( col = 0; col < SC_MAX; ++col )
    {
        ServerListColumns[col].Items[HighliteRow].Blurred.DrawColor = SelectedColor;
    }
}

simulated function UnSetRowHighlite()
{
    local int col;

    if( HighliteRow < 0 )
    {
        return;
    }

    ServerListColumns[0].Items[HighliteRow].Focused.DrawColor = NormalFocusedColor;

    for( col = 0; col < SC_MAX; ++col )
    {
        ServerListColumns[col].Items[HighliteRow].Blurred.DrawColor = NormalBlurredColor;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local int m;
    local int row;
    local float DX, DY;
    local float ScaleX;
    
    Super.DoDynamicLayout(C);
    
    UnSetRowHighlite();
    
    Assert( DisplayCount <= SERVER_MAX_ROWS ); 
    
    m = Min( DisplayCount, Servers.Num() );
    
    for( row = 0; row < m; ++row )
    {
        FillInRow( row, CurrentPosition + row );
    }
    
    if( DisplayCount < Servers.Num() )
    {
        ServerListColumns[SC_Server].Items[0].OnUp = 'OnServerListScrollUp';
        ServerListColumns[SC_Server].Items[m - 1].OnDown = 'OnServerListScrollDown';
    }
    else if( m > 0 )
    {
        ServerListColumns[SC_Server].Items[0].OnUp = 'DoNothing';
        ServerListColumns[SC_Server].Items[m - 1].OnDown = 'DoNothing';
    }

    // Gotta do this after fill-in so we know which are visible:
    if( m > 0 )
    {
        ServerColumnLayout.PosX = ServerListHeadings[SC_Server].Blurred.PosX;
        MapColumnLayout.PosX = ServerListHeadings[SC_Map].Blurred.PosX;
        GameColumnLayout.PosX = ServerListHeadings[SC_Game].Blurred.PosX;
        FullColumnLayout.PosX = ServerListHeadings[SC_Full].Blurred.PosX;
        PingColumnLayout.PosX = ServerListHeadings[SC_Ping].Blurred.PosX;
    
        LayoutWidgets( ServerListColumns[SC_Server].Items[0], ServerListColumns[SC_Server].Items[m - 1], 'ServerColumnLayout' );
        LayoutWidgets( ServerListColumns[SC_Map].Items[0], ServerListColumns[SC_Map].Items[m - 1], 'MapColumnLayout' );
        LayoutWidgets( ServerListColumns[SC_Game].Items[0], ServerListColumns[SC_Game].Items[m - 1], 'GameColumnLayout' );
        LayoutWidgets( ServerListColumns[SC_Full].Items[0], ServerListColumns[SC_Full].Items[m - 1], 'FullColumnLayout' );
        LayoutWidgets( ServerListColumns[SC_Ping].Items[0], ServerListColumns[SC_Ping].Items[m - 1], 'PingColumnLayout' );
    }
    
    // Gotta do it after layout so we know where to put them:
    for( row = 0; row < m; ++row )
    {
        AddServerIcons( row, CurrentPosition + row );
    }
    
    for( m = 0; m < ArrayCount(ServerListHeadings); ++m )
    {
        ServerListHeadings[m].ContextID = m;
    
        GetMenuTextSize( C, ServerListHeadings[m].Blurred, DX, DY );
        
        ScaleX = DX + ButtonBackgroundPaddingDX + (2.f * ButtonIconDX);

        ServerListHeadings[m].BackgroundBlurred.ScaleX = ScaleX;
        ServerListHeadings[m].BackgroundFocused.ScaleX = ScaleX;

        ServerListHeadings[m].BackgroundBlurred.DrawPivot = DP_MiddleLeft;
        ServerListHeadings[m].BackgroundFocused.DrawPivot = DP_MiddleLeft;
        
        if( ServerListHeadings[m].Blurred.DrawPivot == DP_MiddleLeft )
        {
            ServerListHeadings[m].BackgroundBlurred.PosX = 0.f;
            ServerListHeadings[m].BackgroundFocused.PosX = 0.f;
        }
        else if( ServerListHeadings[m].Blurred.DrawPivot == DP_MiddleRight )
        {
            ServerListHeadings[m].BackgroundBlurred.PosX = -DX;
            ServerListHeadings[m].BackgroundFocused.PosX = -DX;
        }
    }

    ProgressText.PosX = ServerListHeadings[0].Blurred.PosX + ScaleX + ButtonBarDX;
    ProgressText.PosY = ServerListHeadings[0].Blurred.PosY;
    ProgressText.MaxSizeX = ServerListHeadings[1].Blurred.PosX - ProgressText.PosX - ServerMaxSizeXFudge;
   
    row = SelectedPosition - CurrentPosition;
    
    if( (row >= 0) && (row < DisplayCount) )
    {
        SetRowHighlite(row);
    }
}

simulated function PostEditChange()
{
    local int i, j;

    Super.PostEditChange();
    
    for( i = 0; i < SC_MAX; ++i )
    {
        for( j = 0; j < ArrayCount(ServerListColumns[i].Items); ++j )
        {
            ServerListColumns[i].Items[j].bHidden = 1;
        }
    }

    for( i = 0; i < ArrayCount(ServerIconColumns); ++i )
    {
        for( j = 0; j < ArrayCount(ServerIconColumns[i].Items); ++j )
        {
            ServerIconColumns[i].Items[j].bHidden = 1;
        }
    }

    Servers.SetServerSortKey( SortKeys );
}

simulated function OnSortChange( int ContextID )
{
    local ServerList.EServerSortField Field;
    local int i;
    
    Field = EServerSortField(ContextID);
    
    if( (SortKeys.Length > 0) && (SortKeys[0].Field == Field) )
    {
        SortKeys[0].SortDirection *= -1;
    }
    else
    {
        for( i = 0; i < SortKeys.Length; ++i )
        {
            if( SortKeys[i].Field == Field )
            {
                SortKeys.Remove(i, 1);
                break;
            }
        }
        
        SortKeys.Insert(0, 1);
        SortKeys[0].Field = Field;
        SortKeys[0].SortDirection = 1;
    }
    
    Servers.SetServerSortKey( SortKeys );
    bDynamicLayoutDirty = true;
}

simulated exec function Pork()
{
    Servers.Pork();
    GotoState('PingingServers');
}

simulated function OnScrollBarScroll()
{
    CurrentPosition = ServerListScrollBar.Position;
    bDynamicLayoutDirty = true;
}

simulated function UpdateScrollBar()
{
    ServerListScrollBar.Position = CurrentPosition;
    ServerListScrollBar.Length = Servers.Num();
    ServerListScrollBar.DisplayCount = DisplayCount;
    
    LayoutMenuScrollBarEx( ServerListScrollBar, ServerListPageUp, ServerListPageDown ); // Will trigger a OnScrollBarScroll
}

simulated function ScrollServerListTo( int NewPosition )
{
    if( ServerListScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, ServerListScrollBar.Length - ServerListScrollBar.DisplayCount ) );

    if( ServerListScrollBar.Position == NewPosition )
        return;
    
    ServerListScrollBar.Position = NewPosition;
    
    LayoutMenuScrollBarEx( ServerListScrollBar, ServerListPageUp, ServerListPageDown ); // Will trigger a OnScrollBarScroll
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

simulated function FocusRow( int row )
{
    local int col;
    
    for( col = 1; col < SC_MAX; ++col )
    {
        ServerListColumns[col].Items[row].Blurred.DrawColor = ServerListColumns[0].Items[row].Focused.DrawColor;
    }
}

simulated function BlurRow( int row )
{
    local int col;
    
    for( col = 1; col < SC_MAX; ++col )
    {
        ServerListColumns[col].Items[row].Blurred.DrawColor = ServerListColumns[0].Items[row].Blurred.DrawColor;
    }
}

simulated function SelectRow( int SelectedRow )
{
    SelectedPosition = CurrentPosition + SelectedRow;
    SetRowHighlite( SelectedRow );
    
    if( ListMode != SLM_Lan )
    {
        HideKButton(0);
    }
    
    HideWButton(0);

    if( Servers.Pinged[SelectedPosition].Ping > 0 )
    {
        HideAButton(0);
    }
    else
    {
        HideAButton(1);
    }

    UpdateFavouritesButton();
}

simulated function UpdateFavouritesButton()
{
    if( bool(Servers.Pinged[SelectedPosition].bFavourite) )
    {
        KLabel.Text = StringRemoveFromFavourites;
    }
    else
    {
        KLabel.Text = StringAddToFavourites;
    }
    
    bDynamicLayoutDirty = true;
}

defaultproperties
{
     ServerListHeadings(0)=(Blurred=(Text="Server",DrawPivot=DP_MiddleLeft,PosX=0.064000,PosY=0.120000),bIgnoreController=1,OnSelect="OnSortChange",Pass=3,Style="SmallPushButtonRounded")
     ServerListHeadings(1)=(Blurred=(Text="Map",DrawPivot=DP_MiddleLeft,PosX=0.500000))
     ServerListHeadings(2)=(Blurred=(Text="Game",DrawPivot=DP_MiddleRight,PosX=0.764000))
     ServerListHeadings(3)=(Blurred=(Text="Size",DrawPivot=DP_MiddleRight,PosX=0.850000))
     ServerListHeadings(4)=(Blurred=(Text="Ping",DrawPivot=DP_MiddleRight,PosX=0.936000))
     ServerListColumns(0)=(Items[0]=(Blurred=(DrawPivot=DP_MiddleLeft),OnFocus="FocusRow",OnBlur="BlurRow",OnSelect="SelectRow",OnDoubleClick="OnAButton",Style="ServerBrowserActiveCell"))
     ServerListColumns(1)=(Items[0]=(Blurred=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.190000),Style="ServerBrowserPassiveCell"))
     ServerListColumns(2)=(Items[0]=(Blurred=(DrawPivot=DP_MiddleRight),Style="ServerBrowserPassiveCell"))
     ServerListColumns(3)=(Items[0]=(Blurred=(DrawPivot=DP_MiddleRight),Style="ServerBrowserPassiveCell"))
     ServerListColumns(4)=(Items[0]=(Blurred=(DrawPivot=DP_MiddleRight),Style="ServerBrowserPassiveCell"))
     ServerIconColumns(0)=(Items[0]=(DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000))
     ServerIconColumns(1)=(Items[0]=(DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000))
     ServerIconColumns(2)=(Items[0]=(DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000))
     IconCustom=Texture'PariahInterface.ServerIcons.Custom'
     IconDedicated=Texture'PariahInterface.ServerIcons.Dedicated'
     IconPrivate=Texture'PariahInterface.ServerIcons.Locked'
     IconFavourite=Texture'PariahInterface.ServerIcons.Favourite'
     IconDX=0.020000
     ServerMaxSizeXFudge=0.020000
     ServerListArrows(0)=(Blurred=(PosX=0.970000,PosY=0.184000),OnSelect="OnServerListScrollUp",Style="TitledStringListArrowUp")
     ServerListArrows(1)=(Blurred=(PosY=0.815000),OnSelect="OnServerListScrollDown",Style="TitledStringListArrowDown")
     ServerListScrollBar=(PosX1=0.970000,PosY1=0.200000,PosX2=0.970000,PosY2=0.800000,OnScroll="OnScrollBarScroll",Style="VerticalScrollBar")
     ServerListPageUp=(bIgnoreController=1,OnSelect="OnServerListPageUp",Pass=2)
     ServerListPageDown=(bIgnoreController=1,OnSelect="OnServerListPageDown",Pass=2)
     ServerScrollArea=(X1=0.020000,Y1=0.100000,X2=0.950000,Y2=0.850000,OnScrollTop="OnServerListTop",OnScrollPageUp="OnServerListPageUp",OnScrollLinesUp="OnServerListScrollLinesUp",OnScrollLinesDown="OnServerListScrollLinesDown",OnScrollPageDown="OnServerListPageDown",OnScrollBottom="OnServerListBottom")
     SelectedPosition=-1
     HighliteRow=-1
     MainMessage=(Style="MessageText")
     StringLookingForGames="Looking for games..."
     StringNoGamesFound="No games found."
     StringDownloadingList="Downloading list"
     StringPingingServers="Pinging servers"
     StringSearchCompleteSingle="Found 1 server."
     StringSearchComplete="Found <COUNT> servers."
     StringStop="Stop"
     StringRefresh="Refresh"
     StringAddToFavourites="Add Favourite"
     StringRemoveFromFavourites="Del. Favourite"
     StringHostGame="Host Game"
     StringDownloadingMOTD="Downloading MOTD"
     ProgressText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.600000,MaxSizeX=0.700000,Pass=4)
     DisplayCount=15
     ServerColumnLayout=(PosY=0.185000,SpacingY=0.045000)
     MapColumnLayout=(PosY=0.185000,SpacingY=0.045000)
     GameColumnLayout=(PosY=0.185000,SpacingY=0.045000)
     FullColumnLayout=(PosY=0.185000,SpacingY=0.045000)
     PingColumnLayout=(PosY=0.185000,SpacingY=0.045000)
     SortKeys(0)=(Field=SSF_Ping,SortDirection=1)
     SelectedColor=(G=150,R=255,A=255)
     MaxPing=1000
     TimeBetweenFatPings=4.000000
     NextServerID=1
     LanBeaconTimeout=1.000000
     YLabel=(Text="Buddies")
     KButtonHidden=1
     WLabel=(Text="Details")
     WButtonHidden=1
     ALabel=(Text="Join")
     APlatform=MWP_All
     AButtonHidden=1
     XLabel=(Text="")
     XButtonHidden=1
     MenuTitle=(bHidden=1)
     Background=(DrawColor=(A=50))
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
