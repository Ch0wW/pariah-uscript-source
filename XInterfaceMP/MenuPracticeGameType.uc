class MenuPracticeGameType extends MenuSelectGameType;

simulated function HandleInputBack()
{
    Super.HandleInputBack();
    GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
}

simulated function OnSelect( int ContextId )
{
    local MenuPracticeMap M;

	GameTypeName = GameTypeRecords[ContextId].ClassName;
	SaveConfig();

    M = Spawn(class'MenuPracticeMap', Owner);
    M.GameType = GameTypeRecords[ContextId];

    GotoMenu(M);
}

defaultproperties
{
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
