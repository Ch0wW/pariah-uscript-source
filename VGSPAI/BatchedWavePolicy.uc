/**
 * BatchedWavePolicy - creates a wave of opponents as immediately as
 *     possible.  That means it will create them all in one shot if
 *     there is enough space.  Otherwise, it will spawn as many as
 *     possible, and then retry periodically until the whole wave is
 *     in play.
 *
 * @version $Revision: 1.4 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    Dec 2003
 */
class BatchedWavePolicy extends WavePolicy
   editinlinenew
   hidecategories(Object);


//===========================================================================
// Editable properties
//===========================================================================

// radius in which to spawn the batch of opponents
var(CreationPolicy) float SpawnAreaRadius;
// radius occupied by each pawn in the world
var(CreationPolicy) float PawnRadius;


//===========================================================================
// Internal data
//===========================================================================

var float retryDelay;

var const int   RETRY_TIMER;
var const float MAX_DELAY;
var const float MIN_SPAWN_RADIUS;


//===========================================================================
// Policy Hooks
//===========================================================================

/**
 * 
 */
function init( OpponentFactory o ) {
    super.init( o );
    retryDelay = default.retryDelay;
    if ( SpawnAreaRadius < MIN_SPAWN_RADIUS 
		&& WaveSize > 1 ) {
        theFactory.DebugLog( "Overriding SpawnAreaRadius for batch policy,"
                             @ "must be at least" @ MIN_SPAWN_RADIUS );
        SpawnAreaRadius = MIN_SPAWN_RADIUS;
    }
    if ( theFactory.NoSpawnZoneRadius > theFactory.SpawnRadius/2 ) {
        theFactory.DebugLog( "Overriding NoSpawnZoneRadius for batch policy" );
        theFactory.NoSpawnZoneRadius = 0;
    }
}

/**
 */
function start() {
    super.start();

    // try to create all of the opponents
    createBatch();
    // if we've still got more opponents to create, schedule a timer
    if ( shouldCreate() ) {
        theFactory.SetMultiTimer( RETRY_TIMER, retryDelay, false );
    }
}

/**
 */
function stop() {
    super.stop();
    theFactory.SetMultiTimer( RETRY_TIMER, 0, false );
}

/**
 */
function opponentCreated() {
    super.opponentCreated();
    if ( theFactory.getOpponentCount() >= WaveSize ) {
        theFactory.SetMultiTimer( RETRY_TIMER, 0, false );
    }
    else {
        theFactory.SetMultiTimer( RETRY_TIMER, retryDelay, false );
    }
}


//===========================================================================
// Helpers
//===========================================================================

/**
 * Exponential back-off for attempting to spawn the rest of the
 * batch.
 */
function bool handleTimer( int timerID ) {
    if ( timerID == RETRY_TIMER ) {
        createBatch();
        // check if still more opponents to create...
        if ( numOpponentsCreated < WaveSize ) {
            retryDelay = min( retryDelay * 2, MAX_DELAY );
            theFactory.SetMultiTimer( RETRY_TIMER, retryDelay, false );
        }
        return true;
    }
    else {
        return super.handleTimer( timerID );
    }
}

/**
 * Spawn as many opponents as possible, until the batch is done or
 * we're unable to spawn.  Opponents are spawned from the outside of
 * the SpawnAreaRadius around the factory, inwards.
 */
function createBatch() {
    local int failCount, origNumOpponents;

    theFactory.DebugLog( "creating batch" );
    failCount = 0;
    theFactory.SpawnRadius = spawnAreaRadius;    
    while ( failCount < 4 && theFactory.SpawnRadius >= 0 && shouldCreate() ) {
        origNumOpponents = theFactory.getOpponentCount();
        theFactory.createOpponent();
        // check if the create was successful...
        if ( theFactory.getOpponentCount() <= origNumOpponents ) {
            if ( failCount < 1 ) {
                theFactory.SpawnRadius -= (pawnRadius * 2);
            }
            ++failCount;
        }
        else failCount = 0;
    }
}


//===========================================================================
// Default Properties
//===========================================================================

defaultproperties
{
     PawnRadius=50.000000
     retryDelay=0.500000
     MAX_DELAY=10.000000
     MIN_SPAWN_RADIUS=64.000000
}
