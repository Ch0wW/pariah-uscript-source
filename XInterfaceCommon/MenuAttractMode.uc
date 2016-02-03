// MenuAttractMode:
//
// Menus that need to go to Attract Mode make a MenuLayer with this class 
// and forward HandleInputKeyRaw and HandleInputAxis to it; this menu will
// do the rest!

class MenuAttractMode extends MenuTemplateTitled;

var() MenuSprite Blackness;
var() MenuSprite PariahLogo;

var() MenuText PressStart;

var() globalconfig float VideoFadeTime;

var() globalconfig float DelayUntilAttractMode;
var() globalconfig float TimeInAttractMode;

var() String AttractVideoFile;

var() float VideoFade;

var() MenuStart StartMenu;
var() MenuMain MainMenu;

var() bool GotInput;

simulated function Init( String Args )
{
    Super.Init( Args );

    if( IsOnConsole() )
    {
        PressStart.Text = class'XboxStandardMsgs'.default.ErrorMsg[5];
    }
    else
    {
        PressStart.Text = class'MenuStart'.default.ClickToBegin;
    }
}

simulated function bool HandleInputKeyRaw( Interactions.EInputKey Key, Interactions.EInputAction Action )
{
    return(HandleInput());
}

simulated function bool HandleInputAxis( Interactions.EInputKey Key, float Delta )
{
    // Note the conspicuous absence of joystick checking.
    if( (Key == IK_MouseX) || (Key == IK_MouseY) )
    {
        return(HandleInput());
    }
    else
    {
        return(false);
    }
}

simulated function InputLeft()
{
    HandleInput();
}

simulated function InputRight()
{
    HandleInput();
}

simulated function InputUp()
{
    HandleInput();
}

simulated function InputDown()
{
    HandleInput();
}

simulated function bool HandleInput()
{
    GotInput = true;
    return(true);
}

auto state Hidden
{
    simulated function BeginState()
    {
        SetTimer( DelayUntilAttractMode, true );
        PlayerController(Owner).ConsoleCommand( "ATTRACT_MODE STATE=0" );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function bool HandleInput()
    {
        SetTimer( DelayUntilAttractMode, true );
        return( false );
    }

    simulated function Timer()
    {
        local PlayerController PC;
        local Menu Outer;
        
        if( StartMenu != None )
        {
            Outer = StartMenu;
        }
        else if( MainMenu != None )
        {
            Outer = MainMenu;
        }
        else
        {
            return;
        }
        
        PC = PlayerController(Owner);
        
        // Disable fading in if the outer menu is not the current (ie: an error has been overlayed).
        if( (PC == None) || (PC.Player == None) || (PC.Player.Console == None) || (PC.Player.Console.CurMenu != Outer) )
        {
            return;
        }
        
        GotoState( 'FadingIn' );
    }
}

state FadingIn
{
    simulated function BeginState()
    {
	    CrossFadeDir = TD_In;
        SetTimer( 1.f / CrossFadeRate, false );
        
        StopAllMusic( 1.f / CrossFadeRate );
        
        PlayerController(Owner).ConsoleCommand( "ATTRACT_MODE STATE=1" );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function bool HandleInput()
    {
        GotoState( 'FadingOut' );
        return( true );
    }
    
    simulated function Timer()
    {
        GotoState( 'StartingVideo' );
    }
}

state StartingVideo
{
    simulated function BeginState()
    {
        local VideoTexture VT;

        VT = VideoTexture(Background.WidgetTexture);
        VT.PlaySoundTrack = true;
        VT.OverrideVideoFile = AttractVideoFile;
    }
    
    simulated function Tick( float Delta )
    {
        local bool Done;
        local VideoTexture VT;

        VT = VideoTexture(Background.WidgetTexture);
        
        Super.Tick( Delta );
        
        VideoFade += 255.f * (Delta / VideoFadeTime);
        
        if( VideoFade >= 255.f )
        {
            VideoFade = 255.f;
            Done = true;
        }
    
        Background.DrawColor.A = VideoFade;
        
        VT.SoundVolume = VideoFade / 255.f;
        
        if( Done )
        {
            GotoState( 'PlayingVideo' );
        }
    }

    simulated function bool HandleInput()
    {
        GotoState( 'StoppingVideo' );
        return( true );
    }
}

state PlayingVideo
{
    simulated function BeginState()
    {
        SetTimer( TimeInAttractMode, false );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function bool HandleInput()
    {
        GotoState( 'StoppingVideo' );
        return( true );
    }

    simulated function Timer()
    {
        GotoState( 'StoppingVideo' );
    }
}

state StoppingVideo
{
    simulated function Tick( float Delta )
    {
        local bool Done;
        local VideoTexture VT;

        VT = VideoTexture(Background.WidgetTexture);

        Super.Tick( Delta );
        
        VideoFade -= 255.f * (Delta / VideoFadeTime);
        
        if( VideoFade <= 0.f )
        {
            VideoFade = 0.f;
            Done = true;
        }
    
        Background.DrawColor.A = VideoFade;
        
        VT.SoundVolume = VideoFade / 255.f;
        
        if( Done )
        {
            GotoState( 'FadingOut' );
        }
    }
}

state FadingOut
{
    simulated function BeginState()
    {
        local VideoTexture VT;

        VT = VideoTexture(Background.WidgetTexture);
        VT.OverrideVideoFile = "";
        VT.PlaySoundTrack = false;

	    CrossFadeDir = TD_Out;
        SetTimer( 1.f / CrossFadeRate, false );
        
        // To kick MenuStart towards MenuMain (TCR says we can't go back to MenuStart)
        
        if( GotInput && (StartMenu != None) )
        {
            StartMenu.OnAttractModeEnd();
        }
    }
    simulated function EndState()
    {
        StopAllMusic( 0.0 );    // mjm - cheap quick patch hack to stop the double play of music
        PlayMusic( Level.Song, 1.f / CrossFadeRate );
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        GotoState( 'Hidden' );
    }
}

defaultproperties
{
     Blackness=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(A=255),PosY=0.155000,ScaleX=1.000000,ScaleY=0.690000,ScaleMode=MSM_Fit)
     PariahLogo=(WidgetTexture=Texture'PariahInterface.Logos.PariahTextLogo',DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.800000,ScaleX=0.750000,ScaleY=0.750000,Pass=2)
     PressStart=(PosY=0.900000,Style="MessageText")
     VideoFadeTime=1.000000
     DelayUntilAttractMode=15.000000
     TimeInAttractMode=86.000000
     AttractVideoFile="AttractMode1Loop.bik"
     Background=(DrawColor=(A=0),PosY=0.000000,ScaleY=1.000000,Pass=1)
     ControllerIcon=(bHidden=1)
     XBLFriendsRequest=(bHidden=1)
     XBLGameInvitation=(bHidden=1)
     GamertagText=(bHidden=1)
     GamerOnlineStatusText=(bHidden=1)
     ControllerNumText=(bHidden=1)
     CrossFadeRate=1.000000
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
}
