class SPAIKamikazeDrone extends SPAIDrone;

var Actor AttractTarget;
var Vector AttractLocation;
var float SenseVelocity;
var float SenseDistance;

var bool bSeekTillDeath;	// flag for drones spawned by the all-seeing drone, will seek target until dead (or the all-seeing one dies or something)

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetMultiTimer(3, 0.25, true);

	AttractLocation = Location;
}

function class<SPPawnDrone> GetDronePawnClass()
{
	return class'SPPawnKamikazeDrone';
}

// check for things moving faster than a certain speed
function SenseMovement()
{
	local Pawn victim;
	local Projectile proj;
	local float dist;

	if(MyDroneArea != none)
		dist = MyDroneArea.SenseDistance;
	else
		dist = SenseDistance;

//	log("sensing movement...");
	ForEach VisibleCollidingActors(class'Pawn', victim, dist, Pawn.Location) {
//		log(dist$" -> Checking "$victim);
		if(victim != Pawn && !victim.IsA('SPPawnDrone') && VSize(victim.Velocity) > SenseVelocity) {
//			log("Sensed movement from "$victim);
			curAction = "Attract";
			AttractTarget = victim;
			GotoState('Seeking', 'BEGIN');
			return;
		}
	}

	ForEach VisibleCollidingActors(class'Projectile', proj, dist, Pawn.Location) {
		if(!proj.bPaused && VSize(proj.Velocity) > SenseVelocity) {
//			log("Sensed movement from "$proj);
			curAction = "Attract";
			AttractTarget = proj;
			GotoState('Seeking', 'BEGIN');
			return;
		}
	}
}


function bool CaresAbout(Actor Other)
{
	if(Other.IsA('Pawn') || Other.IsA('Projectile'))
		return true;
	
	return false;
}

function EnteredArea(Actor Other)
{
	if(!Other.IsA('SPPawnDrone') && !Other.bPaused && DroneCanSee(Other) && VSize(Other.Velocity) > SenseVelocity && Other != Pawn)
	{
//		log(Other$"'s Velocity = "$VSize(Other.Velocity)$" / "$SenseVelocity );
		curAction="Attract";
		AttractTarget=Other;
		AttractLocation=Other.Location;
		GotoState('Seeking', 'BEGIN');
	}
}

function bool DroneCanSee(Actor Other) //since drones are supposed to be lightweight, do a simple single trace to determine visibiltiy
{
	return Other!=None && Pawn != none && FastTrace(Other.Location, Pawn.Location);
}

state Seeking
{
	ignores HearNoise;
//	function BeginState()
//	{
//	}
	function EndState()
	{
		SetMultiTimer(2, 0, false);
	}

BEGIN:
	SetMultiTimer(2, 0.33, true);

	SPPawnKamikazeDrone(Pawn).bChasing = true;
	MoveToward(AttractTarget);

	PickNewAction();
}

state StopSeeking
{
	function EndState()
	{
		if(MyDroneArea != none) {
			MyDroneArea.SetLocation(Pawn.Location);
//			log("   (b) new area loc = "$MyDroneArea.Location);
		}

		Pawn.bFlyingBrake = false;
		Pawn.Velocity = vect(0, 0, 0);
		Pawn.Acceleration = vect(0, 0, 0);
		SPPawnKamikazeDrone(Pawn).bChasing = false;
	}

Begin:
//	log("stop seeking...");

	MoveTo(AttractLocation);
//	log(" * MoveTo ends");
	if(MyDroneArea != none) {
		MyDroneArea.SetLocation(Pawn.Location);
//		log("   new area loc = "$MyDroneArea.Location);
	}

	Pawn.bFlyingBrake = true;
	Sleep(0.01);
	Pawn.bFlyingBrake = false;

	PickNewAction();
}

state SearcherDestroyed
{
	function EndState() {
		bSeekTillDeath = false;
	}

Begin:
	MoveTo(AttractLocation);
	if(MyDroneArea != none)
		MyDroneArea.SetLocation(AttractLocation);

	Pawn.bFlyingBrake = true;
	Sleep(0.01);

	Pawn.bFlyingBrake = false;
	PickNewAction();
}

function ExitArea(Actor Other)
{
//	if(other == AttractTarget && Other.IsA('Projectile') )
//	{
//		AttractLocation = Other.Location;
//		GotoState('LostAttracting','BEGIN');
//	}
	if(Other == Pawn && AttractTarget == none)
	{
		Pawn.Acceleration = vect(0, 0, 0);
		Pawn.Velocity = vect(0, 0, 0);
//		Pawn.bFlyingBrake=true;
		SetMultiTimer(1, 0.25, false);
	}
}

function ConfirmTracked()
{
	local float dist;
	local bool bStopSeeking;

	if(MyDroneArea != none)
		dist = MyDroneArea.Radius*2;
	else
		dist = SenseDistance;

	if(VSize(AttractTarget.Velocity) < SenseVelocity) {
//		log("No longer tracking "$AttractTarget$" (too slow)");
		bStopSeeking = true;
	}
	else if(AttractTarget.bPaused) {
//		log("No longer tracking "$AttractTarget$" (blown up)");
		bStopSeeking = true;
	}
	else if(VSize(AttractTarget.Location-Pawn.Location) > dist) {
//		log("No longer tracking "$AttractTarget$" (too far away)");
		bStopSeeking = true;
	}

	if(bStopSeeking) {
		if(AttractTarget.IsA('Projectile') )
			AttractLocation = (Pawn.Location+AttractTarget.Location)*0.5;
		else
			AttractLocation = AttractTarget.Location;

		AttractTarget = none;
		GotoState('StopSeeking');
	}
}

function MultiTimer(int slot)
{
	switch(slot) {
		case 3:
			if(AttractTarget == none)
				SenseMovement();
			else if(!bSeekTillDeath)
				ConfirmTracked();
//				GotoState('LostAttracting');
			break;
		case 1:
//			log("!!!!");
			PickNewAction();
			break;
		case 2:
			if(!DroneCanSee(AttractTarget) ) {
				MyDroneArea.SetLocation(Pawn.Location);
				AttractTarget = none;
				SetMultiTimer(2, 0, false);
				PickNewAction();
			}
			break;
	}
}

function PickNewAction()
{
	if(AttractTarget != none) {
		// we're still chasing a target
		GotoState('Seeking', 'BEGIN');
	}
	else if(FRand() >= 0)
	{
		curAction="Wander";
		GotoState('DroneWander','BEGIN');
	}
	else
	{
		curAction="Hover";
		GotoState('DroneHover','BEGIN');
	}
		
}

defaultproperties
{
     SenseVelocity=280.000000
     SenseDistance=900.000000
}
