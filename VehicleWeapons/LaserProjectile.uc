//=============================================================================
//=============================================================================
class LaserProjectile extends Projectile;

#exec LOAD FILE="WeaponSounds.uax"

//
// This is the tracer for chapter 3 that hits the pain tower and emits sparks.
//

var int HitDamage;


simulated function PostBeginPlay()
{
	local vector Dir;

	Super.PostBeginPlay();

	Dir = vector(Rotation);
	Velocity = Speed * Dir;
}


simulated singular function Touch(Actor Other)
{

	if (Other.bBlockActors && Other.bBlockPlayers)
	{
		Other.TakeDamage(HitDamage,instigator,Location,vect(0,0,0),MyDamageType);

		Spawn(class'C12GenSpark',,,Location);
		PlaySoundEffect();
		Destroy();
	}
}


simulated function BlowUp(vector HitLocation)
{
	Spawn(class'C12GenSpark',,,HitLocation);
	PlaySoundEffect();
	Destroy();
}

simulated function HitWall (vector HitNormal, actor Wall)
{

	Spawn(class'C12GenSpark',,,Location);
	PlaySoundEffect();
	Destroy();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{

	Spawn(class'C12GenSpark',,,HitLocation);
	PlaySoundEffect();
	Destroy();
}


simulated function PlaySoundEffect()
{

	if ( FRand()<0.5 ) 
		PlaySound(sound'WeaponSounds.Misc.Explosion1',,1.0,,,,, false);
	else 
		PlaySound(sound'WeaponSounds.Misc.Explosion3',,1.0,,,,, false);
	
}

defaultproperties
{
     HitDamage=15
     Speed=12000.000000
     MaxSpeed=12000.000000
     MyDamageType=Class'VehicleWeapons.PlasmaGunDamage'
     LifeSpan=2.000000
     DrawScale=2.200000
     StaticMesh=StaticMesh'JS_Forest.TracerPlanes'
     DrawType=DT_StaticMesh
}
