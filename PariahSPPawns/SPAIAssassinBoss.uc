/*****************************************************************
 * SPAIAssassinBoss
 * Author: Prof. Jesse LaChapelle
 * Most of the co-ordination is done by use of the default properties
 * as static data. Once Assassins are spawned then this dude goes into action
 * once enough 'dive attacks' have occured the boss sets themselves as the one
 * to charge up and the little dudes 'charge' the boss up. Once enough time has
 * passed a wicked cool beam shoots the player.
 *
 * Once all the little dudes are dead the boss just starts freaking out shooting
 * at where ever the player is, giving just enough delay that the player can get
 * out of the way if they keep moving.
 *****************************************************************
 */
class SPAIAssassinBoss extends SPAIAssassin;

var AssassinBossCloak Cloak;
var enum MyAnimState
{
	AS_Idle,
	AS_AttackStart,
	AS_AttackLoop,
	AS_AttackEnd
}AnimState;


var bool bfloating;
var float MaxFloatHeight;
var float RunningFloatHeight;
var float floatRate;
var vector floatVector;

var sound BeamLoopSound;
var vector SavedPlayerLocation;
var bool bCharging;

const BOSS_HEAL = 1122;


/*****************************************************************
 * PostBeginPlay
 *****************************************************************
 */
function PostBeginPlay(){
    super.PostBeginPlay();
    FloatVector = Vect(0,0,-1) * FloatRate;
}


/*****************************************************************
 * InitAiRole
 *****************************************************************
 */
function InitAIRole()
{
	Super.InitAIRole();
	SinglePlayerController(Level.GetLocalPlayerController()).SetBossBarPawn(Pawn);
    //SPPawnShroudAssassin(Pawn).Cloak();
    //SPPawnShroudAssassin(Pawn).SetInvinsible(true);
	SPAIRoleAssassinBoss(myAIRole).Assassin = self;
}

/*****************************************************************
 * Possess
 * Attack to your cloack
 *****************************************************************
 */
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	Cloak = SPPawnAssassinBoss(aPawn).TheCloak;
}

/*****************************************************************
 * Perform_AcquirePlayerAsEnemy
 *****************************************************************
 */
function Perform_AcquirePlayerAsEnemy()
{
	Enemy = Level.RandomPlayerPawn();
}

/*****************************************************************
 * SetupFire
 * Prepare yourself to fire the death beam
 *****************************************************************
 */
function SetUpFire(){
    bFire = 0;
    bAltFire = 1;
    bReloading = false;
    bPlayingHit = false;
    ReflexTime = 0;
    MinNumShots=100;
	MaxNumShots=100;
	MinShotPeriod=0.3;
	MaxShotPeriod=0.5;
}

/*****************************************************************
 * PlayAnimState
 *****************************************************************
 */
function PlayAnimState(MyAnimState s)
{
	switch(s)
	{
	case AS_Idle:
    	Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
		Pawn.PlayAnim('Assasin_idle_float',,,ATTACK_CHANNEL);
		Cloak.PlayAnim('cloak_idle_breathe');

		break;
	case AS_AttackStart:
    	Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
		Pawn.PlayAnim('Assasin_prefire_float',,,ATTACK_CHANNEL);
		Cloak.PlayAnim('cloak_prefire_float');

		break;
	case AS_AttackLoop:
       	Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
		Pawn.PlayAnim('assasin_fireloop_float',,,ATTACK_CHANNEL);
		Cloak.PlayAnim('cloak_fireloop_float');

		break;
	case AS_AttackEnd:
    	Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
		Pawn.PlayAnim('assasin_fireend_float',0.8,,ATTACK_CHANNEL);
		Cloak.PlayAnim('cloak_fireend_float');

		break;

	}
}


/*****************************************************************
 * ApplyHealth
 * modelled after the apply heath that the healing tool uses.
 *****************************************************************
 */
function ApplyHealth(){
    local Pawn ThePlayer;
    ThePlayer = Level.RandomPlayerPawn();
    ThePlayer.GiveHealth(1,ThePlayer.HealthMax);
}

//=================================================================
// Perform_Float
//=================================================================
function Perform_Float(){
    GotoState('FloatIdle');
}

//=================================================================
// FloatIdle
//=================================================================
state FloatIdle
{
    function EndState(){
        Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
    }

	function AnimEnd(int channel){
        if ( Channel == ATTACK_CHANNEL ){
            Notify();
        } else {
            Global.AnimEnd(Channel);
        }
	}
BEGIN:
    //SPPawnShroudAssassin(Pawn).Cloak();
	PlayAnimState(AS_Idle);
	WaitForNotification();
    myAIRole.chargeSucceeded();
}



//=================================================================
// Perform_Engaged_LeadCombinedAttack
//=================================================================
function Perform_Engaged_LeadCombinedAttack(){
    GotoState('Engaged_LeadCombinedAttack');
}

//=================================================================
// STATE Engaged_LeadCombinedAttack
//=================================================================
state Engaged_LeadCombinedAttack{

    function BeginState(){
        SPPawnShroudAssassin(Pawn).SetInvinsible(true);
    }

    function EndState(){
        Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
        enable('NotifyBump');
        SPPawnShroudAssassin(Pawn).SetInvinsible(false);
    }

    function AnimEnd(int Channel) {
        if ( Channel == ATTACK_CHANNEL ){
            Notify();
        } else {
            Global.AnimEnd(Channel);
        }
    }

    function NotifyTakeHit(pawn InstigatedBy, vector HitLocation,
                            int Damage, class<DamageType> damageType,
                            vector Momentum)
    {
        //can only abort during a charge
        if (bCharging == true){
            SPAIRoleAssassin(myAIRole).SetPawnToCharge(None);
            GotoState('Engaged_LeadCombinedAttack', 'DONE');
        }
    }

    function MultiTimer(int ID){
        if (ID == BOSS_HEAL){
            //give the boss as much health as there are beams per
            Pawn.GiveHealth(class'AssassinMgr'.default.CombinedAttackCount * 10,Pawn.HealthMax);
        } else {
            super.Multitimer(ID);
        }
    }

BEGIN:
    StopFireWeapon();
    Pawn.StopMoving();
    Focus = Level.RandomPlayerPawn();
    FinishRotation();
    exclaimMgr.Exclaim(EET_Idle, RandRange(6, 10));
    SPPawnShroudAssassin(Pawn).SpawnChargeUpBeam();
    SetupFire();
    Pawn.LockRootMotion(0);

    bCharging = true;
    SetMultiTimer(BOSS_HEAL, 0.8, true);
    for ( counter = 0; counter< ChargeUpTime; counter++)  {
        //bail if charging has been aborted
        if (SPAIRoleAssassin(myAIRole).GetPawnToCharge() == none){
            break;
        }
        PlayAnimState(AS_Idle);
        WaitForNotification();
    }
    SetMultiTimer(BOSS_HEAL, 0, false);
    bCharging = false;
    PlayAnimState(AS_AttackStart);
    WaitForNotification();
    PlayAnimState(AS_AttackLoop);

    //For the Explosion effect
    //--------------
    SPPawnShroudAssassin(Pawn).SpawnExplosion( class'AssassinMgr'.default.CombinedAttackCount + 1 );
//    Log("Spawning and explosion of size: " $  class'AssassinMgr'.default.CombinedAttackCount + 1);

    //For the Beam effect
    //--------------
    //StartFireWeapon();
    //Spawn(class'AssassinBurst',,,Pawn.Location);
    //Sleep(class'AssassinMgr'.default.CombinedAttackCount + 1);
    //StopFireWeapon();

    PlayAnimState(AS_AttackEnd);
    WaitForNotification();

DONE:
    class'AssassinMgr'.default.iNumberOfAttacks = 0;
    SPAIRoleAssassin(MyAIRole).SetPawnToCharge(None);
    SPPawnShroudAssassin(Pawn).EndChargeUpBeam();
//    Sleep(3);
    myAIRole.chargeSucceeded();
}



//=================================================================
// Perform_FlyDown
//=================================================================
function Perform_FlyDown(){
    GotoState('Engaged_FlyDown');
}

//=================================================================
// STATE Engaged_FlyDown
//=================================================================
state Engaged_FlyDown{
ignores SeePlayer;

    function BeginState(){}

    function EndState(){
        Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
        enable('NotifyBump');
    }

    function AnimEnd(int Channel) {
        if ( Channel == ATTACK_CHANNEL ){
            Notify();
        } else {
            Global.AnimEnd(Channel);
        }
    }

     event Tick(float dt){
          super.Tick(dt);

          if (bfloating){
              Pawn.MoveSmooth(FloatVector * dt);
              RunningFloatHeight += FloatRate * dt;
          }
      }


BEGIN:
    Pawn.LockRootMotion(0);
    Pawn.SetPhysics(PHYS_Projectile);
    RunningFloatHeight = 0;
    bfloating = true;

    for ( counter = 0; counter< 3; counter++)  {
        PlayAnimState(AS_Idle);
        WaitForNotification();
    }
    bfloating = false;
    myAIRole.chargeSucceeded();
}



//=================================================================
// Perform_Fire_Randomly
//=================================================================
function Perform_Fire_Randomly(){
    GotoState('Engaged_Fire_Randomly');
}

//=================================================================
// STATE Engaged_Fire_Randomly
//=================================================================
state Engaged_Fire_Randomly{
ignores SeePlayer;

    function Rotator Aim( Ammunition FiredAmmunition, vector projStart, int aimerror ){
//        Log("Aim is called");
        return rotator(SavedPlayerLocation - Pawn.Location);
    }

    function BeginState(){}

    function EndState(){
        Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
        enable('NotifyBump');
    }

    function AnimEnd(int Channel) {
        if ( Channel == ATTACK_CHANNEL ){
            Notify();
        } else {
            Global.AnimEnd(Channel);
        }
    }

    function Tick(float dt){
        if (bCharging){
            SavedPlayerLocation.X += (Enemy.Location.X - SavedPlayerLocation.X) * 5 * dt;
            SavedPlayerLocation.Y += (Enemy.Location.Y - SavedPlayerLocation.Y) * 5 * dt;
            SavedPlayerLocation.Z += (Enemy.Location.Z - SavedPlayerLocation.Z) * 5 * dt;
           // Log(SavedPlayerLocation);
        }
        super.Tick(dt);
    }

BEGIN:

    Pawn.RotationRate = rot(0,200,2048);
    Focus = Level.RandomPlayerPawn();
    FocalPoint = Focus.Location;
    FinishRotation();
    Pawn.StopMoving();
    SavedPlayerLocation = Level.RandomPlayerPawn().Location;
    Focus = none;
    Spawn(class'AssassinBurst',,,Pawn.Location);
    PlayAnimState(AS_AttackStart);
    WaitForNotification();
    PlayAnimState(AS_AttackLoop);
    //yup we play it twice.
    Pawn.PlaySound(BeamLoopSound,SLOT_Misc);
    Pawn.PlaySound(BeamLoopSound,SLOT_Misc);
    SetupFire();
    bIgnoreNeedToTurn=true;
    StartFireWeapon();
    bCharging = true;
        Sleep(0.5);
        PlayAnimState(AS_AttackEnd);
    bCharging = false;
    StopFireWeapon();
    //Pawn.PlaySound(BeamLoopSound, SLOT_Misc, 0);
    WaitForNotification();
    Focus = Level.RandomPlayerPawn();
    myAIRole.chargeSucceeded();
}





//=================================================================
// defaultProperties
//=================================================================

defaultproperties
{
     MaxFloatHeight=240.000000
     floatRate=35.000000
     BeamLoopSound=Sound'BossFightSounds.Assassin.AssassinBeamFireLoop'
     MinNumShots=10
     MaxNumShots=10
     MaxLostContactTime=1.000000
     MinShotPeriod=0.400000
     MaxShotPeriod=6.000000
}
