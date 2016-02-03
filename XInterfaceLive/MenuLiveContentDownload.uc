class MenuLiveContentDownload extends MenuQuestionYesNo;

var() localized string ConfirmContentDownloadFailedText;

simulated function OnYes()
{
    ConsoleCommand("XLIVE PERSIST");
    ConsoleCommand("XLIVE CONTENT_DOWNLOAD");

    // If we don't reboot in < 1s then we failed and show the warning message.
    SetTimer(1.0, false);
}

simulated function Timer()
{
    CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(ConfirmContentDownloadFailedText));
}

defaultproperties
{
     ConfirmContentDownloadFailedText="Content download failed.\n\nPlease try again later."
     Question=(Text="Content download allows you to get new characters and levels for Pariah as they become available.\n\nThe new content is downloaded to your Xbox Hard Disk and appears in the game as selectable items.\n\nWould you like to see what new content is currently available for download?",Style="LongMessageText")
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
