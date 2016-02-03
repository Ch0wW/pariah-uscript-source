//=============================================================================
// DeathMatch
//=============================================================================
class DeathMatch extends UnrealMPGameInfo
    config;

var() int NumRounds;
var() globalconfig int NetWait		"PI:Net Start Delay:Server:2:40:Text;3";       // time to wait for players in netgames w/ bNetReady (typically team games)
var() globalconfig int MinNetPlayers	"PI:Min. Net Players:Game:1:100:Text;3"; // how many players must join before net game will start
var() globalconfig int RestartWait	"PI:Restart Delay:Server:2:42:Text;3";

var() globalconfig bool bTournament	"PI:Tournament Game:Game:1:10:Check";  // number of players must equal maxplayers for game to start
var() config bool bPlayersMustBeReady	"PI:Players Must Be Ready:Game:1:20:Check";// players must confirm ready for game to start
var() config bool bForceRespawn		"PI:Force Respawn:Game:0:40:Check";
var() config bool bAdjustSkill		"PI:Ajust Bots Skill:Bots:0:30:Check";
var() config bool bAllowTaunts		"PI:Allow Taunts:Game:0:50:Check";
var() bool    bWaitForNetPlayers;     // wait until more than MinNetPlayers players have joined before starting match

var() byte StartupStage;              // what startup message to display
var() int RemainingTime, ElapsedTime;
var() int CountDown;
var() float AdjustedDifficulty;
var() int PlayerKills, PlayerDeaths;
var() class<SquadAI> DMSquadClass;    // squad class to use for bots in DM games (no team)
var() class<LevelGameRules> LevelRulesClass;

// Bot related info
var()     int         RemainingBots;
var()     int         InitialBots;

var() NavigationPoint LastPlayerStartSpot;    // last place player looking for start spot started from
var() NavigationPoint LastStartSpot;          // last place any player started from

// jij ---
var() int             EndMessageWait;         // wait before playing which team won the match
var() transient int   EndMessageCounter;      // end message counter
var() Sound           EndGameSound[2];        // end game sounds
var() Sound           AltEndGameSound[2];     // end game sounds

var() int NextBotName;
var() Array<String> BotNames;

// --- jij

// mc - localized PlayInfo descriptions & extra info
var private localized string DMPropsDisplayText[8];

function PostBeginPlay()
{
    if ( bAlternateMode )
        GoreLevel = 2;

    Super.PostBeginPlay();
    GameReplicationInfo.RemainingTime = RemainingTime;

	if (!IsOnConsole())
	{	
		SetupBots();	
	}
}

function PostLinearize()
{
    Super.PostLinearize();
	if (IsOnConsole())
	{
		SetupBots();	
	}
}

function SetupBots()
{
    RemainingBots = InitialBots;
    log("SetupBots: RemainingBots" @ RemainingBots);

	while ( NeedPlayers() && AddBot() )
        RemainingBots--;

}

function Destroyed()
{
    Super.Destroyed();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    Super.Reset();
    ElapsedTime = NetWait - 3;
    bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
    StartupStage = 0;
    CountDown = Default.Countdown;
    RemainingTime = 60 * TimeLimit;
    //log("Reset() RemainingTime:"$RemainingTime$" TimeLimit: "$TimeLimit); // sjs
    GotoState('PendingMatch');
}

/* CheckReady()
If tournament game, make sure that there is a valid game winning criterion
*/
function CheckReady()
{
    if ( (GoalScore == 0) && (TimeLimit == 0) )
    {
        TimeLimit = 20;
        RemainingTime = 60 * TimeLimit;
    }
}

// Monitor killed messages for fraglimit
function Killed( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )//(pawn killer, pawn Other, name damageType)
{
    local PlayerController pc;

    /*
	local int NextTaunt, i;
	local bool bAutoTaunt, bEndOverTime;
	local Pawn P, Best;

	if ( (damageType == 'Decapitated') && (Killer != Other) && (Killer != None) )
	{
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
		Killer.ReceiveLocalizedMessage( class'DecapitationMessage' );
	}*/

    pc = PlayerController(Killer);

    if( damageType!=None && damageType.default.KillerMessage!=None && pc!=Killed && pc!=None && !pc.SameTeamAs(Killed) )
    {
        pc.ReceiveLocalizedMessage( damageType.default.KillerMessage, damageType.default.KillerMessageIndex );
    }
    
    Super.Killed(Killer, Killed, KilledPawn, damageType);
}


// Parse options for this game...
event InitGame( string Options, out string Error )
{
    local string InOpt;
    local bool bAutoNumBots;

    // find Level's LevelGameRules actor if it exists
    ForEach AllActors(class'LevelGameRules', LevelRules)
        break;
    if ( LevelRules == None )
        LevelRules = spawn(LevelRulesClass);

    RemainingRounds = LevelRules.GetNumRounds(NumRounds);
    GoalScore = LevelRules.GetGoalScore(GoalScore); 
    TimeLimit = LevelRules.GetTimeLimit(TimeLimit);
    MaxLives = LevelRules.GetMaxLives(MaxLives);
    
    Super.InitGame(Options, Error);

    SetGameSpeed(GameSpeed);
    RemainingRounds = GetIntOption( Options, "RemainingRounds", RemainingRounds );
    MaxLives = GetIntOption( Options, "MaxLives", MaxLives );
    GoalScore = GetIntOption( Options, "GoalScore", GoalScore );
    TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );

    InOpt = ParseOption( Options, "bAutoNumBots");
    if ( InOpt != "" )
    {
        log("bAutoNumBots: "$bool(InOpt));
        bAutoNumBots = bool(InOpt);
    }
    
    if (bAutoNumBots)
    {
        MinPlayers = GetMinPlayers();
        
        InitialBots = MinPlayers - 1;
        
        if (IsCoopGame())
            CoopInfo.AdjustPlayerCount(true);
    }
    else
    {
        MinPlayers = GetIntOption( Options, "MinPlayers", MinPlayers );
        InitialBots = GetIntOption( Options, "NumBots", InitialBots );
    }
    
    log("MinPlayers:"@MinPlayers);
    log("InitialBots:"@InitialBots);

    RemainingTime = 60 * TimeLimit;
    
    log("InitGame RemainingTime:"$RemainingTime$" TimeLimit: "$TimeLimit); // sjs
    InOpt = ParseOption( Options, "WeaponStay");
    if ( InOpt != "" )
    {
        log("WeaponStay: "$bool(InOpt));
        //bWeaponStay = bool(InOpt);
		//XJ: Our weapons never stay!
		bWeaponStay = false;
    }

    bTournament = (GetIntOption( Options, "Tournament", 0 ) > 0);
    if ( bTournament ) 
        CheckReady();
    bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
}

function int GetMinPlayers()
{
    local int i;
    
    i = (Level.IdealPlayerCountMax + Level.IdealPlayerCountMin) / 2;
    
    if( IsA('TeamGame') && ((i & 1) == 1) )
        i++;
                
    if( i < 2 )
        i = 2;

    i = Min( MaxPlayers, i );

    return i;
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
    local inventory Inv,next;

    Inv = PlayerPawn.Inventory;
    while ( Inv != None )
    {
        next = Inv.Inventory;
        Inv.Destroy();
        Inv = Next;
    }

    PlayerPawn.Weapon = None;
    PlayerPawn.SelectedItem = None;
    AddDefaultInventory( PlayerPawn );
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller P, NextC;
    local PlayerController Player;

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
        return false;

    // check for tie
    /*for ( P=Level.ControllerList; P!=None; P=P.nextController )
    {
        if ( P.bIsPlayer && 
            (Winner != P.PlayerReplicationInfo) && 
            (P.PlayerReplicationInfo.Score == Winner.Score) 
            && !P.PlayerReplicationInfo.bOutOfLives )
        {
            BroadcastLocalizedMessage( GameMessageClass, 0 );
            return false;
        }       
    }*/

    EndTime = Level.TimeSeconds + 3.0;
    GameReplicationInfo.Winner = Winner;
    log( "Game ended at "$EndTime);
    for ( P=Level.ControllerList; P!=None; P=NextC )
    {
        NextC = P.NextController;
        Player = PlayerController(P);
        if ( Player != None )
        {
            PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
            Player.ClientSetBehindView(true);
            Player.SetViewTarget(Controller(Winner.Owner).Pawn);
            Player.ClientGameEnded();
        }
        P.GotoState('GameEnded');
    }
    return true;
}

function PlayWinMessage(PlayerController Player, bool bWinner)
{
    UnrealPlayer(Player).PlayWinMessage(bWinner);
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local PlayerController NewPlayer;

    NewPlayer = Super.Login(Portal,Options,Error);

    return NewPlayer;
}

event PostLogin( playercontroller NewPlayer )
{
    Super.PostLogin(NewPlayer);
    UnrealPlayer(NewPlayer).PlayStartUpMessage(StartupStage);

    // amb ---
    if (IsCoopGame())
    {
        if (NewPlayer.IsCoopCaptain())
            CoopInfo.Initialize(NewPlayer);
        NewPlayer.GotoState('CoopJoined');
    }
    // --- amb
}

function ChangeLoadOut(PlayerController P, string LoadoutName)
{
    local class<UnrealPawn> NewLoadout;
	
	if ( LoadoutName != "" )
		NewLoadout = class<UnrealPawn>(DynamicLoadObject(LoadoutName,class'Class'));
    if ( (NewLoadout != None) 
        && ((UnrealTeamInfo(P.PlayerReplicationInfo.Team) == None) || UnrealTeamInfo(P.PlayerReplicationInfo.Team).BelongsOnTeam(NewLoadout)) )
    {
        P.PawnClass = NewLoadout;
        if (P.Pawn!=None)
            P.ClientMessage("Your next class is "$P.PawnClass.Default.MenuName);
    }
}

function RestartPlayer( Controller aPlayer )    
{
    local Bot b;

    b = Bot(aPlayer);

    if ( b != None && !IsInState('MatchInProgress') )
        return;

    if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
        return;

    if ( b != None && TooManyBots(aPlayer) )
    {
        aPlayer.Destroy();
        return;
    } 
    Super.RestartPlayer(aPlayer);
}

function SendStartMessage(PlayerController P)
{
    UnrealPlayer(P).PlayStartupMessage(2);
}

function ForceAddBot()
{
    // add bot during gameplay
    if ( Level.NetMode != NM_Standalone )
        MinPlayers = Max(MinPlayers+1, NumPlayers + NumBots + 1);
    AddBot();
}

function bool AddBot(optional string botName)
{
    local Bot NewBot;
	
    NewBot = SpawnBot(botName);
    if ( NewBot == None )
    {
        warn("Failed to spawn bot.");
        return false;
    }
    // broadcast a welcome message.
    BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

    NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
    NumBots++;
    if ( Level.NetMode == NM_Standalone )
		RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead','MPStart');
        
    return true;
}

function AddDefaultInventory( pawn PlayerPawn )
{
    if ( UnrealPawn(PlayerPawn) != None )
        UnrealPawn(PlayerPawn).AddDefaultInventory();
    SetPlayerDefaults(PlayerPawn);
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    if ( ViewTarget.IsA('Controller') )
        return false;
    return ( (Level.NetMode == NM_Standalone) || bOnlySpectator );
}

function bool ShouldRespawn(Pickup Other)
{
    return ( Other.ReSpawnTime!=0.0 );
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
    local Controller APlayer, ChangeBot;
    local int n, d;
    local bool Found;
    local string BaseS;

    log(self$" ChangeName: "$S);

    if ( S == "" )
        return;

    BaseS = S;

	d = 1;
	while ( !Found )
    {
		Found = true;
		for( APlayer=Level.ControllerList; APlayer!=None; APlayer=APlayer.nextController )
        {
			if ( APlayer != Other && APlayer.bIsPlayer && APlayer.PlayerReplicationInfo.RetrivePlayerName() ~= S )
            {
                if ( Bot(APlayer) != None && PlayerController(Other) != None ) // force bot to rename instead of player
                {
                    ChangeBot = APlayer;
                    break;
                }
                else
                {
					n = int( Right(APlayer.PlayerReplicationInfo.RetrivePlayerName(), d) );
					if (n == 0)
                        n = 2; // no suffix, start at 2
                    else
                        n++;
					d = 1 + (Loge(n) / Loge(10)) ; //mikeH: let the renaming go past 10
                    S = BaseS$n;
                    Found = false;
					break;
                }
            }
        }
    }

    if (!(Other.PlayerReplicationInfo.RetrivePlayerName() ~= S))
    {
	    if (GameStats!=None)
		    GameStats.GameEvent("NameChange",s,Other.PlayerReplicationInfo);		

        Other.PlayerReplicationInfo.SetPlayerName(S);
        if ( bNameChange )
            BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );          
    }

    if (ChangeBot != None)
        ChangeName(ChangeBot, S, true);
}

function Logout(controller Exiting)
{
    Super.Logout(Exiting);
    if ( Exiting.IsA('Bot') )
        NumBots--;
    if ( (Level.NetMode != NM_Standalone) && NeedPlayers() && !AddBot() )
        RemainingBots++;
}

function bool NeedPlayers()
{
    if ( Level.NetMode == NM_Standalone )
        return ( RemainingBots > 0 );
    return (NumPlayers + NumBots < MinPlayers);
}

//------------------------------------------------------------------------------
// Game Querying.

function GetServerDetails( out ServerResponseLine ServerState )
{
	local int i;

	Super.GetServerDetails( ServerState );

	i = ServerState.ServerInfo.Length;

	// goalscore
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "goalscore";
	ServerState.ServerInfo[i++].Value = string(GoalScore);
	
	// timelimit
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "timelimit";
	ServerState.ServerInfo[i++].Value = string(TimeLimit);

	// minplayers
	//ServerState.ServerInfo.Length = i+1;
	//ServerState.ServerInfo[i].Key = "minplayers";
	//ServerState.ServerInfo[i++].Value = string(MinPlayers);

	// initialbots
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "initialbots";
	ServerState.ServerInfo[i++].Value = string(InitialBots);
}

function InitGameReplicationInfo()
{
    Super.InitGameReplicationInfo();
    GameReplicationInfo.GoalScore = GoalScore;
    GameReplicationInfo.TimeLimit = TimeLimit;
}

//------------------------------------------------------------------------------

function UnrealTeamInfo GetBotTeam()
{
    return LevelRules.GetDMRoster();
}

/* Spawn and initialize a bot
*/
function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
    local UnrealTeamInfo BotTeam;

    BotTeam = GetBotTeam();
	if ( BotTeam != None )
	{
		Chosen = BotTeam.ChooseBotClass(botName);

		if ( Chosen != None )
		{
			if (Chosen.PawnClass == None)
				Chosen.Init(); //amb

			if ( Chosen.PawnClass != None )
			{
				NewBot = Bot(Spawn(Chosen.PawnClass.default.ControllerClass));

				if ( NewBot != None )
					InitializeBot(NewBot,BotTeam,Chosen);
			}
		}
	}
	
	return NewBot;
}
    
//@@@ MH: OH MY FUCKING GOT THIS IS TERRIBLE
// AND i DON'T REALLY KNOW WHAT I'M doing.
// but the e3 build is in 17 minutes
function string GetCharacterClass(TeamInfo MyTeam)
{
    local int randomInt;
    
    randomInt = Rand(2);
    switch( randomInt)
    {
    case 0:
        return "DMPLAYERA";
    case 1:
        return "DMPLAYERB";
    }
}

function ShuffleBotNames()
{
    local int shuffles;
    local int i, j;
    local String S;
    
    for( shuffles = 0; shuffles < 100; ++shuffles )
    {
        i = Rand(BotNames.Length);
        j = Rand(BotNames.Length);
        
        if( i != j )
        {
            S = BotNames[i];
            BotNames[i] = BotNames[j];
            BotNames[j] = S;
        }
    }
}

function string GetRandomBotName()
{
    if( NextBotName <= 0 )
    {
        ShuffleBotNames();
        NextBotName = 0;
    }

    NextBotName = (NextBotName + 1) % BotNames.Length;

    return(BotNames[NextBotName]);
}

/* Initialize bot
*/
function InitializeBot(Bot NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
    NewBot.InitializeSkill(Difficulty);
    Chosen.InitBot(NewBot, GetCharacterClass( BotTeam ) );
    BotTeam.AddToTeam(NewBot);

    ChangeName(NewBot, GetRandomBotName(), false);
	
    // log("Chose character "$Chosen.PlayerName);
    BotTeam.SetBotOrders(NewBot,Chosen);
}

/* initialize a bot which is associated with a pawn placed in the level
*/
function InitPlacedBot(Bot B)
{
    local UnrealTeamInfo BotTeam;

	log("Init placed bot "$B);
    if ( B.Pawn == None )
        warn("Placed bot with no pawn???");
    
    BotTeam = FindTeamFor(B);
    InitializeBot(B,BotTeam,None);
}

function UnrealTeamInfo FindTeamFor(Bot B)
{
    return GetBotTeam();
}
//------------------------------------------------------------------------------
// Game States

function StartMatch()
{
    GotoState('MatchInProgress');
    GameReplicationInfo.RemainingMinute = RemainingTime;
    Super.StartMatch();

    log("START MATCH");
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
    if (LevelRules.bOnlyObjectivesWin &&
        ((Reason ~= "triggered") || 
         (Reason ~= "LastMan")   || 
         (Reason ~= "TimeLimit") || 
         (Reason ~= "FragLimit") || 
         (Reason ~= "TeamScoreLimit") ||
		 (Reason ~= "objectivedead")) ) // jij
    {       
        Super.EndGame(Winner,Reason);
        if ( bGameEnded )
            GotoState('MatchOver');
    }
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
*/
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint Best;

    if ( (Player != None) && (Player.StartSpot != None) )
        LastPlayerStartSpot = Player.StartSpot;

    Best = Super.FindPlayerStart(Player, InTeam, incomingName );
    if ( Best != None )
        LastStartSpot = Best;
    return Best;
}

auto State PendingMatch
{
    function Timer()
    {
        local Controller P;
        local bool bReady;

        //log("*** PendingMatch Timer! ***");

        // amb ---
        if (IsCoopGame() && !CoopInfo.IsCaptainReady())
            return;
        // --- amb

        Global.Timer();

        // first check if there are enough net players, and enough time has elapsed to give people
        // a chance to join
        // bWaitForNetPlayers = false; // FIXME REMOVE
        if ( bWaitForNetPlayers )
        {
            //log("*** PendingMatch bWaitForNetPlayers! ***");
            if ( NumPlayers > 0 )
                ElapsedTime++;
            else
                ElapsedTime = 0;
            if ( (NumPlayers == MaxPlayers) 
                || ((ElapsedTime > NetWait) && (NumPlayers >= MinNetPlayers)) )
            {
                bWaitForNetPlayers = false;
                CountDown = 3;
            }
        }

        // keep message displayed for waiting players
        for (P=Level.ControllerList; P!=None; P=P.NextController )
            if ( UnrealPlayer(P) != None )
                UnrealPlayer(P).PlayStartUpMessage(StartupStage);

        //log("*** PendingMatch bWaitForNetPlayers! ***");

        if ( bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers)) )
            return;

        // check if players are ready
        bReady = true;
        StartupStage = 1;
        if ( bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone) )
        {
            for (P=Level.ControllerList; P!=None; P=P.NextController )
                if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
                    && P.PlayerReplicationInfo.bWaitingPlayer
                    && !P.PlayerReplicationInfo.bReadyToPlay )
                    bReady = false;
        }
        if ( bReady )
        {
            //log("*** PendingMatch bReady! ***");

            CountDown--;
            if ( CountDown <= 0 )
                StartMatch();
            else
            {
                StartupStage = 2;
                for ( P = Level.ControllerList; P!=None; P=P.nextController )
                    if ( UnrealPlayer(P) != None )
                        UnrealPlayer(P).TimeMessage(CountDown);
            }
        }
    }
}

// gam ---
function PlayerReplicationInfo GetLeader( int Team )
{
    local Controller P;
    local PlayerReplicationInfo BestPC;

    For ( P = Level.ControllerList; P != None; P = P.NextController )
    {
        if( P.PlayerReplicationInfo.bOnlySpectator )
            continue;

        if( (BestPC == None) || (BestPC.Score < P.PlayerReplicationInfo.Score) )
            BestPC = P.PlayerReplicationInfo;
    }

    return BestPC;
}
// --- gam

State MatchInProgress
{
    function Timer()
    {
        local Controller P, NextC;

        //log("*** MatchInProgress Timer! ***");

        Global.Timer();

        if ( bForceRespawn )
            For ( P=Level.ControllerList; P!=None; P=NextC )
            {
                NextC = P.NextController;
                if ( (P.Pawn == None) && P.IsA('PlayerController') && !P.PlayerReplicationInfo.bOnlySpectator )
                    PlayerController(P).ServerReStartPlayer();
            }
        if ( NeedPlayers() )
            AddBot();

        // AsP ---
        if( TimeLimit > 0 )
        {
            if( !bOverTime )
            {
                GameReplicationInfo.bStopCountDown = false;
                RemainingTime--;
                GameReplicationInfo.RemainingTime = RemainingTime;
                if ( RemainingTime % 60 == 0 )
                    GameReplicationInfo.RemainingMinute = RemainingTime;
                if ( RemainingTime <= 0 )
                    EndGame(GetLeader(-1),"TimeLimit");
                else
                {
                    ElapsedTime++;
                    GameReplicationInfo.ElapsedTime = ElapsedTime;
                }
            }
        }
        else
        {
            ElapsedTime++;
            GameReplicationInfo.ElapsedTime = ElapsedTime;
        }
        // --- AsP
    }

    function beginstate()
    {
        //log("*** MatchInProgress beginstate! ***");
        StartupStage = 3;   // if players join during gameplay
    }
}

State MatchOver
{
    function Timer()
    {
		local Controller C;

        Global.Timer();

        if ( Level.TimeSeconds > EndTime + RestartWait )
            RestartGame();

        EndMessageCounter++;
        if (!(EndMessageCounter == EndMessageWait))
            return;

        // jij ---
        // play end-of-match message for winner/losers (for single and muli-player)
        if (!Level.Game.IsA('TeamGame'))
        {
            for ( C = Level.ControllerList; C != None; C = C.NextController )
		    {
			    if ( C.IsA('PlayerController') )
                {
                    if (C.PlayerReplicationInfo == GameReplicationInfo.Winner
                     || C.PlayerReplicationInfo.Score == PlayerReplicationInfo(GameReplicationInfo.Winner).Score)
                        PlayerController(C).PlayAnnouncement(EndGameSound[0],1,true);
                    else
                        PlayerController(C).PlayAnnouncement(EndGameSound[1],1,true);
                }
		    }
        }
        // --- jij
    }
    
    function bool NeedPlayers()
    {
        return false;
    }

    function BeginState()
    {
		GameReplicationInfo.bStopCountDown = true;
	}    
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    P = PlayerStart(N);

    if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( P.bPrimaryStart )
		Score = 10000000;
    if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
        Score -= 10000.0;
    else
        Score += 3000 * FRand(); //randomize

	if ( Level.TimeSeconds - P.LastSpawnCampTime < 30 )
		Score = Score - (30 - P.LastSpawnCampTime + Level.TimeSeconds) * 1000;
	
    for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)  
        if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
        {
            if ( OtherPlayer.Pawn.Region.Zone == N.Region.Zone )
                Score -= 1500;
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
            if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
                Score -= 1000000.0;
            else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                Score -= (10000.0 - NextDist);
            else if ( NumPlayers + NumBots == 2 )
            {
                Score += 2 * VSize(OtherPlayer.Pawn.Location - N.Location);
                if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
                    Score -= 10000;
            }
        }
    return FMax(Score, -8000000);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local bool bNoneLeft;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;

    if ( (Scorer != None) && (bOverTime || (GoalScore > 0)) && (Scorer.Score >= GoalScore) )
        EndGame(Scorer,"fraglimit");

    // check if all other players are out
    if ( MaxLives > 0 )
    {
        bNoneLeft = true;
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (C.PlayerReplicationInfo != None)
                && !C.PlayerReplicationInfo.bOutOfLives )
            {
				if (C.PlayerReplicationInfo != Scorer) 
			   	{
    	        	bNoneLeft = false;
	            	break;
				}
            } 
        if ( bNoneLeft )
            EndGame(Scorer,"LastMan");
    }   
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
    if ( Scorer != None )
    {
        Scorer.Score += Score;
		
		if (GameStats!=None)
			GameStats.ScoreEvent(Scorer,Score,"ObjectiveScore");
		        
        /*
        if ( !bTeamScoreRounds && (Scorer.Team != None) )
            Scorer.Team.Score += Score;
        */
    }

    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreObjective(Scorer,Score);
    CheckScore(Scorer);
}

function ScoreKill(Controller Killer, Controller Other)
{
    if ( Other.PlayerReplicationInfo != None )
    {
        Other.PlayerReplicationInfo.NumLives++;
        if ( (MaxLives > 0) && (Other.PlayerReplicationInfo.NumLives >=MaxLives) )
            Other.PlayerReplicationInfo.bOutOfLives = true;
    }

	//if ( bAllowTaunts && (Killer != None) && (Killer != Other) && Killer.AutoTaunt() && (Killer.PlayerReplicationInfo.VoiceType != None) )
	//	Killer.SendMessage(None, 'AUTOTAUNT', Killer.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(Killer, false, true), 10, 'GLOBAL');
    
	Super.ScoreKill(Killer,Other);

    if ( (killer == None) || (Other == None) )
        return;

    if ( bAdjustSkill && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
    {
        if ( killer.IsA('AIController') )
            AdjustSkill(AIController(killer),true);
        if ( Other.IsA('AIController') )
            AdjustSkill(AIController(Other),false);
    }
}

function AdjustSkill(AIController B, bool bWinner)
{
    local float BotSkill;

    BotSkill = B.Skill;

    if ( bWinner )
    {
        PlayerKills += 1;
        AdjustedDifficulty = FMax(0, AdjustedDifficulty - 2/Min(PlayerKills, 10));
        if ( BotSkill > AdjustedDifficulty )
            B.Skill = AdjustedDifficulty;
    }
    else
    {
        PlayerDeaths += 1;
        AdjustedDifficulty += FMin(7,2/Min(PlayerDeaths, 10));
        if ( BotSkill < AdjustedDifficulty )
            B.Skill = AdjustedDifficulty;
    }
    if ( abs(AdjustedDifficulty - Difficulty) >= 1.f )
    {
        Difficulty = AdjustedDifficulty;
        SaveConfig();
    }
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional out int bPlayHitEffects  )
{
    local float InstigatorSkill;
	local bool	bNonZero;

    Damage = Super.ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

    if ( instigatedBy == None)
        return Damage;

    if ( Level.Game.Difficulty <= 3.f )
    {
		bNonZero = Damage > 0;

        if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
            Damage *= 0.5;

        //skill level modification
        if ( AIController(instigatedBy.Controller) != None )
        {
            InstigatorSkill = AIController(instigatedBy.Controller).Skill;
            if ( (InstigatorSkill <= 3) && injured.IsHumanControlled() )
			{
				if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon) 
					|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
						Damage = Damage * (0.76 + 0.08 * InstigatorSkill);
				else
						Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
            }
        }
    } 
	if(bNonZero)
		return Max(1, (Damage * instigatedBy.DamageScaling));
	else
		return (Damage * instigatedBy.DamageScaling);
}

// amb ---
// Add one or num bots
exec function AddNamedBot(string botname)
{
    if (Level.NetMode != NM_Standalone)
        MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
    AddBot(botName);
}

exec function AddBots(int num)
{
    num = Clamp(num, 0, 32 - (NumPlayers + NumBots));

    while (--num >= 0)
    {
        if ( Level.NetMode != NM_Standalone )
            MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
        AddBot();
    }
}

// Kill all or num bots
exec function KillBots(int num)
{
    local Controller c, nextC;

    if (num == 0)
        num = NumBots;

    c = Level.ControllerList;
    while (c != None)
    {
        if (num <= 0)
            break;
        nextC = c.NextController;
        if (KillBot(c))
            --num;
        c = nextC;
    }
}

function bool KillBot(Controller c)
{
    local Bot b;

    b = Bot(c);
    if (b != None)
    {
        if (Level.NetMode != NM_Standalone)
            MinPlayers = Max(MinPlayers - 1, NumPlayers + NumBots - 1);
        if (b.Pawn != None)
            b.Pawn.Destroy();
		if (b != None)
        b.Destroy();
        return true;
    }
    return false;
}
// --- amb

function ReviewJumpSpots()
{
	local NavigationPoint StartSpot;
	local controller C;
	local Pawn P;
	local Bot B;
	local class<Pawn> PawnClass;
		
	B = spawn(class'Bot');
	B.Squad = spawn(class'DMSquad');
    startSpot = FindPlayerStart(B, 0);
	assert(DefaultPlayerClassName!="");
    PawnClass = class<Pawn>( DynamicLoadObject(DefaultPlayerClassName, class'Class') );
    P = Spawn(PawnClass,,,StartSpot.Location,StartSpot.Rotation);
	if ( P == None )
	{
		log("Failed to spawn pawn to reviewjumpspots");
		return;
	}
	B.Possess(P);
	B.GoalString = "TRANSLOCATING";
	
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( PlayerController(C) != None )
		{
			PlayerController(C).bBehindView = true;
			PlayerController(C).SetViewTarget(P);
			UnrealPlayer(C).ShowAI();
			break;
		}
			
	// first, check translocation	
	//XJ: no Translocator anymore
    //p.GiveWeapon("XWeapons.TransLauncher");
	B.GotoState('Testing');
}

function EvaluateHint(name EventName, Actor Target)
{
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting("Server", "NetWait",             default.DMPropsDisplayText[i++], 2,  40, "Text", "3;0:60");
	PlayInfo.AddSetting("Game",   "MinNetPlayers",       default.DMPropsDisplayText[i++], 1, 100, "Text", "3;0:32");
	PlayInfo.AddSetting("Server", "RestartWait",         default.DMPropsDisplayText[i++], 2,  42, "Text", "3;0:60");
	PlayInfo.AddSetting("Game",   "bTournament",         default.DMPropsDisplayText[i++], 1,  10, "Check");
	PlayInfo.AddSetting("Game",   "bPlayersMustBeReady", default.DMPropsDisplayText[i++], 1,  20, "Check");
	PlayInfo.AddSetting("Game",   "bForceRespawn",       default.DMPropsDisplayText[i++], 0,  40, "Check");
	PlayInfo.AddSetting("Bots",   "bAdjustSkill",        default.DMPropsDisplayText[i++], 0,  30, "Check");
	PlayInfo.AddSetting("Game",   "bAllowTaunts",        default.DMPropsDisplayText[i++], 0,  50, "Check");
}

defaultproperties
{
     NumRounds=1
     NetWait=2
     MinNetPlayers=1
     RestartWait=8
     CountDown=1
     EndMessageWait=2
     NextBotName=-1
     DMSquadClass=Class'UnrealGame.DMSquad'
     BotNames(0)="Stubbs"
     BotNames(1)="Stockton"
     BotNames(2)="Raphael"
     BotNames(3)="Jahal"
     BotNames(4)="Noah"
     BotNames(5)="Greo"
     BotNames(6)="Mick"
     BotNames(7)="Howie"
     BotNames(8)="Tonklin"
     BotNames(9)="Jones"
     BotNames(10)="Eddy"
     BotNames(11)="Garren"
     BotNames(12)="Mitchel"
     BotNames(13)="Jayton"
     BotNames(14)="Jared"
     BotNames(15)="Aaron"
     BotNames(16)="Lance"
     BotNames(17)="Morgan"
     DMPropsDisplayText(0)="Net Start Delay"
     DMPropsDisplayText(1)="Min. Net Players"
     DMPropsDisplayText(2)="Restart Delay"
     DMPropsDisplayText(3)="Tournament Game"
     DMPropsDisplayText(4)="Players Must Be Ready"
     DMPropsDisplayText(5)="Force Respawn"
     DMPropsDisplayText(6)="Adjust Bots Skill"
     DMPropsDisplayText(7)="Allow Taunts"
     bAllowTaunts=True
     GoalScore=30
     TimeLimit=15
     DefaultPlayerClassName="VehicleGame.VGPawn"
     ScoreBoardType="XInterfaceHuds.ScoreBoardDeathMatch"
     MapListType="XInterfaceMP.MapListDeathMatch"
     MapPrefix="DM"
     BeaconName="DM"
     GameName="Deathmatch"
     MutatorClass="UnrealGame.DMMutator"
     PlayerControllerClassName="VehicleGame.VehiclePlayer"
     bRestartLevel=False
     bPauseable=False
     bLoggingGame=True
}
