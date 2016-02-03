class MenuLiveUserHasMessage extends MenuTemplateTitledBA;

var() MenuText MessageText;

simulated function Init( String Args )
{
    Super.Init( Args );
    MessageText.Text = Localize( "Errors", "XONLINE_S_LOGON_USER_HAS_MESSAGE", "XboxLive" );
}

simulated function OnAButton()
{
    CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", "XLD_LAUNCH_DASHBOARD_ACCOUNT_MANAGEMENT" );
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
    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }

    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     MessageText=(Style="MessageText")
     ALabel=(Text="Read Now")
     BLabel=(Text="Read Later")
     MenuTitle=(Text="Message Waiting")
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
