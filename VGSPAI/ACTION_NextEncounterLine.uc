/****************************************************************
 * ACTION_NextEncounter
 * 
 * MACRO action that rewrites the current script with a bunch of new
 * actions. This script is designed to get a bunch of guys from one
 * DEBAIT stage to another.
 *   
 * This subclass is optimized to get guys to the next stage with
 * minimal waypoint specification. All pawns doing this action go to
 * all waypoints in single file. 
 *
 * @author  Jesse LaChapelle (jesse@digitialextremes.com)
 * @version $Revision: 1.5 $
 * @date    Dec 2003
 ****************************************************************
 */
class ACTION_NextEncounterLine extends ACTION_NextEncounter;

//the number of seconds to hold back the next dude when staggering them
var(Action) float StaggerDelay;

//If your pawn tag matchs the waypoint then you do what the waypoint
//says to do
struct PawnInfo{
   var() name PawnTag;
   var() editinline Array<ScriptedAction> PawnActionList;
};

//Waypoints where ALL guys will go to
struct WayPoint{
   var() name DestinationTag;
   var() Array<PawnInfo> PawnActions;
};

//This is the list of all the point the dudes should go to
var(Action) Array<WayPoint> WayPoints;

//keeps track of where the stagger timer is currently
var int OrderDelay;
var bool bAddResetAction;


/****************************************************************
 * StartWalk
 * 
 * Lining a bunch of guys up means you don't want them to start at the
 * same time. We add a delay to each guy so that they all start at
 * different times. 
 ****************************************************************
 */
function StartWalk( Controller c ) 
{
   //initialize once only
   if (default.OrderDelay == -1) {
      default.OrderDelay = StaggerDelay;
      bAddResetAction = true;
   }

   ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_WaitForTimerTwo';
   ACTION_WaitForTimerTwo(ActionArray[ActionArray.Length-1]).PauseTime = default.OrderDelay;
  
   //increase the delay for other controllers
   default.Orderdelay = default.OrderDelay + StaggerDelay;
   Super.StartWalk( c );
}


/****************************************************************
 * DoWayPointStuff
 *
 * All pawns go to all the waypoints. IF the waypoint has additional
 * information for the pawn then the pawn will do those actions.
 ****************************************************************
 */
function DoWayPointStuff(ScriptedController C)
{
   local int i, j, k;
   
   //Move to all of your waypoints in turn
   for (i=0; i < waypoints.length; i++)
   {
      //if there are sub destinations required
      if (waypoints[i].DestinationTag != '')
      {
         ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_MoveToPoint';
         ACTION_MoveToPoint ( ActionArray[ActionArray.Length -1] ).DestinationTag = waypoints[i].DestinationTag;

         //For each action PawnInfo
         for (j = 0; j<waypoints[i].PawnActions.Length; j++)
         {
            //if the pawn tag matches this controller then there is
            //more to do
            if (c.Pawn.Tag == waypoints[i].PawnActions[j].PawnTag){

               //For each action
               for (k=0; k < waypoints[i].PawnActions[j].PawnActionList.Length; k++){
                  ActionArray[ActionArray.Length] = waypoints[i].PawnActions[j].PawnActionList[k];
               }
            }
         }
      }
   }

   Super.DoWayPointStuff(C);
}


/****************************************************************
 * PreJoinStage
 ****************************************************************
 */
function PreJoinStage( Controller c ){
  // This action must be added after a latent action, otherwise the 
  // reset will happen too quickly and there will be no stagger
   if (bAddResetAction == true){
      ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_ResetNextEncounterLine';
   }
   bAddResetAction = false;
}


/****************************************************************
 * DefaultProperties
 ****************************************************************
 */

defaultproperties
{
     OrderDelay=-1
     StaggerDelay=1.000000
     ActionString="NextEncounterLine"
}
