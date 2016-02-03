class SPAIFlameThrower extends SPAIController;

var bool bAltFireMode;
var float sweepTime;
var bool bSweeping;


function bool ShouldMelee(Pawn Seen)
{
    return false;
}

function StartFireWeapon()
{
    Super.StartFireWeapon();
    bSweeping=true;
}

function StopFireWeapon()
{
    Super.StopFireWeapon();
    bSweeping=false;
}

function tick(float dT)
{
    local int desiredYaw;
    Super.Tick(dT);

    if(bSweeping && EnemyIsVisible() )
    {
        sweepTime += dT;
        desiredYaw = 8192 * sin( 2.0 * PI * (sweepTime / sweepTimerPeriod));
    }
    else
    {
        sweepTime = 0;
        desiredYaw = 0;
    }
    Pawn.DesiredRotationOffset.Yaw += dT * 2.0 * (desiredYaw - Pawn.DesiredRotationOffset.Yaw);
}

function bool NeedToTurn(vector targ)
{
    local vector LookDir,AimDir;

    return false;

    LookDir = Vector(Pawn.Rotation);
    LookDir.Z = 0;
    LookDir = Normal(LookDir);
    AimDir = targ - Pawn.Location;
    AimDir.Z = 0;
    AimDir = Normal(AimDir);

    //return ((LookDir Dot AimDir) < 0.923);
    return ((LookDir Dot AimDir) < 0.707);
}

function Rotator Aim( Ammunition FiredAmmunition, vector projStart, int aimerror )
{
    local vector FireSpot, MissVector;
    local rotator ShootDir, result;

    local vector outHitLocation;
    local Pawn HitFriend;

    if ( target == None ) {
        DebugLog( "Aim at invalid target", DEBUG_FIRING );
        return rotator( lastSeenPos - projStart );
    }
    if( Target == Enemy && !EnemyIsVisible() ) {
        result = rotator(LastSeenPos - projStart);
        DebugLog( "Aim on enemy that isn't visible:" @ result,
                  DEBUG_FIRING );
        return result;
    }

    FireSpot = GetTweakedFireSpot(Target);
    ShootDir = rotator( FireSpot - projStart );
    
    //@@@ Q: friendly fire, what to do?
    //    A: Rather have a really good shot than a really stupid one
    if( WillFriendlyFire( projStart, FireSpot+MissVector, HitFriend,
                          outHitLocation ) )
    {
        ShootDir = rotator( outHitLocation + vect(0,0,1.0)
                           * HitFriend.CollisionHeight - projStart);
    }

    return ShootDir;
}


function rotator AdjustAim( Ammunition FiredAmmunition, vector projStart,
                            int aimerror )
{
    local rotator returnVal;

    FiredAmmunition.WarnTarget(Target,Pawn,vect(1,0,0));
    returnVal = Aim(FiredAmmunition, projStart, aimerror);
    //Pawn.DesiredRotationOffset = returnVal - Rotation;
    return returnVal;
}

//////////////////

function bool inFlameRange()
{
    return Vsize(Enemy.Location - Pawn.Location) < 1000;
}
    
//====================
// Override to make him not crouch
//====================

function Perform_Engaged_StandGround( optional float standTime)
{
    if(standTime == 0)
        StandGroundTime = 0.5 + 0.5f * frand();
    else
        StandGroundTime = standTime;

    if(Focus != Enemy) //not visible
    {
        SetFocalPointNearLocation(LastSeenPos);
    }
    else
        Focus = Enemy;
    
    Pawn.bWantsToCrouch = false;
    setCurAction("StandGround");
    GotoState('Engaged_StandGround');
    return;
}


//====================
// Override to make him walk
//====================

state Engaged_HuntEnemy
{
    function bool KeepGoing()
	{
		return ( Enemy!=None && (!EnemyIsVisible() || !inFlameRange()) );
	}

    function Timer()
    {
        if( inFlameRange() ) {
            log("inrange");
            //myAIRole.HuntSucceeded();
        }
    }

    function endState()
    {
        SetTimer(0, false);
    }
	
BEGIN:
	FinishRotation();
MOVE:
    SetTimer(0.2, true);
	MoveToward(MoveTarget,Enemy,,,true);
    if(KeepGoing())
        Continue_Engaged_HuntEnemy();
    myAIRole.HuntSucceeded();
}

function FlameOut()
{
    GotoState('MeFlameOut');
}

state MeFlameOut
{
ignores EnemyNotVisible, HearNoise, SeePlayer, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

    event Blinded(Pawn Instigator, float Duration, Name BlindType) {}

    function tick(float dT)
    {
        Focus = None;
        FocalPoint=Pawn.Location+Pawn.Acceleration;
    }

    event bool NotifyBump(actor Other)
    {
        Pawn.Acceleration=Normal(Pawn.Location - Other.Location)*Pawn.GroundSpeed;
        return true;
    }

    event bool NotifyHitWall(vector HitNormal, actor Wall)
    {
        Pawn.Acceleration=HitNormal*Pawn.GroundSpeed;
        return true;
    }

BEGIN:
    SetCurAction("MeFlameOut");
    StopFiring();
    StopFireWeapon();
    Pawn.Acceleration=VRand()*Pawn.GroundSpeed;
    Sleep(1.0);
    Pawn.Acceleration=VRand()*Pawn.GroundSpeed;
    Sleep(1.0);
    Pawn.Acceleration=VRand()*Pawn.GroundSpeed;
    Sleep(1.0);
    Pawn.Acceleration=VRand()*Pawn.GroundSpeed;
    Sleep(1.0);
    
    Pawn.Notify();
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotFlameThrower"
     MinNumShots=100
     MaxNumShots=100
     MaxShotPeriod=2.000000
     fOddsOfStrafeMove=0.000000
     sweepTimerPeriod=3.000000
}
