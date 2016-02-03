class SPAIDrone extends SPAIController;

var DroneArea MyDroneArea;
var vector DriftCenter;

var bool bDebugInfo;

function Restart()
{
    Super.Restart();
	Pawn.SetMovementPhysics(); 
    Focus = None;
	SwitchToBestWeapon();
}

function SpawnExclaimManager(){}
function initAIRole(){}
function SelectAction()
{
	PickNewAction();
}
//function Tick(float dT){}
function botTickPosition(StagePosition pos){}

function class<SPPawnDrone> GetDronePawnClass()
{
	return class'SPPawnDrone';
}


function StageOrder_Hibernate() 
{
	Super.StageOrder_Hibernate();
	disable('tick');
}

function StageOrder_Awaken() 
{
	Super.StageOrder_Awaken();
	enable('tick');

}


function PickNewAction()
{
	if(FRand() < 0.4)
	{
		curAction="Wander";
		GotoState('DroneWander','BEGIN');
	}
	else
	{
		curAction="Hover";
		GotoState('DroneHover','BEGIN');
	}
		
}

event HearNoise( float Loudness, Actor NoiseMaker)
{
	Super.HearNoise(Loudness, NoiseMaker);
}

/**
 * called when a player (bIsPlayer==true) pawn is seen
 **/
event SeePlayer( Pawn Seen )
{
	Super.SeePlayer(Seen);

}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	Super.DamageAttitudeTo(Other,Damage);
}


event EnemyNotVisible()
{
	Super.EnemyNotVisible();
}

auto state DroneWander
{
	event bool NotifyLanded(vector HitNormal)
	{
//		log("landed");
		PickNewAction();
		return false;
	}
	event bool NotifyHitWall(vector HitNormal, actor Wall)
	{
//		log("hitwall");
		PickNewAction();
		return false;
	}
	event bool NotifyBump(Actor Other)
	{
//		log("bump");
		PickNewAction();
		return false;
	}
	
	function EndState() //cleanup
	{
		if(Pawn != none)
			Pawn.bFlyingBrake=false;
	}

BEGIN:
//	log("==> Start WANDER");

    sleep(0.5);
	if(!PickRandomDestination())
        GotoState('DroneWander','BEGIN');
	

	FocalPoint = Destination;
	FinishRotation();

	MoveTo(Destination);
	Pawn.bFlyingBrake=true;

	sleep(1.2);

	PickNewAction();
}

function Perform_DiveFromGrenade(actor Grenade)
{
}

state DroneHover
{
	event bool NotifyLanded(vector HitNormal)
	{
//		log("! landed");
		PickNewAction();
		return false;
	}
	event bool NotifyHitWall(vector HitNormal, actor Wall)
	{
//		log("! hitwall");
		PickNewAction();
		return false;
	}
	event bool NotifyBump(Actor Other)
	{
//		log("! bump");
		PickNewAction();
		return false;
	}

	function EndState()
	{
		
	}

BEGIN:							
//	log("==> Start HOVER");

	PickRandomLook();

	RandomDrift();
	sleep(0.3);
	CorrectDrift();
	sleep(0.3);
	CorrectDrift();
	sleep(0.3);
	CorrectDrift();
	sleep(0.3);
	CorrectDrift();
	sleep(0.3);

	Pawn.AirSpeed=Pawn.Default.Airspeed;

	PickNewAction();
	
}

function RandomDrift()
{
	if(MyDroneArea == None)
	{
		DriftCenter = Location;
	}
	else
	{
		DriftCenter = MyDroneArea.Location;
	}
	Pawn.Acceleration = VRand()*100;
}

function CorrectDrift()
{
	local vector dir;

	dir = PickRandomDriftSpot() - DriftCenter;

	Pawn.Acceleration = Normal(dir) * 100;
}

function Vector PickRandomDriftSpot()
{
	local Vector v;

	v=VRand()*80;

	return DriftCenter + v;
}

function PickRandomLook()
{
	local Vector v;

	v=VRand();

	v.z=0;

	FocalPoint = Pawn.Location + v*10000;
}

function bool CaresAbout(Actor Other)
{
	return false;
}

function EnteredArea(Actor Other)
{

}

function ExitArea(Actor Other);

function DrawHUDDebug(Canvas C)
{
    local vector screenPos;

    if (!bDebugLogging || Pawn == None)	return;

    screenPos = WorldToScreen( Pawn.Location 
                               + vect(0,0,1)*Pawn.CollisionHeight );
    if (screenPos.Z > 1.0) return;

    //C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    //C.DrawText( myAIROle.GetDebugText());

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-12);
    C.DrawText( curAction );

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y);
    C.DrawText( GetStateName() );
    
    
    //C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-36);
    //if( !exclaimMgr.bScheduled 
    //    && Level.TimeSeconds <= exclaimMgr.nextExclamation.time + 1 ) {
    //    C.DrawText( exclaimMgr.LastMsg );
    //}
}


function bool PickRandomDestination()
{
	//v.z = MyDroneArea.Location.z;
	if(MyDroneArea == None)
	{
	    return false;
	}
	Destination = MyDroneArea.GetRandomLocation();

	return TestDestination();
}

function bool TestDestination()
{	
	local vector HitLocation, HitNormal;
	local actor HitActor;

	HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
	if (HitActor != None)
	{
		Destination = HitLocation + HitNormal*Pawn.CollisionHeight*3.0;
		if ( !FastTrace(Destination, Pawn.Location) )
		{
			return false;
		}
	}

	return true;
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotAssaultRifle"
}
