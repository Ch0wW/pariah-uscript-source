class MenuInternetAdvancedOptionsA extends MenuTemplateTitledBXA;

var() MenuToggle ShowEmptyGamesToggle;
var() MenuButtonEnum PrivateGamesEnum;
var() MenuToggle ShowOnlyDedicatedServersToggle;
var() MenuToggle ShowGamesWithBotsToggle;
var() MenuButtonEnum FriendlyFireEnum;
var() MenuButtonEnum InitialWecsEnum;

var() MenuSliderArrow ShowEmptyGamesDown;
var() MenuSliderArrow PrivateGamesDown;
var() MenuSliderArrow ShowOnlyDedicatedServersDown;
var() MenuSliderArrow ShowGamesWithBotsDown;
var() MenuSliderArrow FriendlyFireDown;
var() MenuSliderArrow InitialWecsDown;

var() MenuSliderArrow ShowEmptyGamesUp;
var() MenuSliderArrow PrivateGamesUp;
var() MenuSliderArrow ShowOnlyDedicatedServersUp;
var() MenuSliderArrow ShowGamesWithBotsUp;
var() MenuSliderArrow FriendlyFireUp;
var() MenuSliderArrow InitialWecsUp;

simulated function Init( String Args )
{
    Super.Init( Args );
 
    if( class'MenuInternetAdvancedSearch'.default.MinPlayers > 0 )
    {
        ShowEmptyGamesToggle.bValue = 0;
    }
    else
    {
        ShowEmptyGamesToggle.bValue = 1;
    }
    
    PrivateGamesEnum.Current = int( class'MenuInternetAdvancedSearch'.default.PrivateGames );
    ShowOnlyDedicatedServersToggle.bValue = int( class'MenuInternetAdvancedSearch'.default.ShowOnlyDedicatedServers );
    ShowGamesWithBotsToggle.bValue = int( class'MenuInternetAdvancedSearch'.default.ShowGamesWithBots );
    FriendlyFireEnum.Current = int( class'MenuInternetAdvancedSearch'.default.FriendlyFire );
    InitialWecsEnum.Current = int( class'MenuInternetAdvancedSearch'.default.InitialWecs );
}

simulated function SaveOptions()
{
    if( ShowEmptyGamesToggle.bValue == 0 )
    {
        if( class'MenuInternetAdvancedSearch'.default.MinPlayers == 0 )
        {
            class'MenuInternetAdvancedSearch'.default.MinPlayers = 1;
        }
    }
    else
    {
        class'MenuInternetAdvancedSearch'.default.MinPlayers = 0;
    }

    class'MenuInternetAdvancedSearch'.default.PrivateGames = Trinary( PrivateGamesEnum.Current );
    class'MenuInternetAdvancedSearch'.default.ShowOnlyDedicatedServers = bool( ShowOnlyDedicatedServersToggle.bValue );
    class'MenuInternetAdvancedSearch'.default.ShowGamesWithBots = bool( ShowGamesWithBotsToggle.bValue );
    class'MenuInternetAdvancedSearch'.default.FriendlyFire = Trinary( FriendlyFireEnum.Current );
    class'MenuInternetAdvancedSearch'.default.InitialWecs = Trinary( InitialWecsEnum.Current );
    class'MenuInternetAdvancedSearch'.static.StaticSaveConfig();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( ShowEmptyGamesToggle, InitialWecsEnum, 'SettingsItemLayout' );
    LayoutWidgets( ShowEmptyGamesDown, InitialWecsDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( ShowEmptyGamesUp, InitialWecsUp, 'SettingsRightArrowLayout' );    
}

simulated function HandleInputBack()
{
    SaveOptions();
    GotoMenuClass("XInterfaceMP.MenuInternetAdvancedSearch");
}

simulated function OnAButton()
{
    SaveOptions();
    class'MenuInternetAdvancedSearch'.static.StartQuery(self, SLM_AdvancedSearchA);
}

simulated function OnXButton()
{
    SaveOptions();
    GotoMenuClass("XInterfaceMP.MenuInternetAdvancedOptionsB");
}

defaultproperties
{
     ShowEmptyGamesToggle=(TextOff="Empty Games: No",TextOn="Empty Games: Don't care",Style="SettingsToggle")
     PrivateGamesEnum=(Items=("Private Games: No","Private Games: Yes","Private Games: Don't care"),Style="SettingsEnum")
     ShowOnlyDedicatedServersToggle=(TextOff="Only Dedicated Servers: Don't care",TextOn="Only Dedicated Servers: Yes",Style="SettingsToggle")
     ShowGamesWithBotsToggle=(TextOff="Games with Bots: No",TextOn="Games with Bots: Don't care",Style="SettingsToggle")
     FriendlyFireEnum=(Items=("Friendly Fire: No","Friendly Fire: Yes","Friendly Fire: Don't care"),Style="SettingsEnum")
     InitialWecsEnum=(Items=("Initial WECs: No","Initial WECs: Yes","Initial WECs: Don't care"),Style="SettingsEnum")
     ShowEmptyGamesDown=(WidgetName="ShowEmptyGamesToggle",Style="SettingsSliderLeft")
     PrivateGamesDown=(WidgetName="PrivateGamesEnum",Style="SettingsSliderLeft")
     ShowOnlyDedicatedServersDown=(WidgetName="ShowOnlyDedicatedServersToggle",Style="SettingsSliderLeft")
     ShowGamesWithBotsDown=(WidgetName="ShowGamesWithBotsToggle",Style="SettingsSliderLeft")
     FriendlyFireDown=(WidgetName="FriendlyFireEnum",Style="SettingsSliderLeft")
     InitialWecsDown=(WidgetName="InitialWecsEnum",Style="SettingsSliderLeft")
     ShowEmptyGamesUp=(WidgetName="ShowEmptyGamesToggle",Style="SettingsSliderRight")
     PrivateGamesUp=(WidgetName="PrivateGamesEnum",Style="SettingsSliderRight")
     ShowOnlyDedicatedServersUp=(WidgetName="ShowOnlyDedicatedServersToggle",Style="SettingsSliderRight")
     ShowGamesWithBotsUp=(WidgetName="ShowGamesWithBotsToggle",Style="SettingsSliderRight")
     FriendlyFireUp=(WidgetName="FriendlyFireEnum",Style="SettingsSliderRight")
     InitialWecsUp=(WidgetName="InitialWecsEnum",Style="SettingsSliderRight")
     ALabel=(Text="Search")
     APlatform=MWP_All
     XLabel=(Text="More Options")
     MenuTitle=(Text="Advanced Search")
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
