class SPAIShield extends SPAIController;

var SPAIRoleShield shieldRole;

//Animation related
const SHIELD_CHANNEL = 3;
var name ShieldWalkF;
var name ShieldCrouch;
var name ShieldRunF;
var name ShieldAttack;

//
var Vector ShieldRushLoc;
var int ShieldRushDist;

var bool bStopShooting;


event Blinded(Pawn Instigator, float Duration, Name BlindType) {}
    
function Restart()
{
    Super.Restart();
    shieldRole = SPAIRoleShield(myAIRole);
	shieldRole.myBot = self;
    SPShieldedPawn(Pawn).myController = self;

    SPPawn(Pawn).BulldogFireAnim = 'CrouchFire_Shield';
}

//============

function NotifyShieldHit()
{
    shieldRole.OnSupressed();
}

function PlayTakeHit()
{
    StopFireWeapon();
    bPlayingHit=true;
    shieldRole.OnSupressed();
}

//============

function StartFireWeapon()
{
    Super.StartFireWeapon();
}
function StopFireWeapon()
{
    Super.StopFireWeapon();
}

//============
// Engage_SlowAdvance
// walks Toward enemy
//============
function Perform_Engaged_SlowAdvance()
{
	SetCurAction("SlowAdvance");
	UnClaimPosition();
	
	if( FindBestPathToward(Enemy, false,true) )
	{
		GotoState('Engaged_SlowAdvance');
	}
	else
	{
		GotoState('Engaged_SlowAdvance', 'FIRE');
	}
}

state Engaged_SlowAdvance
{
    function BeginState()
    {
        Pawn.WalkAnims[0] = ShieldWalkF;
        Pawn.WalkingPct = (150.0 / Pawn.GroundSpeed);
    }

    function EndState()
    {
        if(Pawn != None)
        {
            Pawn.WalkAnims[0]='WalkF' ;  
            Pawn.WalkingPct = Pawn.default.WalkingPct;
        }
        StopFireWeapon();
		SetTimer(0, false);
    }   

    function EndOfBurst() {
        StopFiring();
        if(FRand()<0.5) {
            StartNewBurst();
        }
        else {
            bStopShooting=true;
        }
    }

	function Timer()
	{
		if(bStopShooting || !EnemyIsVisible())
		{
			Notify();
		}
	}
	

BEGIN:
    MoveToward(MoveTarget, Enemy,,, true);
    if(FRand() < 0.5)
	{
		Goto('DONE');
	}
FIRE:
    Pawn.StopMoving();
    StartFireWeapon();
	SetTimer(Frand(), true);
	WaitForNotification();
DONE:
    myAIRole.chargeSucceeded();
}

//============
// Engaged_MeleeRush
// When in range will rush at player with shield charged.
//============

function bool IsInMeleeRange()
{
    return ( VSize(Pawn.Location - Enemy.Location) < ShieldRushDist
		&& ActorReachable(Enemy) );
}

function Perform_Engaged_MeleeRush()
{
    GotoState('Engaged_MeleeRush');
}

state Engaged_MeleeRush
{
    function BeginState()
    {
        Pawn.MovementAnims[0]=ShieldRunF;
    }

    function EndState()
    {
        if(Pawn != None)
        {
            Pawn.MovementAnims[0]='RunF';
            Pawn.AnimBlendToAlpha(SHIELD_CHANNEL, 0, 0.4);
        }
        enable('NotifyBump');
    }

    function AnimEnd(int Channel)
    {
        if ( Channel == SHIELD_CHANNEL )
        {
            Pawn.AnimBlendToAlpha(SHIELD_CHANNEL, 0, 0.4);
            GotoState('Engaged_MeleeRush','DONE');
        }
        else
        {
            Global.AnimEnd(Channel);
        }
    }

    function Notify_Melee()
    {
        if( Enemy != None && Pawn != None && ( VSize(Enemy.Location - Pawn.Location) < Pawn.CollisionRadius*4 )
			&& (Normal(Enemy.Location - Pawn.Location) dot Vector(Pawn.Rotation) > 0.707) )
        {
            Enemy.TakeDamage(35, Pawn, Enemy.Location, 250*Vector(Pawn.Rotation), class'VehicleWeapons.BoneSawDamage');
            Enemy.Controller.DamageShake(100);
		}
    }

	function NotifyShieldHit() {}

    function PlayTakeHit() {}

    event bool NotifyBump(actor Other)
    {
        local Pawn P;
        if(!Other.IsA('Pawn'))
            return false;

        P = Pawn(Other);
        if(Enemy == P)
        {
            disable('NotifyBump');
            GotoState('Engaged_MeleeRush','ATTACK');
        }
        else
        {
            AdjustAround(P);
        }
    }
    
	event SeePlayer( Pawn Seen )
	{
		if(Focus == Enemy)
		{
			Super.SeePlayer(Seen);
		}
		else
		{
			Super.SeePlayer(Seen);
			Focus = None;
		}

	}

	
	function Timer()
	{
		if( VSize(Pawn.Location - Enemy.Location) < MeleeChargeThreshold)
		{
			SetTimer(0, false);
			GotoState('Engaged_MeleeRush', 'ATTACK');
		}
	}

	function debugTick(float dT)
	{
		Super.DebugTick(dT);
		drawdebugline(Pawn.Location, ShieldRushLoc, 255,0,0);
	}

BEGIN:
CHARGE:
    curAction = "CHARGE";
	StopFireWeapon();

    SetTimer(0.1, true);
	MoveToward( Enemy, Enemy);
	//Timer will send us to attack if we got close enough
	//Didn't close the gap
	SetTimer(0, false);
	if(actorReachable(Enemy))
	{
		GOTO('CHARGE');
	}
	else 
	{
		GOTO('DONE');
	}

ATTACK:
    setCurAction("MELEEATTACK");
    disable('NotifyBump');
	ShieldRushLoc = Enemy.Location + Normal(Enemy.Location - Pawn.Location)* 200;
	
	MarkTime(LastMeleeTime);	
    Pawn.AnimBlendParams(SHIELD_CHANNEL, 1.0, 0.0, 0.5, Pawn.SpineBone1);
    Pawn.PlayAnim(ShieldAttack,0.75 , ,SHIELD_CHANNEL);
	Focus = None;
	FocalPoint = ShieldRushLoc;
	MoveTo(ShieldRushLoc);
    
DONE:
	curAction = "DONE";
	Pawn.StopMoving();
	Sleep(0.75);
	MarkTime(LastMeleeTime);
	Focus = Enemy;
	FinishRotation();
    myAIRole.chargeSucceeded();
}



//============
// Engaged_CrouchBehindShield
// When suppressed, will take cover behind shield
//============
function Perform_Engaged_CrouchBehindShield()
{
	curAction = "CrouchBehindShield";
	GotoState('Engaged_CrouchBehindShield');

}

state Engaged_CrouchBehindShield
{

    function EndState()
    {
        if(Pawn != None)
        {
            Pawn.AnimBlendToAlpha(SHIELD_CHANNEL, 0, 0.4);
            Pawn.bWantsToCrouch = false;
        }
    }

    function NotifyShieldHit()
    {
        GotoState('Engaged_CrouchBehindShield', 'WAIT');
    }

    function PlayTakeHit()
    {
        GotoState('Engaged_CrouchBehindShield', 'WAIT');
        StopFireWeapon();
        bPlayingHit=true;
    }

BEGIN:
	Focus = Enemy;
	FinishRotation();
    StopFireWeapon();
	Pawn.StopMoving();
	Pawn.bWantsToCrouch = true;
	Pawn.AnimBlendParams(SHIELD_CHANNEL, 1.0, 0.0, 0.5, Pawn.RootBone);
	Pawn.LoopAnim(ShieldCrouch, , ,SHIELD_CHANNEL);
WAIT:   
	Sleep(2.0);
	Pawn.bWantsToCrouch = false;

    myAIRole.chargeSucceeded();
}

//==============================

/**
 * When called, will draw debug text above the bots head
 */
function DrawHUDDebug(Canvas C)
{
    local vector screenPos;
    if (!bDebugLogging || Pawn == None) return;

    screenPos = WorldToScreen( Pawn.Location
                               + vect(0,0,1)*Pawn.CollisionHeight );
    if (screenPos.Z > 1.0) return;

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    C.DrawText( myAIROle.GetDebugText());

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-12);
    C.DrawText( curAction );

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y);
    if(Enemy != None)
        C.DrawText( ChanceToHit() @ LatentFloat @ VSize(Enemy.Location - Pawn.Location) );
    else
        C.DrawText( ChanceToHit() @ LatentFloat);
    
    
    
}

defaultproperties
{
     ShieldRushDist=1000
     ShieldWalkF="WalkF_Shield"
     ShieldCrouch="Crouch_Shield"
     ShieldRunF="RunF_Shield"
     ShieldAttack="ShieldAttack"
     AssignedWeapon="VehicleWeapons.BotAssaultRifle"
     MaxNumShots=6
     MinShotPeriod=0.300000
     MaxShotPeriod=0.500000
     MeleeChargeThreshold=400.000000
     sweepTimerPeriod=3.000000
}
