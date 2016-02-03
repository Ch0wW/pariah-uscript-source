//=============================================================================
//=============================================================================
class DartPlasma extends VGProjectile;

var xEmitter		Trail;
var ()	class<xEmitter>	TrailClass;
var ()	class<Actor>	ExplosionClass;

// parameters for charging
var () float MaxVehicleDamage;
var () float MaxPersonDamage;
var () float MaxSplashDamage;
var () float MaxDamageRadius;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	bHidden = false;
}

simulated function SpawnTrail()
{
	if(Trail == None && TrailClass != none)
    {
		Trail = Spawn(TrailClass, self);
	}
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	if(ExplosionClass != none)
		Spawn(ExplosionClass,,,HitLocation+HitNormal*ExploWallOut,Rotator(HitNormal));

	if(Trail != None)
    {
		Trail.mRegen = false;
		Trail = None;
	}
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	if(Wall.bStatic && (Level.NetMode != NM_DedicatedServer))
	{
		Spawn(class'VehicleEffects.PulseImpactScorch',,,Location+HitNormal*ExploWallOut,Rotator(HitNormal));
	}

	Super.HitWall(HitNormal, Wall);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other != Instigator)
	{
		Super.ProcessTouch(Other, HitLocation);
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Super.Explode(HitLocation, HitNormal);
}

simulated function Destroyed()
{
    Super.Destroyed();
    if(Trail != None)
    {
		Trail.mRegen = false;
		Trail = None;
	}
}

function SetParams(int VehicleDmg, int PersonDmg, float SplashDmg, float DmgRadius, int MaxVehicleDmg, int MaxPersonDmg, float MaxSplashDmg, float MaxDmgRadius, float momentum)
{
	VehicleDamage = VehicleDmg;
	PersonDamage = PersonDmg;
	SplashDamage = SplashDmg;
	DamageRadius = DmgRadius;

	MaxVehicleDamage = MaxVehicleDmg;
	MaxPersonDamage = MaxPersonDmg;
	MaxSplashDamage = MaxSplashDmg;
	MaxDamageRadius = MaxDmgRadius;

	MomentumTransfer = momentum;
}

defaultproperties
{
     MaxVehicleDamage=50.000000
     MaxPersonDamage=40.000000
     MaxSplashDamage=30.000000
     MaxDamageRadius=400.000000
     TrailClass=Class'VehicleEffects.DartGunPlasmaTrail'
     ExplosionClass=Class'VehicleEffects.xListPlasmaExplosion'
     VehicleDamage=16
     PersonDamage=8
     SplashDamage=8.000000
     ExplosionSound=SoundGroup'NewBulletImpactSounds.Final.sand'
     HitEffectClass=Class'VehicleWeapons.PlasmaHitEffects'
     Speed=8500.000000
     MaxSpeed=10000.000000
     DamageRadius=240.000000
     MomentumTransfer=1000.000000
     ExploWallOut=0.000000
     MyDamageType=Class'VehicleWeapons.PlasmaGunDamage'
     LifeSpan=2.000000
     SoundRadius=50.000000
     DrawScale3D=(X=1.500000)
     RotationRate=(Roll=50000)
     SoundVolume=255
     bReplicateInstigator=False
}
