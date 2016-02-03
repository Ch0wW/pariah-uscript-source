class SPAIRoleStockton extends SPAIRole;



var SPAIStockton Stockton;

var int AccumDamage;


function OnMeleeRange() {} //stub out melee for now


//if stockton takes enough damage, make him attack back.  
function OnTakingDamage(Pawn Other, float Damage)
{

	AccumDamage+=Damage;

	if(AccumDamage > 20.0 && Stockton.CanGotoAttack())
	{
		//GOTO_AttackPlayer();
	}

}

function GOTO_AttackPlayer()
{
	GotoState('AttackPlayer');

}

function GOTO_FinishFight()
{
	SPPawnStockton(Stockton.Pawn).bAllowDeath=true;
	Stockton.Perform_PrepareForTheEnd();
	GotoState('Automated');
}

state AttackPlayer
{
	function PerformIdleOrder() {}
	function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }


    function BeginState() 
	{
		Stockton.Pawn.StopMoving();
	}

	function OnTakingDamage(Pawn Other, float Damage)
	{	}

BEGIN:
	curLabel='AttackPlayer';
	Stockton.Perform_AcquirePlayerAsEnemy();

	Stockton.Perform_SweepBeam();
	WaitForNotification();

	Stockton.Perform_Laugh();
	WaitForNotification();

	Stockton.Perform_AttackPlayer();
	WaitForNotification();


	curLabel='DoneAttack';
}



function GOTO_Relax()
{
	SinglePlayerController(Level.GetLocalPlayerController()).SetBossBarPawn(Stockton.Pawn);


	//GotoState('HangAtGens');

	//GotoState('TestSomething');
	

	GotoState('Automated');
}

state Automated
{
	function PerformIdleOrder() { }
	function SelectBehaviour() {}
    function PerformBehaviour() { }


BEGIN:
	curLabel='Automated';
	//Stockton.Perform_RaiseShield();
	Stockton.Perform_AcquirePlayerAsEnemy();
	Stockton.Perform_FindPosition(true);


}


function MoveToPositionSucceeded()
{
	Stockton.PickNewState();
}


function GOTO_NewStage()
{
	GotoState('Automated');
}

state HangAtGens
{
	function PerformIdleOrder() { }
	function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }


    function BeginState() {}

BEGIN:
	curLabel='HangAtGens';
	Stockton.Perform_AcquirePlayerAsEnemy();
	Stockton.Perform_FindPosition(); 
	WaitForNotification();
	//Stockton.Pawn.GotoState('ScaleUp');

	Stockton.Perform_FireAtCeiling();
	WaitForNotification();
	//GotoState('ChargeAtGens');
	Stockton.Perform_FindPosition(); 
	WaitForNotification();

	Stockton.Perform_AttackPlayer();
	WaitForNotification();
	GotoState('HangAtGens', 'BEGIN');
}

state TestSomething
{
	function PerformIdleOrder() { }
	function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }


    function BeginState() {}

BEGIN:
	curLabel='TESTING';
	Stockton.Perform_AcquirePlayerAsEnemy();
	Stockton.Perform_FindPosition(); 
	WaitForNotification();
	//Stockton.Pawn.GotoState('ScaleUp');

	Stockton.Perform_SweepBeam();
	WaitForNotification();
	//GotoState('ChargeAtGens');

	GotoState('TestSomething', 'BEGIN');
}


state ChargeAtGens
{
	function MoveToPositionSucceeded()
	{
		Notify();
	}

	function PerformIdleOrder() {}
	function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

	function EndState()
	{
		////make sure generator is not invulnerable
		//if(Stockton.currentGen != None)
		//{
		//	log("setting "$Stockton.currentgen$" not invulnerable");
		//	Stockton.currentGen.SetInvulnerable(false);
		//}
	}

BEGIN: 
	curLabel='ChargeAtGens';
	Stockton.Perform_Weakened();
	WaitForNotification();
FINDANDCHARGE:
	Stockton.Perform_FindGen();
	WaitForNotification();
	Stockton.Perform_ChargeUp();
	WaitForNotification();

	//Stockton.Perform_FireAtCeiling();
	GotoState('Automated');
}

function GOTO_Charge()
{
	GotoState('ChargeAtGens','FINDANDCHARGE');
}



function GOTO_Weakened()
{
	GotoState('ChargeAtGens', 'BEGIN');
}

defaultproperties
{
}
