class MenuLeaderBoard extends MenuTemplateTitledBXA;

// show weekly, monthly and yearly stats with current player as pivot?
const RANK_COLUMN_COUNT = 3;
const RANK_ROW_COUNT = 10;

const COL_RANK = 0;
const COL_NAME = 1;
const COL_RATING = 2;

var() MenuText	Label[3];
var() MenuText	LeaderBoardType;

var() MenuSprite	RankListColumnsBorder[3];
var() MenuStringList	RankListColumns[3];

var() MenuText	GettingStatsMsg;

struct XboxRanking
{
    var() int Rank;
    var() string Name;
    var() int Rating;
};

var() Array<XboxRanking>    Rankings;
var() localized String LeaderBoardDurations[3];
var() int LeaderBoardIndex;
var() int TopOfPageDelta;
var() bool AtTop;
var() bool AtBottom;
var() int LeaderBoardPivot;
var() string DisplayName;
var() string GameTypeName;
var() Color  SelfColor;
var() Color  OtherColor;
var() string LocalGamer;
var() int LastFocusIndex;
var() int CurFocusIndex;

simulated function Init( String Args ) // args == "CLASSNAME[or OVERALL] LOCALIZED_NAME"
{
    Super.Init(Args);

    log("MenuLeaderBoard::Init "$Args);

    GameTypeName = ParseToken(Args);
    DisplayName = ParseToken(Args);
    LeaderBoardIndex = 0;
    LeaderBoardPivot = 0;

    LocalGamer = ConsoleCommand("XLIVE GET_GAMER_TAG"@PlayerController(Owner).Player.GamePadIndex);

    GotoState('WaitingToStartQuery');

}

simulated function HandleInputBack()
{
    SetTimer( 0, false );
    CloseMenu();
}

// TCR: We must make sure they don't hammer the servers.
state WaitingToStartQuery
{
    simulated function BeginState()
    {
        HideXButton( 1 ); 
        GettingStatsMsg.bHidden = 0;
    
        Timer();
        SetTimer( 1.0, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds > PlayerController(Owner).NextStatsQueryTime )
            GotoState('WaitingForResults');
    }
}

state WaitingForResults
{
    simulated function BeginState()
    {
        local string s;
        local string interval;

        PlayerController(Owner).NextStatsQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenStatsQueries;    

        if(GetPlatform() == MWP_PC )
        {
            GotoState('Idle');
            Pork();
        }

        switch( LeaderBoardIndex )
        {
        case 0:
            interval = "WEEK";
            break;
        case 1:
            interval = "MONTH";
            break;
        case 2:
            interval = "TOTAL";
            break;
        }

        log("Querying for Pivot" @ LeaderboardPivot);
        interval = interval @ string(LeaderBoardPivot);
        s = ConsoleCommand("XLIVE STAT_GET_LEADERBOARD" @ GameTypeName @ interval);

        if( s != "SUCCESS" )
        {
            ShowStatsError();
        }

        SetTimer( 0.1, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        local String s;

        s = ConsoleCommand("XLIVE STAT_GET_STATE");

        if( s == "READING_LEADERBOARD" )
        {
            return;
        }
        else if ( s == "DONE" )
        {
            GotoState('Idle');
        }
        else
        {
            ShowStatsError();
        }
    }

    simulated function HandleInputBack()
    {
        ConsoleCommand("XLIVE STAT_CANCEL");
        global.CloseMenu();
    }
}

state Idle
{
    simulated function BeginState()
    {
        local String Results;
        
        GettingStatsMsg.bHidden = 1;
        HideXButton( 0 ); 
        
        Results = ConsoleCommand("XLIVE STAT_LEADERBOARD_RESULTS");
        ParseResults( Results );   
    }

    simulated function OnXButton()
    {
        LeaderBoardPivot = 0;
        LeaderBoardIndex = (LeaderBoardIndex+1) % ArrayCount(LeaderBoardDurations);
        
        GotoState('WaitingToStartQuery');
    }

    simulated function ScrollHitTop(int Context)
    {
        if( !AtTop )
        {
            LeaderBoardPivot = Max(LeaderBoardPivot-RankListColumns[COL_RANK].DisplayCount, 1);
            GotoState('WaitingToStartQuery');
        }
    }

    simulated function ScrollHitBottom(int Context)
    {
        if( !AtBottom )
        {
            LeaderBoardPivot += RankListColumns[COL_RANK].DisplayCount;
            GotoState('WaitingToStartQuery');
        }
    }

    function HandleInputLeft()
    {
        if( !AtTop )
        {
            LeaderBoardPivot = Max(LeaderBoardPivot - 100, 1);
            GotoState('WaitingToStartQuery');
        }
    }

    function HandleInputRight()
    {
        if ( !AtBottom )
        {
            LeaderBoardPivot += 100;
            GotoState('WaitingToStartQuery');
        }
    }

    simulated function OnSelect()
    {
        local int i;
        
        for( i=0; i<RankListColumns[0].Items.Length; i++ )
        {
            if ( RankListColumns[0].Items[i].bHasFocus != 0 )
            {
                ShowDetails(i);
                return;
            }
        }
    }    
}

simulated exec function Pork()
{
    local int Rank;
    local String Results;

    DisplayName = "Deathmatch";
    LocalGamer = "PorkMaster233";
    
    for( Rank = 100; Rank < 110; ++Rank )
    {
        Results = Results $ Rank @ "\"Bob" $ Rand(100) $ "\"" @ Rand(1000) $ " ";
    }
    
    ParseResults( Results );
}

simulated function ParseResults( String Results )
{
    local int i;
    local int CurGamerIndex;
    local int NumResults;

    LastFocusIndex = -1;

    LeaderBoardType.Text = DisplayName @ "/" @ LeaderBoardDurations[LeaderBoardIndex];
    XLabel.Text = LeaderBoardDurations[(LeaderBoardIndex+1)%ArrayCount(LeaderBoardDurations)];
    bDynamicLayoutDirty = true;

    FocusOnNothing();

    // need to spew rows of:
    // 20 "Battle boy" 54325
    for( i = 0; i < RANK_COLUMN_COUNT; i++ )
        RankListColumns[i].Items.Length = 0;

    Rankings.Length = 0;
    i = 0;
    CurGamerIndex = -1;
    NumResults = 0;
    AtTop = false;
    AtBottom = false;

    while( Len(Results)>1 )
    {
        Rankings[i].Rank = int(ParseToken(Results));
        Rankings[i].Name = ParseToken(Results);
        Rankings[i].Rating = int(ParseToken(Results));

        RankListColumns[COL_RANK].Items[i].Blurred.Text = string(Rankings[i].Rank);
        RankListColumns[COL_RANK].Items[i].Focused.Text = string(Rankings[i].Rank);

        RankListColumns[COL_NAME].Items[i].Blurred.Text = Rankings[i].Name;
        RankListColumns[COL_NAME].Items[i].Focused.Text = Rankings[i].Name;

        RankListColumns[COL_RATING].Items[i].Blurred.Text = string(Rankings[i].Rating);
        RankListColumns[COL_RATING].Items[i].Focused.Text = string(Rankings[i].Rating);

        if( Rankings[i].Rank == 1 )
        {
            AtTop = true;
        }

        if( LeaderBoardPivot == 0 && Rankings[i].Name == LocalGamer )
        {
            LeaderBoardPivot = Rankings[0].Rank;
            CurGamerIndex = i;
            TopOfPageDelta = i;
        }

        // log("Got Leader: #" $ Rankings[i].Rank $" - "$ Rankings[i].Name $ " - " $ Rankings[i].Rank);
        i++;
    }

    NumResults = i;

    if( NumResults>0 && NumResults != 10 )
    {
        AtBottom = true;
    }

    // fill in listing
    for( i = 0; i < ArrayCount( RankListColumns ); i++ )
    {
        RankListColumns[i].DisplayCount = RANK_ROW_COUNT;
        LayoutMenuStringList( RankListColumns[i] );
    }

    if( CurGamerIndex == -1 )
        CurGamerIndex = Clamp((NumResults / 2)-1, 0, RANK_ROW_COUNT);

    SetListPosition(CurGamerIndex);

    log("GetResults num: "$NumResults);
    if( NumResults == 0 && LeaderBoardPivot != 1)
    {
        LeaderBoardPivot = Max(1, LeaderBoardPivot - 10);
        log("Restarting query with pivot" @ LeaderBoardPivot);
        GotoState('WaitingToStartQuery');
    }
}

simulated function LeaderBoardScroll()
{
    local int i;

    for( i = 0; i < RankListColumns[COL_RANK].Items.Length; i++ )
    {
        if( RankListColumns[COL_RANK].Items[i].bHasFocus==1 )
        {
            CurFocusIndex = i;
        }
        if( Rankings[i].Name == LocalGamer )
        {
            RankListColumns[COL_RANK].Items[i].Blurred.DrawColor = SelfColor;
            RankListColumns[COL_RANK].Items[i].Focused.DrawColor = SelfColor;
            RankListColumns[COL_NAME].Items[i].Blurred.DrawColor = SelfColor;
            RankListColumns[COL_NAME].Items[i].Focused.DrawColor = SelfColor;
            RankListColumns[COL_RATING].Items[i].Blurred.DrawColor = SelfColor;
            RankListColumns[COL_RATING].Items[i].Focused.DrawColor = SelfColor;
        }
        else
        {
            RankListColumns[COL_RANK].Items[i].Blurred.DrawColor = OtherColor;
            RankListColumns[COL_RANK].Items[i].Focused.DrawColor = OtherColor;
            RankListColumns[COL_NAME].Items[i].Blurred.DrawColor = OtherColor;
            RankListColumns[COL_NAME].Items[i].Focused.DrawColor = OtherColor;
            RankListColumns[COL_RATING].Items[i].Blurred.DrawColor = OtherColor;
            RankListColumns[COL_RATING].Items[i].Focused.DrawColor = OtherColor;
        }
    }

    if( GetStateName() == 'Idle' )
    {
        if( CurFocusIndex == LastFocusIndex && LastFocusIndex==0 && !AtTop )
        {
            LeaderBoardPivot = Max(LeaderBoardPivot-RankListColumns[COL_RANK].DisplayCount, 1);
            GotoState('WaitingToStartQuery');
        }
        else if ( CurFocusIndex == LastFocusIndex && 
            LastFocusIndex == RankListColumns[COL_RANK].DisplayCount-1 && !AtBottom )
        {
            LeaderBoardPivot += RankListColumns[COL_RANK].DisplayCount;
            GotoState('WaitingToStartQuery');
        }
        else
        {
            LastFocusIndex = CurFocusIndex;
        }
    }
}

simulated function SetListPosition( int NewPosition )
{
    local int i, j;
    
    for( i = 0; i < ArrayCount( RankListColumns ); i++ )
    {
        if( RankListColumns[i].Position != NewPosition )
        {
            RankListColumns[i].Position = NewPosition;
            LayoutMenuStringList( RankListColumns[i] );
        }
        
        if( i == 0 )
            continue;
            
        for( j = 0; j < RankListColumns[i].Items.Length; j++ )
            RankListColumns[i].Items[j].bDisabled = 1;
    }

    if( RankListColumns[0].Items.Length > NewPosition )
        FocusOnWidget( RankListColumns[0].Items[NewPosition] );
    else
        FocusOnNothing();

    LeaderBoardScroll();
}

simulated function ShowDetails(int Index)
{
    if( GameTypeName=="DEDICATED" )
    {
        CallMenuClass("XInterfaceLive.MenuDHMStats", "\"" $ RankListColumns[COL_NAME].Items[Index].Blurred.Text $"\"" );
    }
    else
    {
        CallMenuClass("XInterfaceLive.MenuPlayerStats", "\"" $ RankListColumns[COL_NAME].Items[Index].Blurred.Text $"\"" );
    }
}

simulated function ShowStatsError()
{
    OverlayErrorMessageBox( "STATS_ERROR" );
}

defaultproperties
{
     Label(0)=(Text="Name",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.230000,Style="SmallLabel")
     Label(1)=(Text="Rank",PosX=0.184375)
     Label(2)=(Text="Rating",PosX=0.812500)
     LeaderBoardType=(Text="Deathmatch / Weekly",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.185000,Style="SmallLabel")
     RankListColumnsBorder(0)=(PosX=0.109000,PosY=0.259414,ScaleX=0.185000,ScaleY=0.527197,Pass=1,Style="Border")
     RankListColumnsBorder(1)=(PosX=0.283750,PosY=0.259414,ScaleX=0.456000,ScaleY=0.527197,Pass=1,Style="Border")
     RankListColumnsBorder(2)=(PosX=0.730000,PosY=0.259414,ScaleX=0.155000,ScaleY=0.527197,Pass=1,Style="Border")
     RankListColumns(0)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft),BackgroundFocused=(PosX=-0.070000,ScaleX=0.765000),OnSelect="OnSelect"),PosX1=0.184000,PosY1=0.308000,PosX2=0.184000,PosY2=0.738000,DisplayCount=10,OnScroll="LeaderBoardScroll",Style="ServerInfoColumn")
     RankListColumns(1)=(Template=(Blurred=(DrawPivot=DP_MiddleMiddle,MaxSizeX=0.500000),bDisabled=1),PosX1=0.500000,PosY1=0.308000,PosX2=0.500000,PosY2=0.738000,OnScroll="DoNothing")
     RankListColumns(2)=(Template=(Blurred=(DrawPivot=DP_MiddleRight,MaxSizeX=0.250000),bDisabled=1),PosX1=0.873000,PosY1=0.308000,PosX2=0.873000,PosY2=0.738000,OnScroll="DoNothing")
     GettingStatsMsg=(Text="Please wait, downloading statistics...",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.840000,bHidden=1,Style="LabelText")
     LeaderBoardDurations(0)="Weekly"
     LeaderBoardDurations(1)="Monthly"
     LeaderBoardDurations(2)="Total"
     SelfColor=(B=225,G=225,R=225,A=255)
     OtherColor=(B=140,G=140,R=140,A=255)
     MenuTitle=(Text="Leaderboard")
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
