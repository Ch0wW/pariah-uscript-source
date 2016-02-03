/**
 * Mostly just to fill in the template function from VGSPAIController that are incompatible with BrainBox builds.
 */
class SPAIController extends VGSPAIController;

enum EAlertState
{
	AS_Asleep,
	AS_UnAware,
	AS_Cautious,
	AS_Alerted,
	AS_Engaged,
};
var String	AssignedWeapon;

//var EAlertState m_Alertness;

const DIVE_CHANNEL = 15;
const HIT_CHANNEL = 14;

var bool bPawnMayDive;
var Actor   diveFromActor;
var bool    bFinishedDive;
var float LastRollTime;
var float BlindedDuration;
var Cigar   Cigar;


function EAlertState GetAlertness()
{
	if(Enemy == None)
		return AS_UnAware;
	
	return AS_Engaged;
}

function TakeControlOf(Pawn aPawn)
{
    Super.TakeControlOf(aPawn);
    
    if( aPawn.IsA('VGVehicle') )
    {
        SetFiringParamsForVehicle();
    }
    else
    {
        ResetFiringParams();
        StopFireWeapon();
    }
}

function Possess(Pawn aPawn)
{
    Super.Possess(aPawn);
    if( aPawn.IsA('VGVehicle') )
    {
        SetFiringParamsForVehicle();
    }
}

function SpecialUnPossess(optional bool bTemporary)
{
    local VGVehicle veh;

    veh = VGVehicle(Pawn);
    if( veh != None)
    {
        veh.EndControlOfVehicle( self );
        ResetFiringParams();
        GotoState('Wow');
    }
	veh.bBrake = false;
}

function UnPossess(optional bool bTemporary)
{
    SpecialUnPossess(bTemporary);
}

state Wow
{
    function Restart() {
        if( AssignedWeapon != "")
		    Pawn.CreateInventory( AssignedWeapon );
	    else if(UnrealPawn(Pawn) != None && UnrealPawn(Pawn).RequiredEquipment[0] != "")
		    Pawn.CreateInventory( UnrealPawn(Pawn).RequiredEquipment[0] );
        ClientSwitchToBestWeapon();
        
        
    }
BEGIN:
	WaitForLanding();
	SelectAction();
}

function SpawnExclaimManager()
{
    local SPPawn p;

	p = SPPawn(Pawn);

	if(VGVehicle(Pawn) != None) {
		p = SPPawn( VGVehicle(Pawn).Driver );
	}

	if( p == None )
		warn("SPAICONTROLLER MUST HAVE SPPAWN");
	else
	{
        exclaimMgr = Spawn(p.ExclamationClass,self);
	    exclaimMgr.init(self);
    }
}

function InitAIRole()
{
	local SPPawn p;

	p = SPPawn(Pawn);

	if(VGVehicle(Pawn) != None) {
		p = SPPawn( VGVehicle(Pawn).Driver );
	}

	if( p == None )
		warn("SPAICONTROLLER MUST HAVE SPPAWN");
	else
	{	
        myAIRole = Spawn( p.AIRoleClass, self );
		myAIRole.init( self );
	}
}

function Restart()
{
	if( Pawn.IsA('VGVehicle') )
    {
		Skill = SPPawn( VGVehicle(Pawn).Driver ).PawnSkill;
    }
    else
    {
        Skill = SPPawn(pawn).PawnSkill;
    }
	Super.Restart();
    
    if( Pawn.IsA('SPPawn') )
    {
        bPawnMayMelee=SPPawn(Pawn).PawnMayMelee();
        bPawnMayDive=SPPawn(Pawn).PawnMayDive();
    }

    if( AssignedWeapon != "") 
    {
        Pawn.CreateInventory( AssignedWeapon );
    }
	else if(UnrealPawn(Pawn) != None && UnrealPawn(Pawn).RequiredEquipment[0] != "")
    {
        Pawn.CreateInventory( UnrealPawn(Pawn).RequiredEquipment[0] );
    }
    
    SwitchToBestWeapon();
}

function bool SameTeamAs( Controller c )
{
    local SPPawn myRealPawn;
    local SPPawn otherPawn;
    
    if( C == None )
    {
        return(false);
    }
    
    if( c.Pawn.IsA('VGVehicle') )
    {
		otherPawn = SPPawn( VGVehicle(c.Pawn).Driver );
    }
    else
    {   
        otherPawn = SPPawn(c.Pawn);
    }
    
    if(Pawn.IsA('VGVehicle'))
    {
		myRealPawn = SPPawn(VGVehicle(Pawn).Driver);
    }
    else
    {
        myRealPawn = SPPawn(Pawn);
    }
    
    if ( c.IsA('SinglePlayerController') )
    {
        if(myRealPawn.race == R_NPC)
            return true;
        else
            return false;
    }
    else if( otherPawn == None || myRealPawn == None )
    {
		return true;
    }
    
	if(otherPawn.race == myRealPawn.race)
		return true;
	
	return false;
}

function bool VerifyShootingNode(StagePathNode node)
{
	local float dist;

	dist = VSize(Enemy.Location - node.Location);

	if( dist > 2500 )
		return false;
	else if( dist < 200 ) 
		return false;
	else return true;
}

function WeaponStopFire( Weapon w )
{
    Pawn.Weapon.ServerStopFire(Pawn.Weapon.BotMode);
}

function float getWeaponFireRate( Weapon w )
{
    return Pawn.Weapon.FireMode[Max(0,Pawn.Weapon.BotMode)].FireRate;
}

function float GetMaxFiringRange()
{
	return Pawn.Weapon.FireMode[Pawn.Weapon.BotMode].MaxRange();
}

function bool isChargeWeapon()
{
	local WeaponFire fireMode;

	fireMode = Pawn.Weapon.FireMode[Pawn.Weapon.BotMode];
	return ( fireMode.bFireOnRelease && fireMode.MaxHoldTime == 0.0f);
		
}

function bool isTargetDestroyed()
{
   local Pawn p;
   // consider invalid targets destroyed
   if ( ShootTarget == None ) return true;
   // check for pawn-health
   p =  Pawn( ShootTarget );
   if ( p != None ) return p.Health <= 0;
   // for all other actors, it's only considered destroyed if it's
   // being deleted...
   return ShootTarget.bDeleteMe == 1;
}

/*
 * This wander is moslty to handle broken scripts
*/

function Wander()
{
	if(VGVehicle(Pawn) != None)
	{
		Perform_vehRest();
	}
	else
	{
		Super.Wander();
	}
}

function debugTick(float dT)
{
	Super.debugTick(dT);
	//log(i);
	//if(Pawn.Anchor != None)
	//	drawdebugline(Pawn.Location, Pawn.Anchor.Location, 255,0,0);
	//if(claimedNode != None)
	//	drawdebugline(Pawn.Location, claimedNode.Location, 0,255,0);

}

//==========
function UpdatePawnViewPitch( )
{
    if(Enemy == None)
    {
        SPPawn(Pawn).StopLookAt();
        return;
    }

    SPPawn(Pawn).SetLookAtTarget(Enemy, vect(0,0,1)*Pawn.BaseEyeHeight, false, true, true);
}

//=========================

function Perform_NotEngaged_FindTossAway()
{
    GotoState('NotEngaged_FindTossAway');
}

state NotEngaged_FindTossAway
{

    function AnimEnd(int Channel)
    {
        switch(Channel)
        {
        case LEAN_CHANNEL:
            Notify();
            break;
        default:
            Pawn.AnimEnd(Channel);
            break;
        }
    }

    function endState()
    {
        Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    }

BEGIN:
    Pawn.StopMoving();
	Pawn.AnimBlendParams(LEAN_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    
    Pawn.PlayAnim('Idle_Search_Alert', , ,LEAN_CHANNEL);
    WaitForNotification();
    
    Pawn.PlayAnim('Find_TossAway', , ,LEAN_CHANNEL);
    WaitForNotification();
    
    myAIRole.NotEngagedAtRestSucceeded();
}

//=========================

function Perform_NotEngaged_AtRest(optional float restForTime)
{
    setCurAction("Rest");
    RestTime = restForTime;

    if ( !Pawn.HasHelmet() && SPPawn(Pawn).MaySmoke() )
    {
        if( FRand() < 0.75f )
            GotoState('NotEngaged_AtRest');
        else
            Perform_NotEngaged_SmokeCigar();
    }
    else
    {
        GotoState( 'NotEngaged_AtRest' );
        return;
    }

}

function Perform_NotEngaged_SmokeCigar()
{
    GotoState('NotEngaged_SmokeCigar');
}

function InitCigar()
{
    if(Cigar == none) {
        Cigar = Spawn(class'PariahSP.Cigar');
    }
}

function HoldCigar()
{
    Cigar.Reset();
    Pawn.AttachToBone(Cigar,'Bip01 L Hand');
    Cigar.SetRelativeLocation( vect(13,-5,-5) );
	Cigar.SetRelativeRotation( rot(0,0,15000) );    
}

function DropCigar()
{
 	if ( Cigar != None )
	{
		Cigar.TornOff();
	}
}

function Notify_Toss();

state NotEngaged_SmokeCigar
{

    function AnimEnd(int Channel)
    {
        switch(Channel)
        {
        case LEAN_CHANNEL:
            Notify();
            break;
        default:
            Pawn.AnimEnd(Channel);
            break;
        }
    }
    
    function BeginState()
    {
        InitCigar();
    }

    function endState()
	{
		if(!Cigar.bHidden)
			DropCigar();
		if(Pawn.Weapon.ThirdPersonActor.bHidden)
			Pawn.Weapon.ThirdPersonActor.bHidden = false;
		Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    }

    function Notify_Toss()
    {
        DropCigar();
    }

    function Timer()
    {
        Pawn.Weapon.ThirdPersonActor.bHidden= !Pawn.Weapon.ThirdPersonActor.bHidden;
    }

BEGIN:
    Pawn.StopMoving();
	Pawn.AnimBlendParams(LEAN_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    
    SetTimer(0.5, false);
    Pawn.PlayAnim('Weapon_Switch', , ,LEAN_CHANNEL);
    WaitForNotification();
    
    HoldCigar();
    Pawn.PlayAnim('Idle_CigLight', , ,LEAN_CHANNEL);
    WaitForNotification();

    do
    {
        Pawn.PlayAnim('Idle_Smoking', , ,LEAN_CHANNEL);
        WaitForNotification();
    } until( Frand() < 0.3);
    
    Pawn.PlayAnim('Idle_CigThrowAway', , ,LEAN_CHANNEL);
    WaitForNotification();

    SetTimer(0.5, false);
    Pawn.PlayAnim('Weapon_Switch', , 0.2,LEAN_CHANNEL);
    WaitForNotification();

    sleep(2.0);

    myAIRole.NotEngagedAtRestSucceeded();
}

//=========

//MH absolutely horrible, the controller hierarchy means we duplicate grenade and rifle
// controllers to make them scavenger specific, or we make a new state, and just have the scavenger role choose.
state NotEngaged_Wander
{
   function SetRelaxed()
    {
        if(Pawn.IsA('SPPawnScavenger') )
        {
            Pawn.WalkingPct = 0.4;
            Pawn.WalkAnims[0] = 'Walk_Search';
        }
    }
}
//=========

function NotifyRunOver(Pawn car)
{
    if(MayDive())
    {
        Perform_DiveFromGrenade( car );
    }
}

function bool MayDive()
{
    if (Pawn != None && Pawn.IsA('VGVehicle'))
    {
        return false;
    }
    else if (bPawnMayDive
         && ( (TimeElapsed(LastRollTime, 5.0) && Frand() < 0.66)
            || (TimeElapsed(LastRollTime, 10.0) && Frand() < 0.8)
            )
         )
    {
        return true;
    }
    return false;
}

function Perform_DiveFromGrenade( actor Grenade)
{
    diveFromActor = Grenade;
    GotoState('DiveFromGrenade');
}

state DiveFromGrenade
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible, NotifyRunOver;
    
    function DamageAttitudeTo(Pawn Other, float Damage)
    {
        if(Pawn == None)
        {
            return;
        }
        if ( (Pawn.health > 0) && (Damage > 0) ) {
            TryAcquiringNewEnemy(Other , CanSee(Enemy) );
        }
        if( SameTeamAs(Other.Controller) ) {
            exclaimMgr.Exclaim(EET_FriendlyFire, 0);
        }
        else {
            exclaimMgr.Exclaim(EET_Pain, RandRange(0, 0.5) );
        }
        //myAIRole.OnTakingDamage( Other,  Damage);
        setLastHitTime();
    }

    function Startle(Actor Other) {}
    
    function bool PickDive()
    {
        local vector predictFutureLocation, right;
        local vector Dir;
    
        if( VSize(diveFromActor.Velocity) > 50 )
        {
            predictFutureLocation = diveFromActor.Location + diveFromActor.Velocity*1.0;
            right = vect(0,1,0) >> Rotator(diveFromActor.Velocity);
            if( (pawn.location - predictFutureLocation) dot right > 0)
                Dir = right;
            else
                Dir = -1*right;

        }
        else
        {
            Dir = Normal(Pawn.Location - diveFromActor.Location);
            Dir.Z = 0;
        }
        
        Destination = Pawn.Location + Dir*1000;
        Focus = none;
        FocalPoint = Destination;
        
        AdjustForWall(700);
        Destination = FocalPoint;
        return true;
    }

    function bool ShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
    {
        return false;
    }

    function bool AdjustForWall(float walldist)
    {
	    local actor HitActor;
	    local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	    LookDir = Normal(Destination - pawn.Location);
	    ViewSpot = Pawn.Location;
	    ViewDist = LookDir * wallDist; 
	    HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	    if ( HitActor == None )
		    return false;

	    ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	    if (FRand() < 0.5)
		    ViewDist *= -1;

	    Focus = None;
	    if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	    {
		    FocalPoint = Pawn.Location + ViewDist;
		    return true;
	    }

	    if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
	    {
		    FocalPoint = Pawn.Location - ViewDist;
		    return true;
	    }

	    FocalPoint = Pawn.Location - LookDir * 700;
	    return true;
    }

    event AnimEnd( int Channel )
    {
        if(Channel != DIVE_CHANNEL)
        {
            Super.AnimEnd(Channel);
            return;
        }
        Notify();
        bFinishedDive = true;
	    //SetLocation( Pawn.Location + vect(0.f, 0.f, 40.f) );
	    Pawn.SetCollisionSize( Pawn.default.CollisionRadius, Pawn.default.CollisionHeight );
    }

    function EndState()
    {
        //set up regular anim again.
        if(Pawn != None)
        {
            Pawn.SetPhysics(PHYS_Walking);
        }
        LastRollTime = level.TimeSeconds;
    }
BEGIN:
    curAction = "Dive";
        
    StopFiring();
    WaitForLanding();
    if( PickDive() )
    {
        Pawn.StopMoving();
    }
    //We dont want the legs to be left behind
    //Pawn.bDoTorsoTwist = false;
    FinishRotation();
    //Pawn.bDoTorsoTwist = true;
    
    //Dive
    Pawn.SetPhysics(PHYS_RootMotionWithPhysics);
    Pawn.AnimBlendParams(DIVE_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
	// Translate actor down because when he finishes roll he needs to adjust up.  This is all due to the crappy cylinder size changing.
	Pawn.SetCollisionSize( Pawn.default.CollisionRadius, Pawn.default.CollisionHeight - 40.f );
	//SetLocation( Pawn.Location - vect(0.f, 0.f, 40.f) );
    Pawn.PlayAnim('DiveRoll_Forward',, 0.05, DIVE_CHANNEL);
    WaitForNotification();
	//Pawn.SetCollisionSize( Pawn.default.CollisionRadius, Pawn.default.CollisionHeight );
    Pawn.AnimBlendToAlpha(DIVE_CHANNEL, 0, 0.4);
    bFinishedDive = false;

    // jim: BEGIN gay root motion hack
    StandGroundTime = 0.5 + 0.5f * frand();
    //Pawn.Velocity = vect(0,0,0);
    Pawn.bWantsToCrouch = false;
    setCurAction("StandGround");
    GotoState('Engaged_StandGround');

    // jim: For gay root motion hack
    //myAIRole.GOTO_Attack();
    //myAIRole.BotSelectAction();
}

//////////////////
// Vehicle Helpers
//////////////////
function SetFiringParamsForVehicle()
{
    MinNumShots = 9999;
    MaxNumShots = 9999;		
    MinShotPeriod = 0.01;
    MaxShotPeriod = 0.01;		
    NumShotsUntilReload = 0;		
}

function ResetFiringParams()
{
    MinNumShots = default.MinNumShots;
    MaxNumShots = default.MaxNumShots;		
    MinShotPeriod = default.MinShotPeriod;
    MaxShotPeriod = default.MaxShotPeriod;		
    NumShotsUntilReload = default.NumShotsUntilReload;
}

state Scripting
{
    function UnPossess(optional bool bTemporary)
    {
        if(!Pawn.IsA('VGVehicle'))
        {    
            Super.UnPossess(bTemporary);
            return;
        }
        
        SpecialUnPossess();
    }
}

//===============
// Driving a vehicle
//===============
function Perform_vehRest()
{
	curAction = "vehRest";
    GotoState('vehRest');
}

state vehRest
{
ignores NotifyRunOver;
BEGIN:
	if(Pawn.Anchor == None && Pawn.LastAnchor != None)
	{	
		curAction = "GetOnRoad";

    	MoveToward(Pawn.LastAnchor);

	}
	else
	{
		VGVehicle(Pawn).bBrake = true;
		VGVehicle(Pawn).Throttle = 0;
		VGVehicle(Pawn).Steering = 0;	
		Sleep(1.0 + Frand() );
	}
	SelectAction();
}

//===============
// vehChargeAttack
// Try to run over enemy
//===============
function Perform_vehChargeAttack()
{
	curAction = "ChargeAttack";
	VGVehicle(Pawn).SetVehMoveTowardParams(5000, false, 0.7 * VGVehicle(Pawn).maxCarSpeed);
	GotoState('vehChargeAttack');
}

function Perform_vehChargeRam()
{
	curAction = "ChargeRam";
	VGVehicle(Pawn).SetVehMoveTowardParams( , false, 0.7 * VGVehicle(Pawn).maxCarSpeed );
	GotoState('vehChargeAttack');
}

state vehChargeAttack
{
ignores NotifyRunOver;

BEGIN:
	//moveparams set in Perform
	MoveToward(Enemy);
	VGVehicle(Pawn).ResetVehMoveTowardParams();
	SelectAction();
}

//===============
// vehStandoff
// Try to keep the car pointed at the enemy without moving too much.
//===============
function Perform_vehStandoff()
{
	curAction = "Standoff";
	GotoState('vehStandoff');
}

state vehStandoff
{
ignores NotifyRunOver;

function bool AimInReverse()
	{
		local bool bDistanceClosing;
		local vector enemyDir;
		local float enemyDist;
		local vector testLocation;

		if(Pawn.Anchor == None || !Pawn.Anchor.IsA('RoadPathNode'))
		{
			return false;
		}
		else // anchor is a road, see if reversing would take us off it.
		{
			testLocation = Pawn.Location - 3.0f * Pawn.CollisionRadius * vector(Pawn.Rotation);
			if( VSize(testLocation - Pawn.Anchor.Location) > Pawn.Anchor.CollisionRadius )
				return false;

		}
		enemyDir = Enemy.Location - Pawn.Location;
		enemyDist = VSize(enemyDir);
		enemyDir = Normal(enemyDir);

		bDistanceClosing = (Enemy.Velocity dot enemyDir) - (Pawn.Velocity dot enemyDir) <  0.0f;
	
		//if we're going fast enough, we'll handbrake turn instead of reverse
		if( (VGVehicle(Pawn).Throttle > 0) && (VSize(Pawn.Velocity) > 750) )
			return false;

		//if we're too close, the distance is closing, or i'm not facing directly enough
		//I ought to keep a bead in reverse	
		if (enemyDist < 3000 || (bDistanceClosing && enemyDist < 5000) || (vector(Pawn.Rotation) dot enemyDir) < 0.7f)
		{
			curAction = "REV"@curAction;
			return true;
		}

		return false;
	}

BEGIN:
	VGVehicle(Pawn).SetVehMoveTowardParams(,true,,AimInReverse() );
	MoveToward(Enemy);
	VGVehicle(Pawn).ResetVehMoveTowardParams();
	
	SelectAction();
}

//===============
// vehAvoidFire
// Try to run over enemy
//===============
function Perform_vehAvoidFire()
{
	curAction = "AvoidFire";
	GotoState('vehAvoidFire');
}

state vehAvoidFire
{
ignores NotifyRunOver;

BEGIN:
	VGVehicle(Pawn).SetVehMoveTowardParams( , , , , true );
	MoveToward(Enemy);
	VGVehicle(Pawn).ResetVehMoveTowardParams();
	SelectAction();
}

//===============
// vehReApproach
// get some distance between self and target.
//===============
function Perform_vehReApproach()
{
	curAction = "Reapproach";
	GotoState('vehReApproach');
}

state vehReApproach
{
ignores NotifyRunOver;

BEGIN:
	VGVehicle(Pawn).SetVehMoveTowardParams( , , , , true );
	MoveToward(Enemy);
	VGVehicle(Pawn).ResetVehMoveTowardParams();
	SelectAction();
}


//===============
// vehHunt
// get some distance between self and target.
//===============
function Perform_vehHunt()
{
	curAction = "Hunting";

	if ( FindBestPathToward(Enemy, true, true) )
	{
		GotoState('vehHunt');
	}
	else
	{
		Perform_vehRest();
	}
	
}

state vehHunt
{
ignores NotifyRunOver;

BEGIN:
	MoveToward(MoveTarget, Enemy);
	SelectAction();
}


//===============
// Riding a vehicle
//===============

function Perform_RidingVehicle()
{
    curAction = "Riding";
    GotoState('RidingVehicle');
}

state RidingVehicle
{
ignores NotifyRunOver;

BEGIN:
    Sleep(1.0);
    myAIRole.BotSelectAction();
}


//====================
// Blinded!
//====================

event Blinded(Pawn Instigator, float Duration, Name BlindType)
{
    if(Pawn != None && Pawn.Weapon != None && Pawn.Weapon.FilterBlindness(BlindType) )
    {
        return; // immune!
    }
    curAction = "Blinded";
    BlindedDuration = Duration;
    GotoState('MeBlinded','BEGIN');
}

state MeBlinded
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible, NotifyRunOver;
    
    function EndState()
    {
        Pawn.AnimBlendToAlpha(MELEE_CHANNEL, 0, 0.4);
    }
BEGIN:
	StopFireWeapon();
    Pawn.StopMoving();
    FinishRotation();
	Focus = None;
	FocalPoint = Enemy.Location;

	Sleep(0.5*Frand()); // try to stagger the animations for when more than one guy get's blinded
    exclaimMgr.Exclaim(EET_Pain, RandRange(0, 0.5));
	Pawn.AnimBlendParams(MELEE_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    Pawn.LoopAnim('Blinded',, 0.05, MELEE_CHANNEL);
    Sleep(BlindedDuration);

	Focus = Enemy;
	AnimStopLooping(MELEE_CHANNEL);
    myAIRole.GOTO_Attack();
    myAIRole.BotSelectAction();
}

function Notify_FallDown();

event FallDown()
{
    curAction = "FallDown";
    GotoState('MeFallDown');
}

state MeFallDown
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible, NotifyRunOver;
    
    function BeginState()
    {
        StopFireWeapon();
        Pawn.StopMoving();
        Focus = None;
	    FocalPoint = Pawn.Location + Vector(Pawn.Rotation)*100;
        bPlayingHit=true;
    }

    function EndState()
    {
        bPlayingHit=false;
        Pawn.AnimBlendToAlpha(HIT_CHANNEL, 0, 0.4);
    }

    function AnimEnd(int Channel)
    {
        if ( Channel == HIT_CHANNEL )
        {
            Notify();
        }
        else
        {
            Global.AnimEnd(Channel);
        }
    }
    function Notify_FallDown()
    {
        Notify();
    }

    event SeePlayer( Pawn Seen )
    {
        if(Focus == Enemy)
        {
            Global.SeePlayer( Seen );
        }
        else
        {
            Global.SeePlayer( Seen );
            Focus = None;
        }
    }

BEGIN:
	
	Pawn.AnimBlendParams(HIT_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    Pawn.PlayAnim('FullBodyHit_Back01',, 0.1, HIT_CHANNEL);
    WaitForNotification();

    Pawn.PlayAnim('Recover_Male',, 0.1, HIT_CHANNEL);
    WaitForNotification();

	Focus = Enemy;
    myAIRole.GOTO_Attack();
    myAIRole.BotSelectAction();
}


event FullBodyHit()
{
    curAction = "FullBodyHit";
    GotoState('MeFullBodyHit');
}

state MeFullBodyHit
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible, NotifyRunOver;
    
    function BeginState()
    {
        StopFireWeapon();
        Pawn.StopMoving();
        Focus = None;
	    FocalPoint = Pawn.Location + Vector(Pawn.Rotation)*100;
        bPlayingHit=true;
    }

    function EndState()
    {
        bPlayingHit=false;
        Pawn.AnimBlendToAlpha(HIT_CHANNEL, 0, 0.4);
    }

    function AnimEnd(int Channel)
    {
        if ( Channel == HIT_CHANNEL )
        {
            Notify();
        }
        else
        {
            Global.AnimEnd(Channel);
        }
    }
    function Notify_FallDown()
    {
        Notify();
    }

    event SeePlayer( Pawn Seen )
    {
        if(Focus == Enemy)
        {
            Global.SeePlayer( Seen );
        }
        else
        {
            Global.SeePlayer( Seen );
            Focus = None;
        }
    }

BEGIN:
	
	Pawn.AnimBlendParams(HIT_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    if(Frand() < 0.5)
        Pawn.PlayAnim('FullBodyHit_Front02',, 0.1, HIT_CHANNEL);
    else
        Pawn.PlayAnim('FullBodyHit_Front03',, 0.1, HIT_CHANNEL);
    WaitForNotification();

    Focus = Enemy;
    myAIRole.GOTO_Attack();
    myAIRole.BotSelectAction();
}

defaultproperties
{
     RotationRate=(Yaw=50000)
}
