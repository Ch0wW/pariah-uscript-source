class SPAITestController extends SPAIController;

var() int TransientCostType;
var() int TransientCostAmt;
var() int CoverPrefType;

enum EAction
{
	A_Rest,				//0
	A_Wander,			//1
	A_MoveToPosition,	//2
	A_StandGround,		//3
	A_PursueEnemy,		//4
	A_Hide,				//5
	A_StrafeMove,		//6
	A_Panic,			//7
	A_TakeCover,		//8
	A_AttackFromCover,	//9
	A_SupressionFire,	//10
	A_Charge,			//11
	A_CloseIn,			//12
	A_ChargeStrafe,		//13
	A_GetLOS,			//14
    A_Hunt,             //15
	A_BackOff,			//16
    A_Flank,			//17
    A_Auto,				//

};

var EAction testAction;
var int curState;
var float timeTracker;
var float timeDuration;

/*
var float GrenadeWatchTime;

function Tick(float dT)
{
    local GrenadeProjectile grenade, bestGrenade;
    local float dotP;

    Super.Tick(dT);

    if( TimeElapsed(GrenadeWatchTime, 3.0) 
        && !TimeElapsed(GrenadeWatchTime, 10.0) )
    {
        SPPawn(Pawn).StopLookAt();
        return;
    }

    foreach AllActors(class'VehicleWeapons.GrenadeProjectile', grenade)
    {
        dotP = vector(Pawn.Rotation) dot Normal(grenade.Location - Pawn.Location);
        if(dotP > 0)
            bestGrenade = grenade;
    }

    if( bestGrenade != None && !bestGrenade.bDestroy)
    {
        
        if( TimeElapsed(GrenadeWatchTime, 6.0))
            MarkTime(GrenadeWatchTime);

        SPPawn(Pawn).SetLookAtTarget(bestGrenade, vect(0,0,0), false, true, false);
        SPPawn(Pawn).SetLookAtTarget(Enemy, vect(0,0,0), false, false, true);

    }
    else
    {
        SPPawn(Pawn).StopLookAt();
    }
}
*/

function debugTick(float dT)
{
    super.debugTick(dT);
    //DrawRoute();
	//SetTransientCosts(Enemy.Location);
    //drawDebugLine(Pawn.Location, bestCoverPosition(CoverPrefType).Location, 0,255,255);
}


/**
 * If it's an enemy, notice it, if it's a friend, coordinate moving
 * out of each others way.
 **/
event bool NotifyBump(actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if (P == None)
		return false;
	
	TryAcquiringNewEnemy(P, true);
	
	if ( Enemy == P )
		return false;
	
	if ( AdjustAround(P) )
		return false;
	return false;
}

function MultiTimer( int timerID ) {
        switch( timerID )
        {
            default:
                Super.MultiTimer(timerID);
                break;
        }
}

function Restart()
{
	Super.Restart();
	
    SPPawn(Pawn).bMayDive = false;
}

function DrawHUDDebug(Canvas C)
{
     Super.DrawHUDDebug(C);
}

function Perform(EAction action)
{
	testAction = action;
	curState = 0;
	log("Performing"@action);
    TestAIRole(myAIRole).testAction = action;

}

function InitAIRole()
{
	myAIRole = Spawn(class'TestAIRoleB',self);
    myAIRole.init(self);
}

function SetTransientCosts(vector Dest)
{
    local NavigationPoint N;
    local float trans;
	local vector enemyDir;

	enemyDir = vector(Enemy.Rotation);
	enemyDir.Z = 0;
    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        switch(TransientCostType)
        {
		case 0:
			trans = 0;
			break;
        case 1:
            trans = (2000 - VSize(N.Location - Enemy.Location) ) / 2000;
            break;
        case 2:
            trans = Normal(N.Location - Enemy.Location) dot Normal(enemyDir);
			if(trans < 0)
				trans = 1;
			else if(trans < 0.707)
				trans = 0;
			else
				trans = (trans - 0.707) / (0.293);
            break;
        case 3:
            trans = VSize( (pawn.Location + Dest) / 2 - N.Location ) / VSize(Dest - pawn.Location);
            trans = fClamp(trans, 0 , 1);
            trans = 1 - trans;
            break;
        }
		N.TransientCost = trans*TransientCostAmt;
        drawdebugline(N.Location, N.Location + vect(0,0,50), trans*250,1,1 );
    }
}

simulated function DrawRoute()
{
    local int i;
    local vector Start, RealStart, Dest;
    local bool bPath;

    if( Level.GetLocalPlayerController() == None
        || Level.GetLocalPlayerController().Pawn == None)
    {
        return;
    }

    Dest = claimedPosition.Location;
    if ( CurrentPath != None )
        Start = CurrentPath.Start.Location;
    else
        Start = Pawn.Location;
    RealStart = Start;

    // show where pawn is going
    if ( Dest != vect(0,0,0) )
    {
        if ( PointReachable(Destination) )
        {
            drawdebugLine(Pawn.Location, Dest, 255,255,255 );
            return;
        }
        SetTransientCosts(Enemy.Location);
        FindPathTo(Dest);
    }
    for ( i=0; i<16; i++ )
    {
        if ( RouteCache[i] == None )
            break;
        bPath = true;
        drawdebugLine(Start,RouteCache[i].Location, 0,255,0 );
        Start = RouteCache[i].Location;
    }
	if ( Pawn.Anchor != None )
		drawdebugLine(Pawn.Location, Pawn.Anchor.Location, 0,255,0);
        
    if ( bPath )
        drawdebugLine(RealStart,Dest, 255,255,255 );
}

//
//function bool FindCoverSpot()
//{
//    UnClaimPosition();
//    if ( currentStage != None ) {
//        ClaimPosition( bestCoverPosition(CoverPrefType) );
//    }
//    return (claimedPosition != None);
//}

function float EvalDist(StagePosition stgPos)
{
    return (2000.0f - VSize(Pawn.Location - stgPos.Location)) / 2000.f;
}

function float EvalCloseToEnemy(StagePosition stgPos)
{
    return (2000.0 - VSize(Enemy.Location - stgPos.Location)) / 2000.0;
}

function float EvalFarFromEnemy(StagePosition stgPos)
{
    return VSize(Enemy.Location - stgPos.Location);
}


function StagePosition bestCoverPosition(int CoverPrefType)
{
    local int i;
    local StagePosition bestPosition;
    local StagePosition stgPos;
    local float tmpWeight, bestPositionWeight;

    for( i = 0; i < currentStage.StagePositions.Length; i++ )
    {
        stgPos = currentStage.StagePositions[i];
        if(stgPos.bIsClaimed)
            continue;
        switch(CoverPrefType)
        {
        case 0:
            tmpWeight = EvalDist(stgPos);
            break;
        case 1:
            tmpWeight = EvalCloseToEnemy(stgPos);
            break;
        case 2:
            tmpWeight = EvalFarFromEnemy(stgPos);
            break;
        }

        if( bestPosition == None || tmpWeight > bestPositionWeight )
        {
            if ( currentStage.PositionProvidesCoverFromEnemy(stgPos, Enemy) > 0) {
                bestPosition = stgPos;
                bestPositionWeight = tmpWeight;
            }
        }
    }
    
    return bestPosition;
}

function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	//SetTransientCosts(Enemy.Location);
	return Super.FindBestPathToward( A,  bCheckedReach,  bAllowDetour);
}

defaultproperties
{
     TransientCostType=2
     TransientCostAmt=2000
     CoverPrefType=1
     AssignedWeapon="VehicleWeapons.BotAssaultRifle"
     MaxNumShots=6
     NumShotsUntilReload=35
     MinShotPeriod=0.300000
     MaxShotPeriod=0.500000
     MaxSecondsOfLOS=4.000000
     Skill=1.000000
}
