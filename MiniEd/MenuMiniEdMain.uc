class MenuMiniEdMain extends MenuTemplateTitledBA;

enum ESaveAction
{
    SA_Save,
    SA_TryMap,
    SA_NewMap,
    SA_LoadMap,
    SA_XboxLive,
    SA_ReturnToPariah,
    SA_Quit
};

var() MenuButtonText Options[8];
var() config int Position;

var() localized String StringSaveOfflineMap;
var() localized String StringSaveLiveMap;

simulated function Init( String Args )
{
    local bool MapIsLoaded;
    local int i;
    
    Super.Init(Args);
    
    MapIsLoaded = MiniEdMapIsLoaded();

    if( !MapIsLoaded )
    {
        HideBButton(1);
    }
    
    for( i = 0; i < ArrayCount(Options); ++i )
    {
        if( Options[i].OnSelect == 'OnSaveMap' )
        {
            if( MiniEdMapIsLive() )
            {
                Options[i].HelpText = StringSaveLiveMap;
                log("Map is live; setting helptext.");
            }
            else
            {
                Options[i].HelpText = StringSaveOfflineMap;
                log("Map is offline; setting helptext.");
            }
        
            break;
        }
    }
    
    
    SetVisible( 'OnTryMap', MapIsLoaded );
    SetVisible( 'OnSaveMap', MapIsLoaded );
    SetVisible( 'OnSettings', MapIsLoaded );
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

    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            ;
    }
    FocusOnWidget( Options[Position] );
}

simulated function HandleInputBack()
{
    if( MiniEdMapIsLoaded() )
    {
        CloseMenu();
        CrossFadeLevel = 0.f;
        CrossFadeDir = TD_None;
    }
}

simulated function OnContinue()
{
    HandleInputBack();
}

simulated function OnTryMap()
{
    PromptForSaveAction( SA_TryMap );
}

simulated function OnNewMap()
{
    PromptForSaveAction( SA_NewMap );
}

simulated function OnLoadMap()
{
    PromptForSaveAction( SA_LoadMap );
}

simulated function OnSettings()
{
    CallMenuClass("MiniEd.MenuMiniEdSettings");
}

simulated function OnXboxLive()
{
    if( PlayerController(Owner).LiveStatus == LS_SignedIn )
    {
        PromptForSaveAction( SA_XboxLive );
    }
    else
    {
        GotoMenuClass( "XInterfaceLive.MenuLiveSignIn", "MINIED_LIVE" );
    }
}

simulated function OnSaveMap()
{
    local MenuMiniEdLowStorage ML;

    if( !HaveSpaceToSaveMap() )
    {
        ML = Spawn( class'MenuMiniEdLowStorage', Owner );
        ML.SaveAction = SA_Save;
        SavePosition();
        GotoMenu(ML);
        return;
    }

    // AsP ---
    if( IsOnConsole() )
		UseConsoleKeyboard();
	else
		UsePCInputField();
}

simulated function UseConsoleKeyboard()
{
	local MiniEdSaveMapKeyboard M;

    M = Spawn( class'MiniEdSaveMapKeyboard', Owner );
    M.SaveAction = SA_Save;
	SavePosition();
    GotoMenu(M);
}

simulated function UsePCInputField()
{
	local MiniEdPCSaveMap M;

    M = Spawn( class'MiniEdPCSaveMap', Owner );
    M.SaveAction = SA_Save;
	SavePosition();
    GotoMenu(M);
}

simulated function OnReturn()
{
    PromptForSaveAction( SA_ReturnToPariah );
}

simulated function OnQuit()
{
    PromptForSaveAction( SA_Quit );
}

// This is kinda gross but it's a all-singing, all-dancing save before destruction action state-machine.
// In order to reuse SavePrompt menu we need to keep track of what we were going to do after they saved!

simulated function PromptForSaveAction( ESaveAction Action )
{
    local MenuMiniEdSavePrompt MS;
    local MenuMiniEdLowStorage ML;

    Assert( Action != SA_Save );

    SavePosition();

    if( !HaveSpaceToSaveMap() && ( (Action == SA_NewMap) || (Action == SA_LoadMap) ) )
    {
        ML = Spawn( class'MenuMiniEdLowStorage', Owner );
        ML.SaveAction = Action;
        GotoMenu(ML);
    }
    else if( !MiniEdMapIsDirty() )
    {
        FinishSaveAction( self, Action );
    }
    else if( !HaveSpaceToSaveMap() )
    {
        // If they don't have space don't bother warning them UNLESS they're about to start working on something (handled above)
        FinishSaveAction( self, Action );
    }    
    else
    {
        MS = Spawn( class'MenuMiniEdSavePrompt', Owner );
        MS.SaveAction = Action;
        GotoMenu(MS);
    }
}

static simulated function FinishSaveAction( MenuBase Menu, ESaveAction Action )
{
    switch( Action )
    {
        case SA_Save:
            Menu.GotoMenuClass( "MiniEd.MenuMiniEdMain" );
            break;
        
        case SA_TryMap:
            Menu.GotoMenuClass( "MiniEd.MenuMiniEdTryMap" );
            break;
            
        case SA_NewMap:
	        Menu.GotoMenuClass( "MiniEd.MenuMiniEdGameType" );
	        break;
	        
	    case SA_LoadMap:
            Menu.GotoMenuClass( "MiniEd.MenuMiniEdLoad" );
            break;
        
        case SA_XboxLive:
        
            if( PlayerController(Menu.Owner).LiveStatus == LS_SignedIn )
            {
                Menu.GotoMenuClass( "MiniEd.MenuMiniEdLive" );
            }
            else
            {
                Menu.GotoMenuClass( "XInterfaceLive.MenuLiveSignIn", "MINIED_LIVE" );
            }
            break;
            
        case SA_ReturnToPariah:
	        Menu.ConsoleCommand( "RETURNTOGAME" );
	        break;
        
        case SA_Quit:
            Menu.GotoMenuClass( "XInterfaceCommon.MenuQuit" );
	        break;
    }
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Try Map"),OnSelect="OnTryMap",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Save Map"),OnSelect="OnSaveMap")
     Options(2)=(Blurred=(Text="New Map"),OnSelect="OnNewMap")
     Options(3)=(Blurred=(Text="Load Map"),OnSelect="OnLoadMap")
     Options(4)=(Blurred=(Text="Settings"),OnSelect="OnSettings")
     Options(5)=(Blurred=(Text="Xbox Live"),OnSelect="OnXboxLive",Platform=MWP_Xbox)
     Options(6)=(Blurred=(Text="Return to Pariah"),OnSelect="OnReturn")
     Options(7)=(Blurred=(Text="Quit"),OnSelect="OnQuit",Platform=MWP_PC)
     StringSaveOfflineMap="Save your Offline map."
     StringSaveLiveMap="Save your Live map."
     BLabel=(Text="Continue Editing")
     MenuTitle=(Text="Pariah Map Editor")
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
