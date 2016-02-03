class MenuLiveErrorMessage extends MenuTemplateTitledBA;

// Args: <OPERATION_NAME>

var() MenuText ErrorText;

var() MenuText ServiceNumber;
var() MenuText ServiceCode;

var() MenuText ErrorNumber;
var() MenuText ErrorCode;

var() String LiveErrorCode;
var() String LiveErrorNumber;
var() String LiveErrorString;

var() String LiveServiceCode;
var() String LiveServiceNumber;
var() String LiveServiceString;

const LivePrefix = "XONLINE_";

var() String LastErrorDash;
var() localized String StringDashMain;
var() localized String StringDashError;
var() localized String StringDashMemory;
var() localized String StringDashSettings;
var() localized String StringDashMusic;
var() localized String StringDashNetwork;
var() localized String StringDashNewAccount;
var() localized String StringDashManageAccount;
var() localized String StringDashOnlineMenu;

var() localized String StringReadMessage;
var() localized String StringCancelLogin;

var() String MainMenuClass;
var() String MiniEdMenuClass;

var() bool WasPaused;

simulated function Init( String Args )
{
    local String OperationName;
    local String S;

    Super.Init( Args );

    OperationName = Args;
        
    log( "Args:" @ Args );

    Controller(Owner).bFire = 0;
    Controller(Owner).bAltFire = 0;
    
    WasPaused = PlayerController(Owner).SetPause(true);
            
    LastErrorDash = ConsoleCommand("XLIVE ALLOW_BOOT_TO_DASH");
  
    if( LastErrorDash == "" )
        HideBButton( 1 );
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_MAIN_MENU" )
        BLabel.Text = StringDashMain;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_ERROR" )
        BLabel.Text = StringDashError;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_MEMORY" )
        BLabel.Text = StringDashMemory;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_SETTINGS" )
        BLabel.Text = StringDashSettings;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_MUSIC" )
        BLabel.Text = StringDashMusic;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_NEW_ACCOUNT_SIGNUP" )
        BLabel.Text = StringDashNewAccount;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_ACCOUNT_MANAGEMENT" )
        BLabel.Text = StringDashManageAccount;
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_ONLINE_MENU" )
        BLabel.Text = StringDashOnlineMenu;
    else
        log( "Unknown value for ALLOW_BOOT_TO_DASH:" @ LastErrorDash );
    
    S = ConsoleCommand("XLIVE LASTERROR");

    LiveErrorCode = ParseToken(S);
    LiveErrorNumber = ParseToken(S);
    LiveErrorString = ParseToken(S);

    LiveServiceCode = ParseToken(S);
    LiveServiceNumber = ParseToken(S);
    LiveServiceString = ParseToken(S);

    if( ForceLogoff() )
    {
        log("Forcing logoff:"@ LiveErrorCode);
        ConsoleCommand("XLIVE LOGOFF -1");
    }

    ErrorCode.Text = ErrorCode.Text @ LiveErrorCode;
    ErrorNumber.Text = ErrorNumber.Text @ LiveErrorNumber;

    ServiceCode.Text = ServiceCode.Text @ LiveServiceCode;
    ServiceNumber.Text = ServiceNumber.Text @ LiveServiceNumber;

    if( LiveErrorString != "" )
        ErrorText.Text = LiveErrorString;
    else if( OperationName != "" )
        ErrorText.Text = Localize( "Errors", OperationName, "XboxLive" );
    
    if( (LiveErrorCode == "XONLINE_E_CANNOT_ACCESS_SERVICE") || (LiveErrorCode == "XONLINE_E_LOGON_CANNOT_ACCESS_SERVICE") )
    {
        ALabel.Text = StringDashNetwork; 
        BLabel.Text = StringCancel;
    }
    else if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_NETWORK_CONFIGURATION" )
    {
        ALabel.Text = StringDashNetwork; 
        BLabel.Text = StringContinue;
    }
    else if( LiveErrorCode == "XONLINE_E_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT" )
    {
        ALabel.Text = StringReadMessage;
        BLabel.Text = StringCancelLogin;
    }
    else if( LiveErrorCode == "XONLINE_E_LOGON_INVALID_USER" )
    {
        ALabel.Text = StringDashManageAccount;
        BLabel.Text = StringCancelLogin;
        GamertagText.PosX = 2.5; // Move this bad boy off the screen! We ship in 5 minutes.
    }

    if( InStr(ErrorCode.Text, LivePrefix) >= 0 )
    {
        if( LiveServiceString != "" )
            ErrorText.Text = LiveServiceString @ ErrorText.Text;
        else
        {
            ServiceNumber.bHidden = 1;
            ServiceCode.bHidden = 1;
        }
    }
    else
    {
        ErrorNumber.bHidden = 1;
        ErrorCode.bHidden = 1;
        
        ServiceNumber.bHidden = 1;
        ServiceCode.bHidden = 1;
    }
    
    ErrorText.Text = ErrorText.Text;
}

simulated function String GetMainMenuClass()
{
    if( IsMiniEd() )
    {
        return("MiniEd.MenuMiniEdMain");
    }
    else
    {
        return("XInterfaceMP.MenuMultiplayerMain");
    }
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function BreakItDownLikeThis()
{
    local Menu M;
    local PlayerController PC;
    local Console C;

    PC = PlayerController(Owner);
    C = PC.Player.Console;

    if( WasPaused )
    {
        PlayerController(Owner).SetPause(false);
    }

    if( IsMiniEd() )
    {
        if( (PreviousMenu != None) && !FindLiveMenu(PreviousMenu) )
        {
            CloseMenu();
        }
        else if( MiniEdMapIsLoaded() )
        {
            CloseDownToMenuEditor(C);
        }
        else
        {
            M = Spawn( class<Menu>( DynamicLoadObject( GetMainMenuClass(), class'Class' ) ), Owner );
            C.MenuOpenExisting( M );
            M.Init(""); // Sick! Make sure we defer all init until after everything is destroyed (including self)
        }
        return;
    }

    if( InLiveGame() ) 
    {
        // If they're in a Live game, they need to be disconnected back to main.
        class'GameEngine'.default.DisconnectMenuClass = GetMainMenuClass();
        class'GameEngine'.default.DisconnectMenuArgs = "";
        class'GameEngine'.static.StaticSaveConfig();
        ConsoleCommand("REALLYDISCONNECT");
        return;
    }

    if( !InMenuLevel() ) // Covers the case of SP, or SystemLink
    {
        CloseMenu();
        
        if( Level.NetMode != NM_DedicatedServer )
        {
            // Hack: close down to any in-progress vignettes; we have to leave up those vignettes!
            // We don't want to leave them in the Friends menu or something.
            PC.Player.Console.CurMenu = PC.Player.Console.CloseVignettes( PC.Player.Console.CurMenu, true );
            
            // Hack: If we actually closed them all, we need to reset the Menu state so you get input again.
            if( PC.Player.Console.CurMenu == None )
                PC.Player.Console.MenuClose();
        }
        return;
    }

    if( !FindLiveMenu(PreviousMenu) )
    {
        // If they're in a non-Live menu just pop off this menu back to the previous.
        CloseMenu();
        return;
    }

    // If they're in a Live menu they need to be booted back to main.
    M = Spawn( class<Menu>( DynamicLoadObject( GetMainMenuClass(), class'Class' ) ), Owner );
    C.MenuOpenExisting( M );
    M.Init(""); // Sick! Make sure we defer all init until after everything is destroyed (including self)
    return;
}

simulated function bool StartsWith( String TestString, String Prefix )
{
    return( Left( TestString, Len( Prefix) ) == Prefix );
}

simulated function OnBButton()
{
    if( BLabel.bHidden != 0 )
        return;

    if
    (
        (LiveErrorCode == "XONLINE_E_CANNOT_ACCESS_SERVICE") ||
        (LiveErrorCode == "XONLINE_E_LOGON_CANNOT_ACCESS_SERVICE") ||
        (LiveErrorCode == "XONLINE_E_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT") ||
        (LastErrorDash == "XLD_LAUNCH_DASHBOARD_NETWORK_CONFIGURATION") || 
        (LiveErrorCode == "XONLINE_E_LOGON_INVALID_USER")
    )
    {
        BreakItDownLikeThis();
    }    
    else
    {
        CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", LastErrorDash );
    }
}

simulated function bool ForceLogoff()
{
    if
    (
        StartsWith( LiveErrorCode, "PLAYER_" ) ||
        StartsWith( LiveErrorCode, "FRIEND_" ) ||
        StartsWith( LiveErrorCode, "STATS_" ) ||
        StartsWith( LiveErrorCode, "MATCHMAKING_" ) ||
        (LiveErrorCode == "BAD_PASSCODE") ||
        (LiveErrorCode == "XONLINE_E_FRIENDS_LIST_ERROR") ||
        (LiveErrorCode == "XONLINE_E_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT") ||
        (LiveErrorCode == "FRIEND_ACCEPT_CROSS_TITLE_INVITE_FAILED") ||
        (LiveErrorCode == "XONLINE_E_NOTIFICATION_LIST_FULL")
    )
    {
        return false;
    }
    else
    {
        return true;
    }
 
}

simulated function OnAButton()
{
    if
    (
        (LiveErrorCode == "XONLINE_E_CANNOT_ACCESS_SERVICE") ||
        (LiveErrorCode == "XONLINE_E_LOGON_CANNOT_ACCESS_SERVICE") ||
        (LiveErrorCode == "XONLINE_E_LOGON_USER_ACCOUNT_REQUIRES_MANAGEMENT") ||
        (LastErrorDash == "XLD_LAUNCH_DASHBOARD_NETWORK_CONFIGURATION") || 
        (LiveErrorCode == "XONLINE_E_LOGON_INVALID_USER")
    ) 
    {
        CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", LastErrorDash );
    }
    else if
    (
        StartsWith( LiveErrorCode, "PLAYER_" ) ||
        StartsWith( LiveErrorCode, "FRIEND_" ) ||
        StartsWith( LiveErrorCode, "STATS_" ) ||
        StartsWith( LiveErrorCode, "MATCHMAKING_" ) ||
        (LiveErrorCode == "BAD_PASSCODE") ||
        (LiveErrorCode == "XONLINE_E_FRIENDS_LIST_ERROR") ||
        (LiveErrorCode == "XONLINE_E_NOTIFICATION_LIST_FULL")
    )
    {
        if( WasPaused )
        {
            PlayerController(Owner).SetPause(false);
        }
    
        // Let them go back to the last menu they were at.
        CloseMenu();
    }
    else if( LiveErrorCode == "FRIEND_ACCEPT_CROSS_TITLE_INVITE_FAILED" )
    {
        if( WasPaused )
        {
            PlayerController(Owner).SetPause(false);
        }
    
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    }
    else
    {
        BreakItDownLikeThis();
    }
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }

    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function bool FindNetMenu(Menu M)
{
    return(false);
}

simulated function bool IsNetMenu()
{
    return(false);
}

simulated function bool IsLiveMenu()
{
    return(false);
}

defaultproperties
{
     ErrorText=(Style="MedMessageText")
     ServiceNumber=(Text="Service number:",DrawPivot=DP_MiddleRight,PosX=0.900000,PosY=0.680000,MaxSizeX=0.800000,bHidden=1,Style="LabelText")
     ServiceCode=(DrawPivot=DP_MiddleRight,PosX=0.900000,PosY=72.000000,MaxSizeX=0.800000,bHidden=1,Style="LabelText")
     ErrorNumber=(Text="Error number:",DrawPivot=DP_MiddleRight,PosX=0.900000,PosY=0.760000,MaxSizeX=0.800000,bHidden=1,Style="LabelText")
     ErrorCode=(DrawPivot=DP_MiddleRight,PosX=0.900000,PosY=0.800000,MaxSizeX=0.800000,bHidden=1,Style="LabelText")
     StringDashMain="Dashboard"
     StringDashError="Diagnostics"
     StringDashMemory="Memory Manager"
     StringDashSettings="Settings"
     StringDashMusic="Music Browser"
     StringDashNetwork="Troubleshooter"
     StringDashNewAccount="Create New Account"
     StringDashManageAccount="Manage Account"
     StringDashOnlineMenu="Online Menu"
     StringReadMessage="Read Message"
     StringCancelLogin="Cancel Sign In"
     ALabel=(Text="Continue")
     APlatform=MWP_All
     BLabel=(Text="")
     MenuTitle=(Text="Xbox Live")
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
     bFullscreenOnly=True
}
