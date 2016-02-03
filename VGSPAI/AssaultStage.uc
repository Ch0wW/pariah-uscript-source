/**
 * AssaultStage - agents directly attacking a list of actors.  Good
 *     for making things the player has to defend.
 *
 * @version $Revision: 1.7 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    Aug 2003
 */
class AssaultStage extends Stage
   placeable;

struct TargetInfo {
   var() const Actor Target;
   var   bool  bDestroyed;
};

var(Stage) Array<TargetInfo> Targets;

struct AssaultPositionInfo {
   var AssaultPosition  pos;           // the position
   var VGSPAIController controller;    // the controller assigned to it.
};
var Array<AssaultPositionInfo> AssaultPositions;
var int nextPosition;
var bool bAllTargetsDestroyed;

//=================
// Stage interface
//=================

/**
 *
 */
function Report_InPosition( VGSPAIController c, StagePosition pos ) {
   local Actor target;
   target = selectTarget();
   if ( (target != None) && activateAssaultPosition(pos, c) ) {
      DebugLog( "agent" @ c @ "in position, ordering to attack" @ target );
      c.StageOrder_AttackTarget( target );
   }
   else { 
      DebugLog( "agent" @ c @ "in position, ordering to hold ground" );
      c.StageOrder_HoldPosition();
   }
}

/**
 */
function Report_TargetDestroyed( VGSPAIController c, Actor target ) {
   local int i;

   DebugLog( "agent" @ c @ "reporting target [" $ target $ "] destroyed" );
   // book-keeping updates...
   destroyedTarget( target );
   bAllTargetsDestroyed = true;
   for ( i = 0; i < targets.length; ++i ) {
      if ( !targets[i].bDestroyed ) bAllTargetsDestroyed = false;
   }
   // dish out some more orders...
   if ( bAllTargetsDestroyed ) {
      if ( onSuccessStage != None ) {
         onSuccessStage.joinStage( c );
      }
      else {
         // do default behaviour...
         super.Report_TargetDestroyed( c, target );
      }
   }
   else {
      target = selectTarget();
      if ( target != none ) {
         DebugLog( "ordering agent" @ c @ "to attack" @ target );
         c.StageOrder_AttackTarget( target );
      }
      else {
         //@@@ not quite right... if !bAllTargetsDestroyed && t == None,
         //@@@ something has gone wrong...
         c.StageOrder_HoldPosition();
      }
   }
}

/**
 * When agents join, assign them a position.
 */
function joinStage( VGSPAIController c ) {
   super.joinStage( c );
   // simple round-robin assignment
   nextPosition = (nextPosition + 1) % AssaultPositions.length;
   c.StageOrder_TakeUpPosition( AssaultPositions[nextPosition].pos );
   c.StageOrder_AttackTarget( selectTarget() );
}

/**
 */
function leaveStage( VGSPAIController c, EReason r ) {
   local int ap;
   
   super.leaveStage( c, r );

   ap = getAssaultPositionInfo( c );
   if ( ap >= 0 ) {
      AssaultPositions[ap].controller = None;
   }
   //@@@ if the controller abandoned an assault position, allocate
   //@@@ someone else to it...
}

function UnClaimPosition( VGSPAIController c, StagePosition p )
{
	local int ap;

	ap = getAssaultPositionInfo( c );
	if ( ap >= 0 ) {
		AssaultPositions[ap].controller = None;
	}
	Super.UnClaimPosition( c, p );
}

/**
 * the assault has succeeded once the targets have all been destroyed.
 */
function bool checkStageSuccess() {
   return bAllTargetsDestroyed;
}

/**
 * send all agents
 */
function Array<VGSPAIController> getAvailableAgents() {
   local Array<VGSPAIController> c;
   local int i;
   c.length = StageAgents.length;
   for ( i = 0; i < StageAgents.length; ++i ) {
      c[i] = StageAgents[i].controller;
   }
   DebugLog( "offering" @ c.length @ "agents" );
   return c;
}


//================
// Implementation
//================

/**
 */
function PostBeginPlay() {
   local int i;
   local AssaultPosition p;

   super.PostBeginPlay();
   for ( i = 0; i < StagePositions.length; ++i ) {
      p = AssaultPosition( StagePositions[i] );
      if ( p != None ) {
         AssaultPositions.length = AssaultPositions.length + 1;
         AssaultPositions[AssaultPositions.length - 1].pos = p;
         AssaultPositions[AssaultPositions.length - 1].controller = None;
      }
   }
   DebugLog( "Found " $ AssaultPositions.length $ " assault position in " 
             $ StageName );

   for ( i = 0; i < targets.length; ++i ) {
      targets[i].bDestroyed = false;
   }
   bAllTargetsDestroyed = !(targets.length > 0);
}

/**
 * gets the assault pos info for a particular controller.
 */
function int getAssaultPositionInfo( VGSPAIController c ) {
   local int i;
   for ( i = 0; i < AssaultPositions.length; ++i ) {
       if ( AssaultPositions[i].controller == c ) {
           return i;
       }
   }
   return -1;
}

/** 
 * Returns None if there are no targets left.
 */
function Actor selectTarget() {
   local int i;
   for ( i = 0; i < targets.length; ++i ) {
      if ( !targets[i].bDestroyed ) return targets[i].target;
   }
   return None;
}

/**
 * returns true if pos is an assault position
 */
function bool activateAssaultPosition( StagePosition pos, 
                                       VGSPAIController c ) {
   local int i;
   for ( i = 0; i < AssaultPositions.length; ++i ) {
      if ( pos == AssaultPositions[i].pos ) {
         AssaultPositions[i].controller = c;
         return true;
      }
   }
   return false;
}

/**
 *
 */
function destroyedTarget( Actor t ) {
   local int i;
   for ( i = 0; i < Targets.length; ++i ) {
      DebugLog( "Checking [" $ Targets[i].target $ "] against [" 
                $ t $ "]" );
      if ( Targets[i].target == t ) {
         Targets[i].bDestroyed = true;
         return;
      }
   }
}

defaultproperties
{
     nextPosition=-1
}
