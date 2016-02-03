//=============================================================================
// Menu base class
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class Menu extends Actor
    abstract
    transient
    native
    dependsOn(Interactions)
;

// The PreviousMenu variables keep a list of menus in series so that when 
// one closes the previous one can be brought back up.

var() editinline Menu PreviousMenu;

// The TravelMenu variable will be returned by the next DrawMenu call.

var() editinline Menu TravelMenu;

// The LastInputSource variable is managed by the Console and can be used
// to modify things like auto-focus behaviour based on the form of input given.

enum InputSource
{
    IS_None,
    IS_Mouse,
    IS_Keyboard,
    IS_Controller
};

var transient InputSource LastInputSource;

enum InputModifier
{
    IM_None,
    IM_Alt,
    IM_Shift,
    IM_Ctrl
};

var transient InputModifier LastInputModifier;

var() bool bRenderLevel;
var() bool bPersistent;
var() bool bFullscreenOnly; // this menu must be drawn fullscreen
var() bool bIgnoresInput;
var() float SpawnTime;

var() bool bShowMouseCursor;
var   bool bActive; // CMR -- menu is currently being rendered
var	  bool bAllowStats;	// RJ -- allow stats to be displayed while this menu is active
var() float MouseX, MouseY;

// This is a lovely hack that allows us to bind space to "Select" but have it still
// work with editboxes and key auto-repeat.
var() bool bRawKeyboardInput;

var() bool bVignette;

var() bool bRequiresNetwork;

simulated function Destroyed()
{
    local PlayerController pc;
    pc = PlayerController(Owner);
    // haxx to cleanup the console's menu refs: it is an object, so does not get 
    // cleanupdestroyed love
    if(pc != None)
    {
        if(pc.Player != None && pc.Player.Console != None)
        {
            if(pc.Player.Console.PrevMenu == self)
            {
                pc.Player.Console.PrevMenu = None;
            }
            if(pc.Player.Console.CurMenu == self)
            {
                pc.Player.Console.CurMenu = None;
            }
        }
    }
    Super.Destroyed();
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    TravelMenu = self;
    
    SpawnTime = Level.TimeSeconds;
}

// Init is called after a the code constructing a menu has finished initializing it.
// It should generally be used instead of PreBeginPlay.

simulated event Init( String Args );

simulated event DrawMenu ( Canvas C, bool HasFocus );

simulated function Plane GetModulationColor();
simulated function bool IsVisible()
{
    return true;
}

// This event will be sent to a menu when a menu closes and focus is returned to this menu,
// or, when the last menu in the call stack has finished fading out, it will get a MenuClosed
// event with (self) as it's ClosingMenu.

simulated function bool MenuClosed( Menu ClosingMenu ); //return true if handled

//Fork left,right,down,up inputs to gui layout input or normal input (xmatt)
simulated function InputLeft();
simulated function InputRight();
simulated function InputUp();
simulated function InputDown();
simulated function InputMouseDown();
simulated function InputMouseUp();

simulated function HandleInputLeft();
simulated function HandleInputRight();
simulated function HandleInputUp();
simulated function HandleInputDown();

simulated function HandleInputSelect();  // The "A" Button or whatever (Space on PC)
simulated function HandleInputStart();   // The "Start" Button
simulated event HandleInputBack();    // The "B" or "Back" Button (Escape on PC)

simulated function bool HandleInputKey( Interactions.EInputKey Key ); // Gives menus a chance to ride the raw input. Return true to consume.
simulated function bool HandleInputKeyRaw( Interactions.EInputKey Key, Interactions.EInputAction Action );
simulated function HandleInputMouseDown();
simulated function HandleInputMouseUp();
simulated function HandleInputMouseMove();

simulated function bool HandleInputAxis( Interactions.EInputKey Key, float Delta );

simulated function bool HandleInputWheelUp( int Clicks );
simulated function bool HandleInputWheelDown( int Clicks );

simulated function bool HandleInputGamePad( String ButtonName )
{
	return( false );
}

simulated function ReopenInit();

simulated function DestroyMenu()
{
    if (!bPersistent)
    {
        log(Name$".Destroy()", 'Log');
        Destroy();
    }
}

event PostLevelChange();

simulated function bool IgnoreKeyEvent( Interactions.EInputKey Key, Interactions.EInputAction Action )
{
    return( false );
}

simulated function bool KeyIsBoundTo( Interactions.EInputKey Key, String Binding )
{
    local String KeyName, KeyBinding;
    
    KeyName = PlayerController(Owner).ConsoleCommand( "KEYNAME "$Key );
    
    if( KeyName == "" )
        return( false );
    
    KeyBinding = PlayerController(Owner).ConsoleCommand( "KEYBINDING "$KeyName );

    if( KeyBinding ~= Binding )
        return( true );

    return( false );
}

simulated event bool IsLiveMenu()
{
    local String ClassName;
    
    ClassName = String(Class);
    
    if( InStr( ClassName, "XInterfaceLive" ) >= 0 )
    {
        return(true);
    }
    else
    {
        return(false);
    }
}

simulated event bool IsNetMenu()
{
    local String ClassName;

    if( IsLiveMenu() )
    {
        return(true);
    }

    ClassName = String(Class);

    if( (InStr( ClassName, "XInterfaceMP" ) >= 0) && (InStr( ClassName, "XInterfaceMP.MenuPractice" ) < 0) )
    {
        return(true);
    }
    
    return(bRequiresNetwork);
}

simulated event bool FindLiveMenu(Menu M)
{
    if( M == None )
    {
        return(false);
    }
    
    return( M.IsLiveMenu() || FindLiveMenu( M.PreviousMenu ) );
}

simulated event bool FindNetMenu(Menu M)
{
    if( M == None )
    {
        return(false);
    }
    
    return( M.IsNetMenu() || FindNetMenu( M.PreviousMenu ) );
}

simulated function Menu GetBottomMenu();

defaultproperties
{
     bShowMouseCursor=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     DrawType=DT_None
     RemoteRole=ROLE_None
     bUnlit=True
     bGameRelevant=True
}
