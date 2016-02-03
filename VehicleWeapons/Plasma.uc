//=============================================================================
//=============================================================================
class Plasma extends VGProjectile;

var vector	SizeScale;
var float	SizeFactor;

var xEmitter		Trail;
var class<xEmitter>	TrailClass;
var class<Actor>	ExplosionClass;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SizeFactor = 0;
}

simulated function Destroyed()
{
	if(Trail != none)
		Trail.mRegen = false;
}

simulated function SpawnTrail()
{
	if(TrailClass != none)
		Trail = Spawn(TrailClass, self);
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	if(ExplosionClass != none)
		Spawn(ExplosionClass,,,HitLocation+HitNormal*ExploWallOut,Rotator(HitNormal));
}


simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if(SizeFactor < 1.0)
	{
		SetDrawScale3D(SizeScale * SizeFactor);
		SizeFactor += DeltaTime * 8.0;
	}
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.ParticlePlasmaTrail'
     ExplosionClass=Class'VehicleEffects.xListPlasmaExplosion'
     SizeScale=(X=1.000000,Y=0.300000,Z=0.300000)
     VehicleDamage=6
     PersonDamage=5
     Speed=8000.000000
     MaxSpeed=9000.000000
     MomentumTransfer=7000.000000
     MyDamageType=Class'VehicleWeapons.PlasmaGunDamage'
     StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Plasma.PlasmaFire'
     DrawScale3D=(X=0.000000,Y=0.000000,Z=0.000000)
     RotationRate=(Roll=50000)
     DrawType=DT_StaticMesh
}
