/**
 * InfinitePolicy - just keeps on creating opponents, up to the
 *    specified limit, whenever it is active.
 *
 * @version $Revision: 1.2 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    Dec 2003
 */
class InfinitePolicy extends CreationPolicy
   editinlinenew
   hidecategories(Object);


//===========================================================================
// Editable properties
//===========================================================================

// Maximum number of opponents allowed in the game from the factory at
// any one time.
var (CreationPolicy) const int MaxOpponents;
// Time between spawn attempts (seconds).
var (CreationPolicy) const int SpawnInterval;


//===========================================================================
// Internal data
//===========================================================================

var const int SPAWN_TIMER;
var bool stopped;


//===========================================================================
// CreationPolicy Hooks
//===========================================================================

function init( OpponentFactory o ) {
	super.init( o );
	theFactory.SetMultiTimer( SPAWN_TIMER, 0, false );
}

/**
 * 
 */
function start() {
    stopped = false;
    theFactory.setMultiTimer( SPAWN_TIMER, spawnInterval, true );
}

/**
 */
function stop() {
    stopped = true;
    theFactory.setMultiTimer( SPAWN_TIMER, 0, false );
}

/**
 */
function bool shouldCreate() {
    local bool limitReached;
    limitReached = theFactory.getOpponentCount() >= maxOpponents;
    if ( limitReached ) { 
        // stop polling if there are already enough opponents.
        theFactory.setMultiTimer( SPAWN_TIMER, 0, false );
    }
    return !limitReached;
}

/**
 */
function opponentKilled() {
    if ( stopped ) return;
    theFactory.setMultiTimer( SPAWN_TIMER, spawnInterval, true );
}


//===========================================================================
// Implementation
//===========================================================================

/**
 */
function bool handleTimer( int timerID ) {
    if ( timerID == SPAWN_TIMER ) {
        if ( theFactory != None ) theFactory.createOpponent();
        return true;
    }
    else {
        return super.handleTimer( timerID );
    }
}




//===========================================================================
// Default Properties
//===========================================================================

defaultproperties
{
     MaxOpponents=1
     SpawnInterval=4
     SPAWN_TIMER=557
}
