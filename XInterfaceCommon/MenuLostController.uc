class MenuLostController extends MenuTemplateTitledA;

// Args: [ port index ]
var() MenuText  Message;
var() bool      WasPaused;
var() int       ControllerIndex;

simulated function Init( String Args )
{
    local MenuTemplateTitled SubMenu;
    local string HostDetails;

    // get previous
    SubMenu = MenuTemplateTitled( PreviousMenu );
    
    if( SubMenu != None && SubMenu.bRenderLevel==false )
        Background = SubMenu.Background;

    bAcceptInput = false;
    ControllerIndex = PlayerController(Owner).Player.GamePadIndex;

    log("@@@ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    log("@@@ LostController: Prev: "$PreviousMenu);
    log("@@@ LostController: Owner: "$Owner);
    log("@@@ LostController: Pauser: "$Level.Pauser);
    log("@@@ LostController: ControllerIndex: "$ControllerIndex);
    
    if( !IsMiniEd() )
    {
        // Sadly, this exec is handled in GameEngine and in MiniEdEngine this falls through to exec "GET"
        HostDetails = ConsoleCommand("GET_HOST_DETAILS");
    }

    HideAButton(0);
    Message.Text = class'XboxStandardMsgs'.default.ErrorMsg[6];

    log("@@@ LostController: HostDetails="$HostDetails);
    if(HostDetails == "")
    {
        // see if we can pause the game
        if(!Level.IsPausable())
        {
            log("@@@ LostController: In cin or mat, SetTimer");
            SetTimer(0.1, false);
        }
        else
        {
            log("@@@ LostController: Try to pause...");
            WasPaused = PlayerController(Owner).SetPause(true);
        }
    }

    log("@@@ LostController: wasPaused="$WasPaused);
    log("@@@ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    UpdateTextField(Message.Text, "%d", string(ControllerIndex + 1)); // show port 1 - 4

    Super.Init(Args);
}

simulated function Timer()
{
    log("@@@ LostController: Timer");
    
    if(!Level.IsPausable())
    {
        SetTimer(0.1, false);
    }
    else if(!bool(ConsoleCommand("XCLIENT CONTROLLER_CONNECTED"@ControllerIndex)))
    {
        WasPaused = PlayerController(Owner).SetPause(true);
        bAcceptInput = true;
    }
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function OnAButton()
{
    CloseMenu();
}

simulated function CloseMenu()
{
    log("@@@ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    if(WasPaused)
    {
        log("@@@ LostController: Unpausing");
        PlayerController(Owner).SetPause(false);
    }

    log("@@@ LostController: CloseMenu");
    log("@@@ LostController: wasPaused="$WasPaused);    
    log("@@@ LostController: Prev: "$PreviousMenu);
    log("@@@ LostController: Owner: "$Owner);
    log("@@@ LostController: Pauser: "$Level.Pauser);
    log("@@@ LostController: ControllerIndex: "$ControllerIndex);    
    log("@@@ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    
    Super.CloseMenu();
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

simulated function HandleInputBack();

defaultproperties
{
     Message=(Style="MessageText")
     ALabel=(Text="Continue")
     APlatform=MWP_All
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
