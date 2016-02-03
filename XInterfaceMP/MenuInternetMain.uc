class MenuInternetMain extends MenuTemplateTitledBA;

var() MenuButtonText Options[6];

var() config int Position;

var MasterServerClient						MSC; 
var array<MasterServerClient.MOTDResponse>	MOTDResponses;
var bool									bMOTDQuerySent;

var localized string ConnectingMsg;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    MSC = Spawn(class'MasterServerClient', Owner);
    Assert( MSC != None );
    
    MSC.OnQueryFinished = OnQueryFinished;
	MSC.OnReceivedMOTDData = OnReceivedMOTDData;
}

simulated function Destroyed()
{
    if( MSC != None )
    {
	    MSC.Stop();
        MSC.Destroy();
    }
}

// All of our delegates should be handled in specific states:

simulated function OnQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
    log("Ignoring unexecpted OnQueryFinished()", 'Error');
}

simulated function OnReceivedMOTDData( MasterServerClient.EMOTDResponse Command, string Value )
{
	log("Ignoring unexpected OnReceivedMOTDData("$Command$","$Value$")");
}

simulated function Init( String Args )
{
    Super.Init( Args ); 

	GotoState('GetMOTD');
}

state GetMOTD
{
    simulated function BeginState()
    {
		local string tmp;

        Assert( MSC != None );

		// swap menu title strings while querying master server
		//
		tmp = MenuTitle.Text;
		MenuTitle.Text = ConnectingMsg;
		ConnectingMsg=tmp;

		bMOTDQuerySent = MSC.MOTDQuerySent();
        MSC.CancelPings();
        MSC.Stop();
        MSC.StartQuery( CTM_GetMOTD );
        
		MOTDResponses.Length = 0;
    }    

	simulated function EndState()
	{
		local string tmp;

		// swap menu title string back
		//
		tmp = MenuTitle.Text;
		MenuTitle.Text = ConnectingMsg;
		ConnectingMsg=tmp;
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
				// if there are MOTD responses and this was the first MOTD query sent
				// this session, goto the MOTD page
				if ( MOTDResponses.Length > 0 && !bMOTDQuerySent )
				{
					mMOTD = Spawn( class'MenuInternetMOTD', Owner );
					mMOTD.MOTDResponses = MOTDResponses;
					CallMenu( mMOTD );
				}

		        GotoState('HandleButtons');
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

    simulated function HandleInputBack()
    {
        MSC.Stop();
        global.HandleInputBack();
    }
}

simulated function HandleInputBack()
{
    SavePosition();
    GotoMenuClass( "XInterfaceMP.MenuMultiplayerMain" );
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(Options); Position++ )
    {
        if( Options[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(Options) )
        Position = 0;

    SaveConfig();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

state HandleButtons
{
	simulated function BeginState()
	{
		Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
		if( Options[Position].bHidden != 0 )
		{
			for( Position = 0; Options[Position].bHidden != 0; Position++ )
				;
		}

		FocusOnWidget( Options[Position] );
	}

	simulated function OnInstantAction()
	{
		SavePosition();
		GotoMenuClass("XInterfaceMP.MenuInternetInstantAction");
	}

	simulated function OnAdvancedSearch()
	{
		SavePosition();
		GotoMenuClass("XInterfaceMP.MenuInternetAdvancedSearch");
	}

	simulated function OnHostGame()
	{
		SavePosition();
		GotoMenuClass("XInterfaceMP.MenuHostMain", "INTERNET");
	}

	simulated function OnFavourites()
	{
		local MenuInternetServerList M;

		SavePosition();
	 
		M = Spawn( class'MenuInternetServerList', Owner );
		M.ListMode = SLM_Favourites;

		GotoMenu( M );
	}

	simulated function OnRecentServers()
	{
		local MenuInternetServerList M;

		SavePosition();
	 
		M = Spawn( class'MenuInternetServerList', Owner );
		M.ListMode = SLM_Recent;

		GotoMenu( M );
	}

	simulated function OnFindBuddies()
	{
		SavePosition();
		class'MenuInternetManageBuddies'.static.StartQuery( self );
	}
}

simulated function OnInstantAction()
{
}

simulated function OnAdvancedSearch()
{
}

simulated function OnHostGame()
{
}

simulated function OnFavourites()
{
}

simulated function OnRecentServers()
{
}

simulated function OnFindBuddies()
{
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Instant Action"),HelpText="Find a server to play on",OnSelect="OnInstantAction",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Advanced Search"),HelpText="Find a server using advanced filters",OnSelect="OnAdvancedSearch")
     Options(2)=(Blurred=(Text="Host Game"),HelpText="Host a game to play with others",OnSelect="OnHostGame")
     Options(3)=(Blurred=(Text="Favourite Servers"),HelpText="Check your favourite servers for games",OnSelect="OnFavourites")
     Options(4)=(Blurred=(Text="Recent Servers"),HelpText="Check servers you've played on recently",OnSelect="OnRecentServers")
     Options(5)=(Blurred=(Text="Find Buddies"),HelpText="See where your friends are playing",OnSelect="OnFindBuddies")
     ConnectingMsg="Connecting to Pariah Master Server..."
     MenuTitle=(Text="Internet Multiplayer")
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
