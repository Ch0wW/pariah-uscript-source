class MiniAssault extends TeamGame;

#exec OBJ LOAD File="PariahAnnouncer.uax"

var MiniAssaultObjective theObjective;	// the objective which is being defended by, we'll say, team 0
var bool bObjectiveEnabled;

//var AssaultBase theBase;			// the base associated with the objective, nyo

var int ResetCountDown;				// count down until the next round
var int AttackTeamIdx;
var int DefendTeamIdx;
var int SecondsBeforeSwitch;
var float SecondsPerSide;

function PostBeginPlay()
{
    local xUtil.PlayerRecord PlayerRecord;
    local Array <xUtil.WeaponRecord> WeaponRecords;
    
    Super.PostBeginPlay();
    
	log( "Precaching MP resources..." );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerA");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerB");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
        	
	class'xUtil'.static.GetWeaponList( WeaponRecords );
}

event InitGame( string Options, out string Error )
{
    Super.InitGame(Options, Error);
    
    // calc seconds per side so that for each match you will have at least two rounds A->B and B->A
	// 150 seconds
	
	SecondsPerSide = 60 * 5; // 5 mins for no-timelimit cases

	if(TimeLimit != 0)
	{
	    SecondsPerSide = float(RemainingTime) / 2;
    	
	    while(SecondsPerSide > 60 * 5)
	    {
	        SecondsPerSide /= 2;
	    }
    }
	
	log(">>> MiniAssault - SecondsPerSide:"@SecondsPerSide@" TotalTime:"@RemainingTime);

	SecondsBeforeSwitch = SecondsPerSide;
}

event PostLogin(PlayerController NewPlayer)
{
    Super.PostLogin(NewPlayer);
    Inform(NewPlayer);   
}

function RestartPlayer( Controller aPlayer )
{
    Super.RestartPlayer(aPlayer);
    Inform(PlayerController(aPlayer));
}

function SetTeamStuff()
{
	Super.SetTeamStuff();

	InitMiniAssault();
}

function ResetObjective()
{
	local Projectile p;

    ForEach AllActors(class'Projectile', p)
	{
		p.Destroy();
	}
	
    theObjective.Reset();
	theObjective.DefenderTeamIndex = DefendTeamIdx;
	GameReplicationInfo.ObjectiveDamage[0] = 255;
}

function InitMiniAssault()
{
	local MiniAssaultObjective ao;

	// find the objective
	foreach AllActors(class'MiniAssaultObjective', ao)
	{
		theObjective = ao;
	}
	assert(theObjective != none);
    ResetObjective();
	SecondsBeforeSwitch = SecondsPerSide;
}

// I think this gets called when the objective is destroyed... yes, this is the case
function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
    Scorer.Team.Score += 1.0;
    Super.ScoreObjective(Scorer, Score);
    ResetObjective();
    Freshen();
}

function Inform(PlayerController NewPlayer) // state only
{
}

function Freshen()
{
    local Controller C;
	local VGVehicle v;
	local VehicleStart vs;
	
    // reset all players position and rotation on the field for the next round
    for ( C = Level.ControllerList; C != None; C = C.NextController )
    {
		// for the moment we'll only reset player controllers 'cause it appears to be doing something funny to the turrets
		if(C.IsA('PlayerController') )
			ResetController(C);
    }

	//kill extra vehicles, reset counts
	ResetVehicleCounts();

	ForEach AllActors(class'VGVehicle', v)
	{
		v.Destroy();
	}
	
	ForEach AllActors(class'VehicleStart', vs)
	{
		vs.VehicleDied();
	}
}

State MatchInProgress
{
    function BeginState()
    {    
        local Controller C;
        for ( C = Level.ControllerList; C != None; C = C.NextController )
        {
	        Inform(PlayerController(C));
        }
        Super.BeginState();
    }
    function Inform(PlayerController NewPlayer)
    {
        if(NewPlayer == None)
        {
            return;
        }
        if(NewPlayer.PlayerReplicationInfo.Team.TeamIndex == DefendTeamIdx)
        {
            NewPlayer.ReceiveLocalizedMessage(class'SiegeHUDMessage', 0);    
        }
        else
        {
            NewPlayer.ReceiveLocalizedMessage(class'SiegeHUDMessage', 1);
        }
    }
	function Timer()
	{
		local PlayerStart start;
        local Controller C;

        Super.Timer();
        
        SecondsBeforeSwitch--;
        
        if(SecondsBeforeSwitch < 11 && ResetCountDown == 0)
        {
            ResetCountdown = SecondsBeforeSwitch;
        }

        if (ResetCountDown > 0)
        {
            ResetCountDown--;

            if (ResetCountDown <= 10 && ResetCountDown > 0)
                BroadcastLocalizedMessage(class'xTimerMessage', ResetCountDown);

            if (ResetCountDown == 0)
            {
                if(GameReplicationInfo.ObjectiveDamage[0] > 0)
                {
                    GameReplicationInfo.Teams[DefendTeamIdx].Score += 1.0;

					// find a controller from defending team to use when calling CheckScore
					//
					for ( C = Level.ControllerList; C != None; C = C.NextController )
					{
						if ( C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team.TeamIndex == DefendTeamIdx )
						{
							CheckScore( C.PlayerReplicationInfo );
							break;
						}
					}
                }

				if ( bOverTime )
				{
					EndGame(None,"timelimit");
				}
            
				// swap defend and attack teams
				if(DefendTeamIdx == 0) 
				{
					DefendTeamIdx = 1;
					AttackTeamIdx = 0;
				}
				else 
				{
					DefendTeamIdx = 0;
					AttackTeamIdx = 1;
				}

				foreach AllActors(class'PlayerStart', start) 
				{
					if(start.TeamNumber == 0)
						start.TeamNumber = 1;
					else
						start.TeamNumber = 0;
				}
                ResetCountDown = 0;
				InitMiniAssault();
				Freshen();
            }
        }
    }
}

function ResetController(Controller C)
{
	local VGPawn p;
	local int TeamNum;

	TeamNum = C.PlayerReplicationInfo.Team.TeamIndex;

	log("!!! Resetting Controller "$C);
	C.StartSpot = FindPlayerStart(C,TeamNum);

	log("    Got Start Spot "$C.StartSpot);

	C.SetLocation(C.StartSpot.Location);
    C.SetRotation(C.StartSpot.Rotation);
    
    if(C.Pawn != None)
    {	
	    if(C.Pawn.IsA('VGVehicle') ) 
	    {
		    VGVehicle(C.Pawn).DriverExits();
	    }
	    else//pawn is a VGPawn
	    {
		    p = VGPawn(C.Pawn);
		    if(p.RiddenVehicle != None) //riding a vehicle, get out
		    {
			    p.RiddenVehicle.EndRide(p);
		    }
		    if(p.RiddenTurret != None )
		    {
			    p.RiddenTurret.EndRide(p);
		    }
			if(p.OwnedVehicle!=None)
		    {
			    p.OwnedVehicle.Destroy();
			    p.OwnedVehicle=None;
		    }
		}
	    C.Pawn.Velocity = vect(0,0,0);
	    C.Pawn.SetLocation(C.StartSpot.Location);
	    C.Pawn.SetRotation(C.StartSpot.Rotation);
		C.Pawn.Health = C.Pawn.HealthMax;
    }
	
	VehiclePlayer(C).GiveLoadout();
	C.ClientSetLocation(C.StartSpot.Location,C.StartSpot.Rotation);
	Inform(PlayerController(C));
}

defaultproperties
{
     AttackTeamIdx=1
     TeamAIType(0)=Class'VehicleGame.AssaultTeamAI'
     TeamAIType(1)=Class'VehicleGame.AssaultTeamAI'
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     EndGameSound(0)=Sound'PariahAnnouncer.red_team_wins'
     EndGameSound(1)=Sound'PariahAnnouncer.blue_team_wins'
     AltEndGameSound(0)=Sound'PariahAnnouncer.you_have_won_the_game'
     AltEndGameSound(1)=Sound'PariahAnnouncer.you_have_lost_the_game'
     LevelRulesClass=Class'XGame.xLevelGameRules'
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
     MaxPlayersOnDedicated=12
     MaxPlayersOnListen=6
     GoalScore=20
     MinGoalScore=10
     MaxLives=0
     ListPriority=6
     DeathMessageClass=Class'XGame.xDeathMessage'
     GameReplicationInfoClass=Class'VehicleGame.AssaultReplicationInfo'
     ScoreBoardType="XInterfaceHuds.ScoreBoardTeamDeathMatch"
     HUDType="VehicleInterface.MiniAssaultHud"
     MapListType="XInterfaceMP.MapListMiniAssault"
     MapPrefix="XSG"
     GameName="Siege"
     ScreenshotName="PariahMapThumbNails.GameTypes.FrontLineAssault"
     DecoTextName="XGame.Assault"
     Acronym="SG"
     VehicleRegenTime=5
     bCustomMaps=True
}
