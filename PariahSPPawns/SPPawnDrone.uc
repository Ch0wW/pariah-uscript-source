class SPPawnDrone extends SPPawn
	native;

var bool bDebugInfo;

var class<Emitter> ExplodeEmitter, ExplosionDistortionClass;
var Sound ExplodeSound;
var bool bExplodeOnDeath;

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);

	Controller.bAdvancedTactics = false;
}

function TossWeapon(Vector TossVel)
{
	// sjs - don't do this for these type of objects
}

function DropHealth(Controller Killer)
{
	// sjs - don't do this for these type of objects
}

function Tick(float dt)
{
	Super.Tick(dt);

	if(bDebugInfo)
		DrawDebugLine( Location, Location + Vector(Rotation) * 50, 255,0,0 );

	if(Health <= 0 && bExplodeOnDeath)
		Explode();
}


simulated function SomeBlood( Vector Loc, Rotator BoneRot )
{
}

function Explode()
{
	if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,self,,Location,Rotation);
	if(ExplosionDistortionClass != None)
		spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

	if(Controller != none)
		Controller.Destroy();
	Destroy();
}

simulated function PlayDyingSound()
{
    // mjm - do nothing - override to not to play the default male death sound
}

defaultproperties
{
     bExplodeOnDeath=True
     InstantHitSound=SoundGroup'NewBulletImpactSounds.Final.MetalImpact'
     GibGroupClass=Class'VehicleGame.SPDroneGibGroup'
     Bleed=False
     bRagdollCorpses=False
     Health=75
     AirSpeed=500.000000
     AccelRate=2000.000000
     ControllerClass=Class'PariahSPPawns.SPAIDrone'
     race=R_Guard
     bCanFly=True
     bInvulnerableBody=True
     DrawScale=3.000000
     CollisionRadius=48.000000
     CollisionHeight=48.000000
     Mass=80.000000
     Buoyancy=80.000000
     StaticMesh=StaticMesh'MannyPrefabs.drones.all_seeing'
     AmbientSound=Sound'KeepersAndDrones.drone.DroneAmbience'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem103
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem103'
     Skins(0)=Texture'MannyTextures.drones.All-Seeing'
     DrawType=DT_StaticMesh
}
