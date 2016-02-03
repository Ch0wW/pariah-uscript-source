class MenuSettingsControlsPCDefaults extends MenuQuestionYesNo;

var() localized String StringRestored;

simulated function OnYes()
{
    Question.Text = StringRestored;
    SetTimer(1.5, false);
    HideAButton(1);
    HideBButton(1);
    bIgnoresInput = true;
    PlayerController(Owner).ResetKeyboard(); // Misnamed -- actually restores all bindings.
}

simulated Function Timer()
{
    CloseMenu();
}

simulated function OnNo()
{
    CloseMenu();
}

defaultproperties
{
     StringRestored="Defaults restored."
     Question=(Text="Restore all input bindings to defaults?")
     MenuTitle=(Text="")
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
