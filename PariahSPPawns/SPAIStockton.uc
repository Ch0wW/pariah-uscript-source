class SPAIStockton extends SPAIController;

#exec OBJ LOAD FILE=StocktonStateGroups.uax

var bool TauntedFailure;

var float ChargeTime;
var bool bAltFireMode;
var bool bDidDamage;
var bool bWeakened;

var Generator currentGen;

var int AccumDamage;

const STOCKTON_CHANNEL = 3;


const MAX_SWEEP_YAW = 9750.0;

var float SweepYawOffset;

var enum SweepState
{
	SS_NONE,
	SS_START,
	SS_SWEEP,
	SS_RETURN
}CurrentSweepState;

var bool bPerformingWeakened;

function PickNewState()
{
	local float r;

	//log("Default 2 from "$GetStateName());

	r=FRand();

	if(CheckShouldCharge() || CheckShouldAttack()) return;

	//if( StocktonStage(currentStage).CeilingPartsLeft() && r < 0.3)
	//	Perform_FireAtCeiling();
	//else 
	if(EnemyIsVisible())
	{
		if(r < 0.5)
			Perform_SweepBeam();
		else 
			Perform_AttackPlayer();
	}
	else
	{
		Perform_MoveToFiringPosition();
	}


}

function GeneratorDestroyed(Generator DeadGen)
{
	log("a robotic six legged dog?  "$GetStateName());
}


function bool EnemyIsVisible()
{
	local Vector V;
	if(GetEnemy() != None)
	{
		V = GetEnemy().Location - Pawn.Location;
	}

	if(VSize(V) < 2000)
		return Super.EnemyIsVisible();
	else 
		return false;

}


function bool isChargeWeapon()
{
    return !bAltFireMode;
}

function float getChargeDelay()
{
    return ChargeTime;
}


function bool CanGotoAttack()
{
	return true;
}

function ChooseMode()
{
}

function SetUpFire()
{
    LOG("SETTING ALTFIRE TO 0 DUE TO SETUPFIRE");
	bFire = 1;
    bAltFire = 0;
    bAltFireMode=false;
    MinNumShots=default.MinNumShots;
	MaxNumShots=default.MaxNumShots;
	MinShotPeriod=default.MinShotPeriod;
	MaxShotPeriod=default.MaxShotPeriod;
}

function SetUpAltFire()
{

	log("I AM SETTING ALTFIRE.  THIS SHOULD STICK GODDAMMIT!");

    bFire = 0;
    bAltFire = 1;
    bAltFireMode=true;
    MinNumShots=100;
	MaxNumShots=100;
	MinShotPeriod=0.3;
	MaxShotPeriod=0.5;
}


function DamageAttitudeTo(Pawn Other, float Damage)
{

	if(frand() < 0.1 || Damage > 50)
	{
		Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Pain', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);
	}
	AccumDamage+=Damage;
}

function SetWeakened()
{
	bWeakened = true;

}

function bool CheckShouldAttack()
{
	if(AccumDamage > 30) //prioritize whacking the ceiling to give the player some cover
	{
		AccumDamage = 0;
		Perform_SweepBeam();
		return true;
	}
	//else if(StocktonStage(currentStage).GroundCoverCount < 3 && !bWeakened)
	//{
	//	Perform_FireAtCeiling();
	//	return true;
	//}

	return false;
}

function bool CheckShouldCharge()
{
	if(bWeakened)
	{
		bWeakened = false;
		SPAIRoleStockton(myAIRole).GOTO_Weakened();
		return true;
	}
	//else if(FRand() < 0.1 && StocktonStage(currentStage).GeneratorsLeft() )
	//{
	//	SPAIRoleStockton(myAIRole).GOTO_Charge();
	//	return true;
	//}
	//else
		return false;
}

// stockton only has one enemy... THE EVIL JACK MASON
function AcquireEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy)
{
	log("trying to acquire enemy "$potentialEnemy$" can see "$bcanseepotenemy);
}


event SeePlayer( Pawn Seen )
{
	//log("seen player "$seen);

	Super.SeePlayer(Pawn);
}
function StageOrder_JoinStage( Stage newStage )
{
	log("============== Joining new stage "$newstage);

	assert(StocktonStage(newStage)!=None);

	StocktonStage(newStage).StocktonAI = self;
	Super.StageOrder_JoinStage(newStage);
}

function InitAIRole()
{
	Super.InitAIRole();
	SPAIRoleStockton(myAIRole).Stockton = self;
}



//want him to aim at the ground NEAR the player (to get at least splash damage)
function Rotator Aim( Ammunition FiredAmmunition, vector projStart, int aimerror )
{
    local vector TargetLoc, GroundTrace, HitLoc, HitNorm, MissVector, v;
	local Actor hit;
	local Rotator ShootDir;

	//if(bAltFireMode)
	//	return Super.Aim(FiredAmmunition, projStart, aimerror);

    if ( target == None ) 
	{
        DebugLog( "AimToMiss on invalid target", DEBUG_FIRING );
        return rotator( lastSeenPos - projStart );
    }
    //if( Target == GetEnemy() && !EnemyIsVisible() ) {
    //    ShootDir = rotator(LastSeenPos - projStart);
    //    DebugLog( "AimToMiss on enemy that isn't visible:" @ ShootDir,
    //              DEBUG_FIRING );
    //    return ShootDir;
    //}
	if(!bAltFireMode)
	{
		if(Target.IsA('Pawn'))
		{
			TargetLoc = Target.Location;

			GroundTrace.X = Rand(100) - 50;
			GroundTrace.Y = Rand(100) - 50;
			GroundTrace.Z = -100;

			GroundTrace = TargetLoc + Normal(GroundTrace)*500;

			hit = Target.Trace(HitLoc, HitNorm, GroundTrace);


			if(hit == None)
			{
				HitLoc = GroundTrace;
			}
		}
		else
		{
			HitLoc = Target.Location;
		}

		ShootDir = rotator( (HitLoc + MissVector) - projStart );

	}		
	else
	{
		TargetLoc = Target.Location;
		//TargetLoc.Z = Pawn.Location.Z;

		HitLoc = TargetLoc;

		v = TargetLoc - Pawn.Location;

		ShootDir = rotator(v);
		//MissVector = vect(0,0,1) cross (TargetLoc - Pawn.Location);
		//MissVector.Z = 0;

		ShootDir.Yaw += SweepScale() * MAX_SWEEP_YAW;
		//MissVector = MissVectorScale * Normal(MissVector) * 750.0;
	}



	return ShootDir;
}

function Perform_AcquirePlayerAsEnemy()
{
	//log("Performing AcquirePlayerAsEnemy()");	
	Enemy = Level.RandomPlayerPawn();
}

function Pawn GetEnemy()
{
	if(Enemy == None)
	{
		Enemy = Level.RandomPlayerPawn();
	}
	return Enemy;
}

function StartSweep()
{
    MarkTime(curSweepTime);
}

function float SweepScale()
{
    local float curSweepScale;
    curSweepScale = 2.0 * ((Level.TimeSeconds - curSweepTime) / sweepTimerPeriod) - 1.0 ;
    return curSweepScale;
}

function bool HandleNoPath(string reason)
{
	if(reason=="NoRunPath")
	{
		log("BLAAAAAAAAAA");
		PickNewState();
		return true;
	}
	return Super.HandleNoPath(reason);
}

function Perform_MoveToFiringPosition()
{
	local StagePosition position;
	curAction="MoveToFiringPos";

	position = currentStage.Request_ShootingPosition(self);

	UnClaimPosition();

	if(position == None)
	{
		curAction="Moving near player";
		Perform_JustGoNearPlayer();
		return;
	}

	ClaimPosition(position);
	DoSmartRunToward();
}

function Perform_JustGoNearPlayer()
{
    if( FindBestPathToward(GetEnemy(), false, true) )
    {
        GotoState('SmartRunToward');
    }
    else
    {
        UnClaimPosition();
		log("Just go near player failing");
   //     setCurAction("NoRunPath");
   //     if(!HandleNoPath("NoRunPath"))
			//Perform_Error_Stop();

		Perform_WaitABit();
    }

	
}


function DoSmartRunToward()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        GotoState('SmartRunToward');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoRunPath");
        if(!HandleNoPath("NoRunPath"))
			Perform_Error_Stop();
    }
}


state SmartRunToward
{
ignores EnemyNotVisible;

    function bool ShouldMelee(Pawn Seen)
    {
        return false;
    }

    function AcquireEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy)
    {
  //      Global.AcquireEnemy( potentialEnemy, bCanSeePotEnemy);
		//if(!bDontFireWhileRunning)
		//{
		//	SetTimer(0.1, false);
		//}

		log("XXXXXXXXXXXXXxx acquire enemy?  "$potentialenemy@bCanSeePotEnemy);
    }

    function Actor Face()
    {
        if (ShouldFace())
            return GetEnemy();
        return MoveTarget;
    }

    function bool ShouldFace()
    {
        return false;
    }

    function Timer()
    {
        if( GetEnemy() == None)
        {
            SetTimer( 0 , false);
            return;
        }

        if( ShouldFace() )
        {
            Focus = GetEnemy();
			StartFireWeapon();
            SetTimer(0.1, true);
            return;
        }
        Focus = MoveTarget;
        SetTimer(0,false);
    }

    function EndState()
    {
        SetTimer(0,false);
    }

    function bool KeepGoing()
    {
		//short out if getting hammered
		if(bWeakened || AccumDamage > 30) return false;


        return !Pawn.ReachedDestination(claimedPosition);
    }


BEGIN:
    if(GetEnemy() != None && !bDontFireWhileRunning)
        SetTimer(0.1, false);
    
    MoveToward( MoveTarget, Face() );
    if( KeepGoing() )
    {
        DoSmartRunToward();
    }
    myAIRole.MoveToPositionSucceeded();
}


function Perform_WaitABit()
{
	setCurAction("Waiting...");
	GotoState('WaitABit');
}

state WaitABit
{
BEGIN:    
	if(frand() < 0.5 && enemy != none)
    {
		Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Chase', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);
    }
    else if (enemy == none && TauntedFailure == false)
    {
        Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Chase', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);
        TauntedFailure = true;
    }
	Sleep(1.0);
	PickNewState();
}

function Perform_MoveToCoverPosition()
{
	local StagePosition position;
	curAction="MoveToCoverPos";

	position = currentStage.Request_CoverPosition(self);

	if(position == None)
	{
		curAction="No Cover position";
		Perform_Error_Stop();
		return;
	}

	UnClaimPosition();

	ClaimPosition(position);
	DoSmartRunToward();

}

function Perform_FindPosition(optional bool skipdistcheck)
{
    local int numAvail, i;
    local StagePosition position;
	//log("Performing FindPosition()");	

	curAction="FindPosition";
	for(i=0; i< currentStage.StagePositions.Length; i++)
    {
        if( !currentStage.StagePositions[i].bIsClaimed && (skipdistcheck || VSize(currentStage.StagePositions[i].Location - Pawn.Location) < 1000.0))
        {
            numAvail++;
            if( FRand() < 1.0f/float(numAvail) ) //  odds are  1/1, 1/2, 1/3, 1/4 ...
            {
                position = currentStage.StagePositions[i];
            }
        }
    }
    UnClaimPosition();

    if(position == None) 
	{
        setCurAction("NoWanderSpots");
        Perform_Error_Stop();
        return;
    }

    ClaimPosition(position);
	DoSmartRunToward();
}

function Perform_FindGen()
{
	local StagePosition pos;
	//log("Performing FindGen()");	

	curAction="FindGenerator";
	UnClaimPosition();

	pos = StocktonStage(currentStage).FindGeneratorSpot(Pawn, currentGen);
	

	//log("setting "$currentgen$" invulnerable");
	//currentGen.SetInvulnerable(true);

	ClaimPosition(pos);

	ContinueRunTowardGen();

}

function ContinueRunTowardGen()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        GotoState('RunTowardGen');
    }
	else
	{
		log("OH SHIT WTF "$Pawn.Location);
	}
}

state RunTowardGen
{
ignores EnemyNotVisible;

    function bool ShouldMelee(Pawn Seen)
    {
        return false;
    }

    function EndState()
    {
        Pawn.StopMoving();
    }
	
	function GeneratorDestroyed(Generator DeadGen)
	{
		log("COMPARING DEADGEN "$deadgen$" TO CURRENTGEN "$currentgen);
		if(DeadGen == currentGen)
		{

			log("GOT MY GENERATOR DESTROYED");
			Pawn.StopMoving();

			Perform_FindGen();
		}
	}

    function bool KeepGoing()
    {
        return !Pawn.ReachedDestination(claimedPosition);
    }

	function Actor Face()
    {
        return MoveTarget;
    }


BEGIN:
    if(GetEnemy() != None && !bDontFireWhileRunning)
        SetTimer(0.1, false);
    
    MoveToward( MoveTarget, Face() );
    if( KeepGoing() )
    {
        ContinueRunTowardGen();
    }
    myAIRole.MoveToPositionSucceeded();
}

function Perform_Laugh()
{
	//log("Performing Laugh()");
	curAction="Laughing";
	Gotostate('Laughing');
}


state RunToward
{
    function bool ShouldFace()
    {
        return false;
    }

}

state Laughing
{
	function AnimEnd(int channel)
	{
		if(Channel==STOCKTON_CHANNEL)
		{
			Notify();
		}
		
		Super.AnimEnd(channel);
	}
	

	function EndState()
	{
		Pawn.bPhysicsAnimUpdate=true;
	}

BEGIN:
	Pawn.StopMoving();
	//Pawn.bPhysicsAnimUpdate=false;
	
	Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Laugh', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);


	Pawn.AnimBlendParams(STOCKTON_CHANNEL, 1, 0.2, 0.2, Pawn.RootBone);// kill off firing animation 
	Pawn.PlayAnim('Laugh', 0.9, 0.2, STOCKTON_CHANNEL);
	WaitForNotification();
	//Pawn.bPhysicsAnimUpdate=true;
	//Pawn.bWaitForAnim=false;

	Pawn.AnimBlendToAlpha(STOCKTON_CHANNEL,0.0, 0.2);
	//Pawn.AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

	Sleep(0.2);

	PickNewState();
}



function Perform_SweepBeam()
{
	//log("Performing SweepBeam()");

	curAction="SweepBeam";

	Target = GetEnemy();
	Focus=Target;

	GotoState('SweepBeam');
}

state SweepBeam
{
	//event tick(float dt)
	//{
	//    if(bDebugLogging)
	//	    debugTick(dT);
	//}

	function Tick(float dt)
	{

		//log(CurrentSweepState);
		switch(CurrentSweepState)
		{
		case SS_Start:

			SweepYawOffset = SweepYawOffset - dt * 20000.0;
			
			if(SweepYawOffset <= -MAX_SWEEP_YAW)
			{
				SweepYawOffset = -MAX_SWEEP_YAW;
				Notify();
			}

			Pawn.DesiredRotationOffset.Yaw = SweepYawOffset&65535;
			break;

		case SS_Sweep:
			SweepYawOffset = SweepYawOffset + dt * (MAX_SWEEP_YAW*2.0) / SweepTimerPeriod;

			if(SweepYawOffset <= -MAX_SWEEP_YAW)
			{
				SweepYawOffset = -MAX_SWEEP_YAW;
			}
			Pawn.DesiredRotationOffset.Yaw = SweepYawOffset&65535;
			break;
		case SS_Return:

			SweepYawOffset = SweepYawOffset - dt * 20000.0;

			if(SweepYawOffset <= 0)
			{
				SweepYawOffset = 0;
				Notify();
			}
			Pawn.DesiredRotationOffset.Yaw = SweepYawOffset&65535;
			break;

		case SS_None:
		default:
		}
		Global.Tick(dt);
	}


	function BeginState()
	{
		//blarg, clean up other shit
		//first, make sure charge timer is OFF
		SetMultiTimer(CHARGE_RELEASE, 0, false);

		//make sure tick isn't going to call stopfiring
		bStopFireAnimation = false;


	}
BEGIN:
	curAction="SweepBeam";

	FinishRotation();

	SetUpAltFire();
	bIgnoreNeedToTurn=true;

	CurrentSweepState = SS_Start;
	Pawn.PlaySound(SPPawnStockton(Pawn).SndStartBeam,SLOT_Misc);
	WaitForNotification();
	CurrentSweepState = SS_Sweep;

	//curAction="Rotation";
	//FinishRotation();

	log("SweepBeam Beam Should START!");
	StartFireWeapon();
	Sleep( SweepTimerPeriod );

	bIgnoreNeedToTurn=false;
	StopFireWeapon();
	CurrentSweepState = SS_Return;
	WaitForNotification();
	CurrentSweepState = SS_None;
	Pawn.DesiredRotationOffset.Yaw = 0;

	SetUpFire();
	//myAIRole.FireAtTargetSucceeded();

	log("SweepBeam Finished!");
	PickNewState();
}


function Perform_FireAtCeiling()
{
	//log("Performing FireAtCeiling() from state "$GetStateName());

	ChargeTime=0.5;
	Perform_FireAt(StocktonStage(currentStage).GetCeilingTarget());
}


function Perform_FireAt(Actor FireAtTarget)
{
	//log("Performing FireAt()");
	SetUpFire();
	Target = FireAtTarget;
	Focus = Target;
	curAction="FireAt"@FireAtTarget;
	GotoState('FireAtSomething');
}

function Perform_AttackPlayer()
{
	//log("Performing AttackPlayer()");

	curAction="FireAtPlayer";
	SetUpFire();
	ChargeTime=2;

	Target = GetEnemy();
	Focus = Target;

	GotoState('FireAtSomething');
}

state FireAtSomething
{
	function PickNewState()
	{
		//log("PickNewState from "$GetStateName());

		if(CheckShouldCharge()) return;

		if(bDidDamage && FRand() < 0.5)
			Perform_Laugh();
		else Global.PickNewState();
	}
	//event Tick(float dt)
	//{
	//	log("my target is "$target$" and my enemy is "$enemy);

	//}

	function EndState()
	{
		bDidDamage=false;
	}

BEGIN:
	log("FireAtSomething Finishing Rotation!");
	FinishRotation();

	bIgnoreNeedToTurn=true;
	log("FireAtSomething should start Charging!");
	StartFireWeapon();
	Sleep(getChargeDelay() );

	StopFireWeapon();
	log("FireAtSomething should be firing!");
	bIgnoreNeedToTurn=false;

	Sleep(1.5);

	log("FireAtSomething finished!");
	PickNewState();
}

function Perform_ChargeUp()
{
//	log("Performing ChargeUp()");
	curAction="ChargingUp";
	GotoState('ChargeUp');
}


function Perform_PrepareForTheEnd()
{
	SPPawnStockton(Pawn).LowerShield();
	StocktonStage(currentStage).DropGeneratorShields();
	SPPawnStockton(Pawn).FinishCharging();

}

state ChargeUp
{
	function AnimEnd(int channel)
	{
		if(Channel==0)
		{
			Notify();
		}
		
	}

	function bool CanGotoAttack()
	{
		return false;
	}


	function BeginState()
	{
		currentGen.SetInvulnerable(true);
		currentGen.MyShield.TurnOn();
	}

	function EndState()
	{
	}

BEGIN:

	assert(currentGen != None);
	
	log("STARTING THE CHARGE UP");
	Target = currentGen;
	Focus=Target;
	FinishRotation();
	Pawn.AnimBlendToAlpha(1,0.0, 0.1);// kill off firing animation 
	SPPawnStockton(Pawn).LowerShield();
	spawn(class'VehicleEffects.StocktonVirusGlow',,,Pawn.Location, Pawn.Rotation);
	Pawn.PlayAnim('TitanChargeStart',0.5);
	WaitForNotification();
	SPPawnStockton(Pawn).StartCharging(currentGen);
	Pawn.PlayAnim('TitanCharge',1);
	WaitForNotification();
	Pawn.PlayAnim('TitanCharge',1);
	WaitForNotification();
	currentGen.EndCharging();
	StocktonStage(currentStage).RaiseGeneratorShields();
	Pawn.PlayAnim('TitanChargeEnd',0.5);
	if(frand() < 0.9)
		Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Charge', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);
	WaitForNotification();
	Pawn.MovementAnims[0]='RunF';
	SPPawnStockton(Pawn).FinishCharging();
	log("ENDING THE CHARGE UP");

	MyAIRole.ChargeSucceeded();

}


function Perform_Weakened()
{
	//log("Performing Weakened()");

	curAction="Weakened";
	GotoState('Weakened', 'BEGIN');
}

function Perform_RaiseShield()
{
	SPPawnStockton(Pawn).RaiseShield();
}

event Blinded(Pawn Instigator, float Duration, Name BlindType)
{}

state Weakened
{
	function AnimEnd(int channel)
	{
		if(Channel==0)
		{
			Notify();
		}
		Super.AnimEnd(channel);
	}
	

	function bool CanGotoAttack()
	{
		return false;
	}


	function EndState()
	{
		if(bPerformingWeakened) //state was interrupted
		{
			Pawn.MovementAnims[0]='RunF_RL';
		}
		else //state completed naturally
		{
			Pawn.MovementAnims[0]='TiredRunTitanFist';
		
		}
		
		Pawn.bPhysicsAnimUpdate=true;
		Pawn.bWaitForAnim=false;

	}

BEGIN:
	bPerformingWeakened=true;
	Pawn.StopMoving();
	if(frand() < 0.6)
		Pawn.PlaySound(sound'StocktonStateGroups.BossFight.Hurt', SLOT_Talk, 5 * Pawn.TransientSoundVolume, true, 5000, 1.0, false);

	StocktonStage(currentStage).DropGeneratorShields();
	SPPawnStockton(Pawn).RaiseShield();
    //Pawn.AnimBlendParams(1, 0.0, 0.2, 0.2, Pawn.RootBone);
    //Pawn.AnimBlendParams(9, 1.0, 0.2, 0.2, Pawn.RootBone);
	Pawn.bPhysicsAnimUpdate=false;
	Pawn.AnimBlendToAlpha(1,0.0, 0.1);// kill off firing animation 
	Pawn.PlayAnim('TitanExhausted', 0.5, 0.3);
	WaitForNotification();
	//Pawn.AnimBlendToAlpha(9, 0, 0.4);
	bPerformingWeakened=false;
	myAIRole.Notify();
}

defaultproperties
{
     AssignedWeapon="PariahSPPawns.StocktonsFist"
     bDontFireWhileRunning=True
}
