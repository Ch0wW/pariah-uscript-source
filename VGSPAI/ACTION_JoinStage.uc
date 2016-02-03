/**
 * Causes the controller to join a stage.  
 * 
 * @author  Neil Gower (neilg@digitialextremes.com)
 * @version $Revision: 1.1 $
 * @date    July 2003
 */
class ACTION_JoinStage extends ScriptedAction;


var(Action) name StageName;


/**
 * Ugh this is slow!
 */
function bool InitActionFor( ScriptedController c ) {
   local Stage s;
   ForEach c.AllActors( class'Stage', s ) {
      if ( s.StageName == StageName ) break;
   }
   if ( s != None ) s.joinStage( VGSPAIController(c) );
   return false;	
}

function string GetActionString() {
   return ActionString@StageName;
}

defaultproperties
{
     ActionString="join stage"
}
