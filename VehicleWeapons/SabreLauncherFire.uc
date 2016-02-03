class SabreLauncherFire extends VGProjectileFire;

var	()	float	HeatPerShot;	// heat per shot at minimum charge
var ()  float   MaxHeatPerShot;	// heat per shot at maximum charge

var () float SeekRange;
var    int Barrel;

var rotator	FiringRotation[6];
var vector	FiringOffset[6];

simulated function bool AllowFire()
{
    return (Instigator != none && Instigator.Health > 0);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function InitEffects()
{
    Super.InitEffects();
}

function ModeDoFire()
{
	Super.ModeDoFire();
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
    local Vector StartProj, StartTrace, X,Y,Z;
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
    
    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

	vect = VGWeaponAttachment(Weapon.ThirdPersonActor).GetMuzzleLocation();
	if(Instigator.Controller.IsA('VehiclePlayer') ) {
		StartTrace = VehiclePlayer(Instigator.Controller).LastCamLocation;
		Other = Trace(HitLocation, HitNormal, StartTrace+20000*vector(VehiclePlayer(Instigator.Controller).LastCamRotation), StartTrace, true);
//		log(" Base = "$Weapon.Base$", Owner = "$Weapon.Owner$", TPA.Base = "$Weapon.ThirdPersonActor.Base);
//		log(" Other 1 = "$Other);
		if(Other != none && Other != Weapon.ThirdPersonActor.Base) {
			rot = Rotator(HitLocation-vect);
			// double check to make sure we're not hitting the bogie the launcher is situated on
			Other = Trace(HitLocation, HitNormal, vect+20000*vector(rot), vect, true);
			if(Other == Weapon.ThirdPersonActor.Base)
				rot = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');
		}
		else
			rot = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');
	}
	else
		rot = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');

//	rot = Weapon.ThirdPersonActor.GetBoneRotation('Weapon');

    StartTrace = vect;
	SpawnCount = Max(0, ProjPerFire * int(Load));

//	log("SpawnCount = "$SpawnCount$", ProjPerFire = "$ProjPerFire);

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
	if(Seeking != none) {
		for(p = 1; p < SpawnCount; p++) {
			closestDist = 1000000;

			foreach VisibleCollidingActors(class'Actor', target, seekRange, Seeking.Location) {
//				log("VGR:  SML:  Testing "$target);
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

//				log("VGR:  SML:  "$target$" pased first check");

				// of the potential targets we haven't ruled out, find the closest one
				SeekingDir = Normal(target.Location-Location);

//				log("VGR:  SML:  Testing dir vs vel");

				// skip targets that are behind us
				if( (SeekingDir Dot Normal(Velocity) ) > 0.05) {
					// go after the closest target in range
					dist = VSize(SeekingDir);
					if(dist < closestDist) {
//						log("VGR:  SML:  potential closest");
						// check to make sure nothing is blocking the target
						if(Trace(HitLocation, HitNormal, target.Location, StartProj, true) == target) {
							closestDist = dist;
							seekTargets[p] = target;
//							log("VGR:  SML:  New closest");
						}
					} // test closest
				} // test direction
			} // foreach
		}
	}

//	for (p = 0; p < SpawnCount; p++)
//    {
		p = 0;
		StartProj = (FiringOffset[Barrel] >> rot) + vect;//Weapon.GetFireStart(X,Y,Z);

		// check if projectile would spawn through a wall and adjust start location accordingly
		Other = Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
		if(Other != None)
			StartProj = HitLocation;

	    rocket = BogieRocket(SpawnProjectile(StartProj, rot) );

		if(rocket != none) {
			// select a target for the rocket to seek
			if(p >= seekTargets.Length)
				rocket.Seeking = Seeking;
			else
				rocket.Seeking = seekTargets[p];

			// inherit vehicle's velocity
			rocket.Velocity += Weapon.ThirdPersonActor.Base.Velocity;
//			log("Rocket "$p$" seeking "$rocket.Seeking);
		}
		
		if(Barrel == 0) {
			Barrel = 1;
			Weapon.ThirdPersonActor.PlayAnim('Fire02', 1);
		}
		else {
			Barrel = 0;
			Weapon.ThirdPersonActor.PlayAnim('Fire01', 1);
		}
//	}
}

defaultproperties
{
     HeatPerShot=0.800000
     MaxHeatPerShot=4.500000
     seekRange=5000.000000
     FiringRotation(0)=(Pitch=1820)
     FiringRotation(1)=(Pitch=910,Yaw=1820)
     FiringRotation(2)=(Pitch=910,Yaw=-1820)
     FiringRotation(3)=(Yaw=910)
     FiringRotation(4)=(Yaw=-910)
     FiringOffset(0)=(X=1.000000,Y=16.370001,Z=0.160000)
     FiringOffset(1)=(X=1.000000,Y=-16.370001,Z=0.160000)
     FiringOffset(2)=(X=1.000000,Y=39.139999,Z=0.160000)
     FiringOffset(3)=(X=1.000000,Y=-39.139999,Z=0.160000)
     FiringOffset(4)=(X=1.000000,Y=16.760000,Z=0.160000)
     FiringOffset(5)=(X=1.000000,Y=-16.760000,Z=0.160000)
     ProjSpawnOffset=(X=25.000000,Y=15.000000,Z=-20.000000)
     MaxHeatTime=5.000000
     MaxCoolTime=3.500000
     bNoAutoAim=True
     AmmoPerFire=1
     FireAnimRate=0.750000
     TweenTime=0.090000
     FireRate=1.000000
     BotRefireRate=0.700000
     AutoAim=0.950000
     MaxFireNoiseDist=3000.000000
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     ProjectileClass=Class'VehicleWeapons.BogieRocket'
     FlashEmitterClass=Class'VehicleEffects.PlasmaMuzzleFlash'
     FireForce="SwarmFire"
}
