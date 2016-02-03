class MenuSettingsControlsPCCombat extends MenuTemplateTitledB;

var() MenuText LabelFire;
var() MenuText LabelZoom;
var() MenuText LabelBonesaw;
var() MenuText LabelReload;
var() MenuText LabelNextWeapon;
var() MenuText LabelPreviousWeapon;
var() MenuText LabelWeaponMenu;

var() MenuBindingBox BindingFireA;
var() MenuBindingBox BindingZoomA;
var() MenuBindingBox BindingBonesawA;
var() MenuBindingBox BindingReloadA;
var() MenuBindingBox BindingNextWeaponA;
var() MenuBindingBox BindingPreviousWeaponA;
var() MenuBindingBox BindingWeaponMenuA;

var() MenuBindingBox BindingFireB;
var() MenuBindingBox BindingZoomB;
var() MenuBindingBox BindingBonesawB;
var() MenuBindingBox BindingReloadB;
var() MenuBindingBox BindingNextWeaponB;
var() MenuBindingBox BindingPreviousWeaponB;
var() MenuBindingBox BindingWeaponMenuB;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( LabelFire, LabelWeaponMenu, 'BindingLabelLayout' );
    LayoutWidgets( BindingFireA, BindingWeaponMenuA, 'BindingBoxLayoutA' );
    LayoutWidgets( BindingFireB, BindingWeaponMenuB, 'BindingBoxLayoutB' );
}

defaultproperties
{
     LabelFire=(Text="Fire",Style="NormalLabel")
     LabelZoom=(Text="Zoom",Style="NormalLabel")
     LabelBonesaw=(Text="Bonesaw",Style="NormalLabel")
     LabelReload=(Text="Reload",Style="NormalLabel")
     LabelNextWeapon=(Text="Next Weapon",Style="NormalLabel")
     LabelPreviousWeapon=(Text="Previous Weapon",Style="NormalLabel")
     LabelWeaponMenu=(Text="Weapon Menu",Style="NormalLabel")
     BindingFireA=(Alias="Fire")
     BindingZoomA=(Alias="Zoom")
     BindingBonesawA=(Alias="IfInVehicle AltFire ; Melee | OnRelease AltFire")
     BindingReloadA=(Alias="ReloadWeapon")
     BindingNextWeaponA=(Alias="NextWeapon")
     BindingPreviousWeaponA=(Alias="PrevWeapon")
     BindingWeaponMenuA=(Alias="ShowWeaponMenu")
     BindingFireB=(Alias="Fire",Priority=1)
     BindingZoomB=(Alias="Zoom",Priority=1)
     BindingBonesawB=(Alias="IfInVehicle AltFire ; Melee | OnRelease AltFire",Priority=1)
     BindingReloadB=(Alias="ReloadWeapon",Priority=1)
     BindingNextWeaponB=(Alias="NextWeapon",Priority=1)
     BindingPreviousWeaponB=(Alias="PrevWeapon",Priority=1)
     BindingWeaponMenuB=(Alias="ShowWeaponMenu",Priority=1)
     MenuTitle=(Text="Combat")
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
