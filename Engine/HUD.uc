class Hud extends Actor
    native
    transient
    exportstructs;

var() PlayerController PlayerOwner;
var() Pawn PawnOwner;
var() PlayerReplicationInfo PawnOwnerPRI;

var() Menu ScoreBoard;
var() Menu PersonalStats;

var() class<Menu> PreGameOverlayClass;
var() class<Menu> SpectatingOverlayClass;
var() class<Menu> UtilityOverlayClass; // for guest logon notification, initial profile choices

var() Menu PreGameOverlay;
var() Menu SpectatingOverlay;
var() Menu UtilityOverlay;

// mini hud-menus
var() Menu VoiceMenu;
var() Menu VoteMenu;
var() Menu ObjectivesMenu;
var() Menu VoiceChannelMenu;
var() bool bShowVoiceMenu;
var() bool bShowVoteMenu;
var() bool bShowVoiceChannelMenu;

var color WhiteColor, RedColor, GreenColor, CyanColor, BlueColor, GoldColor, PurpleColor, TurqColor, GrayColor;

var() config bool bHideHUD;
var() bool bInMatinee; //cmr - for rendering matinee effects to hud
var() bool bShowScoreBoard;             // Display current score-board instead of Hud elements
var() bool bShowPersonalStats;          // Display current personal stats
var() bool bShowDebugInfo;              // if true, show properties of current ViewTarget

var() Font ConsoleFont;
var() Color ConsoleColor;

var() globalconfig float HudScale;          // Global Scale for all widgets
var() globalconfig float QuadScreenHudScale;// Global Scale for all widgets in quad screen mode
var() globalconfig float HudCanvasScale;    // Specifies amount of screen-space to use (for TV's).
var() globalconfig bool bMessageBeep;

var() globalconfig bool bShowPersonalInfo;

var() bool	bVehicleCrosshairShow;	// XJ

var() globalconfig bool bCrosshairShow;
var() globalconfig int CrosshairStyle;
var() globalconfig float CrosshairScale;
var() globalconfig float CrosshairOpacity;

var transient float ResScaleX, ResScaleY;
var transient float HudCanvasCenterX, HudCanvasCenterY;

struct TextMessage
{
    var() String Text;
    var() float Life;
    var() Color DrawColor;
};

var() TextMessage TextMessages[16];

var() float ConsoleMessagePosX, ConsoleMessagePosY; // DP_LowerLeft
var() int ConsoleMessageCount;

/* Draw3DLine()
draw line in world space. Should be used when engine calls RenderWorldOverlays() event.
*/
native final function Draw3DLine(vector Start, vector End, color LineColor);

native final function DrawScreenFlash(Canvas C, Vector vFlashScale, Vector vFlashFog);

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode == NM_DedicatedServer)
        return;

    LinkActors ();
}

simulated function SpawnOverlays()
{
    if (PreGameOverlayClass != None)
    {
        PreGameOverlay = Spawn (PreGameOverlayClass, Owner);
        PreGameOverlay.Init(Level.GetLocalURL());
    }

    if (SpectatingOverlayClass != None)
    {
        SpectatingOverlay = Spawn (SpectatingOverlayClass, Owner);
        SpectatingOverlay.Init(Level.GetLocalURL());
    }

    if (UtilityOverlayClass != None)
    {
        UtilityOverlay = Spawn (UtilityOverlayClass, Owner);
        UtilityOverlay.Init(Level.GetLocalURL());
    }
}

simulated event Destroyed()
{
    if( ScoreBoard != None )
    {
        ScoreBoard.Destroy();
        ScoreBoard = None;
    }
    
    if( PersonalStats != None )
    {
        PersonalStats.Destroy();
        PersonalStats = None;
    }

    if( VoiceMenu != None )
    {
        VoiceMenu.Destroy();
        VoiceMenu = None;
    }

    if( VoteMenu != None )
    {
        VoteMenu.Destroy();
        VoteMenu = None;
    }

    if( ObjectivesMenu != None )
    {
        ObjectivesMenu.Destroy();
        ObjectivesMenu = None;
    }

    if ( VoiceChannelMenu != None)
    {
        VoiceChannelMenu.Destroy();
        VoiceChannelMenu = None;
    }
    
    if( PreGameOverlay != None )
    {
        PreGameOverlay.Destroy();
        PreGameOverlay = None;
    }

    if( SpectatingOverlay != None )
    {
        SpectatingOverlay.Destroy();
        SpectatingOverlay = None;
    }

    if( UtilityOverlay != None )
    {
        UtilityOverlay.Destroy();
        UtilityOverlay = None;
    }

    Super.Destroyed();
}


//=============================================================================
// Execs

simulated function HideOverlays()
{
    while( bShowScoreBoard )
        ShowScores();

    while( bShowPersonalStats )
        ShowPersonalStats();

    while( bShowVoiceMenu )
        ShowVoiceMenu();

    while( bShowVoiceChannelMenu )
        ShowVoiceChannelMenu();

    while( bShowVoteMenu )
        ShowVoteMenu();
}

simulated exec function ShowDebug()
{
    bShowDebugInfo = !bShowDebugInfo;
}

simulated exec function ShowScores()
{
    if( ScoreBoard == None )
    {
        bShowScoreBoard = false;
        return;
    }

    while( bShowPersonalStats )
        ShowPersonalStats();

    while( bShowVoiceMenu )
        ShowVoiceMenu();

    while( bShowVoiceChannelMenu )
        ShowVoiceChannelMenu();

    while( bShowVoteMenu )
        ShowVoteMenu();

	bShowScoreBoard = !bShowScoreBoard;
}

simulated exec function HideScores()
{
    bShowScoreBoard = false;
}

simulated exec function ShowPersonalStats()
{
    if( PersonalStats == None )
    {
        bShowPersonalStats = false;
        return;
    }

    while( bShowScoreBoard )
        ShowScores();

    while( bShowVoiceMenu )
        ShowVoiceMenu();

    while( bShowVoiceChannelMenu )
        ShowVoiceChannelMenu();

    while( bShowVoteMenu )
        ShowVoteMenu();

    bShowPersonalStats = !bShowPersonalStats;

    if (bShowPersonalStats)
        PlayerOwner.Player.Console.MenuOpenExisting( PersonalStats );
    else
        PersonalStats.HandleInputBack();
}

simulated function ShowVoiceMenu()
{
    if( (VoiceMenu == None) || (PlayerOwner.Pawn == None) )
    {
        bShowVoiceMenu = false;
        return;
    }

    if( bShowScoreBoard || bShowPersonalStats )
    {
        bShowVoiceMenu = false;
        return;
    }

    while( bShowVoiceChannelMenu )
        ShowVoiceChannelMenu();

    while( bShowVoteMenu )
        ShowVoteMenu();

    bShowVoiceMenu = !bShowVoiceMenu;

    if (bShowVoiceMenu)
        PlayerOwner.Player.Console.KeyMenuOpenExisting( VoiceMenu );
    else
        PlayerOwner.Player.Console.KeyMenuClose();
}

simulated function ShowVoiceChannelMenu()
{
    if( (VoiceChannelMenu == None) || (PlayerOwner.Pawn == None) || (!PlayerOwner.bHasVoice))
    {
        bShowVoiceChannelMenu = false;
        return;
    }

    if( bShowScoreBoard || bShowPersonalStats )
    {
        bShowVoiceChannelMenu = false;
        return;
    }

    while( bShowVoiceMenu )
        ShowVoiceMenu();

    while( bShowVoteMenu )
        ShowVoteMenu();

    bShowVoiceChannelMenu = !bShowVoiceChannelMenu;

    if (bShowVoiceChannelMenu)
        PlayerOwner.Player.Console.KeyMenuOpenExisting( VoiceChannelMenu );
    else
        PlayerOwner.Player.Console.KeyMenuClose();
}

simulated exec function ShowVoteMenu()
{
    if( VoteMenu == None )
    {
        bShowVoteMenu = false;
        return;
    }

    if( bShowScoreBoard || bShowPersonalStats )
    {
        bShowVoteMenu = false;
        return;
    }

    while( bShowVoiceMenu )
        ShowVoiceMenu();

    while( bShowVoiceChannelMenu )
        ShowVoiceChannelMenu();

    bShowVoteMenu = !bShowVoteMenu;

    if (bShowVoteMenu)
        PlayerOwner.Player.Console.KeyMenuOpenExisting( VoteMenu );
    else
        PlayerOwner.Player.Console.KeyMenuClose();
}

simulated event WorldSpaceOverlays()
{
    if ( bShowDebugInfo && Pawn(PlayerOwner.ViewTarget) != None )
        DrawRoute();
}

simulated function RenderLiveIcons( Canvas C );
simulated function CheckCountdown(GameReplicationInfo GRI);

simulated event PostRenderPostFX( Canvas C )
{
    LinkActors();
    
    // draw weapon in postfx stage
    if( C.bRenderLevel )
    {
        if ( !PlayerOwner.bBehindView )
        {
            if ( (PawnOwner != None) && (PawnOwner.Weapon != None) )
                PawnOwner.Weapon.RenderOverlays(C);
			if ( (PawnOwner != None) && (PawnOwner.DefaultWeapon != None) )
			{
				PawnOwner.DefaultWeapon.RenderOverlays(C);
			}
        }
    }
}

simulated event PostRenderPostFXStage( Canvas C, Object Stage )
{
    // allow weapon to draw itself into post process stages.
    if( C.bRenderLevel )
    {
        if ( !PlayerOwner.bBehindView )
        {
            if ( (PawnOwner != None) && (PawnOwner.Weapon != None) )
                PawnOwner.Weapon.RenderOverlaysPostFXStage(C, Stage);
			if ( (PawnOwner != None) && (PawnOwner.DefaultWeapon != None) )
			{
				PawnOwner.DefaultWeapon.RenderOverlaysPostFXStage(C, Stage);
			}
        }
    }
}

simulated function bool ShowingMenu()
{
    return
    (
        (PlayerOwner != None) &&
        (PlayerOwner.Player != None) &&
        (PlayerOwner.Player.Console != None) &&
        (PlayerOwner.Player.Console.CurMenu != None )
    );
}

simulated event PostRender( Canvas C )
{
    local float XPos, YPos;
    local Console PlayerConsole;
    
    CheckCountDown(PlayerOwner.GameReplicationInfo);

    if( C.bRenderLevel )
    {        
		DrawScreenFlash(C, PlayerOwner.FlashScale, PlayerOwner.FlashFog);

        if( bShowDebugInfo )
        {
            C.Font = ConsoleFont;
            C.Style = ERenderStyle.STY_Alpha;
            C.DrawColor = ConsoleColor;

            PlayerOwner.ViewTarget.DisplayDebug (C, XPos, YPos);
        }
        else if( !bHideHud )
        {
            if (bShowPersonalStats)
            {
                // Do nothing: there's a Menu open.
            }
            else if (bShowScoreBoard)
            {
                if( Scoreboard != None )
                    Scoreboard.DrawMenu( C, false );
            }
            else
            {
                if
                (
                    (PlayerOwner == None)
                    || (PawnOwner == None)
                    || (PawnOwnerPRI == None)
                    || PlayerOwner.IsInState ('Spectating')
                    || PlayerOwner.IsInState ('GameEnded')
					|| PlayerOwner.IsInState('MostlyDead')
                )
                {
                    DrawSpectatingHud (C);
                }
                else
                {
                    DrawHud (C);
                }

                if( !IsOnConsole() )
    	            DisplayMessages(C);

                if(UtilityOverlay != None)
                    UtilityOverlay.DrawMenu(C, false);
                
                if( bShowVoiceMenu )
                    VoiceMenu.DrawMenu(C, false);

                if( bShowVoiceChannelMenu )
                    VoiceChannelMenu.DrawMenu(C, false);
                
                if( bShowVoteMenu )
                    VoteMenu.DrawMenu(C, false);
            }
        }
        else
        {
            DrawInstructionGfx(C); // sjs
        }
        
		if(bInMatinee)
			DrawMatineeHud(C);

        if( (ObjectivesMenu != None) && !ShowingMenu() )
        {
            ObjectivesMenu.DrawMenu(C, false);
        }
    }
    
    if (PlayerOwner.Player != None)
        PlayerConsole = PlayerOwner.Player.Console;

    if (PlayerConsole != None)
    {
        PlayerConsole.MenuRender (C);

        if (PlayerConsole.bTyping)
            DrawTypingPrompt(C, PlayerConsole.TypedStr);
    }

    PlayerOwner.RenderOverlays (C);
    
    // AsP --- Hax for rendering LiveIcons over 1st person weapons
    if( C.bRenderLevel )
        RenderLiveIcons (C);
}

simulated function QueueCinematicFade(float time, Color TransitionColor);
simulated function Blinded(float time, Name BlindType);

simulated function DrawInstructionGfx( Canvas C );
simulated function SetInstructionText( string text );
simulated function SetInstructionKeyText( string text );

simulated function DrawRoute()
{
    local int i;
    local Controller C;
    local vector Start, End, RealStart;
    local bool bPath;

    C = Pawn(PlayerOwner.ViewTarget).Controller;
    if ( C == None )
        return;
    if ( C.CurrentPath != None )
        Start = C.CurrentPath.Start.Location;
    else
        Start = PlayerOwner.ViewTarget.Location;
    RealStart = Start;

    if ( C.bAdjusting )
    {
        Draw3DLine(C.Pawn.Location, C.AdjustLoc, class'Canvas'.Static.MakeColor(255,0,255));
        Start = C.AdjustLoc;
    }

    // show where pawn is going
    if ( (C == PlayerOwner)
        || (C.MoveTarget == C.RouteCache[0]) && (C.MoveTarget != None) )
    {
        if ( (C == PlayerOwner) && (C.Destination != vect(0,0,0)) )
        {
            if ( C.PointReachable(C.Destination) )
            {
                Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,255,255));
                return;
            }
            C.FindPathTo(C.Destination);
        }
        for ( i=0; i<16; i++ )
        {
            if ( C.RouteCache[i] == None )
                break;
            bPath = true;
            Draw3DLine(Start,C.RouteCache[i].Location,class'Canvas'.Static.MakeColor(0,255,0));
            Start = C.RouteCache[i].Location;
        }
		if ( C.Pawn.Anchor != None )
			Draw3DLine(C.Pawn.Location, C.Pawn.Anchor.Location,class'Canvas'.Static.MakeColor(0,255,0));
            
        if ( bPath )
            Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));
    }
    else if ( PlayerOwner.ViewTarget.Velocity != vect(0,0,0) )
        Draw3DLine(RealStart,C.Destination,class'Canvas'.Static.MakeColor(255,255,255));

    if ( C == PlayerOwner )
        return;

    // show where pawn is looking
    if ( C.Focus != None )
        End = C.Focus.Location;
    else
        End = C.FocalPoint;
    Draw3DLine(PlayerOwner.ViewTarget.Location + Pawn(PlayerOwner.ViewTarget).BaseEyeHeight * vect(0,0,1),End,class'Canvas'.Static.MakeColor(255,0,0));
}

simulated function DrawHud (Canvas C);
simulated function DrawSpectatingHud (Canvas C);

// cmr - by default, empty the text array (in case LD uses it in non-SP map)
simulated function DrawMatineeHud(Canvas C)
{
	local PlayerController PC;
	PC = PlayerOwner;

	if(PC==None) return;

	PC.MatineeTextArray.Length=0;
	PC.MatineeMaterialArray.Length=0;
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString );
simulated function int LocalizedMessageSlotsAvailable();

simulated function DrawTypingPrompt (Canvas C, String Text)
{
    local float XPos, YPos;
    local float XL, YL;
    local float PrevFontSizeX, PrevFontSizeY; //msp (console text visibility fix): temporary till Brian makes a console font

    c.Reset();
    C.Font = ConsoleFont;

    //msp (console text visibility fix): temporary till Brian makes a console font
    PrevFontSizeX = C.FontScaleX;
    PrevFontSizeY = C.FontScaleY;
    C.FontScaleX = 0.7; 
    C.FontScaleY = 0.7;

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = ConsoleColor;

    C.TextSize ("A", XL, YL);

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) * HudCanvasCenterX) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) * HudCanvasCenterY) * C.SizeY) - YL;

    C.SetPos (XPos, YPos);
    C.DrawTextClipped ("(>"@Text$"_");

    //msp (console text visibility fix): temporary till Brian makes a console font
    C.FontScaleX = PrevFontSizeX;
    C.FontScaleY = PrevFontSizeY;
}

simulated function SetScoreBoardClass (class<Menu> ScoreBoardClass, class<Menu> PersonalStatsClass)
{
    if (ScoreBoard != None )
        ScoreBoard.Destroy();

    if (ScoreBoardClass == None)
        ScoreBoard = None;
    else
    {
        ScoreBoard = Spawn (ScoreBoardClass, Owner);

        if (ScoreBoard == None)
            log ("Hud::SetScoreBoard(): Could not spawn a scoreboard of class "$ScoreBoardClass, 'Error');
    }

    if (PersonalStats != None )
        PersonalStats.Destroy();

    if (PersonalStatsClass == None)
        PersonalStats = None;
    else
    {
        PersonalStats = Spawn (PersonalStatsClass, Owner);
        PersonalStats.Init( "" );
    
        if (PersonalStats == None)
            log ("Hud::SetScoreBoard(): Could not spawn a PersonalStats of class "$PersonalStatsClass, 'Error');
    }
}

exec function ShowHud()
{
    bHideHud = !bHideHud;
}

simulated function LinkActors()
{
    PlayerOwner = PlayerController (Owner);

    if (PlayerOwner == None)
    {
        PawnOwner = None;
        PawnOwnerPRI = None;
        return;
    }

    if ((PlayerOwner.ViewTarget != None) && 
        (Pawn(PlayerOwner.ViewTarget) != None) &&
		(Pawn(PlayerOwner.ViewTarget).Controller != None && Pawn(PlayerOwner.ViewTarget).Controller == PlayerOwner) )
        PawnOwner = Pawn(PlayerOwner.ViewTarget);
	else if (PlayerOwner.Pawn != None )
        PawnOwner = PlayerOwner.Pawn;
	else
        PawnOwner = None;

    if ((PawnOwner != None) && (PawnOwner.Controller != None))
        PawnOwnerPRI = PawnOwner.PlayerReplicationInfo;
    else
        PawnOwnerPRI = PlayerOwner.PlayerReplicationInfo;
}

// Overridden higher for more sex:
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
    AddTextMessage(Msg,class'LocalMessage', PRI);
}

function DisplayMessages(Canvas C)
{
    local int i, j, XPos, YPos;
    local float XL, YL;
    local Console PlayerConsole;
    local float PrevFontSizeX, PrevFontSizeY; //msp (console text visibility fix): temporary till Brian makes a console font

    for( i = 0; i < ArrayCount(TextMessages); i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;
            
        else if( TextMessages[i].Life < Level.TimeSeconds )
        {
            TextMessages[i].Text = "";

            if( i < ArrayCount(TextMessages) - 1 )
            {
                for(j = i; j < ArrayCount(TextMessages) - 1; j++ )
                {
                    TextMessages[j] = TextMessages[j+1];
                }
            }

            TextMessages[j].Text = "";
            break;
        }
    }   

    XPos = (ConsoleMessagePosX * HudCanvasScale * C.SizeX) + (((1.0 - HudCanvasScale) * HudCanvasCenterX) * C.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * C.SizeY) + (((1.0 - HudCanvasScale) * HudCanvasCenterY) * C.SizeY);

    C.Font = ConsoleFont;
    
    //msp (console text visibility fix): temporary till Brian makes a console font
    PrevFontSizeX = C.FontScaleX;
    PrevFontSizeY = C.FontScaleY;
    C.FontScaleX = 0.7; 
    C.FontScaleY = 0.7;

    C.TextSize ("A", XL, YL);

    YPos -= YL; // DP_LowerLeft

    if (PlayerOwner.Player != None)
        PlayerConsole = PlayerOwner.Player.Console;

    if( (PlayerConsole != None) && PlayerConsole.bTyping )
    {
        YPos -= YL; // Room for typing prompt
    }

    for( i = 0; i < ArrayCount(TextMessages); i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;

        C.StrLen( TextMessages[i].Text, XL, YL );
        C.SetPos( XPos, YPos );
        C.DrawColor = TextMessages[i].DrawColor;
        C.DrawText( TextMessages[i].Text );
        YPos -= YL;
    }    

    //msp (console text visibility fix): temporary till Brian makes a console font
    C.FontScaleX = PrevFontSizeX;
    C.FontScaleY = PrevFontSizeY;
}

function AddTextMessage(string M, class<LocalMessage> MessageClass, optional PlayerReplicationInfo PRI)
{
    local int i, Count;

    Count = Min( ConsoleMessageCount, ArrayCount( TextMessages ) );

    for( i = 0; i < Count; i++ )
    {
        if ( TextMessages[i].Text == "" )
            break;
    }

    if( i == Count )
    {        
        for( i = 0; i < Count - 1; i++ )
        {
            TextMessages[i] = TextMessages[i+1];
        }
    }
    
    log("AddTextMessage MessageClass" @ MessageClass); 
    
    TextMessages[i].Text = M;
    TextMessages[i].Life = Level.TimeSeconds + MessageClass.Default.LifeTime;
    TextMessages[i].DrawColor = MessageClass.static.GetConsoleColor(PRI);
}

exec function unlock()
{
    if( PlayerOwner.GetEntryLevel().game.bLocked )
    {
        PlayerOwner.GetEntryLevel().game.bLocked = false;
        AddTextMessage( "Game unlocked", class'LocalMessage' );
        log( "Game unlocked." );
    }
    else
    {
        PlayerOwner.GetEntryLevel().game.bLocked = true;
        AddTextMessage( "Game locked", class'LocalMessage' );
        log( "Game locked." );
    }
}

simulated function SetTargeting( bool bShow, optional Vector TargetLocation, optional float Size );
simulated function SetHintTarget( bool bShow, optional Vector TargetLocation, optional float Size );
simulated function DrawCrosshair(Canvas C);
simulated function SetCropping( bool Active );

// XJ --
simulated function DrawVehicleCrosshair(Canvas C);
simulated function SetVehicleCrosshairLocation(Vector TargetLocation);
// -- XJ

simulated function KillMessages();

defaultproperties
{
     ConsoleMessageCount=4
     HudScale=1.000000
     QuadScreenHudScale=1.380000
     HudCanvasScale=1.000000
     CrosshairScale=1.000000
     CrosshairOpacity=1.000000
     ConsoleMessagePosY=1.000000
     ConsoleFont=Font'Engine.FontSmall'
     WhiteColor=(B=255,G=255,R=255,A=255)
     RedColor=(B=23,G=23,R=166,A=255)
     GreenColor=(G=255,A=255)
     CyanColor=(B=255,G=255,A=255)
     BlueColor=(B=255,A=255)
     GoldColor=(G=255,R=255,A=255)
     PurpleColor=(B=255,R=255,A=255)
     TurqColor=(B=255,G=128,A=255)
     GrayColor=(B=200,G=200,R=200,A=255)
     ConsoleColor=(B=253,G=216,R=153,A=255)
     bMessageBeep=True
     bShowPersonalInfo=True
     bCrosshairShow=True
     RemoteRole=ROLE_None
     bHidden=True
}
