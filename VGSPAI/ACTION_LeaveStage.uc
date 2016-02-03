/**
 * Causes the controller to leave the stage it is currently a member of.
 * 
 * @author  Neil Gower (neilg@digitialextremes.com)
 * @version $Revision: 1.1 $
 * @date    July 2003
 */
class ACTION_LeaveStage extends ScriptedAction;


var(Action) Stage.EReason Reason;


function bool InitActionFor( ScriptedController sc ) {
   local VGSPAIController c;
   c = VGSPAIController( sc );
   if ( c != None ) c.currentStage.leaveStage( c, Reason );
   return false;	
}

function string GetActionString() {
   return ActionString@Reason;
}

defaultproperties
{
     Reason=RSN_Scripted
     ActionString="leave stage"
}
