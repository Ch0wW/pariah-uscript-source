/**
 * ExclaimManager - manages chatter.
 *
 * @version $Revision: 1.6 $
 * @author  Mike "The Rev" Horgan (mikeh@digitalextremes.com)
 * @date    Sept 2003
 */
class ExclaimManager extends Actor;


//===========================================================================
// Configurable Properties
//===========================================================================

// sound radius for exclamations, in Unreal Units.
var float ExclaimRadiusUU; 
// pitch for exclamations, in case you don't like the default (1.0)
var float ExclaimPitch;
// send exclamations to the messaging system?
var bool bPostMessages;
// messaging system "type" for exclamations
var Name MsgType;
// a hack to increase the volume on the exclamations (>1 is the hack)
var int LoudExclaimHack;
// enable debugging features
var bool bEnableDebug;

//===========================================================================
//Internal data
//===========================================================================

Enum EExclamationType
{
    EET_AcquireEnemy,
	EET_NoticeEnemy,
	EET_LostEnemy,
	EET_Pain,
	EET_Fear,
	EET_Panic,
	EET_Attacking,
	EET_FriendlyFire,
	EET_WitnessedDeath,
	EET_KilledEnemy,
	EET_WitnessedKilledEnemy,
    EET_Idle
	
};

var VGSPAIController c;

var bool bScheduled;

struct ScheduledExclamation
{
    var EExclamationType type;	// which remark
    var float            time;	//level.timeseconds at which to play remark
};

var float GlobalLastExclaimTime;
var float GlobalTimeBetween;

var float LastExclaimTime[12];
var float TimeBetween[12];

var Sound   sndGroups[12];

var Sound	sndIdle;
var Sound	sndAcquire;
var Sound	sndNotice;
var Sound	sndLost;
var Sound	sndPain;
var Sound	sndFear;
var Sound	sndPanic;
var Sound	sndAttacking;
var Sound	sndFriendlyFire;
var Sound	sndWitnessedDeath;
var Sound	sndKilledEnemy;
var Sound	sndWitnessedKilledEnemy;

var ScheduledExclamation nextExclamation;

/**
 */
function init(VGSPAIController ctlr)
{
    c = ctlr;
    sndGroups[EExclamationType.EET_AcquireEnemy] = sndAcquire;
	sndGroups[EExclamationType.EET_NoticeEnemy] = sndNotice;
	sndGroups[EExclamationType.EET_LostEnemy] = sndLost;
	sndGroups[EExclamationType.EET_Pain] = sndPain;
	sndGroups[EExclamationType.EET_Fear] = sndFear;
	sndGroups[EExclamationType.EET_Panic] = sndPanic;
	sndGroups[EExclamationType.EET_Attacking] = sndAttacking;
	sndGroups[EExclamationType.EET_FriendlyFire] = sndFriendlyFire;
	sndGroups[EExclamationType.EET_WitnessedDeath] = sndWitnessedDeath;
	sndGroups[EExclamationType.EET_KilledEnemy] = sndKilledEnemy;
	sndGroups[EExclamationType.EET_WitnessedKilledEnemy] = sndWitnessedKilledEnemy;;
    sndGroups[EExclamationType.EET_Idle] = sndIdle;
    
}

/**
 * Exclaim the desired remark after a delay of "delay" seconds.
 *
 * An exclaimation will be cancelled by a new remark scheduled to
 * occur before it, i.e. when the player hides, delay a second before
 * we remark, but if he becomes visible within that time the
 * "LostEnemy" remark is replaced by the "NoticeEnemy" remark 
 */
function Exclaim(EExclamationType type, float delay, optional float fOdds)
{
    local float schedTime;

    if(fOdds != 0.0 && Frand() > fOdds ) {
        return;
    }

    delay = delay + 0.01;
    schedTime = c.Level.TimeSeconds + delay;

    //don't cancel current remark if a similar remark is requested
    if(bScheduled == true && type == nextExclamation.type)
    {	
        return;
    }

    //don't schedule remarks too close together
    if ( schedTime - GlobalLastExclaimTime < GlobalTimeBetween )
    {
        return;
    }

    //don't schedule similar remarks too close together
    if( ( c.currentStage != None 
          && (schedTime - c.currentStage.LastExclaimTime[type] 
                < TimeBetween[type]) ) 
          || (schedTime - LastExclaimTime[type] < TimeBetween[type] ) )
    {
        return;
    }
	
    if( c.currentStage != None ) {
        c.currentStage.LastExclaimTime[type] = c.Level.TimeSeconds;
    }
    else {
        LastExclaimTime[type] = c.Level.TimeSeconds;
    }
		
    //schedule new remark (overriding current if it exists)
    nextExclamation.type = type;
    nextExclamation.time = schedTime;
    bScheduled = true;
    SetTimer(delay, false);
}

/**
 */
function Timer()
{
    if(bScheduled && c != None && c.Pawn != None) {
        PlayScheduledExclamation();
    }
}

/**
 */
function PlayScheduledExclamation()
{
    local int i;
    local Sound snd;

    GlobalLastExclaimTime = c.Level.TimeSeconds;
	
    if(c.currentStage != None) {
        c.currentStage.LastExclaimTime[nextExclamation.type] 
            = c.Level.TimeSeconds;
    }
    else {
        LastExclaimTime[nextExclamation.type] = c.Level.TimeSeconds;
    }

    bScheduled = false;
    snd = sndGroups[nextExclamation.type];
    
    // you can hack around max-volume by playing the same sound
    // multiple times.  This shouldn't really be neccessary if your
    // sounds are balanced right in the first place.
    for ( i = 0; i < LoudExclaimHack; ++i ) {
        c.Pawn.PlaySound( snd, SLOT_Talk, 2.5*c.Pawn.TransientSoundVolume,
                          false, exclaimRadiusUU / 100, exclaimPitch );
    }
}

//===========================================================================
// Default Properties
//===========================================================================

defaultproperties
{
     LoudExclaimHack=1
     ExclaimRadiusUU=15000.000000
     ExclaimPitch=1.000000
     GlobalTimeBetween=1.000000
     TimeBetween(0)=0.200000
     TimeBetween(1)=1.000000
     TimeBetween(2)=2.000000
     TimeBetween(3)=1.000000
     TimeBetween(4)=1.000000
     TimeBetween(6)=3.000000
     TimeBetween(7)=10.000000
     TimeBetween(8)=10.000000
     TimeBetween(9)=1.000000
     TimeBetween(10)=1.000000
     MsgType="CriticalEvent"
     bEnableDebug=True
     bHidden=True
}
