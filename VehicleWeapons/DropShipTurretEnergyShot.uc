/*
	Desc: Energy shot emitted during the dual firing mode of the dropship turret
	xmatt
*/
class DropShipTurretEnergyShot extends VGProjectile;

var() class<Emitter> ParticleClass;
var Emitter Particles;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Particles = Spawn( ParticleClass, , , , );
	Particles.SetBase( Self );
}

simulated function Destroyed()
{
	if( Particles != none )
	{
		Particles.Kill();
		Particles = none;
	}
}

/*
	Note: I had to override it because VGProjectile checks for the instigator, which is a pawn,
		  however, the turret is an actor. Does that mean that only pawns can shoot projectiles?
		  If so, that's shitty (xmatt)
*/
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local vector dir;

	if ( Other != none && Other != Owner )
	{
		dir = Vector(Rotation);
		if (Other.IsA('VGVehicle'))
		{
			Other.TakeDamage( VehicleDamage, instigator, HitLocation,vect(0,0,0), MyDamageType);
			Other.TakeDamage( VehicleDamage, instigator, HitLocation, MomentumTransfer*dir, MyDamageType);
		}
		else if(Other.IsA('Projectile'))
		{
			return;
		}
		else
		{
			Other.TakeDamage( PersonDamage, instigator, HitLocation, MomentumTransfer*dir, MyDamageType);
		}
	}
}

defaultproperties
{
     ParticleClass=Class'VehicleEffects.DropshipTurretSlowShot'
     VehicleDamage=16
     PersonDamage=4
     Speed=1800.000000
     MaxSpeed=1800.000000
     DamageRadius=50.000000
     MyDamageType=Class'VehicleWeapons.PlasmaGunDamage'
     SoundRadius=50.000000
     SoundVolume=255
}
