//=============================================================================
//=============================================================================
class Tracer extends VGProjectile;

var xEmitter		Trail;
var class<xEmitter>	TrailClass;

var	bool			bDestroyed;

simulated function Destroyed()
{
	bDestroyed = true;
	if(Trail != none)
		Trail.mRegen = false;
}

simulated function SpawnTrail()
{
    if (Instigator != None && Instigator.Weapon != None)
    {
		if(Instigator.Weapon.IsA('PlayerTurretDummyWeapon') ) {
			// do nothing 'cause the turret handles it's own stuff
		}
		else if(Instigator.IsFirstPerson() && !Instigator.IsA('VGVehicle'))
		{
			SetLocation(Instigator.Weapon.GetEffectStart());
		}
    }
	if(TrailClass != none && Trail == none && !bDestroyed)
	{
		Trail = Spawn(TrailClass, self);
	}
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.ParticleTracer'
     Speed=10000.000000
     MaxSpeed=10000.000000
     MyDamageType=Class'VehicleGame.TracerDamage'
     LifeSpan=4.000000
     DrawType=DT_None
}
