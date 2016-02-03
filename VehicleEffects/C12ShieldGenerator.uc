class C12ShieldGenerator extends Effects
	placeable;

// If rocket hits volume, send message to ShieldGenerator to activate.
//
// If ShieldGenerator Destroyed by AssaultRifle or SniperRifle, destroy self and volume.
//
//

var () name GenDieEvent;
var() sound ExplosionSound;
var	() class<Actor>		ExplosionClass;
var	() class<Actor>		SparkClass;
var	() class<Actor>		ExplosionDistortionClass;
var () int Health;
var bool bdead;
var() Sound ShieldSound;

// Triggered from C12Rocket entering physics volume in Chapter12 
// So, spawn the shield and kill the rocket.
//
function Trigger(actor Other, pawn EventInstigator)
{
	local actor Act;
	local rotator r;

	if (Health>0)
	{
		Other.Timer();   //Time Rocket out to explode it.
		spawn(class'VehicleEffects.DistortionShieldDecay',,,Location,r);
		spawn(class'VehicleEffects.DistortionShieldA',,,Location,r);
		spawn(class'VehicleEffects.DistortionShieldB',,,Location,r);
		PlaySound(ShieldSound, SLOT_Misc, 1.5,,1500,,true);

	}
	else  //If health <0 destroy Turret and stop dropship from firing anymore.
	{

		foreach RadiusActors(class'Actor',Act, 19000)
		{
			if (Act.Tag == 'GeneratorDead') 
			{
				Act.Trigger(self, none);
			}
		}

	}
}

simulated function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{

	Health -= Damage;
	if(Health <= 0 && !bDead)
	{
		bDead=True;
		bHidden=True;
		Spawn(ExplosionClass);
	}
	else
	{
		Spawn(SparkClass);
	}
}

defaultproperties
{
     Health=50
     ShieldSound=Sound'PariahDropShipSounds.Millitary.DropshipShieldImpactA'
     GenDieEvent="'"
     ExplosionClass=Class'VehicleEffects.C12GenExpl'
     SparkClass=Class'VehicleEffects.C12GenSpark'
     CollisionRadius=50.000000
     CollisionHeight=100.000000
     Tag="RocketHitShield"
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
}
