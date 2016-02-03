class GeneratorShieldMesh extends StaticMeshActor;

var GeneratorShieldMeshInside InnerMesh;

var bool shielddisabled;

function PostBeginPlay()
{
	InnerMesh = Spawn(class'GeneratorShieldMeshInside',,,Location,Rotation);
}


function TurnOff()
{
	bHidden = true;
	InnerMesh.bHidden = true;
	SetCollision(false, false, false);
}

function TurnOn()
{
	if(shielddisabled) return;
	bHidden = false;
	InnerMesh.bHidden = false;
	SetCollision(true, true, true);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{


	Super.TakeDamage(damage, eventinstigator, hitlocation, momentum, damagetype, projowner, bsplashdamage);
}

defaultproperties
{
     StaticMesh=StaticMesh'StocktonBossPrefabs.BossShield.GeneratorShield'
     bStatic=False
     bProjTarget=True
}
