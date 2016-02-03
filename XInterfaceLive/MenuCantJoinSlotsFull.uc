class MenuCantJoinSlotsFull extends MenuTemplateTitledA;

/*	Cant Join Multiplayer Game - All Slots Full Error Message

	This class is displayed with only the option to go back when the
	game that was selected to be joined has been deemed "full" - AKA
	there are not enough slots left on the about-to-be-joined game to
	accomodate all players that are on this xbox.
*/

var() MenuText Message;

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
     Message=(Text="The game does not have enough openings for all the players on your console.",Style="MedMessageText")
     ALabel=(Text="Continue")
     MenuTitle=(Text="Unable to Join Session")
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
