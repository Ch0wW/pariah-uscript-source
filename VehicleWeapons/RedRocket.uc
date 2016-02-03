class RedRocket extends VGProjectile;

var		xEmitter		Trail;
var		Actor			Corona;
var	()	class<xEmitter>	TrailClass;
var	()	class<Actor>	CoronaClass;
var	()	class<Actor>	ExplosionClass;
var	()	class<Actor>	ExplosionDistortionClass;
var     bool            bExploded;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if(Level.NetMode != NM_DedicatedServer)
        SpawnRocketTrail();
    if(Level.Game != None && Level.Game.bSinglePlayer == true)
    {
        SplashDamage = 100;
        SetCollisionSize(12, 8);
    }
    if(Corona != None)
    {
        Corona.bTrailerPrePivot = true;
        Corona.PrePivot = vect(-40,0,0);
    }
}

simulated function Destroyed()
{
    if(!bExploded)
    {
	    if(Level.NetMode != NM_DedicatedServer)
		    SpawnExplosion(Location, Vect(0,0,1));
	    if(ExplosionSound != none)
		    PlaySound(ExplosionSound,,0.8);
    }

	if(Trail != None) 
	{
		Trail.Kill();
		Trail = none;
	}
	if(Corona != none)
	{
		Corona.Destroy();
    }
	Super.Destroyed();
}

simulated function SpawnRocketTrail()
{
    if(TrailClass != none && Trail == none) 
    {
	    Trail = Spawn(TrailClass,self);
	}
	if(CoronaClass != none )
	{
		Corona = Spawn(CoronaClass,self);
    }
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	local vector v;
	local rotator r;

	v = HitLocation+HitNormal*ExploWallOut;
	r = rotator(HitNormal);
	if(ExplosionClass != none)
		spawn(ExplosionClass,,,v,r);
	if(ExplosionDistortionClass != none)
		spawn(ExplosionDistortionClass,,,v,r);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(Trail != None) 
	{
		Trail.mRegen = false;
		Trail = none;
	}
	if(Corona != none)
		Corona.Destroy();

    Super.Explode(HitLocation, HitNormal);

    bExploded = true;

	Destroy();
}

function SetParams(int VehicleDmg, int PersonDmg, float SplashDmg, float DmgRadius, float Momentum)
{
	VehicleDamage = VehicleDmg;
	PersonDamage = PersonDmg;
	SplashDamage = SplashDmg;
	DamageRadius = DmgRadius;
	MomentumTransfer = Momentum;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
	if(Role == ROLE_Authority && Damage > 10) 
	{
		Blowup(HitLocation);
		Explode(HitLocation, vect(0, 0, 1) );
    }
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.VGRocketTrail'
     CoronaClass=Class'VehicleEffects.PRocketCoronaEffect'
     ExplosionClass=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     VehicleDamage=150
     PersonDamage=40
     SplashDamage=80.000000
     ExplosionSound=Sound'PariahWeaponSounds.hit.Rocket_Explosion'
     Speed=2200.000000
     MaxSpeed=2800.000000
     DamageRadius=300.000000
     MomentumTransfer=4000.000000
     MyDamageType=Class'VehicleWeapons.VGRocketLauncherDamage'
     ExplosionDecal=Class'VehicleEffects.ExplosionMark'
     bSwitchToZeroCollision=True
     LifeSpan=0.000000
     DrawScale=2.500000
     CollisionRadius=25.000000
     CollisionHeight=15.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Projectiles.missile_power'
     AmbientSound=Sound'PariahWeaponSounds.rocket_fly_lp'
     PrePivot=(X=20.000000)
     DrawType=DT_StaticMesh
     AmbientGlow=96
     SoundVolume=255
     bNetTemporary=False
     bAlwaysRelevant=True
     bUpdateSimulatedPosition=True
     bProjTarget=True
}
