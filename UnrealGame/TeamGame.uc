//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatch
    config;
    
var UnrealTeamInfo          Teams[2];
var bool                    bScoreTeamKills;
var globalconfig bool       bBalanceTeams        "PI:Bots Balance Teams:Bots:0:20:Check";   // bots balance teams
var globalconfig bool       bPlayersBalanceTeams "PI:Players Balance Teams:Game:0:30:Check";    // players balance teams
var bool                    bSpawnInTeamArea;   // players spawn in marked team playerstarts
var config int              MaxTeamSize                  "PI:Max Team Size:Rules:1:50:Text;3";
var config float            FriendlyFireScale            "PI:Friendly Fire Scale:Game:1:110:Text;8"; //scale friendly fire damage by this value
var class<TeamAI>           TeamAIType[2];
var bool                    bScoreVictimsTarget;    // Should we check a victims target for bonuses
var bool                    bAssToAss;

// localized PlayInfo descriptions & extra info
var private localized string TGPropsDisplayText[4];

function PostBeginPlay()
{
    if (!IsOnConsole() && !bAssToAss)
        SetTeamStuff();
    Super.PostBeginPlay();
}

function PostLinearize()
{
    if (!bAssToAss)
        SetTeamStuff();
    Super.PostLinearize();
}

function SetTeamStuff()
{
    local int i;

    bAssToAss = true;

    for (i=0;i<2;i++)
    {
        Teams[i] = LevelRules.GetRoster(i);
        Teams[i].AI = Spawn(TeamAIType[i]);
        Teams[i].AI.Team = Teams[i];
        GameReplicationInfo.Teams[i] = Teams[i];
        log(Teams[i].TeamName$" AI is "$Teams[i].AI);
    }
    Teams[0].AI.EnemyTeam = Teams[1];
    Teams[1].AI.EnemyTeam = Teams[0];
    Teams[0].AI.SetObjectiveLists();
    Teams[1].AI.SetObjectiveLists();
	Teams[1].TeamColor.R=0;
	Teams[1].TeamColor.G=0;
	Teams[1].TeamColor.B=255;
	Teams[1].TeamColor.A=255;

	Teams[0].TeamColor.R=255;
	Teams[0].TeamColor.G=0;
	Teams[0].TeamColor.B=0;
	Teams[0].TeamColor.A=255;

}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
    local string InOpt;
    local class<TeamAI> InType;

    Super.InitGame(Options, Error);

    InOpt = ParseOption( Options, "RedTeamAI");
    if ( InOpt != "" )
    {
        log("RedTeamAI: "$InOpt);
        InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
        if ( InType != None )
            TeamAIType[0] = InType;  //FIXME - need const for red and blue
    }

    InOpt = ParseOption( Options, "BlueTeamAI");
    if ( InOpt != "" )
    {
        log("BlueTeamAI: "$InOpt);
        InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
        if ( InType != None )
            TeamAIType[1] = InType;  //FIXME - need const for red and blue
    }

    // gam ---
    InOpt = ParseOption( Options, "FriendlyFireScale");
    if( InOpt != "" )
    {
        log("FriendlyFireScale"@InOpt);
        FriendlyFireScale = float(InOpt);
    }
    // --- gam
}

function bool CanShowPathTo(PlayerController P, int TeamNum)
{
    return true;
}

function RestartPlayer( Controller aPlayer )    
{
    local TeamInfo BotTeam, OtherTeam;
    
    if ( bBalanceTeams && (Bot(aPlayer) != None) )
    {
        BotTeam = aPlayer.PlayerReplicationInfo.Team;
        if ( BotTeam == Teams[0] )
            OtherTeam = Teams[1];
        else
            OtherTeam = Teams[0];
            
        if ( OtherTeam.Size < BotTeam.Size - 1 )
        {
            if ( ChangeTeam(aPlayer, OtherTeam.TeamIndex) )
                UnrealTeamInfo(OtherTeam).SetBotOrders(Bot(aPlayer), None);
            //aPlayer.Destroy();
            //return;
        }
    }
    Super.RestartPlayer(aPlayer);
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
    Teams[0].AI.NotifyKilled(Killer,Killed,KilledPawn);
    Teams[1].AI.NotifyKilled(Killer,Killed,KilledPawn);
}

/* bad! bad! bad! jij ---
function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    at least make DefaultPlayerClass a string in TeamInfo so we can dynloadobect on it goddamnit!
    return UnrealTeamInfo(C.PlayerReplicationInfo.Team).DefaultPlayerClass;
}
--- jij */

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local Controller P, NextC;
    local PlayerController player;

    if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
        return false;

    if ( bTeamScoreRounds )
    {
        if ( Winner != None )
            Winner.Team.Score += 1;
    }
    else if ( Teams[1].Score == Teams[0].Score )
    {
        // tie
        BroadcastLocalizedMessage( GameMessageClass, 0 );
        return false;
    }       

    if ( Winner == None )
        GameReplicationInfo.Winner = self;
    else
        GameReplicationInfo.Winner = Winner.Team;

    EndTime = Level.TimeSeconds + 3.0;

    for ( P=Level.ControllerList; P!=None; P=NextC )
    {
        NextC = P.nextController;
        player = PlayerController(P);
        if ( Player != None )
        {
            PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Winner.Team));
            player.ClientSetBehindView(true);
            Player.SetViewTarget(Controller(Winner.Owner).Pawn);
            player.ClientGameEnded();
        }
        P.GotoState('GameEnded');
    }
    return true;
}

//------------------------------------------------------------------------------
// Player start functions

function Logout(Controller Exiting)
{
    Super.Logout(Exiting);
    if ( Exiting.IsA('PlayerController') && Exiting.PlayerReplicationInfo.bOnlySpectator )
        return;
    if ( Exiting.PlayerReplicationInfo.Team != None )
        Exiting.PlayerReplicationInfo.Team.RemoveFromTeam(Exiting);
}
                
//-------------------------------------------------------------------------------------
// Level gameplay modification


function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
    if ( ViewTarget.IsA('Controller') )
        return false;
    if ( bOnlySpectator )
        return true;
    return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn() 
        && (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

//------------------------------------------------------------------------------
// Game Querying.
function GetServerDetails( out ServerResponseLine ServerState )
{
    local int i;

    Super.GetServerDetails( ServerState );

    i = ServerState.ServerInfo.Length;

    //ServerState.ServerInfo.Length = i+1;
    //ServerState.ServerInfo[i].Key = "balanceteams";
    //ServerState.ServerInfo[i++].Value = string(bBalanceTeams);

    //ServerState.ServerInfo.Length = i+1;
    //ServerState.ServerInfo[i].Key = "playersbalanceteams";
    //ServerState.ServerInfo[i++].Value = string(bPlayersBalanceTeams);

    // minplayers
    ServerState.ServerInfo.Length = i+1;
    ServerState.ServerInfo[i].Key = "friendlyfire";

    if( FriendlyFireScale > 0.f )
    {
        ServerState.ServerInfo[i++].Value = "true";
    }
    else
    {
        ServerState.ServerInfo[i++].Value = "false";
    }
}


//------------------------------------------------------------------------------

function UnrealTeamInfo GetBotTeam()
{
    if ( Teams[0].NeedsBotMoreThan(Teams[1]) )
        return Teams[0];
    else
        return Teams[1];
}       

function UnrealTeamInfo FindTeamFor(Bot B)
{
    if ( Teams[0].BelongsOnTeam(B.Pawn.Class) )
        return Teams[0];
    if ( Teams[1].BelongsOnTeam(B.Pawn.Class) )
        return Teams[1];
    return LevelRules.GetDMRoster();
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num)
{
    local UnrealTeamInfo SmallTeam, BigTeam, NewTeam;

    SmallTeam = Teams[0];
    BigTeam = Teams[1];

    if ( SmallTeam.Size > BigTeam.Size )
    {
        SmallTeam = Teams[1];
        BigTeam = Teams[0];
    }

    if ( num < 2 )
        NewTeam = Teams[num];
    else if ( bPlayersBalanceTeams && (SmallTeam.Size < BigTeam.Size) )
        NewTeam = SmallTeam;

    if ( (NewTeam == None) || (NewTeam.Size >= MaxTeamSize) )
        NewTeam = SmallTeam;

    return NewTeam.TeamIndex;
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num)
{
    local UnrealTeamInfo NewTeam;

    if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
    {
        Other.PlayerReplicationInfo.Team = None;
        
        if ( GameStats!=None && PlayerController(Other)!=None )
            GameStats.GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
            
        return true;
    }

    NewTeam = Teams[PickTeam(num)];

    if ( NewTeam.Size >= MaxTeamSize )
        return false;   // no room on either team

    // check if already on this team
    if ( Other.PlayerReplicationInfo.Team == NewTeam )
        return false;

    Other.StartSpot = None;

    if ( Other.PlayerReplicationInfo.Team != None )
        Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

    if ( NewTeam.AddToTeam(Other) )
        BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );

    return true;
}


function string GetCharacterClass(TeamInfo MyTeam)
{
	//log("UUUUUU  GetCharacterClass checking class for "$NewPlayer$" with PRI "$NewPlayer.PlayerReplicationInfo$" and name "$NewPlayer.PlayerReplicationInfo.PlayerName);
	if(MyTeam == Teams[0])
	{
		return "TEAMPLAYERA";
	}
	else
	{
		return "TEAMPLAYERB";
	}
}


/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local PlayerStart P;

    P = PlayerStart(N);
    if ( P == None )
        return -10000000;
    if ( bSpawnInTeamArea && (Team != P.TeamNumber) )
        return -9000000;

    return Super.RatePlayerStart(N,Team,Player);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Leader[2];
    
    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;

    // check if all other players are out
    if ( MaxLives > 0 )
    {
        if ( !Scorer.bOutOfLives )
            Leader[Scorer.Team.TeamIndex] = Scorer;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( !C.PlayerReplicationInfo.bOutOfLives )
            {
                if ( Leader[C.PlayerReplicationInfo.Team.TeamIndex] == None )
                    Leader[C.PlayerReplicationInfo.Team.TeamIndex] = C.PlayerReplicationInfo;   
                if ( (Leader[0] != None) && (Leader[1] != None ) )
                    break;
            } 
        if ( Leader[0] == None )
        {
            EndGame(Leader[1],"LastMan");
            return;
        }
        else if ( Leader[1] == None )
        {
            EndGame(Leader[0],"LastMan");
            return;
        }
    }   

    //if ( LevelRules.bOnlyObjectivesWin )
    //  return;

    if (  !bOverTime && (GoalScore == 0) )
        return; 
    if ( (Scorer != None) && (Scorer.Team != None) && (Scorer.Team.Score >= GoalScore) )    
        EndGame(Scorer,"teamscorelimit");
    
    if ( (Scorer != None) && bOverTime )
    {
        EndGame(Scorer,"timelimit");
    }
}

function bool CriticalPlayer(Controller Other)
{
    if ((GameRulesModifiers != None) && (GameRulesModifiers.CriticalPlayer(Other)) )
        return true;
        
    return false;
}

// ==========================================================================
// FindVictimsTarget - Tries to determine who the victim was aiming at
// ==========================================================================

function Pawn FindVictimsTarget(Controller Other)
{

    local Vector Start,X,Y,Z;
    local float Dist,Aim;
    local Actor Target;

    if (Other==None || Other.Pawn==None || Other.Pawn.Weapon==None) // If they have no weapon, they can't be targetting someone
        return None;        

    GetAxes(Other.Pawn.GetViewRotation(),X,Y,Z);
    Start = Other.Pawn.Location + Other.Pawn.CalcDrawOffset(Other.Pawn.Weapon); 
    Aim = 0.97;
    Target = Other.PickTarget(aim,dist,X,Start,4000.f); //amb
    
    return Pawn(Target);

} 

function ScoreKill(Controller Killer, Controller Other)
{
    local Pawn Target;
    
    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer || !Killer.bIsPlayer 
        || (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
    {
        if ( false && (Killer!=None) && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
        {
            
            // Kill Bonuses work as follows (in additional to the default 1 point           
            /*
                +1 Point for killing an enemy targetting an important player on your team
                +2 Points for killing an enemy important player
            */
        
            if ( CriticalPlayer(Other) )
            {
                Killer.PlayerReplicationInfo.Score+= 1;
                if (GameStats!=None)
                    GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"critical_frag");
            }

            if (bScoreVictimsTarget)
            {
                Target = FindVictimsTarget(Other);
                if ( (Target!=None) && (Target.PlayerReplicationInfo!=None) && 
                       (Target.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) && CriticalPlayer(Other) )
                {
                    Killer.PlayerReplicationInfo.Score+=1;
                    if (GameStats!=None)
                        GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"team_protect_frag");
                }
            } 
                                        
        } 

        Super.ScoreKill(Killer, Other);
    }

    if ( !bScoreTeamKills )
        return;
    if ( Other.bIsPlayer && ((Killer == None) || Killer.bIsPlayer) )
    {
        if ( (Killer == Other) || (Killer == None) )
        {
            Other.PlayerReplicationInfo.Team.Score -= 1;
            if (GameStats!=None)
                GameStats.ScoreEvent(Other.PlayerReplicationInfo, -1, "self_frag");
        }
        else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
        {
            Killer.PlayerReplicationInfo.Team.Score += 1;
            if (GameStats!=None)
                GameStats.ScoreEvent(Killer.PlayerReplicationInfo, 1, "frag");
        }
        else if ( FriendlyFireScale > 0 )
        {
            Other.PlayerReplicationInfo.Team.Score -= 1;
            Killer.PlayerReplicationInfo.Score -= 1;
            if (GameStats!=None)
                GameStats.ScoreEvent(Killer.PlayerReplicationInfo, -1, "team_frag");

        }
    }

    // check score again to see if team won
    if (Killer != None) //amb
    CheckScore(Killer.PlayerReplicationInfo);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional out int bPlayHitEffects  )
{
    if ( instigatedBy == None )
        return Damage;

    if ( (instigatedBy != injured) && injured.IsPlayerPawn() && instigatedBy.IsPlayerPawn() 
        && (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) )
    {
        if ( FriendlyFireScale > 0.0 && injured.Controller.IsA('Bot') )
            Bot(Injured.Controller).YellAt(instigatedBy);
        
        if (FriendlyFireScale==0.0)
            return 0;
    
        Damage *= FriendlyFireScale;
    }
    
    Damage = Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
        return Damage;
}

// amb ---
function bool SameTeam(Controller a, Controller b)
{
    if(( a == None ) || ( b == None ))
        return( false );

    return (a.PlayerReplicationInfo.Team.TeamIndex == b.PlayerReplicationInfo.Team.TeamIndex);
}

function bool TooManyBots(Controller botToRemove)
{ 
    if (IsCoopGame())
        return CoopInfo.RemoveBotQuery(botToRemove);
    
    return Super.TooManyBots(botToRemove);
}
// --- amb

// jij ---
State MatchOver
{
    function Timer()
    {
        local Controller C;        
        
        EndMessageCounter++;

        Super.Timer();

        // play end-of-match message for winning team (for single and muli-player)
        if (!(EndMessageCounter == EndMessageWait))
                return;        
            
        if ((NumPlayers == 2 && NumBots == 0) || (NumPlayers == 1 && NumBots == 1))
        {
            for ( C = Level.ControllerList; C != None; C = C.NextController )
            {
                if ( C.IsA('PlayerController') )
                {
                    if (Teams[0].Score > Teams[1].Score)
                        PlayerController(C).PlayAnnouncement(AltEndGameSound[0],1,true);
                    else
                        PlayerController(C).PlayAnnouncement(AltEndGameSound[1],1,true);
                }
            }
        }
        else
        {
            for ( C = Level.ControllerList; C != None; C = C.NextController )
            {
                if ( C.IsA('PlayerController') )
                {
                    if (Teams[0].Score > Teams[1].Score)
                        PlayerController(C).PlayAnnouncement(EndGameSound[0],1,true);
                    else
                        PlayerController(C).PlayAnnouncement(EndGameSound[1],1,true);
                }
            }
        }
    }
}
// --- jij

//-----------------------------------------------------------------------------
// Voice (Team-based over-rides for channel assignment & joining)
// jij ---
function bool IsVoiceChannelValid(PlayerController Client, int Channel)
{
    // upper channels are 'neutral' and both teams may join them (6 - 8)
    if (Channel >= 6)
        return true;
    
    // red team (even channels only)
    if (Client.PlayerReplicationInfo.Team.TeamIndex == 0)
    {
        if ((Channel & 1) == 1) // I hate UnrealScript...
            return false;
        else
            return true;
    }

    // blue team (odd channels only)
    if ((Channel & 1) == 1) // ...so very much
        return true;
    else
        return false;
}
// --- jij

function string ParseChatPercVar(controller Who, string Cmd)
{
    //local xPickupBase B;
    local GameObjective GO;
    local actor Closest;
    local float dist;
    //local string near,where;

    
    if (Who.Pawn==None)
        return Cmd;
        
    if (cmd~="%H")
        return Who.Pawn.Health$" Health";
        
    if (cmd~="%W")
    {

        if (Who.Pawn.Weapon!=None)
            return Who.Pawn.Weapon.RetrivePlayerName();
        else
            return "Bare Handed";
    }
    
    if (cmd=="%%")
        return "%";
    
    if (cmd~="%L")
    {

        dist=-1.0;      
        
        foreach AllActors(class 'GameObjective',GO)
        {

            if (dist<0)
            {
                dist = vsize(GO.location - Who.Pawn.Location);
                Closest = GO;
            }
            else
            {
                if (vsize(GO.location - Who.Pawn.Location) < dist)
                {
                    dist = vsize(Go.location - Who.Pawn.Location);
                    Closest=Go;
                }
            }
        }

		/*
        if ( (Go==None) || (vsize(GO.location - Who.Pawn.Location) >1024) ) // Look for closer objects
        {               
            
            foreach AllActors(class 'xPickupBase', b)
            {
        
                if (B.Region.Zone == Who.Pawn.Region.Zone)
                {
        
                    if ( (b.Powerup!=None) && (b.Powerup.default.InventoryType!=none) )
                        near = b.Powerup.default.InventoryType.static.StaticItemName();
                    else
                        near = "";
                    
                    if (near!="")
                    {
                        if (dist<0)
                        {
                            dist = vsize(b.location - Who.Pawn.Location);
                            Closest = b;
                        }
                        else
                        {
                            if (vsize(b.location - Who.Pawn.Location) < dist)
                            {
                                dist = vsize(b.location - Who.Pawn.Location);
                                Closest=b;
                            }
                        }
                    }
                }
            } 

        }   
		*/
        if (Closest!=None)
        {
            if (GameObjective(Closest)!=None )
                return "near the"@GameObjective(Closest).RetrivePlayerName();
			/*
            else
            {
                near = xPickupBase(Closest).Powerup.default.InventoryType.static.StaticItemName();
                where = Level.Game.FindTeamDesignation(Closest);
                
                if (Where=="")
                    return "near the"@Near;
                else
                    return "near the"@where@near;
            }
			*/
        }  
    }

    return Super.ParseChatPercVar(Who,Cmd);
    
}

function string ParseMessageString(Controller Who, String Message)
{
    local string OutMsg;
    local string cmd;
    local int pos,i;

    OutMsg = "";
    pos = InStr(Message,"%");
    while (pos>-1) 
    {
        if (pos>0)
        {
          OutMsg = OutMsg$Left(Message,pos);
          Message = Mid(Message,pos);
          pos = 0;
        }

        i = len(Message);
        cmd = mid(Message,pos,2);
        if (i-2 > 0)
            Message = right(Message,i-2);
        else
            Message = "";

        OutMsg = OutMsg$ParseChatPercVar(Who,Cmd);
        pos = InStr(Message,"%");
    }

    if (Message!="")
        OutMsg=OutMsg$Message;
    
    return OutMsg;
}

function FindNewObjectives(GameObjective DisabledObjective)
{
    Teams[0].AI.FindNewObjectives(DisabledObjective);
    Teams[1].AI.FindNewObjectives(DisabledObjective);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting("Bots",  "bBalanceTeams",        default.TGPropsDisplayText[i++], 0,  20, "Check");
	PlayInfo.AddSetting("Game",  "bPlayersBalanceTeams", default.TGPropsDisplayText[i++], 0,  30, "Check");
	PlayInfo.AddSetting("Rules", "MaxTeamSize",          default.TGPropsDisplayText[i++], 1,  50, "Text", "3;0:16");
	PlayInfo.AddSetting("Rules", "FriendlyFireScale",    default.TGPropsDisplayText[i++], 1,  10, "Text", "8;0.0:1.0");
}

defaultproperties
{
     MaxTeamSize=16
     TeamAIType(0)=Class'UnrealGame.TeamAI'
     TeamAIType(1)=Class'UnrealGame.TeamAI'
     TGPropsDisplayText(0)="Bots Balance Teams"
     TGPropsDisplayText(1)="Players Balance Teams"
     TGPropsDisplayText(2)="Max Team Size"
     TGPropsDisplayText(3)="Friendly Fire Scale"
     bScoreTeamKills=True
     bBalanceTeams=True
     bPlayersBalanceTeams=True
     EndMessageWait=3
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
     MaxLives=1
     NumVoiceChannels=9
     BeaconName="Team"
     GameName="Team Deathmatch"
     bCanChangeSkin=False
     bTeamGame=True
}
