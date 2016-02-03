class MenuSettingsControlsPCWeapons extends MenuTemplateTitledB;

var() MenuText LabelHealingTool;
var() MenuText LabelBulldog;
var() MenuText LabelFragRifle;
var() MenuText LabelGrenadeLauncher;
var() MenuText LabelPlasmaGun;
var() MenuText LabelSniperRifle;
var() MenuText LabelRocketLauncher;
var() MenuText LabelTitansFist;

var() MenuBindingBox BindingHealingToolA;
var() MenuBindingBox BindingBulldogA;
var() MenuBindingBox BindingFragRifleA;
var() MenuBindingBox BindingGrenadeLauncherA;
var() MenuBindingBox BindingPlasmaGunA;
var() MenuBindingBox BindingSniperRifleA;
var() MenuBindingBox BindingRocketLauncherA;
var() MenuBindingBox BindingTitansFistA;

var() MenuBindingBox BindingHealingToolB;
var() MenuBindingBox BindingBulldogB;
var() MenuBindingBox BindingFragRifleB;
var() MenuBindingBox BindingGrenadeLauncherB;
var() MenuBindingBox BindingPlasmaGunB;
var() MenuBindingBox BindingSniperRifleB;
var() MenuBindingBox BindingRocketLauncherB;
var() MenuBindingBox BindingTitansFistB;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( LabelHealingTool, LabelTitansFist, 'BindingLabelLayout' );
    LayoutWidgets( BindingHealingToolA, BindingTitansFistA, 'BindingBoxLayoutA' );
    LayoutWidgets( BindingHealingToolB, BindingTitansFistB, 'BindingBoxLayoutB' );
}

defaultproperties
{
     LabelHealingTool=(Text="Healing Tool",Style="NormalLabel")
     LabelBulldog=(Text="Bulldog",Style="NormalLabel")
     LabelFragRifle=(Text="Frag Rifle",Style="NormalLabel")
     LabelGrenadeLauncher=(Text="Grenade Launcher",Style="NormalLabel")
     LabelPlasmaGun=(Text="Plasma Gun",Style="NormalLabel")
     LabelSniperRifle=(Text="Sniper Rifle",Style="NormalLabel")
     LabelRocketLauncher=(Text="Rocket Launcher",Style="NormalLabel")
     LabelTitansFist=(Text="Titan's Fist",Style="NormalLabel")
     BindingHealingToolA=(Alias="IfInVehicle Nop ; ToggleHealingTool")
     BindingBulldogA=(Alias="SwitchWeapon 1")
     BindingFragRifleA=(Alias="SwitchWeapon 3")
     BindingGrenadeLauncherA=(Alias="SwitchWeapon 7")
     BindingPlasmaGunA=(Alias="SwitchWeapon 2")
     BindingSniperRifleA=(Alias="SwitchWeapon 8")
     BindingRocketLauncherA=(Alias="SwitchWeapon 4")
     BindingTitansFistA=(Alias="SwitchWeapon 6")
     BindingHealingToolB=(Alias="IfInVehicle Nop ; ToggleHealingTool",Priority=1)
     BindingBulldogB=(Alias="SwitchWeapon 1",Priority=1)
     BindingFragRifleB=(Alias="SwitchWeapon 3",Priority=1)
     BindingGrenadeLauncherB=(Alias="SwitchWeapon 7",Priority=1)
     BindingPlasmaGunB=(Alias="SwitchWeapon 2",Priority=1)
     BindingSniperRifleB=(Alias="SwitchWeapon 8",Priority=1)
     BindingRocketLauncherB=(Alias="SwitchWeapon 4",Priority=1)
     BindingTitansFistB=(Alias="SwitchWeapon 6",Priority=1)
     MenuTitle=(Text="Weapons")
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
