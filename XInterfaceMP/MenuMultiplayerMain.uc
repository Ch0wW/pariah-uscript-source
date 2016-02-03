class MenuMultiplayerMain extends MenuTemplateTitledBA;

var() MenuButtonText Options[5];

var() config int Position;

simulated function Init( String Args )
{
    Super.Init( Args ); 

    if( GetPlatform() == MWP_Xbox )
    {
        Timer();
        SetTimer(0.5, true);
    }
    
    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            ;
    }
    
    // Trounced by default prop migration.
    SetVisible( 'OnPracticeMode', true );
    
    FocusOnWidget( Options[Position] );
}

simulated function HandleInputBack()
{
    SetTimer(0, false);
    SavePosition();

    if( PreviousMenu != None )
    {
        CloseMenu();
    }
    else
    {
        GotoMenuClass( "XInterfaceCommon.MenuMain" );
    }
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

simulated exec function Pork()
{
    SetTimer(0, false);

    SetVisible( 'OnLocalNetwork', true );
    SetVisible( 'OnInternet', true );
    SetVisible( 'OnXboxLive', true );
    SetVisible( 'OnSystemLink', true );
    SetVisible( 'OnPracticeMode', true );
}

simulated function UpdateOptionsXbox()
{
    local bool HaveLink;
    local int i;

    // check link cable connection
    HaveLink = bool( ConsoleCommand("XLIVE GET_LINK_ACTIVE") );

    //SetVisible( 'OnXboxLive', HaveLink );
    SetVisible( 'OnSystemLink', HaveLink );

    for( i = 0; i < ArrayCount(Options); ++i )
    {
        if( ( Options[i].bHasFocus != 0 ) && ( Options[i].bHidden == 0 ) )
        {
            return;
        }
    }

    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            ;
    }
    
    FocusOnWidget( Options[Position] );
}

simulated function Timer()
{
    UpdateOptionsXbox();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated function OnPracticeMode()
{
    SavePosition();
    GotoMenuClass("XInterfaceMP.MenuPracticeGameType");
}

simulated function OnLocalNetwork()
{
    local MenuInternetServerList M;

    SavePosition();
    
    M = Spawn( class'MenuInternetServerList', Owner );
    M.ListMode = SLM_Lan;

    GotoMenu( M );
}

simulated function OnInternet()
{
    SavePosition();

    if( class'MenuInternetSettingsPrompt'.default.ConfiguredInternet )
    {
        GotoMenuClass("XInterfaceMP.MenuInternetMain");
    }
    else
    {
        GotoMenuClass("XInterfaceMP.MenuInternetSettingsPrompt");
    }
}

simulated function OnXboxLive()
{
    local String AuthState;
    
    SavePosition();
    
    AuthState = ConsoleCommand("XLIVE GETAUTHSTATE");
    
    if( AuthState == "ONLINE" )
    {
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
        return;
    }
    
    ConsoleCommand("XLIVE LOGOFF -1");
    GotoMenuClass("XInterfaceLive.MenuLiveSignIn", "LIVE_MAIN");
}

simulated function OnSystemLink()
{
    OnLocalNetwork();
}

simulated function bool FindNetMenu(Menu M)
{
    return(false);
}

simulated function bool IsNetMenu()
{
    return(false);
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Internet"),OnSelect="OnInternet",Platform=MWP_PC,Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Local Network"),OnSelect="OnLocalNetwork",Platform=MWP_PC)
     Options(2)=(Blurred=(Text="Xbox Live"),OnSelect="OnXboxLive",Platform=MWP_Xbox)
     Options(3)=(Blurred=(Text="System Link"),OnSelect="OnSystemLink",Platform=MWP_Xbox)
     Options(4)=(Blurred=(Text="Practice Mode"),OnSelect="OnPracticeMode")
     MenuTitle=(Text="Multiplayer")
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
