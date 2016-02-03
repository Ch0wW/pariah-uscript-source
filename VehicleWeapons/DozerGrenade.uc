class DozerGrenade extends VGProjectile;

var		Emitter		    Trail;
var		Actor			Corona;
var	()	class<Emitter>	TrailClass;
var	()	class<Actor>	CoronaClass;
var	()	class<Actor>	ExplosionClass;

simulated function PostBeginPlay()
{
	local vector X;

	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		X = Vector(Rotation);
		Velocity = Speed * X + vect(0,0,1) * Speed * 0.05;
	}

	if ( Level.NetMode != NM_DedicatedServer )
    {
    	Trail = Spawn(TrailClass,self);
		//Corona = Spawn(CoronaClass,self);
    }
}

simulated function Destroyed()
{
	if(Trail != none)
	{
		Trail.Destroy();
        Trail = None;
    }
	if(Corona != none)
	{
		Corona.Destroy();
    }
    Super.Destroyed();
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	local vector v;
	local rotator r;

	v = HitLocation+HitNormal*ExploWallOut;
	r = rotator(HitNormal);
	if(ExplosionClass != none)
		spawn(ExplosionClass,,,v,r);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    Super.Explode(HitLocation, HitNormal);
	Destroy();
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
	Explode(Location, HitNormal);
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.GrenadeMagTrail'
     CoronaClass=Class'VehicleEffects.PRocketCoronaEffect'
     ExplosionClass=Class'VehicleEffects.BarrelShardBurst'
     VehicleDamage=301
     PersonDamage=201
     SplashDamage=301.000000
     ExplosionSound=Sound'SM-chapter03sounds.ExplosionWithMetal'
     Speed=40000.000000
     MaxSpeed=50000.000000
     DamageRadius=768.000000
     MomentumTransfer=1280.000000
     MyDamageType=Class'VehicleWeapons.GrenadeLauncherDamage'
     bSwitchToZeroCollision=True
     LifeSpan=30.000000
     DrawScale=1.100000
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     StaticMesh=StaticMesh'PariahVehicleEffectsMeshes.DozerLauncher.DozerBall'
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     bOrientOnSlope=True
     bProjTarget=True
}
