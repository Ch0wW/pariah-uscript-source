class HavokBarrel extends HavokActor
	placeable;

var() sound BarrelImpactSound;
var() int Health;
var() float HurtDamage;
var() float DamageRadius;
var() float HurtMomentum;
var() bool	bBlowsUp;

struct DestroyEmitterDesc
{
	var() name AttachPoint;
	var() Vector SpawnLocation;
	var() Rotator SpawnRotation;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

var(EventDestroy) name DestroyEvent;
var(EventDestroy) Sound DestroySound;
var(EventDestroy) editinline Array<DestroyEmitterDesc> DestroyEmitters;

simulated event HImpact(actor other, vector pos, vector ImpactVel, vector ImpactNorm, Material HitMaterial)
{
	local float ILoud;

	ILoud = VSize(ImpactVel) / 700.0;

	Playsound(BarrelImpactSound,,ILoud);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	if( !bBlowsUp)
		return;

	Health -= Damage;
	//log( "NewBarrelHealth=" $ Health );

	if(Health < 0)
	{
		Explode(ProjOwner, EventInstigator);
	}

	Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
}

function Explode(Controller ProjOwner, Pawn EventInstigator)
{
	HurtRadius(HurtDamage, DamageRadius, class'BarrelExplDamage', HurtMomentum, Location, ProjOwner );
	Boom(EventInstigator);
	Destroy();
}

function Boom(Pawn instigator)
{
	local int i;
	local Vector v;
	local Rotator r; 

	if(DestroySound != None)
	{
		PlaySound(DestroySound,,2.0);
		PlaySound(DestroySound,,2.0);
	}
	if(DestroyEvent != '')
	{
		TriggerEvent(DestroyEvent, self, instigator);
	}

	for(i = 0; i< DestroyEmitters.Length; i++)
	{
		if(DestroyEmitters[i].AttachPoint == '' || !GetAttachPoint(DestroyEmitters[i].Attachpoint, v, r))
		{
			v = DestroyEmitters[i].SpawnLocation;
			r = DestroyEmitters[i].SpawnRotation;
		}

		if(DestroyEmitters[i].EmitterClass != None)
		{
			spawn(DestroyEmitters[i].EmitterClass,,, Location+v);
			//Location+v)>>Rotation, Rotation + r);
		}

		if(DestroyEmitters[i].xEmitterClass != None)
		{
			spawn(DestroyEmitters[i].xEmitterClass,,,Location+v);
		}
	}
}


//event Bump(Actor Other)
//{
//	local Vector vDiff, vNudge;
//	local float side, end;
//	local rotator fudge;
//
//	fudge.yaw = 65535 / 4;
//
//	if(ROLE == ROLE_Authority)
//	{
//		if(Other.IsA('VGPawn'))
//		{
//			vDiff = Normal(Other.Location - Location);
//
//			log("Going to add my velocity ( "$Velocity$" ) to other "$Other.Location);
//
//			Other.SetLocation(Other.Location + Velocity*0.016);
//		}
//	}
//}

defaultproperties
{
     Health=60
     HurtDamage=200.000000
     DamageRadius=300.000000
     HurtMomentum=15000.000000
     DestroySound=Sound'SM-chapter03sounds.ExplosionWithMetal'
     DestroyEmitters(0)=(EmitterClass=Class'VehicleEffects.BarrelShardBurst')
     bBlowsUp=True
     bCanCrushPawns=True
     DrawScale=0.700000
     StaticMesh=StaticMesh'JamesPrefabs.ShockInterior.AIBarrel'
     Begin Object Class=HavokParams Name=HavokBarrelHParams
         Mass=33.000000
         LinearDamping=1.000000
         AngularDamping=5.000000
         GravScale=1.200000
         Friction=1.500000
         ImpactThreshold=1200.000000
     End Object
     HParams=HavokParams'VehicleEffects.HavokBarrelHParams'
     bNoDelete=False
}
