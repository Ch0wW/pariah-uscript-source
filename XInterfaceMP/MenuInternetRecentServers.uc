class MenuInternetRecentServers extends MenuTemplateTitledB;

// Just rams you the list of your favourites and starts pinging them.

var() MenuText WarningText;

simulated function HandleInputBack()
{
    GotoMenuClass("XInterfaceMP.MenuInternetMain");
}

defaultproperties
{
     WarningText=(Text="This functionality is not implemented yet.",DrawPivot=DP_LowerLeft,PosY=0.500000,Style="MessageText")
     MenuTitle=(Text="Recent Servers")
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
