class DropShipChunks extends Projectile;

var Emitter				Trail;
var	() class<Emitter>	TrailClass;
var	() class<Actor>		ExplosionClass;
var	() class<Actor>		ExplosionDistortionClass;
var	() class<Actor>		ExplosionBurstClass;
var() sound ExplosionSound;
var() vector EDir,ELoc;

simulated function Destroyed()
{

	if(Trail != none)
		Trail.Kill();
	Trail = none;


    Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;
	local float ETime;

	Super.PostBeginPlay();

	Dir = Normal(EDir);
	Velocity = Owner.Velocity + Speed * Dir;
	Acceleration = Vect(0,0,0);

	ETime = FRand()*1.5+1.5;
	SetTimer(ETime, False);

	RandSpin(Speed*60.0);

//	SpawnTrail();
}




simulated function SpawnTrail()
{
	if(TrailClass != none)
	{
		Trail = Spawn(TrailClass, self,,Location + (vect(8,1,4) >> Rotation), Rotation);
		Trail.SetBase(self);
	}	
}


simulated function Timer()
{
	SpawnExplosion(Vect(0,0,1), Vect(0,0,1));
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{

	if(ExplosionBurstClass != None )
		spawn(ExplosionBurstClass);

	bHidden=True;
	Destroy();
}

defaultproperties
{
     ExplosionSound=Sound'PariahWeaponSounds.expl_grenade'
     TrailClass=Class'VehicleEffects.ShipDamageSmoke'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     ExplosionBurstClass=Class'VehicleEffects.ShipChunkExplosion'
     EDir=(Y=1.000000)
     ELoc=(Y=72.000000,Z=9.000000)
     Speed=200.000000
     MaxSpeed=3000.000000
     LifeSpan=10.000000
     StaticMesh=StaticMesh'JS_ForestPrefabs.BrokenShip.DSMain'
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     bCollideActors=False
     bCollideWorld=False
     bBounce=True
     bFixedRotationDir=True
}
