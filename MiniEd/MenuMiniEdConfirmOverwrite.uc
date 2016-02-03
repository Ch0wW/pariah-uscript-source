class MenuMiniEdConfirmOverwrite extends MenuQuestionYesNo
    DependsOn(MenuMiniEdMain);

var() MenuMiniEdMain.ESaveAction SaveAction;
var() String MapName;

simulated function Init( String Args )
{
    MapName = ParseToken( Args );
    Super.Init("");
    Question.Text = ReplaceSubstring( Question.Text, "<MAPNAME>", MapName );
}

simulated function OnYes()
{
    local MenuMiniEdNameVerify NameVerify;

    if( MiniEdMapIsLive() && (PlayerController(Owner).LiveStatus == LS_SignedIn) )
    {
        NameVerify = Spawn( class'MenuMiniEdNameVerify', Owner );
        NameVerify.SaveAction = SaveAction;
        GotoMenu( NameVerify, MakeQuotedString(MapName) );
        return;
    }

	// AsP ---
    if( IsOnConsole() )
		class'MiniEdSaveMapKeyboard'.static.SaveMap( self, MapName, SaveAction );
	else
		class'MiniEdPCSaveMap'.static.SaveMap( self, MapName, SaveAction );
}

simulated function OnNo()
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
    GotoMenu( M, MapName );
}

simulated function UsePCInputField()
{
	local MiniEdPCSaveMap M;

    M = Spawn( class'MiniEdPCSaveMap', Owner );
    M.SaveAction = SaveAction;
    GotoMenu( M, MapName );
}

defaultproperties
{
     Question=(Text="You already have a map named <MAPNAME>. Do you want to replace it?")
     MenuTitle=(Text="Confirm Overwrite")
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
