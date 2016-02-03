class SPPawnKamikazeDrone extends SPPawnDrone;

var float ExplodeDamage;
var float ExplodeRadius;
var float ExplodeMomentum;

var bool bChasing;

function Explode()
{
	HurtRadius(ExplodeDamage, ExplodeRadius, class'BarrelExplDamage', ExplodeMomentum, Location );

	Super.Explode();
}

event Bump(Actor Other)
{
	if(Other != none && !Other.IsA('DroneArea') && !Other.IsA('SPPawnDrone') ) {
		// bit of a hack... avoids having the drone explode on things like the MostlyDeadPawn
		if(Other.IsA('Pawn') && Pawn(Other).Health > 0) {
			log("!! Exploding due to bumping into Other = "$Other);
			Explode();
		}
	}
}

// I don't think that hiting a wall or the ground should cause it to explode... (unless maybe it's chasing something)
event HitWall(Vector hitnormal, actor wall)
{
	if(bChasing)
		Explode();
}

event Landed(Vector normal)
{
	if(bChasing)
		Explode();
}

defaultproperties
{
     ExplodeDamage=30.000000
     ExplodeRadius=350.000000
     ExplodeMomentum=5000.000000
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ExplodeEmitter=Class'VehicleEffects.GrenadeExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     SightRadius=1000.000000
     AirSpeed=1000.000000
     AccelRate=1500.000000
     FlyingBrakeAmount=10.000000
     race=R_Clan
     bDontReduceSpeed=True
     DrawScale=4.000000
     StaticMesh=StaticMesh'DronesStaticMeshes.KamikazeDrone'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem105
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem105'
     Skins(0)=Shader'DroneTex.Kamikaze.KamikazeShader'
}
