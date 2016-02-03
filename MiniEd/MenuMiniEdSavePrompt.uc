class MenuMiniEdSavePrompt extends MenuQuestionYesNoCancel
    DependsOn(MenuMiniEdMain);

var() MenuMiniEdMain.ESaveAction SaveAction;

var() localized String StringSaveChangesUntitled;
var() localized String StringSaveChangesTitled;

simulated function Init( String Args )
{
    local MiniEdInfo Info;
    
    Super.Init( Args );
    
	Info = MiniEdInfo(Level.Game);
	Assert( Info != None );
	
    if( MiniEdGetCustomMapShort() == "" )
    {
        SetText( StringSaveChangesUntitled );
    }
    else
    {
        SetText( ReplaceSubString( StringSaveChangesTitled, "<MAPNAME>", MiniEdGetCustomMapShort() ) );
    }
}

simulated function OnYes()
{
    // AsP ---
    if( IsOnConsole() )
		UseConsoleKeyboard();
	else
		UsePCInputField();

}
simulated function UseConsoleKeyboard()
{
	local MiniEdSaveMapKeyboard M;

    M = Spawn( class'MiniEdSaveMapKeyboard', Owner );
    M.SaveAction = SaveAction;
    GotoMenu(M);
}

simulated function UsePCInputField()
{
	local MiniEdPCSaveMap M;

    M = Spawn( class'MiniEdPCSaveMap', Owner );
    M.SaveAction = SaveAction;
    GotoMenu(M);
}

simulated function OnCancel()
{
    GotoMenuClass("MiniEd.MenuMiniEdMain");
}

simulated function OnNo()
{
    class'MenuMiniEdMain'.static.FinishSaveAction( self, SaveAction );
}

defaultproperties
{
     StringSaveChangesUntitled="Save your map before continuing?"
     StringSaveChangesTitled="Save changes to <MAPNAME> before continuing?"
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
