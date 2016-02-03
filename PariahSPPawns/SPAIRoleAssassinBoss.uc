class SPAIRoleAssassinBoss extends SPAIRoleAssassin;


var SPAIAssassinBoss Assassin;

function OnMeleeRange() {} //stub out melee for now

function string GetDebugText(){
    //return string(class'AssassinMgr'.default.iNumberOfAssassins);
    return string(bot.Pawn.DesiredRotation);
}

/*****************************************************************
 * PostBeginPlay
 * Overridden so that spawning the boss assassin doesn't
 * set bSpawnedAssassin to true. NOTE: the intention lack of a
 * call to super.
 *****************************************************************
 */
function PostBeginPlay(){
    class'AssassinMgr'.default.bSpawnedBoss = true;
}


/*****************************************************************
 * OnKilled
 *****************************************************************
 */
function OnKilled( Controller killer  ){
    SetPawnToCharge(none);
    super.OnKilled(killer);

}

/*****************************************************************
 * PawnDied
 *****************************************************************
 */
function PawnDied(Pawn P) {
    SetPawnToCharge(none);
    super.PawnDied(p);
}

/*****************************************************************
 * GOTO_Attack
 * if there is no one else with this kind of role already attacking
 * then you can attack, otherwise just hold back and enjoy the show
 *****************************************************************
 */
function GOTO_Attack()
{
    //if there have been enough attacks by the assassins
    if (class'AssassinMgr'.default.iNumberOfAttacks >= class'AssassinMgr'.default.iAttacksBetweenCharge){
        SetPawnToCharge(myAI.myPawn);
        GotoState('LeadCombineAttack');

    //if you are the only one left
    } else if ( class'AssassinMgr'.default.iNumberOfAssassins <= 0 && //)//{//&&
                class'AssassinMgr'.default.bSpawnedAssassins == true){
        GotoState('DeathThroes');

    //otherwise just sit there ominously
    } else {
      	GotoState('FloatIdle');
    }
}


//=================================================================
// FloatIdle
//=================================================================
state FloatIdle
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
BEGIN:
    Assassin.Perform_Float();
    WaitForNotification();
	GOTO_Attack();
}



//=================================================================
// LeadCombineAttack
//=================================================================
state LeadCombineAttack{
    function OnKilled( Controller killer  ){
        ReleaseAttackLock();
        GotoState('Dead');
    }

   	function PawnDied(Pawn P) {
        ReleaseAttackLock();
        GotoState('Dead');
	}

    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

BEGIN:
    Assassin.Perform_Engaged_LeadCombinedAttack(); WaitForNotification();
    GOTO_Attack();
}


//=================================================================
// DeathThroes
//=================================================================
state DeathThroes{
    function OnKilled( Controller killer  ){
        ReleaseAttackLock();
        GotoState('Dead');
    }

   	function PawnDied(Pawn P) {
        ReleaseAttackLock();
        GotoState('Dead');
	}

    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

BEGIN:
    Sleep(1);
    //Assassin.Perform_FlyDown();
    //WaitForNotification();
    //SPPawnShroudAssassin(myAI.Pawn).SetInvinsible(false);

ATTACK:
    Assassin.Perform_Fire_Randomly();
    WaitForNotification();
    //GotoState('DeathThroes', 'ATTACK');'
    GOTO_Attack();
}

defaultproperties
{
}
