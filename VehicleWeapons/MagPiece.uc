class MagPiece extends Actor;

var	()	float	DampenFactor, AttractTime;
var		Array<StaticMesh>	AvailableMeshes;

var		Emitter		Trail;
var	()	class<Emitter>	TrailClass;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetStaticMesh(AvailableMeshes[Rand(2)]);

	AttractTime=0.0;

	Spawn(class'GrenadeMagPuff');

    Trail = Spawn(TrailClass,self);
}

simulated function Tick(float dt)
{
	Super.Tick(dt);
	
	if(Owner == None)
	{
	    Destroy();
	}

    if(vsize(Owner.Location - Location) <= 80)
	{
		SetPhysics(PHYS_Trailer);
		if(Trail != None) 
		{
			Trail.Kill();
        }
    }
	else if(Physics != PHYS_Trailer)
	{
		AttractTime+=dt;
		if (AttractTime >= 1.4)
		{
			AttractTime=1.4;
        }
		Velocity = Normal(Owner.Location - Location) * 3600 * AttractTime ;
		Velocity.Z = Velocity.Z + (1.4-AttractTime)*500;					//Give it a starting velocity straight up!
	}
}

simulated function Destroyed()
{
	if(Trail != None) 
	{
		Trail.Kill();
	}
	Super.Destroyed();
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

defaultproperties
{
     DampenFactor=0.500000
     TrailClass=Class'VehicleEffects.GrenadeMagTrail'
     AvailableMeshes(0)=StaticMesh'PariahWeaponEffectsMeshes.Grenade.MChunkA'
     AvailableMeshes(1)=StaticMesh'PariahWeaponEffectsMeshes.Grenade.MChunkB'
     LifeSpan=15.000000
     DrawScale=0.250000
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_None
     AmbientGlow=120
     bFixedRotationDir=True
}
