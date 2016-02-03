/****************************************************************
 * ACTION_ResetNextEncounterLine
 * 
 * @author  Jesse LaChapelle (jesse@digitialextremes.com)
 * @version $Revision: 1.2 $
 * @date    Dec 2003
 ****************************************************************
 */
class ACTION_ResetNextEncounterLine extends ScriptedAction;


/****************************************************************
 * InitActionsFor
 ****************************************************************
 */
function bool InitActionFor( ScriptedController c ) {

   local ACTION_NextEncounterLine tempAction;
   tempAction = new(c.Level) Class'ACTION_NextEncounterLine';
   tempAction.default.OrderDelay = -1;
   return false;   

}


/****************************************************************
 * DefaultProperties
 ****************************************************************
 */

defaultproperties
{
     ActionString="Reset Next Encounter"
}
