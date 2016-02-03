class MenuSettingsControlsPC extends MenuTemplateTitledB;

var() MenuButtonText Options[6];

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );
    
    Options[5].Blurred.PosY = 1.0 - Options[0].Blurred.PosY;
    Options[5].Focused.PosY = 1.0 - Options[0].Focused.PosY;
}

simulated function OnMovement()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCMovement", "" );
}

simulated function OnLooking()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCLooking", "" );
}

simulated function OnCombat()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCCombat", "" );
}

simulated function OnWeapons()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCWeapons", "" );
}

simulated function OnMisc()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCMisc", "" );
}

simulated function OnRestoreDefaults()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPCDefaults", "" );
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Movement"),OnSelect="OnMovement",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Looking"),OnSelect="OnLooking")
     Options(2)=(Blurred=(Text="Combat"),OnSelect="OnCombat")
     Options(3)=(Blurred=(Text="Weapons"),OnSelect="OnWeapons")
     Options(4)=(Blurred=(Text="Miscellaneous"),OnSelect="OnMisc")
     Options(5)=(Blurred=(Text="Restore Defaults"),OnSelect="OnRestoreDefaults")
     MenuTitle=(Text="Controls")
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
