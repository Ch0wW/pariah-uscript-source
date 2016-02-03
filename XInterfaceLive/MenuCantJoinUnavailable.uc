class MenuCantJoinUnavailable extends MenuTemplateTitledA;

var() MenuText Message;

simulated function Init( String Args )
{
    Message.Text = class'XboxStandardMsgs'.default.LiveError[6]; // XONLINE_E_MATCH_INVALID_SESSION_ID
}

simulated function HandleInputStart()
{
    CloseMenu();
}

simulated function OnAButton()
{
    CloseMenu();
}

simulated function HandleInputBack()
{
    CloseMenu();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Style="MedMessageText")
     ALabel=(Text="Continue")
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
