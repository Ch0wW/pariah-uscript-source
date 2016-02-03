class VGSPAIBase extends ScriptedController
    native;

////////////////////////////
// This class just provides some glue to allow us to use ScriptedSequences on placed bots
// who might then leave scripting for our algorithms.
////////////////////////////

////////////////////////////
// Scripted Sequence related
var UnrealScriptedSequence GoalScript;	// ScriptedSequence bot is
                                        // moving toward (assigned by
                                        // TeamAI)
var UnrealScriptedSequence OldGoalScript;
var UnrealScriptedSequence EnemyAcquisitionScript;

////////////////////////////

////////////////////////////
// Called from Possess() when the controller gets a pawn
///////////////////////////
function Restart()
{
	Super.Restart();
	Pawn.SetMovementPhysics(); 
	GotoState('bullshit');
}

//All this does is ensure we don't do anything 'till the game starts.
state bullshit
{
BEGIN:
	WaitForLanding();
	SelectAction();
}

function Wander();

function SelectAction()
{
	// Scripting
	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;
}


///////////////////////////
//  Scripting related functions
//  Override from ScriptedController so that pawns may start 
//  out being scripted, then leave scripting to be autonomous
///////////////////////////
function SetEnemyReaction(int AlertnessLevel)
{
	ScriptedCombat = FOLLOWSCRIPT_IgnoreEnemies;
	if ( AlertnessLevel == 0 )
	{
		ScriptedCombat = FOLLOWSCRIPT_IgnoreAllStimuli;
		bGodMode = true;
	}
	else
		bGodMode = false;

	if ( AlertnessLevel < 2 )
	{
		Disable('HearNoise');
		Disable('SeePlayer');
		Disable('SeeMonster');
		Disable('NotifyBump');
	}
	else
	{
		Enable('HearNoise');
		Enable('SeePlayer');
		Enable('SeeMonster');
		Enable('NotifyBump');
		if ( AlertnessLevel == 2 )
			ScriptedCombat = FOLLOWSCRIPT_StayOnScript;
		else
			ScriptedCombat = FOLLOWSCRIPT_LeaveScriptForCombat;
	}
}

/**
 */
function SetNewScript(ScriptedSequence NewScript)
{
    Super.SetNewScript(NewScript);
    // Clobber old script with new one... let the garbage collector
    // deal with the old script.
    GoalScript = UnrealScriptedSequence(SequenceScript);
    if ( GoalScript != None ) {
        if ( FRand() < GoalScript.EnemyAcquisitionScriptProbability ){
            EnemyAcquisitionScript = GoalScript.EnemyAcquisitionScript;
        } else {
            EnemyAcquisitionScript = None;
        }
    }
}

/**
 */
function FreeScript()
{
	if ( GoalScript != None )
	{
           OldGoalScript = GoalScript;
	   GoalScript.FreeScript();
	   GoalScript = None;
	}
}

function bool ScriptingOverridesAI()
{
	return ( (GoalScript != None) && (ScriptedCombat <= FOLLOWSCRIPT_StayOnScript) );
}

function bool ShouldPerformScript()
{
	if ( GoalScript != None )
	{
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_LeaveScriptForCombat) )
		{
			SequenceScript = None;
			ClearScript();
			return false;
		}
		if ( SequenceScript != GoalScript )
			SetNewScript(GoalScript);
		GotoState('Scripting','Begin');
		return true;
	}
	return false;
}

State Scripting
{
	ignores EnemyNotVisible;

	function Restart() {}

	function Timer()
	{
           if (CurrentAction != None){
		Super.Timer();
           }
	   enable('NotifyBump');
	}

	function CompleteAction()
	{
		CurrentAction.ProceedToNextAction(self); //ActionNum++;
		// mh ---
		//WhatToDoNext(39);
		SelectAction();
                //GotoState('Scripting','Begin'); //@@@ jesse testing
                                                //staggering pawn walks
		// --- mh
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function LeaveScripting()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		// mh ---
		//Global.WhatToDoNext(40);
		SelectAction();
		// --- mh
	}

	function EndState()
	{
		Super.EndState();
		// mh ---
		//SetCombatTimer();		
		// --- mh
		if ( (Pawn != None) && (Pawn.Health > 0) )
		{	Pawn.bPhysicsAnimUpdate = true;
			bGodMode = false;
		}
	}

	function AbortScript()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
			FreeScript();

        // mh ---
		Wander();
        SelectAction();
        // --- mh
	}
	function SetMoveTarget()
	{
        Super.SetMoveTarget();
		if ( Pawn.ReachedDestination(Movetarget) && MoveTarget == CurrentAction.GetMoveTargetFor(self))
		{
            ActionNum++;
			GotoState('Scripting','Begin');
			return;
		}
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_StayOnScript) )
		{	// mh ---
			//GotoState('Fallback');
			SelectAction(); 
			// --- mh
		}

	}

	function MayShootAtEnemy()
	{
		if ( Enemy != None )
		{
			Target = Enemy;
			GotoState('Scripting','ScriptedRangedAttack'); 
		}
	}

ScriptedRangedAttack:
	// mh ---
	// GoalString = "Scripted Ranged Attack";
	// --- mh
	Focus = Enemy;
	WaitToSeeEnemy();
	if ( Target != None )
		FireWeaponAt(Target);
}
//////////////////////////
// end of scripting crap
//////////////////////////

defaultproperties
{
     bIsPlayer=True
}
