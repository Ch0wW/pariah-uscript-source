class FragRifleEmberShard extends VGProjectile;

var float decelTime;
var float decelTimer;

var Vector InitialVelocity;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	InitialVelocity = Velocity;
}

simulated function Tick(float dt)
{
	local float u;

	Super.Tick(dt);

	decelTimer += dt;
	if(decelTimer >= decelTime)
		Velocity = vect(0, 0, 0);
	else {
		u = decelTimer/decelTime;

		Velocity = (1.0-u)*InitialVelocity;
	}
}

defaultproperties
{
     decelTime=0.350000
     VehicleDamage=25
     PersonDamage=25
     Speed=10000.000000
     MaxSpeed=10000.000000
     MomentumTransfer=600.000000
     MyDamageType=Class'VehicleWeapons.FragRifleEmberDamage'
     DrawScale=0.050000
     StaticMesh=StaticMesh'BlowoutGeneralMeshes.Effects.ShockwaveRingMesh'
     DrawType=DT_StaticMesh
}
