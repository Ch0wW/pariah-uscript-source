class AmmoPack extends VehiclePickupPlaceable;

var	Controller Killer;
var GrenadeFuse EnergyEffect;

var() float EnergyAmmount;

replication
{
	reliable if(Role == ROLE_Authority)
		EnergyAmmount;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// give a (small) random initial upward velocity
	Velocity.X = RandRange(-100, 100);
	Velocity.Y = RandRange(-100, 100);
	Velocity.Z = RandRange(0, 200);
}


//Only desire earned WECs or WECs of fallen teamates
function float BotDesireability( pawn Bot )
{
	if(Bot.Controller == None)
	{	
	    return -1;
	}

	return MaxDesireability;
}

function GiveToPawn(Pawn Other)
{
	local Inventory inv;

	if(Other != none) 
	{
		// add ammo to each weapon
		for(inv = Other.Inventory; inv != none; inv = inv.Inventory) 
		{
			if(inv.IsA('Weapon') && Weapon(inv).bAmmoFromPack) 
			{
			    Weapon(inv).Ammo[0].AddAmmo(Weapon(inv).Ammo[0].PickupAmmo);
			}
		}
	}

	AnnouncePickup(Other);
	SetRespawn();
}

static function int GetEnergyAmmount()
{
	return default.EnergyAmmount;
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
	Super.Landed(HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	local float GrenadeSpeed;

	//Note: The object should have a constant restitution coefficient but we do that to have a different behavior
	//		when it hits a wall and a flat surface
	if( HitNormal.Z > 0.7 )
		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
	else
	{
		Velocity = 0.45*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
	}

	//This slows down a grenade going up too fast (could hit the skybox?)
	GrenadeSpeed = VSize(Velocity);
	if ( Velocity.Z > 400 )
	{
		Velocity.Z = 0.5 * (400 + Velocity.Z);	
	}
	else if ( GrenadeSpeed < 10 && Physics == PHYS_Falling ) 
	{
		bBounce = false;
		//Stop it from rotating
//		SetRotation( R );
//		DesiredRotation = R;
//		bRotateToDesired = false;
	}

	Super.HitWall(HitNormal, Wall);
}

defaultproperties
{
     EnergyAmmount=5.000000
     RespawnEmitterClass=Class'VehicleEffects.ParticlePickupResHealth'
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=2.500000
     RespawnTime=60.000000
     DroppedLifeTime=50.000000
     PickupMessage="You picked up an Ammo Pack"
     CantPickupMessage="Ammo full."
     LifeSpan=55.000000
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.Assault.AmmoBundle'
     MessageClass=Class'VehicleGame.PickupMessage'
     RotationRate=(Yaw=0)
     Physics=PHYS_Falling
     bBounce=True
}
