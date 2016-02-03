class MenuBadNetworkConfirm extends MenuQuestionYesNo;

var() localized String StringAreYouSure;
var() string URL;

simulated function Init( String Args ) // ARGS should be the game URL
{   
    Super.Init( Args );

    URL = Args;
    
    Question.Text = class'XboxStandardMsgs'.default.LiveError[7] $ "\\n" $ StringAreYouSure;
}

simulated function OnYes()
{
    // join the URL
    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
}

simulated function OnNo()
{
    CloseMenu();
}

defaultproperties
{
     StringAreYouSure="Do you want to continue?"
     ALabel=(Text="Yes")
     BLabel=(Text="No")
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
