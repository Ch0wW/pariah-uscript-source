class MenuSettingsInternet extends MenuTemplateTitledBA;

var() MenuButtonEnum InternetConnectionEnum;
var() MenuButtonEnum GeographicLocationEnum;

var() MenuSliderArrow InternetConnectionDown;
var() MenuSliderArrow GeographicLocationDown;

var() MenuSliderArrow InternetConnectionUp;
var() MenuSliderArrow GeographicLocationUp;

var() int Speeds[4];

simulated function Init( String Args )
{    
    local PlayerController PC;
    local int ConfiguredInternetSpeed;

    Super.Init( Args );
    
    PC = PlayerController(Owner);
    
    if( PC.Player != None )
    {
        ConfiguredInternetSpeed = PC.Player.ConfiguredInternetSpeed;
    }
    else
    {
        ConfiguredInternetSpeed = class'Player'.default.ConfiguredInternetSpeed;
    }

    Assert( ArrayCount(Speeds) == InternetConnectionEnum.Items.Length );

    for( InternetConnectionEnum.Current = 0; InternetConnectionEnum.Current < (ArrayCount(Speeds) - 1); ++InternetConnectionEnum.Current )
    {
        if( Speeds[InternetConnectionEnum.Current + 1] > ConfiguredInternetSpeed )
        {
            break;
        }
    }
    
    GeographicLocationEnum.Current = int(class'GameEngine'.default.GeographicArea);
}

simulated function SaveSettings()
{
    local PlayerController PC;

    class'GameEngine'.default.GeographicArea = EGeographicArea(GeographicLocationEnum.Current);
    class'GameEngine'.static.StaticSaveConfig();
    
    PC = PlayerController(Owner);
    
    if( PC.Player != None )
    {
        PC.Player.ConfiguredInternetSpeed = Speeds[InternetConnectionEnum.Current];
        PC.Player.SaveConfig();
    }
    else
    {
        class'Player'.default.ConfiguredInternetSpeed = Speeds[InternetConnectionEnum.Current];
        class'Player'.static.StaticSaveConfig();
    }
}

simulated function HandleInputBack()
{
    SaveSettings();
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( InternetConnectionEnum, GeographicLocationEnum, 'SettingsItemLayout' );
    LayoutWidgets( InternetConnectionDown, GeographicLocationDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( InternetConnectionUp, GeographicLocationUp, 'SettingsRightArrowLayout' );    
}

defaultproperties
{
     InternetConnectionEnum=(Items=("Connection: Dialup Modem","Connection: ISDN","Connection: Cable Modem/DSL","Connection: LAN/T1"),Style="SettingsEnum")
     GeographicLocationEnum=(Items=("Location: North America","Location: South America","Location: Europe","Location: Central Asia","Location: Southeast Asia","Location: Africa","Location: Australia"),Style="SettingsEnum")
     InternetConnectionDown=(WidgetName="InternetConnectionEnum",Style="SettingsSliderLeft")
     GeographicLocationDown=(WidgetName="GeographicLocationEnum",Style="SettingsSliderLeft")
     InternetConnectionUp=(WidgetName="InternetConnectionEnum",Style="SettingsSliderRight")
     GeographicLocationUp=(WidgetName="GeographicLocationEnum",Style="SettingsSliderRight")
     Speeds(0)=3000
     Speeds(1)=5000
     Speeds(2)=10000
     Speeds(3)=15000
     APlatform=MWP_All
     AButtonHidden=1
     MenuTitle=(Text="Internet Settings")
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
