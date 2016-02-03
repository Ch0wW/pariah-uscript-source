class DroneArea extends Actor
	placeable
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() float Radius;
var() float Height;
var() class<SPAIDrone> DroneClass;

var() bool bDebugInfo;

var SPAIDrone MyDrone;
var() float SenseDistance;

var vector OriginalLocation;	// if the area gets moved for some reason (ie, for the kamikaze drones) we can move it back to its original spot

var() edfindable Stage MyStage;	 //cmr - stage to add to on spawn

function PostBeginPlay()
{
	SetCollisionSize(Radius, Height);
	OriginalLocation = Location;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	SetLocation(OriginalLocation);

	log("Other = "$Other$", Inst = "$EventInstigator);
	if(MyDrone == None)
		SpawnMyDrone();

	if(EventInstigator != None && EventInstigator.IsA('SPPawnSearchDrone') ) {
		// as in DroneNode this might be better to use the TriggerEx version in the long run
		// this is the support drone spawn
		SPAIKamikazeDrone(MyDrone).bSeekTillDeath = true;
		SPAIKamikazeDrone(MyDrone).AttractTarget = Other;
		SPPawnSearchDrone(EventInstigator).addSupportDrone(SPAIKamikazeDrone(MyDrone) );
	}
}

function Tick(float dt)
{
	local Vector vh;

	if(bDebugInfo)
	{
		vh.z = Height;
		DrawDebugCircle( Location + vh/2, Radius );
		DrawDebugCircle( Location - vh/2, Radius );
	}

}

function AddDroneToStage()
{
	if(MyStage != None)
		MyStage.AddStageDrone(MyDrone);
}

function SpawnMyDrone()
{
	local SPPawnDrone p;

	MyDrone = Spawn(DroneClass,self,,Location,Rotation);
	p = Spawn(MyDrone.GetDronePawnClass(), MyDrone,,Location,Rotation);
	MyDrone.MyDroneArea = self;
	MyDrone.Possess(p);
	
	AddDroneToStage();
}

function Vector GetRandomLocation()
{
	local Vector v, vdir;
	local Rotator r;
	local float f;

	local float max, min;

	max = FMax(Location.Z - Height/2, Location.Z + Height/2);
	min = FMin(Location.Z - Height/2, Location.Z + Height/2);
	
	v.z = RandRange(min, max  );

	r.Yaw = Rand(65535);

	vDir = Vector(r);

	f = FRand();

	vDir *= (f * (Radius - MyDrone.CollisionRadius));

	v.x = Location.x + vDir.x;
	v.y = Location.y + vDir.y;

	return v;
}


function bool IsInArea(Vector v)
{
	local vector v2;
	if(v.z < Location.Z - Height/2 || v.z > Location.Z + Height/2)
		return false;

	v2 = v - Location;
	v2.z = 0;


	if( v2.x * v2.x + v2.y * v2.y < Radius*Radius )
		return true;
	else return false;


}

event Touch(Actor Other)
{
	if(MyDrone==None) return;

	if(MyDrone.CaresAbout(Other))
	{
		MyDrone.EnteredArea(Other);
	}
}

event UnTouch(Actor other)
{
	if(MyDrone != none)
		MyDrone.ExitArea(Other);
}

defaultproperties
{
     Radius=300.000000
     Height=200.000000
     SenseDistance=900.000000
     DroneClass=Class'PariahSPPawns.SPAIDrone'
     bHidden=True
     bCollideActors=True
}
