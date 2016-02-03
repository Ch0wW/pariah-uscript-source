/**
 * AdvanceStage - organizes the AI to try to advance through an area.
 *    Currently, this is just a renamed defense stage that uses
 *    AdvancePositions instead of DefensePositions (as a placeholder)
 *
 * @version $Revision: 1.9 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    July 2003
 */
class AdvanceStage extends Stage
  placeable;

#exec Texture Import File=Textures\AdvanceTower.tga Name=AdvanceStageIcon Mips=Off MASKED=1

//=====================
// Editable properties
//=====================


//===============
// Internal data
//===============
struct AdvancePointData
{
	var AdvancePosition  Node;
	var VGSPAIController attacker;
	var bool             inPosition;
};

var Array<AdvancePointData> AdvancePositions;
var bool bSetupExpired;


//=======================
// Stage framework hooks
//=======================

/**
 * 
 */
function bool checkStageSuccess() {
   return false;
}

/**
 * Failure means the stage has taken too many casualties, or the
 * player has breached the defense.
 */
function bool checkStageFailure() {
   return false;
}

/**
 * N/A ?
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


//=======================
// Inter-Stage interface
//=======================

/**
 * Accept all the help we can get.
 */
function Array<VGSPAIController> takeControl( Array<VGSPAIController> controllers ) {
   local int i;
   for ( i = 0; i < controllers.length; ++i ) {
      joinStage( controllers[i] );
   }
   return controllers;
}


//=============================
// Controller->Stage interface
//=============================

/**
 *
 */
function Report_InPosition( VGSPAIController c, StagePosition pos ) {
   //@@@ quick hack: promote to next stage
   if ( onSuccessStage != None ) {
      DebugLog( "Sending" @ c @ "to next stage:" @ onSuccessStage );
      onSuccessStage.joinStage( c );
	  TriggerEvent( OnSuccessEvent, self, none );
   }
   else {
      DebugLog( "No success stage to advance" @ c @ "to from" @ pos );
   }
}

/**
 * When agents join, assign them a position.
 */
function joinStage( VGSPAIController c ) {
   local int pos;
   super.joinStage( c );
   pos = pickOpenAdvancePosition( c );
   if ( pos != -1 ) {
      AdvancePositions[pos].Attacker   = c;
      AdvancePositions[pos].inPosition = false;
      if( !c.StageOrder_TakeUpPosition( AdvancePositions[pos].node ) )
      {
        AdvancePositions[pos].Attacker   = None;
        AdvancePositions[pos].inPosition = false;
      }
   }
   // else assign agent something generic to do...
}

/**
 * When agents leave the stage, update the cover point info to reflect
 * this.
 */
function leaveStage( VGSPAIController c, EReason r ) {
   local int dPoint;
   super.leaveStage( c, r );
   dPoint = getAdvancePointData( c );
   if ( dPoint != -1) {
      AdvancePositions[dPoint].attacker = None;
      AdvancePositions[dPoint].inPosition = false;
   }
}

function UnClaimPosition( VGSPAIController c, StagePosition p )
{
    local int dPoint;

	dPoint = getAdvancePointData( c );
    if ( dPoint != -1 ) {
		AdvancePositions[dPoint].attacker = None;
		AdvancePositions[dPoint].inPosition = false;
	}
	Super.UnClaimPosition( c, p );
}

//================
// Implementation
//================

/**
 */
function PostBeginPlay() {
   local int i, j, numAdvancePositions;
   local AdvancePosition d;
   local AdvancePointData tmp;

   super.PostBeginPlay();
   numAdvancePositions = 0;
   for ( i = 0; i < StagePositions.length; ++i ) {
      d = AdvancePosition( StagePositions[i] );
      if ( d != None ) {
         AdvancePositions[numAdvancePositions].Node = d;
         ++numAdvancePositions;
      }
   }

   //BubbleSort
   for(i=0; i<AdvancePositions.Length-1; i++) {
       for(j=0; j<AdvancePositions.Length-1-i; j++) {
            if(AdvancePositions[j].node.SequenceNumber > AdvancePositions[j+1].node.SequenceNumber) {
                tmp = AdvancePositions[j];
                AdvancePositions[j] = AdvancePositions[j+1];
                AdvancePositions[j+1] = tmp;
            }
       }
   }

   DebugLog( "Found " $ AdvancePositions.length $ " cover points in " 
             $ StageName );
}

//@@@ a quick hack to mark the geographical breaking point for the
//@@@ attackers with a trigger...
event Trigger( Actor other, Pawn instigator ) {
   /*
   DebugLog( "Triggered" @ other 
             @ "with group [" $ other.group $ "]" @ "by" @ instigator );
   if ( other.Group == BREACHED ) {
      bDefenseBreached = true;
      DebugLog( "breached!!" );
   }
   else if ( other.Group == REPELLED ) {
      bPlayerRepelled = true;
      DebugLog( "repelled" );
   }
   */
}

/**
 * gets the coverpoint info for a particular attacker.
 */
function int getAdvancePointData( VGSPAIController attacker ) {
   local int i;
   for ( i = 0; i < AdvancePositions.length; ++i ) {
      if ( AdvancePositions[i].attacker == attacker ) {
         return i;
      }
   }
   return -1;
}

/**
 * Randomly selects the index of one of the unassigned defense positions.
 */
function int pickOpenAdvancePosition(VGSPAIController c) {
    local int i;
    for ( i = 0; i < advancePositions.length; ++i ) {
        if( advancePositions[i].node.ControllerTag == c.Tag 
            && advancePositions[i].attacker == None) {
            return i;
        }
    }
    //first will do, but reserve ones with Tags
    for ( i = 0; i < advancePositions.length; ++i ) {
        if ( advancePositions[i].attacker == None &&
            advancePositions[i].node.ControllerTag == '')
        {
            return i;
        }
    }
    return -1;
}


// State: Init - stage may not be ready to engage player yet
// ---------------------------------------------------------
auto state Init {

   /**
    * During set up, we don't worry about casualties, but we do still
    * worry about whether the defensive line has been breached
    */
   function bool checkStageFailure() {
      //      return bDefenseBreached;
      return false;
   }

   /**
    */
   function Timer() {
      DebugLog( "starting defense" );
      /*
      if ( StageAgents.length < MinAttackers ) {
         // not enough agents to man the defense, but try anyways
         MinAttackers = StageAgents.length;
      }
      */
      GotoState( 'Defending' );
   }

BEGIN:
   DebugLog( "initializing" );
   //bDefenseBreached    = false;
   //bPlayerRepelled     = false;
   //MinAttackers        = default.MinAttackers;
   SetTimer( 30, false );

} // end state Init


// State: Defending - stage is defending against the player's advance
// ------------------------------------------------------------------
state Defending extends Engaged {

BEGIN:
   
REPEAT:
   Sleep( 3 );
   DebugLog( "Defending::DefenseStage state loop" );
   Goto( 'REPEAT' );

} // end state Defending


// State: Failed - defense has failed, attempting to retreat to the
//   failure stage.
// ----------------------------------------------------------------
state Retreating extends Failed {

} // end state Retreating


//===================
// Default Properties
//===================

defaultproperties
{
     DrawScale=3.000000
     Texture=Texture'VGSPAI.AdvanceStageIcon'
}
