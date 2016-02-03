/**
 * Takes care of global stage things, like hibernation.  Level
 * designers should place one of these in every level.
 *
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @version $Revision: 1.5 $
 * @date    July 2003
 */
class StageManager extends Actor
   placeable;


//=====================
// Editable Properties
//=====================

// Distance beyond the active range boundary of the hibernation
// boundary.  Making this bigger will reduce the frequency of
// StageManager updates, but also reduces how aggressively it puts
// stages into hibernation.
var() const int HIBERNATE_FUDGE;
// Produce verbose debugging info in log
var() bool bDebugLogging;
// For profiling purposes, force all stages to hibernate.
var() bool bAllHibernate;
// How often to poll for reawakening when using bAllHibernate
var() float AllHibernateTime;

//================
// Internal data
//===============
var private Array<Stage> theStages;


//=================
// Stage interface
//=================

/**
 * All stages should call this method at the beginning of the game, so
 * that the manager can... manage them.
 */
function registerStage( Stage s ) {
   local int i;
   i = theStages.length;
   DebugLog( "Adding" @ s @ "to list of" @ i @ "stages" );
   theStages.length = i + 1;
   theStages[i] = s;
}


//================
// Implementation
//================

/**
 */
function BeginPlay() {
   Super.BeginPlay();
   SetTimer( 0.5, false); // initial update
}

/**
 * updates hibernation states for all of the stages, based on the
 * current location of the player's pawn.
 */
function Timer() {
   local int i;
   local float playerDist, minTimeToContact, hibernateDist;
   local float dist;
   local float groundSpeed;
   local Controller c;

   // short-circuit	this process when unconditionally hibernating...
   if (	bAllHibernate )	{
	  AllHibernate();
	  SetTimer(	AllHibernateTime, false	);
	  return;
   }
   // update stage hibernation states...
   DebugLog( "refreshing stage managment data" );
   if (	Level.RandomPlayerPawn() == None ) 
   {
	  // try again later, can't	find the player
	  minTimeToContact = 0.5;
   }
   else	
   {
	  for (	i =	0; i < theStages.length; ++i ) 
	  {
		playerDist = 100000.0;
		for( c=Level.ControllerList; c!=None; c=c.NextController )
		{
			if(c.Pawn != None && c.IsA('SinglePlayerController'))
			{
				dist = VSize(theStages[i].location - c.Pawn.Location);
				if(dist < playerDist)
				{
					playerDist = dist;
					groundSpeed = playerDist;
				}
			}
		}
		hibernateDist =	theStages[i].ActiveRange + HIBERNATE_FUDGE;
		if ( playerDist	> hibernateDist	)
		{
			theStages[i].hibernate();
		}
		else if	( playerDist < hibernateDist )
		{
			theStages[i].awaken();
		}
	  }
	  // schedule the next check for the amount	of time	it would take the
	  // player	to cross the HIBERNATE_FUDGE zone at full speed.
	  minTimeToContact 
		 = HIBERNATE_FUDGE / groundSpeed;
   }
   SetTimer( minTimeToContact, false );
   DebugLog( "scheduling next update in" @ minTimeToContact	@ "seconds"	);
}


//=========
// Helpers
//=========

/**
 * For debugging purposes...
 */
function AllHibernate() {
   local int i;
   Log( "Putting all stages into hibernation", 'DEBAIT' );
   for ( i = 0; i < theStages.length; ++i ) {
      theStages[i].hibernate();
   }
}

/**
 * Handy debugging helper.
 */
function DebugLog( coerce String s, optional name tag ) {
   if ( bDebugLogging ) Log( self @ s, 'DEBAIT' );
}

defaultproperties
{
     HIBERNATE_FUDGE=8192
     AllHibernateTime=11.000000
     bHidden=True
}
