//=============================================================================
class PickupMarker extends Actor 
	hidecategories(Lighting,LightColor,Karma,Force)
	native
	placeable;

var	(PickupMarker)	class<VehiclePickupPlaceable>		PickupClass;
var	(PickupMarker)	class<VehicleWeaponPickupPlaceable>	WeaponPickupClass;

var	(PickupMarker)	float PickupRespawnTime;	//if 0 will use default pickup time

var (PickupMarker)  bool bSpawnByTrigger;


var(Events) const editconst Name hSpawnPickup;

var		VehiclePickup			Pickup;
var		float					PickupHeight;
var		InventorySpot			MyMarker;

simulated function PostBeginPlay()
{
	if(!bSpawnByTrigger)
		SpawnMyPickup();
}

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hSpawnPickup:
		if(Pickup == None && bSpawnByTrigger)
			SpawnMyPickup();
		break;
	}
}

function SpawnMyPickup()
{
	local vector tempLoc;
	local float TempCullDistance;

	tempLoc = Location;
	tempLoc.Z += PickupHeight;
	TempCullDistance = Culldistance;

	if(PickupClass != none)
	{
		Pickup = spawn(PickupClass,,,tempLoc);
	}
	else if(WeaponPickupClass != none)
	{
		Pickup = spawn(WeaponPickupClass,,,tempLoc);
	}
	if (myMarker != None)
	{
		myMarker.markedItem = Pickup;

		if (Pickup != None)
		{
			Pickup.MyMarker = MyMarker;
		}
	}
	if(Pickup != None)
	{
		if(PickupRespawnTime != 0)
		{
			Pickup.RespawnTime = PickupRespawnTime;
		}
	}
	Pickup.Culldistance = TempCullDistance;
}

defaultproperties
{
     hSpawnPickup="SPAWNPICKUP"
     CollisionRadius=40.000000
     CollisionHeight=15.000000
     bHidden=True
     bHasHandlers=True
     bCollideWhenPlacing=True
     bCollideWorld=True
     bUseCylinderCollision=True
}
