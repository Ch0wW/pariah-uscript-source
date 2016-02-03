class MenuLiveSettings extends MenuTemplateTitledB;

var() MenuToggle AppearOnlineToggle;
var() MenuSliderArrow AppearOnlineDown;
var() MenuSliderArrow AppearOnlineUp;

simulated function Init( String Args )
{
    local PlayerController PC;

    Super.Init( Args );

    PC = PlayerController( Owner );
    
    AppearOnlineToggle.bValue = PC.OnlineStatus;
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( AppearOnlineToggle, AppearOnlineToggle, 'SettingsItemLayout' );
    LayoutWidgets( AppearOnlineDown, AppearOnlineDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( AppearOnlineUp, AppearOnlineUp, 'SettingsRightArrowLayout' );    
}

simulated function HandleInputBack()
{
    local PlayerController PC;
    PC = PlayerController(Owner);

    PC.OnlineStatus = AppearOnlineToggle.bValue;

    Super.HandleInputBack();
}

simulated event bool IsLiveMenu()
{
    return(false);
}

defaultproperties
{
     AppearOnlineToggle=(TextOff="Appear Offline",TextOn="Appear Online",Style="SettingsToggle")
     AppearOnlineDown=(WidgetName="AppearOnlineToggle",Style="SettingsSliderLeft")
     AppearOnlineUp=(WidgetName="AppearOnlineToggle",Style="SettingsSliderRight")
     MenuTitle=(Text="Xbox Live Settings")
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
