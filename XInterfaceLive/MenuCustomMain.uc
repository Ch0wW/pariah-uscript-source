class MenuCustomMain extends MenuTemplateTitledBA;

// TODO: Sex me up!

var() MenuButtonText Options[4];

simulated function Init( String Args )
{
    Super.Init( Args );
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated function OnOfficialMaps()
{
    CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE OFFICIAL");
}

simulated function OnLiveMaps()
{
    CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE SELF");
}

simulated function OnOfflineMaps()
{
    // TODO: CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE SELF");
}

simulated function OnFriendsMaps()
{
    // TODO: CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE SELF");
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Official Maps",PosX=0.145000),OnSelect="OnOfficialMaps",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Xbox Live Maps"),OnSelect="OnLiveMaps")
     Options(2)=(Blurred=(Text="Offline Maps"),OnSelect="OnOfflineMaps",bHidden=1)
     Options(3)=(Blurred=(Text="Friends Maps"),OnSelect="OnFriendsMaps",bHidden=1)
     MenuTitle=(Text="Custom Maps")
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
