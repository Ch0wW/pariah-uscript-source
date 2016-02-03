class VehicleStart extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_Vehicle.pcx Name=S_Vehicle Mips=Off MASKED=1

var() class<VGVehicle>	VehicleType;
var() class<VehicleWeapon> Weapons[3];
var() bool bSpawnEnabled;
var() float RespawnTime;
var() float VehicleTimeTillDeathIfUnowned;
var() byte TeamNumber;
var() bool bGametypeIndependant;

var VGVehicle myVehicle;

function PostNetBeginPlay()
{
	if(bSpawnEnabled)
	{
		SpawnVehicle();
	}
}

function bool IsSameAs(VehicleStart other)
{
	return VehicleType == Other.VehicleType;
}

function PrintInfo()
{
	log(Name$" Enabled: "$bSpawnEnabled$" Team: "$TeamNumber$" RespawnTime: "$RespawnTime$" MyVehicle is "$myVehicle);
}

function SpawnVehicle()
{
	if(myVehicle!=None) return;

	myVehicle = spawn(VehicleType,self,,Location,Rotation);

	if(myVehicle==None)
	{
		log("VehicleStart "$self$" Failed to Spawn Vehicle");
		return;
	}

	myVehicle.SetupVehicleWeapons();
	myVehicle.myStart = self;
	myVehicle.TimeTillDeath = VehicleTimeTillDeathIfUnowned;
	myVehicle.bUntouched = True;
}

function VGVehicle DisableSpawn()
{
	local VGVehicle ret;
	bSpawnEnabled = False;
	//if have a vehicle, get rid of it. 

	//if(myVehicle != None)
	//{
	//	myVehicle.Destroy();
	//	myVehicle = None;
	//}

	ret = myVehicle;

	myVehicle = None;

	if(ret != None)
		ret.myStart = None;

	return ret;
}

function EnableSpawn(VGVehicle newVehicle, optional bool bForce)
{
	bSpawnEnabled = True;

	if(((myVehicle != None && newVehicle == None) || (myVehicle == newVehicle))  && !bForce)
		return;



	if(myVehicle != None)
	{
		myVehicle.myStart = None;
		myVehicle=None;
	}

	if(newVehicle != None)
	{
		if(!newVehicle.bUntouched)
		{
			newVehicle.myStart = self;
			myVehicle = newVehicle;
		}
		else
		{
			newVehicle.bUntouched = false;
			SetTimer(RespawnTime, False);
		}
	}
	else
	{
		SetTimer(RespawnTime, False);
	}
}

function VehicleDied()
{
	//log("MY VEHICLE DIED");
	myVehicle=None;
	if(RespawnTime<=0) RespawnTime = 1.0;

	//log("respawntime = "$respawntime);
	SetTimer(RespawnTime, false);
	//maybe play an effect now
}

event Timer()
{
	//log("TIMER");

	if(bSpawnEnabled)
	{
		SpawnVehicle();
	}
}	

event PreLoadData()
{
	Super.PreLoadData();
	PreLoad( VehicleType );
}

defaultproperties
{
     RespawnTime=5.000000
     VehicleTimeTillDeathIfUnowned=20.000000
     bSpawnEnabled=True
     CollisionRadius=0.000000
     CollisionHeight=230.000000
     Texture=Texture'VehicleGame.S_Vehicle'
     bHidden=True
     bDirectional=True
     bNeedPreLoad=True
}
