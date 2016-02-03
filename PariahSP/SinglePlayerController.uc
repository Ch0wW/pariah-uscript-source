class SinglePlayerController extends VehiclePlayer;

//oof
var float CurrentDialogTime;


//deathcam vars

var vector DCamLoc;
var Rotator DCamRot;

var float DCamDist;

//Debug flag
var bool bDebugBots;
var bool bDebugDevices;
var bool bBotStats;

var globalconfig int CurrentSave;


var bool bKillOnFlip, bInSpecialTimedScene, bEnableTagLocator;
var float TimerSceneStartTime, TimerSceneExpireTime;
var Actor LocatorPawn;


var Pawn Boss;
var bool bEnableBossBar;
var Color BossBarColor;

var localized string PressToContinueMsg;
var localized string SavingPlayerProfile;


// how long to wait after you die before responding to button press
//
const DEAD_WAIT_TIME = 1;

var float DeadWait;

function NotifyRestarted()
{
	local StartInventory si;
	local GameProfile g;
	local bool bUseStartInventory;
	
	bUseStartInventory = true;
	g = GetCurrentGameProfile();
	if ( g != None )
	{
		if ( g.SetupInventory( self, Level.Game ) )
		{
			// if profile setup inventory, then we don't use start inventory
			//
			bUseStartInventory = false;
		}
        Level.Game.Difficulty = Level.Game.GetDifficultyLevel(g.GetDifficultyIndex());
	}

	foreach AllActors(class'StartInventory', si)
	{
		if ( bUseStartInventory || si.bForceInventory )
		{
			si.GiveTo(self);
		}
		break;
	}
    
	if(g != None && g.SavePlayerData(Level))
	{
	    UpdateGameProfile();
	}
}

function SetBossBarPawn(Pawn b)
{
	bEnableBossBar=true;
	Boss = b;
}

function DisableBossBar()
{
	bEnableBossBar=false;
}

function StartTimedScene(float StartTime, float ExpireTime)
{
	log("starting timed scene");
	bInSpecialTimedScene = true;
	TimerSceneStartTime = StartTime;
	TimerSceneExpireTime = ExpireTime;
}

function EndTimedScene()
{
	log("ending timed scene");
	bInSpecialTimedScene = false;
}

function ExitVehicleWorker(string AltCmd)
{
	if(bInSpecialVehicleScene) // no exit allowed, just do alt
		ConsoleCommand( AltCmd );
	else
		Super.ExitVehicleWorker(AltCmd);
}

simulated function PrepareForMatinee()
{
	if(Pawn.IsA('VGVehicle')) //ohfuck, driving a car!
	{
		VGVehicle(Pawn).DriverExits();
	}

    MatineePawn = Pawn;
        
	Super.PrepareForMatinee();
}

// beautiful symmetry
function Repossess(Pawn LastPawn)
{
    MatineePawn = None;
    Super.Repossess(LastPawn);
}


function DeathCam(float DeltaTime)
{
	local int pitch;
	local float pitchalpha, distalpha;
	local vector camdir;
    local Vector hitloc, hitnormal;
    local Actor hitactor;
    
	//log("------------------");
	//log("Initial pitch: "$DCamRot.pitch);
	pitch = ((DCamRot.pitch&65535) + 16*1024)&65535;
	//log("transformed to: "$pitch);
	pitchalpha = 1.0 - (1.0/(2.0**(DeltaTime*1.0)));

	pitch = InterpToDesired(pitch, 0, pitchalpha);
	//log("interped to: "$pitch);

	DCamRot.pitch = (pitch - 16*1024)&65535;
	//log("retransformed to: "$DCamRot.pitch);

	camdir = -Vector(DCamRot);

	distalpha = 1.0 - (1.0/(2.0**(DeltaTime*1.0)));

	DCamDist += distalpha * (500.0-DCamDist);

	LastCamRotation = DCamRot;
	LastCamLocation = DCamLoc + camdir*DCamDist;
	
	hitactor = Trace(hitloc, hitnormal, LastCamLocation, DCamLoc);
    if (hitactor != None)
    {
        LastCamLocation = hitloc - camdir * 40.0;
    }
}


function PlayerTick(float dt)
{
	//log(Rotation);

	Super.PlayerTick(dt);
}

function LoadLastSave()
{
	local GameProfile g;

	g = GetCurrentGameProfile();
	if(g == None)
	{
		warn("PROFILE WAS NONE, restarting instead");
		RestartLevel();
		return;
	}

    ClientTravel( g.GetNextURL(string(XLevel.Outer.Name)), TRAVEL_Absolute, false );
}

exec function ShowObjectivesOr( String AltCmd )
{
	local SPObjectiveList objectiveList;

	foreach AllActors( class'SPObjectiveList', objectiveList )
	{
		objectiveList.DisplayCurrentObjective( false );
		return;
	}
	
	ConsoleCommand( AltCmd );
}

state Dead
{
    exec function Fire( optional float F )
    {
		if ( DeadWait <= 0 )
		{
            HudBase(myHUD).KillMessages();

			if(!Level.IsCoopSession() || Level.GetLivingLocalPlayer() == None)
			{
				SinglePlayerController(Level.GetLocalPlayerByIndex(0)).LoadLastSave();
			}
			else
			{
				Level.LoadDelayedPlayers();
				ServerReStartPlayer();
			}
		}
    }

    exec function AltFire( optional float F )
    {
		Fire(F);
    }

    function PlayerMove(float DeltaTime)
    {
        //Super.PlayerMove(DeltaTime);
        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
    }

	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		Global.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
	}

	event CameraTick(float DeltaTime)
	{
		local float savedDeadWait;

		DeathCam(DeltaTime);
		savedDeadWait = DeadWait;
		DeadWait -= DeltaTime;
		if ( savedDeadWait >= 0 && DeadWait < 0 )
		{
			myHUD.LocalizedMessage( class'DeadMessage', 0, None, None, None, PressToContinueMsg );
		}
	}


    function FindGoodView()
    {

    }

	function BeginState()
	{
		DeadWait = DEAD_WAIT_TIME;
		Super.BeginState();
	}
}

function PawnDied(Pawn P)
{
	log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

	SetLocation(P.Location);
	//SetRotation(P.Rotation);

	DCamLoc = P.Location;
	DCamRot = Rotation;

	Super.PawnDied(P);
}


function bool SameTeamAs(Controller C)
{
	if(c.IsA('VGSPAIController'))
		return C.SameTeamAs(self); //cause the bot's sameteamas() is more robust
	else if(c.IsA('SinglePlayerController'))
		return true;
}



//////////////
///  BOT DEBUG
///////////////

exec function botskill(int a)
{
    local VGSPAIController bot;

	foreach AllActors( class'VGSPAIController', bot )
	{
        bot.Skill = a;
		bot.ResetSkill();
	}
}

exec function Perform(int a, optional int b)
{
	local SPAITestController bot;
	local int count;

	foreach AllActors( class'SPAITestController', bot )
	{
		if(b == 0 || b == ++count )
			bot.Perform( EAction(a) );
	}
}


exec function DebugPos()
{
	local Stage stg;
	local VGSPAIController bot;
	local int i;

	//first bot in each stage
	foreach AllActors( class'Stage', stg)
	{
		for(i=0; i<stg.StageAgents.Length; i++)
		{
			bot = stg.StageAgents[i].controller;
			bot.bDebugLogging =true;
			bot.AIDebugFlags = bot.DEBUG_POSITIONS;
			break;
		}
	}
}

exec function flip()
{
	VGPawn(Pawn).RiddenVehicle.HAddImpulse( Vect(0,0,10000), Vect(100,0,0));
}

function NotifyVehicleFlip(Pawn Vehicle)
{
	if(bKillOnFlip)
	{
		if(VGPawn(Pawn).RiddenVehicle != None)
		{
			LOG("doing damage to "$VGPawn(Pawn).RiddenVehicle);
			VGPawn(Pawn).RiddenVehicle.TakeDamage(1500, VGPawn(Pawn).RiddenVehicle, VGPawn(Pawn).RiddenVehicle.Location, Vect(0,0,0), class'Crushed');

		}
		LOG("doing damage to "$pawn);

		Pawn.TakeDamage(500, Pawn, Pawn.Location, Vect(0,0,0), class'Crushed');
	}
}

function Timer()
{
    if(bDebugBots)
    {
        DebugBots(0);
    }
}

// save profile at the end of the cinematic
function MultiTimer(int slot)
{
    local GameProfile gp;
    
    if(slot == 555)
    {
        gp = GetCurrentGameProfile();
        if(Level.InCinematic())
        {
            SetMultiTimer(slot, 0.5, false);
        }
        else if(gp.ShouldSave())
        {
    	    myHUD.LocalizedMessage( class'SavePlayerProfileMessage', 0, None, None, None, SavingPlayerProfile );
    	    SetMultiTimer( 556, 0.25, False );	
        }
    }
    else if(slot == 556)
    {
        UpdatePlayerProfile();
    }
    else
    {
        Super.MultiTimer(slot);
    }
}

exec function DebugBots(int i)
{
	local VGSPAIController bot;
	local bool on;

	if(i == 0)
		on = true;
    if(i == 2)
        SetTimer(0.25, true);
    if(i == 3)
        SetTimer(0, false);

	bDebugBots = on;
	foreach AllActors( class'VGSPAIController', bot )
	{
		bot.bDebugLogging = on;
	}
}

exec function DebugGame()
{
	bDebugDevices = !bDebugDevices;
}

exec function exc()
{
    local SPAIController bot;

    //EET_Idle
    //EET_NoticeEnemy,
	//EET_LostEnemy,
	//EET_FriendlyFire,
	//EET_Attacking,
	//EET_KilledEnemy,

    foreach AllActors( class'SPAIController', bot )
	{
        bot.exclaimMgr.Exclaim(EET_Idle, 0);
    }
}

exec function fakk()
{
    local SPAIController bot;

    foreach AllActors( class'SPAIController', bot )
	{
        bot.StopFiring();
    }
}

exec function slow(optional int on)
{
    local SPAIController bot;
    local float amt;

    amt = 0.5;
    if(on == 0)
        amt = 2.0;

    foreach AllActors( class'SPAIController', bot )
	{
        bot.MinShotPeriod *= amt;
	    bot.MaxShotPeriod *= amt;
    }
}

exec function less(optional int on)
{
    local SPAIController bot;
    local float amt;

    amt = 0.5;
    if(on == 0)
        amt = 2.0;

    foreach AllActors( class'SPAIController', bot )
	{
        bot.MinNumShots *= amt;
	    bot.MaxNumShots *= amt;
    }
}



exec function alert()
{
    local SPAIController bot;

    foreach AllActors( class'SPAIController', bot )
	{
//        bot.Perform_Engaged_Alert();
    }
}

exec function dive()
{
    local SPAIController bot;

    foreach AllActors( class'SPAIController', bot )
	{
        bot.Perform_DiveFromGrenade( self.pawn );
    }
}

/**
 * Change the weighting factors for bot node selection
 **/
exec function CW(int x, int y)
{
	local VGSPAIController bot;

	foreach AllActors( class'VGSPAIController', bot )
	{
		switch(x)
		{
		case 0:
			bot.m_BunchPenalty = y;
			break;
		case 1:
			bot.m_BlockedPenalty = y;
			break;
		case 2:
			bot.m_BlockingPenalty = y;
			break;
		case 3:
			break;
		case 4:
			bot.m_NeedForContact = y;
			break;
		case 5:
			bot.m_NeedCohesion = y;
			break;
		case 6:
			bot.m_NeedForIntel = y;
			break;
		case 7:
			bot.m_NeedToAvoidCorpses = y;
			break;
		case 8:
			bot.m_NeedForClosingIn = y;
			break;
        case 9:
			bot.m_NeedForNearbyGoal = y;
			break;
		case 10:
			bot.m_SameSideOfEnemy = y;
			break;
		case 11:
			bot.m_CrossPenalty = y;
			break;
        case 12:
            bot.m_ProvidesCover = y;
            break;
        case 13:
            bot.m_TacticalHeight = y;
            break;
		}
	}
}


function drawBotStats( Canvas C)
{
    local Stage stg;
    local VGSPAIController bot;
    local int activeStgCount, stasisStgCount;
    local int activeBotCount, stasisBotCount,cheapBotCount;
    local int startY;
    local int i;
    local bool bEnemy;
    local float maxTime;

    foreach AllActors( class'VGSPAIController', bot )
	{
        if(bot.isA('SPAIPopUpAssaultRifle'))
            cheapBotCount++;
		else if ( bot.bHibernating )
            stasisBotCount++;
        else
			activeBotCount++;
	}
    foreach AllActors( class'Stage', stg )
	{
        if( stg.debugUpdateStagePosProfileTime > maxTime)
            maxTime = stg.debugUpdateStagePosProfileTime;

        if ( stg.bHibernating || stg.StageAgents.length <= 0)
        {
            stasisStgCount++;
        }
        else
        {
            bEnemy = false;
			for(i=0; i<stg.MAXENEMY; i++) {
                if( stg.Enemies[i] != None)
                {
                    bEnemy = true;
                    break;
                }
            }
            if(bEnemy)
                activeStgCount++;
            else
                stasisStgCount++;

        }
    }

    startY = C.ClipY - 110;

    C.SetPos(C.ClipX - 100, startY);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    C.DrawText( "ActiveStg:"@activeStgCount);

    startY += 10;
    C.SetPos(C.ClipX - 100, startY);
    C.DrawText( "ActiveBot:"@activeBotCount);

    startY += 10;
    C.SetPos(C.ClipX - 100, startY);
    C.DrawText( "CheapBot:"@cheapBotCount);

    startY += 10;
    C.SetPos(C.ClipX - 100, startY);
    C.DrawText( "StasisStg:"@stasisStgCount);

    startY += 10;
    C.SetPos(C.ClipX - 100, startY);
    C.DrawText( "StasisBot:"@stasisBotCount);

    startY += 10;
    C.SetPos(C.ClipX - 150, startY);
    C.DrawText( "MaxUpdatePosMs:"@maxTime);

}

/**
 * 1 - Stop movement
 * 2 - Resume movement
 * 3 - Stop Shooting
 * 4 - Resume Shooting
 **/
exec function ProfileBots(optional int x)
{
	local VGSPAIController bot;

    if( x == 0) {
        bBotStats = !bBotStats;
        return;
    }

    foreach AllActors( class'VGSPAIController', bot )
	{
		switch(x)
		{
        case 1:
			bot.Pawn.GroundSpeed = 0;
			break;
		case 2:
			bot.Pawn.GroundSpeed = bot.Pawn.default.GroundSpeed;
			break;
		case 3:
			bot.StopFireWeapon();
			break;
		case 4:
			bot.StartFireWeapon();
			break;
        case 5:
            bot.Pawn.SetPhysics(PHYS_None);
            break;
        case 6:
            bot.Pawn.SetPhysics(PHYS_Walking);
            break;
        case 7:
            bot.Pawn.bStasis = true;
            break;
        case 8:
            bot.Pawn.bStasis = false;
            break;
		case 9:
			bot.Pawn.bBlockPlayers = false;
			bot.Pawn.bBlockActors = false;
            break;
		case 10:
			bot.Pawn.bBlockPlayers = true;
			bot.Pawn.bBlockActors = true;
            break;
        }
	}
}



exec function Stasis()
{
	local StageManager mgr;
	local VGSPAIController bot;
	local int count;

	foreach AllActors( class'VGSPAIController', bot )
	{
		if ( !bot.bHibernating )
			count++;
	}
	log("Bots going into hibernation:"@count);


	foreach AllActors( class'StageManager', mgr )
	{
		mgr.bAllHibernate = true;
		mgr.AllHibernate();
	}
}
exec function UnStasis()
{
	local StageManager mgr;

	foreach AllActors( class'StageManager', mgr )
	{
		mgr.bAllHibernate = false;
	}


}


exec function TestDialog()
{
	local class<Menu> MenuMidGameClass;
	MenuMidGameClass = class<Menu>( DynamicLoadObject( "PariahSP.DialogBox", class'Class' ) );

	if( MenuMidGameClass == None )
	{
		log( "Could not load PariahSP.DialogBox!", 'Error' );
		return;
	}

	MenuOpen( MenuMidGameClass );
}



function float PlayDialogue(string TextID, optional bool bAutoClose, optional name CharID, optional bool bCinematicStyle)
{
	local class<Menu> MenuMidGameClass;

	if(bHideDialogue) return 1.0;

	if(bCinematicStyle)
		MenuMidGameClass = class<Menu>( DynamicLoadObject( "PariahSP.DialogBoxSimple", class'Class' ) );
	else
		MenuMidGameClass = class<Menu>( DynamicLoadObject( "PariahSP.DialogBox", class'Class' ) );

	if( MenuMidGameClass == None )
	{
		log( "Could not load PariahSP.DialogBox!", 'Error' );
		return 0;
	}

	MenuOpen( MenuMidGameClass, "?TextID="$TextID$"?CharID="$CharID$"?bAutoClose="$bAutoClose );

	//uhh... this value should end up set before MenuOpen returns.
	return CurrentDialogTime;
}

//oh boy!  A reentrant function which should be called deep from within MenuOpen above.
function SetDialogLength(float Length)
{
	CurrentDialogTime = Length;
}


exec function Radio(){
    local SPExclaimManager SPExMgr;
    foreach AllActors( class'SPExclaimManager', SPExMgr){
        //if it can use the radio
        if (SPExMgr.bCanUseRadio == true){
            SPExMgr.bUseRadio = !SPExMgr.bUseRadio;
        }
    }
}

defaultproperties
{
     PressToContinueMsg="Press fire to continue"
     SavingPlayerProfile="Saving"
     bLoadedOut=True
     bIgnorePlayerRecord=True
     DefaultFOV=90.000000
}
