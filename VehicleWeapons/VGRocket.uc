/******************************************************************************
 VGRocket.uc
 Revisions:
	-before Nov 17: Xavier 
	-after Nov 17: Matthieu
	-after Dec 10: Matthew Thorne (mthorne)
*******************************************************************************/

class VGRocket extends VGProjectile;

var bool bHitWater;

var		xEmitter		Trail;
var		Actor			Corona;
var	()	class<xEmitter>	TrailClass;
var	()	class<Actor>	CoronaClass;
var	()	class<Actor>	ExplosionClass;
var	()	class<Actor>	ExplosionDistortionClass;
var	()	class<xEmitter>	TrailClassMP;
var	()	class<Actor>	CoronaClassMP;
var	()	class<Actor>	ExplosionClassMP;
var	()	class<Actor>	ExplosionDistortionClassMP;

var	()	float			LobDuration;
var ()	vector			LobVelocity;		//used for the lobing effect when first firing
var	()	bool			bInitialLob;
var	()	bool			bSeeking;			//whether it needs to replicate data or not
var	()	bool			bMerv;
var		bool			bMervLet;			//Is it a rocket that was spawned from a merv
var		bool			bSpawnedMervlets;
var	()	bool			bRadiation;
var	()	float			MervDelay;
var	()	int				MervCount;
var	()	class<VGRocket>	MervletClass;
var		float			MervTime;
var		float			time, time2;		//timers for the cool projectile motion
var     float			seekTimer;
var		float			seekDelayTime;
var		float			seekNextTime;
var		vector			SavedFront, SavedRight, SavedUp;	//rocket up vector

//Seeking
var Actor				Seeking;
var Vector				SeekingPos;
var	()	int				Velocity_correction;
var ()	int				Acceleration_correction;
var ()  vector			Imprecision;
var ()	float			seekRange;	// range at which a rocket is able to lock on and start seeking a target
var ()	float			MERVseekRange;

var		vector			InitialDir;
var		Sound			FlySound;

var bool bSavedRadius;
var float SavedRadius;

var VGRocket FellowMervlet1, FellowMervlet2;	// other two mervlets spawned along with this one so that each mervlet can seek
												// a seperate target

var emitter RibbonEffect;
var class<Emitter> EmitterClass;
var class<Emitter> EmitterClassMP;

var bool bNeedsReset;

const seekUpdateFreq = 0.1;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority && bSeeking )
		Seeking, InitialDir, FellowMervlet1, FellowMervlet2, bSpawnedMervlets;
//	reliable if(Role < ROLE_Authority)
//		Trail;
}

simulated function Tick(float dt)
{
	Super.Tick(dt);
	GotoState('Launching');
}

simulated function PostBeginPlay()
{
	Seeking = none;
	seekTimer = 0;
	MervTime = 0;
	seekNextTime = 0.15;
	time = 0;
	time2 = 0;
	InitialDir = vect(0,0,0);

	if(Level.Game == none || !Level.Game.bSinglePlayer) {
		// use multiplayer effect rather than single player
		TrailClass = TrailClassMP;
		CoronaClass = CoronaClassMP;
		ExplosionClass = ExplosionClassMP;
		ExplosionDistortionClass = ExplosionDistortionClassMP;
		EmitterClass = EmitterClassMP;
	}

	bNeedsReset = false;
	bHidden = false;
	bPaused = false;
	bInitialLob = false;
					
	Super.PostBeginPlay();

}

simulated function Destroyed()
{
	if(Trail != None) {
		Trail.mRegen = false;
		Trail = none;
	}
//		Trail.Destroy();
	if(Corona != none)
		Corona.Destroy();
	Super.Destroyed();
}

simulated function SpawnRocketTrail()
{
	if(!bMerv || bMervlet) {
		if(TrailClass != none && Trail == none) {
			Trail = Spawn(TrailClass,self);
		}
	}

	if(CoronaClass != none )
		Corona = Spawn(CoronaClass,self);
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	local vector v;
	local rotator r;

	v = HitLocation+HitNormal*ExploWallOut;
	r = rotator(HitNormal);
	if(ExplosionClass != none)
		spawn(ExplosionClass,,,v,r);
	if(ExplosionDistortionClass != none)
		spawn(ExplosionDistortionClass,,,v,r);
}

// mthorne - this override is no longer needed since we no longer have the radiation rockets
//           henceforth, other overrides will be done in the child classes
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(Trail != None) {
		Trail.mRegen = false;
		Trail = none;
	}
//		Trail.Destroy();

	if(Corona != none)
		Corona.Destroy();

	AmbientSound = None;
    Super.Explode(HitLocation, HitNormal);

	bNeedsReset = true;
	bHidden = true;
	bPaused = true;

	GotoState('InActive');
}

simulated event PostNetReplicate()
{
//	log("bSpawnedMervlets = "$bSpawnedMervlets);
	if(bPaused && !bSpawnedMervlets) {
//		log("!!!!! PANIC!  Paused but never exploded!");
		Explode(Location, Vect(0, 0, 1) );
	}
}

state InActive
{
	simulated function BeginState()
	{
//		log("$$$ now inactive!");
//		log("    Trail = "$Trail);
//		log("    bExploded = "$bExploded);
//		log("    bHidden = "$bHidden);
//		log("    bPaused = "$bPaused);
		// make sure things have been properly exploded...
		if(Trail != None) {
			Trail.mRegen = false;
			Trail = none;
		}

		if(Corona != none)
			Corona.Destroy();

		bNeedsReset = true;
		bHidden = true;
		bPaused = true;
	}

	simulated function Tick(float dt)
	{
//		log("YOINK!");
		Super.Tick(dt);
		GotoState('Launching');
	}
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

	foreach VisibleCollidingActors(class'Actor', target, seekRange, Location) {
//		log("VRG: checking "$target$" with instigator == "$Instigator);
		if( (target.IsA('VGVehicle') || target.IsA('VGPawn') ) && target != Instigator && Instigator != none) {
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

	// check that another mervlet isn't already seeking the same target
	if(FellowMervlet1 != none && Seeking == FellowMervlet1.Seeking)
		Seeking = none;

	if(FellowMervlet2 != none && Seeking == FellowMervlet2.Seeking)
		Seeking = none;
}

simulated function bool CanLockOnTo(Actor Other)
{
    local Pawn P;
	if(!bSeeking)
		return false;
    P = Pawn(Other);

    if (P == None || P == Instigator || !P.bProjTarget || P.Health <= 0)
		// can't lock on if target is self or it's not a valid projectile target or if it's already dead
        return false;

	if(P.Controller == none)
		// in this case, it's probably a vehicle not being driven... allow it to be targeted
		return true;

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
			Trail.mRegen = false;
			Trail = none;
//			Trail.Destroy();

			if(Corona != none)
				Corona.Destroy();

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
//		log("VGR:  bSeeking = "$bSeeking);
		if ( bSeeking )
		{
//		    SetTimer(seekUpdateFreq, true);
			seekTimer = 0;
		}
		AmbientSound = FlySound;

//		log("bNeedsReset = "$bNeedsReset);
//		log("### BeginState!");
		if(bNeedsReset && !bPaused) {
//			log("=== reset!");
			PreBeginPlay();
			BeginPlay();
			PostBeginPlay();
			PostNetBeginPlay();
//			SetInitialState();
		}
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SpawnRocketTrail();
		}
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
//		log("Dir = "$Rotation$", Vel = "$rotator(Velocity) );

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
		
		//If it is a baby merv spin it
		if( bMervLet )
		{
			Dir = vector(Rotation);
			Velocity = Speed * Dir;

			//Try 3: Drop smoothly following a cosine until time reaches the period/2
			//			x(t) = A*cos(w*t) - A
			//			v(t) = -A*w*sin(w*t)
			//
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
				temp2 = -25*w*sin( w*time );
				Velocity += temp2*SavedUp;
			}

			//Only make it spin if the drop is done
			else if(!bSeeking || Seeking == none)
			{
				if( !bSavedRadius )
				{
					SavedRadius = abs( 25*cos(w*time) );
					bSavedRadius = true;
				}
				
				time2 += DeltaTime;

				//Create vector that describes circle in the 2D plane
				//Note: going CCW
				//Note: the mervs start at theta on the unit circle, the circular path must be offset

				//-------- Including phase change in circle motion -------
				//Compute phase change
				launchAngle = 2*PI*(-Rotation.Roll + 3*16384)/65535;

				w2 = 7.0;
				//Vertical circle in 2D including phase change
				//Here is constant-angular velocity
				Spin.y =-2.0 * SavedRadius * w2 * sin( w2 * time2 + launchAngle );
				Spin.z = 2.0 * SavedRadius * w2 * cos( w2 * time2 + launchAngle );

				//Rotate it by the baby merv's rotation so it's a circle with respect to the player's eye
				SpinRot = Rotation;
				SpinRot.Roll = 0;
				Spin = Spin >> SpinRot;

				//Make the baby merv rotate
				Velocity += Spin;
			}
		}
		
		if(bSeeking)
		{
			seekTimer += DeltaTime;
			if(seekTimer < seekNextTime)
				return;

			// not really sure about this... it seems to make it too powerful (can hit things
			// at *really* long distances)

			seekNextTime = seekTimer+seekUpdateFreq;

			if( InitialDir == vect(0,0,0) )
				InitialDir = Normal(Velocity);

			if( (Seeking != None) && (Seeking != Instigator) ) {
				// determine how strongly the rocket seeks by how close they are to the target
				// seek stronger the farther we are away since, in theory, that means we have
				// to turn faster and as we get closer we make finer adjustments so as to try to
				// avoid overshooting
				
				// this is the dumb seeking by the ordinary seeking rockets; mervlets do something else
				if(Seeking.IsA('Pawn') )
					SeekingDir = Seeking.Location + (Seeking.Velocity*Velocity_correction) - Location;
				else
					SeekingDir = SeekingPos + (Seeking.Velocity*Velocity_correction) - Location;

				//Add imprecision (xmatt)
				if( Imprecision.X != 0 || Imprecision.Y != 0 || Imprecision.Z != 0 )
					SeekingDir += Imprecision;
				
				SeekingDir = Normal( SeekingDir );
				
				if( (SeekingDir Dot InitialDir) > 0) {
					MagnitudeVel = VSize(Velocity);
					if(MagnitudeVel > MaxSpeed)
						MagnitudeVel = MaxSpeed;
					SeekingDir = Normal(SeekingDir * MagnitudeVel + Velocity*0.15);
					Velocity =  Velocity*0.25+MagnitudeVel*SeekingDir*0.75;
					A = 8000;
					Acceleration = Acceleration_correction * SeekingDir; 
					SetRotation(rotator(Velocity) );
				}
			}
		}
		//Just make it go straight
		else
		{
			Dir = vector(Rotation);
			Velocity = Speed * Dir;
			Acceleration = vect(0, 0, 0);
		}
	}
}

function SetParams(int VehicleDmg, int PersonDmg, float SplashDmg, float DmgRadius, float Momentum)
{
	VehicleDamage = VehicleDmg;
	PersonDamage = PersonDmg;
	SplashDamage = SplashDmg;
	DamageRadius = DmgRadius;
	MomentumTransfer = Momentum;
}

defaultproperties
{
     MervCount=2
     Acceleration_correction=8000
     LobDuration=0.200000
     MervDelay=0.100000
     seekDelayTime=0.200000
     seekNextTime=0.150000
     seekRange=600.000000
     MERVseekRange=5000.000000
     FlySound=Sound'PariahWeaponSounds.rocket_fly_lp'
     TrailClass=Class'VehicleEffects.VGRocketTrail'
     CoronaClass=Class'VehicleEffects.PRocketCoronaEffect'
     ExplosionClass=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     TrailClassMP=Class'VehicleEffects.VGRocketTrail'
     CoronaClassMP=Class'VehicleEffects.PRocketCoronaEffect'
     ExplosionClassMP=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClassMP=Class'VehicleEffects.VGRocketExplosionDistort'
     EmitterClass=Class'VehicleGame.MervRibbon'
     EmitterClassMP=Class'VehicleGame.MervRibbon'
     LobVelocity=(X=300.000000,Z=300.000000)
     VehicleDamage=50
     PersonDamage=40
     AccelRate=0.500000
     SplashDamage=100.000000
     ExplosionSound=Sound'PariahWeaponSounds.hit.Rocket_Explosion'
     Speed=2200.000000
     MaxSpeed=2800.000000
     DamageRadius=550.000000
     MomentumTransfer=4000.000000
     MyDamageType=Class'VehicleWeapons.VGRocketLauncherDamage'
     ExplosionDecal=Class'VehicleEffects.ExplosionMark'
     LifeSpan=0.000000
     DrawScale=2.500000
     SoundRadius=200.000000
     ForceRadius=500.000000
     ForceScale=5.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Projectiles.missile_power'
     DrawType=DT_StaticMesh
     AmbientGlow=96
     SoundVolume=255
     ForceType=FT_DragAlong
     bNetTemporary=False
     bAlwaysRelevant=True
     bReplicateInstigator=False
     bUpdateSimulatedPosition=True
     bReplicateNotify=True
}
