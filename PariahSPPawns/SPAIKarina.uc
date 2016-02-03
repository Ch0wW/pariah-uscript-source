class SPAIKarina extends ScriptedController
    dependson(ResponseManager);

#exec OBJ LOAD FILE=PariahPlayerSounds.uax

const MINSTRAFEDIST = 200;  //How far to move out of way

const CATCHUPDIST = 300; //How close to the player we try to get when we catch up
const MAXCATCHUPDIST = 500;
const TOOFARDIST = 1000; //How far the player is before we need to try catching up

const NOTIFYBUMPSLOT = 1001;

const IDLETIMERSLOT = 1002;
const IDLECHATDELAY = 10.0;
const STAREDATTIME = 10.0;

var ResponseManager responseMgr;

//Special case timemarks
var  float  LastHeardShotsTime;
var  float  StartHeardShotsTime;
var  float   LastSawEnemyTime;

//Rest state members
var bool bRESTTurnToFace;
var bool bRESTWalk;

//LookatTarget

const UPDATELOOKSLOT = 1000;
struct LookAtTargetInfoType
{
    var Actor   LookAtTarget;
    var Vector  LookAtLocation;
};
var LookAtTargetInfoType LookAtTargetInfo;


//for TryNotLookAtWall
const WALLDIST = 200;
var float       WallDelay;
var Rotator     LastWallCheckRotation;
var Vector      LastWallCheckLocation;

//for TryLookingAtPlayer
var bool  bLookingAtPlayer;
var float PlayerStartLookAtTime;
var float PlayerStopLookAtTime;
var float PlayerStopLookAtDuration;
var float PlayerLookAtDuration;
//for TryLookingAtNothing
var float NothingHeadStartLookAtTime;
var float NothingHeadLookAtDuration;
var Rotator NothingHeadRotation;

var float NothingEyeStartLookAtTime;
var float NothingEyeLookAtDuration;
var Rotator NothingEyeRotation;

//For FollowPlayer
var bool    bHasRun;

var EntryPoint EntrySpot;

var FocusTarget focusTarget;

//////////////////////////////////////

function CreateChatter( ResponseManager.EResponse type)
{
    local ResponseManager.ResponseType Response;

    if( ! responseMgr.CreateResponse( type, Response) )
        return;
    
    if( Response.LSanimName  != '')
    {
        if( Pawn.IsA('VGVehicle') )
            VGVehicle(Pawn).Driver.PlayLIPSincAnim( Response.LSanimName );
        else
            Pawn.PlayLIPSincAnim( Response.LSanimName );
    }
    if( Response.BodyAnimName != '')
    {
        if( !Pawn.IsA('VGVehicle') )
            SPPawnKarina(Pawn).PlayIdleAnims(Response.BodyAnimName);
    }
    UpdateLookTarget();
}

function TryShootingNothingChatter()
{
    if(Enemy != none)
        return;

    if( TimeElapsed(LastHeardShotsTime, 5.0) )
    { 

        MarkTime(StartHeardShotsTime);
        MarkTime(LastHeardShotsTime);
    }
    else
    {
        MarkTime(LastHeardShotsTime);
        if( TimeElapsed(StartHeardShotsTime, 2.0) )
        {    
            MarkTime(StartHeardShotsTime);
            //hack to see if we're being aimed at.
            if( vector(Level.GetLocalPlayerController().Pawn.Rotation) dot Normal(pawn.location - Level.GetLocalPlayerController().Pawn.Location) < 0.98)
                CreateChatter( C_MasonShootingNothing );
        }
    }
}

function handleIdleTimer()
{
    local Pawn player;
    
    SetMultiTimer(IDLETIMERSLOT, IDLECHATDELAY + IDLECHATDELAY*Frand(), false);
        
    if(Enemy != None)
       return;

    player = Level.GetLocalPlayerController().Pawn;
    if( vector(player.Rotation) dot Normal(pawn.location - player.Location) > 0.98 
        && VSize(pawn.location - player.Location) < 300) {
        CreateChatter( C_StaredAt );
    }
    else {
        CreateChatter( C_IDLE );
    }     
}


//////////////////////////////////////
// Events
//////////////////////////////////////

event SeePlayer( Pawn Seen )
{
    if( !SameTeamAs(Seen.Controller) )
    {
        if(TimeElapsed( LastSawEnemyTime, 20) ) {
            MarkTime(LastSawEnemyTime);
        }
        Enemy = Seen;
    }
}

event EnemyNotVisible()
{
    if( TimeElapsed(LastSawEnemyTime, 20) )
        Enemy = None;
}

event HearNoise( float Loudness, Actor NoiseMaker)
{
    if ( Pawn(NoiseMaker) == None || Pawn(NoiseMaker).Controller == None)
        return;

    if( SameTeamAs( Pawn(NoiseMaker).Controller ) ) {
        if( Pawn(NoiseMaker).Weapon != None 
            && Pawn(NoiseMaker).Weapon.IsFiring() ) {
            TryShootingNothingChatter();
        }
    }
}

function MultiTimer(int i)
{
    switch(i)
    {
    case IDLETIMERSLOT:
        handleIdleTimer();
        break;
    case UPDATELOOKSLOT:
        UpdateLookTarget();
        break;
    case NOTIFYBUMPSLOT:
        SetMultiTimer(NOTIFYBUMPSLOT, 0.5*Frand(), false);
        enable('NotifyBump');
        break;
    default:
        Super.MultiTimer(i);
        break;
    }
}

event bool NotifyBump(actor Other)
{
    local Pawn P;

    Disable('NotifyBump');
    P = Pawn(Other);
        
    if ( (P != None) && Enemy == P )
        return false;

    if( (P != None) && (P.Controller != None) && SameTeamAs( P.Controller) && Enemy == None)
        CreateChatter( C_Bumped );

    if ( AdjustAround(P) )
        return false;
    
    if ( SameTeamAs( P.Controller) && VGVehicle(P) == None )
    {
        ClearPathFor(P.Controller);
    }
    return false;
}


function DamageAttitudeTo(Pawn Other, float Damage)
{    
    Super.DamageAttitudeTo(Other, Damage);
    if( SameTeamAs(Other.Controller))
    {
        if(Enemy == None)
            CreateChatter( C_FriendlyFiredAt );
        else
            CreateChatter( C_FriendlyFiredAt );
    }
    else
    {
        CreateChatter( C_TakingDamage );
    }
}


function bool SameTeamAs( Controller c )
{
    local Pawn otherPawn;

    if (c == Level.GetLocalPlayerController())
        return true;

    if( VGVehicle(c.Pawn) != None )
        otherPawn =  VGVehicle(c.Pawn).Driver;
    else
        otherPawn = c.Pawn;

    if( SPPawn(otherPawn) != None && SPPawn(otherPawn).race == R_NPC)
        return true;
    
    return false;
}


function NotifyKilled( Controller Killer, Controller Killed, pawn KilledPawn )
{
    Super.NotifyKilled(Killer, Killed, KilledPawn);
    
    if(KilledPawn == None || Pawn == None)
        return;
    if( VSize(KilledPawn.Location - Pawn.Location) > 2500 )
        return;
    if( !FastTrace(Pawn.Location, KilledPawn.Location))
        return;

    //witnessed kill of opposition by friendly
    if ( SameTeamAs(Killer) && !SameTeamAs(Killed) )
    {
        CreateChatter( C_KillWitnessed );
        return;
    }
}

////////////////////////////////////////

function StartUpdateLook(){ SetMultiTimer(UPDATELOOKSLOT, 0.01, true); }
function EndUpdateLook() { StopLookAtTarget(); SetMultiTimer(UPDATELOOKSLOT, 0.0, false); }

function StopLookAtTarget()
{
    SPPawn(Pawn).StopLookAt();
    LookAtTargetInfo.LookAtTarget = None;
}

function bool TryLookAtPlayer(out LookAtTargetInfoType TargetInfo)
{
    local Pawn      PlayerPawn;
    local float     YawDiff, PitchDiff;
    local Rotator   playerRot;
    local bool      bPlayerMoving;
    
    PlayerPawn = Level.GetLocalPlayerController().Pawn;
    if(PlayerPawn == None)
    {
        bLookingAtPlayer = false;
        return false;
    }

    if(  bLookingAtPlayer && TimeElapsed(PlayerStartLookAtTime, PlayerLookAtDuration) )
    {
        PlayerStopLookAtTime = Level.TimeSeconds;
        PlayerStopLookAtDuration = 15 + Rand(5);
        bLookingAtPlayer = false;
        return false;
    }

    bPlayerMoving = VSize(PlayerPawn.Velocity) > 50;
    //We were looking for too long, we wait a while
    if( !bPlayerMoving && PlayerStopLookAtTime != -1 && !TimeElapsed(PlayerStopLookAtTime, PlayerStopLookAtDuration) )
    {
        bLookingAtPlayer = false;
        return false;
    }
    PlayerStopLookAtTime = -1;

    playerRot = Rotator(Level.GetLocalPlayerController().Pawn.Location - Pawn.Location);
    YawDiff = RotDiff(playerRot.Yaw, Pawn.Rotation.Yaw);
    PitchDiff = RotDiff(playerRot.Pitch, Pawn.Rotation.Pitch);

    if(abs(YawDiff) < 16384 && abs(PitchDiff) < 16384)
    {
        SPPawn(Pawn).SetLookAtTarget( PlayerPawn, 
                                        vect(0,0,1) * PlayerPawn.BaseEyeHeight, 
                                        true, true, true);
        if(!bLookingAtPlayer || bPlayerMoving)
        {
            PlayerLookAtDuration = 8 + Rand(2);
            MarkTime(PlayerStartLookAtTime);
        }
        bLookingAtPlayer = true;
        return true;
    }

    return false;
}

function bool NearWall(float wallDist)
{
    local actor HitActor;
    local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

    LookDir = vector(Rotation);
    ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
    ViewDist = LookDir * wallDist; 
    HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
    if ( HitActor == None )
        return false;

    ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
    if (FRand() < 0.5)
        ViewDist *= -1;

    Focus = None;
    if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
    {
        FocalPoint = Pawn.Location + ViewDist;
        return true;
    }

    if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
    {
        FocalPoint = Pawn.Location - ViewDist;
        return true;
    }

    FocalPoint = Pawn.Location - LookDir * 300;
    return true;
}


function bool TryNotLookAtWall()
{

    if( (LastWallCheckLocation == Pawn.Location
         && LastWallCheckRotation == Pawn.Rotation)
         || !TimeElapsed( WallDelay, frand())
         || VSize(Pawn.Velocity) > 0)
    {
        return false;
    }

    MarkTime(WallDelay);
    if( NearWall(WALLDIST) )
    {
        return true;
    }
    return false;
}

/**
 * integer version of RandRange, returns an random integer between Min and Max
 **/
function int iRandRange(int min, int max)
{
    return Min + Rand((Max - Min) + 1);
}

/**
 * returns A-B, normalized around 180 degrees
 **/
function int RotDiff(int A, int B)
{
    local int returnVal;
    returnVal = (A - B) & 65535;
    if (returnVal < -32768) returnVal += 65536;
    else if (returnVal > 32768) returnVal -= 65536;
    return returnVal;
}

function TryBlink(int newYaw, int oldYaw, int threshold )
{
    if( abs(RotDiff(newYaw, oldYaw)) > threshold )
    {
        SPPawn(Pawn).AnimateBlink(true);
        SPPawn(Pawn).PlayBlink();
    }
}

function bool TryLookAtNothing()
{
    local int oldEyeYaw, oldHeadYaw;
    local vector Loc;
    local Rotator playerRot;
    local float YawDiff, YawDiffL, YawDiffR;

    Loc = pawn.Location + vect(0,0,1)*Pawn.BaseEyeHeight;
    
    if( TimeElapsed( NothingHeadStartLookAtTime, NothingHeadLookAtDuration) )
    {
        oldHeadYaw = NothingHeadRotation.Yaw;
        MarkTime(NothingHeadStartLookAtTime);
        NothingHeadLookAtDuration = 8 + Rand(2);

        playerRot = Rotator(Level.GetLocalPlayerController().Pawn.Location - Pawn.Location);
        YawDiff = RotDiff(playerRot.Yaw,Pawn.Rotation.Yaw);
        
        YawDiffL = YawDiff-2048;
        YawDiffR = YawDiff+2048;
        if(YawDiffL > -12743 && YawDiffR < 12743)
        {
            if(Frand() < 0.5 || NothingHeadRotation.Yaw > YawDiffL)
                NothingHeadRotation.Yaw = iRandRange( -12743, YawDiffL);
            else    
                NothingHeadRotation.Yaw = iRandRange( YawDiffR, 12743 );
        }
        else if( YawDiffL < -12743  && YawDiffR <12743)
        {
            NothingHeadRotation.Yaw = iRandRange( YawDiffR, 12743 );
        }
        else if( YawDiffL > -12743  && YawDiffR >12743 )
        {
            NothingHeadRotation.Yaw = iRandRange( -12743, YawDiffL);
        }
        else
        {
            NothingHeadRotation.Yaw = -12743 + Rand(12743*2);
        }

        if(NothingHeadRotation.Pitch > 1024)
            NothingHeadRotation.Pitch = iRandRange(-1024, 1024);
        else
            NothingHeadRotation.Pitch = iRandRange(1024, 4092);

        NothingHeadRotation.Roll = 0;
        
        NothingEyeRotation.Yaw = 0;
        NothingEyeRotation.Pitch = 0;
        NothingEyeRotation.Roll = 0;
        TryBlink(NothingHeadRotation.Yaw, oldHeadYaw, 6144);
        MarkTime(NothingEyeStartLookAtTime);
    }
    
    if( TimeElapsed( NothingEyeStartLookAtTime, NothingEyeLookAtDuration) )
    {
        oldEyeYaw = NothingEyeRotation.Yaw;
        MarkTime(NothingEyeStartLookAtTime);
        NothingEyeLookAtDuration = 2 + Rand(2);
        NothingEyeRotation.Yaw = -10240 + 2048 * Rand(10);
        //NothingEyeRotation.Pitch = 102 * Rand(10);
        TryBlink(NothingEyeRotation.Yaw, oldEyeYaw, 6144);
    }

    SPPawn(Pawn).SetLookAtTarget( None, Loc + 200*vector(Pawn.Rotation + NothingHeadRotation),
                                    false, true, true);
    SPPawn(Pawn).SetLookAtTarget( None, Loc + 200*Vector(Pawn.Rotation + NothingHeadRotation + NothingEyeRotation),
                                    true, false, false);
    
    return true;
}

function bool TryChatting()
{
    if( Pawn.IsA('VGVehicle') || Pawn.IsPlayingLIPSincAnim() )
        return false;

    SPPawn(Pawn).SetLookAtTarget( Level.GetLocalPlayerController().Pawn, 
                                        vect(0,0,1) * Level.GetLocalPlayerController().Pawn.BaseEyeHeight, 
                                        true, true, false);
    SPPawn(Pawn).StopLookAt(false, false, true);

    return true;
}

function UpdateLookTarget()
{
    local LookAtTargetInfoType TargetInfo;

    if(Pawn == None || SPPawn(Pawn) == None )
        return;

    if( TryChatting()
        || TryNotLookAtWall()
        || TryLookAtPlayer(TargetInfo) 
        || TryLookAtNothing() )
    {
        //noop
    }
    else
        StopLookAtTarget();
}

function Tick(float dT)
{
    Super.Tick(dT);
    //debugTick();
}

function debugTick()
{
    drawdebugline( pawn.Location + vect(0,0,1), pawn.Location + vect(0,0,1) + 200*Vector(pawn.Rotation), 0, 0, 255 );
    if(Focus != None)
        drawdebugline( pawn.Location + vect(0,0,3), Focus.Location, 0, 255, 0 );
    else
        drawdebugline( pawn.Location + vect(0,0,2), FocalPoint, 255, 0, 0 );
}

//////////////////////////////////////
function Update_T_AccompanyPlayer()
{
    Do_Rest();
    Do_FollowPlayer();
}

function Do_Rest()
{
    GotoState('Rest');
}

function Do_FollowPlayer()
{
    GotoState('FollowPlayer');
}


state Scripting
{
    function BeginState()
    {
        Super.BeginState();
        EndUpdateLook();
        SetMultiTimer(NOTIFYBUMPSLOT, 0, false);
    }

    function ClearPathFor(Controller C);

    function LeaveScripting()
    {
        SetMultiTimer(NOTIFYBUMPSLOT, 0.5*Frand(), false);
        GotoState('FollowPlayer');
    }
}


function Restart()
{
    Super.Restart();
    focusTarget = Spawn(class'FocusTarget',self);
    Pawn.SetMovementPhysics();
    responseMgr = Spawn(class'ResponseManager',self);
    responseMgr.init(self);
    SetMultiTimer(NOTIFYBUMPSLOT, 0.5*Frand(), false);
}

function Destroyed()
{
    Super.Destroyed();

    if(focusTarget != None)
        focusTarget.Destroy();
    if(responseMgr !=None)
        responseMgr.Destroy();
    
}

/* FindBestPathToward() 
Assumes the desired destination is not directly reachable. 
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
    if ( !bCheckedReach && ActorReachable(A) )
        MoveTarget = A;
    else
    {
        MoveTarget = FindPathToward(A,(bAllowDetour && (NavigationPoint(A) != None)));
        // gam ---
        if( MoveTarget == A && !LineOfSightTo(A) )
            return false;
        // --- gam
    }
    
    if ( MoveTarget != None )
        return true;
    else if ( bSoaking && (Physics != PHYS_Falling) )
        SoakStop("COULDN'T FIND BEST PATH TO "$A);

    return false;
}   


//=============================================================

function bool NearPlayer()
{
    return ( VSize(Level.GetLocalPlayerController().Pawn.Location - Pawn.Location) < MAXCATCHUPDIST );
}

function bool TooFarFromPlayer()
{
    return ( VSize(Level.GetLocalPlayerController().Pawn.Location - Pawn.Location) < TOOFARDIST );
}


//=============================================================


/** 
 * return true if this bot is moving,
 * and will adjust out of the way of Other
 * Set adjustlocation so move code makes adjustment
 **/
function bool AdjustAround(Pawn Other)
{
    local float speed;
    local vector VelDir, OtherDir, SideDir;

    speed = VSize(Pawn.Acceleration);
    if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
        return false;

    VelDir = Pawn.Acceleration/speed;
    VelDir.Z = 0;
    OtherDir = Other.Location - Pawn.Location;
    OtherDir.Z = 0;
    OtherDir = Normal(OtherDir);
    if ( (VelDir Dot OtherDir) > 0.0 )
    {
        bAdjusting = true;
        SideDir.X = VelDir.Y;
        SideDir.Y = -1 * VelDir.X;
        if ( (SideDir Dot OtherDir) > 0 )
            SideDir *= -1;

        AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
    }
}

function ClearPathFor(Controller C)
{
    local vector OtherDir, SideDir, RelDir;
    
    RelDir = Pawn.Location - C.Pawn.Location;
    OtherDir = C.Pawn.Velocity;
    OtherDir.Z = 0;
    OtherDir = normal(OtherDir);
    SideDir.X = OtherDir.Y;
    SideDir.Y = -1 * OtherDir.X;
    if( SideDir dot RelDir > 0.0)
        DirectedWander( SideDir, false, true );
    else
        DirectedWander( -1*SideDir, false, true );
}

function DirectedWander(vector WanderDir, optional bool bTurnToFace, optional bool bWalk)
{
    Pawn.bWantsToCrouch = Pawn.bIsCrouched;
    bRESTTurnToFace = bTurnToFace;
    bRESTWalk = bWalk;
    if ( TestDirection(WanderDir,Destination) )
    {
        GotoState('Rest', 'Moving');
    }
    else
    {
        GotoState('Rest', 'Begin');
    }
}

function bool TestDirection(vector dir, out vector pick)
{   
    local vector HitLocation, HitNormal, dist;
    local actor HitActor;

    pick = dir * (MINSTRAFEDIST + MINSTRAFEDIST * FRand());

    HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
    if (HitActor != None)
    {
        pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
        if ( !FastTrace(pick, Pawn.Location) )
            return false;
    }
    else
        pick = Pawn.Location + pick;
     
    dist = pick - Pawn.Location;
    if (Pawn.Physics == PHYS_Walking)
        dist.Z = 0;
    
    return (VSize(dist) > MINSTRAFEDIST); 
}

function ResetAccel()
{
    local vector zero;
    if(Pawn != None)
    {
        Pawn.Acceleration = zero;
    }
}

auto state Rest
{
    function BeginState()
    {
        //log("BEGIN REST"@VSize(Pawn.Location - Level.GetLocalPlayerController().Pawn.Location));
        StartIdleTimer();
        StartUpdateLook();
    }
    
    function EndState()
    {
        MonitoredPawn = None;
        EndIdleTimer();
        //EndUpdateLook();
    }

    event MonitoredPawnAlert()
    {
        //if(! TooFarFromPlayer())
            GotoState('FollowPlayer');
    }

    function StartIdleTimer() { SetMultiTimer(IDLETIMERSLOT, IDLECHATDELAY + IDLECHATDELAY*Frand(), false); }
    function EndIdleTimer() { SetMultiTimer(IDLETIMERSLOT, 0.0, false); }
    
    
    function DamageAttitudeTo(Pawn Other, float Damage)
    {
        local vector SideDir, SideSpot;
        local float dist;
    
        Super.DamageAttitudeTo(Other, Damage);
        if( SameTeamAs(Other.Controller))
        {
            //Move Aside
            if( !IsInState('Scripting') && VSize(Pawn.Velocity) < 100)
            { 
                if(Frand() < 0.5)
                    SideSpot = Vector(Other.Rotation) >> rot(0,8192,0);
                else
                    SideSpot = Vector(Other.Rotation) >> rot(0,-8192,0);
                dist = Max(300, VSize(Other.Location - Pawn.Location));
                SideSpot = Other.Location + SideSpot * dist;
                SideDir = Normal(SideSpot - Pawn.Location);
                DirectedWander( SideDir, true, false );
            }
        }      
    }

BEGIN:
    if(Pawn != None)
    {
        Destination = Pawn.Location;
        bRESTTurnToFace = True;
        bRESTWalk = True;
    }
MOVING:
    if(Pawn != None)
    {
        SetMultiTimer(IDLETIMERSLOT, IDLECHATDELAY + IDLECHATDELAY*Frand(), false);
        WaitForLanding();
        ResetAccel();
        StartMonitoring( Level.GetLocalPlayerController().Pawn, TOOFARDIST );
        if( bRESTTurnToFace )
        {
            FinishRotation();
            MoveTo(Destination, None, bRESTWalk);
        }
        else
        {
            focusTarget.SetLocation( Pawn.Location + (Pawn.Location - Destination) );
            MoveTo(Destination, focusTarget, bRESTWalk);
        }
    }
REST:
    ResetAccel();
    Focus = None;
    //Focus = MonitoredPawn;
    FocalPoint = MonitoredPawn.Location + MonitoredPawn.BaseEyeHeight * vect(0,0,1);
    FinishRotation();
    enable('NotifyBump');
    while(true)
    {
        Sleep(1.0);
        if( VGVehicle(Level.GetLocalPlayerController().Pawn) != None )
        {   
            GotoState('FollowPlayer');
        }
    }
}

state Lost
{
BEGIN:
    ResetAccel();
    Sleep(FRand() * 2.0);
    GotoState('FollowPlayer');
}

state FollowPlayer
{
    function bool ShouldWalk()
    {
        if
        ( 
            bHasRun ||
            VSize(Level.GetLocalPlayerController().Pawn.Location - Pawn.location) > 1000 
        )
        {
            bHasRun = true;
            return false;
        }
        return true;
    }

BEGIN:
    bHasRun = false;
    if(Pawn != None)
    {
        Pawn.bWantsToCrouch = false;
        while
        ( 
            !(
                Pawn.Physics == PHYS_Walking && NearPlayer() &&
                LineOfSightTo(Level.GetLocalPlayerController().Pawn)
            ) ||
            VGVehicle(Level.GetLocalPlayerController().Pawn) != None 
        )
        {
            if( VGVehicle(Level.GetLocalPlayerController().Pawn) != None )
            {
                GotoState('RideWithPlayer');
            }

            FindBestPathToward( Level.GetLocalPlayerController().Pawn, false, false );
            if( MoveTarget == None ) 
            {
                GotoState('Lost');
            }

            if(Pawn.Physics != PHYS_Ladder)
            {
                FinishRotation();
            }
            
            if( MoveTarget == Level.GetLocalPlayerController().Pawn )
            {
                Destination = 
                    Level.GetLocalPlayerController().Pawn.Location + 
                    CATCHUPDIST * Normal(Pawn.Location - Level.GetLocalPlayerController().Pawn.Location);
                MoveTo( Destination, , ShouldWalk() );
            }
            else
            {
                MoveToward(MoveTarget,,,, ShouldWalk() );
            }
        }

        ResetAccel();
    }
    GotoState('Rest');
}

state ChatToPlayer
{
BEGIN:
    Pawn.Acceleration = vect(0,0,0);
    Focus = Level.GetLocalPlayerController().Pawn;
    FocalPoint = Focus.Location;
    FinishRotation();

}


//===============
// Riding a vehicle
//===============

function HopOnVehicle(VGVehicle veh)
{
    local VGPawn p;

    p = VGPawn(Pawn);
    p.PotentialVehicle = veh;
    p.PotentialVehicle.TryToRide(p, true);
}

function HopOffVehicle()
{
    local VGPawn p;
    p = VGPawn(Pawn);

    p.RiddenVehicle.EndRide(p);
    bIsRidingVehicle=False;
    p.SetPhysics(PHYS_Falling);
    p.SetBase(None);

}

state RideWithPlayer
{
ignores NotifyRunOver;

BEGIN:
    
    while( VGVehicle(Level.GetLocalPlayerController().Pawn).GetPassengerEntryPoint(EntrySpot)
        && !Pawn.ReachedDestination( EntrySpot ) )
    {
        if( FindBestPathToward(EntrySpot, false, true) )
        {
            MoveToward(EntrySpot);
        }
        else
        {
            GotoState('Lost');
        }
    }
HOPON:
    HopOnVehicle( VGVehicle(Level.GetLocalPlayerController().Pawn) );
    while(true)
    {
        Sleep(1.0);
        if( VGVehicle(Level.GetLocalPlayerController().Pawn) == None )
        {   HopOffVehicle();
            GotoState('FollowPlayer');
        }
    }
}

defaultproperties
{
     PlayerStopLookAtTime=-1.000000
}
