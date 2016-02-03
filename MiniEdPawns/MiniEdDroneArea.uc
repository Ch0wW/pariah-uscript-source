class MiniEdDroneArea extends Actor;

var float Radius;
var float Height;
var class<MiniEdAIDrone> DroneClass;

var MiniEdAIDrone MyDrone;
var float SenseDistance;

var vector OriginalLocation;	// if the area gets moved for some reason (ie, for the kamikaze drones) we can move it back to its original spot

function PostBeginPlay()
{
	SetCollisionSize(Radius, Height);
	OriginalLocation = Location;
	SpawnMyDrone();
}

simulated function Destroyed()
{
	Super.Destroyed();
	if(MyDrone != none) {
		MyDrone.Destroy();
		MyDrone = none;
	}
	log("DRONE AREA DESTROYED!");
}

function SpawnMyDrone()
{
	local MiniEdDrone p;
    local Vector Offset;
    
    Offset.Z = Height; // To avoid having spawning problems because of encroachment

	MyDrone = Spawn(DroneClass,self,,Location + Offset,Rotation);
	p = Spawn(MyDrone.GetDronePawnClass(), MyDrone,,Location + Offset,Rotation);
	MyDrone.MyDroneArea = self;
	MyDrone.Possess(p);
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

	vDir *= (f * Radius);

	v.x = Location.x + vDir.x - MyDrone.CollisionRadius;
	v.y = Location.y + vDir.y - MyDrone.CollisionRadius;

	return v;
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
     Height=300.000000
     SenseDistance=900.000000
     DroneClass=Class'MiniEdPawns.MiniEdAssaultDrone'
     bHidden=True
     bCollideActors=True
}
