/**
 * The main controller class for AI characters using the DEBAIT
 * framework.  The controller is responsible for low level behaviours,
 * like aiming, dodging, and moving, as well as reporting information
 * to the stage.  The stage handles higher level coordination,
 * especially between characters.  The AIRole handles the intermediate
 * logic required to translate orders into sequences of behaviours.
 *
 * TODO:
 *   - make sure all behaviours report completion properly, like
 *     TakePosition does.
 *
 *
 * @author  Mike Horgan (mikeh@digitalextremes.com)
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @author  Jesse LaChapelle (jesse@digitalextremes.com)
 * @version $Revision: 1.111 $
 * @date    June 2003
 */
class VGSPAIController extends VGSPAIBase
    native;

var class<VGSPAIController> PopUpClass;

//----------------------
// Behaviour properties
//----------------------

//How long must the enemy be out of sight before considering him lost
var float MaxLostContactTime;
//How long is the typical time between acquiring LOS and shooting
var(Firing) float ReflexTime;
//How many bullets in a typical burst of fire.
var(Firing) int MinNumShots, MaxNumShots;
//How long between bursts of fire
var(Firing) float MinShotPeriod, MaxShotPeriod;
//How many bursts since reload
var int   NumShotsSinceReload;
//How many bursts until we SHOULd reload
var(Firing) int NumShotsUntilReload;
// maximum chance-to-hit factor due to skill...
var(Firing) float MaxSkillOdds;
var(Anim) Name ReloadAnim;


////////////
//AimRelated
////////////
var(Firing) float BaseAimYawError;
var(Firing) float GameDifficultyFactor;
//aim approaches 0 as enemy's distance approaches this
var(Firing) float MaxAimRange;
//aim approaches 0 as enemy's relative lateral velocity approaches this
var(Firing) float MaxAimVelocity;
//aim approaches 1 as enemy stays in sight this long.
var(Firing) float MaxSecondsOfLOS;
//The scale used to aim away from the targets center, which ought to
//shrink with accuracy.
var float MissVectorScale;

const MAYATTACKDIST = 5000;

////////
// State Data
////////

//Rest
var float RestTime;

//StandGround
var float StandGroundTime;

//StrafeMove action
var float fOddsOfStrafeMove;
// don't tactical move until at least this much time has passed
var float MinTimeBetweenStrafeMove;


//FindNewCover
var float LastFindNewCoverTime;
var bool  bAdvanceWait;
var float LastMoveToBestFailedTime;

//AttackFromCover
var bool bWaitForLOS;
var bool bTakingCover;
//Flank

//MeleeAttack
var bool bPawnMayMelee;
var float LastMeleeTime;
var float MeleeChargeThreshold;
var float MeleeRange;
var Name MeleeAnim;

// Data for TakeUpPosition Order
var StagePosition TakeUpPosition;

// Data for StrafeMove action
var float   LastStrafeMoveTime;
//Last time at which we made a tactical move
var Vector  strafeTarget;
var bool    bStrafeDir;

//Data for Hide action
var float   LastHideTime;

//Data for TakeCover action
var float   maxDistToCrouchForCover;
var float   LastTakeCoverTime;

//Data for Wander
var float   LastWanderTime;

// Data for Panic action
var bool    bHavePanicked; //Only panic once.
var float   PanicStartTime;

///////
// End State members
///////


//---------------------------
// Other editable properties
//---------------------------

//how far the character will travel while panicking?
var float PanicRange;
// How long to focus on the enemy rather than the target when damaged
var float EnemyDistractDuration;
// Min distance between this character and current enemy before
// switching focus from ShootTarget to Enemy.
var float EnemyDistractDistance;
//Position selection behaviour tweaks
var float m_BunchPenalty;
var float m_BlockedPenalty;
var float m_BlockingPenalty;
var float m_NeedForContact;
var float m_NeedCohesion;
var float m_NeedForIntel;
var float m_NeedToAvoidCorpses;
var float m_NeedForClosingIn;
var float m_NeedForNearbyGoal;
var float m_SameSideOfEnemy;
var float m_CrossPenalty;
var float m_ProvidesCover;
var float m_TacticalHeight;

// enable debugging output
var() bool bDebugLogging;
// a bit-mask to reduce the quantity of debugging output, and related
// consts...
var() int AIDebugFlags;
const DEBUG_FIRING = 0x00000001;
const DEBUG_POSITIONS = 0x00000002;

// value added to path cost when passing through a claimed position
var() const int CLAIMED_POSITION_PENALTY;

//---------------------
// Internal properties
//---------------------

//Animation
const RELOAD_CHANNEL =11;
const LEAN_CHANNEL = 12;
const MELEE_CHANNEL = 13;

// How often to change focus
var float LastFocusChangeTime;
var float RandFocusChangeDuration;

// FireControl related
var bool  bPlayingHit;
var bool  bReloading;
var bool  bFireAtLastLocation;
var bool  bStopFireAnimation;
var bool  bIgnoreNeedToTurn;  //cmr haxx, for stockton fight
var bool  bDontFireWhileRunning;  //cmr haxx, for stockton fight
var int   NumShotsToGo;
var bool    bFireWeapon;
var float   curSweepTime;
var bool    bPlayWizzSnd;
var(firing) float sweepTimerPeriod;
var(firing) bool bTimerFireWeapon;


// Enemy Management
//indirect acquisition
var struct native export TAG_IndirectAcquisitionData {
    var Pawn  acquisitionBogie;
    var byte  acquisitionSighted;
    var byte  bIndirectPending;
} IndirectAcquisitionData;

//enemy info
var float EnemyInSightTime;
var bool  bEnemyIsVisibleCache;
var float EnemyVisibilityCacheTime;
var pawn  VisibleEnemy;
var float LoseEnemyCheckTime;
var float AcquireTime;
// an actor to shoot at if there's no enemy
var Actor ShootTarget;
var Actor tmpTarget;

var private OpponentFactory myCreator;
var private Name lastState;
var private EPhysics lastPawnPhysics;
var float lastHitTime; // time (seconds) pawn last took damage.
var String  curAction; //for debugging, should reflect current decision;
var bool bHibernating;
// AI Behaviour Modifier (Grunt, Leader, Medic)
var AIRole myAIRole;
var class<AIRole> AIType;

// Stage related
var Stage currentStage;
var StagePosition claimedPosition;

// Order Management
enum EStageOrder
{
    SO_None,
    SO_TakeUpPosition,
    SO_HoldPosition,
    SO_TakeCover,
    SO_AttackTarget,
    SO_Patrol
};

var EStageOrder curStageOrder;

//Exclamations
var ExclaimManager exclaimMgr;

//Timer Consts
const SIGHT_CHECK_TIMER = 39201;
const ENEMY_ACQUIRE_DELAY = 39202;
const REST_FOCUS_CHANGE = 39203;
const FIRE_TIMER_SLOT = 39204;
const PENDING_BURST = 39205;
const CHARGE_RELEASE = 39206;
const COVER_CHECK = 39207;

native final function Actor FindFlankPathToward(actor anActor, optional bool bWeightDetours);
native final function StagePosition FindNearestHidePosition(optional int EnemyIdx);

function StartSweep()
{
    MarkTime(curSweepTime);
    //if we start halfway through the period, we change direction
    if(frand() > 0.5)
        curSweepTime -= 0.5 * sweepTimerPeriod;
}

function float SweepScale()
{
    local float curSweepScale;
    curSweepScale = 0.5 + 0.5 * sin( 2.0 * pi * ((Level.TimeSeconds - curSweepTime) / sweepTimerPeriod) - pi/2.0);
    return class'SkillResponseCurves'.static.GetPointAt(int(skill), curSweepScale);
}

function drawSweep()
{
    local Rotator r;

    r = Aim(None, Pawn.Location, 0);
    r.Pitch = Pawn.Rotation.Pitch;
    drawdebuglineHSV(Pawn.Location + vect(0,0,10),
        Pawn.Location + vector(r) * VSize(Pawn.Location - Enemy.Location) + vect(0,0,10),
        (7.0-skill)*250/7,1,1);
}



//@@@ this shouldn't really be here, but it breaks the scripted
//@@@ sequences without it.
function SelectAction() {
    myAIRole.botSelectAction();
}

//----------------
// Implementation
//----------------

function Wander()
{
    //Perform_NotEngaged_Wander();
    Perform_Engaged_StrafeMove();
}


/**
 */
function float getLastHitTime() {
    return lastHitTime;
}

/**
 */
function setLastHitTime() {
    MarkTime(lastHitTime);
}

/**
 */
function BeginPlay()
{
    Super.BeginPlay();
}

/**
 * Called from Pawn.possess(), which is in PostBeginPlay() for
 * statically placed pawns.
 */
function Restart()
{
    Super.Restart();
    SpawnExclaimManager();
    initAIRole();
    //SetMultiTimer( SIGHT_CHECK_TIMER, 3, true );
    ResetSkill();
}

function ResetSkill()
{
	local float AdjustedYaw;
    
    if(Level.Game.Difficulty < 2.5)
    {
        GameDifficultyFactor = 1.5;
    }
    else if(Level.Game.Difficulty < 5)
    {
        GameDifficultyFactor = 1.0;
    }
    else if(Level.Game.Difficulty < 7)
    {
        GameDifficultyFactor = 0.75;
    }
    else
    {
        GameDifficultyFactor = 0.5;
    }
	
    RotationRate.Yaw = 100000;
    AdjustedYaw = 0.75 * RotationRate.Yaw;
	AcquisitionYawRate = AdjustedYaw;
    Pawn.PeripheralVision = 0;

	ReflexTime = lerp( Skill/7.0, 2.0, 0.5);
    
    if ( Skill < 2 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill > 6 )
		Pawn.PeripheralVision = -0.2;
	else
		Pawn.PeripheralVision = 1.0 - 0.2 * skill;
}

/**
 */
function SpawnExclaimManager()
{
    exclaimMgr = Spawn(class'ExclaimManager',self);
    exclaimMgr.init(self);
}

/**
 * Ensures that this controller has an AI role object that's ready to
 * go.
 */
function InitAIRole()
{
    if ( myAIRole == None ) {
        if ( AIType == None ) AIType = class'AIRole';
        myAIRole = Spawn(AIType,self);
    }
    myAIRole.init(self);
}

/**
 */
function Destroyed()
{
    Super.Destroyed();

	// make sure we detach ourselves from any stage we are in
	//
	UnClaimPosition();
	if(currentStage != none)
    {
        currentStage.leaveStage(self, RSN_Died);
		currentStage = None;
    }

    if(exclaimMgr != None) {
        exclaimMgr.Destroy();
    }
    if(myAIRole != None) {
        myAIRole.Destroy();
    }
}


//===========================
// Opponent Factory interface
//===========================

/**
 * this is called from the OpponentFactory when it sets up a new NPC
 */
function configure( OpponentFactory f, Stage initialStage ) {
    DebugLog( self $ " configured with " $ f $ ", " $ initialStage );
    myCreator = f;
    if ( initialStage != None ) initialStage.joinStage( self );
    ClientSwitchToBestWeapon();
}


/**
 */
function SetCreator(OpponentFactory f) {
    if(myCreator != None)
        return;
    myCreator = f;
}

//===========================================================================
// Stage Orders - these orders are the stage's interface to the bots.
//    By following the orders, the bots should appear to be
//    coordinated and intelligent in their actions.  However, the
//    orders still leave lots of latitude for personality and
//    variations in *how* they are executed.
//
//    Controllers communicate success and failure back to the stage
//    using the Report_* methods, as specified below...
//===========================================================================

/**
 * Stage is going to maintain bookeeping, but bot is free to do what
 * it likes.
 *
 * success: N/A
 * failure: N/A
 */
function StageOrder_None() {
    myAIRole.Order_None();
}

/**
 * Go to the specified position.  Wandering away from the position
 * after arriving and reporting is okay, as long as it doesn't
 * contradict new orders.  Staying in the general vicinity of the
 * position is prefered.
 *
 * success: Report_InPosition()
 * failure: Report_PositionUnreachable()
 */
function bool StageOrder_TakeUpPosition( StagePosition pos ) {
    myAIRole.Order_TakeUpPosition( pos );
    return true;
}

/**
 * Stay in the current position.  Bot can shoot, hide, or whatever
 * else seems appropriate in the moment.
 *
 * success: N/A
 * failure: Report_AbandonedPosition()
 */
function StageOrder_HoldPosition() {
    myAIRole.Order_HoldPosition();
}

function StageOrder_Patrol(PatrolPosition pos) {
    myAIRole.Order_Patrol(pos);
}

/**
 * Get out of the line of fire by going to (or staying at) pos.  May
 * require crouching at the destination.  If no position is specified,
 * the bot should choose a location itself.
 *
 * success: Report_Covered()
 * failure: Report_Exposed()
 */
function StageOrder_TakeCover( optional StagePosition pos ) {
    myAIROle.Order_TakeCover( pos );
}

/**
 * Attack the specified actor.  The bot should not change targets
 * unless directed to do so by the stage.  Thus it is important for
 * the bot to report if it is under attack from another enemy, so that
 * the stage will be able to promptly tell the bot to change enemies
 * (if it suits the strategy of the stage).
 *
 * success: Report_TargetDestroyed()
 * failure: Report_FailedAttack()
 */
function StageOrder_AttackTarget( Actor target ) {
    myAIRole.Order_AttackTarget( target );
}

//@@@ The rest of these are kind of odd orders, maybe obselete?

/**
 * Treat the specified pawn as your current enemy?
 * @@@ obselete?  implied by attack target?
 */
function StageOrder_AlertNewEnemy(Pawn bogie, bool bCanSee)
{
    AcquireEnemy(bogie, bCanSee);
}

/**
 *
 */
//@@@ right now, only newStage should call this.  use newStage.joinStage()
function StageOrder_JoinStage( Stage newStage )
{
    if ( currentStage != None ) {
        currentStage.leaveStage( self, RSN_JoinedOtherStage );
    }
    currentStage = newStage;
    if ( Enemy != None && currentStage != None ) {
        currentStage.Report_EnemySpotted(Enemy);
    }
}

/**
 * called to put NPC into a dormant (minimal performance hit) mode
 */
function StageOrder_Hibernate() {
    // do nothing if already asleep.
    if ( bHibernating ) return;
    // hibernate the pawn
    bHibernating = true;
    setCurAction("stasis");
    lastPawnPhysics = Pawn.Physics;
    Pawn.SetPhysics(PHYS_None);
	Pawn.SetCollision(false, false, false);
    Pawn.bStasis = true;
    pawn.bHidden = true;
    // hibernate the controller
    bStasis = true;
    GotoState('Dormant');
}

/**
 * called to undo hibernate()
 */
function StageOrder_Awaken() {
    // do nothing if already awake	
	if ( !bHibernating ) return;
    // awaken the pawn
    Pawn.bStasis = false;
	Pawn.SetCollision(true,true,true);
    Pawn.SetPhysics( lastPawnPhysics );
    // awaken the controller
    bStasis = false;
    pawn.bHidden = false;
    bHibernating = false;
    if(myAIRole != None);
        myAIRole.awakenSucceeded();
}


//=================
//Stage interfacing
//=================

/**
 * called from stage when providing a shooting position to make sure it
 * meets bot's requirements
 **/
function bool VerifyShootingPosition(StagePosition position)
{
    if ( Enemy == None || position == None ) return false;
    if( VSize(Enemy.Location - position.Location) > GetMaxFiringRange() ) {
        return false;
    }
    else return true;
}

/**
 * Heigher weight == better
 **/
function float WeightStagePosition(StagePosition position)
{
    local float weight;
    local float total;

    if(Enemy == None)
        return 1.0;

    if( !MayAttack(position.Location, Enemy)
        || currentStage.PositionProvidesCoverFromEnemy(position, Enemy) == 0
        || position.avoidCount > 0)
        return 0;

    total = m_BunchPenalty + m_BlockedPenalty + m_BlockingPenalty
              + m_NeedForContact
              + m_NeedCohesion + m_NeedForIntel + m_NeedToAvoidCorpses
              + m_NeedForClosingIn + m_NeedForNearbyGoal + m_SameSideOfEnemy + m_CrossPenalty
              + m_ProvidesCover + m_TacticalHeight;

    if( total == 0 )
        return 1.0;

    weight =
        m_BunchPenalty * ProjDistToBuddiesAsSeenFromThreat(position)
        + m_BlockedPenalty * BlockedLineOfFireByBuddies(position)
        + m_BlockingPenalty * BlockingLineOfFireOfBuddies(position)
        + m_NeedForContact * NumberOfLinesOfSightToBuddies(position)
        + m_NeedCohesion * ProperDistanceToBuddies(position)
        + m_NeedForIntel * NumberOfLinesOfSightToThreats(position)
        + m_NeedToAvoidCorpses * DistanceToDeadBuddies(position)
        + m_NeedForClosingIn * MinimumDistanceToThreat(position)
        + m_NeedForNearbyGoal * DistanceFromMe(position)
        + m_SameSideOfEnemy * SameSideOfEnemy(position)
        + m_CrossPenalty * CrossInFront(position)
        + m_ProvidesCover * ProvidesCover(position)
        + m_TacticalHeight * TacticalHeight(position);

    return weight / total;
}

function logWeight(StagePosition position)
{
    LOG("---");
    log("m_BunchPenalty"@m_BunchPenalty * ProjDistToBuddiesAsSeenFromThreat(position));
    log("m_BlockedPenalty"@ m_BlockedPenalty* BlockedLineOfFireByBuddies(position));
    log("m_BlockingPenalty"@ m_BlockingPenalty* BlockingLineOfFireOfBuddies(position));
    log("m_NeedForContact"@ m_NeedForContact* NumberOfLinesOfSightToBuddies(position));
    log("m_NeedCohesion"@ m_NeedCohesion* ProperDistanceToBuddies(position));
    log("m_NeedForIntel"@ m_NeedForIntel* NumberOfLinesOfSightToThreats(position));
    log("m_NeedToAvoidCorpses"@ m_NeedToAvoidCorpses* DistanceToDeadBuddies(position));
    log("m_NeedForClosingIn"@ m_NeedForClosingIn* MinimumDistanceToThreat(position));
    log("m_NeedForNearbyGoal"@ m_NeedForNearbyGoal* DistanceFromMe(position));
    log("m_SameSideOfEnemy"@ m_SameSideOfEnemy* SameSideOfEnemy(position));
    log("m_CrossPenalty"@ m_CrossPenalty* CrossInFront(position));
    log("m_ProvidesCover"@ m_ProvidesCover* ProvidesCover(position));
    log("m_TacticalHeight"@ m_TacticalHeight* TacticalHeight(position));
}

/**
 */
function float ProjDistToBuddiesAsSeenFromThreat(StagePosition position)
{
    local float tmpVal;
    local vector enemyRight;

    if( currentStage.StageAgents.Length == 1) return 1.0;

    tmpVal = position.fProjDistToBuddies;

    //Undo the inclusion of ourselves in the stage's calculations
    enemyRight = vect(0,1,0) >> Enemy.Rotation;
    tmpVal -= abs( (Pawn.Location - position.Location) dot enemyRight );
    tmpVal = tmpVal / (currentStage.StageAgents.Length - 1);
    if( tmpVal > 1000 ) {
        return 1.0;
    }
    else {
        return tmpVal / 1000.0;
    }

}

/**
 */
function float BlockedLineOfFireByBuddies(StagePosition position)
{
    local float returnVal;

    if( currentStage.StageAgents.Length == 1) return 1.0;
    returnVal = currentStage.calculateStagePosnLOSIsBlocked(self, position);
    return 1.0 - (returnVal / (currentStage.StageAgents.Length - 1));
}

/**
 */
function float BlockingLineOfFireOfBuddies(StagePosition position)
{
    local float returnVal;

    if( currentStage.StageAgents.Length == 1) return 1.0;
    returnVal = currentStage.calculateStagePosnBlocksLOS(self, position);
    return 1.0 - (returnVal / (currentStage.StageAgents.Length - 1));
}

/**
 */
function float NumberOfLinesOfSightToBuddies(StagePosition position)
{
    return 0;
}

/**
 */
function float ProperDistanceToBuddies(StagePosition position)
{
    local float tmpVal;

    if( currentStage.StageAgents.Length == 1) return 1.0;

    tmpVal = position.fDistToBuddies;
    //Undo the inclusion of ourselves in the stage's calculations
    tmpVal -= VSize(Pawn.Location - position.Location);
    tmpVal = tmpVal / (currentStage.StageAgents.Length);

    if ( tmpVal > 1000 ) {
        return 0;
    }
    else {
        return (1000.0 - tmpVal) / 1000.0;
    }
}

/**
 */
function float NumberOfLinesOfSightToThreats(StagePosition position)
{
    local int i, count;


    //calculate weight of bitvector
    for( i=0; i<8; i++ )
    {
        if( (position.StandLOF & (0x1 << i)) > 0) count++;
    }
    return count;
}

/**
 */
function float DistanceToDeadBuddies(StagePosition position)
{
    return 1.0 - position.FearCost/750.0;
}

/**
 */
function float MinimumDistanceToThreat(StagePosition position)
{
    local float returnVal;

    returnVal = VSize(Enemy.Location - position.Location);
    if ( returnVal > 3000 || returnVal < 400 ) {
        return 0;
    }
    //A function
    // 0-1: -> 400-900, 1-0: -> 900-3000
    if( returnVal > 400 && returnVal < 900 )
    {
        return (returnVal-400) / 500;
    }
    else //returnVal > 900
    {
        return 1.0 - ( (returnVal-900)/ 2100);
    }
}

function float DistanceFromMe(StagePosition position)
{
    local float returnVal;

    // @@@ LUT
    //if(claimedPosition != None && VSize(Pawn.Location - claimedPosition.Location) < 100)
    //    returnVal = currentStage.GetPositionDistance(claimedPosition, position);
    //else
        returnVal = VSize(Pawn.Location - position.Location);

    if ( returnVal > 1000 ) {
        return 0;
    }
    else {
        return 1.0 - ( (returnVal) / 1000.0);
    }
}

function float SameSideOfEnemy(StagePosition position)
{
    local float dotP;
    local Vector enemyDir;

    if( Enemy == None )
        return 1.0f;

    enemyDir = Normal( Pawn.Location - Enemy.Location );

    dotP = enemyDir dot Normal(Position.Location - Enemy.Location);
    if( dotP > 0.17)
        return 1.0;

    return 0;

}

/**
 * Determine if a position would require crossing in front of a buddy
 * (from the enemy's pov)
 * a cross is not required if:
 * A) the angle between me and the position is smaller than between me and buddy
 * or B) the angle is closer to me than to my buddy
 **/
function float CrossInFront(StagePosition position)
{
    local int i;
    local VGSPAIController buddy;
    local Vector enemy2Me, posDir, enemy2Pos, enemy2Buddy;
    local float me2buddyAngle, me2posAngle, buddy2posAngle;
    local float returnVal;

    if( Enemy == None || currentStage.StageAgents.Length == 1)
        return 1.0f;

    enemy2Pos = Normal(position.Location - Enemy.Location);
    enemy2Me = Normal(Pawn.Location - Enemy.Location);
    me2posAngle = enemy2Pos dot enemy2Me;
    posDir = (position.Location - Pawn.Location);

    for( i=0; i<currentStage.StageAgents.Length; i++) {
        buddy = currentStage.StageAgents[i].controller;
        if(buddy == self)
            continue;
        enemy2Buddy = Normal(buddy.Pawn.Location - Enemy.Location);
        me2buddyAngle = enemy2Buddy dot enemy2Me;
        if( me2posAngle > me2buddyAngle )
            continue;
        buddy2posAngle = enemy2Pos dot enemy2Buddy;
        if ( me2posAngle > buddy2posAngle )
            continue;
        returnVal += 1.0;
    }

    returnVal /= (currentStage.StageAgents.Length - 1);

    return 1.0 - returnVal;
}

function float ProvidesCover(StagePosition pos)
{
    if(currentStage != None)
        return currentStage.PositionProvidesCoverFromEnemy(pos, Enemy) / 2.0f;

    return 0.0;
}

function float TacticalHeight(StagePosition pos)
{
    local float ZDiff;

    ZDiff = (pos.OnGroundZ + pawn.CollisionHeight) - Enemy.Location.Z;
    if(ZDiff < -pawn.CollisionHeight)
    {
        return 0;
    }
    return 0.5 + FClamp(ZDiff / 500.0, 0.0, 0.5);
}

//==============
// Events
// This is where "engine level" notifications go.
//==============

/**
 *  Called with an AnimNotify_Script during a melee attack
 **/
function Notify_Melee();

/**
 * Called when a shot is taken at this pawn (so it can dodge)
 **/
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
    DebugLog("ReceivedWarning from "$shooter$shooter.Controller);
}

/**
 * Called when the bot takes damage
 **/
function DamageAttitudeTo(Pawn Other, float Damage)
{
    if ( (Pawn.health > 0) && (Damage > 0) ) {
        TryAcquiringNewEnemy(Other , CanSee(Enemy) );
    }
    if( SameTeamAs(Other.Controller) ) {
		if(exclaimMgr != none)
			exclaimMgr.Exclaim(EET_FriendlyFire, 0);
    }
    else {
		if(exclaimMgr != none)
			exclaimMgr.Exclaim(EET_Pain, RandRange(0, 0.5) );
    }
	if(myAIRole != none)
		myAIRole.OnTakingDamage( Other,  Damage);
    setLastHitTime();
}


/**
 */
event HearNoise( float Loudness, Actor NoiseMaker)
{
    local Pawn maker;

    maker = Pawn(NoiseMaker);

    if ( maker == None ) return;

    TryAcquiringNewEnemy(maker, false);
    IndirectEnemyAcquisition(maker.Controller);
}

/**
 * called when a player (bIsPlayer==true) pawn is seen
 **/
event SeePlayer( Pawn Seen )
{
    local bool spamlog;
    
    if( ShouldMelee(Seen) && myAIRole != None)
        myAIRole.OnMeleeRange();

	if ( Enemy == Seen )
	{
		Focus = Enemy;
        UpdateEnemyInfo();
	}
    else TryAcquiringNewEnemy(Seen, true);

    IndirectEnemyAcquisition(Seen.Controller);
    spamlog = false; // set to true for previous behavior
    if( spamlog && Seen.Health <= 0 ) {
        log("SEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE CORPSE");

    }
}

/**
 * Called as soon as Enemy is no longer visible (LOS)
 **/
event EnemyNotVisible()
{
    //log("EnemyNotVisible"@Enemy);
    EnemyInSightTime = -1;

    //bEnemyAcquired = false;
    if ( Focus == Enemy )
    {
        Focus = None;
        FocalPoint = LastSeenPos;
    }
    if ( currentStage != None )
    {
        currentStage.Report_UnSighted(self, Enemy);
    }
    if ( myAIRole != None )
    {
        myAIRole.OnLostSight();
    }
}

/**
 * This should not only check if our enemy was killed,
 * but also notice if we see a friendly die.
 **/
function NotifyKilled( Controller Killer, Controller Killed, pawn KilledPawn )
{
    local Pawn oldEnemy;

    oldEnemy = Enemy;
    Super.NotifyKilled(Killer, Killed, KilledPawn);
    if ( Enemy == None ) {
        SetRelaxAttributes();
    }
    if ( currentStage != None && KilledPawn == oldEnemy) {
        currentStage.Report_Killed(self, Enemy);
        currentStage.FindNewEnemyFor(self);
    }
    if ( Killer == self && KilledPawn == oldEnemy ) {
        exclaimMgr.Exclaim(EET_KilledEnemy, 0.5);
    }
    //@@@ Distribute
    if( Killer != self)
        CheckInterestInKill( Killer, Killed, KilledPawn );

    if(Enemy == None)
            SelectAction();
}

/**
 * If it's an enemy, notice it, if it's a friend, coordinate moving
 * out of each others way.
 **/
event bool NotifyBump(actor Other)
{
    local Pawn P;

    P = Pawn(Other);
    if (P == None)
        return false;

    TryAcquiringNewEnemy(P, true);

    if ( Enemy == P )
        return false;

    if ( AdjustAround(P) )
        return false;
    /*
    if ( Enemy != None )
    {
        if ( EnemyIsVisible() )
        {
            UnClaimPosition();
            Perform_Engaged_StrafeMove();
            return false;
        }
    }
    */
    return false;
}

function Startle(Actor Other)
{
    myAIRole.OnStartle(Other);
}

/////////////////////////

/**
 * if another bot sees me, he'll call this to
 * check if I have an enemy he should
 * be interested in.
 **/
function bool SharingEnemy()
{
    if ( Enemy != None && !LostContact(MaxLostContactTime) )
        return true;

    return false;
}

function ResetIndirectEnemyAcquisition()
{
    SetMultiTimer(ENEMY_ACQUIRE_DELAY, 0, false);
    IndirectAcquisitionData.bIndirectPending = 0;
}

/**
 * if we see someone with an enemy, maybe we want to engage it?
 **/
function IndirectEnemyAcquisition(Controller seen)
{
    local float delay;
    local VGSPAIController vgseen;

    vgSeen = VGSPAIController(seen);


    if( vgseen != None &&
        IndirectAcquisitionData.bIndirectPending == 0 &&
        SameTeamAs(vgseen) &&
        vgseen.SharingEnemy() &&
        ShouldAcquireEnemy(vgseen.Enemy, false) )
    {

        IndirectAcquisitionData.acquisitionBogie = vgseen.Enemy;
        IndirectAcquisitionData.acquisitionSighted = 0;
        IndirectAcquisitionData.bIndirectPending = 1;
        delay = 0.5 + Frand();
        SetMultiTimer(ENEMY_ACQUIRE_DELAY, delay, false);
        //notify stage
        if(currentStage != None)
        {
            //Stage will assess threat, and assign new enemy
            currentStage.Report_EnemySpotted(vgseen.Enemy);
        }
    }
}


function CheckInterestInKill(Controller Killer, Controller Killed, pawn KilledPawn )
{
    local bool bHaveLOF;

	if(currentStage != none)
		bHaveLOF = currentStage.PositionHasLOFToEnemy(claimedPosition, Killed.Pawn);

    if( bHaveLOF && myAIRole != none)
        myAIRole.OnWitnessedKill( killer, killedPawn );

    //witnessed death of opposing faction member
    if ( SameTeamAs(Killer) && !SameTeamAs(Killed)
              && KilledPawn != None && Pawn != None
              && VSize(KilledPawn.Location - Pawn.Location) < 2500
              && currentStage != None && claimedPosition != None
              && bHaveLOF )
    {
		if(exclaimMgr != none)
			exclaimMgr.Exclaim(EET_WitnessedKilledEnemy, RandRange(1.0, 1.5));
        return;
    }

    //witnessed death of friendly
    if ( SameTeamAs(Killed)
              && KilledPawn != None && Pawn != None
              && VSize(KilledPawn.Location - Pawn.Location) < 2500 )
    {
        if( FastTrace(Pawn.Location, KilledPawn.Location) )
        {
			if(exclaimMgr != none)
				exclaimMgr.Exclaim(EET_WitnessedDeath, RandRange(0.0, 1.0), 0.5);
            if ( Killer != None && Killer.Pawn != None ) {
                TryAcquiringNewEnemy(Killer.Pawn, false );
            }
            return;
        }

    }
}



/**
 * This is supposed to "interrupt" the regular movetowards stuff (by
 * setting bAdjusting) so that the bot moves around a dynamic obstacle
 **/
function bool AdjustAround(Pawn Other)
{
    local float speed;
    local vector VelDir, OtherDir, SideDir;

    speed = VSize(Pawn.Acceleration);
    if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
        return false;

    VelDir = Pawn.Acceleration/speed;
    VelDir.Z = 0;
    OtherDir = Other.Location - Pawn.Location;
    OtherDir.Z = 0;
    OtherDir = Normal(OtherDir);
    if ( (VelDir Dot OtherDir) > 0.8 )
    {
        bAdjusting = true;
        SideDir.X = VelDir.Y;
        SideDir.Y = -1 * VelDir.X;
        if ( (SideDir Dot OtherDir) > 0 )
            SideDir *= -1;
        AdjustLoc = Pawn.Location + 2 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
    }
}
//==============
// Enemy Management
//==============

function float AssessThreat( Pawn NewThreat, bool bThreatVisible )
{
    local float ThreatValue, NewStrength, Dist;

    if( NewThreat.Controller == None || SameTeamAs(NewThreat.Controller) ) return -1;
    //NewStrength = RelativeStrength(NewThreat);

    //Because the threat is also the objective, we want it's priority low to prevent frustrating
    //the player.
    if( NewThreat == ShootTarget)
        return 0.1;

    ThreatValue = NewStrength;
    Dist = VSize(NewThreat.Location - Pawn.Location);
    if ( Dist < 2000 )
    {
        ThreatValue += 0.2;
        if ( Dist < 1500 )
            ThreatValue += 0.2;
        if ( Dist < 1000 )
            ThreatValue += 0.2;
        if ( Dist < 500 )
            ThreatValue += 0.2;
    }

    if ( bThreatVisible )
        ThreatValue += 1;
    if ( (NewThreat != Enemy) && (Enemy != None) )
    {
        if ( !bThreatVisible )
            ThreatValue -= 5;
        if ( Dist > 0.7 * VSize(Enemy.Location - Pawn.Location) )
            ThreatValue -= 0.25;
        ThreatValue -= 0.2;
    }

    if ( NewThreat.IsHumanControlled() )
            ThreatValue += 0.25;

    //DebugLog("assess threat "$ThreatValue$" for "$NewThreat);
    return ThreatValue;
}

/**
 * Has this bot been out of contact for MaxTime
 *  the stage may call this to see if an enemy can be removed.
 **/
function bool LostContact(float MaxTime)
{
    if ( Enemy == None || Enemy.Controller == None)
        return true;

    if ( TimeElapsed( FMax(LastSeenTime, AcquireTime) , MaxTime) )
        return true;

    return false;
}

/* LoseEnemy()
get rid of old enemy, if stage lets me
*/
function bool LoseEnemy(float Time)
{
    if ( Enemy == None || currentStage == None)
        return true;
    if ( (Enemy.Health > 0) && (Enemy.Controller != None) && (!TimeElapsed(LoseEnemyCheckTime,0.2)) )
        return false;
    MarkTime(LoseEnemyCheckTime);
    if ( currentStage.Report_EnemyLost(self, Time) )
    {
        return true;
    }
    // still have same enemy
    return false;
}
function bool SameTeamAs( Controller c )
{
    return (c.Pawn.Race == Pawn.Race || c.IsA('PlayerController'));
}

function bool EnemyIsVisible()
{
    if ( (EnemyVisibilityCacheTime == Level.TimeSeconds)
             && (VisibleEnemy == Enemy) )
    {
        return bEnemyIsVisibleCache;
    }
    VisibleEnemy = Enemy;
    EnemyVisibilityCacheTime = Level.TimeSeconds;
    bEnemyIsVisibleCache = LineOfSightTo(Enemy);
    return bEnemyIsVisibleCache;
}

function TryAcquiringNewEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy)
{
    local bool bShouldAcquire;

    if( Enemy == potentialEnemy || potentialEnemy.Controller == None
            || SameTeamAs(potentialEnemy.Controller) )
    {
        return;
    }

    bShouldAcquire = ShouldAcquireEnemy(potentialEnemy, bCanSeePotEnemy);
    if( bShouldAcquire ) {
        AcquireEnemy( potentialEnemy, bCanSeePotEnemy);
    }
    else {
        //TODO: Maybe some exclaims about "There's more over there." etc
    }

    if(myAIRole != None)
    {
        if ( bCanSeePotEnemy ) {
            myAIRole.OnThreatSpotted( potentialEnemy );
        }
        else {
            myAIROle.OnThreatHeard( potentialEnemy );
        }
    }
    //notify stage
    if(currentStage != None)
    {
        //Stage will assess threat, and assign new enemy
        currentStage.Report_EnemySpotted(potentialEnemy);
    }
}

function bool ShouldAcquireEnemy( Pawn potentialEnemy, bool bCanSeePotEnemy )
{
    local float newThreatVal, oldThreatVal;

    if(Enemy == None)
        return true;

    oldThreatVal = AssessThreat(Enemy, EnemyIsVisible());
    newThreatVal = AssessThreat(potentialEnemy,bCanSeePotEnemy);

    return newThreatVal > oldThreatVal;

}

function AcquireEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy)
{
    ResetIndirectEnemyAcquisition();
    MarkTime(AcquireTime);
    
	Enemy = potentialEnemy;
    Target = Enemy;
    EnemyInSightTime = -1;
    MoveTimer = -1;
    SetMultiTimer(FIRE_TIMER_SLOT, 0.1, true);
    bEnemyAcquired = false;
    if(!bCanSeePotEnemy)
    {
        LastSeenTime = -1000;
        bEnemyInfoValid = false;
    }
    else
    {
        if(exclaimMgr!=None)
            exclaimMgr.Exclaim(EET_AcquireEnemy, 0);
        UpdateEnemyInfo();
    }
    SetCombatAttributes();

    if(myAIRole != None)
        myAIRole.OnEnemyAcquired();
}

function EnemyNowVisible();

/**
 * Update the visibility info
 **/
function UpdateEnemyInfo()
{
    //Update lastseen visibility info
    if(EnemyInSightTime == -1)
    {
        if( !FastTrace(Enemy.Location, Pawn.Location+Pawn.BaseEyeHeight*vect(0,0,1) ) )
            return;

        MarkTime(EnemyInSightTime);

        //Only remark on visibility if it's not a new enemy
        if( VisibleEnemy == Enemy && currentStage != None
                    && currentStage.Request_PercentEyeSighted(self) == 0
                    && TimeElapsed(LastSeenTime, 1.0) )
        {
            exclaimMgr.Exclaim(EET_NoticeEnemy, 0);
        }

        //only need to update the stage if we were actually unsighted until now
        if(currentStage != None)
        {
            currentStage.Report_EyeSighted(self, Enemy);
        }
        EnemyNowVisible();
    }

    //This happens in unController.cpp LineOfSight
    //LastSeenTime = Level.TimeSeconds;
    //LastSeenPos = Enemy.Location;
    //LastSeeingPos = Pawn.Location;
    //bEnemyInfoValid = true;

    VisibleEnemy = Enemy;
    MarkTime(EnemyVisibilityCacheTime);
    bEnemyIsVisibleCache = true;

    //UpdateFocus();
}
function UpdateFocus()
{
    Focus = Enemy;
}

/**
 * When we acquire an enemy, we should "heighten awareness" as it were.
 **/
function SetCombatAttributes();

/**
 * When we don't have an enemy, our awareness is "less"
 **/
function SetRelaxAttributes();

//==============
// Decision logic.
// Given a situation, decide what tactical behaviour is appropriate.
// In general, we must follow orders first, however the bot may have discretion about how to handle some orders
// (engage enemies first, or while on the way etc)
//==============

/**
 *  Stay put.  Fire at will.
 **/
function FollowOrder_HoldPosition()
{
    //@@@ should make use of take-cover behaviours in hold position impl.
    myAIRole.RoleSelectAction();
}

/**
 */
function FollowOrder_TakeCover() {
    Perform_Engaged_TakeCover();
}

/**
 * Call the appropriate order function
 **/
function FollowOrder()
{
   switch (curStageOrder)
   {
   case SO_None:
       myAIRole.RoleSelectAction();
       break;
   case SO_TakeUpPosition:
       myAIRole.RoleSelectAction();
       break;
   case SO_HoldPosition:
       FollowOrder_HoldPosition();
       break;
   case SO_TakeCover:
       FollowOrder_TakeCover();
       break;
   case SO_Patrol:
       myAIRole.RoleSelectAction();
       break;
   default:
       myAIRole.RoleSelectAction();
       break;
   }
}


/**
 * Override for non-standard weapon range checking.
 */
function float GetMaxFiringRange()
{
   return 10000;

   //@@@Warfare Codebase
   //return Pawn.Weapon.MaxRange;
}

/**
 */
function MultiTimer( int timerID ) {
    switch ( timerID ) {
    case SIGHT_CHECK_TIMER:
        if ( enemy != None
             && VSize( enemy.location - pawn.location ) > pawn.sightRadius ) {
            // make sure that we lose track of enemies that have moved
            // beyond our sight radius.
            EnemyNotVisible();
            Enemy = None;
        }
        break;
    case ENEMY_ACQUIRE_DELAY:
        AcquireEnemy(IndirectAcquisitionData.acquisitionBogie,
                        IndirectAcquisitionData.acquisitionSighted != 0);
        break;
    case PENDING_BURST:
        handlePendingBurstTimer();
        break;
    case FIRE_TIMER_SLOT:
        if(bTimerFireWeapon)
        {
            bTimerFireWeapon = false;
			StartFireWeapon();
		}
        break;
    case CHARGE_RELEASE:
        handleChargeRelease();
    default:
        super.MultiTimer( timerID );
    }
}

////////////////////////////
// Animation Control
////////////////////////////

function AnimEnd(int Channel)
{
    switch(Channel)
    {
    case RELOAD_CHANNEL:
        ReloadComplete();
        break;
    default:
        Pawn.AnimEnd(Channel);
        break;
    }
}

function StartReload()
{
	Pawn.AnimBlendParams(RELOAD_CHANNEL, 1.0, 0.0, 0.5, Pawn.SpineBone1);
    Pawn.PlayAnim(ReloadAnim, , ,RELOAD_CHANNEL);
	StopFireWeapon();
    NumShotsSinceReload = 0;
	bReloading=true;
    
}

function ReloadComplete()
{
	bReloading=false;
	Pawn.AnimBlendToAlpha(RELOAD_CHANNEL, 0, 0.4);
}

function PlayTakeHit()
{
    StopFireWeapon();
    bPlayingHit=true;
}

function TakeHitComplete()
{
    bPlayingHit=false;
}

////////////////////////////
// Fire Control
////////////////////////////


/**
 * Game specific override
 */
function float getWeaponFireRate( Weapon w );

/**
 * Call this to start the weapon firing
 **/
function StartFireWeapon()
{
    ChooseMode();
    bFireWeapon = true;
    NumShotsToGo = iRandRange(MinNumShots,MaxNumShots);
    StartSweep();

    if(exclaimMgr != None)
        exclaimMgr.Exclaim(EET_Attacking, 0, 0.1);

	if(bReloading || bPlayingHit)
	{
		SetMultiTimer(PENDING_BURST, 0.1, true);
		return;
	}

    if(!TimeElapsed(EnemyInSightTime, ReflexTime) )
    {
        // log("Reflex"@ReflexTime - (Level.TimeSeconds - EnemyInSightTime));
        SetMultiTimer(PENDING_BURST, ReflexTime - (Level.TimeSeconds - EnemyInSightTime), false);
        return;
    }
    WeaponFireAgain(1.0, false);
}
/**
 * Call this to stop the weapon firing
 **/
function StopFireWeapon()
{
    SetMultiTimer(PENDING_BURST, 0, false);
    bFireWeapon=false;
    bStopFireAnimation = true;
}

/**
 * called at the end of a burst of fire to
 * check reload conditions and set up next burst
 **/
function EndOfBurst()
{
    StopFiring();
    if( ShouldReload() )
        myAIRole.OnMustReload();
    StartNewBurst();
}

function StartNewBurst() {
    local float timeOut;
    bFireWeapon = true;
    NumShotsToGo = iRandRange(MinNumShots,MaxNumShots);
    timeout = RandRange(MinShotPeriod,MaxShotPeriod);
    SetMultiTimer(PENDING_BURST, timeout, false);
}

function bool ShouldReload()
{
    if(NumShotsUntilReload > 0 && NumShotsSinceReload >= NumShotsUntilReload)
        return true;
    return false;
}
/**
 * How long to "charge" weapon for
 **/
function float getChargeDelay()
{
    return 0.1;
}
/**
 * Called when CHARGE_RELEASE timer fires
 **/
function handleChargeRelease()
{
    if(!Pawn.Weapon.ReadyToFire(Pawn.Weapon.BotMode))
        SetMultiTimer(CHARGE_RELEASE, 0.1, false);
    else
        StopFiring();
}

// called when the PENDING_BURST timer goes
function handlePendingBurstTimer()
{
	if(bReloading || bPlayingHit)
	{
		SetMultiTimer(PENDING_BURST, 0.1, true);
		return;
	}   

    SetMultiTimer(PENDING_BURST, 0, false);
    StartSweep();
    ChooseMode();

    WeaponFireAgain(1.0, false);
}

/**
 * wrap up some of the weapon code interface
 * for stopping its firing
 **/
function StopFiring()
{
    if ( (Pawn != None) && (Pawn.Weapon != None) /*&& Pawn.Weapon.IsFiring()*/ )
    {
           WeaponStopFire( Pawn.Weapon );
//      bStoppedFiring = true;
    }
//  bCanFire = false;
    bFire = 0;
    bAltFire = 0;
}

/** code-base specific
 * i.e
 * Pawn.Weapon.ServerStopFire(Pawn.Weapon.BotMode);
 **/
function WeaponStopFire( Weapon w );

/**
 * Find a spot on a side of the enemy so we'll miss
 **/
function CalculateMissVectorScale()
{
    if(Frand() < 0.5)
        MissVectorScale = 1.0;
    else
        MissVectorScale = -1.0;
}

function ChooseMode();

/**
 * This is a callback from the weapon when it has finished firing.
 * bFinishedFire==true indicates a callback from the weapon, and is
 * passed into BotFire to indicate that we want to keep shooting
 * (otherwise, the gun would return false since the RefireTime on the
 * weapon hadn't been reached yet)
 *
 * In essence, when this is called, you call BotFire again
 * to keep the trigger pulled.
 *
 * the RefireRate is set on the weapon, and gives you a chance to
 * shoot in "bursts" it should really be called RefireOdds, since it's
 * really the chance that you'll stop the burst.
 **/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
    local bool bFireSuccess;
    if(!bFireWeapon){
		bStopFireAnimation = true;
        return false;
    }

	if ( Target == None )
	{
		Target = Enemy;
	}
    if ( Target == None ) {
        bStopFireAnimation = true;
        return false;
    }

    if ( NumShotsToGo <= 0 ) {
        EndOfBurst();
        bStopFireAnimation = true;
        return false;
    }

    //Can't Attack
    if( ( NeedToTurn(Target.Location) && !bIgnoreNeedToTurn ) || !CanAttack(Target) ) {
        SetMultiTimer(PENDING_BURST, 0.1, true);
		bStopFireAnimation = true;
        return false;
    }

    //Can't Fire
    bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
    if (!bFireSuccess) {
        SetMultiTimer(PENDING_BURST, 0.1, true);
        bStopFireAnimation = true;
        return false;
    }

    if( isChargeWeapon() )
    {
        if( bFinishedFire )
            Pawn.Weapon.BotFire(false);
        SetMultiTimer(CHARGE_RELEASE, getChargeDelay(), false);
    }

    //Fired Properly
    NumShotsToGo--;
    NumShotsSinceReload++;
    return bFireSuccess;
}


/**
 * return true if weapon capable of hitting target, and allowed to attack
 **/
function bool CanAttack(Actor Other)
{
    local bool result;

    if(Pawn == None || Pawn.Weapon == None)
    {
        return(false);
    }

    result = MayAttack(Pawn.Location, Other) && Pawn.Weapon.CanAttack(Other);
    DebugLog( "Weapon.CanAttack() returned" @ result, DEBUG_FIRING );
    return result;
}

function bool NeedToTurn(vector targ)
{
    local vector LookDir,AimDir;
    LookDir = Vector(Pawn.Rotation);
    LookDir.Z = 0;
    LookDir = Normal(LookDir);
    AimDir = targ - Pawn.Location;
    AimDir.Z = 0;
    AimDir = Normal(AimDir);

    return ((LookDir Dot AimDir) < 0.93);
}

/**
 * return false if we're too far (to be fair)
 * but if the player is taking pot-shots, pot shot back for a while
 **/
function bool MayAttack(Vector from, Actor Other)
{
    local vector A, B;
    local float Dist;

    A = from;
    B = Other.Location;
    A.Z = 0;
    B.Z = 0;

    Dist = VSize(A - B);
    return (( Dist < MAYATTACKDIST ) ||
        (TimeElapsed(LastHitTIme,0.5) && !TimeElapsed(LastHitTIme, 5.0) ));
}


/**
 * returns a number [0,1] to indicate odds of "shooting to hit"
 **/
function float ChanceToHit()
{
    local float skillOdds, range, relVelocity, losTime, result;

    if ( Pawn == None || Target == None ) return 0;

    //skill (0-7)
    skillOdds = FMax(MaxSkillOdds, Skill/7.0f);

    //target distance
    range =  VSize(Pawn.Location - Target.Location);
    range = FClamp( 1.0 - (range/MaxAimRange), 0.0, 1.0);
    if(range == 0.0) return 0;

    //relative Velocity
    relVelocity = Normal(Target.Location - Pawn.Location)
        dot Normal( (Target.Location + 2.0*Target.Velocity)
                       - (Pawn.Location + Pawn.Velocity) );
    relVelocity = FClamp(relVelocity, 0.0, 1.0);
    if(relVelocity == 0.0) return 0;

    //how long visible
    if(Target != Enemy) {
        losTime = 1.0;
    }
    else if(EnemyIsVisible()) {
        losTime = Level.TimeSeconds - EnemyInSightTime;
        losTime = FMin(losTime / MaxSecondsOfLOS, 1.0);
    }

    result = 1.0 * skillOdds * range * relVelocity*losTime;
    DebugLog( "ChanceToHit:" @ result @ "skill:" @ skillOdds
              @ "range:" @ range @ "relative velocity" @ relVelocity
              @ "los time" @ losTime, DEBUG_FIRING );
    return result;
}

function bool WillFriendlyFire(vector start, vector end, out Pawn HitFriend, out vector outHitLocation)
{
    local vector HitLocation, HitNormal, extent;
    local actor HitActor;

    extent = vect(20, 20, 20);

    //HitActor = Trace(HitLocation, HitNormal, end, start, true, extent);
    HitActor = Trace(HitLocation, HitNormal, end, start, true);

    if(HitActor != None && Pawn(HitActor) != None && Pawn(HitActor).Controller != None && SameTeamAs(Pawn(HitActor).Controller))
    {
        HitFriend = Pawn(HitActor);
        outHitLocation = HitLocation;
        return true;
    }

    return false;
}

function SendBulletMiss(Pawn Enemy, Vector offset)
{
    Enemy.NotifyBulletMiss(Enemy.Location + offset, 0);
}

function Rotator OldAim( Ammunition FiredAmmunition, vector projStart, int aimerror )
{
    local vector FireSpot, MissVector;
    local rotator ShootDir, result;
    local float targetDistance, projSpeed;

    local vector outHitLocation;
    local Pawn HitFriend;

    if ( target == None ) {
        DebugLog( "AimToMiss on invalid target", DEBUG_FIRING );
        return rotator( lastSeenPos - projStart );
    }
    if( Target == Enemy && !EnemyIsVisible() ) {
        result = rotator(LastSeenPos - projStart);
        DebugLog( "AimToMiss on enemy that isn't visible:" @ result,
                  DEBUG_FIRING );
        return result;
    }

    MissVector = vect(0,0,1) cross (Target.Location - Pawn.Location);
    MissVector.Z = 0;

    MissVectorScale = SweepScale();
    if(true)
    {
        MissVector = MissVectorScale * Normal(MissVector)
                * Target.CollisionRadius*2.0;
    }

    MissVector.Z = RandRange( -(Target.CollisionHeight/2),
                              2*Target.CollisionHeight );

    if( bPlayWizzSnd && abs(MissVectorScale) > 0.5)
    {
        SendBulletMiss(Enemy, MissVector);
    }

    FireSpot = GetTweakedFireSpot(Target);
    if(FiredAmmunition.bLeadTarget)
    {
        targetDistance = VSize(Target.Location - projStart);
        projSpeed = FiredAmmunition.ProjectileClass.default.speed;
        FireSpot += Target.Velocity * targetDistance / projSpeed;
    }

    ShootDir = rotator( (FireSpot + MissVector) - projStart );
    //@@@ Q: friendly fire, what to do?
    //    A: Rather have a really good shot than a really stupid one
    if( WillFriendlyFire( projStart, FireSpot+MissVector, HitFriend,
                          outHitLocation ) )
    {
        ShootDir = rotator( outHitLocation + vect(0,0,1.0)
                           * HitFriend.CollisionHeight - projStart);
    }

    return ShootDir;
}

function Rotator Aim( Ammunition FiredAmmunition, vector projStart, int aimerror )
{
    local vector FireSpot;
    local rotator ShootDir;
    local float targetDistance, projSpeed, FireDist;
	local float correctYaw;
    local float yawError;
	local vector MissVector;

    FireSpot = GetTweakedFireSpot(Target);
	targetDistance = VSize(Target.Location - projStart);
    if(FiredAmmunition.bLeadTarget)
    {
        projSpeed = FiredAmmunition.ProjectileClass.default.speed;
        FireSpot += Target.Velocity * targetDistance / projSpeed;
    }

    yawError = BaseAimYawError;
	//relative velocity
	yawError *= FMin(5,(12 - 11 *  
		(Normal(Target.Location - Pawn.Location) 
		  Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity))))); 
	//skill base
	yawError *= (3.3 - 0.44 * (FMin(skill,7) + 0.5 * FRand()));
	//enemy is still
	if ( Target.Velocity == vect(0,0,0) )
		yawError *= 0.6;
	//back is turned
	if ( Vector(Target.Rotation) dot Normal(Pawn.Location - Target.Location ) < 0)
		yawError *= 1.5;
	//just got hit
	if ( (skill < 6) && !TimeElapsed(LastHitTime, 0.2) )
		yawError *= 1.3;
	//recently Acquired
	if ( !TimeElapsed(AcquireTime, 0.5 + 0.6 * (7 - skill) ) )
	{
		yawError *= 1.5;
		if ( FiredAmmunition.bInstantHit )
			yawError *= 1.5;
	}
	//aim improves the longer in sight
	if( TimeElapsed(EnemyInSightTime, 5 + MaxSecondsOfLOS * (7 - skill)/7.0 ) )
	{
		yawError *= 0.6;
	}
	//less accurate if farther away
	yawError *= lerp(targetDistance / MaxAimRange, 0.75, 1.5);
	//GameDifficulty
	yawError *= GameDifficultyFactor;
	
    yawError = RandRange(-yawError, yawError);

	ShootDir = rotator( FireSpot - projStart );
	correctYaw = ShootDir.Yaw;
	ShootDir.Yaw = SetFireYaw(ShootDir.Yaw + yawError);

    FireDist = VSize(FireSpot - projStart);
    FireSpot = projStart + FireDist*Vector(ShootDir);
	MissVector = FireSpot - Target.Location;
	//if enemy is facing away, make sure misses go in front
	if ( Vector(Target.Rotation) dot Normal(Pawn.Location - Target.Location ) < 0.707)
	{
		if( Vector(Target.Rotation) dot MissVector < 0)
        {
            ShootDir.Yaw = SetFireYaw(correctYaw - yawError);
			FireSpot = projStart + FireDist*Vector(ShootDir);
			MissVector = FireSpot - Target.Location;
		}
    }

    if( bPlayWizzSnd 
        && VSize(MissVector) > Target.CollisionRadius
        && VSize(MissVector) < 2*Target.CollisionRadius)
    {
        SendBulletMiss(Enemy, MissVector);
    }

    return ShootDir;
}


/**
 * Subclasses may override if you don't like the conservative
 * shoot-for-the-middle approach.
 */
function vector GetTweakedFireSpot( Actor target ) {
    return target.Location;
}


/**
 * AdjustAim()
 * Returns a rotation which is the direction the bot should aim -
 * after introducing the appropriate aiming error
 **/
function rotator AdjustAim( Ammunition FiredAmmunition, vector projStart,
                            int aimerror )
{
    FiredAmmunition.WarnTarget(Target,Pawn,vect(1,0,0));
    return Aim(FiredAmmunition, projStart, aimerror);
}

/**
 * can we indefinitely hold/charge the weapon?
 **/
function bool isChargeWeapon()
{
    return false;
}


function Tick(float dT)
{
    Super.Tick(dT);
    if(bStopFireAnimation)
    {
        bStopFireAnimation = false;
        StopFiring();
    }

    if(bDebugLogging)
        debugTick(dT);
}

//===============
// Helper functions
//===============

function UnClaimPosition()
{
    if(claimedPosition != None)
    {
		currentStage.UnClaimPosition( self, claimedPosition );
        claimedPosition = None;
    }
}

function ClaimPosition( StagePosition position )
{
    if(position == None)
        return;
    if(claimedPosition != None && position != claimedPosition)
        UnClaimPosition();

    claimedPosition = position;
	currentStage.ClaimPosition( self, claimedPosition );
}

function SetRelaxed()
{
    Pawn.WalkingPct = 0.4;
    Pawn.WalkAnims[0] = 'Walk_Relaxed';
}

function SetAlert()
{
    Pawn.WalkingPct = Pawn.default.WalkingPct;
    Pawn.WalkAnims[0] = Pawn.default.WalkAnims[0];
}

function bool isHideSpotAvailable()
{
    local StagePosition pos;

    if(currentStage == None)
        return false;

    if( None != FindNearestHidePosition(currentStage.GetEnemyIndex(Enemy)) )
    {
        pos = StagePosition(RouteGoal);
    }
        
    if( pos == None || VSize(pos.Location - Pawn.Location) > 1200 )
    {
        return false;
    }

    return true;
}

function bool IsInValidCover()
{
    if(claimedPosition == None)
        return false;

    if( currentStage.PositionProvidesCoverFromEnemy(claimedPosition, Enemy) != 2 )
        return false;

    if( !Pawn.ReachedDestination(claimedPosition) )
        return false;
    return true;
}

function bool isProvidingCoverFire()
{
    if ( IsInState( 'Engaged_StandGround' ))
        return true;
    if ( IsInState( 'Engaged_StandGroundCrouched' ))
        return true;

    return false;
}

function bool someOneProvidesCover()
{
    local int i;
    local VGSPAIController buddy;

    if(currentStage == None || currentStage.StageAgents.Length <= 1)
        return false;

    for( i=0; i<currentStage.StageAgents.Length; i++)
    {
        buddy = currentStage.StageAgents[i].controller;
        if( self == buddy )
            continue;
        if( buddy.isProvidingCoverFire())
            return true;
    }

    return false;
}

function bool allOthersProvideCover()
{
    local int i;
    local VGSPAIController buddy;

    if(currentStage == None || currentStage.StageAgents.Length <= 1)
        return true;

    for( i=0; i<currentStage.StageAgents.Length; i++)
    {
        buddy = currentStage.StageAgents[i].controller;
        if( self == buddy )
            continue;
        if( !buddy.isProvidingCoverFire())
            return false;
    }

    return true;
}


/**
 * Sets a random direction to look at.
 **/
function SetRandomFocalPointLocation(float viewDist)
{
    local Rotator LookDir;

    if( !TimeElapsed(LastFocusChangeTime, RandFocusChangeDuration ) )
        return;
    MarkTime(LastFocusChangeTime);
    RandFocusChangeDuration = RandRange(1.0, 2.0);

    Focus = None;
    LookDir = Rotation;
    LookDir.Yaw = LookDir.Yaw + iRandRange(-32768, 32768);

    FocalPoint = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1) + vector(LookDir)*viewDist;
}

function SetFocalPointNearLocation(vector oldPoint)
{
    local vector oldDirVector;
    local rotator LookDir;

    if( !TimeElapsed(LastFocusChangeTime, RandFocusChangeDuration ) )
        return;
    MarkTime(LastFocusChangeTime);
    RandFocusChangeDuration = RandRange(1.0, 2.0);
    Focus = None;

    oldDirVector = oldPoint - (Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1) );
    LookDir = rotator(oldDirVector);
    LookDir.Yaw = LookDir.Yaw + iRandRange(-8192, 8192); //45deg

    FocalPoint = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1) + vector(LookDir)*VSize(oldDirVector);
}

/**
 * NearWall()
 * returns true if there is a nearby barrier at eyeheight, and
 * changes FocalPoint to a suggested place to look
 **/
function bool NearWall(float wallDist)
{
    local actor HitActor;
    local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

    LookDir = vector(Rotation);
    ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
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

    FocalPoint = Pawn.Location - LookDir * 300;
    return true;
}

/* FindBestPathToward()
Assumes the desired destination is not directly reachable.
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
    if ( !bCheckedReach && ActorReachable(A) )
        MoveTarget = A;
    else
    {
        MoveTarget = FindPathToward(A,(bAllowDetour && (NavigationPoint(A) != None)));
    }

    if ( MoveTarget != None )
        return true;
    else if ( bSoaking && (Physics != PHYS_Falling) )
        SoakStop("COULDN'T FIND BEST PATH TO "$A);
    else
        log("No Path from"@ Pawn.Anchor @ "(" $claimedPosition $ ")" @"to"@A);

    return false;
}

//=====================
// Decision heuristics
//=====================
//@@@ we should collect all of our shouldX()-style methods here...
/**
 * A heuristic for whether running or walking is appropriate in the
 * current situation.
 */
function bool shouldWalk() {
   return Enemy == None;
}

//==============
//  Actions and Action States
//==============

//==============
// NotEngaged_AtRest
//
// Just idling, waiting for something to happen.
//==============
function Perform_NotEngaged_AtRest(optional float restForTime)
{
    setCurAction("Rest");
    RestTime = restForTime;
    GotoState('NotEngaged_AtRest');
}

state NotEngaged_AtRest
{
    function BeginState()
    {
        Pawn.Acceleration = vect(0,0,0);
        Pawn.Velocity = vect(0,0,0);
        SetMultiTimer( REST_FOCUS_CHANGE, 1.0, false );
    }

    function EndState()
    {
        SetMultiTimer( REST_FOCUS_CHANGE, 0, false );
    }

    function MultiTimer( int timerID ) {
        switch( timerID )
        {
            case REST_FOCUS_CHANGE:
                setFocus();
                SetMultiTimer( REST_FOCUS_CHANGE, 1.0, false );
                if(Enemy != None)
                    myAIRole.NotEngagedAtRestSucceeded();
                break;
            default:
                global.MultiTimer(timerID);
                break;
        }
    }

    // Don't Shoot
    function Timer() {}

    event SeePlayer( Pawn Seen ) {
        Global.SeePlayer(Seen);
        Focus = None;
    }

    function setFocus()
    {
        if(claimedPosition != None)
        {    SetFocalPointNearLocation( Vector(claimedPosition.Rotation)*2000 + Pawn.Location );
        }
        else if( bEnemyInfoValid )
        {    SetFocalPointNearLocation( LastSeenPos );
        }
        else
        {    SetRandomFocalPointLocation(2000);
        }
        NearWall(1000);

    }

BEGIN:
    WaitForLanding();
    exclaimMgr.Exclaim(EET_Idle, 0, 0.25);
    FinishRotation();
    if(RestTime != 0)
        Sleep( RestTime );
    else
        Sleep( RandRange(2.0, 3.0) );
    myAIRole.NotEngagedAtRestSucceeded();
}
//===========================
// NotEngaged_Wander
//
// Pick a spot, and go to it.
//===========================
function Perform_NotEngaged_Wander()
{
    local int numAvail, i;
    local StagePosition position;

    if(currentStage == None) {
        setCurAction("NoStage");
        Perform_Error_Stop();
        return;
    }

    for(i=0; i< currentStage.StagePositions.Length; i++)
    {
        if( !currentStage.StagePositions[i].bIsClaimed )
        {
            numAvail++;
            if( FRand() < 1.0f/float(numAvail) ) //  odds are  1/1, 1/2, 1/3, 1/4 ...
            {
                position = currentStage.StagePositions[i];
            }
        }
    }
    UnClaimPosition();
    if(position == None) {
        setCurAction("NoWanderSpots");
        Perform_Error_Stop();
        return;
    }

    setCurAction("Wander");
    ClaimPosition(position);
    ContinueWander();

}

function ContinueWander()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        if( IsInState('NotEngaged_Wander') )
            GotoState('NotEngaged_Wander', 'MOVE');
        else
            GotoState('NotEngaged_Wander');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoWanderPath");
        Perform_Error_Stop();
    }
}


state NotEngaged_Wander
{
    function BeginState() {
        SetRelaxed();
    }

    function EndState() {
        SetAlert();
    }

    // Don't Shoot
    function Timer() {}

    function bool KeepGoing()
    {
        if( Enemy != None ) {
            UnClaimPosition();
            return false;
        }
        return !Pawn.ReachedDestination(claimedPosition);
    }

BEGIN:
    Focus = MoveTarget;
    Sleep(1.0);
    FinishRotation();
    sleep(RandRange(0.1, 0.5));
MOVE:
    Focus = MoveTarget;
    MoveToward( MoveTarget,,,,true );
    if( KeepGoing() )
    {
        ContinueWander();
    }
    MarkTime(LastWanderTime);
    //@@@ maybe too soon to return this?
    myAIRole.NotEngagedWanderSucceeded();
}
//==============
// NotEngaged_RunToward
//
// MoveToward an actor, not currently paying attention to an enemy
//==============
function Perform_RunToward( StagePosition goal)
{
    setCurAction("Running");
    ClaimPosition(goal);
    ContinueRunToward();
}

function bool HandleNoPath(string reason)
{
	return false;
}

function ContinueRunToward()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        GotoState('RunToward');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoRunPath");
        if(!HandleNoPath("NoRunPath"))
			Perform_Error_Stop();
    }
}

state RunToward
{
ignores EnemyNotVisible;

    function bool ShouldMelee(Pawn Seen)
    {
        return false;
    }

    function AcquireEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy)
    {
        Global.AcquireEnemy( potentialEnemy, bCanSeePotEnemy);
		if(!bDontFireWhileRunning)
		{
			SetTimer(0.1, false);
		}
    }

    function Actor Face()
    {
        if (ShouldFace())
            return Enemy;
        return MoveTarget;
    }

    function bool ShouldFace()
    {
		if ( Enemy == None || claimedPosition == None )
			return false;
        if(Normal(Enemy.Location - Pawn.Location) dot Normal(claimedPosition.Location - Pawn.Location) > 0.707)
            return true;
        return false;
    }

    function Timer()
    {
        if( Enemy == None)
        {
            SetTimer( 0 , false);
            return;
        }

        if( ShouldFace() )
        {
            Focus = Enemy;
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
        return !Pawn.ReachedDestination(claimedPosition);
    }


BEGIN:
    if(Enemy != None && !bDontFireWhileRunning)
        SetTimer(0.1, false);
    
    MoveToward( MoveTarget, Face() );
    if( KeepGoing() )
    {
        ContinueRunToward();
    }
    myAIRole.MoveToPositionSucceeded();
}

//==============
// NotEngaged_WalkToward
//
// MoveToward an actor, not currently paying attention to an enemy
//==============
function Perform_WalkToward( StagePosition goal)
{
    setCurAction("Walking");
    ClaimPosition(goal);
    ContinueWalkToward();
}

function ContinueWalkToward()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        GotoState('WalkToward');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoWalkPath");
        Perform_Error_Stop();
    }
}

state WalkToward
{
ignores EnemyNotVisible;

    function BeginState() {
        SetRelaxed();
    }

    function EndState() {
        SetAlert();
    }

    function bool KeepGoing()
    {
        return !Pawn.ReachedDestination(claimedPosition);
    }

BEGIN:
    MoveToward( MoveTarget,,,,true );
    if( KeepGoing() )
    {
        ContinueWalkToward();
    }
    myAIRole.MoveToPositionSucceeded();
}

//==============
// Engaged_StandGround
//
// We are engaged with an enemy, and are standing our ground (human turret)
//==============
function Perform_Engaged_StandGround( optional float standTime)
{
    if(standTime == 0)
        StandGroundTime = 0.5 + 0.5f * frand();
    else
        StandGroundTime = standTime;

    if(Focus != Enemy) //not visible
    {
        SetFocalPointNearLocation(LastSeenPos);
    }
    else
        Focus = Enemy;
    //Pawn.Velocity = vect(0,0,0);

    if( ShouldCrouch(Pawn.Location, Enemy.Location, 0.5f) )
    {
        setCurAction("StandGroundCrouch");
        Pawn.bWantsToCrouch = true;
        //GotoState('Engaged_StandGroundCrouched');
    }
    else
    {
        Pawn.bWantsToCrouch = false;
        setCurAction("StandGround");
        //GotoState('Engaged_StandGround');
    }

    GotoState('Engaged_StandGround');
    return;
}

state Engaged_StandGround
{
    function BeginState()
    {
        bFireAtLastLocation = true;
    }

    function EndState()
    {
        if(Pawn != None)
        {
            Pawn.bWantsToCrouch = false;
        }
        
        MonitoredPawn = None;
        bFireAtLastLocation = false;
    }

    event SeePlayer( Pawn Seen )
    {
        Global.SeePlayer( Seen );
        if(Enemy == Seen)
        {
            Focus = Enemy;
        }
    }

    function DamageAttitudeTo(Pawn Other, float Damage)
    {
        if( MayStrafe() ) {
            Perform_Engaged_StrafeMove();
        }
        Global.DamageAttitudeTo( Other, Damage);
    }


BEGIN:
    if( Pawn.Acceleration != vect(0,0,0) ) {
        MoveTo(Pawn.Location);
    }
    FinishRotation();
	StartFireWeapon();
    Sleep( StandGroundTime );
    StopFireWeapon();
    myAIRole.StandGroundSucceeded();
}


function Perform_AttackFromCover(optional float duration)
{
    setCurAction("AttackFromCover");

    if(duration == 0.0)
        StandGroundTime = 0.5 + 0.5f * frand();
    else
        StandGroundTime = duration;

    if( EnemyIsVisible() && claimedPosition.CoverType != CA_Standing)
    {
        GotoState('Engaged_AttackFromCover', 'ATTACKABLE');
        return;
    }

    GotoState('Engaged_AttackFromCover', 'PREPARETOATTACK');

}

state Engaged_AttackFromCover
{
    function debugTick(float dt)
    {
        Global.debugTick( dt);
        drawdebugline(Pawn.location, strafeTarget, 255,0,0);
    }

    function BeginState()
    {
        bTakingCover = false;
        SetMultiTimer( COVER_CHECK, 0.1, true );
        Pawn.StopMoving();
    }

    function EndState()
    {
        SetMultiTimer( COVER_CHECK, 0.0, false );

        if(Pawn == none)
            return;
        //in case we short-circuit out of the state
        Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
        Pawn.SetPhysics(PHYS_Walking);
        Pawn.StopMoving();
    }

    function MultiTimer( int timerID ) {
        if( timerID != COVER_CHECK )
        {
            global.MultiTimer(timerID);
            return;
        }

        if(!IsInValidCover() )
        {
            myAIRole.OnCoverNotValid();
            
        }
    }

    function bool IsInValidCover()
    {
        if(claimedPosition == None)
        {
            return false;
        }

        if( currentStage.PositionProvidesCoverFromEnemy(claimedPosition, Enemy) != 2 )
        {
            return false;
        }
        return true;
    }


    function AnimEnd(int Channel)
    {
        if ( Channel == LEAN_CHANNEL )
        {
            Notify();
        }
        else
        {
            Global.AnimEnd(Channel);
        }
    }

    function Timer()
    {
        Notify();
    }

    //intercept, and call again manually if we want
    function EndOfBurst()
    {
        if("AttackFromCover:Attackable" == curAction)
        {
            Global.EndOfBurst();
            return;
        }
        StopFiring();
        Notify();
    }

    function EnemyNowVisible()
    {
        if(bWaitForLOS)
            GotoState('Engaged_AttackFromCover', 'STARTFIRE');
    }

    function TurnOnRM()
    {
        Pawn.SetPhysics(PHYS_RootMotionWithPhysics );
    }
    function TurnOffRM()
    {
        Pawn.SetPhysics(PHYS_Walking );
    }

    function bool EnemyIsAimingAtMe()
    {
        local vector MissVector;
        local float dotPAbs, dotPCur;

        MissVector = (vect(0,0,1) cross (pawn.Location - Enemy.Location) );
        MissVector = Pawn.Location + Normal(MissVector) * Pawn.CollisionRadius*2 ;
        
        dotPAbs = Normal(MissVector - Enemy.location )dot Normal(pawn.location - Enemy.location);
        dotPCur = vector(Enemy.Rotation) dot Normal(pawn.location - Enemy.location);

        if( (dotPCur >= dotPAbs) )
        {
            return true;
        }
        return false;
    }
    
    function DamageAttitudeTo(Pawn Other, float Damage)
    {
        Global.DamageAttitudeTo( Other, Damage);
        if( !bTakingCover )
            GotoState('Engaged_AttackFromCover', 'TAKECOVER');
    }

BEGIN:

ATTACKABLE:
    bTakingCover = true;
    setCurAction("AttackFromCover:Attackable");
    Focus=Enemy;
	StartFireWeapon();
    sleep(StandGroundTime);
    StopFireWeapon();
    goto('Done');
    
PREPARETOATTACK:
    setCurAction("AttackFromCover:PrepareToAttack");
    Focus = Enemy;
    FinishRotation();
    switch(claimedPosition.CoverType)
    {
    case CA_Standing:
        setCurAction(curAction @ "CA_Standing");
        Pawn.bWantsToCrouch = false;
        sleep(0.3);

        break;
    case CA_Crouching:
        setCurAction(curAction @ "CA_Crouching");
        Pawn.bWantsToCrouch = true;
        sleep(0.3);
        break;
    //case CA_LeanLeft:
    //    setCurAction(curAction @ "CA_LeanLeft");
    //    
    //    Pawn.bAccurateMoveTo=true;
    //    strafeTarget = Normal(Vector(claimedPosition.Rotation) cross vect(0,0,1));
    //    strafeTarget *= 2 * Pawn.CollisionRadius;
    //    strafeTarget += Pawn.Location;
    //    MoveTo( strafeTarget, Enemy, true );
    //    Pawn.StopMoving();
    //    Pawn.bAccurateMoveTo=false;
    //    
    //    TurnOnRM();
    //    Pawn.AnimBlendParams(LEAN_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    //    Pawn.PlayAnim('LeanL_Out_Bulldog', , ,LEAN_CHANNEL);
    //    if( Pawn.HasAnim('LeanL_Out_Bulldog') )
    //        WaitForNotification();
    //    //TurnOffRM();
    //    Pawn.PlayAnim('LeanL_Fire_Bulldog', , ,LEAN_CHANNEL);
    //    WaitForNotification();
    //    //Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    //    //TurnOffRM();
    //    break;
    //case CA_LeanRight:
    //    setCurAction(curAction @ "CA_LeanRight");
    //    
    //    Pawn.bAccurateMoveTo=true;
    //    strafeTarget = Normal(Vector(claimedPosition.Rotation) cross vect(0,0,-1));
    //    strafeTarget *= 2 * Pawn.CollisionRadius;
    //    strafeTarget += Pawn.Location;
    //    MoveTo( strafeTarget, Enemy, true );
    //    Pawn.StopMoving();
    //    Pawn.bAccurateMoveTo=false;
    //    
    //    TurnOnRM();
    //    Pawn.AnimBlendParams(LEAN_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    //    Pawn.PlayAnim('LeanR_Out_Bulldog', , ,LEAN_CHANNEL);
    //    if( Pawn.HasAnim('LeanR_Out_Bulldog') )
    //        WaitForNotification();
    //    //TurnOffRM();
    //    Pawn.PlayAnim('LeanR_Fire_Bulldog', , ,LEAN_CHANNEL);
    //    WaitForNotification();
    //    //Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    //    //TurnOffRM();
    //    break;
    default:
        setCurAction(curAction @ "default");
        break;
    }

FIREATENEMY:
    bWaitForLOS = false;
    if( !EnemyIsVisible() ) //Don't immediately give up
    {
        setCurAction("AttackFromCover/WaitForLOS");
        bWaitForLOS = true;
        Sleep(3.0);
        Goto('TAKECOVER');
    }    
STARTFIRE:
    if(bWaitForLOS) //A reaction delay
    {
        bWaitForLOS = false;
        Sleep(0.5);
    }
    Focus=Enemy;
    StartFireWeapon();
KEEPFIRING:
    //make sure the backup notify-timer fires after we have a chance to burst again
    SetTimer( FMax(2*NumShotsToGo * getWeaponFireRate(Pawn.Weapon), MaxShotPeriod+0.1), false);
    WaitForNotification();
    if( !ShouldReload() )
    {
        if( EnemyIsAimingAtMe() )
        {
            if( Frand() < 0.5 )
            {
                StartNewBurst();
                Goto('KEEPFIRING');
            }
        }
        else //Not being aimed at.
        {
            if( Frand() < 0.75 )
            {
                StartNewBurst();
                Goto('KEEPFIRING');
            }
        }
    }
    StopFireWeapon();
    Sleep( Frand()* 0.5);

TAKECOVER:
    bTakingCover = true;
    setCurAction("AttackFromCover/TakeCover");

    switch(claimedPosition.CoverType)
    {
    case CA_Standing:
        Pawn.bWantsToCrouch = true;
        sleep(0.3);
        setCurAction(curAction @ "CA_Standing");
        break;
    case CA_Crouching:
        Pawn.bWantsToCrouch = true;
        sleep(0.3);
        setCurAction(curAction @ "CA_Crouching");
        break;
    //case CA_LeanLeft:
    //    TurnOnRM();
    //    Pawn.PlayAnim('LeanL_In_Bulldog', , ,LEAN_CHANNEL);
    //    if( Pawn.HasAnim('LeanL_In_Bulldog') )
    //        WaitForNotification();
    //    Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    //    TurnOffRM();
    //    
    //    Pawn.bAccurateMoveTo=true;
    //    MoveToward( claimedPosition, Enemy,,, true );
    //    Pawn.bAccurateMoveTo=false;
    //    
    //    break;
    //case CA_LeanRight:
    //    TurnOnRM();
    //    Pawn.PlayAnim('LeanR_In_Bulldog', , ,LEAN_CHANNEL);
    //    if( Pawn.HasAnim('LeanR_In_Bulldog') )
    //        WaitForNotification();
    //    Pawn.AnimBlendToAlpha(LEAN_CHANNEL, 0, 0.4);
    //    TurnOffRM();
    //    
    //    
    //    Pawn.bAccurateMoveTo=true;
    //    MoveToward( claimedPosition, Enemy,,, true );
    //    Pawn.bAccurateMoveTo=false;
    //    setCurAction(curAction @ "CA_LeanRight");
    //    
    //    break;
    default:
        setCurAction(curAction @ "default");
        break;
    }
DONE:

    //switch(claimedPosition.CoverType)
    //{
    //    case CA_LeanLeft:
    //    case CA_LeanRight:
    //        // jim: root motion hack
    //        StandGroundTime = 0.1;
    //        Pawn.bWantsToCrouch = false;
    //        setCurAction("StandGround");
    //        GotoState('Engaged_StandGround');
    //        break;
    //}

    if(bWaitForLOS)
    {
        bWaitForLOS = false;
        myAIRole.AttackFromCoverFailed();
    }
    else
    {
        if( !EnemyIsVisible() )
            Sleep(2.0);
        myAIRole.AttackFromCoverSucceeded();
    }
}

//==============
// Flank
//
//==============

function Perform_Engaged_FlankTo(Actor flankTo)
{
    setCurAction("flank");
    bFlank = true;
    flankTarget = flankTo;
    FlankStartLoc = Pawn.Location;
    Continue_Engaged_FlankTo();
}

function Continue_Engaged_FlankTo()
{
    MoveTarget = FindFlankPathToward(flankTarget, false);
    
    if ( MoveTarget != None )
    {
        GotoState('Engaged_Flank');
    }
    else
    {
        GotoState('Engaged_Flank', 'Done');
    }
}

state Engaged_Flank
{
    function bool KeepGoing()
    {
        return (Enemy!=None);
    }
BEGIN:
    MoveToward(MoveTarget, Enemy);
    if( KeepGoing() )
        Continue_Engaged_FlankTo();
DONE:
    bFlank = false;
    myAIRole.TakeCoverSucceeded();
}

//==============
// FireAtTarget
//
// Firing on the ShootActor, and ignoring the enemy.
//==============
function Perform_NotEngaged_FireAtTarget()
{
   DebugLog( "Perform_NotEngaged_FireAtTarget" );
   setCurAction("FireAtTarget");
   Focus = ShootTarget;
   GotoState( 'NotEngaged_FireAtTarget' );
}

/**
 * May need to be overridden for particular games...
 */
function bool isTargetDestroyed();
/*
{
   local Pawn p;
   // consider invalid targets destroyed
   if ( ShootTarget == None ) return true;
   // check for pawn-health
   p =  Pawn( ShootTarget );
   if ( p != None ) return p.Health <= 0;
   // for all other actors, it's only considered destroyed if it's
   // being deleted...
   return !ShootTarget.bDeleteMe;
}
*/

state NotEngaged_FireAtTarget
{
   //@@@
   event SeePlayer( Pawn Seen ) {
      Global.SeePlayer(Seen);
      Focus = ShootTarget;
   }

BEGIN:
   DebugLog( "NotEngaged_FireAtTarget" );
   FinishRotation();
   //@@@ ShootTarget?
   Target = ShootTarget;
   StartFireWeapon();
   Sleep( RandRange(0.5,2.0) );
   StopFireWeapon();
   if ( isTargetDestroyed() ) {
      tmpTarget = ShootTarget;
      if ( currentStage != None ) {
         currentStage.Report_TargetDestroyed( self, ShootTarget );
      }
      if ( tmpTarget == ShootTarget ) ShootTarget = None;
   }
   myAIRole.FireAtTargetSucceeded();
}


//==============
// Engaged_RecoverEnemy
//
// Enemy was recently seen, and went out of sight,
// try to find him by going to the last position we saw him
// under the assumption that he's probably near by.
//==============

function Perform_Engaged_RecoverEnemy()
{
    setCurAction("RecoverEnemy");
    
    Continue_Engaged_RecoverEnemy();
}

function Continue_Engaged_RecoverEnemy()
{
    if( Enemy == None || !bEnemyInfoValid || EnemyIsVisible() ) {
        GotoState('Engaged_RecoverEnemy', 'DONE');
        return;
    }

    if(PointReachable( LastSeenPos ) )
    {
        GotoState('Engaged_RecoverEnemy', 'POINT');
    }

    MoveTarget = FindPathTo(LastSeenPos);
    if(MoveTarget == None)
    {
        setCurAction("NoRecoverPosPath");
        myAIRole.RecoverEnemyFailed();
        return;
    }

    UnClaimPosition();
    GotoState('Engaged_RecoverEnemy', 'PATH');
}

state Engaged_RecoverEnemy
{
ignores EnemyNotVisible;

    function EnemyNowVisible()
    {
        Pawn.Acceleration=vect(0,0,0); 
        myAIRole.RecoverEnemySucceeded();
    }
    
    function bool KeepGoing()
    {
        return (Enemy!=None) && !EnemyIsVisible();
    }

    event SeePlayer( Pawn Seen )
    {
        Global.SeePlayer(Seen);
        if(Enemy == Seen )
            Focus = Enemy;
    }

BEGIN:
    FinishRotation();
PATH:
    Focus = None;
    FocalPoint = LastSeenPos;
    MoveTo(MoveTarget.Location);
    if( KeepGoing() )
        Continue_Engaged_RecoverEnemy();
POINT:
    MoveTo(LastSeenPos);
DONE:
    myAIRole.RecoverEnemySucceeded();
}


//==============
// Engaged_GetLOS
//
// Cheat and get LOS to Enemy
//==============

/**
 */
function Perform_Engaged_GetLOS()
{
    local StagePosition oldPos;

    setCurAction("GetLOS");
    oldPos    = claimedPosition;
    UnClaimPosition();
    if ( currentStage != None ) {
        ClaimPosition( currentStage.Request_ShootingPosition(self) );
    }

    if(claimedPosition == None)
    {
        ClaimPosition( oldPos );
        if( EnemyIsVisible() )
        {
            setCurAction("NoLOSSpotA");
            Perform_Error_Stop();
        }
        else
        {
            setCurAction("NoLOSSpotB");
            Perform_Error_Stop();
        }
        //@@@GotoState( 'GetLOSFailed' );
        return;
    }

    Continue_Engaged_GetLOS();
}

/**
 */
function Continue_Engaged_GetLOS()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        if( IsInState('Engaged_GetLOS') ) {
            GotoState('Engaged_GetLOS', 'GETLOS');
        }
        else {
            GotoState('Engaged_GetLOS');
        }
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoGetLOSPath");
        Perform_Error_Stop();
    }
}

state GetLOSFailed {
BEGIN:
    Sleep(0.1);
    myAIRole.GetLOSFailed();
}

state Engaged_GetLOS
{
    //ignores EnemyNotVisible;

    function bool KeepGoing()
    {
        //log("Reached"@claimedPosition@Pawn.ReachedDestination(claimedPosition) );
        return (Enemy!=None) && !Pawn.ReachedDestination(claimedPosition);
    }

BEGIN:
    FinishRotation();
GETLOS:
    //if(EnemyIsVisible())
    MoveToward(MoveTarget, Enemy);
    //else
    //  MoveToward(MoveTarget);
    if( KeepGoing() ) {
        Continue_Engaged_GetLOS();
    }
    myAIRole.GetLOSSucceeded();
}


//==============
// Engaged_HideFromEnemy
//
// try to get to a spot where the enemy can't shoot us
//==============

function Perform_Engaged_HideFromEnemy()
{
    local StagePosition newPos;
    setCurAction("Hide");

    if( claimedPosition != None && currentStage.PositionProvidesHidingFromEnemy(claimedPosition, Enemy))
    {
        if(Pawn.ReachedDestination(claimedPosition) )
        {
            GotoState('Engaged_HideFromEnemy', 'HIDDEN');
            return;
        }
        else
        {
            Continue_Engaged_HideFromEnemy();
            return;
        }
    }

    //need a new spot
    if ( currentStage != None )
    {
        if( None != FindNearestHidePosition(currentStage.GetEnemyIndex(Enemy)) )
        {
            newPos = StagePosition(RouteGoal);
        }

        if(newPos == None)
        {
            setCurAction("NoHideSpot");
            myAIRole.HideFromEnemyFailed();
            Perform_Error_Stop();
            return;
        }
        else if( RouteDist >= 2040 )
        {
            myAIRole.HideFromEnemyFailed();
            Perform_Error_Stop();
            return;
        }
        setCurAction( "Hide"@RouteDist );
        ClaimPosition(newPos);

    }
    Continue_Engaged_HideFromEnemy();

}

/**
 * Move towards cover...
 */
function Continue_Engaged_HideFromEnemy()
{
   if( FindBestPathToward(claimedPosition, false, true) ) {
        if(IsInState('Engaged_HideFromEnemy') )
            GotoState('Engaged_HideFromEnemy', 'HIDE');
        else {
            exclaimMgr.Exclaim(EET_Fear, 0);
            GotoState('Engaged_HideFromEnemy');
        }
    }
    else {
        UnClaimPosition();
        setCurAction("NoHidePath");
        Perform_Error_Stop();
    }
}

state Engaged_HideFromEnemy
{
//ignores EnemyNotVisible;

    function bool KeepGoing()
    {
        //return  ( (Enemy!=None) && !Pawn.ReachedDestination(claimedPosition) ) || EnemyIsVisible();
        return ( (Enemy!=None) && !Pawn.ReachedDestination(claimedPosition) );
    }

    function BeginState() {
        if(currentStage != None)
            currentStage.Report_Unsighted(self, Enemy);
    }

    function EndState() {
        if(currentStage != None && EnemyIsVisible() )
        {
            currentStage.Report_Eyesighted(self, Enemy);
        }
        Pawn.bWantsToCrouch = false;
    }

BEGIN:
//  FinishRotation();
HIDE:
    MoveToward(MoveTarget);
    if( KeepGoing() )
    {
        //  Perform_Engaged_HideFromEnemy();
        Continue_Engaged_HideFromEnemy();
    }
   MarkTime(LastHideTime);
HIDDEN:
    Focus = None;
    FocalPoint = LastSeeingPos;
    Sleep(1.0);
    myAIRole.HideFromEnemySucceeded();
}

//=================
// Engage_TakeCover
// hide as best as possible, as fast as possible...
//=================

function GetCoverPositions(){}

function bool FindCoverSpot()
{
    UnClaimPosition();
    if ( currentStage != None ) {
        ClaimPosition( currentStage.Request_CoverPosition(self) );
    }
    return (claimedPosition != None);
}

/**
 * Crouch, or move to somewhere nearby for cover.
 */
function Perform_Engaged_TakeCover(optional float duration)
{
    if(duration == 0.0)
        StandGroundTime = 0.5 + 0.5f * frand();
    else
        StandGroundTime = duration;

    setCurAction("TakeCover");
    Focus = Enemy;

    if( isInValidCover() )
    {
        if(Pawn.ReachedDestination(claimedPosition) )
        {
            GotoState('Engaged_TakeCover', 'COVERED');
            return;
        }
        else
        {
            Continue_Engaged_TakeCover();
            return;
        }
    }

    //need a new spot
    if( FindCoverSpot() ) {
        Continue_Engaged_TakeCover();
    }
    else {
        setCurAction("NoCoverSpot");
        GotoState('TakeCoverFailed');
        return;
    }
}

/**
 * Move towards cover...
 */
function Continue_Engaged_TakeCover()
{

    if( FindBestPathToward(claimedPosition, false, true) )
    {
        GotoState('Engaged_TakeCover', 'RUN');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoCoverPath");
        GotoState('TakeCoverFailed');
    }
}

state TakeCoverFailed {
BEGIN:
    Sleep(0.1);
    myAIRole.TakeCoverFailed();
    Perform_Error_Stop();
}

state Engaged_TakeCover
{
    function bool KeepGoing() {
        return  (Enemy!=None) && !Pawn.ReachedDestination(claimedPosition);
    }

    function EndState() {
        if ( pawn != None ) pawn.bWantsToCrouch = false;
    }

    function EnemyNotVisible() {
        Global.EnemyNotVisible();
    }
    

BEGIN:

RUN:
    StartFireWeapon();
    Pawn.bAccurateMoveTo = (MoveTarget==claimedPosition);
    MoveToward( MoveTarget, Enemy );
    if ( KeepGoing() ) {
        Continue_Engaged_TakeCover();
    }
COVERED:
    Sleep(StandGroundTime);
DONE:
    MarkTime(LastTakeCoverTime);
    Pawn.bAccurateMoveTo = false;
    myAIRole.TakeCoverSucceeded();
}

//=======================
// Engage_SuppressionFire
// The enemy isn't visible, but lay down fire at the last seen position to keep him hidden
//=======================

function Perform_Engaged_SupressionFire()
{
    setCurAction("SupressionFire");
    FocalPoint = LastSeenPos;
    GotoState('Engaged_SupressionFire');
}

state Engaged_SupressionFire
{

    function BeginState()
    {
        bFireAtLastLocation = true;
    }

    function EndState()
    {
        bFireAtLastLocation = false;
    }

    event SeePlayer( Pawn Seen )
    {
        Global.SeePlayer( Seen );
        if(Enemy == Seen)
        {
            Focus = Enemy;
        }
    }

    event EnemyNotVisible()
    {
        Global.EnemyNotVisible();
        Focus = None;
        FocalPoint = LastSeenPos;
    }

BEGIN:
    StopFiring();
    FinishRotation();
    Sleep(0.1);

	StartFireWeapon();
    NumShotsToGo = NumShotsUntilReload;
    Sleep( (NumShotsUntilReload - NumShotsSinceReload) * getWeaponFireRate(Pawn.Weapon) );
    StopFireWeapon();
    myAIRole.supressionFireSucceeded();
}


//==============
//Engage_Approach
// Run at player to intimidate, but not to within melee range
// Doesn't use any cover.. is basically a quick charge/rush
//==============

function Perform_Engaged_AssaultApproach()
{
    setCurAction("AssaultApproach");
    
    Continue_Engaged_AssaultApproach();
}

function Continue_Engaged_AssaultApproach()
{
    if( VSize(Enemy.Location - Pawn.Location) < 500 )
    {
        GotoState('Engaged_AssaultApproach', 'DONE');
    }

    if( !FindBestPathToward(Enemy, false,true) )
    {
        myAIRole.AssaultApproachFailed();
        return;
    }

    if(MoveTarget == Enemy 
        || (VSize(MoveTarget.Location - Pawn.Location) + VSize(MoveTarget.Location - Enemy.Location)) < 1200) {
        
		GotoState('Engaged_AssaultApproach', 'DONE');
        return;
    }

    GotoState('Engaged_AssaultApproach', 'GO');
    
}

state Engaged_AssaultApproach
{
BEGIN:
    StartFireWeapon();
GO:
    MoveToward(MoveTarget, Enemy);
    Continue_Engaged_AssaultApproach();
    
DONE:
    StopFireWeapon();myAIRole.AssaultApproachSucceeded();
        
}



//==============
//Engage_StrafeMove
// do a little strafe to keep from looking like we're stuck in one spot.
//==============

function bool MayStrafe()
{
    if(Frand() < fOddsOfStrafeMove && TimeElapsed(LastStrafeMoveTime, MinTimeBetweenStrafeMove))
        return true;
    return false;
}

function Perform_Engaged_StrafeMove()
{
    PickStrafeDir();
    setCurAction("Strafe B"@VSize(strafeTarget - Pawn.Location));
    GotoState('Engaged_StrafeMove', 'Strafe');
}

function bool TestDirection(vector dir, float minDist, out vector pick)
{
    local vector HitLocation, HitNormal, dist;
    local actor HitActor;

    pick = dir * RandRange(minDist, 2 * minDist);

    HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
    if (HitActor != None)
    {
        pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
        if ( !FastTrace(pick, Pawn.Location) )
            return false;
    }
    else
        pick = Pawn.Location + pick;

    //log("PICK X:" @ VSize(pick - Pawn.Location) );
    //log("PICK Y:" @ VSize(claimedPosition.Location - Pawn.Location) );

    if( claimedPosition != None && VSize(pick - claimedPosition.Location) > 500 )
    {
        //log("PICK A:" @ VSize(pick - claimedPosition.Location) );
        pick = pick + Normal(claimedPosition.Location - pick) * ( VSize(claimedPosition.Location - pick) - 500 ) ;
        //log("PICK B:" @ VSize(pick - claimedPosition.Location) );
        //log("PICK C:" @ VSize(pick - Pawn.Location) );
    }

    dist = pick - Pawn.Location;
    if (Pawn.Physics == PHYS_Walking)
        dist.Z = 0;

    if(bDebugLogging)
        setCurAction(curAction @ VSize(dist) / Pawn.CollisionRadius);
    //log("TESTDIRDIST:"@VSize(dist));
    return (VSize(dist) > minDist);
}

function PickStrafeDir()
{
    local Vector strafeDir;

    strafeDir = Normal(Vector(Rotation) cross vect(0,0,1));
    bStrafeDir = !bStrafeDir;
    if(bStrafeDir)
        strafeDir = -1 * strafeDir;

    if(!TestDirection(strafeDir, Pawn.CollisionRadius * RandRange(5.0, 10.0), strafeTarget) )
    {
        setCurAction("NoStrafeDir");
        Perform_Error_Stop();
    }
}

state Engaged_StrafeMove
{
    //function Timer() { SetCombatTimer();}  //Dont' Shoot

    //Avoid falling off ledges while strafing
    function BeginState()
    {
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        Pawn.bCanJump = false;
        bAdjustFromWalls = false;
        Pawn.bCanWalkOffLedges=false;
    }

    function EndState()
    {
        bAdjustFromWalls = true;
        if ( Pawn == None )
            return;
        Pawn.bAvoidLedges = false;
        Pawn.bStopAtLedges = false;
        MinHitWall -= 0.15;
        if (Pawn.JumpZ > 0)
            Pawn.bCanJump = Pawn.default.bCanJump;
        Pawn.bCanWalkOffLedges = Pawn.default.bCanWalkOffLedges;
    }

    function bool KeepGoing()
    {
        return !Pawn.ReachedDestination(claimedPosition);
    }

BEGIN:

Strafe:
    MoveTo( strafeTarget, Enemy /*,bShouldWalk*/ );
    //If it was *our* move that hid the enemy, we ought to recover it.
    if ( (Enemy == None) || EnemyIsVisible() || !FastTrace(Enemy.Location, LastSeeingPos) )
        Goto('FinishedStrafe');

RecoverEnemy:
    setCurAction("StrafeRecover");
    StopFiring();
    Sleep(0.5 + 0.2 * FRand());
    Destination = LastSeeingPos + 4 * Pawn.CollisionRadius * Normal(LastSeeingPos - Pawn.Location);
    MoveTo(Destination, Enemy);

FinishedStrafe:
    MarkTime(LastStrafeMoveTime);
    myAIRole.strafeMoveSucceeded();

}


//==============
// Engaged_HuntEnemy
// Hopefully this doesn't happen to often, but basically, chase the player since we can't rely on the
// stage for LOS (or he's just too far)
// @@@ Rather than pathfind right to the enemy, we could try AI Game Wisdon 2 article 2.6.
//==============

function Perform_Engaged_HuntEnemy()
{
    setCurAction("Hunting");

    UnClaimPosition();
    Continue_Engaged_HuntEnemy();
}

function Continue_Engaged_HuntEnemy()
{
    if( FindBestPathToward(Enemy, false, true) )
    {
        if( IsInState('Engaged_HuntEnemy') )
            GotoState('Engaged_HuntEnemy', 'MOVE');
        else
            GotoState('Engaged_HuntEnemy');
    }
    else
    {
        setCurAction("NoHuntPath");
        myAIRole.HuntFailed();
    }
}

state Engaged_HuntEnemy
{
    function bool KeepGoing()
    {
        return (Enemy!=None) && !EnemyIsVisible();
    }

    function EnemyNowVisible()
    {
        SetTimer(1.5, false);
    }

    function Timer()
    {
        Pawn.Acceleration = vect(0,0,0);
        myAIRole.HuntSucceeded();
    } 

BEGIN:
    FinishRotation();
MOVE:
    MoveToward(MoveTarget);
    if(KeepGoing())
        Continue_Engaged_HuntEnemy();
    myAIRole.HuntSucceeded();
}

//==============
// Engaged_Panic
// This can be our basic "Panic" state.. we will just try to run away from the enemy.
// if we gain enough distance, lose sight, or do it long enough, we can finish panicking
// stage for LOS (or he's just too far)
//==============

function bool KeepPanicking()
{
    if(Enemy == None)
        return false;

    if( VSize(Pawn.Location - Enemy.Location) < PanicRange )
        return true;

    if( !TimeElapsed(LastSeenTime, 2.0) )
        return true;

    if( !TimeElapsed(PanicStartTime, 3.0) )
        return true;

    return false;
}
function Perform_Engaged_Panic()
{
    setCurAction("Panic");
    Focus = None;
    bHavePanicked = true;
    MarkTime(PanicStartTime);
    UnClaimPosition();
    exclaimMgr.Exclaim(EET_Panic, 0.1);
    GotoState('Engaged_Panic');
}

state Engaged_Panic
{
//ignores EnemyNotVisible;

    event SeePlayer( Pawn Seen )
    {
        Global.SeePlayer(Seen);
        Focus = MoveTarget;
    }

    /**
     * from our current anchor, pick a pathposition that goes away from enemy.
     * search locally since we're not really "thinking coherently", plus
     * getting cornered might look cool for a panic retreat.
     **/
    function PickDestination()
    {
        local NavigationPoint bestPosition, position;
        local ReachSpec spec;
        local float dp, bestDP;
        local int i, numPaths;
        local vector enemyDir;
        local NavigationPoint fromSpot;


        fromSpot = Pawn.Anchor;
        if(fromSpot == None)
            fromSpot = Pawn.LastAnchor;

        numPaths = 0;
        enemyDir = (Pawn.Location - enemy.Location);

        for(i = 0; i < fromSpot.PathList.length; i++ )
        {
            spec = fromSpot.PathList[i];
            position = spec.End;
            dp = (spec.End.Location - spec.Start.Location) dot enemyDir;

            if( dp > 0.0 )
            {
                numPaths++;
                //don't always pick the "most away" position, since then any bots in the area might go the same way.
                if( FRand() < 1.0f/float(numPaths) )        //  odds are  1/1, 1/2, 1/3, 1/4 ...
                {
                    bestDP = dp;
                    bestPosition = position;
                }
            }
        }

        if( bestPosition != None )
        {
            MoveTarget = bestPosition;
        }
        else
        {
            //@@@ This should do something more interesting like cower, beg for mercy etc...
            setCurAction("NoPanicDir");
            //Perform_Engaged_Stop();
            Perform_Engaged_StandGround();
        }
    }

    function BeginState()
    {
        if(currentStage != None)
            currentStage.Report_Unsighted(self, Enemy);
    }
    function EndState()
    {
        if(currentStage != None && EnemyIsVisible() )
        {
            currentStage.Report_Eyesighted(self, Enemy);
        }
    }

BEGIN:
    PickDestination();
//  FinishRotation();
FLEE:
    MoveToward(MoveTarget);
    PickDestination();
    if( KeepPanicking() )
        Goto('FLEE');
DONE:
        myAIRole.PanicSucceeded();
}

//========================
// Engaged_FindNewCover
// Find a new position to engage our enemy from
//========================
function Perform_Engaged_FindNewCover()
{
    local StagePosition newPos;

    setCurAction("FindNewCover");
    
    if ( currentStage != None ) {
        newPos = currentStage.Request_ShootingPosition(self);
    }

    if(newPos != None)
    {       
        ClaimPosition(newPos);
        Continue_Engaged_FindNewCover();
    }
    else
    {
        GotoState('Engaged_FindNewCover', 'WAIT');
    }
}

function Continue_Engaged_FindNewCover()
{
    if( FindBestPathToward(claimedPosition, false, true) )
    {
        if( IsInState('Engaged_FindNewCover') )
            GotoState('Engaged_FindNewCover', 'MOVE');
        else
            GotoState('Engaged_FindNewCover');
    }
    else
    {
        UnClaimPosition();
        setCurAction("NoFindNewCoverPath");
        Perform_Error_Stop();
    }
}

state Engaged_FindNewCover
{
ignores EnemyNotVisible;

    function EndState() {
        bAdvanceWait = false;
    }

    function bool KeepGoing() {
        return (Enemy!=None) && !Pawn.ReachedDestination(claimedPosition);
    }

    function Timer() {
        if(Frand() < 0.5)
		{
			StartFireWeapon();
		}
        else
            SetTimer( VSize(MoveTarget.Location - Pawn.Location)/(Pawn.GroundSpeed*2), false);
    }

    function EndOfBurst() {
        StopFiring();
        if(FRand()<0.5)
            StartNewBurst();
        else
            SetTimer( VSize(MoveTarget.Location - Pawn.Location)/(Pawn.GroundSpeed*2), false);
    }

BEGIN:
    FinishRotation();
MOVE:
    SetTimer( VSize(MoveTarget.Location - Pawn.Location)/(Pawn.GroundSpeed*2), false);
    MoveToward( MoveTarget, ActorToFace(),,,
        ActorToFace()==Enemy &&
        VSize(claimedPosition.Location - Enemy.Location) > VSize(Pawn.Location - Enemy.Location) );
    if( KeepGoing() )
    {   Continue_Engaged_FindNewCover();
    }

    MarkTime(LastFindNewCoverTime);
    Goto('DONE');
WAIT:
    bAdvanceWait = true;
    Sleep(2.5);
    //log("WAIT FAILED");
DONE:
    myAIRole.FindNewCoverSucceeded();


}

//==============
// BackOff
// Go to a spot that is at least X distance away from enemy
// preferably, without walking past him
//==============
function Perform_Engaged_BackOff()
{
    PickBackOff();
    setCurAction("BackOff");
    
    GotoState('Engaged_BackOff', 'Backoff');
}

function PickBackOff()
{
    local Vector strafeDir;

    strafeDir = Normal(Vector(Rotation) cross vect(0,0,1));
    bStrafeDir = !bStrafeDir;
    if(bStrafeDir)
        strafeDir = -1 * strafeDir;

	strafeDir += normal(Pawn.Location - Enemy.Location);

    if(!TestDirection(strafeDir, Pawn.CollisionRadius * RandRange(5.0, 10.0), strafeTarget) )
    {
        setCurAction("NoBackoffDir");
        Perform_Error_Stop();
    }
}

state Engaged_BackOff
{
    //Avoid falling off ledges while moving
    function BeginState()
    {
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        Pawn.bCanJump = false;
        bAdjustFromWalls = false;
    }

    function EndState()
    {
        bAdjustFromWalls = true;
        if ( Pawn == None )
            return;
        Pawn.bAvoidLedges = false;
        Pawn.bStopAtLedges = false;
        MinHitWall -= 0.15;
        if (Pawn.JumpZ > 0)
            Pawn.bCanJump = Pawn.default.bCanJump;
    }

BEGIN:

BACKOFF:
    MoveTo( strafeTarget, Enemy /*,bShouldWalk*/ );
    
FinishedBackoff:
    myAIRole.strafeMoveSucceeded();

}

//==============
// ShortRush
// Go to a spot that is at least X distance away from enemy
// preferably, without walking past him
//==============
function Perform_Engaged_ShortRush()
{
    PickShortRush();
    setCurAction("ShortRush");
    
    GotoState('Engaged_ShortRush', 'ShortRush');
}

function PickShortRush()
{
    local Vector rushDir;

    rushDir = normal(Enemy.Location - Pawn.Location);

    if(!TestDirection(rushDir, Pawn.CollisionRadius * RandRange(5.0, 10.0), strafeTarget) )
    {
        setCurAction("NoShortRushDir");
        Perform_Error_Stop();
    }
}

state Engaged_ShortRush
{
    //Avoid falling off ledges while moving
    function BeginState()
    {
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        bAdjustFromWalls = false;
    }

    function EndState()
    {
        bAdjustFromWalls = true;
        if ( Pawn == None )
            return;
        Pawn.bAvoidLedges = false;
        Pawn.bStopAtLedges = false;
        MinHitWall -= 0.15;
    }

BEGIN:

ShortRush:
    MoveTo( strafeTarget, Enemy /*,bShouldWalk*/ );
    
FinishedShortRush:
    myAIRole.strafeMoveSucceeded();

}
//==============
// Melee
//
// Enemy is too close, take a swing
//==============

function bool ShouldMelee(Pawn Seen)
{
    if( bPawnMayMelee
        && Enemy == Seen 
        && !Pawn.IsA('VGVehicle') && !bIsRidingVehicle
        && !IsInState('Engaged_Melee') 
        && !IsInState('Scripting')
        && VSize(Enemy.Location - Pawn.Location) < MeleeRange
        && abs(Enemy.Location.Z - Pawn.Location.Z) < 100
        && TimeElapsed(LastMeleeTime, 3.0) )
    {
        return true;            
    }
    return false;
    
}

function Perform_Engaged_Melee()
{
    GotoState('Engaged_Melee');
}

state Engaged_Melee
{
    function EndState()
    {
        enable('NotifyBump');
        if(Pawn != None)
        {
            Pawn.AnimBlendToAlpha(MELEE_CHANNEL, 0, 0.4);
        }
    }


    function AnimEnd(int Channel)
    {
        if ( Channel == MELEE_CHANNEL )
        {
            Pawn.AnimBlendToAlpha(MELEE_CHANNEL, 0, 0.4);
            Notify();
        }
        else
        {
            Global.AnimEnd(Channel);
        }
    }

    function Notify_Melee()
    {
        if( Pawn != None && Enemy != None && Enemy.Controller != None && VSize(Enemy.Location - Pawn.Location) < Pawn.CollisionRadius*4 )
        {
            Enemy.TakeDamage(15, Pawn, Enemy.Location, 100*Vector(Pawn.Rotation), class'VehicleWeapons.BoneSawDamage');
            Enemy.Controller.DamageShake(50);
		}
    }

    function vector MeleeDest()
    {
        return Enemy.Location + Normal(Pawn.Location - Enemy.Location)*Enemy.CollisionRadius*2;
    }

    event bool NotifyBump(actor Other)
    {
        local Pawn P;
        if(!Other.IsA('Pawn'))
            return false;

        P = Pawn(Other);
        if(Enemy == P)
        {
            disable('NotifyBump');
            GotoState('Engaged_Melee','ATTACK');
        }
        else
        {
            AdjustAround(P);
        }
    }


BEGIN:
    setCurAction("MELEE");
CHARGE:
    StopFireWeapon();
    if(VSize(Enemy.Location - Pawn.Location) > MeleeChargeThreshold
        && VSize(Enemy.Location - Pawn.Location) < MeleeRange )
    {
        if(actorReachable(Enemy))
        {
            MoveToward( Enemy,Enemy );
            GOTO('ATTACK');
        }
        else
        {
            MoveTarget = FindPathToward(Enemy);
            if(MoveTarget != None)
            { 
                MoveToward( MoveTarget,Enemy );
                GOTO('CHARGE');
            }
			GOTO('DONE');
        }

    }
ATTACK:
    disable('NotifyBump');
    if(VSize(Enemy.Location - Pawn.Location) > MeleeChargeThreshold)
		GOTO('DONE');
    Pawn.StopMoving();
    Focus = Enemy;
    FinishRotation();
    Pawn.AnimBlendParams(MELEE_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    Pawn.PlayAnim(MeleeAnim, , ,MELEE_CHANNEL);
	WaitForNotification();
    Sleep(0.2);
    if( Normal(Enemy.Location - Pawn.Location) dot Normal(Enemy.Velocity) > 0.707)
        Goto('DONE');
    if( Normal(Enemy.Location - Pawn.Location) dot Vector(Enemy.Rotation) > 0.707)
        Goto('DONE');
    if( VSize(Enemy.Location - Pawn.Location) < MeleeRange)
        Goto('CHARGE');
DONE:
    MarkTime(LastMeleeTime);
    myAIRole.MeleeSucceeded();
    
}

//==============
// Dead
//
// Make sure we notify Stage if appropriate
//==============
function WasKilledBy(Controller Other)
{
    //add fear
    local StagePosition position;
    local int i;
    local float tmpDist;

    if ( currentStage == None ) return;
    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        position = currentStage.StagePositions[i];
        if ( position == None || Pawn == None ) continue;
        tmpDist = VSize(position.Location - Pawn.Location);
        if( tmpDist < 750) {
            position.FearCost += 750 - tmpDist;
        }
    }
}

/**
 */
//@@@ not sure why this works, but WasKilledBy() doesn't (in UW codebase)...?
function PawnDied( Pawn p ) {

    super.PawnDied( p );

    if(myAIRole != None)
        myAIRole.OnKilled( none );
    //GotoState('Dead');
}

State Dead
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

    function Timer() {}

    function BeginState()
    {

        Enemy = None;

        if ( (GoalScript != None) && (HoldSpot(GoalScript) == None) )
            FreeScript();

        StopFiring();
        UnClaimPosition();

        if(currentStage != none)
        {
            currentStage.leaveStage(self, RSN_Died);
			currentStage = None;
        }

        if ( myCreator != None ) myCreator.OpponentDied( self );
        Destroy();
    }

}

// for hibernating
State Dormant {
ignores EnemyNotVisible, SeePlayer, HearNoise;

}

//==============
// Debugging
//==============

/**
 *  Basically the same as standGround, but it relies on the caller to set "curAction" to be used for unaccounted-for
 * situations like when a path can't be found, etc.
 **/
function Perform_Error_Stop()
{

    if(Focus != Enemy) //not visible
    {
            SetFocalPointNearLocation(LastSeenPos);
    }
    Pawn.Velocity = vect(0,0,0);
    GotoState('Error_Stop');
}

state Error_Stop
{
ignores EnemyNotVisible;

    function BeginState()
    {
         Pawn.Acceleration = vect(0,0,0);
        Pawn.Velocity = vect(0,0,0);
    }

BEGIN:
    Focus = Enemy;
    FinishRotation();
    Sleep( 2.0 );
        myAIRole.ErrorStopSucceeded();
}

/**
 */
function vector WorldToScreen( vector w ) {
    //@@@ UC
    //C.WorldToScreen( w );

    //@@@ I think this method should be portable across codebases...
   return Level.GetLocalPlayerController().player.console.WorldToScreen( w );
}

/**
 * When called, will draw debug text above the bots head
 */
function DrawHUDDebug(Canvas C)
{
    local vector screenPos;

    if (!bDebugLogging || Pawn == None) return;

    screenPos = WorldToScreen( Pawn.Location
                               + vect(0,0,1)*Pawn.CollisionHeight );
    if (screenPos.Z > 1.0) return;

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    C.DrawText( myAIROle.GetDebugText());

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-12);
    C.DrawText( curAction );

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y);
    if(Enemy == None)
        C.DrawText(LatentFloat );
    else
        C.DrawText(LatentFloat @ VSize(Enemy.Location - Pawn.Location) );
    

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-36);
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local string drawText;
    local float CurY;
    //if ( !bDebugLogging ) return;

    Super.DisplayDebug(Canvas,YL, YPos);
    CurY = Canvas.CurY;
    Canvas.SetPos( Canvas.CurX, Canvas.ClipY - 100 );
    Canvas.SetDrawColor(0,255,0);
    drawText = "Stage:";
    if ( currentStage == None ) {
        drawText = drawText @ "None";
    }
    else {
        drawText = drawText @ currentStage.StageName;
    }
    Canvas.DrawText( drawText );

    switch (curStageOrder)
    {
    case SO_None:
        drawText = "SO_None";
        break;
    case SO_TakeUpPosition:
        drawText = "SO_TakeUpPosition"@TakeUpPosition;
        break;
    case SO_HoldPosition:
        drawText = "SO_HoldPosition";
        break;
    case SO_TakeCover:
        drawText = "SO_TakeCover";
        break;
    case SO_AttackTarget:
        drawText = "SO_AttackTarget";
        break;
    case SO_Patrol:
        drawText = "SO_Patrol";
        break;
    default:
        drawText = "Unrecognized order:" @ curStageOrder;
        break;
    }

    drawText = "STAGE ORDER:"@drawText@"  Performing:"@curAction;
    if(Enemy != None) {
        drawText = drawText @ "hitChance:" @ ChanceToHit() @ "enemyDist"
            @ VSize(Enemy.Location - Pawn.Location);
    }
    Canvas.DrawText(drawText);

    drawText = "Enemy:" $ Enemy @ "ShootTarget:" $ ShootTarget
                        @ "Focus:" $ Focus @ "FocalPoint:" $ FocalPoint;
    Canvas.DrawText( drawText );
    Canvas.SetPos( Canvas.CurX, CurY );
}

/**
 * Handy debugging helper.  No flags means always output, otherwise
 * output is only generated when the flag bits are also set in
 * AIDebugFlags.
 */
function DebugLog( coerce String s, optional int flags ) {
    if ( bDebugLogging ) {
        if ( flags == 0 || (flags & AIDebugFlags) != 0 ) {
            Log( self @ s, 'VGSPAIController' );
        }
    }
}

function debugTick(float dT)
{
    //drawSweep();

    if(claimedPosition != None)
        drawdebugline(Pawn.Location + vect(0,0,1), claimedPosition.Location + vect(0,0,1), 255,0,255);
    
    //drawdebugline(Pawn.Location, Destination, 255,255,255);
    //drawdebugline(Pawn.Location, FocalPoint + vect(0,0,2), 255,255,255);
    /*
    if(Pawn.Anchor != None)
        drawdebugline(Pawn.Location, Pawn.Anchor.Location, 0,255,0 );
    */

    //drawClaimedLOSChecks();
    //drawEnemyTarget();
    //debugDrawFireCone(); //cone-shaped

    if ((AIDebugFlags & DEBUG_POSITIONS) != 0 )
    {
        //drawCover();
        //drawHiding();
        //drawPosnLOS();
        //drawPosnEnemyLOS();
        drawPositionWeights();
        //drawExperimentalGrid(); //green
        //debugDrawBlockingLOF(); //red
        //debugDrawBlockedLOF(); // blue
        //debugDrawVerifiedPositions(); //white and black
    }
}

/**
 * Draw the lines that are used to check LOF from the node
 **/
function drawClaimedLOSChecks()
{
    local vector eyeLoc, nodeOnGround;
    if(claimedPosition != None && Enemy != None)
    {
        eyeLoc = vect(0,0,1) * Pawn.default.BaseEyeHeight;
        nodeOnGround = claimedPosition.Location;
        nodeOnGround.Z = claimedPosition.OnGroundZ;
        drawdebugline(nodeOnGround + vect(0,0,1)*Pawn.CollisionHeight + eyeLoc,
                      Enemy.Location, 255,255,255);

        drawdebugline(nodeOnGround + vect(0,0,1)*(Pawn.CrouchHeight-20) + eyeLoc,
                      Enemy.Location, 255,255,255);
    }
}

/**
 * Draw lines for some enemy data (such as last seen position)
 */
function drawEnemyTarget()
{
    if(Enemy != None)
    {
        if(EnemyIsVisible()) {
            if( SameTeamAs(Level.GetLocalPlayerController()) ) {
                drawdebugline( Pawn.Location+vect(0,0,10), Enemy.Location,
                               0, 0, 255 );
            }
            else {
                drawdebugline( Pawn.Location+vect(0,0,10), Enemy.Location,
                               255, 0, 0 );
            }
        }
        else {
                drawdebugline( Pawn.Location+vect(0,0,10), LastSeenPos,
                            179, 179, 255 );
                drawdebugline( Pawn.Location+vect(0,0,10), LastSeeingPos,
                           53, 53, 255 );
        }
    }
}

/**
 * draw a bar to indicate whether the node provides some obstuction
 */
function drawCover()
{
    local int i;
    local StagePosition position;

    if ( currentStage == None ) return;

    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        position = currentStage.StagePositions[i];
        if( currentStage.PositionProvidesCoverFromEnemy(position, Enemy) > 0) {
            drawdebugline( position.Location,
                           position.Location + vect(0,0,1)*50, 255,0,0 );
        }
        else {
            drawdebugline( position.Location,
                           position.Location + vect(0,0,1)*50, 0,0,255 );
        }
    }
}


/**
 * Draw a bar to indicate whether the node provides concealment
 **/
function drawHiding()
{
    local int i;
    local StagePosition position;

    if ( currentStage == None ) return;

    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        position = currentStage.StagePositions[i];
        if( currentStage.PositionProvidesHidingFromEnemy(position, Enemy)) {
            drawdebugline( position.Location + vect(0,5,0),
                           position.Location + vect(0,0,1)*50, 255,0,0 );
        }
        else {
            drawdebugline( position.Location + vect(0,5,0),
                           position.Location + vect(0,0,1)*50, 0,255,0 );
        }
    }
}

/**
 * Draw a fan-out to indicate if the pos has LOF to any of 8 possible enemies
 **/
function drawPosnLOS()
{
    local int i, j;
    local StagePosition position;
    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        position = currentStage.StagePositions[i];
        for(j=0;j<8;j++)
        {
            if( (position.StandLOF & (0x1<<j)) != 0 )
            {   drawdebugline(position.Location, position.Location + vect(0,0,1)*50 + vect(0,1,0)*10*j, 255,0,0);
            }
            else if(currentStage.Enemies[j] != None)
            {   drawdebugline(position.Location, position.Location + vect(0,0,1)*50 + vect(0,1,0)*10*j, 0,255,0);
            }
            else
            {   drawdebugline(position.Location, position.Location + vect(0,0,1)*50 + vect(0,1,0)*10*j, 0,0,255);
            }

        }
    }
}

/**
 * Draw a bar to indicate whether the node has standing and/or crouching LOF
 **/
function drawPosnEnemyLOS() {
    local int i, idx;
    local StagePosition position;

    idx = currentStage.GetEnemyIndex(Enemy);

    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        position = currentStage.StagePositions[i];
        if( (position.CrouchLOF & (0x1<<idx)) == 1 ) {
            drawdebugline(position.Location,
                            position.Location + vect(0,0,1)*75, 255,0,0);
        }
        else {
            drawdebugline(position.Location,
                        position.Location + vect(0,0,1)*75, 0,0,255);
        }

        if( (position.StandLOF & (0x1<<idx)) == 1 ) {
            drawdebugline(position.Location + vect(0,0,1)*75,
                            position.Location + vect(0,0,1)*100, 255,0,0);
        }
        else {
            drawdebugline(position.Location + vect(0,0,1)*75,
                            position.Location + vect(0,0,1)*100, 0,0,255);
        }
    }
}

/**
 * Draw a bar to indicate whether the node is Hot or Cold, based on Weight
 **/
function drawPositionWeights()
{
    local int i;
    local StagePosition position, bestPos;
    local float weight, bestWeight;

    if(Enemy != None)
    {
        bestWeight = 0;
        for( i = 0; i < currentStage.StagePositions.Length; i++ )
        {
            position = currentStage.StagePositions[i];
            weight = WeightStagePosition(position);
            if(weight > bestWeight) {
                bestWeight = weight;
                bestPos = position;
            }
            weight = 250.0 * (1.0 - weight);
            drawdebuglineHSV(position.Location, position.Location + vect(0,0,1)*50, weight, 1.0, 1.0);
            //weight = 255.0 * weight;
            //drawdebugline(position.Location, position.Location + vect(0,0,1)*50, weight,0,0);
            if(position.bIsClaimed)
                drawdebugline(position.Location + vect(0,0,1)*50,
                                position.Location + vect(0,0,1)*75, 255,0,255);
        }

        if(bestPos != None)
            drawdebugline(bestPos.Location + vect(0,0,1), bestPos.Location + vect(0,0,1)*50, 255, 255, 255);
    }

}

function drawExperimentalGrid()
{

    local int gridNum, colSize;
    local int x, y, sign, xSign, ySign;
    local vector delta, spot;

    colSize = 160;
    gridNum = 1200 / (colSize*2);

    for(sign = 0; sign<4; sign++)
    {
        xSign = 1 - 2*(sign/2);
        ySign = 1 - 2*(sign%2);
        for(x = 0; x < gridNum; x++)
        {
            for(y = 0; y < gridNum-x; y++)
            {
                delta = vect(1,0,0)*colSize*x*xSign + vect(0,1,0)*colSize*y*ySign;
                spot = Pawn.Anchor.Location + delta;
                spot.X = int( (spot.X + 0.5*colSize) / colSize ) * colSize;
                spot.Y = int( (spot.Y + 0.5*colSize) / colSize ) * colSize;

                drawdebugline(spot, spot + vect(0,0,1)*50 , 0,255,0 );
            }
        }
    }

}

function debugDrawVerifiedPositions()
{
    local int i;
    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        if( VerifyShootingPosition(currentStage.StagePositions[i]) )
            drawdebugline(currentStage.StagePositions[i].Location, currentStage.StagePositions[i].Location + 50 * vect(0,0,1), 255,255,255);
        else
            drawdebugline(currentStage.StagePositions[i].Location, currentStage.StagePositions[i].Location + 50 * vect(0,0,1), 0,0,0);
    }
}

function debugDrawFireCone()
{
    if(Enemy != None)
    {
        if( (Enemy.CollisionRadius*3.0) / VSize(Pawn.Location - Enemy.Location) > 0.123 )
        {
            drawdebugline(Pawn.Location,  Enemy.Location + (( Normal(Enemy.Location - Pawn.Location)*VSize(Pawn.Location - Enemy.Location)* 0.123) << rotator(vect(0,1,0))), 0,0,255);
            drawdebugline(Pawn.Location,  Enemy.Location + (( Normal(Enemy.Location - Pawn.Location)*VSize(Pawn.Location - Enemy.Location)* 0.123) << rotator(vect(0,-1,0))), 0,0,255);
        }
        else
        {
            drawdebugline(Pawn.Location,  Enemy.Location + (( Normal(Enemy.Location - Pawn.Location)*Enemy.CollisionRadius*3.0) << rotator(vect(0,1,0))), 0,255,0);
            drawdebugline(Pawn.Location,  Enemy.Location + (( Normal(Enemy.Location - Pawn.Location)*Enemy.CollisionRadius*3.0) << rotator(vect(0,-1,0))), 0,255,0);
        }
    }
}

function debugDrawBlockedLOF()
{
    local int i;

    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        if( currentStage.calculateStagePosnLOSIsBlocked(self, currentStage.StagePositions[i]) > 0)
        {
            drawdebugline(currentStage.StagePositions[i].Location, currentStage.StagePositions[i].Location + 50 * vect(0,0,1), 0,0,255);
        }
    }
}

function debugDrawBlockingLOF()
{
    local int i;
    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        if( currentStage.calculateStagePosnBlocksLOS(self, currentStage.StagePositions[i]) > 0)
        {
            drawdebugline(currentStage.StagePositions[i].Location, currentStage.StagePositions[i].Location + 100 * vect(0,0,1), 255,0,0);
        }
    }
}



//=============
// Helpers
//=============

//just let's us do some logging if we need to
function setCurAction(string action)
{
    //log("curAction"@curAction);
    curAction = action;
}

/**
 * integer version of RandRange, returns an random integer between Min and Max
 **/
function int iRandRange(int min, int max)
{
    return Min + Rand((Max - Min) + 1);
}

function bool ShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
	local actor HitActor;
	local vector HitNormal,HitLocation, X,Y,Z, projstart;

	if ( !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability))
		|| Pawn.Weapon.RecommendSplashDamage() )
	{
		return false;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Pawn.Weapon.GetFireStart(X,Y,Z);
	projStart = projStart + StartPosition - Pawn.Location;
	projStart.Z = projStart.Z - 1.8 * (Pawn.CollisionHeight - Pawn.CrouchHeight); 
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		return true;
	}

	projStart.Z = projStart.Z + 1.8 * (Pawn.Default.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		return false;
	}
	return true;
}


/**
 * Return an actor that the bot should use as the Focus during movetowards
 **/
function Actor ActorToFace()
{
    local float RelativeDir;

    if ( (Enemy == None) || TimeElapsed(LastSeenTime, 6) )
        return FaceMoveTarget();
    if ( (MoveTarget == Enemy) || (skill >= 6) ||
        (VSize(MoveTarget.Location - Pawn.Location) < 4 * Pawn.CollisionRadius) )
        return Enemy;
    if ( TimeElapsed(LastSeenTime,4) )
        return FaceMoveTarget();

    if ( VSize( Enemy.Location - Pawn.Location) < 1000 )
        return Enemy;

    RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z))
            Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

    if ( RelativeDir > 0.9 )
        return Enemy;
    if ( skill < 2 + FRand() )
        return FaceMoveTarget();
}

function Actor FaceMoveTarget()
{
    if ( MoveTarget != Enemy )
        StopFiring();
    return MoveTarget;
}

function drawdebuglineHSV(vector LineStart, vector LineEnd, byte h, byte s, byte v)
{
    local float r,g,b;

    HSVtoRGB(h,s,v, r,g,b);
    drawdebugline( LineStart,  LineEnd, r*255, g*255, b*255);
}

function HSVtoRGB(float h, float s, float v,  out float r, out float g, out float b)
{
    local int i;
    local float f, p, q, t;
    if( s == 0 ) {
        // achromatic (grey)
        r = v;
        g = v;
        b = v;
        return;
    }
    h /= 60;            // sector 0 to 5
    i = h;
    f = h - i;          // factorial part of h
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    switch( i ) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:        // case 5:
            r = v;
            g = p;
            b = q;
            break;
    }
}

defaultproperties
{
     MinNumShots=3
     MaxNumShots=5
     CLAIMED_POSITION_PENALTY=9999
     MaxLostContactTime=5.000000
     ReflexTime=0.500000
     MinShotPeriod=1.000000
     MaxShotPeriod=3.000000
     MaxSkillOdds=0.750000
     BaseAimYawError=800.000000
     MaxAimRange=5000.000000
     MaxAimVelocity=500.000000
     MaxSecondsOfLOS=3.000000
     fOddsOfStrafeMove=0.250000
     MinTimeBetweenStrafeMove=3.000000
     MeleeChargeThreshold=200.000000
     MeleeRange=350.000000
     maxDistToCrouchForCover=300.000000
     EnemyDistractDuration=7.000000
     EnemyDistractDistance=1000.000000
     m_BunchPenalty=1.000000
     m_BlockedPenalty=1.000000
     m_BlockingPenalty=1.000000
     m_NeedForContact=1.000000
     m_NeedCohesion=1.000000
     m_NeedForIntel=1.000000
     m_NeedToAvoidCorpses=1.000000
     m_NeedForClosingIn=1.000000
     m_NeedForNearbyGoal=1.000000
     m_SameSideOfEnemy=1.000000
     m_CrossPenalty=1.000000
     m_ProvidesCover=1.000000
     m_TacticalHeight=1.000000
     sweepTimerPeriod=2.000000
     lastHitTime=-1.000000
     ReloadAnim="Bulldog_Reload"
     MeleeAnim="MeleeAttack"
}
