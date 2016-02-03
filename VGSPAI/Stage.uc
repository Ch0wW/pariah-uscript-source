/**
 * Stage - the base class for the entities that control the AI
 * opponents in an area.
 *
 * @version $Revision: 1.70 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @author  Jesse LaChapelle (Dec 2003)
 * @date    June 2003
 */
class Stage extends Actor
   abstract
   exportstructs
   native;


//=====================
// Editable properties
//=====================

//IF there is no stage specified, this is the script that agents will
//perform if the stage succeeds.
var() Name OnSuccessScriptTag;
// the name used to refer to this stage
var() Name  StageName;
// stage to send agents to if this stage succeeds
var() Name  OnSuccessStageName;
// stage to send agents to if this stage fails.
var() Name  OnFailStageName;
// output extra debugging info to the log
var() bool  bDebugLogging;
// how often the stage polls for state changes
var() const int STAGE_CHECK_INTERVAL;
// distance of the player in UU from this actor that the stage remains active
var() int   ActiveRange;
// Don't go back to sleep once you're turned on
var() bool  bTriggerOnStayOn;
// Hibernate and Wake up based on an associated volume
var() bool  bVolumeActive;
// seconds between fail/success happening, and this stage
// restarting. -1 for never restart (stay failed/successful).
var() int   ResetDelay;
// The Stage has innate knowledge of the player as an enemy
var() bool  bRushPlayer;

// events this actor generates...
//
// when the patrol spots an enemy
var(Events) Name OnEnemySpottedEvent;   //@@@ patrol?
// the stage has met it's success criteria
var(Events) Name OnSuccessEvent;
// the stage has met it's failure criteria
var(Events) Name OnFailEvent;
// the stage is doing it's primary function (defending, patrolling, etc)
var(Events) Name OnEngageEvent;

// event handlers this actor exposes
//
// trigger success of this stage
var(Events) const editconst Name hSucceed;
// trigger failure of this stage
var(Events) const editconst Name hFail;
// put this stage into hibernation
var(Events) const editconst Name hHibernate;
// wake this stage from hibernation
var(Events) const editconst Name hAwaken;
// trigger this stage to engage
var(Events) const editconst Name hEngage;
// trigger this stage to start (again)
var(Events) const editconst Name hRestart;
// trigger this stage to awaken (and stay awake)
var(Events) const editconst Name hTriggerOn;
// trigger this with the instigator set to an enemy
// to alarm the stage
var(Events) const editconst Name hAlarm;



//===============
// Internal data
//===============
//store the largest clocked time for a stagepos update
var float debugUpdateStagePosProfileTime;

var StageManager theStageManager;
var Array<StagePosition> StagePositions;
var float EncompassingRadius;
var int stagePositionLOSIdx;
var int enemyLOSIdx;
var int TouchingPlayers;

struct AgentData
{
	var VGSPAIController controller;
	var bool		isUnderFire;
	var bool		isWounded;
	var bool		isInPosition;
	var bool		isEyeSighted;
};

var Array<AgentData>        StageAgents;
var Array<VGSPAIController> TakenAgents;
var Array<OpponentFactory>  Factories;
var UnrealScriptedSequence OnSuccessScript;
var Stage OnSuccessStage;
var Stage OnFailStage;
var bool  bHibernating;
var Name  lastState;
var private bool bSucceeded;
var private bool bFailed;

var const int UPDATE_STAGEPOS_TIMER;
var const int STAGE_CHECK_TIMER;
var const int STAGE_RESET_TIMER;
var const int DEBUG_RANGE;

const MAXENEMY = 8;
var Pawn Enemies[MAXENEMY];
//used by exclaim mgrs so bots don't trample over each others speech
var float LastExclaimTime[12];  

var const int FEARDECAY_TIMER;
const FEARDECAYRATE = 0.75;

//Listen for this startup event
var Name playerSpawnedEventName;

var Array<VGSPAIController> StageDrones; //cmr for hibernation

//=============================
// Controller->Stage interface
//=============================

enum EReason {
    RSN_Died,
    RSN_Fled,
    RSN_Scripted,
    RSN_JoinedOtherStage
};

event String SuggestedGroup()
{
    return String(StageName);
}


function AddStageDrone( VGSPAIController d )
{
	local int i;
	//check if empty slot (or drone already in list)
	for(i=0;i<StageDrones.Length;i++)
	{
		if(StageDrones[i]==None || StageDrones[i]==d)
		{
			StageDrones[i] = d;
			return;
		}
		
	}

	//else it wasn't there or space, grow and add
	StageDrones[StageDrones.Length] = d;

	if(bHibernating)
		d.StageOrder_Hibernate();
}

/**
 * called by a (pawn's) controller when it joins the stage
 */
function joinStage( VGSPAIController c ) {
    local int i;
    DebugLog( "Agent" @ c @ "joining stage" );
    // could check to prevent duplicates here...
    i = StageAgents.length;
    StageAgents.length = i + 1;
    StageAgents[i].controller = c;
    c.StageOrder_JoinStage(self);
    findNewEnemyFor(c);
    if ( bHibernating ) {  
        c.StageOrder_Hibernate();
    }
    
    //@@@  Q: Should LD be responsible for making sure guys don't join sleeping stages?
    //@@@  Q2: Would this really help anyhow? Since the stage manager could presumably put it
    //@@@       right back to sleep?
    // make sure we're awake if agents are joining the stage.
    // awaken();
}

/**
 * called when a controller is no longer participating in the stage.
 */
function leaveStage( VGSPAIController c, EReason r ) {
    local int i;
    DebugLog( "Agent" @ c @ "leaving stage, reason" @ r );
    i = findAgentIndex( c );
    if ( i >= 0 ) StageAgents.remove( i, 1 );
    
    // don't sleep... since we won't wake you when new guys join.
    /*
    if ( StageAgents.length < 1 ) {
        // last agent left, might as well go to sleep.
        hibernate();
    }
    */
}

/**
 * If a bot find himself with nothing to do, request an order from the stage
 **/
function Request_IdleOrder(VGSPAIController c)
{
}

/**
 * returns a node that provides Line of Sight to target
 **/
function StagePosition Request_ShootingPosition(VGSPAIController c)
{
    return bestShootPositionAccordingToBot(c);
    //return closestShootPosition(false, c, c.Pawn.Location);
}


/**
 * returns a node that does not have Line of Sight from target
 **/
function StagePosition Request_CoverPosition(VGSPAIController c)
{
    return closestCoverPosition( c, c.Pawn.Location );
}

/**
 * called when the controller has moved it's pawn to a position
 * specified by this stage with StageOrder_TakeUpPosition().
 */
function Report_InPosition( VGSPAIController c, StagePosition pos );

/**
 * Alert other agents of bogie
 **/
function Report_EnemySpotted( Pawn NewEnemy )
{
    //local int i;
    
    if( AddEnemy(NewEnemy) )
    {
        /*
        for(i=0; i<StageAgents.length; i++)
        {
            findNewEnemyFor(StageAgents[i].controller);
        }
        */
        DebugLog( "Triggering Spotted Event:"@OnEnemySpottedEvent);   
        triggerEvent( OnEnemySpottedEvent, self, None );
    }
}

/**
 * Bot has lost contact with enemy for some time
 * Give him a new enemy, and remove enemy from list if noone else sees it
 **/
function bool Report_EnemyLost( VGSPAIController c, float time )
{
    local pawn Lost;
    local bool bFound;
    local int i;
    local VGSPAIController bot;
    
    Lost = c.Enemy;
    c.Enemy = None;
    
    for( i=0; i<StageAgents.length; i++ )
    {
        bot = StageAgents[i].controller;
        if ( (bot.Enemy == Lost) && !bot.LostContact(time) )
        {
            bFound = true;
            break;
        }
    }

    if ( bFound ) {
        c.Enemy = Lost;
        c.Focus = Lost;
    }
    else
    {
        RemoveEnemy(Lost);
        //FindNewEnemyFor(c);
    }
    return (c.Enemy != Lost);
}

/**
 */
function Report_Killed( VGSPAIController c,  Pawn enemy)
{
    RemoveEnemy(enemy);
}

/**
 * The controller has LOS to enemy
 **/
function Report_EyeSighted( VGSPAIController c, Pawn enemy)
{
    StageAgents[findAgentIndex(c)].isEyeSighted = true;
}

/**
 * The controller does not have LOS to enemy
 **/
function Report_UnSighted( VGSPAIController c, Pawn enemy)
{
    StageAgents[findAgentIndex(c)].isEyeSighted = false;
}

/**
 * what percentage of bots in this squad can see the enemy (excluding me)
 * (at least some bots should be engaged all the time)
 **/
function float Request_PercentEyeSighted( VGSPAIController c )
{
    local int i, accumulator;
    
    if(StageAgents.length ==0)
    {
        log("ERROR:"@c@"Thinks he's part of stage"@self);
        return 0;
    }
    for ( i=0; i<StageAgents.length; i++ )
    {
        if( StageAgents[i].isEyeSighted && StageAgents[i].controller != c) {
            accumulator++;
        }
    }
    return  float(accumulator) / float(StageAgents.length);
}

/**
 */
function Report_TargetDestroyed( VGSPAIController c, Actor target ) {
    c.StageOrder_HoldPosition();
}

/**
 */
function Report_Covered( VGSPAIController c );

/**
 */
function Report_Exposed( VGSPAIController c );

// some other possible report functions...
function Report_UnderAttack( VGSPAIController c );
function Report_EnemyInRange( VGSPAIController c );


//=========================
// Factory->Stage interface
//=========================

function registerFactory(OpponentFactory factory)
{
    local int i;
    DebugLog( "Factory" @ factory @ "registered" );
    i = Factories.length;
    Factories.length = i + 1;
    Factories[i] = factory;
}


//=======================
// Stage framework hooks
//=======================


function AddAvoid(vector fearLocation, float fearRadius)
{
    local int i;
    local StagePosition pos;

    if( VSize2D(fearLocation - Location) > EncompassingRadius )
        return;

    for ( i = 0; i < stagePositions.length; ++i )
    {
        pos = stagePositions[i];
        if( VSize2D(pos.Location - fearLocation) < fearRadius )
        {   
            pos.AvoidCount++;
        }
    }
}

function RemoveAvoid(vector fearLocation, float fearRadius)
{
    local int i;
    local StagePosition pos;

    if( VSize2D(fearLocation - Location) > EncompassingRadius )
        return;

    for ( i = 0; i < stagePositions.length; ++i )
    {
        pos = stagePositions[i];
        if( VSize2D(pos.Location - fearLocation) < fearRadius )
        {   
            pos.AvoidCount--;
        }
    }
}

/**
 * override to decide which controllers could be offered to another
 * stage.
 */
function Array<VGSPAIController> getAvailableAgents() {
    local Array<VGSPAIController> c;
    local int i;
    c.length = StageAgents.length;
    for ( i = 0; i < StageAgents.length; ++i ) {
        c[i] = StageAgents[i].controller;
    }
    DebugLog( "default getAvailableAgents: offering" @ c.length @ "agents" );
    return c;
}

/**
 * override to decide if the stage's success conditions have been
 * met.
 */
function bool checkStageSuccess() {
    return false;
}

/**
 * override to decide if the stage's failure conditions have been
 * met.
 */
function bool checkStageFailure() {
    return false;
}

/**
 * call to (re)initialize the stage
 */
function initStage() {
    DebugLog( "(re)initializing" );
    bSucceeded = false;
    bFailed    = false;
    SetMultiTimer( STAGE_CHECK_TIMER, STAGE_CHECK_INTERVAL, true );
	SetMultiTimer( FEARDECAY_TIMER, 1.0, true );
    SetMultiTimer( UPDATE_STAGEPOS_TIMER, 0.1 + FRand()*0.2, false );
    // regenerate StageSpot list?
    // remove agents from the stage?
}

/**
 * Output handy real-time info all over the screen.  Subclasses will
 * need to call this in a codebase-specific way to view the output
 * (e.g. make your HUD class aware of stages).
 */
function drawDebugInfo( Canvas c ) {
    local int i,j;
    local vector screenPos;
   
    for ( i = 0; i < stagePositions.length; ++i ) {
        if (  VSize( Level.GetLocalPlayerController().pawn.location 
                     - stagePositions[i].location ) > DEBUG_RANGE ) continue;
        screenPos = WorldToScreen( stagePositions[i].location );
        // don't show actors that are between the camera and the viewplane...
        if ( screenPos.z > 1.0 ) continue;

        // output the name
        c.SetPos( screenPos.x, screenPos.y );
        c.DrawText( stagePositions[i].name );
        // output the cover bit-vector (if applicable)
        if ( stagePositions[i].CoverType != CA_None ) {
            for ( j = 7; j >= 0; --j ) {
                c.SetPos( screenPos.x - (j * 10) + 70, screenPos.y - 16 );
                c.DrawText( (stagePositions[i].coverValid & (0x01 << j)) );
            }
        }
    }
}


//=======================
// Inter-Stage interface
//=======================

/**
 * Called to offer this stage a set of agents.  Return any controllers
 * that were accepted by this stage.
 *
 * Accept all the help we can get.
 */
function Array<VGSPAIController> takeControl( Array<VGSPAIController> controllers ) {
    local int i;
    for ( i = 0; i < controllers.length; ++i ) {
        joinStage( controllers[i] );
    }
    return controllers;
}


//================
// Implementation
//================

/**
 * Set off by some external trigger, alert all the bots.
 **/
function Alarm(Pawn instigator)
{
    local int i;
    local Controller c;

    if(instigator == None)
    {
		for( c=Level.ControllerList; c!=None; c=c.NextController )
		{
			if(c.Pawn != None && c.IsA('SinglePlayerController'))
			{
				AddEnemy(instigator);
				for(i=0; i<StageAgents.length; i++)
				{
					StageAgents[i].controller.StageOrder_AlertNewEnemy(c.Pawn, false);
				}  
			}
		}
	}
	else
	{
		AddEnemy(instigator);
		for(i=0; i<StageAgents.length; i++)
		{
			StageAgents[i].controller.StageOrder_AlertNewEnemy(instigator, false);
		}  
	}
}

/**
 * Called if associated with a volume.
 **/
event Touch(Actor Other)
{
    local pawn P;

    P = Pawn(Other);
    if ( (P == None) || !P.Controller.IsA('SinglePlayerController') ) {
        return;
    }
    TouchingPlayers++;
    awaken();
}

/**
 */
event UnTouch(Actor Other)
{
    local pawn P;

    P = Pawn(Other);
    if ( (P == None) || !P.Controller.IsA('SinglePlayerController') ) {
        return;
    }
    
    TouchingPlayers--;
    
    if(TouchingPlayers == 0)
    {
		hibernate();
	}
}

/**
 */
function TryUpdateStagePositions()
{
    local float time;
    
    clock(time);
    if ( !bHibernating && StageAgents.length > 0 ) tickStagePositions();
    unclock(time);
    
    if(time > debugUpdateStagePosProfileTime)
        debugUpdateStagePosProfileTime = time;

    SetMultiTimer( UPDATE_STAGEPOS_TIMER, FRand()*0.1, false );
}

/*
function Tick(float dT)
{
    Super.Tick(dT);
    TryUpdateStagePositions();
}
*/

/**
 */
function PreBeginPlay() {
    local StageManager sm;
    local int count;
    local StagePosition s;
    local Stage current;
    local int numPositions;
    local UnrealScriptedSequence curSequence;
    local float distance;
    
    Super.PreBeginPlay();
    if(!bVolumeActive && !bTriggerOnStayOn)
    {
        count = 0;
        ForEach AllActors( class'StageManager', sm ) {
            ++count;
            theStageManager = sm;
        }
        assert( count <= 1 );
        if ( theStageManager != None ) theStageManager.registerStage( self );
    }

    numPositions = 0;
    ForEach AllActors( class'StagePosition', s ) {
        if ( s.stage == StageName ) {
            StagePositions[numPositions++] = s;
            distance = VSize2D(s.Location - Location);
            if(distance > EncompassingRadius)
                EncompassingRadius = distance;
        }
    }
    DebugLog( "Found " $ StagePositions.length $ " StagePositions in "
              $ StageName );
   
    ForEach AllActors( class'Stage', current ) {
        if ( current.StageName != '' && 
             current.StageName == OnSuccessStageName ) {
            onSuccessStage = current;
        }
        else if ( current.StageName == OnFailStageName ) {
            onFailStage = current;
            if ( OnFailStage == self) {
                warn(self@" Has OnFailStage set to itself.");
            }
        }
    }

    //assign a script for successful completion
    ForEach AllActors( class'UnrealScriptedSequence', curSequence ) {
        if ( curSequence.Tag == OnSuccessScriptTag ) {
            onSuccessScript = curSequence;
        }
    }

    NodeOnGroundChecks();

    //Make sure we listen for startevent
    EventBindings.Length = EventBindings.Length + 1;
        EventBindings[EventBindings.Length-1].EventName = playerSpawnedEventName;
        EventBindings[EventBindings.Length-1].HandledBy = playerSpawnedEventName;

}

//@@@ OUCH.. the nodes should be placed a predetermined distance
//@@@ above the ground during a level rebuild... I do it once here
//@@@ and cache it... 
function NodeOnGroundChecks()
{
    local int i;
    for( i = 0; i < StagePositions.Length; i++ )
    {
        NodeOnGroundCheck(StagePositions[i]);
    }
}    

function NodeOnGroundCheck(StagePosition node)
{
    local actor HitActor;
    local vector HitLocation, HitNormal;
    
    HitActor = Trace(HitLocation, HitNormal, 
                         node.Location - vect(0,0,200), node.Location, false);
    if(HitActor == None)
        warn(node@"Is too far off ground");
    else
        node.OnGroundZ = HitLocation.Z;
}

/**
 */
function PostBeginPlay() {
    Super.PostBeginPlay();
    
    if ( bVolumeActive || bTriggerOnStayOn ) 
    {
        hibernate();
    }
    else
    {
        if ( theStageManager != None ) theStageManager.registerStage( self );
    }
}

/**
 */
event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) {
    DebugLog( "TriggerEx(" @ sender @ instigator @ handler @ realevent @")" );

    if(realevent == playerSpawnedEventName )
        handleStartEvent();

    switch ( handler ) {
        
    case hEngage:
        GotoState( 'Engaged' );
        break;

    case hRestart:
        GotoState( 'Init' );
        break;

    case hSucceed:
        //@@@ possibly there should be some logic to ensure that
        //@@@ bFailed isn't also true...
        bSucceeded = true;
        break;

    case hFail:
        bFailed = true;
        break;

    case hHibernate:
        hibernate();
        break;

    case hAwaken:
        awaken();
        break;

    case hAlarm:
        Alarm( instigator );

    default:
        DebugLog( "Unknown handler [" $ handler $ "]" );
        break;
    }
}

/**
 * called when the level starts up, and the player is spawned
 **/
function handleStartEvent()
{
	local Controller c;
    if( bRushPlayer )
    {
		for( c=Level.ControllerList; c!=None; c=c.NextController )
		{
			if(c.Pawn != None && c.IsA('SinglePlayerController'))
			{
				AddEnemy(c.Pawn);
			}
		}
	}
}


/**
 * called to put the stage into a dormant (minimal performance hit)
 * mode, no-op if already hibernating.
 */
function hibernate() {
   local int i;
   // suggest that the agents sleep...
   for ( i = 0; i < StageAgents.length; ++i ) {
      StageAgents[i].controller.StageOrder_Hibernate();
   }
   // tell those pissy ass drones to stfu
   for ( i = 0; i < StageDrones.length; ++i )
   {
	   if(StageDrones[i] != None)
		StageDrones[i].StageOrder_Hibernate();
   }
   // suggest that the factories sleep...
   for ( i = 0; i < Factories.length; ++i ) {
      Factories[i].hibernate();
   }
   // put the stage itself to sleep...
   if ( bHibernating ) return;
   DebugLog( "Hibernating" );
   bHibernating = true;
   lastState    = GetStateName();
   GotoState( 'Dormant' );
}

/**
 * called to undo hibernate(), no-op if not hibernating.
 */
function awaken() {
   local int i;
   if ( !bHibernating ) return;
   DebugLog( "Awakening" );
   bHibernating = false;
   GotoState( lastState );

   // wake up the agents...
   for ( i = 0; i < StageAgents.length; ++i ) {
      StageAgents[i].controller.StageOrder_Awaken();
   }
   // wake up factories
   for ( i = 0; i < Factories.length; ++i ) {
      Factories[i].awaken();
   }   

   // wake up drones
   for ( i = 0; i < StageDrones.length; ++i )
   {
	   if(StageDrones[i] != None)
		StageDrones[i].StageOrder_Awaken();
   }

}

/**
 */
event MultiTimer( int timerID ) {
    //@@@ maybe this can be purely event driven?
    DebugLog( "Engaged::Stage.MultiTimer(" @ timerID @ ")" );
    if ( timerID == UPDATE_STAGEPOS_TIMER )
    {
        TryUpdateStagePositions();
    }
    else if ( timerID == STAGE_CHECK_TIMER ) {
        if ( isSuccessful() ) GotoState( 'Succeeded' );
        else if ( isFailed() ) GotoState( 'Failed' );
    }
    else if ( timerID == STAGE_RESET_TIMER ) {
        GotoState( 'Init' );
    }
	else if ( timerID == FEARDECAY_TIMER ) {
		FearDecay();
	}
    // unrecognized timer ID
    else {
        super.MultiTimer( timerID );
    }
}

// State: Init - stage may not be ready to engage player yet
// ---------------------------------------------------------
auto state Init {

    /**
     * make sure to call initStage()!
     */
    function BeginState() {
        initStage();
    }

BEGIN:
   // some stages may wish to defer this until other conditions are met...
   GotoState( 'Engaged');
}


// State: Engaged - stage is engaged with, or ready to engage the player
// ---------------------------------------------------------------------
state Engaged {
    /**
     *
     */
    function BeginState() {
        DebugLog( "Stage::Engaged state" );
        TriggerEvent( OnEngageEvent, self, None );
    }
   
} // end state Engaged


// State: Succeeded - stage has met it's success conditions
// --------------------------------------------------------
state Succeeded {
    /**
     */
    function BeginState() {

       local int i;

        // handle linking to another stage...
        if ( OnSuccessStage == None ) {
            DebugLog( "No linked stage for success of " $ self );
            for (i = 0; i < stageAgents.length; i++){
               PutOntoScript(stageAgents[i].Controller);
               StageAgents.remove( i, 1 );
               --i; // ugly, but necessary since the array just shrank
            }
        }
        else {
            DebugLog( "Transitioning to success stage" );
            TakenAgents = OnSuccessStage.TakeControl( getAvailableAgents() );
            removeTakenAgents( TakenAgents );
            OnSuccessStage.GotoState( 'Init' );
        }
        // generic success stuff...
        TriggerEvent( OnSuccessEvent, self, none );
        SetMultiTimer( STAGE_CHECK_TIMER, 0, false );
        if ( ResetDelay == 0 ) GotoState( 'Init' );
        else if ( ResetDelay > 0 ) {
            SetMultiTimer( STAGE_RESET_TIMER, ResetDelay, false );
        }
    }
   
    /**
     * Pass on any new agents to the next stage.
     */
    function joinStage( VGSPAIController c ) {
        if ( OnSuccessStage != None ){
              OnSuccessStage.joinStage( c );
        } else {
           PutOntoScript(c);
        }
    }

    /**
     * Pass on any new agents to the script.
     */
    function PutOntoScript(VGSPAIController C){

       //go back to your old script 
       if (OnSuccessScript == None){
          C.currentStage = None;
          C.curStageOrder = SO_None;
          C.ActionNum++ ;
          C.GoalScript = C.OldGoalScript;
          C.GotoState('Scripting');  
          } 
       //or go to a new script
       else {  
          C.currentStage = None;
          C.curStageOrder = SO_None;
          C.ActionNum = 0;
          C.SetNewScript( OnSuccessScript);
          C.GotoState('Scripting');  
       }
    }

} // end state Succeeded


// State: Failed - stage has met it's failure conditions
// -----------------------------------------------------
state Failed {

    /**
     */
    function BeginState() {
        // handle linking to another stage...
        if ( OnFailStage == None ) {
            DebugLog( "No linked stage for failure of " $ self );
        }
        else {
            DebugLog( "Transitioning to failed stage" );
            TakenAgents = OnFailStage.TakeControl( getAvailableAgents() );
            removeTakenAgents( TakenAgents );
            OnFailStage.GotoState( 'Init' );
        }
        // generic success stuff...
        TriggerEvent( OnFailEvent, self, none );
        SetMultiTimer( STAGE_CHECK_TIMER, 0, false );
        if ( ResetDelay == 0 ) GotoState( 'Init' );
        else if ( ResetDelay > 0 ) {
            SetMultiTimer( STAGE_RESET_TIMER, ResetDelay, false );
        }
    }

} // end state Failed


// State: Dormant - stage is doing nothing
// ---------------------------------------
state Dormant {
   ignores Tick;

   /**
    */
   function BeginState() {
       // cancel timer
       SetMultiTimer( STAGE_CHECK_TIMER, 0, false );
       SetMultiTimer( UPDATE_STAGEPOS_TIMER, 0, false );
   }
   function EndState() {
        SetMultiTimer( UPDATE_STAGEPOS_TIMER, 0.1, false );
   }

} // end state Dormant


//=================
// Various helpers
//=================


static final function float VSize2D(vector A)
{
	return sqrt(A.X*A.X + A.Y*A.Y);
}

/**
 * When bots die, they add Fear to the position.
 * this gets called occasionally to decay it.
 **/
function FearDecay()
{
	local int i;
	for ( i = 0; i<StagePositions.Length; i++)
		StagePositions[i].FearCost *= FEARDECAYRATE;
}

/**
 * Just wraps up the foofoorah req'd to get project w onto screen space.
 */
function vector WorldToScreen( vector w ) {
    return Level.GetLocalPlayerController().player.console.WorldToScreen( w );
}

/**
 */
function final bool isSuccessful() {
    // success determined by a trigger...
    if ( bSucceeded ) return true;
    // otherwise defer to subclasses to decide.
    else return checkStageSuccess();
}

/**
 * maybe isDefeated would be better, but not consistent with our
 * terminology
 */
function final bool isFailed() {
    // failure determined by a trigger...
    if ( bFailed ) return true;
    // otherwise defer to subclasses to decide.
    return checkStageFailure();
}


/**
 *  idx is set to the index of the next valid enemy in the list
 *      or left as is if no next value found
 *  true is returned if a new index is found that required looping back 
 *      to the beginning of the list of if idx remained unchanged
 *
 **/
function bool nextEnemyIdx(out int idx, StagePosition node)
{
    local int i;
   
    for(i=idx+1; i<MAXENEMY; i++)
    {
        if(Enemies[i] != None)
        {
            idx = i;
            return false;
        }
		else
		{
			node.StandLOF = node.StandLOF &  (~(0x1 << i));
			node.CrouchLOF = node.CrouchLOF &  (~(0x1 << i));
			node.CoverValid = node.CoverValid | (0x1 << i);		
            node.HidingValid = node.HidingValid | (0x1 << i);		
		}
    }
    for(i=0; i<idx+1; i++)
    {
        if(Enemies[i] != None)
        {
            idx = i;
            return true;
        }
		else
		{
			node.StandLOF = node.StandLOF & (~(0x1 << i));
			node.CrouchLOF = node.CrouchLOF & (~(0x1 << i));
			node.CoverValid = node.CoverValid | (0x1 << i);
            node.HidingValid = node.HidingValid | (0x1 << i);		
		}
    }
    return true;
}

/**
 * Update one stagenode each tick to reflect whether it has LOS to player. 
 **/
function tickStagePositions()
{
    local StagePosition node;

    if ( stagePositionLOSIdx < 0 
               || stagePositionLOSIdx >= StagePositions.Length ) {
        return;
    }
	
	node = StagePositions[stagePositionLOSIdx];
    
    //update the stage position for a single enemy    		
    if(Enemies[enemyLOSIdx] != None)
		node.UpdateStatus(enemyLOSIdx, Enemies[enemyLOSIdx]);

    if( nextEnemyIdx(enemyLOSIdx, node) )
    {
        //nextEnemyIdx returns true if we've been through the entire enemy list
        // so we're free to finish this stagePosition

        updateProperDistanceToBuddies(node);
        updateProjDistToBuddiesAsSeenFromThreat(node);
        stagePositionLOSIdx++;
        if(stagePositionLOSIdx == StagePositions.Length)
            stagePositionLOSIdx = 0;
    }
}

/**
 */
function updateProjDistToBuddiesAsSeenFromThreat(StagePosition node)
{
    local float returnVal;
    local int i;
    local vector enemyRight;
    //local Pawn Threat;
    
    if( StageAgents.Length == 0 ) return;
    
    if ( NumEnemies() <= 0 ) {
		node.fProjDistToBuddies = 1.0;
		return;
	}
    enemyRight = vect(0,1,0) >> AverageEnemyDir();

    for ( i=0; i< StageAgents.Length; i++ )
    {
       if (StageAgents[i].Controller !=None &&
           StageAgents[i].Controller.Pawn != None){
            returnVal += 
            abs( (StageAgents[i].controller.Pawn.Location - node.Location) 
                    dot enemyRight );
       }
    }

	node.fProjDistToBuddies = returnVal;
}

/**
 */
function updateProperDistanceToBuddies(StagePosition node)
{
    local float returnVal;
    local int i;
    
    if ( StageAgents.Length == 0 || node == None ) return;

    for ( i=0; i < StageAgents.Length; i++ )
    {
        if ( StageAgents[i].Controller != None 
             && StageAgents[i].Controller.Pawn != None ) {
            returnVal += 
                VSize(StageAgents[i].controller.Pawn.Location - node.Location);
       }
    }
	node.fDistToBuddies = returnVal;
}

/**
 */
function float calculateStagePosnBlocksLOS( VGSPAIController c, 
                                                StagePosition node )
{
    local int i;
    local VGSPAIController buddy;
    local vector buddyLOF, nodeDir;
    local float dotP, cosConeAngle;
    local float numLOFBlocked;

    for ( i = 0; i < StageAgents.length; ++i )
    {
        buddy = StageAgents[i].controller;
        if( (c == buddy) || (buddy.Enemy == None) ) continue;
        
        if( buddy.claimedPosition == None 
               || buddy.claimedPosition == buddy.Pawn.Anchor )
        {
            buddyLOF = buddy.Enemy.Location - buddy.Pawn.Location;
            nodeDir = node.Location - buddy.Pawn.Location;
        }
        else
    {   
            buddyLOF = buddy.Enemy.Location - buddy.claimedPosition.Location 
                + vect(0,0,1) * ( buddy.Pawn.Location.Z 
                                     - buddy.claimedPosition.Location.Z );
            nodeDir = node.Location - buddy.claimedPosition.Location 
                + vect(0,0,1) * ( buddy.Pawn.Location.Z 
                                     - buddy.claimedPosition.Location.Z );
        }

        dotP = Normal(buddyLOF) dot Normal(nodeDir);
        dotP = aCos(dotP);
        dotP = dotP - atan(buddy.Pawn.CollisionRadius, VSize(nodeDir));
        dotP = cos(dotP);
        cosConeAngle = cos( atan( buddy.Enemy.CollisionRadius*3.0, 
                                  VSize(buddyLOF) ) );
        
        //how "in the way" is it
        if( (dotP < cosConeAngle) || (VSize(nodeDir) > VSize(buddyLOF)) ) {
            continue;
        }   
        numLOFBlocked += 1;
    }
    return numLOFBlocked;
}

/**
 */
function float calculateStagePosnLOSIsBlocked( VGSPAIController c, 
                                                   StagePosition node )
{
    local int i;
    local VGSPAIController buddy;
    local vector buddyDir, nodeLOF;
    local float dotP, cosConeAngle;
    local float numLOFBlocked;

    for ( i = 0; i < StageAgents.length; ++i )
    {
        buddy = StageAgents[i].controller;
        if( c == buddy ) continue;
        if( buddy.claimedPosition == None 
               || buddy.claimedPosition == buddy.Pawn.Anchor ) {
            buddyDir = buddy.Pawn.Location - node.Location;
        }
        else {
            buddyDir = buddy.claimedPosition.Location - node.Location;
        }
        
        nodeLOF = c.Enemy.Location - node.Location; 
        cosConeAngle = cos(atan(c.Enemy.CollisionRadius*3.0, VSize(nodeLOF)));
        dotP = Normal(buddyDir) dot Normal(nodeLOF);
        
        dotP = aCos(dotP);
        dotP = dotP - atan(buddy.Pawn.CollisionRadius, VSize(buddyDir));
        dotP = cos(dotP);
        
        //how "in the way" is my buddy
        if( (dotP < cosConeAngle) || (VSize(buddyDir) > VSize(nodeLOF)) ) {
            continue;
        }       
        numLOFBlocked += 1;
    }
    return numLOFBlocked;
}

/**
 * Returns true if there is a Line of Fire to the enemy, either Standing or Crouching 
 */
function bool PositionHasLOFToEnemy(StagePosition node, Pawn Enemy)
{
    local int idx;
    
    if(node == None)
    {
		return(false);
    }
    
    idx = GetEnemyIndex(Enemy);
    if(idx < 0 )
        return false;

    if ( ((node.StandLOF & (0x1 << idx)) != 0 ) ||
            ((node.CrouchLOF & (0x1 << idx)) != 0) ){
        return true;
    }
    
    return false;
}

function bool PositionHasCrouchLOFToEnemy(StagePosition node, Pawn Enemy)
{
    local int idx;
    
    idx = GetEnemyIndex(Enemy);
    if(idx < 0 )
        return false;

    if ( (node.CrouchLOF & (0x1 << idx)) != 0 ){
        return true;
    }
    
    return false;
}



/**
 * Returns true if this node would hide you from the enemies LOF 
 */
function bool PositionProvidesHidingFromEnemy(StagePosition node, optional Pawn Enemy)
{
    local int idx;
    
    if(Enemy == None) {
		return ( node.HidingValid == 0xFF );
	}

    idx = GetEnemyIndex(Enemy);
    if ( (node.HidingValid & (0x1 << idx)) != 0 )
        return true;
    
    return false;

}


/**        
 * if Enemy is NONE or not provided, the cover is checked for ALL known enemies
 * returns:
 *  2 if it meets LD-specified cover
 *  1 if it is not LD-specified, but has no shot from crouch yet has one from standing
 *  0 if neither of the above cases (it appears wide open)
 **/
function int PositionProvidesCoverFromEnemy( StagePosition node, 
                                             optional Pawn Enemy )
{
    local int idx;
    
    if ( node == None ) return 0;

	if( node.CoverType != CA_None) { // may provide LD specified  cover
		if(Enemy == None) {
			if(	node.CoverValid == 0xFF)
				return 2;
		}
		else {
			idx = GetEnemyIndex(Enemy);
			if ( (node.CoverValid & (0x1 << idx)) != 0 )
				return 2;
		}
	}
	else { // assume cover means no shots from here, since LD didn't specify
		if(Enemy == None) {
			if( node.StandLOF == 0xFF && node.CrouchLOF == 0)
				return 1;
		}
		else {
			idx = GetEnemyIndex(Enemy);
			if ( ((node.StandLOF & (0x1 << idx)) == 1 ) &&
				((node.CrouchLOF & (0x1 << idx)) == 0) )
				return 1;
		}
	}
    return 0;
}

/**
 */
function StagePosition bestShootPositionAccordingToBot( VGSPAIController c)
{
    local int i;
    local StagePosition bestPosition;
    local float tmpVal, bestVal;
   
    for( i = 0; i < StagePositions.Length; i++ )
    {
        if( StagePositions[i].bIsClaimed 
               || !c.VerifyShootingPosition(StagePositions[i]) 
               || !PositionHasLOFToEnemy(StagePositions[i], C.Enemy) ) {
            continue;
        }

        tmpVal = c.WeightStagePosition(StagePositions[i]);
        if( tmpVal > bestVal )
        {
            bestPosition = StagePositions[i];
            bestVal = tmpVal;
        }
    }
    return bestPosition;
}

/**
 */
function StagePosition closestShootPosition( VGSPAIController c, 
                                             vector Location, 
                                             optional float rangeLimit)
{
    local int i;
    local StagePosition bestPosition;
    local float tmpDist, bestPositionDist;
   
    for( i = 0; i < StagePositions.Length; i++ )
    {
        tmpDist = VSize(Location - StagePositions[i].Location);      
        if( bestPosition == None || tmpDist < bestPositionDist )
        {
            if( PositionHasLOFToEnemy(StagePositions[i], C.Enemy) 
                   && !StagePositions[i].bIsClaimed 
                   && c.VerifyShootingPosition(StagePositions[i]) 
                   && calculateStagePosnLOSIsBlocked(c,StagePositions[i]) == 0 
                   && calculateStagePosnBlocksLOS(c,StagePositions[i]) == 0 )
            {
                bestPosition = StagePositions[i];
                bestPositionDist = tmpDist;
            }
        }
    }
    // if the closest node is out of range, forget it.
    if ( (rangeLimit > 0) && (bestPositionDist > rangeLimit) ) {
        return None;
    }
    return bestPosition;
}

function StagePosition closestCoverPosition(VGSPAIController c, vector Location,
                                           optional float rangeLimit)
{
    local int i;
    local StagePosition bestPosition;
    local float tmpDist, bestPositionDist;
   
    for( i = 0; i < StagePositions.Length; i++ )
    {
        tmpDist = VSize(Location - StagePositions[i].Location);      
        if( bestPosition == None || tmpDist < bestPositionDist )
        {
            // only consider positions that offer some kind of cover...
            //@@@ should really weight by amount of cover
            if ( !StagePositions[i].bIsClaimed 
                 && PositionProvidesCoverFromEnemy(StagePositions[i], C.Enemy) > 0) {
                bestPosition = StagePositions[i];
                bestPositionDist = tmpDist;
            }
        }
    }
    // if the closest node is out of range, forget it.
    if ( (rangeLimit > 0) && (bestPositionDist > rangeLimit) ) {
        return None;
    }
    return bestPosition;
}

/**
 */
function int findAgentIndex( VGSPAIController c ) {
    local int i;
    for ( i = 0; i < StageAgents.length; ++i ) {
        if ( StageAgents[i].controller == c ) return i;
    }
    return -1;
}

/**
 */
function removeTakenAgents( Array<VGSPAIController> agents ) {
    local int i;
    local int idx;
    for ( i = 0; i < agents.length; ++i ) {
        idx = findAgentIndex(agents[i]);
        if( idx >= 0 ) StageAgents.remove( idx, 1 );  
    }
}

/**
 * find the best enemy we know of for c to engage
 **/
function bool findNewEnemyFor(VGSPAIController c)
{
    local int   i;
    local Pawn  bestEnemy, oldEnemy;
    local float bestThreat, NewThreat;
    local bool  bSeeEnemy, bSeeNew;

    BestEnemy = c.Enemy;
	OldEnemy = c.Enemy;
	//current enemy's threat level
    if ( BestEnemy != None )
	{
		if ( (BestEnemy.Health < 0) || (BestEnemy.Controller == None) )
		{
			c.Enemy = None;
			BestEnemy = None;
		}
		else
		{
			BestThreat = c.AssessThreat(BestEnemy,bSeeEnemy);
		}
	}
    //is there a more pressing threat?
    for ( i=0; i<ArrayCount(Enemies); i++ )
    {
        if( Enemies[i] == None 
            || Enemies[i].Controller == None 
            || c.SameTeamAs(Enemies[i].Controller)
            || Enemies[i].health <=0 )
            continue;

        //If we have no current enemy, the first will do for now
        if ( BestEnemy == None )
		{
			BestEnemy = Enemies[i];
			bSeeEnemy = c.CanSee(Enemies[i]);
            BestThreat = c.AssessThreat(BestEnemy,bSeeEnemy);
		}
		else if ( Enemies[i] != BestEnemy )
		{
            if ( VSize(Enemies[i].Location - c.Pawn.Location) < 1500 )
                bSeeNew = c.LineOfSightTo(Enemies[i]);
            else
                bSeeNew = c.CanSee(Enemies[i]); // only if looking at him
            
            NewThreat = c.AssessThreat(Enemies[i],bSeeNew);
            if ( NewThreat > BestThreat )
            {
                BestEnemy = Enemies[i];
                BestThreat = NewThreat;
                bSeeEnemy = bSeeNew;
            }
        }
    }
    
    if ( (bestEnemy != OldEnemy) && (bestEnemy != None) )
	{
		c.StageOrder_AlertNewEnemy(bestEnemy, bSeeEnemy);
		return true;
	}
	return false;
}

/**
 **/
function bool AddEnemy(Pawn NewEnemy)
{
    local int   i, j;
    local bool  bCurrentEnemy;

    //check already existing
    for ( i=0; i<ArrayCount(Enemies); i++ )
    {
        if ( Enemies[i] == NewEnemy )
            return false;
    }
    //add to empty slot
    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] == None)
        {
            Enemies[i] = newEnemy;
            return true;
        }
    }
    //If there's no room, then replace an enemy that's not being dealt with
    for ( i=0; i<MAXENEMY; i++ )
    {
        bCurrentEnemy = false;
        for ( j = 0; j < StageAgents.length; ++j )
        {  
            if ( StageAgents[j].controller.Enemy == Enemies[i] )
            {
                bCurrentEnemy = true;
                break;
            }
        }
        if ( !bCurrentEnemy )
        {
            Enemies[i] = NewEnemy;
            return true;
        }
     }
    return false;
}

/**
 *
 **/
function  RemoveEnemy(Pawn oldEnemy)
{
    local int i;

    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] == oldEnemy)
        {
            Enemies[i] = None;
			break;
        }
    }

/*    for ( i = 0; i < StageAgents.length; ++i )
    {
        if ( StageAgents[i].controller.Enemy == oldEnemy )
        {
            FindNewEnemyFor(StageAgents[i].controller);
        }
    }
*/
}

/**
 */

function string EnemyList()
{
   local int i;
   local string enemyList;

    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] != None)
            enemyList = enemyList@Enemies[i];
    }
    return enemyList;
}
/**
 */
function int GetEnemyIndex(Pawn P)
{
    local int i;

    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] == P)
            return i;
    }

    return -1;
}

/**
 */
function int NumEnemies()
{
    local int i, numEnemies;

    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] != None)
            numEnemies++;
    }

    return numEnemies;
}

/**
 */
function Rotator AverageEnemyDir()
{
    local vector avgDir;
    local int numEnemies;
    local int i;

    avgDir = vect(0,0,0);
    for(i=0; i<MAXENEMY; i++)
    {
        if(Enemies[i] != None)
        {
            numEnemies++;
            avgDir += vector(Enemies[i].Rotation);
        }
    }

    if(numEnemies > 0) return Rotator(avgDir);
    
    return Rotator(vect(0,0,1)); //shouldn't really ever get here.
}

function ClaimPosition( VGSPAIController c, StagePosition p )
{
	p.bIsClaimed = true;
}

function UnClaimPosition( VGSPAIController c, StagePosition p )
{
	//log( "RJ: UnClaimPosition("@c@","@p@")" );
	p.bIsClaimed = false;
}

/**
 * Handy debugging helper.
 */
function DebugLog( coerce String s, optional name tag ) {
   if ( bDebugLogging ) Log( self @StageName@ s, 'DEBAIT' );
}


//===================
// Default Properties
//===================

defaultproperties
{
     STAGE_CHECK_INTERVAL=5
     ActiveRange=20000
     ResetDelay=-1
     UPDATE_STAGEPOS_TIMER=1127
     STAGE_CHECK_TIMER=1128
     STAGE_RESET_TIMER=208
     DEBUG_RANGE=2000
     hSucceed="SUCCEED"
     hFail="FAIL"
     hHibernate="START_HIBERNATE"
     hAwaken="WAKEUP"
     hEngage="ENGAGE"
     hRestart="RESTART_STAGE"
     hAlarm="alarm"
     lastState="'"
     playerSpawnedEventName="PlayerSpawned"
     bHidden=True
     bHasHandlers=True
}
