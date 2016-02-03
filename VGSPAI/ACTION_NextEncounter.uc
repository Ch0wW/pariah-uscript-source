/****************************************************************
 * ACTION_NextEncounter
 * 
 * MACRO action that rewrites the current script with a bunch of new
 * actions. This script is designed to get a bunch of guys from one
 * DEBAIT stage to another.
 * 
 * @author  Jesse LaChapelle (jesse@digitialextremes.com)
 * @version $Revision: 1.19 $
 * @date    Dec 2003
 ****************************************************************
 */
class ACTION_NextEncounter extends ScriptedAction;


//The name of the stage that they will join
var(Action) name StageName;
//The event that should be used to start them (if any)
var(Action) name ExternalEvent;
//use stage as waypoint
var(Action) bool bUseStageAsWayPoint;
//the length that guys should wait before moving to the next stage
var(Action) float RndDelayMax;
var(Action) float RndDelayMin;

//The list of new actions to perform
var array<ScriptedAction> ActionArray;

//the actual instance of the script that replaces the existing one
var DynamicSequence NewScript;



/****************************************************************
 * InitActionsFor
 * Does a bunch of wee actions
 ****************************************************************
 */
function bool InitActionFor( ScriptedController c ) {

   local int i;
   local ScriptedAction debugAction;

   NewScript = C.Spawn(class'DynamicSequence'); 
   NewScript.Actions.Length = 0;
   ActionArray.Length = 0;

   //   LogActionDetails(c); // debug
      
   //Set Alertness
   ActionArray[ActionArray.Length] =  new(c.Level) class'ACTION_SetAlertness';
   ACTION_SetAlertness (ActionArray[ActionArray.Length-1] ).Alertness = ALERTNESS_IgnoreAll;

   //Wait For Something
   WaitForSomething( c );

   //Do your walk
   //ActionArray[ActionArray.Length] = new (c.Level) Class'ACTION_Run';
   ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_Walk';

   //delay a wee bit
   StartWalk( c );

   //Go to all your way points
   DoWayPointStuff(c);

   if (bUseStageAsWayPoint){
      //Move to the next stage tag
      ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_MoveToStage';
      ACTION_MoveToStage ( ActionArray[ActionArray.Length -1] ).DestinationTag = StageName;
   }

   //Run into battle
   ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_Run';

   //notification that we are about to join a stage
   PreJoinStage( c );

   //Join the next stage
   ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_JoinStage';
   ACTION_JoinStage( ActionArray[ActionArray.Length -1] ).StageName = StageName;

   //leave the sequence
   ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_LeaveSequence';

   //add space to the action list, just after this action
   NewScript.Actions.insert(0,ActionArray.Length);

   //copy the local array into the real one that executes!
   for (i=0; i < ActionArray.Length; i++){
      debugaction = ActionArray[i];
      NewScript.Actions[i] = ActionArray[i];
   }

   //For each of the remaining actions in the original SequenceScript
   for (i=c.ActionNum+1; i< c.SequenceScript.Actions.Length; i++){
      debugaction=c.SequenceScript.Actions[i];
      NewScript.Actions[Newscript.Actions.Length]=c.SequenceScript.Actions[i];
   }

   c.ActionNum = 0;
   c.SetNewScript(NewScript);
   //   LogActionDetails(c); //debug
        
   return true;   

}

/****************************************************************
 * StartWalk
 ****************************************************************
 */

function StartWalk( Controller c ) 
{
   //nothing here, check the subclass...
}


/****************************************************************
 * DoWayPointStuff
 ****************************************************************
 */
function DoWayPointStuff(ScriptedController C)
{
   //nothing here, check the subclass...
}


/****************************************************************
 * PreJoinStage
 ****************************************************************
 */
function PreJoinStage( Controller c ){
}


/****************************************************************
 * WaitForSomething
 * You MUST wait for something. Otherwise you can get bumped into a
 * stage on your first actio and it starts rewriting your script on
 * you and really just bad bad stuff happens. Put a latent action in
 * and it all goes away!
 ****************************************************************
 */
function WaitForSomething( Controller c ){
   local bool waited;

   //optional Wait for event
   if ( ExternalEvent != ''){
      ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_WaitForEvent';
      ACTION_WaitForEvent ( ActionArray[ActionArray.Length -1] ).ExternalEvent = ExternalEvent;
      waited = true;
   }
   if ( RndDelayMax > 0 ){
      ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_WaitForTimer';
      ACTION_WaitForTimer ( ActionArray[ActionArray.Length -1] ).PauseTime = RndDelayMin + (FRand() * (RndDelayMax - RndDelayMin));
      waited = true;
   } 
   if (!waited) {
      ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_WaitForTimer';
      ACTION_WaitForTimer ( ActionArray[ActionArray.Length -1] ).PauseTime = 0.01;
   }

}


/****************************************************************
 * LogActionDetails
 ****************************************************************
 */
function LogActionDetails(ScriptedController C){
   local int i;

   Log (C $ C.Pawn.Tag);
   for (i=0; i< c.SequenceScript.Actions.Length; i ++){
      Log ("Action: " $ c.SequenceScript.Actions[i] );
      if (ACTION_WaitForTimer(c.SequenceScript.Actions[i]) !=None){
         Log ("timer param: " $ACTION_WaitForTimer( c.SequenceScript.Actions[i] ).PauseTime);
      }
   }
}



/****************************************************************
 * GetActionString
 ****************************************************************
 */
function string GetActionString() {
   return ActionString;
}


/****************************************************************
 * DefaultProperties
 ****************************************************************
 */

defaultproperties
{
     RndDelayMax=8.000000
     RndDelayMin=4.000000
     bUseStageAsWayPoint=True
     ActionString="Next Encounter"
}
