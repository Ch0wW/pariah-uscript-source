class MenuLiveAutoUpdate extends MenuQuestionYesNo;

var() localized String AutoUpdateFailedText;

simulated function Init( String Args )
{
    Super.Init(Args);
    
    ALabel.Text = default.ALabel.Text;
    BLabel.Text = default.BLabel.Text;
}

simulated function OnYes()
{
    ConsoleCommand("XLIVE PERSIST");
    ConsoleCommand("XLIVE UPDATE_TITLE");

    // If we don't reboot in < 1s then we failed and show the warning message.
    SetTimer(1.0, false);
}

simulated function Timer()
{
    CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(AutoUpdateFailedText));
}

defaultproperties
{
     AutoUpdateFailedText="Auto-update failed.\n\nPlease try again later."
     Question=(Text="A required update is available for the Xbox Live service.\n\nYou cannot connect to Xbox Live until the update is installed.",Style="MedMessageText")
     ALabel=(Text="Update")
     BLabel=(Text="Cancel")
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
