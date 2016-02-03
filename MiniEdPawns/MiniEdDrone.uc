class MiniEdDrone extends Pawn;

var class<Emitter> ExplodeEmitter, ExplosionDistortionClass;
var Sound ExplodeSound;
var bool bExplodeOnDeath;

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);
	
//	Controller.bAdvancedTactics = false;
}


//function Tick(float dt)
//{
//	Super.Tick(dt);

//	if(Health <= 0 && bExplodeOnDeath)
//		Explode();
//}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	if(Health <= 0 && bExplodeOnDeath)
		Explode();
}

simulated function Destroyed()
{
	Super.Destroyed();
	log("MINI ED DRONE DESTROYED!");
}

simulated function SomeBlood( Vector Loc, Rotator BoneRot )
{
}

function Explode()
{
	if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,self,,Location,Rotation);
	if(ExplosionDistortionClass != None)
		spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

	if(Controller != none)
		Controller.Destroy();
//	Destroy();
}

defaultproperties
{
     bExplodeOnDeath=True
     Health=75
     AirSpeed=500.000000
     AccelRate=2000.000000
     race=R_Shroud
     bCanFly=True
     bCanStrafe=True
     DrawScale=2.000000
     CollisionRadius=48.000000
     CollisionHeight=48.000000
     Mass=80.000000
     Buoyancy=80.000000
     StaticMesh=StaticMesh'MannyPrefabs.drones.all_seeing'
     Skins(0)=Texture'MannyTextures.drones.All-Seeing'
     DrawType=DT_StaticMesh
}
