class MiniEdPawnAssaultDrone extends MiniEdDrone;

// vars needed for drone bobbing motion
var bool bBobbing;
var float bobAmplitude;
var float bobFrequency;
var float bobTimer;
var float LastBobZ;

// vars needed to move drone from place to place
var vector MoveDir;
var vector MoveStart;
var float moveDuration;
var float moveCounter;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LastBobZ = Location.Z;
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);
}

function float SetMoveParams(vector Destination)
{
	local vector moveVector;

	MoveStart = Location;
	moveVector = Destination-Location;
	MoveDir = Normal(moveVector);
	moveDuration = VSize(moveVector)/AirSpeed;
	moveCounter = 0;
	bobTimer = 0;

//	FinalRotation = rotator(MoveDir);

	return moveDuration;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local MiniEdAssaultDrone aiDrone;

//	if(EventInstigator.IsA('SPPawn') && SPPawn(EventInstigator).race == race)
		// don't respond to members of own team
//		return;

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	// we've been hit so we should really go into attack mode now
	aiDrone = MiniEdAssaultDrone(Controller);
	if(aiDrone != none && Health > 0) {
		// log("-->  I was attacked by "$EventInstigator);
		aiDrone.AttackTarget = EventInstigator;
		aiDrone.AttackDistance = VSize(EventInstigator.Location-Location)*1.25;
		aiDrone.GotoState('Attacking');
	}
}

defaultproperties
{
     bobAmplitude=35.000000
     bobFrequency=0.750000
     bBobbing=True
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ExplodeEmitter=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     Health=50
     race=R_Guard
     Skins(0)=Texture'MannyTextures.drones.All-Seeing'
}
