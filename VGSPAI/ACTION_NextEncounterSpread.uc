/****************************************************************
 * ACTION_NextEncounter
 * 
 * MACRO action that rewrites the current script with a bunch of new
 * actions. This script is designed to get a bunch of guys from one
 * DEBAIT stage to another.
 * 
 * This subclass optimizes the work for for the guys to spread out
 * during the transition from one stage to another. LD's must specify
 * waypoints for ALL the pawns that they are controlling, otherwise
 * pawns walk immediately and directly to the next stage.
 *
 * @author  Jesse LaChapelle (jesse@digitialextremes.com)
 * @version $Revision: 1.4 $
 * @date    Dec 2003
 ****************************************************************
 */
class ACTION_NextEncounterSpread extends ACTION_NextEncounter;

//Waypoints can specify a list of actions
struct WayPoint{
   var() name DestinationTag;
   var() editinline Array<ScriptedAction> Actions;
};

//Each pawn gets a list of waypoints
struct PawnPath{
   var() name PawnTag;
   var() Array<WayPoint> WayPoints;
};

//This is the list of all the point the dudes should go to
var(Action) Array<PawnPath> PawnPaths;


/****************************************************************
 * DoWayPointStuff
 *
 * Each pawn has a list of waypoints that is just for it. The pawn
 * will go to each of these waypoints in order and complete the
 * actions that are listed for it at that point.
 ****************************************************************
 */
function DoWayPointStuff(ScriptedController C)
{
   local int i, j, k;
   
   //For each pawn path
   for (i=0; i<PawnPaths.length;i++){
      //if this is the pawn you control
      if (C.Pawn.Tag == PawnPaths[i].PawnTag){
         //for each waypoint
         for (j=0; j<PawnPaths[j].WayPoints.Length;j++){

            //Build and action to go to the waypoint         
            ActionArray[ActionArray.Length] = new(c.Level) Class'ACTION_MoveToPoint';
            ACTION_MoveToPoint(ActionArray[ActionArray.Length-1]).DestinationTag = PawnPaths[i].WayPoints[j].DestinationTag;

            //do each action in the waypoint   
            for (k=0; k < PawnPaths[i].WayPoints[j].Actions.Length; k++){
               ActionArray[ActionArray.Length] = PawnPaths[i].WayPoints[j].Actions[k];
            }
         }
      }
   }
   Super.DoWayPointStuff(C);
}



/****************************************************************
 * DefaultProperties
 ****************************************************************
 */

defaultproperties
{
     ActionString="NextEncounterSpread"
}
