class MenuLivePasscode extends MenuTemplateTitledBA;

// Args: <Gamertag> <LIVE_MAIN | MINIED_PROMPT | MINIED_LIVE | CROSS_TITLE_JOIN>

const MAX_PASSCODE_LENGTH = 4;

var() String        AccountName;
var() String        LoginMode;

var() MenuText      Instructions;
var() MenuSprite    InputBorder[4];
var() MenuText      Input[4];

var() MenuText      Authenticating;

var() String        PassCode;
var() int           PassCodeLength;

var() transient float T;
var() float BlinkTime;
var() bool AccountHasNoPasscode;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    AccountName = ParseToken( Args );
    LoginMode = ParseToken( Args );
    
    Instructions.Text = ReplaceSubString( Instructions.Text, "<GAMERTAG>", AccountName );
    
    ClearPasscode();

    // check if passcode needed
    AccountHasNoPasscode = false;
    if( ConsoleCommand("XLIVE REQUIRE_PASSCODE \""$AccountName$"\"") == "FALSE" )
    {
        AccountHasNoPasscode = true;
        HandleInputStart();
    }
}

simulated function HandleBackInterrupt()
{
    ConsoleCommand("XLIVE LOGOFF"@string(PlayerController(Owner).Player.GamePadIndex));
    ClearPasscode();
    GotoState('');
    
    log("HandleBackInterrupt");

    if( !AccountHasNoPasscode )    
        GotoState('GettingInput');
}

simulated function ClearPasscode()
{
    local int i;
    
    for( i = 0; i < ArrayCount(Input); i++ )
        Input[i].bHidden = 1;

    PassCodeLength = 0;
    PassCode = "";
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    local PlayerController PC;

    if( ButtonName == "A" )
    {
        HandleInputStart();
        return( true );
    }

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound( SoundOnFocus );
        
    if( ButtonName == "B" )
    {
        if( PassCodeLength == 0 )
            HandleInputBack();
        else
        {
            Input[--PassCodeLength].bHidden = 1;
            PassCode = Left( PassCode, (PassCodeLength * 2) );
        }
        return( true );
    }
    
    if( PassCodeLength >= MAX_PASSCODE_LENGTH )
        return( true );

    Input[PassCodeLength++].bHidden = 0;
    PassCode = PassCode $ ButtonName $ " ";

    if( PassCodeLength == MAX_PASSCODE_LENGTH )
    {
        HandleInputStart();
    }

    return( true );
}

simulated function HandleInputStart()
{
    local String s;
    local int controllerIndex;

    if( GetStateName() == 'SigningIn' )
        return;

    controllerIndex = PlayerController(Owner).Player.GamePadIndex;

    log( "Logging in with <"$AccountName$"> ["$PassCode$"]"@controllerIndex, 'Log' );
    s = ConsoleCommand("XLIVE LOGON" @ controllerIndex @ " \""$AccountName$"\"" @ "\"" $ PassCode $ "\"" @ "FALSE");
    
    if( (GetPlatform() != MWP_Xbox) || (s == "SUCCESS") )
        GotoState('SigningIn');
    else if ( s == "FAILED_MUST_UPDATE" )
    {
        ClearPasscode();
        CallMenuClass( "XInterfaceLive.MenuLiveAutoUpdate", MakeQuotedString(""));        
    }
    else
    {
        ClearPasscode();
        OverlayErrorMessageBox( "XONLINE_E_LOGON_FAILED" );
    }
}

auto state GettingInput
{
    simulated function BeginState()
    {
        local int i;
        
        Authenticating.bHidden = 1;
        MenuTitle.Text = default.MenuTitle.Text;
        
        ClearPasscode();
        HideAButton(0);

        for( i = 0; i < 4; ++i )
        {
            InputBorder[i].DrawColor.A = 255;
            Input[i].DrawColor.A = 255;
        }

        Instructions.bHidden = 0;
        Authenticating.bHidden = 1;
    }

    simulated exec function Pork()
    {
        HandleInputGamePad( "R" );
        HandleInputGamePad( "R" );
        HandleInputGamePad( "R" );
        HandleInputGamePad( "R" );
    }
}

simulated function AuthSuccess()
{
    GotoState('SignedIn');

    if( LoginMode == "LIVE_MAIN" )
    {
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    }
    else if( LoginMode == "MINIED_PROMPT" )
    {
        PreviousMenu.MenuClosed(self); // Hurry up!
        CloseMenu();
    }
    else if( LoginMode == "MINIED_LIVE" )
    {
        GotoMenuClass( "MiniEd.MenuMiniEdLive" );
    }
    else if( LoginMode == "CROSS_TITLE_JOIN" )
    {
        GotoMenuClass( "XInterfaceLive.MenuJoiningMatch", "CROSS_TITLE" );
    }
    else
    {
        log("MenuLivePasscode::AuthSuccess(): Unknown LoginMode:" @ LoginMode);
    }
}

state SigningIn
{
    simulated function HandleInputStart();

    simulated function HandleInputBack()
    {
        HandleBackInterrupt();
    }

    simulated function BeginState()
    {
        Instructions.bHidden = 1;
        Authenticating.bHidden = 0;
        
        MenuTitle.Text = Authenticating.Text;
        
        HideAButton(1);

        SetTimer( 0.1, true );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        local String s;

        s = ConsoleCommand("XLIVE GETAUTHSTATE");

        if( s == "SIGNING_ON" || s == "CHANGING_LOGON" )
            return;
        
        log("XLIVE GETAUTHSTATE:"@s);
            
        if ( s == "ONLINE" )
        {
            AuthSuccess();
        }
        else if ( s == "FAILED_MUST_UPDATE" )
        {
            ClearPasscode();
            CallMenuClass( "XInterfaceLive.MenuLiveAutoUpdate", MakeQuotedString(""));                   
            HandleBackInterrupt();
        }
        else if ( s == "FAILURE" || s == "BAD_STATE" || s == "ERROR" )
        {
            ClearPasscode();
            OverlayErrorMessageBox( "XONLINE_E_LOGON_FAILED" );
            GotoState('GettingInput');
        }
    }

    simulated function bool HandleInputGamePad( String ButtonName )
    {
        if( ButtonName == "B" )
        {
            HandleBackInterrupt();
            return( true );
        }
        
        return( false );
    }

    simulated exec function Pork()
    {
        AuthSuccess();
    }

    simulated function Tick( float DT )
    {
        local float f;
        local byte DeltaA;
        local int i;
        
        Super.Tick(DT);
        
        T += DT;
        
        if( T > BlinkTime )
            T -= BlinkTime;

        f = 0.5 * (Cos( 2 * PI * T / BlinkTime ) + 1.0);

        Authenticating.DrawColor.A = 128.f + (127.f * f);
        
        DeltaA = byte( 255.f * (CrossFadeRate * DT) );
        DeltaA = Min( DeltaA, Input[0].DrawColor.A );
        
        for( i = 0; i < 4; ++i )
        {
            InputBorder[i].DrawColor.A -= DeltaA;
            Input[i].DrawColor.A -= DeltaA;
        }
    }    
}

state SignedIn
{
    simulated function HandleInputBack();
    simulated function HandleInputStart();
    
    simulated function BeginState()
    {
        HideAButton(1);
        HideBButton(1);
    }
    
    simulated function bool HandleInputGamePad( String ButtonName )
    {
        return false;
    }
}


simulated function HandleInputBack()
{
    ConsoleCommand("XLIVE LOGOFF"@string(PlayerController(Owner).Player.GamePadIndex));
    GotoMenuClass("XInterfaceLive.MenuLiveSignIn", LoginMode);
}

simulated function bool MenuClosed( Menu closingMenu )
{
    local MenuLiveAutoUpdate confirm;
    local MenuLiveErrorMessage ErrorMenu;
    
    confirm = MenuLiveAutoUpdate(closingMenu);
    if (confirm != None)
    {
        if (!confirm.bSelectedYes)
        {
            ConsoleCommand("XLIVE LOGOFF"@string(PlayerController(Owner).Player.GamePadIndex));
            GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
        }
    }

    ErrorMenu = MenuLiveErrorMessage(ClosingMenu);
    if( ErrorMenu != None )
    {
        if( ErrorMenu.LiveErrorCode == "BAD_PASSCODE" )
        {
            ClearPasscode();
        }
        else
        {
            global.HandleInputBack();
        }
    }

    return true;
}

simulated function bool FindNetMenu(Menu M)
{
    return(false);
}

simulated function bool IsNetMenu()
{
    return(false);
}

simulated function bool FindLiveMenu(Menu M)
{
    return(false);
}

simulated function bool IsLiveMenu()
{
    return(false);
}

defaultproperties
{
     Instructions=(Text="Please enter the pass code for <GAMERTAG>.",DrawPivot=DP_LowerLeft,Style="MessageText")
     InputBorder(0)=(DrawPivot=DP_MiddleMiddle,PosX=0.350000,PosY=0.575000,ScaleX=0.062500,ScaleY=0.075314,Pass=1,Style="DarkBorder")
     InputBorder(3)=(PosX=0.650000)
     Input(0)=(Text="?",DrawPivot=DP_MiddleMiddle,PosX=0.350000,PosY=0.579000,Style="LabelText")
     Input(3)=(PosX=0.650000)
     Authenticating=(Text="Signing in...",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,bHidden=1,Style="LabelText")
     BlinkTime=1.000000
     MenuTitle=(Text="Enter pass code")
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
