class MagFrag extends VGProjectile;

var		Array<StaticMesh>	AvailableMeshes;

var		xEmitter		Trail;
var	()	class<xEmitter>	TrailClass;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
	SetStaticMesh(AvailableMeshes[Rand(2)]);

    if ( Level.NetMode != NM_DedicatedServer )
    {
		Trail = Spawn(TrailClass, self);
    }

    Velocity = Vector(Rotation) * 3500;
    SetRotation(RotRand());
}

simulated function Destroyed()
{
	if(Trail != None) 
	{
		Trail.mRegen = false;
		Trail = none;
	}
	Super.Destroyed();
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.FlakBall'
     AvailableMeshes(0)=StaticMesh'PariahWeaponEffectsMeshes.Grenade.MChunkA'
     AvailableMeshes(1)=StaticMesh'PariahWeaponEffectsMeshes.Grenade.MChunkB'
     VehicleDamage=60
     PersonDamage=40
     LifeSpan=4.000000
     DrawScale=0.250000
     DrawType=DT_StaticMesh
     AmbientGlow=120
     bBounce=True
}
