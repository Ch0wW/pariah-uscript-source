class BogieLauncherFire extends VGProjectileFire;

var	()	float	HeatPerShot;	// heat per shot at minimum charge
var ()  float   MaxHeatPerShot;	// heat per shot at maximum charge

const maxRockets = 6;			// maximum number of rockets to be loaded
var int numRocketsLoaded;		// number of rockets loaded thus far
var int loadCount;				// keep track of animation
var () float loadFreq;			// frequency with which rockets are loaded
var float loadTimer;
var () float SeekRange;

// this is how much havok impulse is applied to the vehicle per rocket fired
//
const havokImpulseStrengthPerRocket = 10000;

var rotator	FiringRotation[maxRockets];
var vector	FiringOffset[maxRockets];
var int		FireOrder[maxRockets];
var int		numToFire;

simulated function bool AllowFire()
{
		return (Instigator != none && Instigator.Health > 0);
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();
	for(i = 0; i < maxRockets; i++)
	{
		FireOrder[i] = i;
	}
}

function InitEffects()
{
		Super.InitEffects();
}

function RandomizeFiring()
{
	local int i, j, k, temp;
	for(i=0;i<maxRockets;i++)
	{
		j=Rand(maxRockets);
		k=Rand(maxRockets);
		temp=FireOrder[j];
		FireOrder[j]=FireOrder[k];
		FireOrder[k]=temp;
	}
}

function ModeDoFire()
{
	Load = numRocketsLoaded;
	if(Load < 0)
		Load = 0;

	AmmoPerFire = Load;//numRocketsLoaded;
	numToFire = Load;

//	log("BLF:  load = "$Load);
//	log("BLF:  Role = "$Role);

	if(Load > 0) {
		Load = 0;
		numRocketsLoaded = 0;
		loadTimer = 0;//loadFreq;
		loadCount = 0;
	}

	if(Weapon.ThirdPersonActor != none)
		Weapon.ThirdPersonActor.StopAnimating();

	Super.ModeDoFire();
}

function Tick(float dt)
{
	loadTimer += dt;
	if(loadTimer >= loadFreq && numRocketsLoaded < maxRockets) {

		loadTimer -= loadFreq;
		loadCount++;

		// play a loading animation
		if(Weapon.ThirdPersonActor != none) {
			if(loadCount == 1 || loadCount == 3 || loadCount == 5)
			{
				Weapon.ThirdPersonActor.PlayAnim('Reload02', 1);
				numRocketsLoaded++;
			}
			else if(loadCount <= maxRockets)
			{
				Weapon.ThirdPersonActor.PlayAnim('Reload01', 1);
				numRocketsLoaded++;
			}
		}
	}

	Super.Tick(dt);
}

simulated function bool CanLockOnTo(Actor Other)
{
		local Pawn P;

	P = Pawn(Other);

		if (P == None || P == Instigator || !P.bProjTarget)
		// can't lock on if target is self or it's not a valid projectile target
				return false;

		if (!Level.Game.bTeamGame && !P.Controller.SameTeamAs(Instigator.Controller) )
		// not a team game and not a friendly bot so we can lock on
				return true;

	// don't lock onto team mates
		return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
}

function DoFireEffect()
{
	local Vector StartProj, StartTrace, X;
	local Vector HitLocation, HitNormal, SeekingDir;
	local Actor Other;
	local int p, n, SpawnCount;
	local vector vect;
	local rotator rot;
	local BogieRocket rocket;
	local array<Actor> seekTargets;
	local Actor target, Seeking;
	local bool bTargetted;
	local float closestDist, dist;
	local BogieLauncher launcher;

//    if(Weapon.Role < ROLE_Authority)
//        return;

	launcher = BogieLauncher(Weapon);

	Instigator.MakeNoise(1.0);

	vect = VGWeaponAttachment(Weapon.ThirdPersonActor).GetMuzzleLocation();

	rot = launcher.GetAimRot(VehiclePlayer(Instigator.Controller));

	// one last check to make sure we're not likely to shoot ourselves...
	if(Rot.Pitch < -6000)
		Rot.Pitch = -6000;

	StartTrace = vect;
	SpawnCount = numToFire;//Load;//Max(0, ProjPerFire * int(Load));

	// find initial target to seek
	Seeking = Instigator.Controller.PickTarget(closestDist, dist, Vector(rot), StartTrace, SeekRange);

	if(Seeking == none) {
		Seeking = Trace(HitLocation, HitNormal, StartTrace+vector(rot)*SeekRange, StartTrace, true);
		if(Seeking != none && !Seeking.IsA('VGVehicle') )
			Seeking = none;
	}

	if(!CanLockOnTo(Seeking) )
		Seeking = none;


	// check for other targets to seek
	if(Seeking != none)
    {
		for(p = 1; p < SpawnCount; p++)
        {
			closestDist = 1000000;

			foreach VisibleCollidingActors(class'Actor', target, seekRange, Seeking.Location)
            {
				if( (!target.IsA('VGVehicle') && !target.IsA('VGPawn') ) || target == Instigator || !CanLockOnTo(target) || target == self)
					// skip actors that are neither vehicles nor pawns or the instigator or not lockable
					continue;

				bTargetted = false;
				for(n = 0; n < seekTargets.length; n++) {
					if(target == seekTargets[n]) {
						bTargetted = true;
						break;
					}
				}

				if(bTargetted)
					// skip actors that have already been targetted
					continue;

				// of the potential targets we haven't ruled out, find the closest one
				SeekingDir = Normal(target.Location-Location);

				// skip targets that are behind us
				if( (SeekingDir Dot Normal(Velocity) ) > 0.05) {
					// go after the closest target in range
					dist = VSize(SeekingDir);
					if(dist < closestDist) {
						// check to make sure nothing is blocking the target
						if(Trace(HitLocation, HitNormal, target.Location, StartProj, true) == target) {
							closestDist = dist;
							seekTargets[p] = target;
						}
					} // test closest
				} // test direction
			} // foreach
		}
	}

	if(Instigator.IsLocallyControlled() )
    {
		for (p = 0; p < SpawnCount; p++)
		{
			StartProj = (FiringOffset[p] >> rot) + vect;//Weapon.GetFireStart(X,Y,Z);

			// check if projectile would spawn through a wall and adjust start location accordingly
			Other = Trace(HitLocation, HitNormal, StartProj+vector(rot)*2000, StartProj-vector(rot)*50, false);
			//			if(Other != None)
			if(Other == Weapon.ThirdPersonActor.Base)
				StartProj = HitLocation+vector(rot)*50;

			rocket = BogieRocket(launcher.SpawnRocket(StartProj, rot.yaw, rot.pitch) );

			if(rocket != none)
            {
				// select a target for the rocket to seek
				if(p >= seekTargets.Length)
					rocket.Seeking = Seeking;
				else
					rocket.Seeking = seekTargets[p];

				// inherit vehicle's velocity
				//			log("- vel = "$rocket.Velocity$", after = "$(rocket.Velocity+Weapon.ThirdPersonActor.Base.Velocity) );
				X = Weapon.ThirdPersonActor.Base.Velocity;
				if( (X dot rocket.Velocity) > 0.90)
					// only transmit vehicle's velocity to rockets if it is more or less parallel to the rocket's velocity
					rocket.Velocity += (Weapon.ThirdPersonActor.Base.Velocity*0.5);

				//			log("Rocket "$p$" seeking "$rocket.Seeking);
			}
		}
	}

	if(Weapon.Role == ROLE_Authority && rocket != none)
    {
		VGHavokRaycastVehicle(launcher.ThirdPersonActor.Base).HAddImpulse(
			Normal(rocket.Velocity)*(-havokImpulseStrengthPerRocket)*SpawnCount,
			launcher.ThirdPersonActor.Location
			);
	}

	numRocketsLoaded = 0;
	loadTimer = 0;//loadFreq;
	loadCount = 0;
	numToFire = 0;
}

defaultproperties
{
     numRocketsLoaded=6
     loadcount=6
     HeatPerShot=0.800000
     MaxHeatPerShot=4.500000
     loadFreq=1.000000
     seekRange=5000.000000
     FiringRotation(0)=(Pitch=1820)
     FiringRotation(1)=(Pitch=910,Yaw=1820)
     FiringRotation(2)=(Pitch=910,Yaw=-1820)
     FiringRotation(3)=(Yaw=910)
     FiringRotation(4)=(Yaw=-910)
     FiringOffset(0)=(X=-30.000000,Y=18.781000,Z=0.160000)
     FiringOffset(1)=(X=-30.000000,Y=-18.781000,Z=0.160000)
     FiringOffset(2)=(X=-30.000000,Y=29.322001,Z=0.160000)
     FiringOffset(3)=(X=-30.000000,Y=-29.322001,Z=0.160000)
     FiringOffset(4)=(X=-30.000000,Y=39.549000,Z=0.160000)
     FiringOffset(5)=(X=-30.000000,Y=-39.549000,Z=0.160000)
     ProjSpawnOffset=(X=25.000000,Y=15.000000,Z=-20.000000)
     MaxHeatTime=5.000000
     MaxCoolTime=3.500000
     bNoAutoAim=True
     AmmoPerFire=1
     FireAnimRate=0.750000
     TweenTime=0.010000
     FireRate=1.750000
     BotRefireRate=0.700000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireSound=Sound'NewVehicleSounds.bogie.BogieLauncherFire'
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     ProjectileClass=Class'VehicleWeapons.BogieRocket'
     FireForce="SwarmFire"
}
