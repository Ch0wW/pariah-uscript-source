/**
 * This is a quick and dirty implementation that creates controllers
 * and pawns together, and performs necessary configuration before
 * setting them lose in the game.
 *
 * A fancier future version would provide objects for configuring the
 * spawning behaviour, for example opponent "pools" from which
 * opponents could be drawn.
 *
 * @version $Revision: 1.42 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    June 2003
 */
class OpponentFactory extends NavigationPoint
   placeable;

#exec Texture Import File=Textures\LotsOStickGuys.tga Name=OpponentFactoryIcon Mips=On MASKED=1

//=====================
// Editable properties
//=====================

// start creating opponents as soon as the game begins
var() bool bStartActive;
//
var() editinline export CreationPolicy TheCreationPolicy;
struct native export OpponentType {
    // the pawn class to spawn
    var() class<Pawn> PawnType;
    // tag to set on the controller
    var() Name ControllerTag;
};
// the types of opponents to spawn
var() editinline array<OpponentType> OpponentTypes;
// a script that the bot should be put on
var() Name AIScriptTag;
// the stage object that these opponents should participate in
var() Name InitialStage;
// use verbose logging?
var() bool bDebugLogging;
// use verbose logging on opponents spawned from this factory?
var() bool bOpponentLogging;
// spawn the bot with special PopUpAI
var() bool bPopUpAI;

//TEST CONTROLLER SETUP
var(AdvancedFactory) bool bTestBot;
var(AdvancedFactory) class<VGSPAIController> TestType;

// area around the factory that must be clear of pawns for spawning
var(AdvancedFactory) float NoSpawnZoneRadius;
// Distance from the location of the factory that opponents should be spawned
var(AdvancedFactory) float SpawnRadius;
// Do a trace when spawning to make sure opponents are placed on the ground.
var(AdvancedFactory) bool  bSpawnOnGround;
// When > 0, all opponents from this factory will be killed after this
// many seconds.
var(AdvancedFactory) float KillAllTime;
// an event triggered by the KillAllTime expiring.  Note that this is
// in addition to any events the creation policy might generate when
// all of the opponents are killed...
var(Events) const Name OnKillAllEvent;

// handlers this actor provides for reacting to events
//
// start the spawning process
var(Events) editconst const Name hStartSpawn;
// stop (pause) the spawning process
var(Events) editconst const Name hStopSpawn;
// spawn a single opponent (if possible)
var(Events) editconst const Name hDoSpawn;
// restart the spawning process
var(Events) editconst const Name hRestartFactory;
// kill all of the opponents this factory has created
var(Events) editconst const Name hDestroyOpponents;


//===============
// Internal data
//===============

struct native export OpponentInfo {
   var VGSPAIController controller;
   var Pawn pawn;
};
var protected int     numLiveOpponents;
var protected int     numOpponentsCreated;
var protected Stage   LocalStage;
var protected ScriptedSequence Script;
var private Rotator currentSpawnRotn;
var private int     typeIndex;
var private bool    bHibernating;
var private Array<OpponentInfo> myOpponents;
var private bool    bActive;

const KILL_ALL_TIMER = 559900;

event String SuggestedGroup()
{
    return String(InitialStage);
}
//======================
// Controller interface
//======================

/**
 * Must be called by the controller when the opponent is
 * killed/removed from the game, so that the factory can updates it's
 * records.
 */
function OpponentDied( VGSPAIController c ) {
    local int i;
    local bool found;
   
    DebugLog( "Opponent died:" @ c );
    --numLiveOpponents;
   
    found = false;
    for ( i = 0; i < myOpponents.length; ++i ) {
        if ( myOpponents[i].controller == c ) {
            found = true;
            break;
        }
    }
    if ( found ) myOpponents.remove( i, 1 );
    else Warn( "Unable to cleanup" @ c @ "from factory" @ self );
    if ( theCreationPolicy != None ) theCreationPolicy.opponentKilled();
}

/**
 * A handy debugging function, which removes all opponents from the game.
 */
function DestroyAllOpponents() {
    local int i, numOpponents;

    numOpponents = myOpponents.length;
    DebugLog( "Destroying all" @ numOpponents @ "opponents" );
    for ( i = 0; i < numOpponents; ++i ) {
        // killing an opponent will shrink the array, so we can keep
        // deleting off the front.
        if(VGPawn(myOpponents[0].pawn).DrivenVehicle != None)
		{
			VGPawn(myOpponents[0].pawn).DrivenVehicle.TakeDamage(1500, VGPawn(myOpponents[0].pawn).DrivenVehicle, VGPawn(myOpponents[0].pawn).DrivenVehicle.Location, Vect(0,0,0), class'Crushed'); 
		}
		myOpponents[0].pawn.Died( None, None, Vect(0,0,0) );     
    }
    GotoState( 'Dormant' );
}


//========================
// StageManager Interface
//========================

/**
 * Go into performance conserving mode.
 */
function hibernate()
{
    // don't sleep while we're supposed to be generating opponents
    if ( bActive ) return;

    bHibernating = true;
    theCreationPolicy.stop();
    GotoState('Dormant');
}

/**
 * Get back to work!
 */
function awaken()
{
    bHibernating = false;
    if ( bActive ) theCreationPolicy.start();
    GotoState('Active');
}


//==================
// Policy Interface
//==================

/**
 */
function int getOpponentCount() {
    return numLiveOpponents;
}


//=================
// Actor Interface
//=================

/**
 */
function BeginPlay() {
    local Stage s;

    Super.BeginPlay();
    if ( LocalStage != None ) return;
    ForEach AllActors( class'Stage', s ) {
        if ( s.StageName == InitialStage ) {
            LocalStage = s;
            LocalStage.registerFactory(self);
            break;
        }
    }
	if( AIScriptTag != '') {
		ForEach AllActors(class'ScriptedSequence',Script,AIScriptTag)
				break;
	}
			
    init();
}

/**
 */
event TriggerEx( Actor other, Pawn instigator, Name handler, Name realevent ) {
    DebugLog( "TriggerEx(" @ handler @ ")" );
    switch ( handler ) {
    case hDoSpawn:
        createOpponent();
        break;

    case hStartSpawn:
        bActive = true;
        GotoState( 'Active' );
        theCreationPolicy.start();
        break;

    case hStopSpawn:
        theCreationPolicy.stop();
        break;

    case hRestartFactory:
        init();
        GotoState( 'Active' );
        break;

    case hDestroyOpponents:
        DestroyAllOpponents();
        break;

    default:
        if ( theCreationPolicy == None 
                || !theCreationPolicy.handleEvent( handler ) ) {
            super.TriggerEx( other, instigator, handler, realevent );
        }
        break;
    }
}

/**
 */
function MultiTimer( int timerID ) {
    DebugLog( "my timer went off:" @ timerID );
    if ( timerID == KILL_ALL_TIMER ) {
        if ( onKillAllEvent != '' ) {
            TriggerEvent( onKillAllEvent, self, None );
        }
        DestroyAllOpponents();
    }
    else if ( theCreationPolicy == None
                 || !theCreationPolicy.handleTimer( timerID ) ) {
        super.MultiTimer( timerID );
    }
}

//=========
// Helpers
//=========

/**
 * Initialize factory to start producing opponents.  This has the
 * effect of resetting the factory
 */
function init() {
    DebugLog( "Initializing factory" );
    DestroyAllOpponents();
    numOpponentsCreated = 0;
    bActive = false;

    theCreationPolicy.init( self );
    if ( bStartActive ) {
        bActive = true;
        theCreationPolicy.start();
    }
}

/**
 * Handy debugging helper.
 */
function DebugLog( coerce String s, optional name tag ) {
    if ( bDebugLogging ) Log( self @ s, 'DEBAIT' );
}

function bool PlayerWouldSeePopping(Vector spawnSpot)
{
    local vector oldLocation;
    local Controller C;
    local PlayerController PC;
    local float dist;

    oldLocation = Location;
    SetLocation(spawnSpot);
    
    for(C=Level.ControllerList; C != None; C= C.nextController)
    {
        if(!C.IsA('PlayerController') )
            continue;
        PC = PlayerController(C);
        dist = VSize(Location - PC.ViewTarget.Location);
        if( (dist < 10000)
		    && (( Vector(PC.Rotation) dot (Location - PC.ViewTarget.Location)) >= 0.5f * dist)
		    && PC.LineOfSightTo(self) )
        {
            SetLocation(oldLocation);
            return true;
        }
    }
    SetLocation(oldLocation);
    return false;
}

/**
 * Performs the low level work in attempting to spawn a controller and pawn
 */
function OpponentInfo spawnOpponent() {
    local OpponentInfo newOpponent;
    local Actor hit;
    local vector hitLocn, hitNorm, spawnSpot;
    local Pawn p;
    local int nextIndex;
    local class<Pawn> pawnClass;
    local class<VGSPAIController> ctlrClass;

    newOpponent.controller = None;
    newOpponent.pawn       = None;
    if ( OpponentTypes.length < 1 ) return newOpponent;

    if ( NoSpawnZoneRadius > 0 ) {
        ForEach RadiusActors( class'Pawn', p, NoSpawnZoneRadius ) {
            // if there are any pawns in this radius, bail.
            DebugLog( "Pawn" @ p @ "in no-spawn-zone, radius" 
                      @ NoSpawnZoneRadius );
            return newOpponent;
        }
    }
    nextIndex = typeIndex;
    // rotate by 225 degrees each time, to get a 45 degree offset on
    // alternating sides of the factory, giving pawns lots of room to move.
    currentSpawnRotn.Yaw += 40960;
    currentSpawnRotn = Normalize( currentSpawnRotn );
    spawnSpot = Location + (SpawnRadius * Vector(currentSpawnRotn));
    if ( bSpawnOnGround ) {
        // try to ensure the pawn ends up above the ground by tracing down...
        hit = Trace( hitLocn, hitNorm, 
                     spawnSpot + vect(0,0,-1000), spawnSpot,
                     false );
        if ( (hit == None) 
             || ( (LevelInfo(hit) == None) && (TerrainInfo(hit) == None) ) ) {
            // maybe location is below the ground?
            hit = Trace( hitLocn, hitNorm, 
                         spawnSpot + vect(0,0,1000), spawnSpot,
                         false );
            if ((hit == None)
                || ((LevelInfo(hit) == None) && (TerrainInfo(hit) == None))) {
                DebugLog( "can't spawn pawn, hit =" @ hit );
                newOpponent.controller = None;
                newOpponent.pawn = None;                
                return newOpponent;
            }
        }
        // apply adjustments to the spawn location...
        spawnSpot 
            = hitLocn 
               + (vect(0,0,1) 
                  * opponentTypes[nextIndex].pawnType.default.CollisionHeight);
    }

    if(PlayerWouldSeePopping(spawnSpot))
    {
        return newOpponent;
    }
    
    // create the pawn and controller...
    pawnClass = opponentTypes[nextIndex].pawnType;
    if ( pawnClass != None ) {
        newOpponent.pawn = Spawn( pawnClass ,,, spawnSpot, Rotation );
    }
    else {
        DebugLog( "null pawn class, #" @ nextIndex );
    }
    if ( newOpponent.pawn != None ) {	
        //Use the Pawns default ControllerClass since
        // pawns now have specific weapon loadouts
        
        if(bTestBot) {
            ctlrClass = TestType;
        }
        else {
            ctlrClass = class<VGSPAIController>(newOpponent.pawn.ControllerClass);
            if(bPopUpAI) {
                ctlrClass = ctlrClass.default.PopUpClass;
            }
        }

        if( ctlrClass == None )
            warn("Invalid Controller Type"@newOpponent.pawn@newOpponent.pawn.ControllerClass);
        
        if( newOpponent.pawn.Controller != None ) {
            if( newOpponent.pawn.Controller.class != ctlrClass ) {
                // This pawn created a controller for us and it isn't the kind we want!
                newOpponent.pawn.Controller.Destroy();
                newOpponent.controller = None;
            } else {
                // Cool, we already have one and it's what we wanted anyway, just use it!
                newOpponent.controller = VGSPAIController(newOpponent.pawn.Controller);
                Assert( newOpponent.controller != None );
            }
        }

        if( newOpponent.controller == None ) {
            newOpponent.controller = Spawn( ctlrClass,,, spawnSpot, Rotation );
        }
        
        if (newOpponent.Controller == None) {
            DebugLog( "Failed to create controller" );
            // cleanup
            newOpponent.pawn.Destroy();
            newOpponent.controller.Destroy();
            newOpponent.pawn = None;
            newOpponent.controller = None;
        }
        else {
            // complete, utter success.
            newOpponent.controller.Tag 
                = opponentTypes[nextIndex].controllerTag;
			typeIndex = (typeIndex + 1) % opponentTypes.length;
            theCreationPolicy.opponentCreated();
        }
    }
    else {
        DebugLog( "Failed to created pawn, type" @ nextIndex 
                  @ pawnClass @ "at" @ spawnSpot @ Rotation );
    }
    return newOpponent;
}

function postPossessConfigure(Controller C);
		


//============
// State code
//============

/**
 */
function createOpponent() {
    DebugLog( "createOpponent() called while inactive" );
}

/**
 * The initializing state is used *once* to initialize the factory.
 * The init() method may be called more than once, to reset the
 * factory. 
 *
 * a little hack because GotoState() doesn't seem to work from
 * *BeginPlay(). 
 * mh: add hibernate hack for same reason
 */
auto state Initializing {

BEGIN:
    if (!bStartActive || bHibernating) GotoState( 'Dormant' );
    else GotoState( 'Active' );
}


/**
 * Awake, not hibernating.  May or may not be generating opponents,
 * depending on the policy.
 */
state Active {

    function BeginState() {
        DebugLog( "Active" );
        if ( killAllTime > 0 ) {
            SetMultiTimer( KILL_ALL_TIMER, killAllTime, false );
        }
    }

    /**
     * Makes a new opponent, subject to the creation policies of the factory.
     */
    function createOpponent() {
        local OpponentInfo newOpponent;
        if ( !theCreationPolicy.shouldCreate() ) return;

        // create the opponent, and do bookkeeping...
        newOpponent = spawnOpponent();
        if ( newOpponent.controller == None || newOpponent.pawn == None ){
        
            if ( newOpponent.controller != None ){
                log("Holy shit! We pawned a controller but no pawn!");
            } else if ( newOpponent.pawn != None ){
                log("Holy shit! We pawned a pawn but no controller!");
            }
            
        
            return;
        }
        ++numLiveOpponents;
        ++numOpponentsCreated;
        myOpponents.length = myOpponents.length + 1;
        myOpponents[myOpponents.length - 1]  = newOpponent;
        newOpponent.controller.bDebugLogging = bOpponentLogging;
        newOpponent.controller.Possess( newOpponent.pawn );
        postPossessConfigure( newOpponent.controller );
        newOpponent.controller.configure( self, LocalStage );
		if( Script != None ) {
			newOpponent.controller.SetNewScript( Script);
			newOpponent.controller.GotoState('Scripting');
		}
    }
}

/**
 * Hibernating, hopefully not chewing up unneccessary cycles.
 */
state Dormant {
    ignores Tick;

    function BeginState() {
        DebugLog( "Hibernating" );
    }

    /**
     */
    function createOpponent() {
        DebugLog( "Attempted to create opponent while dormant" );
    }
}

event PreLoadData()
{
	local int p;

	Super.PreLoadData();
	for ( p = 0; p < OpponentTypes.Length; p++ )
	{
		PreLoad( OpponentTypes[p].PawnType );
	}
}

defaultproperties
{
     hStartSpawn="START_SPAWN"
     hStopSpawn="STOP_SPAWN"
     hDoSpawn="DO_SPAWN"
     hRestartFactory="RESTART_FACTORY"
     hDestroyOpponents="DESTROY_ALL"
     DrawScale=2.000000
     Texture=Texture'VGSPAI.OpponentFactoryIcon'
     bStatic=False
     bHasHandlers=True
     bDirectional=True
     bNeedPreLoad=True
}
