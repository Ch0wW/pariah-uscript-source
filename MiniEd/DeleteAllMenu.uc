class DeleteAllMenu extends MiniedYesNoMenu;

var localized String	L_MenuText;

simulated function Init( String Args )
{
	Super.Init( Args );
	MenuDescription.Text=L_MenuText;
}

simulated function OnYes()
{
	ConsoleCommand( "DESTROYALLMESHES" );
	CloseMenu();
}

defaultproperties
{
     L_MenuText="Confirm : \n Delete All Objects?"
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
