class MenuGamerConfirm extends MenuQuestionYesNo
    DependsOn(MenuGamerList);

var() class<MenuGamerDetails> BackClass;
var() MenuGamerList.Gamer Gamer;

var() String CommandText;
var() String FailedOperation;

var() localized String StringGamertagToken;

simulated function Init( String Args )
{
    local String N;
    
    Super.Init( Args );

    N = Gamer.Gamertag;
    
    Question.Text = ReplaceSubString( Question.Text, StringGamertagToken, N );
}

simulated function OnYes()
{
    if( "SUCCESS" != ConsoleCommand( CommandText ) )
        OverlayErrorMessageBox( FailedOperation );
    else
    {
        MenuGamerList(PreviousMenu).RefreshList();
        CloseMenu();
    }
}

simulated function OnNo()
{
    local MenuGamerDetails M;
    M = Spawn( BackClass, Owner );
    GotoMenu( M );
}

defaultproperties
{
     StringGamertagToken="<GAMER>"
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
