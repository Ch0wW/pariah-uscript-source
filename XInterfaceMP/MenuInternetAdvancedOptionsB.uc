class MenuInternetAdvancedOptionsB extends MenuTemplateTitledBA;

var() MenuSlider MinOpenSlotsSlider;
var() MenuSlider MaxPlayersSlider;
var() MenuSlider MinPlayersSlider;
var() MenuSlider MaxPingSlider;

var() MenuSliderArrow MinOpenSlotsDown;
var() MenuSliderArrow MaxPlayersDown;
var() MenuSliderArrow MinPlayersDown;
var() MenuSliderArrow MaxPingDown;

var() MenuSliderArrow MinOpenSlotsUp;
var() MenuSliderArrow MaxPlayersUp;
var() MenuSliderArrow MinPlayersUp;
var() MenuSliderArrow MaxPingUp;

simulated function Init( String Args )
{
    Super.Init( Args );
 
    MinOpenSlotsSlider.Value = class'MenuInternetAdvancedSearch'.default.MinOpenSlots;
    MaxPlayersSlider.Value = class'MenuInternetAdvancedSearch'.default.MaxPlayers;
    MinPlayersSlider.Value = class'MenuInternetAdvancedSearch'.default.MinPlayers;
    MaxPingSlider.Value = class'MenuInternetAdvancedSearch'.default.MaxPing;

    UpdateOpenSlots();
    UpdatePlayersText();
    UpdateMaxPing();
}

simulated function SaveOptions()
{
    class'MenuInternetAdvancedSearch'.default.MinOpenSlots = MinOpenSlotsSlider.Value;
    class'MenuInternetAdvancedSearch'.default.MaxPlayers = MaxPlayersSlider.Value;
    class'MenuInternetAdvancedSearch'.default.MinPlayers = MinPlayersSlider.Value;
    class'MenuInternetAdvancedSearch'.default.MaxPing = MaxPingSlider.Value;

    class'MenuInternetAdvancedSearch'.static.StaticSaveConfig();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( MinOpenSlotsSlider, MaxPingSlider, 'SettingsItemLayout' );
    LayoutWidgets( MinOpenSlotsDown, MaxPingDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( MinOpenSlotsUp, MaxPingUp, 'SettingsRightArrowLayout' );    
}

simulated function HandleInputBack()
{
    SaveOptions();
    GotoMenuClass("XInterfaceMP.MenuInternetAdvancedOptionsA");
}

simulated function OnAButton()
{
    SaveOptions();
    class'MenuInternetAdvancedSearch'.static.StartQuery(self, SLM_AdvancedSearchB);
}

simulated function UpdateOpenSlots()
{
    MinOpenSlotsSlider.Blurred.Text = default.MinOpenSlotsSlider.Blurred.Text @ int( MinOpenSlotsSlider.Value );
    MinOpenSlotsSlider.Focused.Text = MinOpenSlotsSlider.Blurred.Text;
}

simulated function UpdatePlayersText()
{
    MinPlayersSlider.Blurred.Text = default.MinPlayersSlider.Blurred.Text @ int( MinPlayersSlider.Value );
    MinPlayersSlider.Focused.Text = MinPlayersSlider.Blurred.Text;

    MaxPlayersSlider.Blurred.Text = default.MaxPlayersSlider.Blurred.Text @ int( MaxPlayersSlider.Value );
    MaxPlayersSlider.Focused.Text = MaxPlayersSlider.Blurred.Text;
}

simulated function UpdateMinPlayers()
{
    MaxPlayersSlider.Value = Max( MinPlayersSlider.Value, MaxPlayersSlider.Value );
    UpdatePlayersText();
}

simulated function UpdateMaxPlayers()
{
    MaxPlayersSlider.Value = Max( MaxPlayersSlider.Value, 1 );
    MinPlayersSlider.Value = Min( MinPlayersSlider.Value, MaxPlayersSlider.Value );
    UpdatePlayersText();
}

simulated function UpdateMaxPing()
{
    MaxPingSlider.Blurred.Text = default.MaxPingSlider.Blurred.Text @ int( MaxPingSlider.Value );
    MaxPingSlider.Focused.Text = MaxPingSlider.Blurred.Text;
}

defaultproperties
{
     MinOpenSlotsSlider=(MaxValue=32.000000,Delta=1.000000,OnSlide="UpdateOpenSlots",Blurred=(Text="Min Open Slots:"),Style="SettingsSlider")
     MaxPlayersSlider=(MaxValue=32.000000,Delta=1.000000,OnSlide="UpdateMaxPlayers",Blurred=(Text="Max players:"),Style="SettingsSlider")
     MinPlayersSlider=(MaxValue=32.000000,Delta=1.000000,OnSlide="UpdateMinPlayers",Blurred=(Text="Min players:"),Style="SettingsSlider")
     MaxPingSlider=(MinValue=25.000000,MaxValue=500.000000,Delta=25.000000,OnSlide="UpdateMaxPing",Blurred=(Text="Max Ping:"),Style="SettingsSlider")
     MinOpenSlotsDown=(WidgetName="MinOpenSlotsSlider",Style="SettingsSliderLeft")
     MaxPlayersDown=(WidgetName="MaxPlayersSlider",Style="SettingsSliderLeft")
     MinPlayersDown=(WidgetName="MinPlayersSlider",Style="SettingsSliderLeft")
     MaxPingDown=(WidgetName="MaxPingSlider",Style="SettingsSliderLeft")
     MinOpenSlotsUp=(WidgetName="MinOpenSlotsSlider",Style="SettingsSliderRight")
     MaxPlayersUp=(WidgetName="MaxPlayersSlider",Style="SettingsSliderRight")
     MinPlayersUp=(WidgetName="MinPlayersSlider",Style="SettingsSliderRight")
     MaxPingUp=(WidgetName="MaxPingSlider",Style="SettingsSliderRight")
     ALabel=(Text="Search")
     APlatform=MWP_All
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
