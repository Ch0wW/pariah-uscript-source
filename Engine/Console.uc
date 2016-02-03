//=============================================================================
// Console: handles command input and manages menus.
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
class Console extends Interaction
    config;
    
var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[16];           // Holds the current command, and the history
var bool bTyping;                           // Turn when someone is typing on the console                           
var bool bIgnoreKeys;                       // Ignore Key presses until a new KeyDown is received                           

// Menu supporting stuff

var Name PrevState;

enum HoldingState
{
    StandingStill,
    HoldingLeft,
    HoldingRight,
    HoldingUp,
    HoldingDown,
    HoldingSelect,
    HoldingStart,
    HoldingBack,
};

var() float ControllerRepeatDelayInitial;
var() float ControllerRepeatDelaySubsequent;
var() transient float ControllerRepeatDelayCurrent;
var() transient HoldingState ControllerState;

var() transient float DeltaPrevJoyX, DeltaPrevJoyY, DeltaPrevJoyU, DeltaPrevJoyV;

// CurMenu is the menu stack the currently has focus,
// PrevMenu is the non-current menu stack that most
// recently had focus. If not none, and not flagged
// as bDeleteMe, PrevMenu will be drawn prior to CurMenu.

var() editinline Menu CurMenu;
var() editinline Menu PrevMenu;

var Menu KeyMenu; // only grabs key/buttons

var() bool UsingMenuRes;
var() String NormalRes;

var array<string> BufferedConsoleCommands;  // If this is blank, perform the command at Tick

exec function Type()
{
    TypedStr="";
    TypingOpen();
}
 
exec function Talk()
{
    TypedStr="Say ";
    TypingOpen();
}

exec function TeamTalk()
{
    TypedStr="TeamSay ";
    TypingOpen();
}

exec function ConsoleOpen();
exec function ConsoleClose();
exec function ConsoleToggle();

simulated function Menu CloseVignettes( Menu M, bool bNoNotCloseVignettesMaybe )
{
    local Menu RM;

    if( M == None )
        return None;

    M.PreviousMenu = CloseVignettes( M.PreviousMenu, bNoNotCloseVignettesMaybe );
    
    if( M.bVignette == bNoNotCloseVignettesMaybe )
        return M;

    if( M.PreviousMenu != None )
        RM = M.PreviousMenu;
    else
        RM = None;

    M.DestroyMenu();
    return RM;
}

// gam ---
simulated event PreLevelChange()
{
    if( CurMenu != None )
    {
        CurMenu = CloseVignettes( CurMenu, true );

        if( CurMenu == None )
            MenuClose();
    }
    
    ConsoleClose();
}

simulated event PostLevelChange()
{
    if( CurMenu != None )
    {
        CurMenu = CloseVignettes( CurMenu, false );

        if( CurMenu == None )
            MenuClose();
    }
}
// --- gam

function DelayedConsoleCommand(string command)
{
    BufferedConsoleCommands.Length = BufferedConsoleCommands.Length+1;
    BufferedConsoleCommands[BufferedConsoleCommands.Length-1] = Command;
}
    

//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

event Message( coerce string Msg, float MsgLife);

function bool IgnoreKeyEvent( EInputKey Key, EInputAction Action )
{
    return( false );
}

function bool KeyIsBoundTo( EInputKey Key, String Binding )
{
    local String KeyName, KeyBinding;
    
    KeyName = ViewportOwner.Actor.ConsoleCommand( "KEYNAME "$Key );
    
    if( KeyName == "" )
        return( false );
    
    KeyBinding = ViewportOwner.Actor.ConsoleCommand( "KEYBINDING "$KeyName );

    if( KeyBinding ~= Binding )
        return( true );

    return( false );
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

function TypingOpen()
{
    PrevState = GetStateName();

    bTyping = true;

    if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
        ViewportOwner.Actor.Typing( bTyping );

    //TypedStr = "";

    GotoState('Typing');
}

function TypingClose()
{
    bTyping = false;

    if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
        ViewportOwner.Actor.Typing( bTyping );

    TypedStr="";

    if( GetStateName() == 'Typing' )
        GotoState( PrevState ); 
}

simulated function DoConsoleCommand( String Cmd )
{
    local String Error;
    
    if( ConsoleCommand( Cmd ) )
    {
        return;
    }

    Error = Localize("Errors","Exec","Core") $ ":" @ Cmd;
    
    Message( Error, 6.0 );

    if( (ViewportOwner != None) || (ViewportOwner.Actor != None) || (ViewportOwner.Actor.MyHud != None) )
    {
        ViewportOwner.Actor.MyHud.AddTextMessage( Error, class'LocalMessage' );
    }
}

state Typing
{
    exec function Type()
    {
        TypedStr="";
        TypingClose();
    }
    function bool KeyType( EInputKey Key, optional string Unicode )
    {
        if (bIgnoreKeys)        
            return true;

        if( Key>=0x20 )
        {
            if( Unicode != "" )
                TypedStr = TypedStr $ Unicode;
            else
                TypedStr = TypedStr $ Chr(Key);
            return( true );
        }
    }
    
    function bool IgnoreKeyEvent( EInputKey Key, EInputAction Action )
    {
        if( KeyIsBoundTo( Key, "Type" ) )
            return( true );

        return( global.IgnoreKeyEvent( Key, Action ) );
    }

    function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
    {
        local string Temp;
    
        if( IgnoreKeyEvent( Key, Action ) )
            return( false );
    
        if (Action== IST_PRess)
        {
            bIgnoreKeys=false;
        }
    
        if( Key==IK_Escape )
        {
            if( TypedStr!="" )
            {
                TypedStr="";
                HistoryCur = HistoryTop;
                return( true );
            }
            else
            {
                TypingClose();
                return( true );
            }
        }
        else if( Action != IST_Press )
        {
            return( false );
        }
        else if( Key==IK_Enter )
        {
            if( TypedStr!="" )
            {
                History[HistoryTop] = TypedStr;
                HistoryTop = (HistoryTop+1) % ArrayCount(History);
                
                if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
                    HistoryBot = (HistoryBot+1) % ArrayCount(History);

                HistoryCur = HistoryTop;

                // Make a local copy of the string.
                Temp=TypedStr;
                TypedStr="";
                
                DoConsoleCommand( Temp );
            }

            TypingClose();
                
            return( true );
        }
        else if( Key==IK_Up )
        {
            if ( HistoryBot >= 0 )
            {
                if (HistoryCur == HistoryBot)
                    HistoryCur = HistoryTop;
                else
                {
                    HistoryCur--;
                    if (HistoryCur<0)
                        HistoryCur = ArrayCount(History)-1;
                }
                
                TypedStr = History[HistoryCur];
            }
            return( true );
        }
        else if( Key==IK_Down )
        {
            if ( HistoryBot >= 0 )
            {
                if (HistoryCur == HistoryTop)
                    HistoryCur = HistoryBot;
                else
                    HistoryCur = (HistoryCur+1) % ArrayCount(History);
                    
                TypedStr = History[HistoryCur];
            }           

        }
        else if( Key==IK_Backspace || Key==IK_Left )
        {
            if( Len(TypedStr)>0 )
                TypedStr = Left(TypedStr,Len(TypedStr)-1);
            return( true );
        }
        return( true );
    }
    
    function BeginState()
    {
        bTyping = true;
        bVisible= true;
        bIgnoreKeys = true;
        HistoryCur = HistoryTop;
    }
    function EndState()
    {
        bTyping = false;
        bVisible = false;
    }
}
    
simulated event Tick( float Delta )
{
    while( BufferedConsoleCommands.Length > 0 )
    {
        ViewportOwner.Actor.ConsoleCommand(BufferedConsoleCommands[0]);
        BufferedConsoleCommands.Remove(0,1);
    }       

    if( ViewportOwner == None)
        return;

    if( (CurMenu != None) && (CurMenu.TravelMenu == CurMenu ) )
    {
        if( (CurMenu.MouseX != ViewportOwner.WindowsMouseX) || (CurMenu.MouseY != ViewportOwner.WindowsMouseY) )
        {
            CurMenu.MouseX = ViewportOwner.WindowsMouseX;
            CurMenu.MouseY = ViewportOwner.WindowsMouseY;
            
            CurMenu.LastInputSource = IS_Mouse;
            CurMenu.HandleInputMouseMove();
            CurMenu.LastInputSource = IS_None;
        }
    }
}
    
//-----------------------------------------------------------------------------
// State used while in a menu.

simulated function MenuRenderStack( Canvas C, Menu M, int Depth, bool HasFocus )
{
    local Plane POverlayColor;
    local Color COverlayColor;
    
    POverlayColor = M.GetModulationColor();

    C.ColorModulate.X = 1.f;
    C.ColorModulate.Y = 1.f;
    C.ColorModulate.Z = 1.f;
    C.ColorModulate.W = POverlayColor.W;
    
    // Mod2X!
    COverlayColor.R = 128 * POverlayColor.X;
    COverlayColor.G = 128 * POverlayColor.Y;
    COverlayColor.B = 128 * POverlayColor.Z;
    COverlayColor.A = 255;
    
    M.DrawMenu( C, HasFocus );
    
    // If we could properly modulate materials I wouldn't have to do this.
    C.Style = 4; // WHY THE FUCK DOESN'T ERenderStyle.STY_Modulated WORK???;
    C.DrawColor = COverlayColor;
    C.SetPos( 0, 0 );
    C.DrawRect( Material'Engine.PariahWhiteTexture', C.ClipX, C.ClipY );
}

simulated function MenuRender( Canvas C )
{
    local Menu NextMenu;
    local Plane CurModColor;
    local Plane PrevModColor;

    // Handle travelling first!
    if( (CurMenu != None) && (CurMenu.TravelMenu != CurMenu) )
    {    
        if( CurMenu.TravelMenu != None ) // Going/calling/overlaying another menu
        {
            NextMenu = CurMenu.TravelMenu;

            // Set the travel menu back so it'll be good when this menu is displayed next.
            if( NextMenu.PreviousMenu == CurMenu )
                CurMenu.TravelMenu = CurMenu;
            else
                CurMenu.TravelMenu = None;

            ControllerState = StandingStill;
            ControllerRepeatDelayCurrent = 0;
        }
        else // Closing current menu
        {
            if( CurMenu.PreviousMenu != None )
                NextMenu = CurMenu.PreviousMenu;
            else
                NextMenu = None;

            ControllerState = StandingStill;
            ControllerRepeatDelayCurrent = 0;
        }

        if( (PrevMenu != None) && (PrevMenu.TravelMenu == None) )
            PrevMenu.DestroyMenu();

        if( NextMenu != None )
            CheckResolution( !NextMenu.bRenderLevel );

        PrevMenu = CurMenu;
        CurMenu = NextMenu;
    }
    
    if( (CurMenu == None) && (PrevMenu == None) )       // No menus visible or active
        return;

    if( CurMenu == None )                               // Last menu fading away
    {
        MenuRenderStack( C, PrevMenu, 0, true );

        if( !PrevMenu.IsVisible() )                     // Prev fully faded away
        {
            if (!PrevMenu.MenuClosed( PrevMenu )) // Need notification if final menu
                LogMenuClosedError( PrevMenu, PrevMenu );
            PrevMenu.DestroyMenu();
            PrevMenu = None;
            MenuClose();
        }
        return;
    }
    else if( PrevMenu == None )                         // No prev
    {
        MenuRenderStack( C, CurMenu, 0, true );
    }
    else if( !PrevMenu.IsVisible() )                    // Prev fully faded away
    {
        MenuRenderStack( C, CurMenu, 0, true );

        if( PrevMenu.TravelMenu == None )
        {
            if (!CurMenu.MenuClosed( PrevMenu ))
                LogMenuClosedError( CurMenu, PrevMenu );
            PrevMenu.DestroyMenu();
            PrevMenu = None;
        }
    }
    else                                                // Inter-stack transition
    {
        CurModColor = CurMenu.GetModulationColor();
        PrevModColor = PrevMenu.GetModulationColor();

        if( (CurModColor.W >= 0.99) && !CurMenu.bRenderLevel )
        {
            // Cur menu is fully in and needs to obscure the prev menu, no matter what!
            MenuRenderStack( C, CurMenu, 0, true );
        }
        else if( PrevModColor.W > CurModColor.W )
        {
            MenuRenderStack( C, CurMenu, 0, true );
            MenuRenderStack( C, PrevMenu, 0, false );
        }
        else
        {
            MenuRenderStack( C, PrevMenu, 0, false );
            MenuRenderStack( C, CurMenu, 0, true );
        }
    }

    C.Reset();
}

simulated function LogMenuClosedError( Menu curMenu, Menu closingMenu )
{
    //log( curMenu.class $ "::MenuClosed couldn't handle a " $ closingMenu.class, 'Error');
}

simulated function CheckResolution( bool NeedMenuResolution )
{
    local PlayerController PC;
    local int CurrentX, CurrentY, MenuX, MenuY, i;
    local String MenuRes;

    if( IsOnConsole() )
        return;

    PC = ViewportOwner.Actor;

    if( NeedMenuResolution && UsingMenuRes )
        return;

    if( !NeedMenuResolution && !UsingMenuRes )
        return;
        
    if( !NeedMenuResolution )
    {
        log( "Leaving menu, changing resolution from" @ PC.ConsoleCommand( "GETCURRENTRES" ) @ "to" @ NormalRes );
        DelayedConsoleCommand( "SETRES" @ NormalRes );
        //PC.ConsoleCommand( "SETRES" @ NormalRes );
    }
    else
    {
        NormalRes = PC.ConsoleCommand( "GETCURRENTRES" );
        
        i = InStr( NormalRes, "x" );
        
        if( i > 0 )
        {
            CurrentX = int( Left( NormalRes, i )  );
            CurrentY = int( Right( NormalRes, Len(NormalRes) - i - 1 )  );
        }
                
        if( ( CurrentX == 0 ) || ( CurrentY == 0 ) )
        {
            log( "Couldn't parse GETCURRENTRES result:" @ NormalRes, 'Error' ); 
            return;
        }
        
        MenuX = int( PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager MenuViewportX") );
        MenuY = int( PC.ConsoleCommand("get ini:Engine.Engine.ViewportManager MenuViewportY") );
    
        if( ( MenuX == 0 ) || ( MenuY == 0 ) )
            return;

        if( ( MenuX <= CurrentX ) && ( MenuY <= CurrentY ) )
            return;

        MenuRes = String(MenuX) $ "x" $ String(MenuY);

        log( "Entering menu, changing resolution from" @ NormalRes @ "to" @ MenuRes );

        DelayedConsoleCommand( "SETRES" @ MenuRes  );
        //PC.ConsoleCommand( "SETRES" @ MenuRes  );

        // Stuff back the INI settings just in case they quit while in a menu.
        if( bool( PC.ConsoleCommand("ISFULLSCREEN")) )
        {
            PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenViewportX" @ CurrentX );
            PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager FullscreenViewportY" @ CurrentY );
        }
        else
        {
            PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager WindowedViewportX" @ CurrentX );
            PC.ConsoleCommand("set ini:Engine.Engine.ViewportManager WindowedViewportY" @ CurrentY );
        }
    }
    
    UsingMenuRes = NeedMenuResolution;
}

// NOTE: This is clears out any open menus on the stack!

simulated event MenuOpen (class<Menu> MenuClass, String Args)
{
    local PlayerController PC;
    
    log( "MenuOpen:" @ MenuClass @ "(" $ Args $ ")" );

    DestroyMenuTree( CurMenu );
    DestroyMenuTree( PrevMenu );

    if (ViewportOwner == None)
    {
        log ("MenuOpen: can't spawn without an owner", 'Error');
        return;
    }

    PC = ViewportOwner.Actor;
    
    if (PC == None)
    {
        log ("MenuOpen: can't spawn without a PlayerController", 'Error');
        return;
    }
    
    CurMenu = PC.Spawn (MenuClass, PC);

    if (CurMenu == None)
    {
        log ("MenuOpen: Failed to open menu of class "$MenuClass, 'Error');
        return;
    }

    CheckResolution( !CurMenu.bRenderLevel );

    CurMenu.Init( Args );
    MenuOpenExisting(CurMenu);
}

// NOTE: This is clears out any open menus on the stack!

simulated event MenuOpenExisting(Menu m)
{
    if (m == None)
    {
        log ("1 MenuOpenExisting: Failed to open menu "$m, 'Error');
        return;
    }

    if (CurMenu != None && CurMenu != m)
        MenuClose();

    CurMenu = m;
    m.bActive = True;
    m.ReopenInit();

    ControllerState = StandingStill;
    ControllerRepeatDelayCurrent = 0;

    GotoState ('Menuing');
}

simulated function MenuCallExisting(Menu m, String Args)
{
    log("MenuCallExisting"@m@CurMenu);

    if(m == None)
    {
        log ("1 MenuOpenExisting: Failed to open menu "$m, 'Error');
        return;
    }

    if( (CurMenu != None) && (CurMenu != m) )
    {
        if( CurMenu.bFullScreenOnly && !m.bFullScreenOnly )
        {
            M.Init(Args);
            
            M.PreviousMenu = CurMenu.PreviousMenu;
            CurMenu.PreviousMenu = M;
        }
        else
        {
            M.Init(Args);
            
            M.PreviousMenu = CurMenu;
            CurMenu = M;
        }
    }
    else
    {
        CurMenu = m;
        m.ReopenInit();
    }

    ControllerState = StandingStill;
    ControllerRepeatDelayCurrent = 0;

    GotoState ('Menuing');
}

simulated function DestroyMenuTree( out Menu M )
{
    if( M == None )
        return;

    DestroyMenuTree( M.PreviousMenu );

    M.DestroyMenu();
    M = None;
}

simulated event MenuClose()
{
    DestroyMenuTree( CurMenu );
    DestroyMenuTree( PrevMenu );

    if( IsInState('Typing') )
        TypingClose();

    CheckResolution( false );

    GotoState ('');
}

simulated function KeyMenuOpenExisting(Menu m)
{
    if (m == None)
    {
        log ("1 MenuOpenExisting: Failed to open menu "$m, 'Error');
        return;
    }

    KeyMenuClose();

    KeyMenu = m;
    m.ReopenInit();

    GotoState ('KeyMenuing');
}

simulated function KeyMenuClose()
{
    KeyMenu = None;
    if( IsInState('Typing') )
        TypingClose();
    GotoState ('');
}

state KeyMenuing
{
    event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
    {
        local bool rc;

        if( IgnoreKeyEvent( Key, Action ) )
            return( false );

        if( KeyMenu.IgnoreKeyEvent( Key, Action ) )
            return( false );

        if( Action == IST_Press )
        {
            rc = KeyMenu.HandleInputKeyRaw( Key, Action ); // may cause KeyMenu to be None
            if( KeyMenu != None )
                KeyMenu.LastInputSource = IS_None;
            //ControllerRepeatDelayCurrent = 0;
            if( rc )
                return( true );
        }
        return Super.KeyEvent( Key, Action, Delta );
    }
}

state Menuing
{
    function bool KeyType( EInputKey Key, optional string Unicode )
    {
        local bool rc;

        if( (CurMenu == None) || (CurMenu.TravelMenu != CurMenu) )
            return( false );

        CurMenu.LastInputSource = IS_Keyboard;
        rc = CurMenu.HandleInputKey( Key );
        CurMenu.LastInputSource = IS_None;
        ControllerState = StandingStill;
        ControllerRepeatDelayCurrent = 0;
        
        if( rc )
            return( true );
    }

    function bool IgnoreKeyEvent( EInputKey Key, EInputAction Action )
    {
        if( KeyIsBoundTo( Key, "ConsoleToggle" ) )
            return( true );

        if( KeyIsBoundTo( Key, "Type" ) )
            return( true );

        return( global.IgnoreKeyEvent( Key, Action ) );
    }

    event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
    {
        local bool rc;
        
        if( Action == IST_Press && ViewportOwner.Actor.Level.StopCinematic() )
        {
            return(true);
        }
        
        if( CurMenu != None && CurMenu.bIgnoresInput )
            return false;

        if( (CurMenu == None) || (CurMenu.TravelMenu != CurMenu) )
            return( true );

        if( (Action == IST_Press) && !CurMenu.bRawKeyboardInput )
        {
            if( IgnoreKeyEvent( Key, Action ) )
                return( false );

            if( CurMenu.IgnoreKeyEvent( Key, Action ) )
                return( false );
        }

        if( ( Action == IST_Press ) || ( Action == IST_Release ) )
        {
            if( (Key >= IK_Joy1) && (Key <= IK_Joy16) )
            {
                CurMenu.LastInputSource = IS_Controller;
            }
            else
            {
                CurMenu.LastInputSource = IS_Keyboard;
            }
            
            rc = CurMenu.HandleInputKeyRaw( Key, Action );

            if( CurMenu != None )
            {              
                CurMenu.LastInputSource = IS_None;
            }
            
            ControllerState = StandingStill;
            ControllerRepeatDelayCurrent = 0;
            
            if( rc )
                return( true );
        }

        if( Action == IST_Axis )
        {
            if( CurMenu.HandleInputAxis( Key, Delta ) )
            {
                return( true );
            }
        
            if( ( Key == IK_MouseX ) || ( Key == IK_MouseY ) )
            {
                return( false );
            }
            else if( (Key == IK_JoyX) || (Key == IK_JoyY) || (Key == IK_JoyU) || (Key == IK_JoyV) )
            {
                if( Delta < -0.4  )
                    Delta = -1;
                else if( Delta > 0.4 )
                    Delta = 1;
                else
                    Delta = 0;
                    
                if( Key == IK_JoyX )
                {
                    if( Delta != DeltaPrevJoyX )
                    {                
                        if( Delta < 0 )
                        {
                            if( ControllerState != HoldingLeft )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputLeft();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingLeft;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else if( Delta > 0 )
                        {
                            if( ControllerState != HoldingRight )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputRight();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingRight;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else
                        {
                            if( ( ControllerState == HoldingLeft ) || ( ControllerState == HoldingRight ) )
                            {
                                ControllerState = StandingStill;
                                ControllerRepeatDelayCurrent = 0;
                            }
                        }

                        DeltaPrevJoyX = Delta;
                    }
                }
                else if( Key == IK_JoyY )
                {
                    if( Delta != DeltaPrevJoyY )
                    {                
                        if( Delta > 0 )
                        {
                            if( ControllerState != HoldingUp )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputUp();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingUp;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else if( Delta < 0 )
                        {
                            if( ControllerState != HoldingDown )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputDown();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingDown;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else
                        {
                            if( ( ControllerState == HoldingDown ) || ( ControllerState == HoldingUp ) )
                            {
                                ControllerState = StandingStill;
                                ControllerRepeatDelayCurrent = 0;
                            }
                        }

                        DeltaPrevJoyY = Delta;
                    }
                }
                else if( Key == IK_JoyU )
                {
                    if( Delta != DeltaPrevJoyU )
                    {                
                        if( Delta < 0 )
                        {
                            if( ControllerState != HoldingLeft )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputLeft();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingLeft;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else if( Delta > 0 )
                        {
                            if( ControllerState != HoldingRight )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputRight();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingRight;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else
                        {
                            if( ( ControllerState == HoldingLeft ) || ( ControllerState == HoldingRight ) )
                            {
                                ControllerState = StandingStill;
                                ControllerRepeatDelayCurrent = 0;
                            }
                        }

                        DeltaPrevJoyU = Delta;
                    }
                }
                else if( Key == IK_JoyV )
                {
                    if( Delta != DeltaPrevJoyV )
                    {                
                        if( Delta > 0 )
                        {
                            if( ControllerState != HoldingUp )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputUp();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingUp;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else if( Delta < 0 )
                        {
                            if( ControllerState != HoldingDown )
                            {
                                CurMenu.LastInputSource = IS_Controller;
                                CurMenu.InputDown();
                                CurMenu.LastInputSource = IS_None;
                                ControllerState = HoldingDown;
                                ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                            }
                        }
                        else
                        {
                            if( ( ControllerState == HoldingUp ) || ( ControllerState == HoldingDown ) )
                            {
                                ControllerState = StandingStill;
                                ControllerRepeatDelayCurrent = 0;
                            }
                        }

                        DeltaPrevJoyV = Delta;
                    }
                }
            }
        }
        else if( Action == IST_Press )
        {
            if( !CurMenu.bRawKeyboardInput )
            {
                switch( Key )
                {
                    case IK_Escape:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.HandleInputBack();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingBack;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Space:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.HandleInputSelect();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingSelect;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Enter:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.HandleInputSelect();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingSelect;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Left:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.InputLeft();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingLeft;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Right:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.InputRight();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingRight;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Up:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.InputUp();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingUp;
                        ControllerRepeatDelayCurrent = 0;
                        break;

                    case IK_Down:
                        CurMenu.LastInputSource = IS_Keyboard;
                        CurMenu.InputDown();
                        CurMenu.LastInputSource = IS_None;
                        ControllerState = HoldingDown;
                        ControllerRepeatDelayCurrent = 0;
                        break;
                }
            }
            
            // Gamepad pass code stuff
            
            rc = false;
            CurMenu.LastInputSource = IS_Controller;
            
            switch( Key )
            {
                case IK_Joy1:
                    rc = CurMenu.HandleInputGamePad( "Y" );
                    break;

                case IK_Joy2:
                    rc = CurMenu.HandleInputGamePad( "B" );
                    break;

                case IK_Joy3:
                    rc = CurMenu.HandleInputGamePad( "A" );
                    break;

                case IK_Joy4:
                    rc = CurMenu.HandleInputGamePad( "X" );
                    break;

                case IK_Joy5:
                    rc = CurMenu.HandleInputGamePad( "K" );
                    break;

                case IK_Joy6:
                    rc = CurMenu.HandleInputGamePad( "W" );
                    break;

                case IK_Joy7:
                    rc = CurMenu.HandleInputGamePad( "LT" );
                    break;

                case IK_Joy8:
                    rc = CurMenu.HandleInputGamePad( "RT" );
                    break;

                case IK_JoyPovUp:
                    rc = CurMenu.HandleInputGamePad( "U" );
                    break;

                case IK_JoyPovDown:
                    rc = CurMenu.HandleInputGamePad( "D" );
                    break;

                case IK_JoyPovLeft:
                    rc = CurMenu.HandleInputGamePad( "L" );
                    break;

                case IK_JoyPovRight:
                    rc = CurMenu.HandleInputGamePad( "R" );
                    break;
            }
            
            CurMenu.LastInputSource = IS_None;
            
            if(rc)
            {
                return(true);
            }
            

            switch( Key )
            {
                case IK_Joy10: // Back button
                case IK_Joy2: // B button
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.HandleInputBack();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingBack;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_Joy9: // Start button
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.HandleInputStart();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingStart;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_Joy3: // A button
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.HandleInputSelect();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingSelect;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_JoyPovLeft:
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.InputLeft();
                    CurMenu.LastInputSource = IS_Controller;
                    ControllerState = HoldingLeft;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_JoyPovRight:
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.InputRight();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingRight;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_JoyPovUp:
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.InputUp();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingUp;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_JoyPovDown:
                    CurMenu.LastInputSource = IS_Controller;
                    CurMenu.InputDown();
                    CurMenu.LastInputSource = IS_None;
                    ControllerState = HoldingDown;
                    ControllerRepeatDelayCurrent = ControllerRepeatDelayInitial;
                    break;

                case IK_RightMouse:
                    CurMenu.LastInputModifier = IM_Alt;
                case IK_LeftMouse:
                    // Sometimes we get spurious middle-mouse events when using the wheel. Hence, let's ignore the middle mouse in the menus.
                    CurMenu.LastInputSource = IS_Mouse;
                    CurMenu.InputMouseDown();
                    CurMenu.LastInputSource = IS_None;
                    CurMenu.LastInputModifier = IM_None;
                    break;

                case IK_MouseWheelUp:
                    CurMenu.LastInputSource = IS_Mouse;
                    if( !CurMenu.HandleInputWheelUp( int(Delta) ) )
                    {
                        while( Delta > 0 )
                        {
                            CurMenu.InputUp();
                            Delta -= 1.f;
                        }
                    }
                    CurMenu.LastInputSource = IS_None;
                    break;

                case IK_MouseWheelDown:
                    CurMenu.LastInputSource = IS_Mouse;
                    if( !CurMenu.HandleInputWheelDown( int(Delta) ) )
                    {
                        while( Delta > 0 )
                        {
                            CurMenu.InputDown();
                            Delta -= 1.f;
                        }
                    }
                    CurMenu.LastInputSource = IS_None;
                    break;
            }
        }
        else if( Action == IST_Release )
        {
            ControllerState = StandingStill;
            ControllerRepeatDelayCurrent = 0;

            switch( Key )
            {
                case IK_RightMouse:
                    CurMenu.LastInputModifier = IM_Alt;
                case IK_LeftMouse:
                case IK_MiddleMouse:
                    CurMenu.LastInputSource = IS_Mouse;
                    CurMenu.InputMouseUp();
                    CurMenu.LastInputSource = IS_None;
                    CurMenu.LastInputModifier = IM_None;
                    break;
				default: //cmr allow all release through
					return false;
            }
        }
        
        return( true ); // Consume all input while in menus
    }

    simulated event Tick( float dt )
    {
        global.Tick( dt );

        if( CurMenu == None )
            return;

        if( ControllerRepeatDelayCurrent == 0 )
            return;

        ControllerRepeatDelayCurrent -= dt;

        if( ControllerRepeatDelayCurrent > 0 )
            return;
        else
            ControllerRepeatDelayCurrent = ControllerRepeatDelaySubsequent;

        CurMenu.LastInputSource = IS_Controller;

        switch( ControllerState )
        {
            case HoldingLeft:
                CurMenu.InputLeft();
                break;

            case HoldingRight:
                CurMenu.InputRight();
                break;

            case HoldingUp:
                CurMenu.InputUp();
                break;

            case HoldingDown:
                CurMenu.InputDown();
                break;

            case HoldingStart:
                CurMenu.HandleInputStart();
                break;

            case HoldingSelect:
                CurMenu.HandleInputSelect();
                break;

            case HoldingBack:
                CurMenu.HandleInputBack();
                break;

            default: 
                ControllerRepeatDelayCurrent = 0;
                break;
        }

        CurMenu.LastInputSource = IS_None;
    }
}

defaultproperties
{
     HistoryBot=-1
     ControllerRepeatDelayInitial=0.700007
     ControllerRepeatDelaySubsequent=0.135000
     bRequiresTick=True
}
