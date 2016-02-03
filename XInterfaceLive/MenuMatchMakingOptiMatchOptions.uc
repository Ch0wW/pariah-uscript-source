class MenuMatchMakingOptiMatchOptions extends MenuTemplateTitledBA
    config;

var() MenuSlider MinPlayersSlider;
var() MenuSlider MaxPlayersSlider;
var() MenuButtonEnum DedicatedOnlyEnum;
var() MenuButtonEnum MatchSkillEnum;

var() MenuSliderArrow MinPlayersDown;
var() MenuSliderArrow MaxPlayersDown;
var() MenuSliderArrow DedicatedOnlyDown;
var() MenuSliderArrow MatchSkillDown;

var() MenuSliderArrow MinPlayersUp;
var() MenuSliderArrow MaxPlayersUp;
var() MenuSliderArrow DedicatedOnlyUp;
var() MenuSliderArrow MatchSkillUp;

var() config String GameTypeName;
var() config int MinPlayers, MaxPlayers, MatchSkill, DedicatedOnly;

enum EMapClassFilter
{
    MCF_All,
    MCF_NormalOnly,
    MCF_CustomOnly
};

var() config EMapClassFilter MapClassFilter;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    MinPlayersSlider.Value = MinPlayers;
    MaxPlayersSlider.Value = Min( MaxPlayersSlider.MaxValue, MaxPlayers );

    DedicatedOnlyEnum.Current = DedicatedOnly;
    MatchSkillEnum.Current = MatchSkill;
    
    UpdatePlayersText();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( MinPlayersSlider, MatchSkillEnum, 'SettingsItemLayout' );
    LayoutWidgets( MinPlayersDown, MatchSkillDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( MinPlayersUp, MatchSkillUp, 'SettingsRightArrowLayout' );    
}

simulated function SaveOptions()
{
    MinPlayers = int(MinPlayersSlider.Value);
    MaxPlayers = int(MaxPlayersSlider.Value);
    DedicatedOnly = DedicatedOnlyEnum.Current;
    MatchSkill = MatchSkillEnum.Current;

    SaveConfig();
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

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function OnAButton()
{
    local int MinSkill, MaxSkill;
    local PlayerController PC;
    local int MinCustomMap;
    local int MaxCustomMap;

    PC = PlayerController( Owner );

    SaveOptions();

    switch( MatchSkill )
    {
        case 0:
            MinSkill = 0;
            MaxSkill = 100;
            break;
            
        case 1:
            MinSkill = PC.Skill - 25;
            MaxSkill = PC.Skill + 25;
            break;
        
        case 2:
            MinSkill = PC.Skill - 10;
            MaxSkill = PC.Skill + 10;
            break;
    }    
    
    MinSkill = Max( MinSkill, 0 );    
    MaxSkill = Min( MaxSkill, 100 );    

    switch( MapClassFilter )
    {
        case MCF_All:
            MinCustomMap = 0;
            MaxCustomMap = 1;
            break;
            
        case MCF_NormalOnly:
            MinCustomMap = 0;
            MaxCustomMap = 0;
            break;
            
        case MCF_CustomOnly:
            MinCustomMap = 1;
            MaxCustomMap = 1;
            break;
    }
    
    GotoMenuClass
    (
        "XInterfaceLive.MenuMatchMakingAvailableMatches", 
        GameTypeName @
        MinPlayers @
        MaxPlayers @
        MinSkill @
        MaxSkill @
        DedicatedOnly @
        MinCustomMap @
        MaxCustomMap
    );
}


simulated exec function Pork()
{
    OnAButton();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    
    return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function HandleInputBack()
{
    SaveOptions();
    
    if( MapClassFilter == MCF_All )
    {
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatch");
    }
    else
    {
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchGameType", "");
    }
}

defaultproperties
{
     MinPlayersSlider=(MaxValue=16.000000,Delta=1.000000,OnSlide="UpdateMinPlayers",Blurred=(Text="Min players:"),HelpText="Minimum players in the match",Style="SettingsSlider")
     MaxPlayersSlider=(MaxValue=16.000000,Delta=1.000000,OnSlide="UpdateMaxPlayers",Blurred=(Text="Max players:"),HelpText="Maximum players in the match",Style="SettingsSlider")
     DedicatedOnlyEnum=(Items=("All Hosts","Only Dedicated Hosts"),HelpText="Dedicated servers can host bigger games.",Style="SettingsEnum")
     MatchSkillEnum=(Items=("Average Skill Filter: Off","Average Skill Filter: Loose","Average Skill Filter: Tight"),Style="SettingsEnum")
     MinPlayersDown=(WidgetName="MinPlayersSlider",Style="SettingsSliderLeft")
     MaxPlayersDown=(WidgetName="MaxPlayersSlider",Style="SettingsSliderLeft")
     DedicatedOnlyDown=(WidgetName="DedicatedOnlyEnum",Style="SettingsSliderLeft")
     MatchSkillDown=(WidgetName="MatchSkillEnum",Style="SettingsSliderLeft")
     MinPlayersUp=(WidgetName="MinPlayersSlider",Style="SettingsSliderRight")
     MaxPlayersUp=(WidgetName="MaxPlayersSlider",Style="SettingsSliderRight")
     DedicatedOnlyUp=(WidgetName="DedicatedOnlyEnum",Style="SettingsSliderRight")
     MatchSkillUp=(WidgetName="MatchSkillEnum",Style="SettingsSliderRight")
     MaxPlayers=16
     ALabel=(Text="Continue")
     MenuTitle=(Text="OptiMatch Options")
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
