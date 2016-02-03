class MenuOverwriteProgress extends MenuQuestionYesNoCancel;

var localized string mOverwriteQuestion;
var GameProfile.ESessionMode mMode;


simulated function Init(string Args)
{
    Super.Init(Args);
    SetText( mOverwriteQuestion ); 
}

simulated function OnYes()
{
    mMode = ESM_Replay;
    CloseMenu();
}

simulated function OnNo()
{
    mMode = ESM_Overwrite;
    CloseMenu();
}

simulated function OnCancel()
{
    CloseMenu();
}

defaultproperties
{
     mOverwriteQuestion="Would you like to play without saving or overwrite your single player progress?"
     ALabel=(Text="Play")
     XLabel=(Text="Overwrite")
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
