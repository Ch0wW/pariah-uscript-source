class SPPawnAssaultDrone extends SPPawnDrone
	native;

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


var Emitter				Trail;
var	() class<Emitter>	TrailClass;

// vars needed to handle rotation... and all I wanted to do was to make the thing bob up and down
//var rotator FinalRotation;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LastBobZ = Location.Z;

	if(TrailClass != none)
	{
		Trail = Spawn(TrailClass,self);
		Trail.SetBase(self);
	}
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
	local SPAIAssaultDrone aiDrone;

	if(EventInstigator != None && EventInstigator.IsA('SPPawn') && SPPawn(EventInstigator).race == race)
		// don't respond to members of own team
		return;

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	// we've been hit so we should really go into attack mode now
	
	if(EventInstigator != None)
	{
	aiDrone = SPAIAssaultDrone(Controller);
	if(aiDrone != none && Health > 0) {
		// log("-->  I was attacked by "$EventInstigator);
		aiDrone.AttackTarget = EventInstigator;
		aiDrone.AttackDistance = VSize(EventInstigator.Location-Location)*1.25;
		aiDrone.GotoState('Attacking');
	}
	}
}
simulated function Destroyed()
{
    Super.Destroyed();

	if(Trail != none)
	{
		Trail.Destroy();
	}
}

defaultproperties
{
     bobAmplitude=35.000000
     bobFrequency=0.750000
     TrailClass=Class'VehicleEffects.DroneTrail'
     bBobbing=True
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ExplodeEmitter=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     Health=100
     SightRadius=1000.000000
     AirSpeed=1000.000000
     AccelRate=1500.000000
     FlyingBrakeAmount=10.000000
     bDontReduceSpeed=True
     DrawScale=2.500000
     StaticMesh=StaticMesh'DronesStaticMeshes.AssaultDrone'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem104
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem104'
     Skins(0)=Shader'DroneTex.AssaultDrone.AssaultDrone_Shader'
     Rotation=(Yaw=-16384)
}
