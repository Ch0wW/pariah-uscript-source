class MenuMiniEdLive extends MenuTemplateTitledBA;

var() MenuButtonText Options[3];

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );

    SetVisible( 'OnPublishMap', !bool( ConsoleCommand("XLIVE DENY_CUSTOM_CONTENT") ) );
}

simulated function HandleInputBack()
{
    GotoMenuClass("MiniEd.MenuMiniEdMain");
}

simulated function OnPublishMap()
{
    CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE SELF");
}

simulated function OnFriends()
{
    CallMenuClass("XInterfaceLive.MenuFriendList");
}

simulated function OnSignOut()
{
    GotoMenuClass("XInterfaceLive.MenuLiveSignOut");
}

simulated event bool IsLiveMenu()
{
    return(true);
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Publish Maps"),OnSelect="OnPublishMap",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Friends"),OnSelect="OnFriends")
     Options(2)=(Blurred=(Text="Sign out"),OnSelect="OnSignOut")
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
