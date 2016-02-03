// these are nodes for the all-seeing drone to follow

class DroneNode extends DroneArea;

var() float nodeTime;	// how much time the drone should spend at this node
var() Name NextNode;
var() Name PrevNode;

var() array<Name> SupportNodes;

function Trigger(Actor Other, Pawn EventInstigator)
{
	if(Other.IsA('SPAIDrone') ) {
		// this has been triggered by a drone wanting to move to this node... I may prefer to switch this to the TriggerEx down the road
		MyDrone = SPAIDrone(Other);
		MyDrone.Destination = Location;
		MyDrone.MyDroneArea = self;
	}
	else if(MyDrone == None) {
		SpawnMyDrone();
		if(MyDrone != none)
			MyDrone.SetMultiTimer(0, nodeTime, false);
	}
}

event Touch(Actor Other)
{
	if(MyDrone==None || MyDrone.MyDroneArea != self) return;

	if(MyDrone.CaresAbout(Other) )
	{
		MyDrone.EnteredArea(Other);
	}
}

function SpawnMyDrone()
{
	local SPPawnDrone p;

	MyDrone = Spawn(DroneClass,,,Location,Rotation);
	p = Spawn(MyDrone.GetDronePawnClass(), MyDrone,,Location,Rotation);
	MyDrone.MyDroneArea = self;
	MyDrone.Possess(p);

	if(MyDrone.IsA('SPAISearchDrone') )
		SPAISearchDrone(MyDrone).startNode = self;

	AddDroneToStage();
}

function SpawnSupport(Actor Victim)
{
	local int n;

	for(n = 0; n < SupportNodes.Length; n++) {
		log("-> Spawning support drone at "$SupportNodes[n]);
		TriggerEvent(SupportNodes[n], Victim, MyDrone.Pawn);
	}
}

defaultproperties
{
     nodeTime=1.000000
     Radius=150.000000
     Height=300.000000
}
