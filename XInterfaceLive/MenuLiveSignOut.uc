class MenuLiveSignOut extends MenuQuestionYesNo;

simulated function Init(string Args)
{
    Super.Init(Args);
    SetText( class'MenuLiveMain'.default.ConfirmSignOutText ); // To avoid more INT changes.
}

simulated function OnYes()
{
    ConsoleCommand("XLIVE LOGOFF -1");
    
    if( IsMiniEd() )
    {
        GotoMenuClass("MiniEd.MenuMiniEdMain");
    }
    else
    {
        GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
    }
}

simulated function OnNo()
{
    if( IsMiniEd() )
    {
        GotoMenuClass("MiniEd.MenuMiniEdLive");
    }
    else
    {
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    }
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
