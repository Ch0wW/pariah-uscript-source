class MenuSettingsControlsPCMovement extends MenuTemplateTitledB;

var() MenuText LabelForward;
var() MenuText LabelBackward;
var() MenuText LabelLeft;
var() MenuText LabelRight;
var() MenuText LabelJump;
var() MenuText LabelDuck;
var() MenuText LabelDash;
var() MenuText LabelStrafe;

var() MenuBindingBox BindingForwardA;
var() MenuBindingBox BindingBackwardA;
var() MenuBindingBox BindingLeftA;
var() MenuBindingBox BindingRightA;
var() MenuBindingBox BindingJumpA;
var() MenuBindingBox BindingDuckA;
var() MenuBindingBox BindingDashA;
var() MenuBindingBox BindingStrafeA;

var() MenuBindingBox BindingForwardB;
var() MenuBindingBox BindingBackwardB;
var() MenuBindingBox BindingLeftB;
var() MenuBindingBox BindingRightB;
var() MenuBindingBox BindingJumpB;
var() MenuBindingBox BindingDuckB;
var() MenuBindingBox BindingDashB;
var() MenuBindingBox BindingStrafeB;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( LabelForward, LabelStrafe, 'BindingLabelLayout' );
    LayoutWidgets( BindingForwardA, BindingStrafeA, 'BindingBoxLayoutA' );
    LayoutWidgets( BindingForwardB, BindingStrafeB, 'BindingBoxLayoutB' );
}

defaultproperties
{
     LabelForward=(Text="Forward",Style="NormalLabel")
     LabelBackward=(Text="Backward",Style="NormalLabel")
     LabelLeft=(Text="Left",Style="NormalLabel")
     LabelRight=(Text="Right",Style="NormalLabel")
     LabelJump=(Text="Jump",Style="NormalLabel")
     LabelDuck=(Text="Duck",Style="NormalLabel")
     LabelDash=(Text="Dash",Style="NormalLabel")
     LabelStrafe=(Text="Strafe",Style="NormalLabel")
     BindingForwardA=(Alias="MoveForward | DriveForward")
     BindingBackwardA=(Alias="MoveBackward | DriveBackward")
     BindingLeftA=(Alias="StrafeLeft")
     BindingRightA=(Alias="StrafeRight")
     BindingJumpA=(Alias="Jump")
     BindingDuckA=(Alias="Duck")
     BindingDashA=(Alias="IfInVehicle HandBrake ; Dash | OnRelease HandBrake")
     BindingStrafeA=(Alias="Strafe")
     BindingForwardB=(Alias="MoveForward | DriveForward",Priority=1)
     BindingBackwardB=(Alias="MoveBackward | DriveBackward",Priority=1)
     BindingLeftB=(Alias="StrafeLeft",Priority=1)
     BindingRightB=(Alias="StrafeRight",Priority=1)
     BindingJumpB=(Alias="Jump",Priority=1)
     BindingDuckB=(Alias="Duck",Priority=1)
     BindingDashB=(Alias="IfInVehicle HandBrake ; Dash | OnRelease HandBrake",Priority=1)
     BindingStrafeB=(Alias="Strafe",Priority=1)
     MenuTitle=(Text="Movement")
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
