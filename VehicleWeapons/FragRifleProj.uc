//=============================================================================
//=============================================================================
class FragRifleProj extends VGProjectile;

var xEmitter		Trail;
var class<xEmitter>	TrailClass;
var class<Actor>	ExplosionClass;
var byte			Bounces;

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

simulated function Landed( Vector HitNormal )
{
	HitWall(HitNormal, none);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	if(Wall != none && !Wall.bStatic)
	{
		Super.HitWall(HitNormal, Wall);
	}
    SetPhysics(PHYS_Falling);
	if (Bounces > 0)
    {
        Velocity = 0.55 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;
        return;
    }
	bBounce = false;
    LifeSpan = 1.0;
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.ParticlePlasmaTrail'
     ExplosionClass=Class'VehicleEffects.xListPlasmaExplosion'
     Bounces=2
     VehicleDamage=15
     PersonDamage=21
     Speed=5500.000000
     MaxSpeed=6000.000000
     DamageRadius=0.000000
     MomentumTransfer=250.000000
     MyDamageType=Class'VehicleWeapons.FragRifleDamage'
     DrawScale=0.100000
     StaticMesh=StaticMesh'BlowoutGeneralMeshes.Effects.Sphere_Misc'
     DrawType=DT_StaticMesh
     bBounce=True
}
