class MenuConnectionFailed extends MenuTemplateTitledA;

var() MenuText Message;

simulated function HandleInputBack();

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function OnAButton()
{
    if( class'GameEngine'.default.DisconnectMenuClass == "" )
        GotoMenuClass( "XInterfaceCommon.MenuMain", "" );
    else
    {
        GotoMenuClass( class'GameEngine'.default.DisconnectMenuClass, class'GameEngine'.default.DisconnectMenuArgs );
        class'GameEngine'.default.DisconnectMenuClass = "";
        class'GameEngine'.default.DisconnectMenuArgs = "";
        class'GameEngine'.static.StaticSaveConfig();
    }
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Text="This game session is no longer available.",Style="MessageText")
     ALabel=(Text="Continue")
     APlatform=MWP_All
     CrossFadeRate=20.000000
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
     bFullscreenOnly=True
}
