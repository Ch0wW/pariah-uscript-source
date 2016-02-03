class MiniEdAssaultDrone extends MiniEdAIDrone;

var Pawn AttackTarget;		// target to attack
var float AttackDistance;	// maximum attack distance
var float AttackHalfDistance;

// properties to manage drone's movement while attacking
var vector AttackStart;		// where the drone was when the attack commenced
var vector AttackLimitLeft;	// drone's leftwards movement limits
var vector AttackLimitRight;// drone's rightward movement limits
var vector AttackFrom;		// where the drone wants to attack from
var float droneMoveFreq;	// how often the drone moves (base value)
var float droneMoveVar;		// variance in how often the drone moves
var float MaxMoveDist;
var sound ShootSound;

// drone's attacking properties
var float FireRate;
var float Spread;
var float NextFireTime;
var class<Projectile> ProjectileClass;

var Name PrevState;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetMultiTimer(0, 0.25, true);
}

function PickNewAction()
{
	if(FRand() < 0.65)
	{
//		curAction="Wander";
		GotoState('DroneWander','BEGIN');
	}
	else
	{
//		curAction="Hover";
		GotoState('DroneHover','BEGIN');
	}

}

function class<MiniEdDrone> GetDronePawnClass()
{
	return class'MiniEdPawnAssaultDrone';
}

// scan for potential targets
function MultiTimer(int slot)
{
	local Vector dir, loc;
	local Pawn p;
	local float timeToNextMove;

	switch(slot) {
		case 0:
			if(AttackTarget == none) {
				// no target to fire at yet so we search for one
				dir = Normal(Vector(Rotation));
				loc = Pawn.Location+dir*AttackHalfDistance;

				foreach CollidingActors(class'Pawn',p, AttackHalfDistance, loc) {
//					if(p.IsA('SPPlayerPawn') || (p.IsA('SPPawn') && SPPawn(p).race != SPPawn(Pawn).race) ) {
//						log("I see "$p@ Normal(Location - p.Location) dot dir);
//				if(Normal(p.Location - Pawn.Location) dot dir > 0.5) {
//					log("** Considering "$p$" as attack target");
					if(p.IsA('VGPawn') && p.Controller != none) {
//						log("   Attacking "$p.Controller);
							AttackTarget = p;
							NextFireTime = Level.TimeSeconds+FireRate;
							GotoState('Attacking');
							break;
//				}
					}
				}
			}
			else {
				// double check to make sure that the target is in firing distance
				if(VSize(AttackTarget.Location-Pawn.Location) > AttackDistance*1.25)
					AttackTarget = none;
			}
			break;
		case 1:
			PickAttackSpot();
			timeToNextMove = droneMoveFreq+FRand()*droneMoveVar;
			SetMultiTimer(1, timeToNextMove, false);
			GotoState('Attacking', 'BEGIN');
			break;
	}
}

function bool CaresAbout(Actor Other)
{
	// want to watch out for projectiles and attempt to avoid them
//	if(Other.IsA('Projectile') )
//		return true;

	return false;
}

function EnteredArea(Actor Other)
{
}

function Tick(float dt)
{
	local Projectile p;
	local vector projStart;
	local rotator dir;

	if(AttackTarget != none) {
		// there is something to attack so... ATTACK!
		if(Level.TimeSeconds >= NextFireTime) {
			// it's time to fire the next shot
			NextFireTime += FireRate;

			// dertermine projectile start position
			projStart = Pawn.Location;

			// in here we'll do some aiming...  what I think I'll do is put in some sort of "spread" for shots
			// which will vary based on distance from target (more accurate closer up)
			dir = rotator(AttackTarget.Location-projStart+VRand()*FRand()*Spread);

            if(ShootSound != None)
	            Pawn.PlaySound(ShootSound);
    		p = Spawn(ProjectileClass,,, projStart, Dir);

			if(p != none) {
				p.ProjOwner = self;
				p.Instigator = Pawn;
				p.Damage *= 0.5;
			}
		}

		if(AttackTarget.Health <= 0)
			AttackTarget = none;
	}

	Super.Tick(dt);
}

auto state DroneWander
{
	function EndState() //cleanup
	{
		if(Pawn != none)
			Pawn.bFlyingBrake=false;
	}

BEGIN:
//	log("==> Start WANDER");

	if(!PickRandomDestination()) GotoState('DroneWander','BEGIN');

	FocalPoint = Destination;
	FinishRotation();
//	Sleep(SPPawnAssaultDrone(Pawn).SetMoveParams(Destination) );
//	SPPawnAssaultDrone(Pawn).MoveDir = Normal(Destination-Pawn.Location);

	MoveTo(Destination);
	Pawn.bFlyingBrake=true;

	sleep(0.5);

	PickNewAction();
}

function PickAttackSpot()
{
	local vector EndPt;
	local float u;
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local bool bFoundSpot;

	if(FRand() < 0.5)
		EndPt = AttackLimitLeft;
	else
		EndPt = AttackLimitRight;

	while(!bFoundSpot) {
		u = RandRange(0.15, 0.95);
		AttackFrom = (1.0-u)*AttackStart+u*EndPt;

		u = MyDroneArea.Height*0.5;
		AttackFrom.Z = RandRange(MyDroneArea.Location.Z-u, MyDroneArea.Location.Z+u);
		AttackFrom += (VRand()*75);

		// test the attack position
		HitActor = Trace(HitLocation, HitNormal, AttackFrom, Pawn.Location, false);
		if(HitActor != None) {
			AttackFrom = HitLocation + HitNormal*Pawn.CollisionHeight*3.0;
			if(!FastTrace(AttackFrom, Pawn.Location) ) {
				// need to try again...
				bFoundSpot = false;
				continue;
			}
		}

		bFoundSpot = true;
	}

//	log("Now attacking from "$AttackFrom);
}

state Attacking
{
	function BeginState()
	{
		local float timeToNextMove;
		local vector tempStart, tempTarget, dist;
		local rotator fortyfive;

		tempStart = Pawn.Location;
		tempStart.Z = 0;

		tempTarget = AttackTarget.Location;
		tempTarget.Z = 0;

		dist = tempTarget-tempStart;
		if(VSize(dist) > MaxMoveDist)
			dist = Normal(dist)*MaxMoveDist;

		// this should be about 45 degrees (pi/4 radians)
		fortyfive.yaw = 8192;

		// set up attacking parameters
		AttackStart = tempStart;

		AttackLimitLeft = tempStart+(dist>>fortyfive);
		fortyfive.yaw = -8192;
		AttackLimitRight = tempStart+(dist>>fortyfive);

//		log("AttackStart = "$AttackStart);
//		log("AttackLimitLeft = "$AttackLimitLeft);
//		log("AttackLimitRight = "$AttackLimitRight);

		PickAttackSpot();

		timeToNextMove = droneMoveFreq+FRand()*droneMoveVar;
		SetMultiTimer(1, timeToNextMove, false);
		NextFireTime = Level.TimeSeconds+FireRate;
	}

	function Tick(float dt)
	{
		if(AttackTarget != none)
			FocalPoint = AttackTarget.Location;
		else
			GotoState('DroneWander');

		Global.Tick(dt);
	}

	function EndState()
	{
		if(Pawn != none) {
			Pawn.Airspeed = Pawn.default.Airspeed;
			Pawn.AccelRate = Pawn.default.AccelRate;
			Pawn.bFlyingBrake = false;
			SetMultiTimer(1, 0, false);
		}

		AttackDistance = default.AttackDistance;
	}

BEGIN:
//	log("beginning...");
	FocalPoint = AttackTarget.Location;
//	FinishRotation();
	Pawn.Airspeed=850;
	Pawn.AccelRate=60000.000000;
	MoveTo(AttackFrom);

	Pawn.Airspeed = Pawn.default.Airspeed;
	Pawn.AccelRate = Pawn.default.AccelRate;
	Pawn.bFlyingBrake = true;
}

state Dodge
{
BEGIN:
	Pawn.Airspeed = 20000;
	Pawn.AccelRate = 60000.0;
	MoveTo(AttackFrom);

	Pawn.Airspeed = Pawn.default.Airspeed;
	Pawn.AccelRate = Pawn.default.AccelRate;
	Pawn.bFlyingBrake = true;
	Sleep(0.25);
	GotoState(PrevState);
}

defaultproperties
{
     AttackDistance=1200.000000
     AttackHalfDistance=600.000000
     droneMoveFreq=0.750000
     droneMoveVar=0.500000
     MaxMoveDist=350.000000
     FireRate=0.400000
     Spread=100.000000
     ShootSound=Sound'KeepersAndDrones.drone.DroneFire'
     ProjectileClass=Class'VehicleWeapons.DronePlasma'
}
