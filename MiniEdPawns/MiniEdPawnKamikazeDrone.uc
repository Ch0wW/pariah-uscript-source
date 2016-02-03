class MiniEdPawnKamikazeDrone extends MiniEdDrone;

var float ExplodeDamage;
var float ExplodeRadius;
var float ExplodeMomentum;

var bool bChasing;

function Explode()
{
	HurtRadius(ExplodeDamage, ExplodeRadius, class'BarrelExplDamage', ExplodeMomentum, Location );

	if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,self,,Location,Rotation);
	if(ExplosionDistortionClass != None)
		spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

	if(Controller != none) {
		Controller.Destroy();
		Controller = none;
	}
//	Destroy();
//	Super.Explode();
}

event Bump(Actor Other)
{
	if(Other != none && !Other.IsA('MiniEdDroneArea') && !Other.IsA('MiniEdDrone') ) {
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
     PeripheralVision=0.707000
     AirSpeed=1000.000000
     AccelRate=1500.000000
     FlyingBrakeAmount=10.000000
     race=R_Clan
     bDontReduceSpeed=True
     StaticMesh=StaticMesh'DronesStaticMeshes.KamikazeDrone'
     Skins(0)=Shader'DroneTex.Kamikaze.KamikazeShader'
}
