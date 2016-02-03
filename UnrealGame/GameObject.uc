class GameObject extends Decoration
    abstract;

var bool            bHome;
var bool            bHeld;
var Pawn			Holder;
var GameObjective   HomeBase;
var Sound           TakenSounds[2];
var float           TakenTime;
var float           MaxDropTime;
var float           DisabledTime;
var bool            bDisabled;
var Controller FirstTouch;			// Who touched this objective first
var array<Controller> Assists;		// Who tocuhes it after


replication
{
    reliable if (Role == ROLE_Authority)
        bHome, bHeld, Holder;
}

// Initialization
function PostBeginPlay()
{
    //log(self$" PostBeginPlay owner="$owner, 'GameObject');

    HomeBase = GameObjective(Owner);
    SetOwner(None);

    Super.PostBeginPlay();
}

// State transitions
function SetHolder(Controller C)
{

    //log(self$" setholder c="$c, 'GameObject');
    LogTaken(c);
	//cmr --
    Holder = C.Pawn.GetHolder();//UnrealPawn(C.Pawn);

	//-- cmr
    C.PlayerReplicationInfo.HasFlag = self;
    PlayTakenSound();

    GotoState('Held');

	// AI Related	
	C.MoveTimer = -1;
	Holder.MakeNoise(2.0);

	// Track First Touch
	
	if (FirstTouch == None)
		FirstTouch = C; 

	// Track Assists

    if (Assists.Length < 2)
        Assists.Length = 2;

    Assists[0] = Assists[1];
    Assists[1] = C;

	/*for (i=0;i<Assists.Length;i++)
		if (Assists[i] == C)
		  return;
	
	Assists.Length = Assists.Length+1;
  	Assists[Assists.Length-1] = C;*/

}

function Score()
{
    //log(self$" score holder="$holder, 'GameObject');
    GotoState('Home');
}

function Drop(vector newVel)
{
    //log(self$" drop holder="$holder, 'GameObject');

    LogDropped();
    Velocity = newVel;
    GotoState('Dropped');
}

function SendHome()
{
    CalcSetHome();
    GotoState('Home');			
}

function SendHomeDisabled(float TimeOut)
{
    CalcSetHome();
    DisabledTime = TimeOut;
    GotoState('HomeDisabled');
}

// Helper funcs
protected function CalcSetHome()
{
    local Controller c;

	// AI Related	
    for (c = Level.ControllerList; c!=None; c=c.nextController)
        if (c.MoveTarget == self)
            c.MoveTimer = -1.0;

			
	LogReturned();
				
	// Reset the assists and First Touch
			
	FirstTouch = None;
	
	while (Assists.Length!=0)
	  Assists.Remove(0,1);
}

protected function ClearHolder()
{
    //log(self$" clearholder holder="$holder, 'GameObject');
    assert(Holder != None);

    if (Holder == None)       
        return;

    Holder.GetRealPRI().HasFlag = None;
    Holder = None;
}

protected function SetReplicatedState( GameReplicationInfo.GameObjectState gos )
{
}

protected function SetDisable(bool disable)
{
    bDisabled = disable;
    bHidden = disable;
}

function Actor Position()
{
    if (bHeld)
        return Holder;

    if (bHome)
        return HomeBase;

    return self;
}

function bool IsHome()
{
    return false;
}

function bool ValidHolder(Actor other)
{
    local Pawn p;

    if( bDisabled )
        return false;
    //log(self$" ValidHolder other="$other, 'GameObject');

    p = Pawn(other);
    if (p == None || p.Health <= 0 || !p.IsPlayerPawn() || !p.bCanHoldGameObjects)
        return false;

    return true;
}

function PlayTakenSound()
{
    local controller c;

    if (Holder == None || Holder.PlayerReplicationInfo == None || Holder.PlayerReplicationInfo.Team == None)
        return;

    for ( c=Level.ControllerList; c!=None; c=c.NextController )
        if ( c.IsA('PlayerController') )
            PlayerController(c).PlayAnnouncement(TakenSounds[Holder.PlayerReplicationInfo.Team.TeamIndex],2,true);
}

// Events
singular function Touch(Actor Other)
{
    //log(self$" Touch other="$other, 'GameObject');

    if (!ValidHolder(Other))
        return;

    SetHolder(Pawn(Other).Controller);
}

event FellOutOfWorld(eKillZType KillType)
{
    //log(self$" FellOutOfWorld", 'GameObject');
    SendHome();
}

function Landed(vector HitNormall)
{
	local Controller C;

    //log(self$" landed", 'GameObject');
	
    // tell nearby bots about this
    for (C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if ((C.Pawn != None) && (Bot(C) != None) 
            && (C.RouteGoal != self) && (C.Movetarget != self) 
            && (VSize(C.Pawn.Location - Location) < 1600)
            && C.LineOfSightTo(self) )
        {
			Bot(C).Squad.Retask(Bot(C));	
        }
    }
}

singular simulated function BaseChange()
{
    //log(self$" basechange", 'GameObject');
}

// Logging
function LogTaken(Controller c);
function LogDropped();
function LogReturned();

// States
auto state Home
{
    ignores SendHome, Score, Drop;

    function bool IsHome()
    {
        return true;
    }

    function BeginState()
    {
        //log(self$" home.beginstate", 'GameObject');
        SetReplicatedState(GOS_Home);
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
    }

    function EndState()
    {
        //log(self$" home.endstate", 'GameObject');
        bHome = false;
        TakenTime = Level.TimeSeconds;
    }
}

state HomeDisabled
{
    ignores Score, Drop;

    function bool IsHome()
    {
        return true;
    }

    function BeginState()
    {
        log(self$" HomeDisabled.beginstate", 'GameObject');
        SetReplicatedState(GOS_Home);
        SetDisable(true);
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
        SetCollision(false, false, false);
        bHidden = true;
    }

    function EndState()
    {
        SetDisable(false);
        log(self$" HomeDisabled.endstate", 'GameObject');
        bHome = false;
        SetCollision(true, false, false);
        bHidden = false;
    }
}

state Held
{
    ignores SetHolder, SendHome;

    function BeginState()
    {
        //log(self$" held.beginstate", 'GameObject');
        SetReplicatedState(GOS_Held);
        bHeld = true;
        bCollideWorld = false;
        SetCollision(false, false, false);
        SetLocation(Holder.Location);
        Holder.HoldGameObject(self);
    }

    function EndState()
    {
        //log(self$" held.endstate", 'GameObject');

        ClearHolder();
        bHeld = false;
        bCollideWorld = true;
        SetCollision(true, false, false);
        SetBase(None);
        SetRelativeLocation(vect(0,0,0));
        SetRelativeRotation(rot(0,0,0));
    }
}

state Dropped
{
    ignores Drop;

    function BeginState()
    {
        //log(self$" dropped.beginstate", 'GameObject');
        SetReplicatedState(GOS_Dropped);
        SetPhysics(PHYS_Falling);
        SetTimer(MaxDropTime, false);
    }

    function EndState()
    {
        //log(self$" dropped.endstate", 'GameObject');
        SetPhysics(PHYS_None);
    }

    function Timer()
	{
		SendHome();
	}
}

defaultproperties
{
     MaxDropTime=25.000000
     bUseCylinderCollision=True
}
