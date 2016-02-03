class OverlayLiveUtility extends MenuTemplate;

var() MenuText          WarningMessage;
var() MenuText          WarningMessage2;
var() MenuSprite        DarkBack;

var() float             InformationDisplayTime;
var() PlayerController  PlayerOwner;
var() bool              ShowingWarning;
var() MenuBase          CurMenu;

var() localized string  YouAreGuestText;
var() localized string  YouHaveGuestText;
var() localized string  AddingSplitscreen;
var() localized string  FailedAddingSplitscreen;
var() localized string  FailedAddingReason;
var() localized string  FailedAddingReasonSP;


simulated function Init( String Args )
{
    Super.Init( Args );
    PlayerOwner = PlayerController(Owner);
    GotoState('WaitingForViewport');
}

simulated function ViewportInit()
{
    local menu m;
    local Menu current;
    
    log("PlayerOwner="$PlayerOwner);
    log("PlayerOwner.Player="$PlayerOwner.Player);
    log("PlayerOwner.Player.Console="$PlayerOwner.Player.Console);

    current = PlayerOwner.Player.Console.CurMenu;

    log("PlayerOwner.Player.Console.CurMenu="$current);
    
    if(current != None)
    {
        CurMenu = MenuBase(current);
        assert(CurMenu != None);
    }
    
    if(PlayerOwner.IsSharingScreen() && !PlayerOwner.SplitLoadLastProfile())
    {
        // cannot load - no 'last' one or inuse/invalid/etc
        // force profile selection/creation
        m = Spawn(class'MenuProfileMain', Owner);
        m.Init("");
        PlayerOwner.Player.Console.MenuCallExisting(m, "");
        GotoState('SelectingProfile');
    }
}

simulated function Timer()
{
    log("OverlayLiveUtility::Timer()");
    ShowingWarning = false;
    CrossFadeDir = TD_Out;
}

// hack!!! don't change the name of this function - called from native code with FindFunction!
simulated function ParseWarning(string Cmd)
{
    log("ParseWarning"@Cmd);
    if( Cmd == "GUEST_JOINED" )
    {
        ShowWarning(YouHaveGuestText);
    }
    else if ( Cmd == "ADDING_SPLIT" )
    {
        ShowWarning(AddingSplitscreen);
    }
    else if ( Cmd == "ADD_SPLIT_FAILED" )
    {
        if( Level.NetMode == NM_StandAlone && GetCurrentGameProfile() != None )
        {
            ShowWarning(FailedAddingSplitscreen, FailedAddingReasonSP);
        }
        else
        {
            ShowWarning(FailedAddingSplitscreen, FailedAddingReason);
        }
    }
}

simulated function ShowWarning(string Msg, optional string Msg2)
{
    log("ShowWarning"@Msg@Msg2);
    ShowingWarning = true;
    WarningMessage.Text = Msg;
    WarningMessage2.Text = Msg2;
    SetTimer(InformationDisplayTime, false);
    CrossFadeDir = TD_In;
}

simulated function string GetHostingGamerTag()
{
    local int gamepad;
    if(Level.GetAuthMode() == AM_Live)
    {
        gamepad = PlayerOwner.Player.GamePadIndex;
        if("TRUE" == ConsoleCommand("XLIVE INDEX_IS_GUEST"@gamepad))
        {
            return(ConsoleCommand("XLIVE GET_GAMER_TAG"@gamepad));
        }
    }
    return("");
}

simulated function Menu GetBottomMenu()
{
    return(CurMenu);
}


state WaitingForViewport
{
    simulated function Timer()
    {
        if( PlayerOwner.Player != None && PlayerOwner.Player.GamePadIndex != -1 )
        {
            GotoState('');
            ViewportInit();
        }
        else
        {
            SetTimer(0.1, false);
        }
    }

    simulated function BeginState()
    {
        log("WaitingForViewport::BeginState");
        SetTimer(0.1, false);
    }

    simulated function EndState()
    {
        if( ShowingWarning )
        {
            log("WaitingForViewport::EndState() setting timer!");
            SetTimer(InformationDisplayTime, false);
        }
    }
}

state SelectingProfile
{
    simulated function BeginState()
    {
        log("SelectingProfile::BeginState");
    }
    
    simulated function EndState()
    {
        local string hostingGamerTag;

        log("SelectingProfile::EndState");
        
        hostingGamerTag = GetHostingGamerTag();
        log(self @ "SelectingProfile::MenuClosed(), hostingGamerTag=" $ hostingGamerTag);
        if(hostingGamerTag != "")
        {
            ShowWarning(YouAreGuestText, hostingGamerTag);
        }
    }
}

defaultproperties
{
     warningMessage=(DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.250000,Style="HugeText")
     WarningMessage2=(DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.320000,Style="HugeText")
     DarkBack=(PosX=0.500000,PosY=0.275000,ScaleX=1.000000,ScaleY=0.240000,Style="Darken")
     InformationDisplayTime=4.000000
     YouAreGuestText="You are a guest of:"
     YouHaveGuestText="You have a guest."
     AddingSplitscreen="Adding split-screen player..."
     FailedAddingSplitscreen="Cannot add split-screen player:"
     FailedAddingReason="Session is full."
     FailedAddingReasonSP="Single player mode."
     CrossFadeLevel=0.000000
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
     bRenderLevel=True
     bPersistent=True
     bIgnoresInput=True
}
