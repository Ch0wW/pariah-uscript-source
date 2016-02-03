class ScoreBoardBase extends MenuTemplateTitled;

var() GameReplicationInfo           GRI;
var() array<PlayerReplicationInfo>  PRIArray;
var() float                         AlternatingFade;


var() localized string lsFragLimit, lsBotSkill, lsTimeRemaining;
var() localized string      PlayerText, lsTimeLimit;
var() localized string      PointsText, lsElaspedTime;

var() localized String      ScoresTitle, PlayerNamesTitle, PingsTitle, FragLimit, FPH, GameType, MapName, TimeLimit, Spacer, bar;
var() localized String      divider, tPlayers;

var() MenuText ScoreLabel, PlayerNameLabel, PsbFragLimit[2], sbTimeLimit[2], sbBotSkill, sbTimeRemaining[2], sbFragLimit[2];

var() Color ScoreboardHeader;
var() Color ScoreboardbotList;
var() Color ScoreboardList;
var() Color ScoreboardNumberList;

var() Color PlayerHighLight;
var() Color PlayerBGColor;
var() Color OldPlayerBGColor;
var Texture AnimatedCommunicator;

var() localized String StringMatchOver;
var() localized String StringStartingNextMatch;

var() int                           PlayerIndex;

var() float NextMatchAt;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    InitGRI();
    Init("");
}

simulated function InitGRI()
{
    GRI = PlayerController(Owner).GameReplicationInfo;
    if (GRI != None)
    {
        MenuTitle.Text = InitTitle();
        GRI.AddPRIArrayUser(self);
        PRIArrayUpdated();
    }
}

simulated function Destroyed()
{
    if (GRI != None)
    {
        GRI.RemovePRIArrayUser(self);
    }
    Super.Destroyed();
}

simulated function LanguageChange()
{
    // Sadly, when linear-loading, we get created before the language is set to the appropriate localization.
    MenuTitle.Text = InitTitle();
}

simulated function string InitTitle()
{
    local class<GameInfo> gameClass;
    local string gameTypeName;
    
	if ( GRI == None )
	{
		InitGRI();
	}
	if ( GRI != None )
	{
		gameClass = class<GameInfo>(DynamicLoadObject(GRI.GameClass, class'Class'));
	    
		if(gameClass != None)
		{
			gameTypeName = gameClass.default.GameName;
		}
	}

    if( Level.IsCustomMap() )
    {
        return( GetMapDisplayNameFromCustomMapPassport( Level.GetCustomMap() ) @ "/" @ gameTypeName );
    }
    else
    {
	    return( Level.Title @ "/" @ gameTypeName );
	}
}

simulated event DrawMenu( Canvas C, bool HasFocus )
{
    if (GRI == None)
        InitGRI();

    SortPRIArray();
    UpdateScoreBoard();
    UpdateGameINFOTEXT();

    Super.DrawMenu(C, HasFocus);
}

simulated function bool IsSPGame()
{
    return (Level.NetMode == NM_StandAlone && GetCurrentGameProfile() != None);
}

simulated function StartNextMatchCountdown()
{
    if( NextMatchAt <= 0.f )
    {
        NextMatchAt = Level.TimeSeconds + class'Deathmatch'.default.RestartWait + 3; // Taste my FUDGE!
        
        if( Level.NetMode != NM_StandAlone )
        {
            NextMatchAt += 5; // no, you taste my fudge
        }
    }
}

simulated function UpdateGameINFOTEXT()
{
    local PlayerController PC;
    local int i;

    sbTimeRemaining[0].Text = lsTimeRemaining;
    sbFragLimit[0].Text     = lsFragLimit; 
    sbTimeLimit[0].Text     = lsTimeLimit; 

    PC = PlayerController( Owner );
    
    if( (PC != None) && (PC.GetStateName() == 'GameEnded') )
    {
        StartNextMatchCountdown();
        i = NextMatchAt - Level.TimeSeconds;
        if( i > 0 )
        {
            sbBotSkill.Text = ReplaceSubstring( StringMatchOver, "%d", i );
        }
        else
        {
            sbBotSkill.Text = StringStartingNextMatch;
        }
    }
    else if (IsSPGame())
        sbBotSkill.Text  = "";	// rj
    else if ( GRI != None )
        sbBotSkill.Text  = lsBotSkill $" : "$ GRI.GetDifficultyString();
        
	if ( GRI != None )
	{
		sbTimeRemaining[1].Text     = FormatTime(GRI.RemainingTime);
		sbFragLimit[1].Text         = Caps( GRI.GoalScore ); 
		sbTimeLimit[1].Text         = FormatTime(GRI.TimeLimit * 60);
	    
		if( GRI.TimeLimit == 0 )
		{
			sbTimeLimit[0].bHidden = 1;
			sbTimeRemaining[0].bHidden = 1;
			sbTimeLimit[1].bHidden = 1;
			sbTimeRemaining[1].bHidden = 1;
		}
		else
		{
			sbTimeLimit[0].bHidden = 0;
			sbTimeRemaining[0].bHidden = 0;
			sbTimeLimit[1].bHidden = 0;
			sbTimeRemaining[1].bHidden = 0;
		}

		if( GRI.GoalScore == 0 )
		{
			sbFragLimit[0].bHidden = 1;
			sbFragLimit[1].bHidden = 1;
		}
		else
		{
			sbFragLimit[0].bHidden = 0;
			sbFragLimit[1].bHidden = 0;
		}
	} 
}
simulated function UpdateScoreBoard();

simulated function PRIArrayUpdated()
{
    GRI.GetPRIArray(PRIArray);
}

simulated function bool IsOnlySpectator( PlayerReplicationInfo P )
{
    return P.bOnlySpectator;
}

simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
    local bool S1, S2;
    
    S1 = IsOnlySpectator( P1 );
    S2 = IsOnlySpectator( P2 );
    
    if( S1 )
    {
        if( S2 )
            return( true );
        else
            return( false );
    }
    else if ( S2 )
        return( true );

    if( (P1.Team != None) && (P2.Team != None) )
    {
        if( P1.Team.TeamIndex > P2.Team.TeamIndex )
            return( false );
        else if( P1.Team.TeamIndex < P2.Team.TeamIndex )
            return( true );
    }

    if( P1.Score < P2.Score )
        return( false );
    
    return( true );
}

simulated function SortPRIArray()
{
    local int i;
    local int j;
    local PlayerReplicationInfo tmp;

    for (i=0; i<PRIArray.Length-1; i++)
    {
        for (j=i+1; j<PRIArray.Length; j++)
        {
            if( !InOrder( PRIArray[i], PRIArray[j] ) )
            {
                tmp = PRIArray[i];
                PRIArray[i] = PRIArray[j];
                PRIArray[j] = tmp;
            }
        }
    }
}

simulated function HandleInputBack()
{
    local PlayerController PC;

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.myHud.bShowScoreBoard = false;
    CloseMenu();
}

simulated function ReopenInit()
{
    local PlayerController PC;

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound();

    CrossFadeDir = TD_In;
    CrossFadeLevel = 0;
    TravelMenu = self;
}

defaultproperties
{
     AlternatingFade=0.200000
     lsFragLimit="Score Limit"
     lsBotSkill="Game Skill"
     lsTimeRemaining="Time Left"
     PlayerText="Player"
     lsTimeLimit="Time Limit"
     PointsText="Points"
     lsElaspedTime="Elapsed Time"
     ScoresTitle="Score"
     PlayerNamesTitle="Player"
     PingsTitle="Ping"
     FragLimit="Frag Limit :"
     FPH="FPH"
     GameType="Game"
     MapName="/"
     TimeLimit="TimeLimit :"
     Spacer=" "
     Bar="|"
     Divider="/"
     tPlayers="Players"
     sbTimeLimit(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.700000,PosY=0.300000,ScaleX=0.625000,ScaleY=0.625000,Pass=1,Style="TitleText")
     sbTimeLimit(1)=(DrawColor=(G=150,R=255,A=255),PosY=0.340000)
     sbBotSkill=(DrawColor=(G=150,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.880000,ScaleX=0.625000,ScaleY=0.625000,Pass=1,Style="TitleText")
     sbTimeRemaining(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.700000,PosY=0.390000,ScaleX=0.625000,ScaleY=0.625000,Pass=1,Style="TitleText")
     sbTimeRemaining(1)=(DrawColor=(G=150,R=255,A=255),PosY=0.430000)
     sbFragLimit(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.700000,PosY=0.210000,ScaleX=0.625000,ScaleY=0.625000,Pass=1,Style="TitleText")
     sbFragLimit(1)=(DrawColor=(G=150,R=255,A=255),PosY=0.250000)
     ScoreboardHeader=(B=255,G=255,R=255,A=255)
     ScoreboardbotList=(B=150,G=150,R=100,A=255)
     ScoreboardList=(B=255,G=255,R=255,A=255)
     ScoreboardNumberList=(B=255,G=255,R=255,A=255)
     PlayerHighLight=(B=255,G=255,R=255,A=15)
     AnimatedCommunicator=Texture'InterfaceContent.LiveIconsAnim.Communicator_a00'
     StringMatchOver="Match over. Next match in %d..."
     StringStartingNextMatch="Starting next match..."
     PlayerIndex=-1
     MenuTitle=(PosY=0.030000)
     TopBar=(ScaleY=0.070000)
     BottomBar=(ScaleY=0.150000)
     Background=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=0,G=0,R=0,A=80),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.515000,ScaleX=0.575000,ScaleY=0.900000)
     ControllerIcon=(bHidden=1)
     ControllerNumText=(bHidden=1)
     CrossFadeRate=100.000000
     ModulateRate=100.000000
     SoundTweenOut=None
     SoundOnFocus=None
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
     bRenderLevel=True
     bPersistent=True
     bIgnoresInput=True
     bShowMouseCursor=False
}
