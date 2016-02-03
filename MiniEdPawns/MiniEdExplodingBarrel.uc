class MiniEdExplodingBarrel extends Actor
	placeable;

var() sound BarrelImpactSound;
var() int Health;
var() float HurtDamage;
var() float DamageRadius;
var() float HurtMomentum;

struct DestroyEmitterDesc
{
	var() name AttachPoint;
	var() Vector SpawnLocation;
	var() Rotator SpawnRotation;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

var(EventDestroy) Sound DestroySound;
var(EventDestroy) editinline Array<DestroyEmitterDesc> DestroyEmitters;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	Health -= Damage;
	//log( "NewBarrelHealth=" $ Health );

	if(Health < 0)
	{
		Explode(ProjOwner, EventInstigator);
	}
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

defaultproperties
{
     Health=50
     HurtDamage=200.000000
     DamageRadius=300.000000
     HurtMomentum=15000.000000
     DestroySound=Sound'Sounds_Library_manny.Weapon_Sounds.73-long_dynamite_blast4'
     DestroyEmitters(0)=(EmitterClass=Class'VehicleEffects.BridgeShardBurst')
     StaticMesh=StaticMesh'HavokObjectsPrefabs.Barrels.ExplosiveBarrel'
     DrawType=DT_StaticMesh
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
}
