class MenuHostServerSettings extends MenuTemplateTitledB;

var MenuHostMain HostMain;

var() MenuToggle DedicatedServerToggle;
var() MenuSlider MaxPlayersSlider;
var() MenuSlider PrivateSlotsSlider;
var() MenuButtonEnum BotsEnum;

var() MenuSliderArrow DedicatedServerDown;
var() MenuSliderArrow MaxPlayersDown;
var() MenuSliderArrow PrivateSlotsDown;
var() MenuSliderArrow BotsDown;

var() MenuSliderArrow DedicatedServerUp;
var() MenuSliderArrow MaxPlayersUp;
var() MenuSliderArrow PrivateSlotsUp;
var() MenuSliderArrow BotsUp;

var() localized String StringBots;

simulated function Init( String Args )
{
    local int i;
    
    Super.Init( Args );
    
    HostMain = MenuHostMain(PreviousMenu);
    Assert( HostMain != None );
    
    DedicatedServerToggle.bValue = HostMain.ServerSettings.bDedicatedServer;
    
    MaxPlayersSlider.Value = HostMain.ServerSettings.MaxPlayers;
    PrivateSlotsSlider.Value = HostMain.ServerSettings.PrivateSlots;
    
    if( !HostMain.HostingLive() )
    {
        PrivateSlotsSlider.bHidden = 1;
        PrivateSlotsDown.bHidden = 1;
        PrivateSlotsUp.bHidden = 1;
    }
    
    BotsEnum.Items[0] = StringBots $ ":" @ StringNone;
    
    for( i = 0 ; i < class'GameInfo'.static.GetNumDifficultyLevels(); ++i )
    {
        BotsEnum.Items[i + 1] = StringBots $ ":" @ class'GameInfo'.static.GetDifficultyName(i);
    }
    
    if( HostMain.ServerSettings.bEnableBots == 0 )
    {
        BotsEnum.Current = 0;
    }
    else
    {
        BotsEnum.Current = 1 + class'GameInfo'.static.GetDifficultyLevelIndex( HostMain.ServerSettings.Difficulty );
    }

    if( HostMain.HostingCustom() )
    {
        BotsEnum.bHidden = 1;
        BotsDown.bHidden = 1;
        BotsUp.bHidden = 1;
    }
        
    UpdateDedicatedServer();
    UpdateMaxPlayers();
    UpdatePrivateSlots();
    UpdateBots();
}

simulated function HandleInputBack()
{
    HostMain.Refresh();
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( DedicatedServerToggle, BotsEnum, 'SettingsItemLayout' );
    LayoutWidgets( DedicatedServerDown, BotsDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( DedicatedServerUp, BotsUp, 'SettingsRightArrowLayout' );
}

simulated exec function Pork()
{
    HostMain.WarnedMaxBandwidth = false;
    HostMain.MaxBandwidthPlayers = 1;
    ConfirmBandwidthOverride();
}

simulated function UpdateDedicatedServer()
{
    HostMain.ServerSettings.bDedicatedServer = DedicatedServerToggle.bValue;

    if( bool(DedicatedServerToggle.bValue) )
    {
        MaxPlayersSlider.MaxValue = HostMain.GameSettings[HostMain.GameTypeIndex].GameTypeRecord.MaxPlayersOnDedicated;

        if( HostMain.HostingLive() )
        {
            PrivateSlotsSlider.bHidden = 1;
            PrivateSlotsDown.bHidden = 1;
            PrivateSlotsUp.bHidden = 1;
            bDynamicLayoutDirty = true;
        }
    }
    else
    {
        MaxPlayersSlider.MaxValue = HostMain.GameSettings[HostMain.GameTypeIndex].GameTypeRecord.MaxPlayersOnListen;
        MaxPlayersSlider.Value = Min(MaxPlayersSlider.Value, MaxPlayersSlider.MaxValue );
        UpdateMaxPlayers();

        if( HostMain.HostingLive() )
        {
            PrivateSlotsSlider.bHidden = 0;
            PrivateSlotsDown.bHidden = 0;
            PrivateSlotsUp.bHidden = 0;
            bDynamicLayoutDirty = true;
        }
    }
}

simulated function ConfirmBandwidthOverride()
{
    if( HostMain.WarnedMaxBandwidth || (MaxPlayersSlider.Value <= HostMain.MaxBandwidthPlayers) )
    {
        return;
    }
    
    CallMenuClass
    (
        "XInterface.MenuQuestionYesNo",
        MakeQuotedString(HostMain.BandwidthWarningText) @ MakeQuotedString(HostMain.BandwidthWarningTitle)
    );
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    local MenuQuestionYesNo Question;

    Question = MenuQuestionYesNo( ClosingMenu );
    
    if( Question != None )
    {
        if( Question.bSelectedYes )
        {
            HostMain.WarnedMaxBandwidth = true;
            class'MenuHostMain'.default.WarnedMaxBandwidth = true; // so it only happens once per session
        }
        else
        {
            MaxPlayersSlider.Value = HostMain.MaxBandwidthPlayers;
            UpdateMaxPlayers();
        }
        return(true);
    }
    
    return(false);
}

simulated function UpdateMaxPlayers()
{
    ConfirmBandwidthOverride();

    HostMain.ServerSettings.MaxPlayers = int( MaxPlayersSlider.Value );

    MaxPlayersSlider.Blurred.Text = default.MaxPlayersSlider.Blurred.Text $ ": " @ HostMain.ServerSettings.MaxPlayers;
    MaxPlayersSlider.Focused.Text = MaxPlayersSlider.Blurred.Text;
    
    PrivateSlotsSlider.MaxValue = MaxPlayersSlider.Value;
    PrivateSlotsSlider.Value = Min( PrivateSlotsSlider.Value, PrivateSlotsSlider.MaxValue );
    UpdatePrivateSlots();
}

simulated function UpdatePrivateSlots()
{
    HostMain.ServerSettings.PrivateSlots = int( PrivateSlotsSlider.Value );
    
    PrivateSlotsSlider.Blurred.Text = default.PrivateSlotsSlider.Blurred.Text $ ": " @ HostMain.ServerSettings.PrivateSlots;
    PrivateSlotsSlider.Focused.Text = PrivateSlotsSlider.Blurred.Text;
}

simulated function UpdateBots()
{
    if( BotsEnum.Current == 0 )
    {
        HostMain.ServerSettings.bEnableBots = 0;
    }
    else
    {
        HostMain.ServerSettings.bEnableBots = 1;
        HostMain.ServerSettings.Difficulty = class'GameInfo'.static.GetDifficultyLevel( BotsEnum.Current - 1 );
    }
}

defaultproperties
{
     DedicatedServerToggle=(TextOff="Dedicated Server: No",TextOn="Dedicated Server: Yes",OnToggle="UpdateDedicatedServer",Style="SettingsToggle")
     MaxPlayersSlider=(MinValue=2.000000,MaxValue=16.000000,Delta=1.000000,OnSlide="UpdateMaxPlayers",Blurred=(Text="Max Players"),Style="SettingsSlider")
     PrivateSlotsSlider=(MaxValue=8.000000,Delta=1.000000,OnSlide="UpdatePrivateSlots",Blurred=(Text="Private Slots"),Style="SettingsSlider")
     BotsEnum=(bNoWrap=1,OnChange="UpdateBots",Style="SettingsEnum")
     DedicatedServerDown=(WidgetName="DedicatedServerToggle",Style="SettingsSliderLeft")
     MaxPlayersDown=(WidgetName="MaxPlayersSlider",Style="SettingsSliderLeft")
     PrivateSlotsDown=(WidgetName="PrivateSlotsSlider",Style="SettingsSliderLeft")
     BotsDown=(WidgetName="BotsEnum",Style="SettingsSliderLeft")
     DedicatedServerUp=(WidgetName="DedicatedServerToggle",Style="SettingsSliderRight")
     MaxPlayersUp=(WidgetName="MaxPlayersSlider",Style="SettingsSliderRight")
     PrivateSlotsUp=(WidgetName="PrivateSlotsSlider",Style="SettingsSliderRight")
     BotsUp=(WidgetName="BotsEnum",Style="SettingsSliderRight")
     StringBots="Bots"
     MenuTitle=(Text="Server Settings")
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
