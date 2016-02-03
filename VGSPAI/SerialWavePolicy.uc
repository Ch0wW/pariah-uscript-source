/**
 * SerialWavePolicy - create a "wave" of opponents, one at a time.
 *
 * @version $Revision: 1.1 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    Dec 2003
 */
class SerialWavePolicy extends WavePolicy
   editinlinenew
   hidecategories(Object);


//===========================================================================
// Editable properties
//===========================================================================

// time (seconds) between guys being spawned;
var(CreationPolicy) int SpawnInterval;


//===========================================================================
// Internal data
//===========================================================================

var const int SPAWN_TIMER;


//===========================================================================
// 
//===========================================================================

function init( OpponentFactory o ) {
	super.init( o );
	theFactory.SetMultiTimer( SPAWN_TIMER, 0, false );
}

/**
 */
function start() {
    super.start();
    theFactory.createOpponent();
    theFactory.SetMultiTimer( SPAWN_TIMER, SpawnInterval, true );
}

/**
 */
function stop() {
    super.stop();
    theFactory.SetMultiTimer( SPAWN_TIMER, 0, false );
}

/**
 */
function opponentCreated() {
    super.opponentCreated();
    if ( theFactory.getOpponentCount() >= WaveSize ) {
        theFactory.SetMultiTimer( SPAWN_TIMER, 0, false );
    }
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
     SpawnInterval=4
     SPAWN_TIMER=1056
}
