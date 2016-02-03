/**
 * StationaryRole - the role that handles stationary AI logic.
 *
 * Todo:
 *   - duck and shoot
 *   - dodge
 *   - special behaviour when approached?
 *
 * @version $Revision: 1.8 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    Jan 2004
 */
class StationaryRole extends AIRole
   placeable;


//===========================================================================
// Editable properties
//===========================================================================

// AIScriptTag of the pawn to control
var(AI) Name PawnAIScriptTag;
// The type of AIController to use.
var(AI) class<VGSPAIController> ControllerType;
// set to true if the bot should wait to be triggered before attacking.
var(AI) bool bShouldAmbush;
// An event created when this bot's pawn is killed.
var(Events) Name onKilledEvent;
// Causes bot to start attacking if waiting in ambush.
var(Events) const editconst Name hAmbush;


//===========================================================================
// Internal data
//===========================================================================
var bool bHoldFire;
var struct AttackerRecord {
    var Pawn  enemy;
    var int   numAttacks;
    var float time;
} lastAttacker;

const START_FIRE_TIMER = 3918740;

//===========================================================================
// AI Role overrides
//===========================================================================

/**
 */
function OnThreatSpotted( Pawn threat ) {
    if ( threat == None ) return;
    SwitchIfCloser( threat );
    if ( !bHoldFire ) Tactic_Attack();
}

/**
 */
function OnThreatHeard( Pawn threat ) {
    if ( threat == None ) return;
    SwitchIfCloser( threat );
    if ( !bHoldFire ) Tactic_Attack();
}

/**
 * 
 */
function OnTakingDamage(Pawn other, float damage) {
    // maintain some info for repeated attacks
    if ( lastAttacker.enemy != other ) {
        lastAttacker.enemy = other;
        lastAttacker.numAttacks = 1;
        lastAttacker.time = Level.timeSeconds;
    }
    else {
        lastAttacker.numAttacks++;
        lastAttacker.time = Level.timeSeconds;
    }

    if ( lastAttacker.numAttacks > 1 ) {
        bot.DebugLog( "attacking threat:" @ other );
        bot.enemy = other;
        bot.focus = other;
    }
    else SwitchIfCloser( other );
    SetMultiTimer( START_FIRE_TIMER, 0.3, false );
    Tactic_Attack();
}

/**
 */
function OnKilled( Controller killer ) {
    TriggerEvent( onKilledEvent, bot.pawn, killer.pawn );
}

//===========================================================================
// Role Tactics
//===========================================================================

/**
 * Waiting for an enemy to come into view...
 */
function Tactic_LieInWait() {
    GotoState( 'LyingInWait' );
}

auto state LyingInWait {

    /**
     * Already lying in wait...
     */
    function Tactic_LieInWait() {
        // no-op
    }

BEGIN:
    //@@@ make sure the bot isn't shooting...
    bot.SetTimer( 0, false );
    while (true) {
        DebugLog( "lying in wait" );
        bot.Perform_Engaged_StandGround();    WaitForNotification();
    }
}

/**
 * Start firing!
 */
function Tactic_Attack() {
    GotoState( 'Attacking' );
}

state Attacking {

    /**
     * Already attacking!
     */
    function Tactic_Attack() {
        // no-op
    }

BEGIN:
    //@@@ now the bot can open fire!
    bot.StartFireWeapon();
    while (true) {
        bot.Perform_Engaged_StandGround();    WaitForNotification();
    }
    bot.StopFireWeapon();
    //@@@ should probably do something clever once the enemy is dead,
    //@@@ like attack another enemy or hide again...
}


//===========================================================================
// Implementation and helpers
//===========================================================================

/**
 * if new threat is closer than old threat, switch targets.
 */
function SwitchIfCloser( Pawn threat ) {
    if ( threat == None ) return;
    if ( bot.enemy == None 
         || VSize(bot.location - threat.location) 
             < VSize(bot.location - bot.enemy.location) ) {
        bot.DebugLog( "switching enemies to" @ threat );
        bot.enemy = threat;
        bot.focus = threat;
    }
}

/**
 */
function TriggerEx( Actor other, Pawn instigator, Name handler, Name realevent ) {
    switch ( handler ) {
    case hAmbush:
        bHoldFire = false;
        Tactic_Attack();
        break;

    default:
        super.TriggerEx( other, instigator, handler, realevent );
        break;
    }
}

/**
 */
function MultiTimer( int timerID ) {
    if ( timerID == START_FIRE_TIMER ) {
        bot.StartFireWeapon();
    }
    else super.MultiTimer( timerID );
}

/**
 * Spawn a controller for this role, and hook it up with the right
 * pawn.
 */
function PreBeginPlay() {
    local Pawn p;
    local VGSPAIController c;

    super.PreBeginPlay();
    bHoldFire = bShouldAmbush;
    // if no pawn or controller is specified, then this role is
    // useless...
    if ( pawnAIScriptTag == '' ) {
        Warn( "No pawn specified for" @ self );
        return;
    }
    else if ( ControllerType == None ) {
        Warn( "No controller type specified for" @ self );
        return;
    }
    // find the pawn and do the hookups...
    ForEach AllActors( class'Pawn', p ) {
        if ( p.AIScriptTag == pawnAIScriptTag ) {
            c = Spawn( ControllerType, self );
            if ( c == None ) {
                Warn( "Failed to spawn controller of type" @ ControllerType );
                return;
            }
            c.myAIRole      = self;
            c.bDebugLogging = bDebugLogging;
            c.AIDebugFlags  = ~(c.DEBUG_FIRING);
            p.Controller    = c;
            c.possess( p );
            c.configure( none, none );
            // make sure the pawn doesn't clobber us with an AIScript
            p.bDontPossess = true;
            return;
        }
    } 
    // falling through that loop is bad...
    Warn( self @ "could not find a pawn with AIScriptTag [" 
          $ pawnAIScriptTag $ "]" );
    return;
}


//===========================================================================
// Default Properties
//===========================================================================

defaultproperties
{
     hAmbush="AMBUSH"
     ControllerType=Class'VGSPAI.VGSPAIController'
     bDebugLogging=True
     bHasHandlers=True
}
