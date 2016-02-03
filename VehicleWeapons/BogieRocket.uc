class BogieRocket extends VGProjectile;

var bool bHitWater;

var		Emitter			Trail;
var		Actor			Corona;
var	()	class<Emitter>	TrailClass;
var	()	class<Actor>	CoronaClass;
var	()	class<Actor>	ExplosionClass;

var	()	float			LobDuration;
var ()	vector			LobVelocity;		//used for the lobing effect when first firing
var	()	bool			bInitialLob;
var	()	bool			bSeeking;			//whether it needs to replicate data or not
var		float			time, time2;		//timers for the cool projectile motion
var     float			seekTimer;
var		float			seekDelayTime;
var		float			seekNextTime;
var		float			seekRange;
var		vector			SavedFront, SavedRight, SavedUp;	//rocket up vector

var Actor Seeking;
var vector InitialDir;
var Sound FlySound;

var bool bSavedRadius;
var float SavedRadius;

var xEmitter RibbonEffect;
var class<xEmitter> EmitterClass;

const seekUpdateFreq = 0.1;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority && bSeeking )
		Seeking, InitialDir;
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
    	RibbonEffect = Spawn( EmitterClass, Self );
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
//	if(Seeking != none)
//		Seeking.numSeeking--;

	if(Trail != None)
		Trail.Kill();
	if(Corona != none)
		Corona.Destroy();
	if(RibbonEffect != none) {
		RibbonEffect.mRegen = false;
		RibbonEffect = none;
	}
	Super.Destroyed();
}

simulated function SpawnRocketTrail()
{
//	if(TrailClass != none)
//		Trail = Spawn(TrailClass,self);
    if(CoronaClass != none)
        Corona = Spawn(CoronaClass,self);
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	if(ExplosionClass != none)
		spawn(ExplosionClass,,,HitLocation+HitNormal*ExploWallOut,rotator(HitNormal));
}

auto state Launching
{
	simulated function BeginState()
	{
		if(!bInitialLob)
		{
			Timer();
			return;
		}

		//The small MERVs and the seeking rockets are lobbed
		Velocity = LobVelocity >> Rotation;
//		SetTimer( LobDuration, false );
		seekTimer = 0;
	}
	simulated function Tick(float dt)
	{
		seekTimer += dt;
		if(dt >= LobDuration) {
			SetPhysics(PHYS_Projectile);
			GotoState('Flying');
		}
	}
	simulated function Timer()
	{
		SetPhysics(PHYS_Projectile);
		GotoState('Flying');
	}
}

// set the seek status of this rocket
simulated function SetSeeking(bool bSeekFlag)
{
	bSeeking = bSeekFlag;
//	log("VGR:  (SetSeeking) bSeeking = "$bSeeking);
	if(bSeeking) {
//		if(IsInState('Flying') )
//			SetTimer(seekUpdateFreq, true);
		seekTimer = 0;

		// try to find a target to seek
//		FindSeekingTarget();
	}
}

simulated function FindSeekingTarget()
{
	local Actor target;
	local float closestDist, dist, dist2;
	local Vector HitLoc, HitNorm, SeekingDir;//, StartTrace;
//	local Rotator Aim;
//	local float BestDist, BestAim;

	closestDist = 1000000;

/*	StartTrace = Instigator.Location+Instigator.EyePosition();
	Aim = Instigator.GetViewRotation();
	BestAim = 1.0;

	target = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, 5000);
	if(target == none) {
		target = Trace(HitLoc, HitNorm, StartTrace+vector(Aim)*5000, StartTrace, true);
		if(target != none && !target.IsA('VGVehicle') )
			target = none;
	}
	log("Pick target = "$target);
	if(target != none) {
		Seeking = target;
		return;
	}
*/
//	log("VGR:  checking for seek targets");
	foreach VisibleCollidingActors(class'Actor', target, seekRange, Location) {
//		log("VRG: checking "$target$" with instigator == "$Instigator);
		if( (target.IsA('VGVehicle') || target.IsA('VGPawn') ) && target != Instigator) {
			SeekingDir = Normal(target.Location-Location);
			dist2 = VSize(target.Location-Instigator.Location);

			// skip targets that are behind us
			if( (SeekingDir Dot Velocity) > 0 && dist2 > 500) {
				// go after the closest target in range
				dist = VSize(SeekingDir);
				if(dist < closestDist && CanLockOnTo(target) ) {
					// check to make sure nothing is blocking the target
					if(Trace(HitLoc, HitNorm, target.Location, Location, true) == target) {
						closestDist = dist;
						Seeking = target;
					}
//					log("VGR:  potential seek target "$target);
				}
			}
		}
	}

//	if(Seeking != none)
//		log("VGR:  now seeking "$Seeking);
}

simulated function bool CanLockOnTo(Actor Other)
{
		local Pawn P;
	if(!bSeeking)
		return false;
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

state Flying
{
	simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if (!NewVolume.bWaterVolume || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			PlayAnim( 'Still', 3.0 );
			Trail.Kill();
		}
		Velocity=0.6*Velocity;
	}

	simulated function BeginState()
	{
		local vector Dir;
		Dir = vector(Rotation);
		GetAxes( Rotation, SavedFront, SavedRight, SavedUp );
		Velocity = Speed * Dir;
		Acceleration = Dir * AccelRate;
		AddLightTag( 'WeaponEffectLight' );
		if ( PhysicsVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SpawnRocketTrail();
		}
//		log("VGR:  bSeeking = "$bSeeking);
		if ( bSeeking )
		{
//		    SetTimer(seekUpdateFreq, true);
			seekTimer = 0;
		}
		AmbientSound = FlySound;
	}

	simulated function Tick(float DeltaTime)
	{
		local float temp2, launchAngle; //used in the velocity calculation
		local float A,w,w2,t_max; //to debug only
		local vector Dir;
		local vector Spin;
		local rotator SpinRot;

		local vector SeekingDir;
		local float MagnitudeVel;//, amod;

//		log("VG:  Tick!");

		//Testing a cooler projectile motion (xmatt)
		//Note: I might not want to do that for the bots
		//Note: The domain is [0,inf]


		//Try 1: Decaying sinusoid with large period
		//			x(t) = -A*sin(k*t+theta)e^(-p*t)
		//			v(t) = -A*e^(-p*t){k*cos(k*t+theta) - p*sin(k*t+theta))}
		//

		//Try 2: Drops slightly then regains height with an asymptote at y=0
		//			x(t) = -A*t*e^(-p*t)
		//			v(t) = -A*e^(-p*t)*(1 - p*t)
		//
		if(false)// && !bSeeking)
		{
			if(Seeking != none)
				SetRotation(rotator(Velocity) );
			Dir = vector(Rotation);
			Velocity = Speed * Dir;

			//Try 3: Drop smoothly following a cosine until time reaches the period/2
			//			x(t) = A*cos(w*t) - A
			//			v(t) = -A*w*sin(w*t)
			//
			A = 25;
			t_max = 0.35;
			//Make it drop until it hits the first local minimum (which is -2*A)
			if( time < t_max )
			{
				//Set the velocity so that physProjectile in UnPhysics.cpp can use it
				Acceleration.x = 0; //force physProjectile to use the velocity we compute here
				Acceleration.y = 0;
				Acceleration.z = 0;

				time += DeltaTime;
				w = PI/t_max;
				temp2 = -A*w*sin( w*time );
				Velocity += temp2*SavedUp;
			}

			//Only make it spin if the drop is done
			else if(false) //Seeking == none)
			{
				if( !bSavedRadius )
				{
					SavedRadius = abs( A*cos(w*time) );
					//log( "SavedRadius=" $ SavedRadius );
					bSavedRadius = true;
				}

				time2 += DeltaTime;
				//Create vector that describes circle in the 2D plane
				//Note: going CCW
				//Note: the mervs start at theta on the unit circle, the circular path must be offset

				//-------- Including phase change in circle motion -------
				//Compute phase change
				launchAngle = 2*PI*(-Rotation.Roll + 3*16384)/65535;

				//Linearly increase angular speed
				//accTime = 0.8;
				//w2_max = 7.0;
				//if( time2 <= accTime )
				//{
				//	w2 = Lerp( time2/accTime, 0.0, w2_max );
				//	//Vertical circle in 2D including phase change
				//	//Note: The second 2.0 is from the linear angular acceleration
				//	Spin.y =-2.0 * A * 2.0 * w2 * sin( w2 * time2 + launchAngle );
				//	Spin.z = 2.0 * A * 2.0 * w2 * cos( w2 * time2 + launchAngle );
				//}
				//else
				//{
					w2 = 7.0;
					//Vertical circle in 2D including phase change
					//Here is constant-angular velocity
					Spin.y =-2.0 * SavedRadius * w2 * sin( w2 * time2 + launchAngle );
					Spin.z = 2.0 * SavedRadius * w2 * cos( w2 * time2 + launchAngle );
				//}

				//Rotate it by the baby merv's rotation so it's a circle with respect to the player's eye
				SpinRot = Rotation;
				SpinRot.Roll = 0;
				Spin = Spin >> SpinRot;
				//---------------------------------------------------------------------

				//-------- Adding phase change through rotator -------
				//w2 = 2.0;
				////Vertical circle in 2D
				//Spin.y =-2.0 * SavedRadius * w2 * sin( w2 * time2 );
				//Spin.z = 2.0 * SavedRadius * w2 * cos( w2 * time2 );
				//
				////Generate the phase change using a rotator
				//DeltaRoll.Roll = Rotation.Roll + 16384;
				//Spin = Spin >> DeltaRoll;

				////Rotate it by the baby merv's rotation so it's a circle with respect to the player's eye
				//SpinRot = Rotation;
				//SpinRot.Roll = 0;
				//Spin = Spin >> SpinRot;
				//---------------------------------------------------------------------

				//Make the baby merv rotate
				Velocity += Spin;
			}
		}

//		log("VGR:  Tick!  bSeeking = "$bSeeking$", Seeking = "$Seeking);
		if(bSeeking) {
			seekTimer += DeltaTime;
			if(seekTimer < seekNextTime)
				return;

			// not really sure about this... it seems to make it too powerful (can hit things
			// at *really* long distances)
//			if(Seeking == None && seekTimer > seekDelayTime)
				// look for a seek target if there is currently none
//				FindSeekingTarget();

			seekNextTime = seekTimer+seekUpdateFreq;

			if( InitialDir == vect(0,0,0) )
				InitialDir = Normal(Velocity);

//			log("Seeking "$Seeking);

			if( (Seeking != None) && (Seeking != Instigator) ) {
				// determine how strongly the rocket seeks by how close they are to the target
				// seek stronger the farther we are away since, in theory, that means we have
				// to turn faster and as we get closer we make finer adjustments so as to try to
				// avoid overshooting
								w = VSize(Seeking.Location-Location);
				if(w > 2500)
					w = 2500;
				w /= 2500;	// w is in [0, 1]; w = 1 when VSize >= 2500; w = 0 when VSize = 0
								A = 0.25*(1.0-w)+0.5*w;

				// this is the dumb seeking by the ordinary seeking rockets; mervlets do something else
				SeekingDir = Normal(Seeking.Location + (Seeking.Velocity*A) - Location);
				if( (SeekingDir Dot InitialDir) > 0) {
//					log("VGR:  seeking");
					MagnitudeVel = VSize(Velocity);
					if(MagnitudeVel > MaxSpeed)
						MagnitudeVel = MaxSpeed;
					SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
					Velocity =  MagnitudeVel * SeekingDir;
					A = 50*(1.0-w)+30*w;
					Acceleration = A * SeekingDir;
					SetRotation(rotator(Velocity) );
				}
			}
		}
		//Just make it go straight
		else
		{
			Dir = vector(Rotation);
			Velocity = Speed * Dir;
		}
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if(Other.IsA('VGVehicle') && Instigator.IsA('VGPawn') && VGPawn(Instigator).RiddenVehicle == Other) {
		// don't do anything if we hit our own vehicle... hrm, well, try to move it forward a bit
		SetLocation(Location+vector(Rotation)*50);
		return;
	}

	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
     LobDuration=0.500000
     seekDelayTime=0.250000
     seekNextTime=0.100000
     seekRange=1000.000000
     FlySound=Sound'PariahWeaponSounds.rocket_fly_lp'
     CoronaClass=Class'VehicleEffects.PRocketCoronaEffect'
     ExplosionClass=Class'VehicleEffects.BarrelShardBurst'
     EmitterClass=Class'VehicleEffects.VGRocketTrail'
     LobVelocity=(X=300.000000,Z=300.000000)
     bSeeking=True
     VehicleDamage=30
     PersonDamage=50
     AccelRate=0.500000
     SplashDamage=30.000000
     ExplosionSound=Sound'PariahWeaponSounds.expl_rocket'
     Speed=4250.000000
     MaxSpeed=10000.000000
     DamageRadius=400.000000
     MomentumTransfer=1500.000000
     MyDamageType=Class'VehicleWeapons.VGRocketLauncherDamage'
     ExplosionDecal=Class'VehicleEffects.ExplosionMark'
     DrawScale=2.500000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Projectiles.missile_power'
     LightType=LT_Steady
     LightHue=19
     LightSaturation=210
     DrawType=DT_StaticMesh
     AmbientGlow=96
     bMatchLightTags=True
}
