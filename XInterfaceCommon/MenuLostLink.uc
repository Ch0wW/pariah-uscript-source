class MenuLostLink extends MenuTemplateTitledBA;

var() MenuText Message;
var() bool WasPaused;

simulated function Init( String Args )
{
    // "There's no connection available, please check your cable."
    Message.Text = class'XboxStandardMsgs'.default.ErrorMsg[10];

    if( PlayerController(Owner).LiveStatus == LS_SignedIn )
    {
        Message.Text = Localize( "Errors", "XONLINE_E_LOGON_CONNECTION_LOST", "XboxLive" ) $ "\\n\\n" $ Message.Text;
        ConsoleCommand("XLIVE LOGOFF -1");
    }
    
    if( IsMiniEd() && MiniEdMapIsLive() )
    {
        // TODO: Extra warning!
    }
    
    Controller(Owner).bFire = 0;
    Controller(Owner).bAltFire = 0;

    WasPaused = PlayerController(Owner).SetPause(true);

    Super.Init(Args);
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function OnBButton()
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
        if( (PreviousMenu != None) && !FindNetMenu(PreviousMenu) )
        {
            CloseMenu();
        }
        else if( MiniEdMapIsLoaded() )
        {
            CloseDownToMenuEditor(C);
        }
        else
        {
            M = Spawn( class<Menu>( DynamicLoadObject( "MiniEd.MenuMiniEdMain", class'Class' ) ), Owner );
            C.MenuOpenExisting( M );
            M.Init(""); // Sick! Make sure we defer all init until after everything is destroyed (including self)
        }
        return;
    }

    if( InMenuLevel() )
    {
        if( FindNetMenu(PreviousMenu) )
        {
            M = Spawn( class<Menu>( DynamicLoadObject( "XInterfaceMP.MenuMultiplayerMain", class'Class' ) ), Owner );
            PC = PlayerController(Owner);        
            C = PC.Player.Console;
            C.MenuOpenExisting( M );
            M.Init(""); // Sick! Make sure we defer all init until after everything is destroyed (including self)
        }
        else
        {
            CloseMenu();
        }
        return;
    }
    
    if( Level.NetMode == NM_Standalone )
    {
        if( FindNetMenu(PreviousMenu) )
        {
            C = PC.Player.Console;
            C.MenuClose();
        }
        else
        {
            CloseMenu();
        }
        return;
    }
    
    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceMP.MenuMultiplayerMain";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();
    ConsoleCommand("REALLYDISCONNECT");
    return;
}

simulated function OnAButton()
{
    CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", "XLD_LAUNCH_DASHBOARD_NETWORK_CONFIGURATION" );
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }

    if( ButtonName ~= "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Style="MedMessageText")
     ALabel=(Text="Troubleshooter")
     BLabel=(Text="Cancel")
     CrossFadeRate=20.000000
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
