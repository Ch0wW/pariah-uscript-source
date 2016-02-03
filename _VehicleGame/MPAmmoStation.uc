class MPAmmoStation extends Actor placeable;

var array<Pawn> chargingPawns;	// list of pawns the ammo station is charging

var () float chargeRadius;		// how close we need to be to the station to be charging
var () float rechargeFreq;		// frequences of recharging
var () float rechargeTime;		// total time for recharging
var    float ammoPerTick;		// amount of ammo restored per time period
var	   float LastTouchTime;		// Time from last Player Touch

var bool	bStationOpen;		// replicated
var bool	bCurStationOpen;

var MPAmmoStationCollision box;

replication
{
	reliable if ( Role==ROLE_Authority )
		bStationOpen;
}

simulated function PostBeginPlay()
{
	box = spawn(class'MPAmmoStationCollision',self,,Location,Rotation);
	box.Station = self;

	if(Role == ROLE_Authority) 
	{
		SetTimer(rechargeFreq, true);
	}
}

event Bump(Actor Other)
{
	Touch(Other);
	Super.Bump(Other);
}

simulated function OpenStation()
{
	PlayAnim( 'Open', 1.0 );
}

simulated function CloseStation()
{
	PlayAnim( 'Close', 1.0 );
}

event Touch(Actor Other)
{
	local int n;


	if (Other.IsA('VGPawn') && ((Level.TimeSeconds-LastTouchTime)>=0.5) ) PlaySound(Sound'VehicleGameSounds.DefaultPickupSound');

	LastTouchTime = Level.TimeSeconds;

	if(Other.IsA('VGPawn') && Role == ROLE_Authority) 
	{

		// add to the list of charging pawns if not already on it
		for(n = 0; n < chargingPawns.length; n++) 
		{
			if(chargingPawns[n] == Pawn(Other) )
				return;
		}
		if ( chargingPawns.length == 0 )
		{
			bStationOpen = true;
			OpenStation();
		}
		chargingPawns[chargingPawns.length] = Pawn(Other);
	}
}

simulated function Timer()
{
	local vector dir;
	local int n, sl;

	if(Role == ROLE_Authority) 
	{
		sl = chargingPawns.length;
		for(n = 0; n < chargingPawns.length; n++) 
		{
			dir = Location-chargingPawns[n].Location;
			if(VSize(dir) > chargeRadius) 
			{
				chargingPawns.Remove(n, 1);
				n--;
				continue;
			}

			if(Vector(chargingPawns[n].Rotation) dot dir > 0) 
			{
				// only charge if facing the station
				chargingPawns[n].AddEnergy(rechargeFreq);

			}
		}
		if ( sl > 0 && chargingPawns.length == 0 )
		{
			bStationOpen = false;
			CloseStation();
		}
	}
}

simulated event PostNetReceive()
{
	if ( bStationOpen != bCurStationOpen )
	{
		if ( bStationOpen )
		{
			OpenStation();
		}
		else
		{
			CloseStation();
		}
		bCurStationOpen = bStationOpen;
	}
}

defaultproperties
{
     chargeRadius=300.000000
     rechargeFreq=0.100000
     rechargeTime=2.500000
     CollisionRadius=90.000000
     CollisionHeight=30.000000
     Mesh=SkeletalMesh'PariahGameplayDevices.ammo_station'
     DrawType=DT_Mesh
     bNoDelete=True
     bMovable=False
     bCollideActors=True
     bBlockZeroExtentTraces=False
     bUseCylinderCollision=True
     bBlockKarma=True
     bNetNotify=True
}
