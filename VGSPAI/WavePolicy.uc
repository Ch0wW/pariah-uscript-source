/**
 * WavePolicy - provides a framework for concrete policies that
 *    generate waves of opponents.  In particular, the base class
 *    doesn't actually call createOpponent.
 *
 * @version $Revision: 1.4 $
 * @author  Name (email@digitalextremes.com)
 * @date    Dec 2003
 */
class WavePolicy extends CreationPolicy
   abstract;


//===========================================================================
// Editable properties
//===========================================================================

// number of opponents that make up the wave
var(CreationPolicy) int WaveSize;
// max number of opponents this factory is allowed to have in play at
// any given moment.
var(CreationPolicy) int InPlayLimit;
// event generated when a wave of opponents has been completely spawned
var(CreationPolicy) Name WaveCreatedEvent;
// event generated when a wave of opponents has been completely destroyed
var(CreationPolicy) Name WaveDestroyedEvent;


//===========================================================================
// Internal data
//===========================================================================

var protected int  numOpponentsCreated;
var private bool bCreateTriggered;
var private bool bDestroyedTriggered;


//===========================================================================
// Example section
//===========================================================================

/**
 */
function init( OpponentFactory o ) {
    super.init( o );
    numOpponentsCreated = 0;
    bDestroyedTriggered = false;
    bCreateTriggered    = false;
    if ( InPlayLimit <= 0 ) InPlayLimit = WaveSize;
}

/**
 */
function bool shouldCreate() {
    // ok to create if we're beneath the InPlayLimit and the wave
    // limit has not yet been reached.
    return ( numOpponentsCreated < WaveSize 
                && theFactory.getOpponentCount() < InPlayLimit );
}

/**
 */
function opponentCreated() {
    ++numOpponentsCreated;
    if ( !bCreateTriggered && (numOpponentsCreated >= WaveSize) ) {
        bCreateTriggered = true;
        theFactory.triggerEvent( WaveCreatedEvent, theFactory, None );
    }
}

/**
 * 
 */
function opponentKilled() {
    if ( !bDestroyedTriggered && (numOpponentsCreated >= WaveSize) 
             && (theFactory.getOpponentCount() <= 0) ) {
        // notify anyone who's interested that the wave is destroyed.
        bDestroyedTriggered = true;
        theFactory.triggerEvent( WaveDestroyedEvent, theFactory, None );
    }
}


//===========================================================================
// Default Properties
//===========================================================================

defaultproperties
{
     WaveSize=1
}
