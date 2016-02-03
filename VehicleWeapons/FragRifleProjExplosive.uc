//=============================================================================
//=============================================================================
class FragRifleProjExplosive extends VGProjectile;

var xEmitter		Trail;
var class<xEmitter>	TrailClass;
var class<Actor>	ExplosionClass;

// FragRifleProjHot effect added here
var	float			BurnDamage;
var	float			BurnTime;

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	Super.ProcessTouch(Other, HitLocation);

	if ( Other!=Instigator && Other != none && Instigator != none/*&& !Other.IsA('Projectile') */)
	{
		if(Other.IsA('VGPawn'))
		{
			VGPawn(Other).Poison(Instigator, BurnDamage, BurnTime);
		}
	}
}
//////////////////////////////////

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

defaultproperties
{
     BurnDamage=3.000000
     BurnTime=5.000000
     TrailClass=Class'VehicleEffects.ParticlePlasmaTrail'
     ExplosionClass=Class'VehicleEffects.xListPlasmaExplosion'
     VehicleDamage=15
     PersonDamage=21
     SplashDamage=10.000000
     Speed=5500.000000
     MaxSpeed=6000.000000
     DamageRadius=50.000000
     MomentumTransfer=100.000000
     MyDamageType=Class'VehicleWeapons.FragRifleDamage'
     DrawScale=0.100000
     StaticMesh=StaticMesh'BlowoutGeneralMeshes.Effects.Sphere_Misc'
     DrawType=DT_StaticMesh
}
