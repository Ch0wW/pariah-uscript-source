class MenuDashboardConfirm extends MenuTemplateTitledBA;

// Args: <XLD_LAUNCH_DASHBOARD_ENUM> [Options]

var() MenuText ConfirmText;

var() localized String StringDashMain;
var() localized String StringDashError;
var() localized String StringDashMemory;
var() localized String StringDashSettings;
var() localized String StringDashMusic;
var() localized String StringDashNetwork;
var() localized String StringDashNewAccount;
var() localized String StringDashManageAccount;
var() localized String StringDashOnlineMenu;

var() localized String StringAreYouSure;

simulated function Init( String Args )
{
    local String DashType;
    
    Super.Init( Args );

    DashType = ParseToken( Args );

    if( DashType == "XLD_LAUNCH_DASHBOARD_MAIN_MENU" )
        ConfirmText.Text = StringDashMain;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_ERROR" )
        ConfirmText.Text = StringDashError;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_MEMORY" )
        ConfirmText.Text = StringDashMemory;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_SETTINGS" )
        ConfirmText.Text = StringDashSettings;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_MUSIC" )
        ConfirmText.Text = StringDashMusic;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_NETWORK_CONFIGURATION" )
        ConfirmText.Text = StringDashNetwork;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_NEW_ACCOUNT_SIGNUP" )
        ConfirmText.Text = StringDashNewAccount;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_ACCOUNT_MANAGEMENT" )
        ConfirmText.Text = StringDashManageAccount;
    else if( DashType == "XLD_LAUNCH_DASHBOARD_ONLINE_MENU" )
        ConfirmText.Text = StringDashOnlineMenu;
    else
    {
        log( "Unknown value for ALLOW_BOOT_TO_DASH:" @ DashType );
        CloseMenu();
    }
    
    ConfirmText.Text = ConfirmText.Text $ "\\n\\n" $ StringAreYouSure;
}

simulated function OnAButton()
{
    PlayerController(Owner).ConsoleCommand( "DASHBOARD" @ Args );
}

simulated function OnBButton()
{
    CloseMenu();
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }

    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
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
     ConfirmText=(Style="MedMessageText")
     StringDashMain="You are about to leave Pariah to load the Xbox Dashboard main menu."
     StringDashError="You are about to leave Pariah to load the Xbox Dashboard diagnostic tool."
     StringDashMemory="You are about to leave Pariah."
     StringDashSettings="You are about to leave Pariah to load the Xbox Dashboard settings."
     StringDashMusic="You are about to leave Pariah to load the Xbox Dashboard music manager."
     StringDashNetwork="You are about to leave Pariah to load the troubleshooter."
     StringDashNewAccount="You are about to leave Pariah to create a new Xbox Live account."
     StringDashManageAccount="You are about to leave Pariah to manage your Xbox Live account."
     StringDashOnlineMenu="You are about to leave Pariah to load the Xbox Live online menu."
     StringAreYouSure="Any unsaved progress will be lost.\n\nDo you want to continue?"
     ALabel=(Text="Yes")
     APlatform=MWP_All
     BLabel=(Text="No")
     MenuTitle=(Text="Please Confirm")
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
