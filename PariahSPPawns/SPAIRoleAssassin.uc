class SPAIRoleAssassin extends SPAIRole;

var SPAIAssassin myAI;

//locking vars
var bool bHaveTheLock;
var int CloseAttackDistance;

//shared static data use .default only!
var SPPawnShroudAssassin TheChargingAssassin;

function string GetDebugText(){
    return "enemy: " $ myAI.Enemy $
           " - lock: " $ bHaveTheLock $
           " - #: " $ class'AssassinMgr'.default.iNumberOfAssassins;
}


/*****************************************************************
 * PostLoadGame
 * Set it back to what it was
 *****************************************************************
 */
function PostLoadGame(){
    super.PostLoadGame();
    bHaveTheLock = false;
   class'SPAIRoleAssassin'.default.TheChargingAssassin = None;
}

/*****************************************************************
 * PostBeginPlay
 * As these guys are using 'static' data, if you die while one of them
 * has the lock then you restart, you end up locking the system. Ensure
 * it is unlocked before you start attacking.
 *****************************************************************
 */
function PostBeginPlay(){
    class'AssassinMgr'.default.bSpawnedAssassins = true;
    class'AssassinMgr'.default.iNumberOfAssassins++;
    super.PostBeginPlay();
}

/*****************************************************************
 * OnKilled
 *****************************************************************
 */
function OnKilled( Controller killer  ){
    ReleaseAttackLock();
    GotoState('Dead');
}

/*****************************************************************
 * PawnDied
 *****************************************************************
 */
function PawnDied(Pawn P) {
    ReleaseAttackLock();
    GotoState('Dead');
}

/*****************************************************************
 * AssaultApproachFailed
 * Immediately after spawn the bots can fail their assault attempts
 * and lose their enemies. This makes them a little zippier.
 *****************************************************************
 */
function AssaultApproachFailed() {
	myAI.Enemy = Level.RandomPlayerPawn();
    GotoState('Delay');
}

/*****************************************************************
 * GOTO_Attack
 * if there is no one else with this kind of role already attacking
 * then you can attack, otherwise just hold back and enjoy the show
 *****************************************************************
 */
function GOTO_Attack()
{
    //You are the man, blow the crap out of 'em
    if (( class'AssassinMgr'.default.iNumberOfAttacks <= class'AssassinMgr'.default.iAttacksBetweenCharge &&
        GetPawnToCharge() == none ) ||
        class'AssassinMgr'.default.bSpawnedBoss == false  )
    {
        if (AcquireAttackLock() == true){
            class'AssassinMgr'.default.iNumberOfAttacks++;
            GotoState('DiveAttack');
        } else {
            GotoState('HoldBack');
        }

    //awwww, you are not the man, helpout
    } else {
        if (GetPawnToCharge() == none){
           GotoState('HoldBack');
           //GotoState('Test');
        } else {
           GotoState('CombineAttack');
        }
    }
}


/*****************************************************************
 * GOTO_Relax
 *****************************************************************
 */
function GOTO_Relax(){
    GOTO_Attack();
}

state Delay{
BEGIN:
    Sleep(1);
    GOTO_Attack();
}

//=================================================================
// HoldBack
//=================================================================
state HoldBack{
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
    myAI.myPawn.Cloak();
    while(true){
        //myAI.Perform_NotEngaged_Wander();  WaitForNotification();
        myAI.Perform_Engaged_BackOff(); WaitForNotification();

        sleep(1);
        GOTO_Attack();
    }
}


//=================================================================
// DiveAttack
//=================================================================
state DiveAttack
{
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
    function AssaultApproachSucceeded() {
        SetTimer(0,false);
        //proceed on failure to find the player
        Notify();
    }
    function Timer(){
        Notify(); //obviously you are not capable of finding
                  //a path and you need a little coaxing!
    }


BEGIN:
    //get close
    SetTimer(5,false);
    myAI.Perform_Engaged_AssaultApproach(); WaitForNotification();
    myAI.myPawn.DeCloak();
    Sleep(1);
    //attack
    myAI.Perform_Engaged_DiveAttack(); WaitForNotification();
    //if close to the player
    //if (Vsize(myAI.myPawn.Location  - myAI.Enemy.Location) < CloseAttackDistance){
     //   myAI.Perform_Engaged_CloseAttack(); WaitForNotification();
    //}
DONE:
    ReleaseAttackLock();
    GotoState('HoldBack');
}


//=================================================================
// CombineAttack
//=================================================================
state CombineAttack{

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
    class'AssassinMgr'.default.CombinedAttackCount++;
    myAI.Perform_Engaged_CombinedAttack(); WaitForNotification();
    class'AssassinMgr'.default.CombinedAttackCount--;
    ReleaseAttackLock();
    GotoState('HoldBack');
}




//=================================================================
// Dead
//=================================================================
state Dead{
    function bool AcquireAttackLock(){return false;}
    function GOTO_Attack(){};
BEGIN:
    class'AssassinMgr'.default.iNumberOfAssassins--;
    ReleaseAttackLock();
    myAI.MyPawn.Tag = '';
    myAI.GotoState('Dead');
}

//=================================================================
// Helper Functions
//=================================================================


/*****************************************************************
 * AquireAttackLock
 * No real sophisticated way to do mutexes, but defaults work really
 * well for as static data for all instances. Be very careful with this
 * as there are no multiple acquires or anything cool like that.
 *****************************************************************
 */
function bool AcquireAttackLock(){
    if (class'AssassinMgr'.default.bAllowedToAttack == true || bHaveTheLock == true){
        class'AssassinMgr'.default.bAllowedToAttack = false;
        bHaveTheLock = true;
        return true;
    }
    return false;
}


/*****************************************************************
 * ReleaseAttackLock
 * Release the 'mutex'. Be sure you had it and that it matches
 * the acquire
 *****************************************************************
 */
function ReleaseAttackLock(){
    if (bHaveTheLock == true){
        bHaveTheLock = false;
        class'AssassinMgr'.default.bAllowedToAttack = true;
    }
}


/*****************************************************************
 * GetPawnToCharge
 *****************************************************************
 */
function SPPawnShroudAssassin GetPawnToCharge(){
    return  class'SPAIRoleAssassin'.default.TheChargingAssassin;
}

/*****************************************************************
 * SetPawnToCharge
 *****************************************************************
 */
function SetPawnToCharge(SPPawnShroudAssassin PawnToCharge){
    if (PawnToCharge != none){
        PawnToCharge.Tag = 'PrimeAssassin';
    }
    class'SPAIRoleAssassin'.default.TheChargingAssassin = PawnToCharge;
}



//=================================================================
// Default Properties
//=================================================================

defaultproperties
{
     CloseAttackDistance=1000
     bNeedPreLoad=True
}
