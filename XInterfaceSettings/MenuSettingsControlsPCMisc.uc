class MenuSettingsControlsPCMisc extends MenuTemplateTitledB;

var() MenuText LabelUse;
var() MenuText LabelShowObjectives;
var() MenuText LabelShowMenu;
var() MenuText LabelSay;
var() MenuText LabelTeamSay;
var() MenuText LabelType;
var() MenuText LabelConsole;

var() MenuBindingBox BindingUseA;
var() MenuBindingBox BindingShowObjectivesA;
var() MenuBindingBox BindingShowMenuA;
var() MenuBindingBox BindingSayA;
var() MenuBindingBox BindingTeamSayA;
var() MenuBindingBox BindingTypeA;
var() MenuBindingBox BindingConsoleA;

var() MenuBindingBox BindingUseB;
var() MenuBindingBox BindingShowObjectivesB;
var() MenuBindingBox BindingShowMenuB;
var() MenuBindingBox BindingSayB;
var() MenuBindingBox BindingTeamSayB;
var() MenuBindingBox BindingTypeB;
var() MenuBindingBox BindingConsoleB;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( LabelUse, LabelConsole, 'BindingLabelLayout' );
    LayoutWidgets( BindingUseA, BindingConsoleA, 'BindingBoxLayoutA' );
    LayoutWidgets( BindingUseB, BindingConsoleB, 'BindingBoxLayoutB' );
}

defaultproperties
{
     LabelUse=(Text="Use",Style="NormalLabel")
     LabelShowObjectives=(Text="Show Objectives",Style="NormalLabel")
     LabelShowMenu=(Text="Show Menu",Style="NormalLabel")
     LabelSay=(Text="Say",Style="NormalLabel")
     LabelTeamSay=(Text="Team Say",Style="NormalLabel")
     LabelType=(Text="Quick Console",Style="NormalLabel")
     LabelConsole=(Text="Console",Style="NormalLabel")
     BindingUseA=(Alias="ExitVehicleOr EnterVehicleOr Use")
     BindingShowObjectivesA=(Alias="ShowObjectivesOr ShowScores | OnRelease ShowObjectivesOr HideScores")
     BindingShowMenuA=(Alias="ShowMenu")
     BindingSayA=(Alias="Talk")
     BindingTeamSayA=(Alias="TeamTalk")
     BindingTypeA=(Alias="Type")
     BindingConsoleA=(Alias="ConsoleToggle")
     BindingUseB=(Alias="ExitVehicleOr EnterVehicleOr Use",Priority=1)
     BindingShowObjectivesB=(Alias="ShowObjectivesOr ShowScores | OnRelease ShowObjectivesOr HideScores",Priority=1)
     BindingShowMenuB=(Alias="ShowMenu",Priority=1)
     BindingSayB=(Alias="Talk",Priority=1)
     BindingTeamSayB=(Alias="TeamTalk",Priority=1)
     BindingTypeB=(Alias="Type",Priority=1)
     BindingConsoleB=(Alias="ConsoleToggle",Priority=1)
     MenuTitle=(Text="Miscellaneous")
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
