// This is the "PRESS START / INSERT COIN menu"
class MenuStart extends MenuTemplateTitled;

var() MenuText PressStart;
var bool bFoundCrossTitleInvite;
var() MenuSprite PariahLogo;

var localized String ClickToBegin;

var() MenuText Version;

var() MenuLayer AttractModeLayer;
var() bool EnteredAttractMode;

simulated function Init( String Args )
{
    local string s;

    // iterate saves
    GetManifest();
    
    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();

    Super.Init( Args );

    s = ConsoleCommand("XLIVE GETAUTHSTATE");
    if( s == "ONLINE" || s == "CHANGING_LOGON" )
    {
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
        return;
    }

    LanguageChange();

    SetTimer(0.1, true);
}

simulated function bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if( AttractModeLayer.Layer != None )
    {
        if( AttractModeLayer.Layer.HandleInputKeyRaw(Key, Action) )
        {
            EnteredAttractMode = true;
            return(true);
        }
        else
        {
            return(false);
        }
    }
    else
    {
        return(false);
    }
}

simulated function bool HandleInputAxis( Interactions.EInputKey Key, float Delta )
{
    if( AttractModeLayer.Layer != None )
    {
        if( AttractModeLayer.Layer.HandleInputAxis(Key, Delta) )
        {
            EnteredAttractMode = true;
            return(true);
        }
        else
        {
            return(false);
        }
    }
    else
    {
        return(false);
    }
}

simulated function Tick( float Delta )
{
    local MenuAttractMode M;
    
    Super.Tick( Delta );

    M = MenuAttractMode( AttractModeLayer.Layer );
    if( M != None )
    {
        M.StartMenu = self;
    }
}

simulated function Timer()
{
    CheckForCrossTitleInvite();
}

simulated function CheckForCrossTitleInvite()
{
    local MenuMain M;

    if( bFoundCrossTitleInvite )
        return;
    
    if( "TRUE" == ConsoleCommand("XLIVE IS_CROSS_TITLE_INVITE") )
    {
        bFoundCrossTitleInvite = true;
    
        M = Spawn( class'MenuMain', Owner );
        M.CallMenuClass("XInterfaceLive.MenuAcceptCrossTitleInvite");
        GotoMenu(M);
    }
}

simulated function LanguageChange()
{
    if( IsOnConsole() )
    {
        PressStart.Text = class'XboxStandardMsgs'.default.ErrorMsg[5];
    }
    else
    {
        PressStart.Text = ClickToBegin;
    }
	Version.Text = ConsoleCommand("INSTALL_VERSION");
}

simulated function HandleInputBack();

simulated function OnAttractModeEnd()
{
    // Ugly hacks so that returning from AM puts you straight at the main menu (I believe this is required by TCR).
    PariahLogo.bHidden = 1;
    PressStart.bHidden = 1;
    Version.bHidden = 1;
    MenuTitleLine.bHidden = 1;
    HandleInputSelect();
}

simulated function HandleInputMouseDown()
{
    HandleInputSelect();
}

simulated function HandleInputStart()
{
    HandleInputSelect();
}

simulated function HandleInputSelect()
{
    ConsoleCommand("XLIVE SILENT_LOGON");
    GotoMenuClass("XInterfaceCommon.MenuMain");
}

defaultproperties
{
     PressStart=(PosY=0.900000,Style="MessageText")
     PariahLogo=(WidgetTexture=Texture'PariahInterface.Logos.PariahLogoHelix',DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=0.670000,ScaleY=1.000000,Pass=1)
     ClickToBegin="Press any key to begin"
     Version=(MenuFont=Font'Engine.FontMono',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_LowerLeft,PosY=1.000000,Pass=4)
     AttractModeLayer=(MenuClassName="XInterfaceCommon.MenuAttractMode",Pass=10)
     ControllerIcon=(bHidden=1)
     GamertagText=(bHidden=1)
     GamerOnlineStatusText=(bHidden=1)
     ControllerNumText=(bHidden=1)
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
