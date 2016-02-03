class MenuPlayerFeedbackDone extends MenuTemplateTitledA;

var() MenuText Text;

simulated function HandleInputBack();

simulated function OnAButton()
{
    CloseMenu();
}

simulated function HandleInputStart()
{
    OnAButton();
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
     Text=(Text="Your feedback has been sent.\nThank you for your time.",Style="MessageText")
     ALabel=(Text="Continue")
     APlatform=MWP_All
     MenuTitle=(Text="Feedback Sent")
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
