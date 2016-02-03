class MenuHostGameSettings extends MenuTemplateTitledB;

var MenuHostMain HostMain;

var() MenuButtonEnum TimeLimitEnum;
var() MenuButtonEnum GoalScoreEnum;
var() MenuSlider InitialWECSlider;
var() MenuToggle FriendlyFireToggle;

var() MenuSliderArrow TimeLimitDown;
var() MenuSliderArrow GoalScoreDown;
var() MenuSliderArrow InitialWECDown;
var() MenuSliderArrow FriendlyFireDown;

var() MenuSliderArrow TimeLimitUp;
var() MenuSliderArrow GoalScoreUp;
var() MenuSliderArrow InitialWECUp;
var() MenuSliderArrow FriendlyFireUp;

var() Array<int> TimeLimitTable;
var() Array<int> GoalScoreTable;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    HostMain = MenuHostMain(PreviousMenu);
    Assert( HostMain != None );

    SetTimeLimit( HostMain.GameSettings[HostMain.GameTypeIndex].TimeLimit );
    SetGoalScore( HostMain.GameSettings[HostMain.GameTypeIndex].GoalScore );
    InitialWECSlider.Value = HostMain.GameSettings[HostMain.GameTypeIndex].InitialWECs;
    FriendlyFireToggle.bValue = HostMain.GameSettings[HostMain.GameTypeIndex].bFriendlyFire;
    
    if( HostMain.GameSettings[HostMain.GameTypeIndex].GameTypeRecord.bTeamGame == 0 )
    {
        FriendlyFireToggle.bHidden = 1;
        FriendlyFireDown.bHidden = 1;
        FriendlyFireUp.bHidden = 1;
    }
    
    Assert( TimeLimitTable.Length == TimeLimitEnum.Items.Length );
    Assert( GoalScoreTable.Length == GoalScoreEnum.Items.Length );
    
    OnTimeLimitChange(); // Double-check that we haven't got an endless match setup.
    UpdateInitialWECs();
}

simulated function HandleInputBack()
{
    HostMain.Refresh();
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutWidgets( TimeLimitEnum, FriendlyFireToggle, 'SettingsItemLayout' );
    LayoutWidgets( TimeLimitDown, FriendlyFireDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( TimeLimitUp, FriendlyFireUp, 'SettingsRightArrowLayout' );
}

simulated function int GetTimeLimit()
{
    return( TimeLimitTable[TimeLimitEnum.Current] );
}

simulated function int GetGoalScore()
{
    return( GoalScoreTable[GoalScoreEnum.Current] );
}

simulated function SetTimeLimit( int TimeLimit )
{
    local int i;

    HostMain.GameSettings[HostMain.GameTypeIndex].TimeLimit = TimeLimit;

    for( i = 0; i < TimeLimitTable.Length; ++i )
    {
        if( TimeLimitTable[i] == TimeLimit )
        {
            TimeLimitEnum.Current = i;
            return;
        }
    }


    TimeLimitEnum.Current = ( TimeLimitEnum.Items.Length - 1 );
}

simulated function SetGoalScore( int GoalScore )
{
    local int i;
    
    HostMain.GameSettings[HostMain.GameTypeIndex].GoalScore = GoalScore;
    
    for( i = 0; i < GoalScoreTable.Length; ++i )
    {
        if( GoalScoreTable[i] == GoalScore )
        {
            GoalScoreEnum.Current = i;
            return;
        }
    }

    GoalScoreEnum.Current = ( GoalScoreEnum.Items.Length - 1 );
}

simulated function OnTimeLimitChange()
{
    if( (GetTimeLimit() == 0) && (GetGoalScore() == 0) )
    {
        log("Resetting goal-score to avoid endless game!");
        SetGoalScore( HostMain.GameSettings[HostMain.GameTypeIndex].GameTypeRecord.DefaultGoalScore );
    }
    
    SetTimeLimit( GetTimeLimit() );
}

simulated function OnGoalScoreChange()
{
    if( (GetTimeLimit() == 0) && (GetGoalScore() == 0) )
    {
        log("Resetting time limit to avoid endless game!");
        SetTimeLimit( HostMain.GameSettings[HostMain.GameTypeIndex].GameTypeRecord.DefaultTimeLimit );
    }
    
    SetGoalScore( GetGoalScore() );
}

simulated function UpdateInitialWECs()
{
    HostMain.GameSettings[HostMain.GameTypeIndex].InitialWECs = InitialWECSlider.Value;
    
    InitialWECSlider.Blurred.Text = default.InitialWECSlider.Blurred.Text $ ":" @ int(InitialWECSlider.Value);
    InitialWECSlider.Focused.Text = InitialWECSlider.Blurred.Text;
}

simulated function OnFriendlyFireToggle()
{
    HostMain.GameSettings[HostMain.GameTypeIndex].bFriendlyFire = FriendlyFireToggle.bValue;
}

defaultproperties
{
     TimeLimitEnum=(Items=("Time Limit: 5:00","Time Limit: 10:00","Time Limit: 15:00","Time Limit: 20:00","Time Limit: 25:00","Time Limit: 30:00","Time Limit: 45:00","Time Limit: 60:00","Time Limit: None"),bNoWrap=1,OnChange="OnTimeLimitChange",Style="SettingsEnum")
     GoalScoreEnum=(Items=("Score limit: 1","Score limit: 2","Score limit: 3","Score limit: 4","Score limit: 5","Score limit: 6","Score limit: 7","Score limit: 8","Score limit: 9","Score limit: 10","Score limit: 15","Score limit: 20","Score limit: 25","Score limit: 30","Score limit: 35","Score limit: 40","Score limit: 50","Score limit: 75","Score limit: 100","Score limit: None"),bNoWrap=1,OnChange="OnGoalScoreChange",Style="SettingsEnum")
     InitialWECSlider=(MaxValue=18.000000,Delta=1.000000,OnSlide="UpdateInitialWECs",Blurred=(Text="Initial WECs"),Style="SettingsSlider")
     FriendlyFireToggle=(TextOff="Friendly Fire: Off",TextOn="Friendly Fire: On",OnToggle="OnFriendlyFireToggle",Style="SettingsToggle")
     TimeLimitDown=(WidgetName="TimeLimitEnum",Style="SettingsSliderLeft")
     GoalScoreDown=(WidgetName="GoalScoreEnum",Style="SettingsSliderLeft")
     InitialWECDown=(WidgetName="InitialWECSlider",Style="SettingsSliderLeft")
     FriendlyFireDown=(WidgetName="FriendlyFireToggle",Style="SettingsSliderLeft")
     TimeLimitUp=(WidgetName="TimeLimitEnum",Style="SettingsSliderRight")
     GoalScoreUp=(WidgetName="GoalScoreEnum",Style="SettingsSliderRight")
     InitialWECUp=(WidgetName="InitialWECSlider",Style="SettingsSliderRight")
     FriendlyFireUp=(WidgetName="FriendlyFireToggle",Style="SettingsSliderRight")
     TimeLimitTable(0)=5
     TimeLimitTable(1)=10
     TimeLimitTable(2)=15
     TimeLimitTable(3)=20
     TimeLimitTable(4)=25
     TimeLimitTable(5)=30
     TimeLimitTable(6)=45
     TimeLimitTable(7)=60
     GoalScoreTable(0)=1
     GoalScoreTable(1)=2
     GoalScoreTable(2)=3
     GoalScoreTable(3)=4
     GoalScoreTable(4)=5
     GoalScoreTable(5)=6
     GoalScoreTable(6)=7
     GoalScoreTable(7)=8
     GoalScoreTable(8)=9
     GoalScoreTable(9)=10
     GoalScoreTable(10)=15
     GoalScoreTable(11)=20
     GoalScoreTable(12)=25
     GoalScoreTable(13)=30
     GoalScoreTable(14)=35
     GoalScoreTable(15)=40
     GoalScoreTable(16)=50
     GoalScoreTable(17)=75
     GoalScoreTable(18)=100
     MenuTitle=(Text="Game Settings")
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
