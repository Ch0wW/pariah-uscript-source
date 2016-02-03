class SPAIKeeperFlyPast extends SPAIController;

const MINSTRAFEDIST = 400;

var vector temp1;
var vector Origin;

var bool bDeccel;

var vector SwoopDest;
var vector EnemyLoc;

//==========
// Overrides
//==========

function debugTick(float dT)
{
    drawdebugline(temp1 + vect(0,0,50), temp1, 255, 0, 0);
}

function ResetSkill()
{
	local float AdjustedYaw;
	
    AdjustedYaw = 0.75 * RotationRate.Yaw;
	AcquisitionYawRate = AdjustedYaw;
    Pawn.PeripheralVision = 0;
}

function InitAIRole()
{
	myAIRole = Spawn(class'SPAIRoleKeeperFly',self);
    myAIRole.init(self);
}

function Tick(float dT)
{
    Super.Tick(dT);
    if(bDeccel) 
    {
        Pawn.Acceleration = vect(0,0,0);
        Pawn.Velocity += dt * 4.0 * ( vect(0,0,0) - Pawn.Velocity );
        if( VSIze(Pawn.Velocity) < 25)
        {
            bDeccel=false;
            Notify();
        }
    }
}

function PickDestination()
{
    local vector Dir;
    local rotator polar;

    dir = pawn.location - Enemy.Location;
    
    polar.Pitch = 100*RandRange(54, 10) + Rand(100);
    
    polar.Roll = 0;
    if(Frand() < 0.5)
        polar.Yaw = 2000*RandRange(-5461.0/2000.0, -2000.0/2000.0) + Rand(2000);
    else
        polar.Yaw = 2000*RandRange(2000.0/2000.0, 5461.0/2000.0) + Rand(2000);
    
    dir.Z = 0;
    dir = Normal(dir);
    Destination = vector(polar) * RandRange(400, 1500);
    Destination = Destination >> rotator(Dir);
    
    Destination = Enemy.Location + Destination;
    TestDestination();
	temp1 = Destination;
    Origin = Destination;
}



function bool TestDestination()
{	
	local vector HitLocation, HitNormal, dir;
	local actor HitActor;

    dir = Normal(Destination - Pawn.Location);
	HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
	if (HitActor != None)
	{
		Destination = HitLocation + (HitNormal-dir)*Pawn.CollisionHeight*3.0;
		if ( !FastTrace(Destination, Pawn.Location) )
		{
			return false;
		}
	}
	else if (! FastTrace(Destination, Destination - vect(0,0,1)*Pawn.CollisionHeight) )
	{
		Destination += vect(0,0,1)*Pawn.CollisionHeight*(1.0 + FRand());
	}
	return true;
}

/////////////////////
////////////////////

function Perform_Engaged_KeeperMove()
{
	setCurAction("KeeperMove");
	
	PickDestination();
	strafeTarget = Destination;
	GotoState('Engaged_KeeperMove');
}

state Engaged_KeeperMove
{
	event bool NotifyBump(actor Other)
	{
		local bool returnVal;
		returnVal = Super.NotifyBump(Other);
		myAIRole.RoleSelectAction();
		return returnVal;
	}

	event EnemyNotVisible()
	{
		Global.EnemyNotVisible();
        if( FastTrace(Enemy.Location, LastSeeingPos) )
        {
            Destination = LastSeeingPos;
            strafeTarget = Destination;
            GotoState('Engaged_KeeperMove', 'BEGIN');
        }
	}

	function BeginState()
 	{
    }

    function EndState()
    {
        bDeccel = false;
        StopFireWeapon();
        SetTimer(0, false);
    }
    function Timer()
    {
        bDeccel = false;
        GotoState('Engaged_KeeperMove', 'DONE');
    }

 	function Tick(float dT)
    {
        Super.Tick(dT);
        if(bDeccel) 
        {
            Pawn.Velocity += dt * 8.0 * ( vect(0,0,0) - Pawn.Velocity );
            if( VSIze(Pawn.Velocity) < 25)
            {
                bDeccel = false;
                Notify();
            }
        }
    }
BEGIN:
    if(Vsize(Pawn.Location - strafeTarget) > 300)
        MoveTo( strafeTarget );
    else
        MoveTo( strafeTarget, Enemy );
    Focus = Enemy;
    bDeccel=true;
    SetTimer(3.0, false);
    WaitForNotification();
    bDeccel = false;
    SetTimer(0, false);
    
    
DONE:
    StartFireWeapon();
    Sleep(1.0+ FRand());
    StopFireWeapon();
	myAIRole.RoleSelectAction();
}


/////////////////////////
/////////////////////////

function Perform_Engaged_StandGround( optional float standTime )
{
	setCurAction("StandGround");
	
	if(Focus != Enemy) //not visible
	{
		SetFocalPointNearLocation(LastSeenPos);
	}
	GotoState('Engaged_StandGround');
}

state Engaged_StandGround
{
    function BeginState()
    {
        Origin=Pawn.Location;
    }

BEGIN:
	bDeccel = true;
    WaitForNotification();
    myAIRole.RoleSelectAction();
}

//////////////////
//////////////////

function Perform_Engaged_Swoop()
{
    setCurAction("KeeperSwoop");
	GotoState('KeeperSwoop');
}

function bool isSwooping() { return false; }


state KeeperSwoop
{
    function bool isSwooping() { return true; }

    event bool NotifyBump(actor Other)
    {
        local Pawn P;
        if(!Other.IsA('Pawn'))
            return false;

        P = Pawn(Other);
        if(Enemy == P)
        {
            log("HIT ENEMY");
            disable('NotifyBump');
            GotoState('KeeperSwoop','HIT');
        }
        return false;
    }

    function BeginState()
    {
        pawn.AirSpeed = 2000;
        Pawn.RotationRate.Yaw = 200000;
    }

    function EndState()
    {
        enable('NotifyBump');
        bDeccel=false;
        pawn.AirSpeed = pawn.default.AirSpeed ;
        Pawn.RotationRate = Pawn.default.RotationRate;
    }

    function SetSwoop()
    {
        local vector predictedLoc;
        
        predictedLoc = Enemy.Location;
        predictedLoc += Enemy.Velocity * VSize(pawn.Location - Enemy.Location) / 2000;
        
        SwoopDest = predictedLoc + 300.0 * Normal(pawn.Location - predictedLoc);
        temp1 = SwoopDest;
        EnemyLoc = Enemy.Location;
        Destination = SwoopDest;
    }

    function Timer()
    {
        //Update swoop dest until we've sped up a bit
        if( VSize(Origin - Pawn.Location) < (VSize(Origin - SwoopDest)/2.0 ) )
        {
            SetSwoop();
        }
    }

BEGIN:

    setCurAction("KeeperSwoopA");
    Origin=Pawn.Location;
    SetSwoop();
    SetTimer(0.1, true);
    FocalPoint = Enemy.Location;
    MoveTo( SwoopDest, None);
    SetTimer(0, false);
    
HIT:
    setCurAction("KeeperSwoopB");
    FocalPoint = Origin;
    temp1 = Origin;
    MoveTo( Origin, None);
    log("MoveTimer"@MoveTimer);

SETTLE:  
    setCurAction("KeeperSwoopC");
    
    bDeccel = true;
    Focus = Enemy;
    WaitForNotification();
    setCurAction("KeeperSwoopD");
    
    myAIRole.RoleSelectAction();
}

////////////////
////////////////


function bool isChargeWeapon()
{
    return true;
}

function float getChargeDelay()
{
    return 0.1;
}

//Don't stop shooting the weapon
function PlayTakeHit(){}


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
    if(Enemy == None)
        C.DrawText(LatentFloat );
    else
        C.DrawText(LatentFloat @ VSize(Enemy.Location - Pawn.Location) @ (Pawn.Location.Z - Enemy.Location.Z) );
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.KeeperWeapon"
     MaxNumShots=8
     MaxShotPeriod=1.000000
     RotationRate=(Pitch=1000,Roll=0)
}
