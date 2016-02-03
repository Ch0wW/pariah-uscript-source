class SPAIAssassin extends SPAIController;


const ATTACK_CHANNEL = 3;

var name SpinDive;
var name ChargeBlades;
var name Recover;
var name FlipKick;
var name ElbowSmash;
var name RoundHouse;
var name JumpKick;
var name CloakAttack;

var int counter;
var float Distance;
var bool bBailOnDive;
var int ChargeUpTime;
var float CloseAttackRate;

var int ChargeRate;
var int JumpRate;
var int CloseDistanceRate;
var bool bPlayedAcquire;
var class<Emitter> SlashEmitter;

var SPPawnShroudAssassin myPawn;

/*****************************************************************
 * PostBeginPlay
 *****************************************************************
 */
function PostBeginPlay(){
    super.PostBeginPlay();
  	Enemy = Level.RandomPlayerPawn();
}

/*****************************************************************
 * Perform_AcquirePlayerAsEnemy
 *****************************************************************
 */
function Perform_AcquirePlayerAsEnemy(){
	Enemy = Level.RandomPlayerPawn();
}


/*****************************************************************
 * AcquireEnemy
 *****************************************************************
 */
function AcquireEnemy(Pawn potentialEnemy, bool bCanSeePotEnemy){
//    super.AcquireEnemy(potentialEnemy, bCanSeePotEnemy);
    if (bPlayedAcquire == false){
        exclaimMgr.Exclaim(EET_AcquireEnemy, 0);
        bPlayedAcquire = true;
    }
	Enemy = Level.RandomPlayerPawn();
}


function NotifyTakeHit(pawn InstigatedBy, vector HitLocation,
                            int Damage, class<DamageType> damageType,
                            vector Momentum)

{
    super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
    exclaimMgr.Exclaim(EET_Pain, RandRange(0, 0.2) );
}


//=================================================================
// Perform_Engaged_DiveAttack
//=================================================================
function Perform_Engaged_DiveAttack()
{
    GotoState('Engaged_DiveAttack');
}

//=================================================================
// STATE Engaged_DiveAttack
//=================================================================
state Engaged_DiveAttack
{
    function BeginState(){}

    function EndState(){
        Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
        enable('NotifyBump');
    }

    function AnimEnd(int Channel){
        if ( Channel == ATTACK_CHANNEL ){
            Notify();
        } else {
            Global.AnimEnd(Channel);
        }
    }

    event bool NotifyBump(actor Other){
        local Pawn P;

        bBailOnDive = true;
        if(!Other.IsA('Pawn'))
            return false;

     //   P = Pawn(Other);
     //   if(Enemy == P) {
    //        disable('NotifyBump');
     //       Enemy.TakeDamage(25, Pawn, Enemy.Location, 300*Vector(Pawn.Rotation), class'VehicleWeapons.BoneSawDamage');
     //       Enemy.Controller.DamageShake(100);
     //   } else {
            AdjustAround(P);
     //   }
    }



   function Notify_Melee(){
       local Emitter temp;
       if( VSize(Enemy.Location - Pawn.Location) < Pawn.CollisionRadius*8 )
        {
            Enemy.TakeDamage(15, Pawn, Enemy.Location, 100*Vector(Pawn.Rotation), class'VehicleWeapons.BoneSawDamage');
            temp = Spawn(SlashEmitter,,, Enemy.Location);
   			Enemy.AttachToBone(temp,'bip01');
            Enemy.Controller.DamageShake(50);
		}
    }


BEGIN:

    setCurAction("DIVEATTACK");
    exclaimMgr.Exclaim(EET_Attacking, RandRange(0, 0.1) );
DIVE:
    StopFireWeapon();
    Pawn.StopMoving();
    Focus = Enemy;
    bBailOnDive = false;
    FinishRotation();
    Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);

    Pawn.PlayAnim(ChargeBlades, , ,ATTACK_CHANNEL);
	WaitForNotification();

    GotoState('Engaged_DiveAttack', 'JUMP');

JUMP:
    PrepareJumpAttack();
    Pawn.PlayAnim(JumpKick,1.2 , ,ATTACK_CHANNEL);
    Sleep(0.1);
    //Pawn.bCollideWorld = true;
    WaitForNotification();
    GotoState('Engaged_DiveAttack', 'POSTATTACK');

POSTATTACK:
    //Pawn.PlayAnim(Recover,0.7,0.2,ATTACK_CHANNEL);
	//WaitForNotification();
	ResetPawnMovement();
	Focus = Enemy;
    Pawn.AnimBlendToAlpha(ATTACK_CHANNEL, 0, 0.4);
    Sleep(0.2);
DONE:
    myAIRole.chargeSucceeded();
}

/*****************************************************************
 * ResetPawnMovement
 *****************************************************************
 */
function ResetPawnMovement(){
	Pawn.SetPhysics(PHYS_Walking);
    Pawn.StopMoving();
    Pawn.bCollideWorld = Pawn.default.bCollideWorld;
    Pawn.RotationRate = Pawn.default.RotationRate;
    Pawn.GroundSpeed = Pawn.default.GroundSpeed;
}

/*****************************************************************
 * PrepareJumpAttack
 *****************************************************************
 */
function PrepareJumpAttack(){
    Focus = None;           //Prevents the ot from turning while flying
    Pawn.LockRootMotion(0); // <- This seemed to make the character move.!?
    Pawn.SetPhysics(PHYS_Falling);
   // Pawn.bCollideWorld = false;
    Pawn.Velocity = vector(Pawn.Rotation)*JumpRate + vect(0,0,300);
    Pawn.RotationRate = rot(0,0,0);
    Pawn.GroundSpeed = JumpRate;
}

/*****************************************************************
 * PrepareSpinAttack
 *****************************************************************
 */
function PrepareSpinAttack(){
    Focus = None;           //Prevents the ot from turning while flying
    Pawn.LockRootMotion(0); // <- This seemed to make the character move.!?
    Pawn.Acceleration = vector(Pawn.Rotation)*ChargeRate;
    Pawn.Velocity = vector(Pawn.Rotation)*ChargeRate;
    Pawn.RotationRate = rot(0,0,0);
    Pawn.GroundSpeed = ChargeRate;
}


//=================================================================
// Perform_Engaged_CloseAttack
//=================================================================
function Perform_Engaged_CloseAttack(){
    GotoState('Engaged_CloseAttack');
}

//=================================================================
// STATE Engaged_CloseAttack
//=================================================================
state Engaged_CloseAttack
{
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

    function Notify_Melee(){
        if( VSize(Enemy.Location - Pawn.Location) < Pawn.CollisionRadius*4 )
        {
            Enemy.TakeDamage(15, Pawn, Enemy.Location, 100*Vector(Pawn.Rotation), class'VehicleWeapons.BoneSawDamage');
            Enemy.Controller.DamageShake(50);
		}
    }

BEGIN:
    setCurAction("CLOSEATTACK");
DIVE:
    StopFireWeapon();
    Pawn.StopMoving();
    Focus = Enemy;
    FinishRotation();
    Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);

    CloseDistance();
    exclaimMgr.Exclaim(EET_Attacking, RandRange(0, 0.1) , 0.5);
    Pawn.PlayAnim(FlipKick,CloseAttackRate, ,ATTACK_CHANNEL);
	WaitForNotification();

    CloseDistance();
     exclaimMgr.Exclaim(EET_Attacking, RandRange(0, 0.1) , 0.5);
    Pawn.PlayAnim(ElbowSmash,CloseAttackRate, ,ATTACK_CHANNEL);
	WaitForNotification();

    CloseDistance();
    exclaimMgr.Exclaim(EET_Attacking, RandRange(0, 0.1) , 0.5);
    Pawn.PlayAnim(RoundHouse,CloseAttackRate, ,ATTACK_CHANNEL);
	WaitForNotification();
	ResetPawnMovement();
    Sleep(0.2);
DONE:
    myAIRole.chargeSucceeded();
}


/*****************************************************************
 * CloseDistance
 *****************************************************************
 */
function CloseDistance(){
    Pawn.LockRootMotion(0); // <- This seemed to make the character move.!?
    Pawn.Acceleration = (Enemy.Location - Pawn.Location)*CloseDistanceRate;
    Pawn.Velocity =( Enemy.Location - Pawn.Location)*CloseDistanceRate;
    Pawn.GroundSpeed = JumpRate;
}


//=================================================================
// Perform_Engaged_CombinedAttack
//=================================================================
function Perform_Engaged_CombinedAttack(){
    GotoState('Engaged_CombinedAttack');
}

//=================================================================
// STATE Engaged_CombinedAttack
//=================================================================
state Engaged_CombinedAttack{
ignores SeePlayer;

    function BeginState(){}

    function EndState(){
        Focus = Enemy;
        SPPawnShroudAssassin(Pawn).EndChargeUpBeam();
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

    function NotifyTakeHit(pawn InstigatedBy, vector HitLocation,
                            int Damage, class<DamageType> damageType,
                            vector Momentum)
    {
        //if you are the guy being charged then call the whole thing off
        GotoState('Engaged_CombinedAttack', 'DONE');
    }

BEGIN:
    StopFireWeapon();
    Pawn.StopMoving();
    Sleep(0.7);
    Focus = SPAIRoleAssassin(myAIRole).GetPawnToCharge();
    FinishRotation();
    Pawn.AnimBlendParams(ATTACK_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
    Pawn.PlayAnim(CloakAttack, , ,ATTACK_CHANNEL);
    SPPawnShroudAssassin(Pawn).SpawnHelperBeam();
    for ( counter = 0; counter< ChargeUpTime + 3; counter++)
    {
        //bail if the guy charging has completed
        if (SPAIRoleAssassin(myAIRole).GetPawnToCharge() == none){
            break;
        }
        Focus = SPAIRoleAssassin(myAIRole).GetPawnToCharge();
        Pawn.PlayAnim(CloakAttack, , ,ATTACK_CHANNEL);
        WaitForNotification();
    }
    //SPPawnShroudAssassin(Pawn).DoChargeUpExplosion();

DONE:
    Focus = Enemy;
    SPPawnShroudAssassin(Pawn).EndChargeUpBeam();
    myAIRole.chargeSucceeded();
}




/*****************************************************************
 * ChargingPawn
 * returns if you are the pawn that is being charged
 *****************************************************************
 */
function bool ChargingPawn(){
    return (SPAIRoleAssassin(myAIRole).GetPawnToCharge() == myPawn);
}

/*****************************************************************
 * Restart
 *****************************************************************
 */
function Restart()
{
    Super.Restart();
   SPAIRoleAssassin(myAIRole).myAI = self;
   myPawn=SPPawnShroudAssassin(Pawn);
}


/*****************************************************************
 * PawnDied
 *****************************************************************
 */
function PawnDied( Pawn p ) {
    if(myAIRole != None){
        SPAIRoleAssassin(myAIRole).OnKilled( none );
   }
}


/*****************************************************************
 * DrawHUDDebug
 * When called, will draw debug text above the bots head
 *****************************************************************
 */
function DrawHUDDebug(Canvas C)
{
    local vector screenPos;
    local String T;
    local name anim;
	local float frame,rate;

    if (!bDebugLogging || Pawn == None) return;
    screenPos = WorldToScreen( Pawn.Location
                               + vect(0,0,1)*Pawn.CollisionHeight );
    if (screenPos.Z > 1.0) return;
    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    C.DrawText( myAIROle.GetDebugText());
//    C.DrawText(Pawn.Physics);
//    C.DrawText(Pawn.Velocity);
    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-12);
    C.DrawText( curAction );

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y);
    if(Enemy != None) {
        C.DrawText( ChanceToHit() @ LatentFloat @ VSize(Enemy.Location - Pawn.Location) );
    } else {
        C.DrawText( ChanceToHit() @ LatentFloat);
    }
    Pawn.GetAnimParams(3,Anim,frame,rate);
    T = Anim$" Frame "$frame;
    C.SetPos(screenPos.X - 8*Len(T)/2, screenPos.y-36);
    C.DrawText( T);
}



//=================================================================
// Default Properties
//=================================================================

defaultproperties
{
     ChargeUpTime=7
     ChargeRate=1500
     JumpRate=3000
     CloseDistanceRate=450
     CloseAttackRate=1.100000
     SpinDive="Assasin_Attack04"
     ChargeBlades="ChargeUp_Blades"
     RECOVER="Assasin_Recover"
     FlipKick="Assasin_Attack01"
     ElbowSmash="Assasin_Attack02"
     RoundHouse="Assasin_Attack04"
     JumpKick="Assasin_Attack06"
     CloakAttack="Assasin_Cloak_Attack01"
     SlashEmitter=Class'VehicleEffects.AssassinHit'
     AssignedWeapon="PariahSPPawns.AssassinsFist"
}
