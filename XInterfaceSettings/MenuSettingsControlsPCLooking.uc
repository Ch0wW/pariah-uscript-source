class MenuSettingsControlsPCLooking extends MenuTemplateTitledB;

var() MenuText LabelLeft;
var() MenuText LabelRight;
var() MenuText LabelUp;
var() MenuText LabelDown;
var() MenuText LabelCenterView;

var() MenuBindingBox BindingLeftA;
var() MenuBindingBox BindingRightA;
var() MenuBindingBox BindingUpA;
var() MenuBindingBox BindingDownA;
var() MenuBindingBox BindingCenterViewA;

var() MenuBindingBox BindingLeftB;
var() MenuBindingBox BindingRightB;
var() MenuBindingBox BindingUpB;
var() MenuBindingBox BindingDownB;
var() MenuBindingBox BindingCenterViewB;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( LabelLeft, LabelCenterView, 'BindingLabelLayout' );
    LayoutWidgets( BindingLeftA, BindingCenterViewA, 'BindingBoxLayoutA' );
    LayoutWidgets( BindingLeftB, BindingCenterViewB, 'BindingBoxLayoutB' );
}

defaultproperties
{
     LabelLeft=(Text="Left",Style="NormalLabel")
     LabelRight=(Text="Right",Style="NormalLabel")
     LabelUp=(Text="Up",Style="NormalLabel")
     LabelDown=(Text="Down",Style="NormalLabel")
     LabelCenterView=(Text="Center View",Style="NormalLabel")
     BindingLeftA=(Alias="TurnLeft")
     BindingRightA=(Alias="TurnRight")
     BindingUpA=(Alias="LookUp")
     BindingDownA=(Alias="LookDown")
     BindingCenterViewA=(Alias="CenterView")
     BindingLeftB=(Alias="TurnLeft",Priority=1)
     BindingRightB=(Alias="TurnRight",Priority=1)
     BindingUpB=(Alias="LookUp",Priority=1)
     BindingDownB=(Alias="LookDown",Priority=1)
     BindingCenterViewB=(Alias="CenterView",Priority=1)
     MenuTitle=(Text="Looking")
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
