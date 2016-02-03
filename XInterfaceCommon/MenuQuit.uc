class MenuQuit extends MenuQuestionYesNo;

var() localized String StringUnSavedProgressWillBeLost;

simulated function Init( String Args )
{
    local GameProfile gProfile;
    
    Super.Init( Args );
    
    gProfile = GetCurrentGameProfile();
    if( Level.Game.bSinglePlayer && gProfile != None && gProfile.ShouldSave())
    {
        Question.Text = Question.Text @ StringUnSavedProgressWillBeLost;
    }
}

simulated function OnYes()
{
    ConsoleCommand( "QUIT" );
}

simulated function OnNo()
{
    if( IsMiniEd() )
    {
        GotoMenuClass("MiniEd.MenuMiniEdMain");
    }
    else if( InMenuLevel() )
    {
        GotoMenuClass("XInterfaceCommon.MenuMain");
    }
    else
    {
        CloseMenu();
    }
}

defaultproperties
{
     StringUnSavedProgressWillBeLost="Any unsaved progress will be lost!"
     Question=(Text="Really quit Pariah?")
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
