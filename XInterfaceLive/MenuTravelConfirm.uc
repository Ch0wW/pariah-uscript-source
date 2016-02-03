class MenuTravelConfirm extends MenuQuestionYesNo
    DependsOn(MenuGamerList);

var() MenuGamerList.Gamer Gamer;
var() String Command; // [JOIN | ACCEPT]

var() localized String MiniEdQuestionText;

simulated function Init( String Args )
{
    Super.Init(Args);

    Command = Args;
    
    if( IsMiniEd() )
    {
        SetText( MiniEdQuestionText );
    }
    else if( (Level.Game != None) && Level.Game.bSinglePlayer )
    {
        SetText( Question.Text $ "\\n\\n" $ class'MenuPause'.default.StringUnSavedProgressWillBeLost );
    }
}

simulated function OnNo()
{
    CloseMenu();
}

simulated function OnYes()
{
    local MenuJoiningMatch M;
    
    M = Spawn( class'MenuJoiningMatch', Owner );
    M.Gamer = Gamer;

    Assert( M.Gamer.Gamertag != "" );
    GotoMenu( M, Command );
}

defaultproperties
{
     MiniEdQuestionText="Are you sure that you want to stop editing your map? Any unsaved changes will be lost."
     Question=(Text="Are you sure that you want to leave your current game?")
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
