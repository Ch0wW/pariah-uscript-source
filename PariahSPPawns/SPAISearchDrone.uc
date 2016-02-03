class SPAISearchDrone extends SPAIDrone;

var bool bWantToMove; // time to move on to next node
var bool bForward;	  // moving forward along the node path
var bool bScanning;

var DroneNode startNode;
var vector seenTarget;

var SPPawnSearchDrone searchDrone;

var float FloatTimer;

var bool bScanLeft;					// scanning to left (if true) right otherwise
var bool bLightScanning;			// search light is scanning
var (Scanning) float ScanSpeed;		// speed of search light
var (Scanning) vector ScanDir;		// search light direction
var (Scanning) vector ScanTarget;	// target direction for the search light
var (Scanning) Range ScanLimits;	// side-to-side limits of the search light

const ScanMaxDist = 900;
const ScanHalfDist = 450;

const ScanRate = 0.025;	// rate at which the search light is updated

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// initialize the scanning
	SetMultiTimer(1, 0.25, true);
	SetMultiTImer(2, ScanRate, true);
}

/*function Tick(float dt)
{
	local Vector dir, loc;

	if(bScanning) {
		dir = Normal(Vector(Rotation));
		loc = Pawn.Location + dir * ScanHalfDist;

		DrawDebugCircle(Loc, ScanHalfDist);
		DrawDebugCircle(Loc, ScanHalfDist, Vect(0,0,1));
		DrawDebugCircle(Loc, ScanHalfDist,,Vect(0,0,1));
	}

	Super.Tick(dt);
}*/

function PickNewAction()
{
	local DroneNode node;
	local Name targetNode, alternateNode;

	searchDrone = SPPawnSearchDrone(Pawn);

	if(bWantToMove) {
		// move to next node, if there is one
		node = DroneNode(MyDroneArea);
		if(node != none) {
			// get the target node
			if(bForward) {
				targetNode = node.NextNode;
				alternateNode = node.PrevNode;
			}
			else {
				targetNode = node.PrevNode;
				alternateNode = node.NextNode;
			}

			if(targetNode == '') {
				// reached the end of the path, so switch directions
				bForward = !bForward;
				targetNode = alternateNode;
			}

			if(targetNode != '') {
				TriggerEvent(targetNode, self, Pawn);
				GotoState('MoveToNode');
				curAction = "MoveToNode";
			}
		}

		bWantToMove = false;
	}
	else
		Super.PickNewAction();
}

function MultiTimer(int slot)
{
	switch(slot) {
		case 0:
			// set to move during next PickNewAction call
			bWantToMove = true;
			break;
		case 1:
			// scanning
			if(bScanning)
				CheckView();
			break;
		case 2:
			// move search light
			Scanning();
			break;
	}
}

function Scanning()
{
	if(bLightScanning) {
		if(bScanLeft) {
			ScanDir.Y -= ScanSpeed*ScanRate;
			if(ScanDir.Y <= ScanLimits.Min)
				bScanLeft = false;
		}
		else {
			ScanDir.Y += ScanSpeed*ScanRate;
			if(ScanDir.Y >= ScanLimits.Max)
				bScanLeft = true;
		}
	}
	else {
		if(abs(ScanDir.Y) < 0.025)
			ScanDir.Y = 0;
		else
			ScanDir.Y *= 0.5;
	}

	searchDrone.SearchLight.SetRelativeRotation(rotator(ScanDir) );
}

function CheckView()
{
	local Vector dir, loc;
	local Pawn p;
	local HavokActor h;

//	dir = Normal(Vector(Rotation));
	dir = Normal(Vector(searchDrone.SearchLight.Rotation) );

	loc = Pawn.Location + dir * ScanHalfDist;

	ForEach CollidingActors(class'Pawn',p, ScanHalfDist, loc) {
		if(p.IsA('SPPlayerPawn') || (p.IsA('SPPawn') && SPPawn(p).race == R_NPC) ) {
			log("I see "$p@ Normal(Location - p.Location) dot dir);
			if(Normal(p.Location - Pawn.Location) dot dir > 0.5) {
				if(IsValidPawnTarget(p)) {
					FoundPawnTarget(p);
					break;
				}
			}
		}
	}

	ForEach CollidingActors(class'HavokActor',h, ScanHalfDist, loc) {
		//log("I see "$p@ Normal(Location - p.Location) dot dir);
		if(Normal(h.Location - Pawn.Location) dot dir > 0.9) {
			//log("I see "$h);
			if(IsValidHavokTarget(h)) {
				FoundHavokTarget(h);
				break;
			}
		}
	}
}

state MoveToNode
{
	function bool CaresAbout(Actor Other)
	{
		return other == Pawn;
	}

	function EnteredArea(Actor Other)
	{
//		Pawn.bFlyingBrake = false;
		curAction="Wander";
		GotoState('DroneWander','BEGIN');
		Pawn.Velocity = vect(0, 0, 0);
		Pawn.Acceleration = vect(0, 0, 0);
//		PickNewAction();
		if(MyDroneArea.IsA('DroneNode') )
			SetMultiTimer(0, DroneNode(MyDroneArea).nodeTime, false);
	}

//End:
//	MoveTo(Pawn.Location);
//	Pawn.bFlyingBrake = true;

Begin:
//	log("=> Start MoveToNode");
	FocalPoint = Destination;
	FinishRotation();
	MoveTo(Destination);
	Pawn.bFlyingBrake = true;
	Sleep(0.05);
	Pawn.bFlyingBrake = false;
}

// extending antenae
state Extending
{
Begin:
	MoveTo(Pawn.Location);
	Pawn.Velocity = vect(0, 0, 0);
	Pawn.Acceleration = vect(0, 0, 0);
	curAction = "Alerting";
	FocalPoint = Target.Location;
	FinishRotation();

	SPPawnSearchDrone(Pawn).SearchLight.SetSkin(0, Material'PariahGametypeTextures.Camera.viewcone_red_shader');

	// extending the antenae takes 2 seconds, the drone can be destroyed in this time before summoning the other drones
	bLightScanning = false;
	Sleep(2.0);

	// summon drones
//	log("SUMMONING stealth drones");
	if(startNode != none)
		startNode.SpawnSupport(Target);
	else
		log("-> WARNING:  Don't know how to spawn support drones!");

	GotoState('Annoying');
}

// annoying the player by moving in front of them
state Annoying
{
Begin:
	Pawn.Airspeed = 625;
	Pawn.AccelRate = 3750.000000;
	
	seenTarget = Target.Location+Target.Velocity*0.15+vector(Pawn(Target).Controller.Rotation)*300+vect(0, 0, 150);
	curAction = "Following";
//	FocalPoint = Target.Location;
	MoveTo(seenTarget, Target);
//	FocalPoint = Target.Location;
	Pawn.bFlyingBrake = true;
//	FinishRotation();

	Sleep(0.01);
	Pawn.bFlyingBrake = false;
	GotoState('Annoying', 'BEGIN');
}

function class<SPPawnDrone> GetDronePawnClass()
{
	return class'SPPawnSearchDrone';
}

function bool IsValidHavokTarget(HavokActor h)
{
	if(VSize(h.Velocity) > 10.0 )
		return true;
	else
		return false;
}


function FoundHavokTarget(Actor NewTarget)
{
	Target = NewTarget;
//	log("Scanning identified:  "$Target);
	SetMultiTimer(1, 0, false);
	GotoState('Extending');
}

function bool IsValidPawnTarget(Pawn P)
{
	if(	P.IsA('SPPlayerPawn') || (P.IsA('SPPawn') && SPPawn(P).race == R_NPC) )
		return true;
	else return false;
}

function FoundPawnTarget(Actor NewTarget)
{
	Target = NewTarget;
//	log("Scanning identified:  "$Target);
	SetMultiTimer(1, 0, false);
	GotoState('Extending');
}

defaultproperties
{
     ScanSpeed=1.500000
     ScanDir=(X=6.000000,Z=-4.000000)
     ScanLimits=(Min=-3.000000,Max=3.000000)
     bForward=True
     bScanning=True
     bLightScanning=True
}
