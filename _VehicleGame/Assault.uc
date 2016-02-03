class Assault extends TeamGame;

#exec OBJ LOAD File="PariahAnnouncer.uax"

var array<AssaultSpawn> AssaultSpawns;

var array<AssaultObjective> WhiteAssaultObjectives;
var bool bWhiteObjectivesEnabled;
var array<AssaultObjective> BlackAssaultObjectives;
var bool bBlackObjectivesEnabled;

var AssaultBase Bases[2];

var AssaultSpawn NeutralSpawn;

var int NumSpawns;

var int   ResetCountDown;

var sound PushingForward[2];
var sound AtEnemyBase[2];

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

function SetTeamStuff()
{
	Super.SetTeamStuff();

	InitAssault();

 	AssaultTeamAI(Teams[0].AI).AssaultGameInfo = self;
 	AssaultTeamAI(Teams[1].AI).AssaultGameInfo = self;

}

function InitAssault()
{
	local int i, spawncount;
	local AssaultSpawn TempSpawns[10];
	local AssaultSpawn spawn;
	local AssaultObjective ao;
	local AssaultBase ab;
	local PlayerStart start;
	local float dist, nearsdist, nearbdist;
	local int nearsindex, nearbindex;
	local DumbTurret turret;
	//local VehicleSpawnPad vehiclepad;
	//local VehicleTeleportPad teleportpad;
	local VehicleStart vstart;

	ForEach AllActors(class'AssaultBase', ab)
	{
		assert(ab.TeamIndex==0 || ab.TeamIndex==1);
		ab.EnableSpawn(False,255);
		ab.PlayerStarts.Remove(0,ab.PlayerStarts.Length);
		Bases[ab.TeamIndex]=ab;
		log("AssaultBase found "$ab.TeamIndex);
	}
	assert(Bases[0]!=None && Bases[1]!=None);


	ForEach AllActors(class'AssaultSpawn', spawn)
	{
		TempSpawns[spawn.OrderIndex]=spawn;
		spawn.EnableSpawn(False, 255);
		spawn.PlayerStarts.Remove(0,spawn.PlayerStarts.Length);
		log("CHARLES:  Foundspawn "$spawn.OrderIndex);
		spawncount++;
	}
	//
	NumSpawns=Spawncount;

	if(spawncount%2==0) //even number of assault spawns.  Bad mojo.
	{
		log("CHARLES: Even number of assault spawns.  Unbalanced map!",'Error');
	}

	ForEach AllActors(class'PlayerStart', start)
	{
		//find the closest AssaultSpawn and associate it.
		nearsdist=100000000;
		nearbdist=100000000;
		nearsindex=-1;
		nearbindex=-1;
		for(i=0;i<NumSpawns;i++)
		{
			dist= VSize(start.Location - TempSpawns[i].Location);
			if(dist < nearsdist)
			{
				nearsdist=dist;
				nearsindex=i;
			}
		}

		for(i=0;i<2;i++)
		{
			dist= VSize(start.Location - Bases[i].Location);
			if(dist < nearbdist)
			{
				nearbdist=dist;
				nearbindex=i;
			}
		}

		if(nearbdist<nearsdist)
		{
			Bases[nearbindex].PlayerStarts[Bases[nearbindex].PlayerStarts.Length]=start;
		}
		else
		{		
			TempSpawns[nearsindex].PlayerStarts[TempSpawns[nearsindex].PlayerStarts.Length]=start;
		}
	}

	ForEach AllActors(class'DumbTurret',turret)
	{
		nearsdist=100000000;
		nearsindex=-1;
		
		for(i=0;i<NumSpawns;i++)
		{
			dist= VSize(turret.Location - TempSpawns[i].Location);
			if(dist < nearsdist)
			{
				nearsdist=dist;
				nearsindex=i;
			}
		}

		assert(nearsindex!=-1);
		TempSpawns[nearsindex].Turrets[TempSpawns[nearsindex].Turrets.Length]=turret;
		log(turret.name$" added to spawn "$TempSpawns[nearsindex].orderindex);
		
	}

	//ForEach AllActors(class'VehicleSpawnPad',vehiclepad)
	//{
	//	nearsdist=100000000;
	//	nearsindex=-1;
	//	
	//	for(i=0;i<NumSpawns;i++)
	//	{
	//		dist= VSize(vehiclepad.Location - TempSpawns[i].Location);
	//		if(dist < nearsdist)
	//		{
	//			nearsdist=dist;
	//			nearsindex=i;
	//		}
	//	}

	//	assert(nearsindex!=-1);
	//	TempSpawns[nearsindex].VehiclePads[TempSpawns[nearsindex].VehiclePads.Length]=vehiclepad;
	//	log(vehiclepad.name$" added to spawn "$TempSpawns[nearsindex].orderindex);
	//	
	//}


	//ForEach AllActors(class'VehicleTeleportPad',teleportpad)
	//{
	//	nearsdist=100000000;
	//	nearsindex=-1;
	//	
	//	for(i=0;i<NumSpawns;i++)
	//	{
	//		dist= VSize(teleportpad.Location - TempSpawns[i].Location);
	//		if(dist < nearsdist)
	//		{
	//			nearsdist=dist;
	//			nearsindex=i;
	//		}
	//	}

	//	assert(nearsindex!=-1);
	//	TempSpawns[nearsindex].TeleportPads[TempSpawns[nearsindex].TeleportPads.Length]=teleportpad;
	//	log(teleportpad.name$" added to spawn "$TempSpawns[nearsindex].orderindex);
	//	
	//}

	ForEach AllActors(class'VehicleStart',vstart)
	{
		nearsdist=100000000;
		nearsindex=-1;
		
		if(vstart.bGametypeIndependant) continue;

		for(i=0;i<NumSpawns;i++)
		{
			dist= VSize(vstart.Location - TempSpawns[i].Location);
			if(dist < nearsdist)
			{
				nearsdist=dist;
				nearsindex=i;
			}
		}

		assert(nearsindex!=-1);
		TempSpawns[nearsindex].VehicleStarts[TempSpawns[nearsindex].VehicleStarts.Length]=vstart;
		log(vstart.name$" added to spawn "$TempSpawns[nearsindex].orderindex);
		
	}


	ForEach AllActors(class'AssaultObjective', ao)
	{
		if(ao.DefenderTeamIndex==0)
		{
			log("CHARLES:  Found White Assault Objective");
			WhiteAssaultObjectives[WhiteAssaultObjectives.Length]=ao;
		}
		else
		{
			log("CHARLES:  Found Black Assault Objective");
			BlackAssaultObjectives[BlackAssaultObjectives.Length]=ao;
		}
	}

	for(i=0;i<NumSpawns;i++)
	{
		AssaultSpawns[i]=TempSpawns[i];
		AssaultSpawns[i].EnableSpawn(False, 255);
		log("Assault Spawn has "$AssaultSpawns[i].PlayerStarts.Length$" playerstarts");
	}

	Bases[0].EnableSpawn(false,255);
	Bases[1].EnableSpawn(false,255);

	ResetGame();

}

exec function testspawns()
{
	local int i;

	log("Base 0:");
	Bases[0].listspawninfo();


	for(i=0;i<NumSpawns;i++)
	{
		log("Spawn "$i$" TeamIndex:"@AssaultSpawns[i].DefenderTeamIndex);
		AssaultSpawns[i].listspawninfo();
	}

	log("Base 1:");
	Bases[1].listspawninfo();

}

// a debug function to double check that spawn points are being set and enabled correctly
function SetSpawns(int neutral)
{
	local int i;

	//disable ALL spawns
	Bases[0].EnableSpawn(false, 255);
	Bases[1].EnableSpawn(false, 255);
	for(i=0;i<NumSpawns;i++)
	{
		AssaultSpawns[i].EnableSpawn(false, 255);
	}

	//enable just the wanted spawns

	if(neutral==0) //neutral is at white base
	{
		Bases[0].EnableSpawn(true, 0);
		AssaultSpawns[0].EnableSpawn(true, 0);
	}
	else
	{
		AssaultSpawns[neutral-1].EnableSpawn(true, 0);
		if(neutral-1 == 0)
		{
			Bases[0].EnableSpawn(true, 0);
		}
	}

	if(neutral==NumSpawns-1) //neutral is at black base
	{
		Bases[1].EnableSpawn(true, 1);
		AssaultSpawns[NumSpawns-1].EnableSpawn(true, 1);
	}
	else
	{
		AssaultSpawns[neutral+1].EnableSpawn(true, 1);
		if(neutral+1 == NumSpawns-1)
		{
			Bases[1].EnableSpawn(true, 1);
		}
	}
	
}

function ResetGame()
{
	local int i;
	local AssaultObjective ao;

	AssaultReplicationInfo(GameReplicationInfo).GameObjStates[0]=GOS_Home;
	

	ForEach AllActors(class'AssaultObjective', ao)
	{
		ao.Reset();
		ao.bDisabled=True;
	}

	EnableWhiteObjectives(False);
	EnableBlackObjectives(False);

	for(i=0;i<NumSpawns;i++)
	{
		AssaultSpawns[i].ResetAssaultPoint(True);
		if(i< NumSpawns/2) //it's a 0 team spawn
		{
			//AssaultSpawns[i].ControllingTeam=Teams[0];
			AssaultSpawns[i].bForceUpdate=True;
			//AssaultSpawns[i].DefenderTeamIndex = 0;
			log("Setting "$i$" to "$Teams[0]);
			AssaultSpawns[i].UpdateStatus(Teams[0]);
			AssaultSpawns[i].SetTurrets(0);
			AssaultSpawns[i].CallEvent(AS_Reset);
		}
		else if(i == NumSpawns/2) //middle point
		{
			AssaultSpawns[i].bForceUpdate=True;
			AssaultSpawns[i].UpdateStatus();
			AssaultSpawns[i].DefenderTeamIndex = 255;
			AssaultSpawns[i].SetTurrets(-1);
			AssaultSpawns[i].CallEvent(AS_Reset);
			
			log("Setting "$i$" to no team");

			NeutralSpawn=AssaultSpawns[i];
			AssaultReplicationInfo(GameReplicationInfo).FlagPos[0] = NeutralSpawn.Location + Vect(0,0,50);
			AssaultReplicationInfo(GameReplicationInfo).AssaultBar = 128;

		}
		else
		{
			//AssaultSpawns[i].ControllingTeam=Teams[1];
			AssaultSpawns[i].bForceUpdate=True;
			//AssaultSpawns[i].DefenderTeamIndex = 1;
			log("Setting "$i$" to "$Teams[0]);
			AssaultSpawns[i].UpdateStatus(Teams[1]);
			AssaultSpawns[i].SetTurrets(1);
			AssaultSpawns[i].CallEvent(AS_Reset);

		}


	}
	AssaultSpawns[0].BaseTeamIndex=0;
	AssaultSpawns[0].bIsBase=True;
	AssaultSpawns[NumSpawns-1].BaseTeamIndex=1;
	AssaultSpawns[NumSpawns-1].bIsBase=True;
	
	//set front line spawns

	AssaultSpawns[NeutralSpawn.OrderIndex-1].EnableSpawn(True, 0);
	AssaultSpawns[NeutralSpawn.OrderIndex-1].EnableVehicleStarts(True);
	AssaultReplicationInfo(GameReplicationInfo).Team1NextPoint = AssaultSpawns[NeutralSpawn.OrderIndex-1].Location;
	AssaultSpawns[NeutralSpawn.OrderIndex+1].EnableSpawn(True, 1);
	AssaultSpawns[NeutralSpawn.OrderIndex+1].EnableVehicleStarts(True);
	AssaultReplicationInfo(GameReplicationInfo).Team0NextPoint = AssaultSpawns[NeutralSpawn.OrderIndex+1].Location;
	
	SetSpawns(NeutralSpawn.OrderIndex);

	//reset AI Objectives
	ResetAIObjectives();
}

function ResetAIObjectives()
{
	AssaultTeamAI(Teams[0].AI).ResetSquadObjectives();
 	AssaultTeamAI(Teams[1].AI).ResetSquadObjectives();
}


function SetNeutralPoint(AssaultSpawn NewNeutral)
{
 	local AssaultSpawn oldNeutral;
	local AssaultSpawn Old1,Old0,New1,New0;

	//clear front lines
	if(NeutralSpawn.OrderIndex > 0)
	{
		AssaultSpawns[NeutralSpawn.OrderIndex-1].EnableSpawn(False, 255);
		Old0 = AssaultSpawns[NeutralSpawn.OrderIndex-1];
	}

	if(NeutralSpawn.OrderIndex < (NumSpawns-1))
	{
		Old1 = AssaultSpawns[NeutralSpawn.OrderIndex+1];
		AssaultSpawns[NeutralSpawn.OrderIndex+1].EnableSpawn(False, 255);
	}


	if(NewNeutral.DefenderTeamIndex==0)
	{
		NeutralSpawn.UpdateStatus(Teams[1]);
		NeutralSpawn.DefenderTeamIndex=1;
		NeutralSpawn.SetTurrets(1);
	}
	else
	{
		NeutralSpawn.UpdateStatus(Teams[0]);
		NeutralSpawn.DefenderTeamIndex=0;
		NeutralSpawn.SetTurrets(0);
	}

	NewNeutral.bForceUpdate=True;
	NewNeutral.DefenderTeamIndex=255;
	NewNeutral.UpdateStatus();							
	NewNeutral.EnableSpawn(False,255);
	NewNeutral.SetTurrets(-1);
	NewNeutral.bIsNeutral=True;
	NewNeutral.CallEvent(AS_Neutral);
	NeutralSpawn.bIsNeutral=False;
	NeutralSpawn.ResetAssaultPoint();
	oldNeutral = NeutralSpawn;
	NeutralSpawn=NewNeutral;
	
	AssaultReplicationInfo(GameReplicationInfo).FlagPos[0] = NeutralSpawn.Location + Vect(0,0,50);
	AssaultReplicationInfo(GameReplicationInfo).AssaultBar = 128;
	AssaultReplicationInfo(GameReplicationInfo).GameObjStates[0]=GOS_Home;
	//log("GI: GameReplicationInfo.FlagPos = "$GameReplicationInfo.FlagPos);

	//set the new front lines
	if(NeutralSpawn.OrderIndex > 0)
	{
		AssaultSpawns[NeutralSpawn.OrderIndex-1].EnableSpawn(True, 0);
		New0 = AssaultSpawns[NeutralSpawn.OrderIndex-1];
		EnableWhiteObjectives(False);
		AssaultReplicationInfo(GameReplicationInfo).Team1NextPoint = New0.Location;
	}
	else //front line is at White base, enable objectives
	{
		//log("Charles: Enabling White Objectives");
		NeutralSpawn.GotoState('AutoCapture');
		EnableWhiteObjectives(True);
		AssaultReplicationInfo(GameReplicationInfo).Team1NextPoint = Vect(0,0,0);
	}

	if(NeutralSpawn.OrderIndex < NumSpawns-1)
	{
		AssaultSpawns[NeutralSpawn.OrderIndex+1].EnableSpawn(True, 1);
		New1 = AssaultSpawns[NeutralSpawn.OrderIndex+1];
		EnableBlackObjectives(False);
		AssaultReplicationInfo(GameReplicationInfo).Team0NextPoint = New1.Location;
	}
	else //front line is at Black base, enable objectives
	{
		//log("Charles: Enabling Black Objectives");
		NeutralSpawn.GotoState('AutoCapture');
		EnableBlackObjectives(True);
		AssaultReplicationInfo(GameReplicationInfo).Team0NextPoint = Vect(0,0,0);
	}

	if(New1!=None && Old1!=None)
	{
		New1.InheretVehicleSpawns(Old1);
	}

	if(New0!=None && Old0!=None)
	{
		New0.InheretVehicleSpawns(Old0);
	}

	SetSpawns(NeutralSpawn.OrderIndex);

	//Update all the AI squads who need to focus on the new front
 	FindNewObjectives(oldNeutral);

}

function PlayMessageSound(sound s)
{
    local controller c;

    for ( c=Level.ControllerList; c!=None; c=c.NextController )
        if ( c.IsA('PlayerController') )
            PlayerController(c).PlayAnnouncement(s,2,true);
}


function ScoreFrontline(PlayerReplicationInfo PRI, TeamInfo RealTeam, AssaultSpawn Spawn)
{
	local int team;
	local int i;
	
	if(PRI!=None)
	{
		if(PRI.Team == RealTeam)
			PRI.Score+=3;
		RealTeam.Score+=1;

		BroadcastLocalizedMessage( class'AssaultMessage', 0, PRI, None, RealTeam );
		team = RealTeam.TeamIndex;
		CheckScore(PRI);
	}
	else //reverting point, no capturer
	{
		BroadcastLocalizedMessage( class'AssaultMessage',4,None,None,Spawn);
		if(Spawn.OrderIndex==0)
			team=0;
		else
			team=1;
	}
	
	if(team==0)
	{
		Assault(Level.Game).SetNeutralPoint(AssaultSpawns[Spawn.OrderIndex+1]);
		if(Spawn.OrderIndex+1 < NumSpawns-1)
		{
			PlayMessageSound(PushingForward[0]);
		}
	}
	else
	{
		Assault(Level.Game).SetNeutralPoint(AssaultSpawns[Spawn.OrderIndex-1]);
		if(Spawn.OrderIndex-1 > 0)
		{
			PlayMessageSound(PushingForward[1]);
		}
	}

	//Update all the AI squads who need to focus on the new front
 	if(team==0)
	{
		for(i=0;i<WhiteAssaultObjectives.Length;i++)
		{
			FindNewObjectives(WhiteAssaultObjectives[i]);
		}
	}
	else
	{
		for(i=0;i<BlackAssaultObjectives.Length;i++)
		{
			FindNewObjectives(BlackAssaultObjectives[i]);
		}
	}

	
}

function EnableWhiteObjectives(bool bEnable)
{
	local int i;
	if(bEnable)
	{
		AssaultReplicationInfo(GameReplicationInfo).FlagPos[0] = WhiteAssaultObjectives[0].Location + Vect(0,0,50);
		AssaultReplicationInfo(GameReplicationInfo).ObjectiveDamage[0] = 255.0 * (float(WhiteAssaultObjectives[0].Health) / float(WhiteAssaultObjectives[0].DamageCapacity));
		AssaultReplicationInfo(GameReplicationInfo).GameObjStates[1] = GOS_HeldRed;
		for(i=0;i<WhiteAssaultObjectives.Length;i++)
		{
			WhiteAssaultObjectives[i].bDisabled=False;
		}
		PlayMessageSound(AtEnemyBase[1]);
		bWhiteObjectivesEnabled=True;
		AssaultSpawns[0].EnableSpawn(True,0);
		Bases[0].EnableSpawn(True,0);
	}
	else
	{
		if(bWhiteObjectivesEnabled) //only disable if enabled
		{
			AssaultReplicationInfo(GameReplicationInfo).GameObjStates[1] = GOS_Dropped;
			bWhiteObjectivesEnabled=False;
			for(i=0;i<WhiteAssaultObjectives.Length;i++)
			{
				WhiteAssaultObjectives[i].bDisabled=True;
			}
			Bases[0].EnableSpawn(False,255);
		}
	}
}

function EnableBlackObjectives(bool bEnable)
{
	local int i;
	if(bEnable)
	{
		AssaultReplicationInfo(GameReplicationInfo).FlagPos[0] = BlackAssaultObjectives[0].Location + Vect(0,0,50);
		AssaultReplicationInfo(GameReplicationInfo).ObjectiveDamage[1] = 255.0 * (float(BlackAssaultObjectives[0].Health) / float(BlackAssaultObjectives[0].DamageCapacity));
		AssaultReplicationInfo(GameReplicationInfo).GameObjStates[1] = GOS_HeldBlue;
		for(i=0;i<BlackAssaultObjectives.Length;i++)
		{
			BlackAssaultObjectives[i].bDisabled=False;
		}
		PlayMessageSound(AtEnemyBase[0]);
		bBlackObjectivesEnabled=True;
		Bases[1].EnableSpawn(True,1);
		AssaultSpawns[AssaultSpawns.Length-1].EnableSpawn(True,1);

	}
	else
	{
		if(bBlackObjectivesEnabled) //only disable if enabled
		{
			AssaultReplicationInfo(GameReplicationInfo).GameObjStates[1] = GOS_Dropped;
			bBlackObjectivesEnabled=False;
			for(i=0;i<BlackAssaultObjectives.Length;i++)
			{
				BlackAssaultObjectives[i].bDisabled=True;
				Bases[1].EnableSpawn(False, 255);

			}
		}
	}
}


function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
	local bool bDestroyedAll;
	local int i;
	//check and see if this completes the destruction of all objectives
	bDestroyedAll=True;

	if(Scorer.Team.TeamIndex==0)
	{
		for(i=0;i<BlackAssaultObjectives.Length;i++)
		{
			if(BlackAssaultObjectives[i].bDestroyed==False)
			{
				bDestroyedAll=False;
				break;
			}
		}
	}
	else
	{
		for(i=0;i<WhiteAssaultObjectives.Length;i++)
		{
			if(WhiteAssaultObjectives[i].bDestroyed==False)
			{
				bDestroyedAll=False;
				break;
			}
		}
	}

	if(bDestroyedAll)
	{
		Scorer.Team.Score += 5.0;
		BroadcastLocalizedMessage( class'AssaultMessage', 2, Scorer, None, None );
		BroadcastLocalizedMessage( class'AssaultMessage', 3, Scorer, None, None );
		
		for(i=0;i<AssaultSpawns.Length;i++)
		{
			AssaultSpawns[i].GotoState('');
		}


		ResetCountDown=5;
	}
	else
	{
		BroadcastLocalizedMessage( class'AssaultMessage', 1, Scorer, None, None );
		Scorer.Team.Score += 2.0;
	}

	Super.ScoreObjective(Scorer, Score);
}

function CheckScore(PlayerReplicationInfo Scorer)
{
	

	Super.CheckScore(Scorer);
}


State MatchInProgress
{
	function Timer()
	{
        local Controller C;
		local VGVehicle v;

        Super.Timer();

        if (ResetCountDown > 0)
        {
            ResetCountDown--;

            if (ResetCountDown <= 3)
                BroadcastLocalizedMessage(class'xTimerMessage', ResetCountDown);

            if (ResetCountDown == 1)
            {
				ResetGame();
                ResetCountDown = 0;
                // reset all players position and rotation on the field for the next round
                for ( C = Level.ControllerList; C != None; C = C.NextController )
    	        {
					ResetController(C);
     	        }

				//kill extra vehicles, reset counts
				ResetVehicleCounts();

				ForEach AllActors(class'VGVehicle', v)
				{
					v.Destroy();
				}

            }
        }
    }
}

function ResetController(Controller C)
{
	local VGPawn p;
	local int TeamNum;

	TeamNum = C.PlayerReplicationInfo.Team.TeamIndex;

	C.StartSpot = FindPlayerStart(C,TeamNum);


	C.SetLocation(C.StartSpot.Location);
    C.SetRotation(C.StartSpot.Rotation);
	C.Pawn.Velocity = vect(0,0,0);
    
	if(C.Pawn.IsA('VGVehicle')) 
	{
		VGVehicle(C.Pawn).EndRideAll();
		VGVehicle(C.Pawn).DriverExits();
		
	}
	
	
	if(C.Pawn.IsA('VGPawn'))//player is on foot.  Either put him in his vehicle, or (if no vehicle) give him a new one
	{
		p=VGPawn(C.Pawn);

		//check and see if he's a rider, and force him out
		if(p.RiddenVehicle != None)
		{
			p.RiddenVehicle.EndRide(p);
		}

		if(p.OwnedVehicle!=None)
		{
			p.OwnedVehicle.Destroy();
			p.OwnedVehicle=None;
		}

		VehiclePlayer(C).GiveLoadout();
	}

	C.Pawn.SetLocation(C.StartSpot.Location);
	C.Pawn.SetRotation(C.StartSpot.Rotation);
	
	C.ClientSetLocation(C.StartSpot.Location,C.StartSpot.Rotation);
	
}

defaultproperties
{
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
     MaxPlayersOnDedicated=10
     MaxPlayersOnListen=6
     GoalScore=20
     MinGoalScore=10
     MaxLives=0
     ListPriority=7
     DeathMessageClass=Class'XGame.xDeathMessage'
     GameReplicationInfoClass=Class'VehicleGame.AssaultReplicationInfo'
     ScoreBoardType="XInterfaceHuds.ScoreBoardTeamDeathMatch"
     HUDType="VehicleInterface.HudAAssault"
     MapListType="XInterfaceMP.MapListAssault"
     MapPrefix="AS"
     GameName="Front Line Assault"
     ScreenshotName="PariahMapThumbNails.GameTypes.FrontLineAssault"
     DecoTextName="XGame.Assault"
     Acronym="AS"
     VehicleRegenTime=5
}
