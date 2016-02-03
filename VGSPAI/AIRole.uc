/**
 * AIRole - encapsulates the logic for translating orders into
 *    behaviours.
 *
 * Note: This class is in a transitional state, so might not be quite
 *       in synch with the above description.
 *
 * Todo:
 *  - convert to state-code implementation, with latent behaviours.
 *  - maybe an instance of a role could act like a prototype object,
 *    which controllers can clone at run-time.
 *
 * @version $Revision: 1.23 $
 * @author  Mike Horgan (mikeh@digitalextremes.com)
 * @date    Dec 2003
 */
class AIRole extends Actor;

#exec Texture Import File=Textures/Brain.tga Name=AIRoleIcon Mips=Off MASKED=1


// Our owner
var VGSPAIController	bot;

//@@@ A new idea, that doesn't exist yet between stages and
//@@@ controllers, but might make role design easier.
enum OrderStrictness {
    OS_Normal,     // should follow this order, with room for interpretation.
    OS_Imperitive, // *must* follow this order as best it can manage.
    OS_Optional    // more of a hint, bot can follow as closely as it likes.
};

//=========
//Modifiers
//=========

// Percent of health below which a bot might hide or panic.
var float	pctHealth;

// Odds this character will panic from low health
var float	fOddsOfPanic;

//Set in state for sub action
var name curLabel;

///////
// State members
//////
var PatrolPosition patrolPos;

// set to Level.TimeSeconds by behaviours to track durations	
var float timeTracker;			
// set to a duration by behaviours to trigger state changes
var float timeDuration;	

var(AI) bool bDebugLogging;


//======================
// Current Situation
//======================

function String GetDebugText()
{
    return GetStateName() $ ":" $ curLabel;
}

//===========================================================================
// Order hooks - called when the stage gives the controller an order.
//   See the corresponding StageOrder_* methods in VGSPAIController
//   for the semantics of the orders.
//===========================================================================

//@@@ currently, these are just copied from the VGSPAIController
//@@@ versions, eventually, they will be re-implemented to keep all of
//@@@ the logic in the AIRole.

/**
 */
function Order_TakeUpPosition( StagePosition pos, 
                               optional OrderStrictness strictness ) {
    if (pos == None) return;
    bot.curStageOrder  = SO_TakeUpPosition;
    bot.TakeUpPosition = pos;
    GotoState('TakeUpPosition');
}

/**
 */
function Order_HoldPosition( optional OrderStrictness strictness ) {
    //UnClaimPosition();
    bot.curStageOrder = SO_HoldPosition;
}

/**
 */
function Order_TakeCover( StagePosition pos, 
                          optional OrderStrictness strictness ) {
    bot.curStageOrder = SO_TakeCover;
}

/**
 */
function Order_AttackTarget( Actor target, 
                             optional OrderStrictness strictness ) {
    if ( target == None ) return;
    bot.curStageOrder = SO_AttackTarget;
    bot.ShootTarget   = target;
    if ( Pawn(target) != None ) {
        bot.AcquireEnemy( Pawn(target), false ); //@@@ what to use for bCanSee?
    }
    PerformShootTarget();
}

/**
 */
function Order_Patrol( PatrolPosition pos,
                       optional OrderStrictness strictness ) {
    bot.curStageOrder = SO_Patrol;
    patrolPos = pos;
    GOTO_Patrol();
}

/**
 */
function Order_None( optional OrderStrictness strictness ) {
    bot.curStageOrder = SO_None;
}


	   

//===========================================================================
// Behaviour status callbacks...
//===========================================================================

/**
 */
function awakenSucceeded() {
    BotSelectAction();
}

/**
 */
function NotEngagedAtRestSucceeded() {
    BotSelectAction();
}

/**
 */
function NotEngagedWanderSucceeded() {
    BotSelectAction();
}

/**
 */
function MoveToPositionSucceeded() {
    BotSelectAction();
}

/**
 */
function StandGroundSucceeded() {
    BotSelectAction();
}

function AttackFromCoverSucceeded(){
    BotSelectAction();
}

function AttackFromCoverFailed() {
    BotSelectAction();
}

/**
 */
function FireAtTargetSucceeded() {
    BotSelectAction();
}

/**
 */
function RecoverEnemySucceeded() {
    BotSelectAction();
}

function RecoverEnemyFailed() {
    BotSelectAction();
}

/**
 */
function GetLOSSucceeded() {
    BotSelectAction();
}

/**
 */
function GetLOSFailed() {
    BotSelectAction();
}

/**
 */
function HideFromEnemySucceeded() {
    BotSelectAction();
}

function HideFromEnemyFailed() {
    BotSelectAction();
}

/**
 */
function outFromCoverSucceeded() {
    BotSelectAction();
}

/**
 */
function supressionFireSucceeded() {
    BotSelectAction();
}


/**
 */
function ReloadWeaponSucceeded() {
    BotSelectAction();
} 

/**
 */
function TakeCoverSucceeded() {
    if ( bot.currentStage != None ) bot.currentStage.Report_Covered( bot );
    BotSelectAction();
}

/**
 */
function TakeCoverFailed() {
    if ( bot.currentStage != None ) bot.currentStage.Report_Exposed( bot );
    BotSelectAction();
}

/**
 */
function ChargeSucceeded() {
    BotSelectAction();
}

/**
 */
function strafeMoveSucceeded() {
    BotSelectAction();
}

/**
 */
function HuntSucceeded() {
    BotSelectAction();
}
function HuntFailed() {
    BotSelectAction();
}
/**
 */
function PanicSucceeded() {
    BotSelectAction();
}

/**
 */
function FindNewCoverSucceeded() {
    BotSelectAction();
}

function FindNewCoverFailed() {
    BotSelectAction();
}

function errorStopSucceeded() {
    DebugLog("ErrorStop FAILED at"@bot.curAction);
    BotSelectAction();
}

/**
 */
function takePositionFailed() {
    BotSelectAction();
}

/**
 */
function TakePositionSuceeded() {
    BotSelectAction();
}


function AssaultApproachSucceeded() {
    BotSelectAction();
}

function AssaultApproachFailed() {
    BotSelectAction();
}

function MeleeSucceeded() {
    BotSelectAction();
}

//===========================================================================
// Events of note, care of the controller...
//===========================================================================

function OnCoverNotValid();

/**
 */
function OnEnemyAcquired();

/**
 */
function OnTakingDamage(Pawn Other, float Damage);

/**
 */
function OnUnderFire();

/**
 */
function OnLostSight();

/**
 */
function OnRegainedSight();

/**
 * Death of a friendly...
 */
function OnWitnessedDeath();

/**
 * Killed an enemy
 */
function OnWitnessedKill( Controller killer, Pawn victim ) {
    //bot.DebugLog( "Saw" @ killer @ "kill" @ victim );
}

/**
 * Called whenever an enemy pawn is in sight, but not the current
 * enemy.
 */
function OnThreatSpotted( Pawn threat );

/**
 * Analagous to OnThreatSpotted().
 */
function OnThreatHeard( Pawn threat );

/**
 */
function OnKilled( Controller killer );

/**
 */
function OnStartle(Actor Feared);

/**
 */
function OnMustReload();

function OnMeleeRange()
{
    bot.Perform_Engaged_Melee();
}

//===========================================================================
// Misc controller interface
//===========================================================================

/**
 */
function init(VGSPAIController c)
{
    bot = c;
    SetNodeFactorWeights(c);
    bDebugLogging = c.bDebugLogging;
}


//===========================================================================
// Transient code (will probably be obselete...)
//===========================================================================

/**
 * Migrated from VGSPAIController.SelectAction()
 *
 * This will eventually be replaced by state code, which will be able
 * to block waiting for behaviours, instead of this crazy
 * state-machine polling action.
 **/
function BotSelectAction()
{
    // Scripting performs behaviours.
    if ( bot.ScriptingOverridesAI() && bot.ShouldPerformScript() )
    {
        if ( bot.ActionNum < bot.SequenceScript.Actions.length ) {
            bot.curAction = "Script" 
                @ bot.SequenceScript.Actions[bot.ActionNum].GetActionString();
        }
        else {
            bot.curAction = "Script-action-out-of-bounds";
        }
        return;
    }
	// Let the order determing the behaviour
    if( bot.currentStage != None)
    {
        bot.FollowOrder();
    }
    else // Let the role determine behaviour.
    {
        RoleSelectAction();
    }
}



/**
 * The Role will decide what behaviour is most appropriate.
 */
function RoleSelectAction() {
    //AnalyzeSituation();
    if( PerformRole() ) return;
    if( PerformShootTarget() ) return;

    PerformIdleOrder();
    SelectBehaviour();
    PerformBehaviour();
    return;
}

/**
 * A sketchy hack to start the crazy AIRole control flow... hopefully
 * this won't be needed once latent behaviours are implemented.
 */
auto state InitRole {
BEGIN:
    Sleep( 0.25 );
    BotSelectAction();
}


//===========================================================================
// Other code (don't know if it's in or out)
//===========================================================================


/**
 */
function SetNodeFactorWeights(VGSPAIController c);

/**
 */
function bool PerformRole()
{
    return false;
}

function bool PerformShootTarget()
{
    if(ShouldShootTarget() ) {
        GotoState('AttackTarget');
        return true;
    }
    return false;
}
        
/**
 */
function bool ShouldShootTarget()
{
    // during combat, have to decide between shooting at the
    // target and doing other combat things - like shooting at the
    // enemy.
    local float lastHitTime;
    lastHitTime = bot.getLastHitTime();
    if ( bot.ShootTarget != None 
         // haven't been damaged lately...
         && ( (lastHitTime < 0) 
             || (Level.TimeSeconds - lastHitTime) > bot.EnemyDistractDuration)
         // and the enemy isn't too close...
         && ( (bot.Enemy == None) 
                || (VSize(bot.Enemy.Location - Location) > bot.EnemyDistractDistance) )
         // and we haven't seen him in a while
         && ( (bot.Enemy == None) 
                || (bot.LastSeenTime < 0) 
                || ((Level.TimeSeconds - bot.LastSeenTime) > bot.EnemyDistractDuration) )
         ) {
        return true;
    }			
    return false;
}

/**
 */
function AnalyzeSituation()
{
    local float fContactPct;
    
    if( bot.LostContact(bot.MaxLostContactTime) )
    {
        bot.LoseEnemy(bot.MaxLostContactTime);
    }
    
    if ( bot.Enemy == None && bot.currentStage != None)
    {
        bot.currentStage.FindNewEnemyFor(bot);
    }

    // if there is no stage, then an contact of 0 is reasonable
    // (we only know ourselves);
    if( bot.currentStage != None )
    {		
        fContactPct = bot.currentStage.Request_PercentEyeSighted(bot);
    }
}

/** 
 * We are coming out of an engagement, and should check idle orders
 **/
function PerformIdleOrder() {
    if( bot.Enemy == None ) {
        GOTO_Relax();
    }
}

/** 
 * SelectBehaviour
 * This must take the situation analysis and choose the most fit behaviour
 */
function SelectBehaviour()
{
    GOTO_Attack();
}
/** 
 * PerformBehaviour
 * This allows the behaviour to choose appropriate bot actions
 */
function PerformBehaviour();


//===========================================================================
// Role Tactics
//===========================================================================


//===========
// Directives
// basically, our analysis of the situation will prioritze these
//===========

function GOTO_Relax()
{
    local VGSPAIController.EStageOrder oldOrder;

    GotoState('Relax');

    if( bot.currentStage != None ) {
        oldOrder = bot.curStageOrder;
        bot.currentStage.Request_IdleOrder( bot );
        if( bot.curStageOrder != oldOrder ) {
            bot.FollowOrder(); 
            return;
        }
    }
}

function GOTO_Patrol(){
    GotoState('Patrol');
}

/**
 * For now, rely on subclasses to choose attack state.
 **/
function GOTO_Attack()
{
    GotoState('DefaultAttack');
    
}

//=============
// Order States
//=============

state AttackTarget
{
    function SelectBehaviour() {}

    function PerformBehaviour()
    {
        Notify();
    }

    function bool PerformShootTarget()
    {
        if(ShouldShootTarget() ) {
            Notify();
            return true;
        }
        GOTO_Attack();
        return false;
    }

    function OnEnemyAcquired() {
        if( curLabel == 'Fire');
        GOTO_Attack();
    }

BEGIN:
    curLabel = 'Run';
    bot.Perform_RunToward(bot.TakeUpPosition); WaitForNotification();
    while(true) {
        curLabel = 'Fire';
        bot.Perform_NotEngaged_FireAtTarget(); WaitForNotification();
    }
}


/**
 * We won't get interrupted until we get where we're supposed to be
 **/
state TakeUpPosition
{
    function SelectBehaviour() {
        if(curLabel == 'Rest' && bot.Enemy != None) {
            GOTO_Attack();
        }
    }

    function 

    function PerformBehaviour()
    {
        Notify();
    }

    function PerformIdleOrder() {}

    function OnEnemyAcquired() {
        if( curLabel == 'Rest')
            GOTO_Attack();
    }
BEGIN:
    curLabel = 'Run';
    bot.Perform_RunToward(bot.TakeUpPosition); WaitForNotification();
    bot.curStageOrder = SO_None;
    bot.currentStage.Report_InPosition(bot, bot.TakeUpPosition);
    if(bot.Enemy != None)
         GOTO_Attack();
    while( true ) {
        curLabel = 'Rest';
        bot.Perform_NotEngaged_AtRest( 5.0 );  WaitForNotification();
    }     
}


state Patrol
{
    function SelectBehaviour() {}

    function PerformBehaviour()
    {
        Notify();
    }

    function PerformIdleOrder() {}

    function OnEnemyAcquired() {
        bot.curStageOrder = SO_None;
        GOTO_Attack();
    }

BEGIN:
    curLabel = '';
    while( true ) {
        if(patrolPos == None){
            bot.Perform_NotEngaged_AtRest( 5.0 );  WaitForNotification();
        }
        else {
            curLabel = patrolPos.Tag;
            bot.Perform_WalkToward(patrolPos); WaitForNotification();
            if(patrolPos.PauseTimeMin > 0) { 
                bot.Perform_NotEngaged_AtRest( RandRange(patrolPos.PauseTimeMin, patrolPos.PauseTimeMax)  );
                WaitForNotification();
            }
            patrolPos = patrolPos.nextPosition;
        }
    }
    //patrolPos
}

//================
// Attitude States
//================

state Relax
{
    function GOTO_Relax() {} //Only ask for "Idle" order once.

    function BeginState() {}

    function SelectBehaviour()
    {
        if( bot.Enemy != None )
            GOTO_Attack();
    }

    function PerformBehaviour()
    {
        Notify();
    }

	function OnEnemyAcquired()
	{
       GOTO_Attack();
	}

BEGIN: 
    curLabel = '';
    bot.Perform_NotEngaged_Wander();    WaitForNotification();
    while(true) {
RELAX:
        bot.Perform_NotEngaged_AtRest(5.0);    WaitForNotification();
WANDER:
        bot.Perform_NotEngaged_Wander();    WaitForNotification();
    }
}

state DefaultAttack
{
    function BeginState()
    {}

    function SelectBehaviour()
    {
    }

    function PerformBehaviour()
    {
        Notify();
    }

BEGIN:
    while(true)
    {
        bot.Perform_Engaged_StandGround();   WaitForNotification();
    }
}


///////////////////////////////////////
///////////////////////////////////////

state Panic
{
    function SelectBehaviour() {}

    function PerformBehaviour() {
        Notify();
    }

    function OnLostSight() {
        SetTimer(2.0, false);
    }
    
    function Timer()
    {
        GOTO_Attack();
    }

BEGIN:
    curLabel = '';
    while(true) {
        bot.Perform_Engaged_Panic();  WaitForNotification();  
    }
}

//========
// Helpers
//========

function float contactPct()
{
    if( bot.currentStage != None ) {
        return bot.currentStage.Request_PercentEyeSighted( bot );
    }
    else return 0;
}

function float contactNum()
{
    if( bot.currentStage != None ) {
        return (bot.currentStage.StageAgents.Length - 1) 
                  * bot.currentStage.Request_PercentEyeSighted( bot );
    }
    else return 0;
}

/**
 * Handy debugging helper.
 */
function DebugLog( coerce String s, optional name tag ) {
   if ( bDebugLogging ) Log( self @ s, 'VGSPAIController' );
}

defaultproperties
{
     pctHealth=0.500000
     fOddsOfPanic=0.500000
     Texture=Texture'VGSPAI.AIRoleIcon'
     bHidden=True
}
