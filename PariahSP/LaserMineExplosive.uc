class LaserMineExplosive extends HavokActor
	placeable;

var float ExplodeDamage;
var float ExplodeRadius;
var float ExplodeMomentum;
var Sound ExplodeSound, ArmingSound, DisarmingSound;
var class<Emitter> ExplodeEmitter, ExplosionDistortionClass;


function Explode()
{
	HurtRadius(ExplodeDamage, ExplodeRadius, class'BarrelExplDamage', ExplodeMomentum, Location );

	spawn(ExplodeEmitter,self,,Location,Rotation);
	spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

	Destroy();
}

defaultproperties
{
     ExplodeDamage=200.000000
     ExplodeRadius=768.000000
     ExplodeMomentum=1024.000000
     ExplodeSound=Sound'PariahGameSounds.Mines.LaserMineExplode'
     ExplodeEmitter=Class'VehicleEffects.GrenadeExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     StaticMesh=StaticMesh'PariahGametypeMeshes.neutral.tripmine_bomb'
     Begin Object Class=HavokParams Name=LaserMineExplosiveHParams
         Mass=10.000000
         LinearDamping=1.000000
         AngularDamping=1.000000
         GravScale=1.500000
         ImpactThreshold=4000.000000
     End Object
     HParams=HavokParams'PariahSP.LaserMineExplosiveHParams'
     bNoDelete=False
}
