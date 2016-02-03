class VGPawn extends xPawn
		native;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx
#exec OBJ LOAD FILE=PariahEffectsTextures.utx //msp
#exec OBJ LOAD FILE=HavokObjectSounds.uax 
#exec OBJ LOAD FILE=PariahWeaponSounds.uax

var VGVehicle PotentialVehicle;
var VGVehicle OwnedVehicle;
var bool bDrivingSomething;

var PlayerTurret PotentialTurret;

//If we want to spawn a pawn *in* a car, we have to disable the encroach death while we spawn the car.
var bool bNoEncroachHack;

//I know, this is getting confusing.  But DrivenVehicle is a reference to the vehicle iff the VGPawn is currently driving one.
var VGVehicle DrivenVehicle;
var Vector DrivenVehicleSpot;
var VGVehicle RiddenVehicle;
var byte RiddenVehicleSpot;

var vector  ExitByAnimPos;


var PlayerTurret RiddenTurret;

var	bool bHealthEffect;
var	bool bHasRegeneration;
var	float	DeltaRegen;
var float SumDelta;

var VGWeaponAttachment VGWeaponAttachment;

// jim: HelmetAttachment for helmets that can fall off or shatter the visor.
var() staticmesh Helmet;
var class<HelmetAttachment> HelmetClass;
var HelmetAttachment HelmetActor;
var name HelmetBone;
var vector HelmetRelativeLocation;
var rotator HelmetRelativeRotation;


var bool	bPoisoned;
var	int		PoisonAmmount;
var	float	PoisonEndTime, NextPoisonTime;
var	Pawn	PoisonInstigator;

var bool	bMotionBlurWhileDashing;
var	transient bool	bMotionBlurred;
var float	MotionBlurDeltaRate;
var float	MotionBlurFactor;

var float DashSpeed;
var float DashTimeLeft;
var float DashTime;
var float DashRechargeTimeLeft;
var float DashRechargeTime;

// stuff for setting on fire
var ParticleSmallFire Fire;
var float burningTime;
var float maxBurningTime;
var float lastFireDamageTime;
var float fireDamageFreq;
var int fireDamagePerInterval;
var array<float> fireDecreaseAt;
var Pawn FireInstigator;
var class<DamageType> BurnDamageType;

// poisoning stuff
var float lastPoisonTime;

var InterpCurve	 HavokObjectImpulseScale;

// cmr -- to force linearization of teamskin textures.  Temp hack.
// rj --- extend hack so that this is an array of materials and it's also used for precaching
var array<Material> CharacterSkins;
var array<Mesh>		CharacterMeshes;

var StaticMesh JimBox;


var transient vector RunOverVelocity;
var float RagdollRunOverLift;
var float RagdollRunOverVelocityTransfer;

var PhysicsVolume			SurfaceEmitterPhysicsVolume;
var transient Emitter		PhysicsVolumeSurfaceMotionEmitter;
var transient array<float>	PhysicsVolumeSurfaceMotionEmitterPPS;
var transient bool			PhysicsVolumeSurfaceMotionEmitterRunning;
var transient Emitter		PhysicsVolumeSurfaceIdleEmitter;
var transient array<float>	PhysicsVolumeSurfaceIdleEmitterPPS;
var transient bool			PhysicsVolumeSurfaceIdleEmitterRunning;
var bool					bDisableSurfaceEmitters;

// flags a pawn as being "irradiated" via the uranium bullet upgrade on the bulldog (or possibly other means)
var bool bIrradiated;
var float RadiationTime;
var float RadiationTimer, RadDmgTimer;
var Pawn RadiationInst;

var bool bNeedToDie;
var Vector NeedToDieVelocity;

// needed for the ability to be revived
var Controller DelayedKiller;
var class<DamageType> DelayedDamageType;
var Vector DelayedHitLoc;
var bool bDelayingDeath;	// for networking

var Weapon SavedWeapon;

var bool IsCloaked; //If it is cloaked due to the sniper weapon (MS)
var float HealthUnitRegenRate;


var bool bDropNothingOnDeath;

enum RunAnimStyle
{
	RAS_Default,
	RAS_NormalGun,
	RAS_BigGun,
	RAS_SingleHand,
};

var float LastDamaged;
var float HealthAccum;
var bool bPlayedHealthUp;

var bool bFriendly; // Friendly to player

replication
{
	// functions client can call
	reliable if( Role<ROLE_Authority )
		EnterVehicleWorker,RideVehicleDebug, ToggleCloaking;

	reliable if( Role==ROLE_Authority )
		RiddenVehicle, RiddenVehicleSpot, Fire, lastPoisonTime, DashTime, bIrradiated, SavedWeapon, IsCloaked, RiddenTurret;
	reliable if( Role==ROLE_Authority )
		DrivenVehicle, bDrivingSomething, DrivenVehicleSpot, SurfaceEmitterPhysicsVolume;


	reliable if( Role==ROLE_Authority )
		ClientVehicleWeaponStuff, ClientEndRideVehicle;

	//cmr need to make dashing functions reliable so they don't accidentally fire out of order.  
	reliable if( Role == ROLE_Authority )
		ClientEndDash, ClientDash;
	reliable if( Role < ROLE_Authority )
		ServerDash, ServerEndDash;

}


//cmr -- moved up from xpawn to handle case of a driver driving a vehicle
simulated event PostNetReceive()
{
	local PlayerReplicationInfo PRI;
    //log(self$" PostNetReceive PlayerReplicationInfo.CharacterName="$PlayerReplicationInfo.CharacterName);

	if ( PlayerReplicationInfo != None || (DrivenVehicle != None && DrivenVehicle.PlayerReplicationInfo!=None ) ) // && PlayerReplicationInfo.Team != None)
    {
		//log("SPR called by postnetreceive");

		PRI=GetRealPRI();

		SetupPlayerRecord(class'xUtil'.static.FindPlayerRecord(PRI.CharacterName));
		bNetNotify = false;
    }
}


simulated function SetupPlayerRecord(xUtil.PlayerRecord rec, optional bool bLoadNow)
{   
	local string meshstr;
	

	Super.SetupPlayerRecord(rec, bLoadNow);


	meshstr = rec.MeshName;


	if(InStr(Caps(meshstr), Caps("stubbs_male")) != -1)
	{
		Helmet = StaticMesh(DynamicLoadObject("PariahCharacterMeshes.Helmets.Stubbs_Helmet", class'StaticMesh'));
	}
	else if(InStr(Caps(meshstr), Caps("HeavyGuard_Male")) != -1)
	{
		Helmet = StaticMesh(DynamicLoadObject("PariahCharacterMeshes.Helmets.HeavyGuard_Helmet", class'StaticMesh'));
	}
	else
	{
		return;
	}

	if(Role == Role_Authority)
		SetHelmet();

	

}


simulated function PlayerReplicationInfo GetRealPRI()
{
	if(DrivenVehicle != None)
		return DrivenVehicle.PlayerReplicationInfo;
	else
		return PlayerReplicationInfo;
}


function SetDrivenVehicle(VGVehicle v)
{
	DrivenVehicle = v;
	bDrivingSomething= v!=None;
	//log("SetDrivenVehicle( "$bDrivingSomething@DrivenVehicle$" )");
}

exec function Dash()
{
	if(!Weapon.IsFiring() && !Weapon.IsInState('Reload'))
	{
		//log("Dash called serverdash");
		ServerDash();
	}
}

exec function BlurWhileDashing()
{
	bMotionBlurWhileDashing = !bMotionBlurWhileDashing;
}

simulated event Destroyed()
{
	if(Role == ROLE_Authority)
	{
		if ( HelmetActor != None )
			HelmetActor.Destroy();
	}

	Super.Destroyed();
}

function ClientDash() //replicated from server to client, tells client to do dash starting stuff
{
	local MotionBlurPostFXStage	mbe;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		//log("clientdash received");
		Weapon.LowerWeapon();

		if ( bMotionBlurWhileDashing && !PlayerController(Controller).IsSharingScreen() )
		{
			mbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage( Level );
			if ( mbe != None )
			{
				if ( !bMotionBlurred )
				{
					mbe.PushMotionBlurState();	// save current state
				}

				// start with no motion blur
				MotionBlurFactor = 0;
				mbe.SetMotionBlurParams( True, 1, 0 );
				MotionBlurDeltaRate = 4;
				bMotionBlurred = True;
			}
		}
	}
}

function ServerDash() //replicated from client to server, tells server to start dash
{
	if(DashRechargeTimeLeft > 0.0 || DashTimeLeft > 0.0 || Physics == PHYS_Ladder)
	{
		return;
	}
	if(Level.Game.bGameEnded)
	{
	    return;
	}
	
	//log("serverdash, calling clientdash");
	ClientDash();
	
	if(Controller != None && Controller.IsA('PlayerController'))
	{
		PlayerController(Controller).ClientEndZoom();
	}

	//log("setting dashtime to "$DashTime);
	DashTimeLeft = DashTime;
	GroundSpeed = DashSpeed;

	DashState = DSX_Dashing;
}

//function ServerDash()
//{
//	GroundSpeed = DashSpeed;
//}

function IncreaseDashTime(float amount, float max)
{
	local float f;
	f = FMin(Dashtime+amount, max);
	log("increasing dasht ime to "$f);
	DashTime = f;
}

function EndDash() //called only on server, not replicated
{

	if(Role < ROLE_Authority)
	{
		log("ERROR: ENDDASH CALLED ON CLIENT");
		return;
	}

	if( DashState != DSX_Dashing )
	{
		//log("enddash skipped cause of not dashing");

		return;
	}

	//log("enddash calling clientenddash()");
	ClientEndDash();

	GroundSpeed = default.GroundSpeed;
	DashTimeLeft = 0.0;
	DashState = DSX_Resting;

}


function ClimbLadder(LadderVolume L)
{
	Super.ClimbLadder(L);
	log("climbing ladder LOL");
	EndDash();
}

function ServerEndDash() //replicated from client to server, tells server to end dash (like when player fires);
{
	//GroundSpeed = default.GroundSpeed;
	//log("serverenddash called");
	EndDash();
}

function ClientEndDash() //replicated from server to client, tells client dashing is done.
{
	//log("clientenddash received");
	if(Controller.GetStateName()!='PlayerClimbing') //for when we dash to a ladder
		Weapon.RaiseWeapon();

	// reduce motion blur
	if ( bMotionBlurred )
	{
		MotionBlurDeltaRate = -2;
	}
}

simulated function CreateSurfaceEmitter( class<Emitter> EmitterClass, out Emitter TheEmitter, out array<float> SavedPPS )
{
	local int				e;
	local ParticleEmitter	SubEmitter;

	if ( EmitterClass != None )
	{
		TheEmitter = Spawn( EmitterClass, self );

//		`log( "RJ: Created surface emitter "$TheEmitter$" of class "$EmitterClass );

		TheEmitter.SetPhysics( PHYS_None );

		SavedPPS.Length = TheEmitter.Emitters.Length;
		TheEmitter.AutoReset = True;
		TheEmitter.AutoDestroy = False;
		for ( e = 0; e < TheEmitter.Emitters.Length; e++ )
		{
			SubEmitter=TheEmitter.Emitters[e];
			if ( SubEmitter.ParticlesPerSecond != 0 )
			{
				SavedPPS[e] = SubEmitter.ParticlesPerSecond;
			}
			else
			{
				SavedPPS[e] = SubEmitter.MaxParticles / SubEmitter.LifetimeRange.Max;
				SubEmitter.InitialParticlesPerSecond = SavedPPS[e];
				SubEmitter.ParticlesPerSecond = SavedPPS[e];
			}
//			`log( "RJ: Surface emitter "$TheEmitter$" subemitter "$e$" has pps="$SavedPPS[e] );
			SubEmitter.AutoDestroy=True;
			SubEmitter.AutoReset=False;
			SubEmitter.AutomaticInitialSpawning=False;
			SubEmitter.RespawnDeadParticles=False;
			SubEmitter.ResetAfterChange=True;
		}
	}
}

simulated function bool StopSurfaceEmitter( Emitter TheEmitter, bool bRunning )
{
	local int				e;
	local ParticleEmitter	SubEmitter;

	if ( TheEmitter != None && bRunning )
	{
//		`log( "RJ: stopping surface emitter "$TheEmitter );
		for ( e = 0; e < TheEmitter.Emitters.Length; e++ )
		{
			SubEmitter = TheEmitter.Emitters[e];

			if ( SubEmitter != None )
			{
				if ( SubEmitter.ParticlesPerSecond != 0 )
				{
					SubEmitter.InitialParticlesPerSecond = 0;
					SubEmitter.ParticlesPerSecond = 0;
				}
			}
		}
		bRunning = False;
	}
	return bRunning;
}

simulated function bool RestartSurfaceEmitter( Emitter TheEmitter, array<float> SavedPPS, bool bRunning )
{
	local int				e;
	local ParticleEmitter	SubEmitter;

	if ( TheEmitter != None && !bRunning )
	{
		for ( e = 0; e < TheEmitter.Emitters.Length; e++ )
		{
			SubEmitter = TheEmitter.Emitters[e];

			if ( SubEmitter != None )
			{
				// If the emitter shut itself off, turn it back on
				//
				if ( SubEmitter.Disabled )
				{
					SubEmitter.Disabled = False;
					SubEmitter.InactiveTime = 0;
					SubEmitter.AllParticlesDead = False;
				}
				SubEmitter.InitialParticlesPerSecond = SavedPPS[e];
				SubEmitter.ParticlesPerSecond = SavedPPS[e];
				`log( "RJ: restarting surface emitter "$TheEmitter$" subemitter "$e$" with pps="$SavedPPS[e] );
			}
		}
		bRunning = True;
	}
	return bRunning;
}

event Touch(Actor Other)
{
	local PhysicsVolume		pv;

	Super.Touch( Other );

	if ( SurfaceEmitterPhysicsVolume == None )
	{
		pv = PhysicsVolume( Other );
		if ( pv != None && (pv.SurfaceEmitter != None || pv.SurfaceIdleEmitter != None) && !bDisableSurfaceEmitters )
		{
			SurfaceEmitterPhysicsVolume = pv;
//			`log( "RJ: Touching "$SurfaceEmitterPhysicsVolume );
		}
	}
}

event UnTouch( Actor Other )
{
	Super.Untouch( Other );
	if ( Other == SurfaceEmitterPhysicsVolume )
	{
//		`log( "RJ: Untouching "$SurfaceEmitterPhysicsVolume );

		SurfaceEmitterPhysicsVolume = None;
	}
}

simulated function KillSurfaceEmitters( optional bool bForever )
{
	// shutdown any created emitters
	//
	SurfaceEmitterPhysicsVolume = None;
	if ( PhysicsVolumeSurfaceMotionEmitter != None )
	{
		PhysicsVolumeSurfaceMotionEmitter.Kill();
		PhysicsVolumeSurfaceMotionEmitterRunning = False;
		PhysicsVolumeSurfaceMotionEmitter = None;
	}
	if ( PhysicsVolumeSurfaceIdleEmitter != None )
	{
		PhysicsVolumeSurfaceIdleEmitter.Kill();
		PhysicsVolumeSurfaceIdleEmitterRunning = False;
		PhysicsVolumeSurfaceIdleEmitter = None;
	}
	if ( bForever )
	{
		bDisableSurfaceEmitters = True;
	}
}

function AutoHeal(float d)
{
	local int diffToBubble;
	local int bubbleIndex;
	local Controller RealController;

	if( Role != ROLE_Authority )
	{
		return;
	}

	if(Controller == None && DrivenVehicle != None)
	{
		RealController = DrivenVehicle.Controller;
	}
	else
	{
		RealController = Controller;
	}
	
	if
	(
	    Health == HealthMax ||
	    RealController == None ||
	    !RealController.IsA('PlayerController') || 
	    Level.TimeSeconds - LastDamaged < 5.0
    )
	{
	    return;
	}

    // regen, but only current interval
	bubbleIndex = Health / 25;
	if(bubbleIndex * 25 != Health)
	{
	    //log(">>Health: "@Health);
		diffToBubble = ((bubbleIndex + 1) * 25) - Health;
		if(diffToBubble > 0)
		{
			HealthAccum += d * 8.0;
			if(HealthAccum >= diffToBubble)
			{
				Health += diffToBubble;
				HealthAccum = 0.0;
			}
			else
			{
				while(HealthAccum > 1)
				{
					Health += HealthAccum;
					HealthAccum -= int(HealthAccum);
				}
            }
            //log(">>Health: "@Health);
			if(!bPlayedHealthUp)
			{
				bPlayedHealthUp = true;
				PlayerController(RealController).ClientPlaySound(Sound'PariahWeaponSounds.HealthRechargeB', true, 1.0, SLOT_Pain); // charge up
			}
		}
	}
}

//XJ: reduce health slowly if over default
simulated function Tick(float dt)
{
	local MotionBlurPostFXStage mbe;
	local vector hl, hn, ts, te;
	local Actor hitActor;
	local rotator r;

	Super.Tick(dt);
	
	if(bNeedToDie)
	{
		TakeDamage(1300, self, location, NeedToDieVelocity, class'RammingDamage');
		bNeedToDie=false;
		return;
	}

	if ( SurfaceEmitterPhysicsVolume != None && Level.NetMode != NM_DedicatedServer  && !IsFirstPerson() &&
		 !bIsDriving && RiddenVehicle == None )
	{
		ts = Location + CollisionHeight * vect(0,0,1);
		te = Location - CollisionHeight * vect(0,0,1);
		HitActor = VolumeTrace( hl, hn, te, ts );

		if ( HitActor == SurfaceEmitterPhysicsVolume )
		{
			if ( Velocity != vect(0,0,0) )
			{
				PhysicsVolumeSurfaceIdleEmitterRunning = StopSurfaceEmitter( PhysicsVolumeSurfaceIdleEmitter, PhysicsVolumeSurfaceIdleEmitterRunning );
				if ( SurfaceEmitterPhysicsVolume.SurfaceEmitter != None )
				{
					if ( PhysicsVolumeSurfaceMotionEmitter == None )
					{
						CreateSurfaceEmitter( SurfaceEmitterPhysicsVolume.SurfaceEmitter, PhysicsVolumeSurfaceMotionEmitter, PhysicsVolumeSurfaceMotionEmitterPPS );
						PhysicsVolumeSurfaceMotionEmitterRunning = True;
					}
					else
					{
						PhysicsVolumeSurfaceMotionEmitterRunning = RestartSurfaceEmitter( PhysicsVolumeSurfaceMotionEmitter, PhysicsVolumeSurfaceMotionEmitterPPS, PhysicsVolumeSurfaceMotionEmitterRunning );
					}
					PhysicsVolumeSurfaceMotionEmitter.SetLocation( hl );
				}
			}
			else
			{
				PhysicsVolumeSurfaceMotionEmitterRunning = StopSurfaceEmitter( PhysicsVolumeSurfaceMotionEmitter, PhysicsVolumeSurfaceMotionEmitterRunning );
				if ( SurfaceEmitterPhysicsVolume.SurfaceIdleEmitter != None )
				{
					if ( PhysicsVolumeSurfaceIdleEmitter == None )
					{
						CreateSurfaceEmitter( SurfaceEmitterPhysicsVolume.SurfaceIdleEmitter, PhysicsVolumeSurfaceIdleEmitter, PhysicsVolumeSurfaceIdleEmitterPPS );
						PhysicsVolumeSurfaceIdleEmitterRunning = True;
					}
					else
					{
						PhysicsVolumeSurfaceIdleEmitterRunning = RestartSurfaceEmitter( PhysicsVolumeSurfaceIdleEmitter, PhysicsVolumeSurfaceIdleEmitterPPS, PhysicsVolumeSurfaceIdleEmitterRunning );
					}
					PhysicsVolumeSurfaceIdleEmitter.SetLocation( hl );
				}
			}
		}
		else
		{
			PhysicsVolumeSurfaceMotionEmitterRunning = StopSurfaceEmitter( PhysicsVolumeSurfaceMotionEmitter, PhysicsVolumeSurfaceMotionEmitterRunning );
			PhysicsVolumeSurfaceIdleEmitterRunning = StopSurfaceEmitter( PhysicsVolumeSurfaceIdleEmitter, PhysicsVolumeSurfaceIdleEmitterRunning );
		}
	}
	else
	{
		KillSurfaceEmitters();
	}

	SumDelta += dt;
	if(Health > HealthMax)
	{
		if(SumDelta >= 2.0)
		{
			SumDelta = 0.0;
			Health -= 1;
		}
	}

	DeltaRegen += dt;
	if(bHasRegeneration && Health < default.Health && DeltaRegen > 1.0)
	{
		DeltaRegen = 0.0;
		Health += 1;
		bPoisoned = false;
	}

	if(Role==ROLE_Authority)
	{
		if(DashTimeLeft > 0.0)
		{
			DashTimeLeft-=dt;

			DashRechargeTimeLeft+=dt;

			if(DashTimeLeft <= 0.0)
			{
				DashTimeLeft = 0.0;
				EndDash();
			}
		}
		else if(DashRechargeTimeLeft > 0.0)
		{
			DashRechargeTimeLeft-=dt;
			if(DashRechargeTimeLeft <= 0.0)
			{
				DashState=DSX_Normal;
			}
		}
		if ( DashState == DSX_Resting )
		{
			AmbientSound = Sound'PariahWeaponSounds.hit.HeartbeatA';
		}
		else
		{
			AmbientSound = None;
		}
	}

	if(IsLocallyControlled() && DashState==DSX_Dashing)
	{
		if(PressingFire() || PendingWeapon != none || Get4WayDirection() != 0)
		{
			ServerEndDash();
		}
	}


	if(bPoisoned && NextPoisonTime <= Level.TimeSeconds)
	{
		if(PoisonEndTime != 0.0 && PoisonEndTime <= Level.TimeSeconds)
			bPoisoned = false;
		else
		{
			TakeDamage(PoisonAmmount, PoisonInstigator, Location, vect(0,0,0), class'DamageType',,true);
			NextPoisonTime = Level.TimeSeconds + 1.0;
		}
	}

	if ( bMotionBlurred )
	{
		mbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage( Level );

		MotionBlurFactor += dt * MotionBlurDeltaRate;

		if ( MotionBlurFactor > 0 )
		{
			MotionBlurFactor *= (VSize(Velocity) / GroundSpeed);
			MotionBlurFactor = FClamp( MotionBlurFactor, 0, 0.75 );
			mbe.SetMotionBlurParams( True, 1 - MotionBlurFactor, MotionBlurFactor );
		}
		else
		{
			bMotionBlurred = False;
			mbe.PopMotionBlurState();	// restore old state
		}
	}

	if(Role < ROLE_Authority)
	{
		//blah, a hack to get around the issue of drivenvehicle not replicating
		if(!bDrivingSomething)
		{
			DrivenVehicle=None;
			bIsDriving = False;
		}


		if(RiddenVehicle!=None && Physics!=PHYS_RidingBase) //engage the rider on this client
		{
			//log("CHARLES: Attaching pawn to riddenvehilce");

			SetPhysics(PHYS_RidingBase);
			SetBase(RiddenVehicle);
			SetRelativeLocation(RiddenVehicle.PassengerPoints[RiddenVehicleSpot]);
			if(RiddenVehicle.IsGunnerSpot[RiddenVehicleSpot]==1)
				SetRelativeRotation(r);
			bDontRotateWithBase=True;
		}
		else if(RiddenVehicle != None && Physics==PHYS_RidingBase && RelativeLocation != (RiddenVehicle.PassengerPoints[RiddenVehicleSpot]))
		{
			//warn("CHARLES:  Had to adjust rider position, it wasn't correct!");
			//SetRelativeLocation(RiddenVehicle.PassengerPoints[RiddenVehicleSpot]);
		}

		if(RiddenTurret != none && Physics != PHYS_RidingBase) {
			SetPhysics(PHYS_RidingBase);
			SetBase(RiddenTurret);
			SetRelativeLocation(RiddenTurret.PassengerPoint);
			bDontRotateWithBase = true;
		}

//		if(RiddenVehicle != none) {
//			log("3) RiderWeapon = "$RiddenVehicle.RiderWeapon$", Role = "$RiddenVehicle.RiderWeapon.Role$", RemoteRole = "$RiddenVehicle.RiderWeapon.RemoteRole);
//			log("   RiddenVehicle = "$RiddenVehicle$", Role = "$RiddenVehicle.Role$", RemoteRole = "$RiddenVehicle.RemoteRole);
//		}


		if(DrivenVehicle!=None && Physics!=PHYS_RidingBase) // engage the driver on this client
		{
			//log("CHARLES: Attaching pawn to driven vehicle because");

			//log(Physics@PHYS_Falling);

			SetPhysics(PHYS_RidingBase);
			SetBase(DrivenVehicle);
			SetRelativeLocation(DrivenVehicleSpot);
			bIsDriving = True;

			////log("Setting driveranim for "$self$" to "$DrivenVehicle.DrivingAnim);
			//DriverAnim = DrivenVehicle.DrivingAnim;
		}
		else if(DrivenVehicle == None && RiddenVehicle == None && RiddenTurret == none && Physics==PHYS_RidingBase)
		{
			//log("hey check that crazy shit out, I don't have a car and I'm still in the physics ridingbase");
			SetPhysics(PHYS_Falling);
			//warn("CHARLES:  Had to adjust driver position, it wasn't correct!");
			//SetRelativeLocation(DrivenVehicleSpot + Vect(0,0,80));
		}
		//else if(DrivenVehicle != None && Physics==PHYS_RidingBase)
		//{
		//	//log("Everything seems fine..."@"bIsDriving = "$bIsDriving$" Base = "$Base);

		//}

		if(RiddenVehicle==None && RiddenTurret == none)
			bDontRotateWithBase=False;
	}

	// if burning, take damage
	if(bOnFire) {
		burningTime += dt;
		if(burningTime >= maxBurningTime) {
//			log("???");
			bOnFire = false;
			Fire.Kill();
			FireInstigator = none;
			fireDamagePerInterval = 0;
		}
		else if( (burningTime-lastFireDamageTime) >= fireDamageFreq) {
			// still burninating... take damage
			lastFireDamageTime = burningTime;
//			log("FireInstigator = "$FireInstigator);
			if(Role == ROLE_Authority && FireInstigator != none && FireInstigator.Health > 0)
				TakeDamage(fireDamagePerInterval, FireInstigator, Location, vect(0, 0, 0), BurnDamageType);
//			log("VGRN:  Yoink! ("$self$")");
		}

		if(fireDecreaseAt.length > 0 && burningTime >= fireDecreaseAt[0] && Role == ROLE_Authority) {
			fireDamagePerInterval -= 5;
			if(fireDamagePerInterval < 0)
				fireDamagePerInterval = 0;

//			log("VGRN:  Less Burnination! ("$fireDamagePerInterval$", "$fireDecreaseAt[0]$")");
			fireDecreaseAt.Remove(0, 1);
		}
	}

	if(bIrradiated && ROLE == ROLE_Authority) {
		RadiationTimer += dt;
		RadDmgTimer += dt;
		if(RadiationTimer > RadiationTime) {
			bIrradiated = false;
			RadiationInst = none;
//			TakeDamage(2, RadiationInst, Location, vect(0, 0, 0), BurnDamageType);
		}
//		else {
//			if(RadDmgTimer > 2) {
//				RadDmgTimer -= 2;
//				log("Radiation Damage from "$RadiationInst);
//				TakeDamage(2, RadiationInst, Location, vect(0, 0, 0), BurnDamageType);
//			}
//		}
	}
	
    if( (PotentialVehicle != None) && Controller != None && Controller.IsA('VehiclePlayer') && (PotentialVehicle.GetPlayerVehicleAction(self) == PVA_None) )
    {
        PotentialVehicle = None;
    }	
	
    if( (PotentialTurret != None) && !PotentialTurret.CanEnter(self) )
    {
        PotentialTurret = None;
    }
    
	AutoHeal(dt);
}

simulated event int GetRiderYaw()
{
	local rotator rfinal;//, zero;
	if(RiddenVehicle==None)
	{
		return 0;
	}
	else
	{
		if(RiddenVehicle.IsGunnerSpot[RiddenVehicleSpot]==1 && RiddenVehicle.PassengerCameras[RiddenVehicleSpot].bUse3rdPerson )
		{
			return 0;
		}
		else if(RiddenVehicle.PassengerCameras[RiddenVehicleSpot].bLimitYaw)  // must be a first person non-gunner passenger, let them have their proper rotation.
		{
			rfinal.yaw = RiddenVehicle.PassengerCameras[RiddenVehicleSpot].CenterYaw;
			return rfinal.yaw;
		}
	}

	return 0;
}


//simulated function FaceRotation( rotator NewRotation, float DeltaTime )
//{
//	local rotator rfinal, zero;
//
//	log(self@"XXXX"@Controller.bIsRidingVehicle@Controller.bUseRiderCamera);
//
//}

simulated function Poison(Pawn PInstigator, int PoisonDamage, optional float PoisonDuration)
{
	PoisonAmmount=PoisonDamage;
	bPoisoned = true;
	NextPoisonTime = Level.TimeSeconds;
	if(PInstigator.IsA('Pawn'))
		PoisonInstigator = PInstigator;
	if(PoisonDuration > 0.0)
			PoisonEndTime = Level.TimeSeconds + PoisonDuration;
	else
		PoisonEndTime = 0.0;
}

simulated function InfraFlash()
{
	//Make pawn flash somehow...
	//log("XJ"@self@"is flashing.");
}

function bool GiveHealth(int HealAmmount, int HealMax)
{
	if(bIrradiated)
		// no healing whilst irradiated
		return false;

	return Super.GiveHealth(HealAmmount, HealMax);
}

function vector CameraShake()
{
		local vector x, y, z, shakevect;
		local VehiclePlayer pc;

		pc = VehiclePlayer(Controller);

		if (pc == None)
				return shakevect;

		GetAxes(pc.Rotation, x, y, z);

	//The new camera shake uses a mass-spring-damper model
	if( pc.bNewCamShake )
	{
		shakevect = pc.RandomShakePosition.X * x +
					pc.RandomShakePosition.Y * y +
					pc.RandomShakePosition.Z * z +
					pc.Vertical_cam_spring.spring_p * z;
	}
	else
	{
		shakevect = pc.RandomShakePosition.X * x +
					pc.RandomShakePosition.Y * y +
					pc.RandomShakePosition.Z * z +
					pc.ShakeOffset.X * x +
					pc.ShakeOffset.Y * y +
					pc.ShakeOffset.Z * z;
	}

	//log("VGPawn:  shakevect = "$shakevect$" (bJustLanded = "$bJustLanded$")");

		return shakevect;
}

simulated function PostBeginPlay()
{
	SetHavokCharacterCollisions( UseHavokCharacterCollision() );
	Super.PostBeginPlay();
}

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
//	if( (Level.Game == none || Level.Game.bTeamGame) && IsHumanControlled() ) {
//		bDelayDied = true;
//		bRagdollCorpses = false;
//	}
}

function bool UseHavokCharacterCollision()
{
	return default.bHavokCharacterCollisions && Level.NetMode == NM_Standalone;
}

event bool EncroachingOn(Actor Other)
{
	if(Physics == PHYS_KarmaRagDoll && Other!=None && Other.Physics == PHYS_Karma)
		return True;

	return Super.EncroachingOn(Other);
}


event bool HavokCharacterCollision(HavokCharacterObjectInteractionEvent data, out HavokCharacterObjectInteractionResult res)
{
	local Vector vDiff, vDir;
	local Vector hDir, pDir;
	local bool bCanCrushMe;
	local float CrushSpeed;

	if( data.body.IsA('HavokActor') && HavokActor(data.body).bCanCrushPawns )
	{
		bCanCrushMe = true;
		CrushSpeed = HavokActor(data.body).CrushSpeed;
	}
	else if( data.body.IsA('GameplayDevices') && GameplayDevices(data.body).bCanCrushPawns )
	{
		bCanCrushMe = true;
		CrushSpeed = GameplayDevices(data.body).CrushSpeed;
	}

	if ( bCanCrushMe )
	{
		//log(self@"Was hit by havok object "$data.body);


		hDir = Normal(data.Body.Velocity);
		pDir = data.Body.Location - Location;


		if( hDir dot pDir < 0  &&  VSize(data.Body.Velocity) > CrushSpeed)
		{
			PlayOwnedSound(Sound'HavokObjectSounds.BodyImpactRandom', SLOT_Pain, 1.0);
			NeedToDieVelocity = data.Body.Velocity;
			bNeedToDie=true;
			res.ObjectImpulse=Vect(0,0,0);
			return true;
		}
	}

	//desired behavior:  Player should NEVER cause a vehicle to stop its movement, nor influence it.
	//any impulse at all would be dangerous, since this would happen every frame.
	if(data.body.IsA('VGVehicle') || data.body.IsA('DropShipCargo') || data.body.IsA('DropShipCargoDoor') )
	{
		res.ObjectImpulse=Vect(0,0,0);
		res.ImpulsePosition=Vect(0,0,0);

		vDir = (data.body.Velocity);
		vDiff = Normal(Location - data.body.Location);

		res.CharacterImpulse = (vDir dot vDiff) * vDiff;
	}
	else
	{
		res.ObjectImpulse *= InterpCurveEval( HavokObjectImpulseScale, data.ObjectMass );
	}

	return true;
}

simulated function SetRunningAnims(optional RunAnimStyle ras)
{
	switch(ras)
	{
	case RAS_NormalGun:
		MovementAnims[0]='RunF';
		MovementAnims[1]='RunB';
		MovementAnims[2]='RunL';
		MovementAnims[3]='RunR';
		break;
	case RAS_BigGun:
		MovementAnims[0]='RunF_RL';
		MovementAnims[1]='RunB_RL';
		MovementAnims[2]='RunL_RL';
		MovementAnims[3]='RunR_RL';
		break;

	case RAS_SingleHand:
		MovementAnims[0]='RunF';
		MovementAnims[1]='RunB';
		MovementAnims[2]='RunL';
		MovementAnims[3]='RunR';
		break;
	case RAS_Default:
		MovementAnims[0]='RunF';
		MovementAnims[1]='RunB';
		MovementAnims[2]='RunL';
		MovementAnims[3]='RunR';
		break;
	}

}

simulated function SetVGWeaponAttachment(VGWeaponAttachment NewAtt)
{
	//log("setvgweaponattachment called for "$self$" with "$NewAtt);

		VGWeaponAttachment = NewAtt;
	switch(VGWeaponAttachment.WeaponType)
	{
	case EWT_HealingTool:
		IdleWeaponAnim = HealingToolIdleAnim;
		HitAnims[0]='Hit01_Healing_Tool';
		HitAnims[1]='Hit02_Healing_Tool';
		SetRunningAnims(RAS_SingleHand);
		break;
	case EWT_BoneSaw:
		IdleWeaponAnim = BoneSawIdleAnim;
		HitAnims[0]='Hit01_Healing_Tool';
		HitAnims[1]='Hit02_Healing_Tool';
		SetRunningAnims(RAS_SingleHand);
		break;
	case EWT_FragRifle:
		IdleWeaponAnim = FragRifleIdleAnim;
		HitAnims[0]='Hit01_Plasma';
		HitAnims[1]='Hit02_Plasma';
		SetRunningAnims(RAS_NormalGun);
		break;
	case EWT_GrenadeLauncher:
		IdleWeaponAnim = GrenadeLauncherIdleAnim;
		HitAnims[0]='Hit01_Plasma';
		HitAnims[1]='Hit02_Plasma';
		SetRunningAnims(RAS_NormalGun);
		break;
	case EWT_PlasmaGun:
		IdleWeaponAnim = PlasmaGunIdleAnim;
		HitAnims[0]='Hit01_Plasma';
		HitAnims[1]='Hit02_Plasma';
		SetRunningAnims(RAS_NormalGun);
		break;
	case EWT_TitansFist:
		IdleWeaponAnim = TitansFistIdleAnim;
		HitAnims[0]='Hit01_Rocket';
		HitAnims[1]='Hit02_Rocket';
		SetRunningAnims(RAS_BigGun);
		break;
	case EWT_RocketLauncher:
		IdleWeaponAnim = RocketLauncherIdleAnim;
		HitAnims[0]='Hit01_Rocket';
		HitAnims[1]='Hit02_Rocket';
		SetRunningAnims(RAS_BigGun);
		break;
	case EWT_Bulldog:
		IdleWeaponAnim = BulldogIdleAnim;
		HitAnims[0]='Hit01_Bulldog';
		HitAnims[1]='Hit02_Bulldog';
		SetRunningAnims(RAS_NormalGun);
		break;
	case EWT_SniperRifle:
		IdleWeaponAnim = SniperIdleAnim;
		HitAnims[0]='Hit01_Bulldog';
		HitAnims[1]='Hit02_Bulldog';
		SetRunningAnims(RAS_NormalGun);
		break;
	case EWT_None:
		HitAnims[0]='';
		HitAnims[1]='';
		IdleWeaponAnim='';
		SetRunningAnims();
		break;
	default:
		HitAnims[0]='Hit01_Plasma';
		HitAnims[1]='Hit02_Plasma';

		if (VGWeaponAttachment.bHeavy)
			IdleWeaponAnim = IdleHeavyAnim;
		else
			IdleWeaponAnim = IdleRifleAnim;
		SetRunningAnims();

		break;
	}

}

function Bump(Actor Other)
{
    local VGVehicle Vehicle;
    local PlayerTurret Turret;
    
    local CarBot CB;
    local PlayerController PC;

	if(Other == None)
	{
	    return;
	}
	
	Vehicle = VGVehicle( Other );
	Turret = PlayerTurret( Other );
    CB = CarBot( Controller );
    PC = PlayerController( Controller );

	if( Vehicle != None )
	{
		PotentialVehicle = Vehicle;

		if( CB != None )
			CB.NotifyEnterVehicle( PotentialVehicle );

		// This looks to be where we need to set other pawns on fire if the vehicle is burning
		// since Touch doesn't seem to get triggered when running into a vehicle...
		
		if( Vehicle.bOnFire && !bOnFire )
			SetOnFire();

		if( (PC != None) && (PC.myHUD != None) )
		{
		    PC.myHUD.LocalizedMessage( class'VehicleMessage', 0, None, None, PC );
		}
	}
	
	if( Turret != None )
	{
	    PotentialTurret = Turret;

		if( (PC != None) && (PC.myHUD != None) )
		{
		    PC.myHUD.LocalizedMessage( class'VehicleMessage', 0, None, None, PC );
		}
	}
}

function JumpOffVehicle()
{
	//cmr make sure the random vector is completely sideways so it always pushes you off 
	//(conceivably, a random vector with z zeroed out could push you almost not at all in a horizontal direction)
	local vector v;
	v = Normal( Location - Base.Location );

	Velocity += (100 + CollisionRadius) * v;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	if ( Controller != None )
	{
		Controller.SetFall();
	}
}

singular event BaseChange()
{
	local Pawn P;

	if ( bInterpolating || bDriver )
		return;

	P = Pawn(Base);

	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if ( P != None && ( !P.IsA('VGVehicle') || Physics == PHYS_Falling || Physics == PHYS_Walking ) ) //filter out vehicles so this doesn't shortcircuit the next if statement.
	{
		if ( !P.bCanBeBaseForPawns)
		{
			JumpOffPawn();
		}
		else if ( Physics == PHYS_Falling || Physics == PHYS_Walking )
		{
			JumpOffVehicle();
		}
	}


	if(Base!=None && Base!=RiddenVehicle && Controller!=None && Controller.bIsRidingVehicle==True)
	{
		if(Role==ROLE_Authority)
		{
			log("CHARLES: DROPPED OFF VEHICLE RIDE");

			if(Role==ROLE_Authority) {
				RiddenVehicle.EndRide(self);

				if(Controller.IsA('VehiclePlayer') ) {
					VehiclePlayer(Controller).bUse3rdPersonCam = false;
					VehiclePlayer(Controller).bBehindView = false;
				}
			}
		}
		//SetPhysics(PHYS_Falling);
		//SetBase(None);
		Controller.bIsRidingVehicle=False;

		if( DriveController(Controller) != None)
				DriveController(Controller).EndRiding();

	}

}


function RideVehicleDebug(  )
{
	log("CHARLES: RideVehicleDebug called");
	if(PotentialVehicle != None)
	{
		PotentialVehicle.TryToRide(self);
		PotentialVehicle = None;
	}
}

function bool CanRide()
{
    local VehiclePlayer VP;
    
    VP = VehiclePlayer(Controller);
    
	if( (VP != None) && VP.bStartInVehicle )
	    return true;

	if( !( Level.Game.bTeamGame==True &&
			PotentialVehicle.bIsDriven &&
			PotentialVehicle.Controller.PlayerReplicationInfo.Team.TeamIndex != Controller.PlayerReplicationInfo.Team.TeamIndex)
		&& (VSize( PotentialVehicle.Location - Location ) < PotentialVehicle.MaxEnterDistance) )
		return True;
	else
		return False;

}

simulated event bool PassengerSameTeam()
{
    local int n;
	
	if(Level.NetMode == NM_Standalone && Level.Game.bSinglePlayer) //do the single player check
	{
		for(n = 0; n < PotentialVehicle.PassengerPointCount; n++) 
		{
			if(PotentialVehicle.PassengerPointsUsed[n] == 1) 
			{
				if(!PotentialVehicle.Passengers[n].Controller.SameTeamAs(Controller))
					return false;
			}
		}
	}
	else //mp
	{
		for(n = 0; n < PotentialVehicle.PassengerPointCount; n++) 
		{
			if(PotentialVehicle.PassengerPointsUsed[n] == 1) 
			{
				if(PlayerReplicationInfo.Team == None || PotentialVehicle.Passengers[n].PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)
					return false;
			}
		}
	}


	return true;
}

function bool CanDrive()
{
	
	if(!PassengerSameTeam()) return false;

	if(VSize( PotentialVehicle.Location - Location ) < PotentialVehicle.MaxEnterDistance && PotentialVehicle.bIsDriven==False)
		return True;
	else
		return False;
}

function EnterVehicleWorker( string AltCmd )
{
	local bool bTryToDrive;
	local int index,dindex;
	local float driverdist,passengerdist;
	local VehiclePlayer VP;

	bTryToDrive = False;
	
	VP = VehiclePlayer(Controller);

	if(PotentialVehicle != None && PotentialVehicle.Health > 0)
	{

		dindex = PotentialVehicle.GetClosestDrivePointDist(Location,driverdist);

			index = PotentialVehicle.GetClosestPassengerPoint(Location, passengerdist);

		//log("Driverdist "$driverdist$" passenger: "$passengerdist);

		if ( PotentialVehicle.InvertedTime > 0 )
		{
			PotentialVehicle.StartFlip();
		}
		else
		{
            // jjs - ch5 shove player in vehicle regardless
            if( (VP != None) && VP.bStartInVehicle )
            {
				PotentialVehicle.TryToRide(self, true);
				PotentialVehicle = None;
				bTryToDrive = True;
            }
			// see if we are close enough
			else if( index != -1 && passengerdist < driverdist )
			{
				if( CanRide() )
				{
					EndDash();
					PotentialVehicle.TryToRide(self);
					PotentialVehicle = None;
					bTryToDrive = True;
				}
			}
			else
			{

				// see if we are close enough
				if( CanDrive() )
				{
					EndDash();
					PotentialVehicle.TryToDrive(self, dindex);
					PotentialVehicle = None;
					bTryToDrive = True;
				}
			}
		}
	}
	if(PotentialTurret != none && !bTryToDrive && VSize(Location-PotentialTurret.Location) < PotentialTurret.MaxEnterDistance) {
		// try to get into a turret, but only if it's not already occupied
		if(PotentialTurret.PawnGunner == none) {
			// nobody on board
			EndDash();
			PotentialTurret.TryToEnter(self);
			PotentialTurret = none;
			bTryToDrive = true;
		}
	}

	if ( !bTryToDrive && Len( AltCmd ) > 0 )
	{
		Controller.ConsoleCommand( AltCmd );
	}
}

exec function EnterVehicle()
{
//	log("EnterVehicle");
	EnterVehicleWorker("");
	if(RiddenVehicle != none && Role < ROLE_Authority) {
		// set up ridding parameters for client and so forth
		RiddenVehicle.ClientSetRide(self);
//		log("Riding vehicle");
	}
	if(DrivenVehicle != none) {
//		log("Driving vehicle");
	}
	if(RiddenTurret != none && Role < ROLE_Authority) {
		RiddenTurret.ClientSetRide(self);
	}
}

// jjs - force player into nearest vehicle - for chapter05
exec function EnterNearestVehicle()
{
		local VGVehicle ride;
		if(FindRide(ride, true))
		{
				PotentialVehicle = ride;
				EnterVehicle();
		}
}

exec function RideVehicle()
{
	log("CHARLES: RideVehicle called");
	RideVehicleDebug();
}

exec function EnterVehicleOr( string AltCmd )
{
//	log("EnterVehicleOr");
	EnterVehicleWorker( AltCmd );
	if(RiddenVehicle != none && Role < ROLE_Authority) {
		// set up ridding parameters for client and so forth
		RiddenVehicle.ClientSetRide(self);
//		log("Riding vehicle");
	}
	if(RiddenTurret != none && Role < ROLE_Authority) {
		RiddenTurret.ClientSetRide(self);
	}
}

function bool FindRide(out VGVehicle ride, optional bool bSkipTeam) //used for teleporting
{
	local VGVehicle v;
	local array<VGVehicle> vs;
	local float dist, neardist;
	local int i;



	ForEach AllActors(class'VGVehicle', v)
	{
		if(v.FreePassengerPoint() &&
		   ((v.bIsDriven && v.Controller.PlayerReplicationInfo.Team.TeamIndex == Controller.PlayerReplicationInfo.Team.TeamIndex) || bSkipTeam))
		{
			vs[vs.Length]=v;
		}
	}

	if(vs.Length == 0)
		return False;
	else if(vs.Length == 1)
	{
		ride = vs[0];
		return True;
	}
	else //pick the closest
	{
		v=None;
		neardist=10000000;

		for(i=0;i<vs.Length;i++)
		{
			dist = VSize(vs[i].Location - Location);
			if(dist < neardist)
			{
				v = vs[i];
				neardist=dist;
			}
		}
		assert(v!=None);

		ride=v;
		return True;
	}




	return False;
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
 	/*
	local UTTeleportEffect PTE;

	if ( IsHumanControlled() )
		PlayerController(Controller).SetFOVAngle(135);
	if ( bSound )
	{
 		PTE = Spawn(class'UTTeleportEffect');
 		PTE.Initialize(self, bOut);
		PlaySound(sound'Resp2A',, 10.0);
	} */
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int OrigHealth,AdjustedDamage;
    local vector HitLoc;

	OrigHealth = Health;
	
	bPlayedHealthUp = false;
	LastDamaged = Level.TimeSeconds;
	
	if(RiddenVehicle!=None && RiddenVehicle.GetStateName() != 'DelayingDeath' && RiddenVehicle.GetStateName() != 'VehicleDying') //take half damage when riding a vehicle
	{
        // jjs - chapter5 hack to make players invulnerable while in bogie
        if(VehiclePlayer(Controller) != None && VehiclePlayer(Controller).bInSpecialVehicleScene && RiddenVehicle.Health > 0 )
        {
            AdjustedDamage = 0;
        }
        else
        {
		    AdjustedDamage = Damage/2;
		    //make sure it doesn't stop all damage
		    if(Damage > 0 && AdjustedDamage==0)
		    {
			    AdjustedDamage=1;
		    }
        }
	}
	else
		AdjustedDamage = Damage;

	// Location is in world space and HitLoc is local space.
    HitLoc = hitlocation - Location;
	if( instigatedBy != None && damageType.default.bLocationalHit && ( HitLoc.Z > (0.6 * CollisionHeight) || Damage > 70 ) )
	{
		CheckHelmetHit(DamageType,Damage);
	}
	
	Super.TakeDamage(AdjustedDamage, instigatedBy, hitlocation, momentum, damageType, ProjOwner, bSplashDamage);


}

// Lame attempt at locational damage.  Calculates the rotational adjustments based on where you are hit and the % of the full
// damage you receive.

function CalcHitAdjust(int DamagePct, class<DamageType> damageType, vector HitLoc, out vector KickAdjust)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotx, doty;

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;

	dotx = HitVec2D dot X;
	doty = HitVec dot Y;

	// Check for an upper body shot

	if ( HitLoc.Z - Location.Z > 0.5 * CollisionHeight )
	{
		if (dotx> 0.31) 	// Front side of body
		{
			KickAdjust.Z = damageType.default.DamageKick.Z * DamagePct;
		}
		else if (dotx < -0.31)	// Back side of body
		{
			KickAdjust.Z = (damageType.default.DamageKick.Z * DamagePct) * -1;
		}
		else
			KickAdjust.Z = 0;
	}
	else	// Lower shot
	{
		if (dotx> 0.31) 	// Front side of body
		{
			KickAdjust.Z = (damageType.default.DamageKick.Z * DamagePct) * -1;
		}
		else if (dotx < -0.31)
		{
			KickAdjust.Z = damageType.default.DamageKick.Z * DamagePct;
		}
		else
			KickAdjust.Z = 0;
	}

	// Process Left/Right

	if (doty > 0.0)
	{
		KickAdjust.X = damageType.default.DamageKick.X;
	}
	else
	{
		KickAdjust.X = (damageType.default.DamageKick.X)*-1;
	}

	KickADjust.Y = 0;	// Never roll

}

function float MovetoZero(float step, float Value)
{
	if (Value<0)
	{
		Value += Step;
		if (Value<0)
			return Value;
		else
			return 0;
	}
	else if (Value>0)
	{
		Value -= Step;
		if (Value>0)
			return Value;
		else
			return 0;
	}
}

// Notify called when ready to land (should loop)
function CheckLanding()
{
	if ( Physics == PHYS_Falling )
	{
		// stop animating, haven't landed yet
		TweenAnim('Jump_Land', 9000.0);
	}
}

// spawn gibs (local, not replicated)
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation,optional Pawn Killer, optional vector HitLocation)
{
	local Gibs gibs;

	return;


	if(Killer!=None && Killer.IsA('VGVehicle'))
	{
		gibs=Spawn(class'Gibs',,,Location,Rotation);

		gibs.SpawnGibs(Killer.Velocity);
	}
	else
	{
		Super.SpawnGibs(HitRotation, ChunkPerterbation, Killer, HitLocation);
	}
}

simulated function vector EyePosition()
{
	return EyeHeight * vect(0,0,1) + WalkBob;
}

function InitializeRagdollDeathImpulse( class<DamageType> DamageType, vector HitLoc )
{
	local HavokSkeletalSystem hskel;

	if ( ClassIsChildOf( DamageType, class'RunOver' ) )
	{
		hskel = HavokSkeletalSystem(HParams);

		hskel.StartLinVel = RunOverVelocity * RagdollRunOverVelocityTransfer;
		hskel.StartLinVel.Z += RagdollRunOverLift;
		hskel.StartAngVel = vect(0,0,0);
		`log( "RJ: Initializing ragdoll to lv="$hskel.StartLinVel$",av="$hskel.StartAngVel$" after run over with velocity "$RunOverVelocity );
	}
	else
	{
		Super.InitializeRagdollDeathImpulse( DamageType, HitLoc );
	}
}

event EncroachedBy( actor Other )
{
		if(bNoEncroachHack)
				return;

	if ( VGVehicle(Other) != None && Role == ROLE_Authority)
	{
		// maybe damage should depend on closing velocity
		//
		PlayOwnedSound(Sound'HavokObjectSounds.BodyImpactRandom', SLOT_Pain, 1.0);
		RunOverVelocity = Other.Velocity;
		// `log( "RJ: Hit by vehicle "$Other$" with velocity of "$RunOverVelocity );
		TakeDamage( 100, Pawn(Other), Location, Other.Velocity, class'RunOver' );
	}
	else if ( Pawn(Other) != None )
	{
		gibbedBy(Other);
	}
}

simulated function ChunkUp(Rotator HitRotation, float ChunkPerterbation, optional Controller Killer, optional vector HitLocation)
{
	if(Physics == PHYS_KarmaRagDoll)
		return;
	else Super.ChunkUp(HitRotation, ChunkPerterbation, Killer, HitLocation);
}

// will drop the wecs from the highest level weapon
function DropWEC(Controller Killer)
{
    local float ratio;
	local VehiclePickup tempPickup;
	local class<VehiclePickup> tempPickupClass;
	
	if(Killer == Controller || Controller.SameTeamAs(Killer))
	{
	    return; // don't drop WECs if you've killed yourself
	}
	
	if(Level.Game != None && Level.Game.bSinglePlayer)
	{
	    return;
	}
	
	ratio = FMax(1,PlayerReplicationInfo.Score) / FMax(1,Killer.PlayerReplicationInfo.Score);
	ratio = FMax(0.35, ratio);
	ratio *= 0.5; // MAGIC - drop infrequently!
	
	//log(">>>> Drop ratio:"@ratio);
	if(FRand() > ratio)
	{
        DropEnergy(Killer); // drop ammo pack if not dropping a WEC
	    return;
	}
	
	tempPickupClass = class<VehiclePickup>(DynamicLoadObject("VehiclePickups.PickupWECRed", class'Class'));
	tempPickup = spawn(tempPickupClass,,,Location,rot(0,0,0));
	tempPickup.bPickupOnce = true;
	tempPickup.InitDroppedPickupFor(None);
}

// will drop the energy from the highest level weapon
function DropEnergy(Controller Killer)
{
	local Inventory Inv;
	local int LastWeaponEnergy;
	local PersonalWeapon PW;

	LastWeaponEnergy = 0;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if(Inv.IsA('PersonalWeapon'))
		{
			if(LastWeaponEnergy <= PersonalWeapon(Inv).Ammo[0].AmmoAmount) {
				PW = PersonalWeapon(Inv);
				LastWeaponEnergy = PW.Ammo[0].AmmoAmount;
			}
		}
	}

//	log("PW = "$PW);
	if(PW != none) // && Level.Game != none && Level.Game.bSinglePlayer)
		PW.DropEnergy(Killer);
}

simulated function StopBlur()
{
	local MotionBlurPostFXStage	mbe;

	if ( bMotionBlurred )
	{
		bMotionBlurred = False;

		mbe = class'MotionBlurPostFXStage'.static.GetMotionBlurPostFXStage( Level );
		mbe.PopMotionBlurState();	// restore old state
	}
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if(bDelayDied && !IsInPain() ) {
		TearOffMomentum = vect(0, 0, 0);
	}

	Super.PlayDying(DamageType,HitLoc);

	if(OwnedVehicle!=None)
	{
		OwnedVehicle.SetPlayerOwner(None);
	}

	StopBlur();
	SetHavokCharacterCollisions( false );	// shut off any havok-character collision
	KillSurfaceEmitters( True );
}

function DropHealth(Controller Killer) // sjs
{
		local float healthProb;
	local VehiclePickup tempPickup;
	local class<VehiclePickup> tempPickupClass;

		if( Killer == None )
		{
				return;
		}

		healthProb = 0.2;

		if(Killer.Pawn != None && Killer.Pawn.Health < 20)
		{
				healthProb *= 2.0;
		}
		if(Killer.Pawn != None && Killer.Pawn.Health < 5)
		{
				healthProb *= 2.0;
		}

		if(FRand() > healthProb)
		{
				return;
		}

		tempPickupClass = class<VehiclePickup>(DynamicLoadObject("VehicleWeapons.HealingToolPickup", class'Class'));
		tempPickup = Spawn(tempPickupClass,,,Location, rot(0, 0, 0) );
		tempPickup.bPickupOnce = true;
		tempPickup.InitDroppedPickupFor(None);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Vector TossVel;

	if(RiddenVehicle != none) {
		log("Stopping riding "$RiddenVehicle$" due to sudden cessation of existence");
		RiddenVehicle.EndRide(self);
	}
	if(RiddenTurret != none) {
		RiddenTurret.EndRide(self);
	}

	if(Level.NetMode != NM_Client && Level.Game != None && !Level.Game.IsA('SinglePlayer'))
	{
        DropWEC(Killer);
	}

	if(!bDropNothingOnDeath)
	{
		if(Level.Game != None && Level.Game.IsA('SinglePlayer') )
		{
			// sjs - toss weapon instead of energy
			if (Weapon != None)
			{
				Weapon.bCanThrow = true;
				Weapon.HolderDied();
				TossVel = Vector(GetViewRotation());
				TossVel = TossVel * ((Velocity Dot TossVel) + 100) + Vect(0,0,200);
				TossWeapon(TossVel);
			}
			DropHealth(Killer);
		}
		else
		{
			//DropEnergy(Killer);
		}
	}

	StopBlur();
	SetHavokCharacterCollisions( false );	// shut off any havok-character collision
	KillSurfaceEmitters( True );

	Super.Died( Killer, damageType, HitLocation);
}

function bool CanSplash()
{
	if ( (Level.TimeSeconds - SplashTime > 0.25) && (Abs(Velocity.Z) > 10) )
	{
		SplashTime = Level.TimeSeconds;
		return true;
	}
	return false;
}

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;
/*
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		if(bPlayedDeath && Physics == PHYS_KarmaRagdoll) // sjs
		{
			//log("HIT RAGDOLL. M:"$Momentum);
			KAddImpulse(10000*Normal(Momentum), HitLocation);
			return;
		}
		Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType, ProjOwner, bSplashDamage );
	}
*/

}

// irradiate the pawn
simulated function Irradiate()
{
	log("Irradiated!");
	bIrradiated = true;
	RadiationTimer = 0;
	RadDmgTimer = 0;
}

// burninate this pawn
simulated function SetOnFire()
{
//	log("VGRN:  ping!");
	if(!bOnFire) {
//		log("VGP:  SetOnFire; Role = "$Role$", RemoteRole = "$RemoteRole);
		// burn!!
		bOnFire = true;
		Fire = spawn(class'ParticleSmallFire',self,,Location);
		if(Fire != none) {
			burningTime = 0;
			maxBurningTime = 5;
			fireDamagePerInterval = 5;
			lastFireDamageTime = -fireDamageFreq;
			fireDecreaseAt[0] = maxBurningTime;
//			log("VGRN:  Burninating the peasants!");
			//Fire.SetBase(self);
            AttachToBone(Fire,SpineBone2);
	
//			log(": FireInst="$FireInstigator);
//			if(Role == ROLE_Authority)
//				ClientSetOnFire(burningTime, maxBurningTime);
        }
	}
	else if(fireDamagePerInterval < 5) {
		// already on fire, do increased damage
		fireDecreaseAt[fireDamagePerInterval] = burningTime+5.0;
		fireDamagePerInterval += 5;
		maxBurningTime = burningTime+5.0;
//		if(Role < ROLE_Authority)
//			ClientSetOnFire(burningTime, maxBurningTime);
//		log("VGRN:  More Burnination! ("$fireDamagePerInterval$", "$maxBurningTime$")");
	}
}

// go through the pawn's weapons and disable them
simulated function EMPHit(bool bEnhanced)
{
	local Inventory inv;

	for(inv = Inventory; inv != none; inv = inv.Inventory) {
		if(inv.IsA('Weapon') )
			Weapon(inv).EMPHit(bEnhanced);
	}
}


function DelayDied(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if( (Level.Game == none || Level.Game.bTeamGame) && !IsA('Bot') ) {
		bDelayDied = true;

		// we also disallow ragdolling the corpses if in MP
		bRagdollCorpses = false;
	}

	log("VGPawn::DelayDied() called - Killer = "$Killer );
	if(IsInPain() ) {
		bRagdollCorpses = true;
		Died(Killer, damageType, HitLocation);
		return;
	}

	DelayedKiller = Killer;
	DelayedDamageType = damageType;
	DelayedHitLoc = HitLocation;

	Velocity = vect(0, 0, 0);
	Acceleration = vect(0, 0, 0);
	StopAnimating();

	if(Weapon != none)
		Weapon.HolderDied();

	if(damageType.default.bFreezes && !IsHumanControlled() ) {
		// a bot is being frozen
		GotoState('Frozen');
//		if(Controller != none)
//			Controller.GotoState('Frozen');
		return;
	}

	GotoState('DelayingDeath');
	if(Controller != none && Controller.bIsPlayer && IsHumanControlled()) {
		Controller.GotoState('MostlyDead');
		ClientDelayDied();
	}
}

simulated function ClientDelayDied()
{
	// this function has obviously been called because we want to delay death..... make sure variables have been set properly on client
	bDelayDied = true;

	GotoState('DelayingDeath');
	Controller.GotoState('MostlyDead');
	if(Weapon != none)
		Weapon.HolderDied();
}

state DelayingDeath
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	function Landed(vector HitNormal)
	{
	}

	function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	simulated function BeginState()
	{
		local PlayerController PC;

		Health = 0;

		if(Controller != none && PlayerController(Controller) != none) {
			PC = PlayerController(Controller);
			PC.ClientEndZoom();
			PC.bBehindView = true;
			PC.SetViewTarget(self);
			PC.ClientSetViewTarget(self);
		}
//		Controller.SetViewTarget(Pawn);
//	    Controller.ClientSetViewTarget(Pawn);
		bDelayingDeath = true;
		SetTimer(15.0, false);
	}

	simulated function Timer()
	{
		if(PlayerController(Controller) != none)
			PlayerController(Controller).bAutoSpawn = true;

//		log("Role = "$Role);
		if(Role == ROLE_Authority && bDelayingDeath) {
			Died(DelayedKiller, DelayedDamageType, DelayedHitLoc);
			DelayedKiller = none;
			DelayedDamageType = none;
			bDelayingDeath = false;
//			bPlayedDeath = true;
		}
	}
}

state Frozen
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	function Landed(vector HitNormal)
	{
	}

	function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		local IceChunk bit;
		local int n;
		local Vector vel;

		// shatter the frozen bot upon taking damage
		TearOffMomentum = vect(0, 0, 0);
		bRagdollCorpses = false;
		Died(DelayedKiller, DelayedDamageType, DelayedHitLoc);
		DelayedKiller = none;
		DelayedDamageType = none;
		bDelayingDeath = false;
//		Destroy();

		// create some "ice chunks"
		for(n = 0; n < 5; n++) {
			vel.X = RandRange(-100, 100);
			vel.Y = RandRange(-100, 100);
			vel.Z = RandRange(0, 200);

			bit = Spawn(class'VehicleGame.IceChunk',,, Location+vel);
			if(bit != none)
				bit.Velocity = vel;
		}

		Controller.Destroy();
		Destroy();
	}

	simulated function BeginState()
	{
		Health = 0;
		bDelayingDeath = true;
//		log(self$" is frozen solid");
		IdleCrouchAnim = '';
		IdleSwimAnim = '';
		IdleWeaponAnim = '';

		// kill the controller...
		if(Controller != none) {
			Controller.WasKilledBy(DelayedKiller);
			Controller.GotoState('Dead');
		}
	}
}

function DemandRespawn()
{
	if(Role == ROLE_Authority) {// && DelayedKiller != none) {
		if(PlayerController(Controller) != none)
			PlayerController(Controller).bAutoSpawn = true;

		Died(DelayedKiller, DelayedDamageType, Vect(0, 0, 0) );
		DelayedKiller = none;
		DelayedDamageType = none;
	}
}

function Revive(optional Pawn RevivedBy)
{
	ClientRevive();

	DelayedKiller = none;
	DelayedDamageType = none;
	GotoState('');
	Controller.GotoState('PlayerWalking');
	if(PlayerController(Controller) != none) {
		PlayerController(Controller).bAutoSpawn = false;
		PlayerController(Controller).bBehindView = false;
		bDelayingDeath = false;
	}
}

simulated function ClientRevive()
{
	DelayedKiller = none;
	DelayedDamageType = none;
	GotoState('');
	Controller.GotoState('PlayerWalking');
	if(PlayerController(Controller) != none) {
		PlayerController(Controller).bAutoSpawn = false;
		PlayerController(Controller).bBehindView = false;
		bDelayingDeath = false;
	}
}

simulated function ClientVehicleWeaponStuff(Weapon RiderWeapon)
{
	local int n;

//	log("* CVWS * "$RiderWeapon);
	if(RiderWeapon != none) {
		// this vehicle has a rider controlled weapon so place it under the control of the rider
		RiderWeapon.Instigator = self;
//		SavedWeapon = Weapon;
		self.Weapon = RiderWeapon;

		if(RiderWeapon.ThirdPersonActor != none) {
			RiderWeapon.ThirdPersonActor.Instigator = self;
			RiderWeapon.ThirdPersonActor.SetOwner(RiderWeapon);
		}

		// make sure the rider weapon has ammo
		for(n = 0; n < RiderWeapon.NUM_FIRE_MODES; n++) {
			if(RiderWeapon.FireMode[n] != none) {
				RiderWeapon.FireMode[n].Instigator = self;
				RiderWeapon.GiveAmmo(n);
			}
		}

		RiderWeapon.ClientState = WS_ReadyToFire;
		RiderWeapon.GotoState('');
		RiderWeapon.SetOwner(self);
	}
}

simulated function ClientEndRideVehicle(Weapon SaveWeapon)
{
	if(SaveWeapon != none)
    {
		Weapon = SaveWeapon;
		Weapon.AttachToPawn(self);
		Weapon.SetOwner(self);
		SavedWeapon = none;
	}
    Weapon.BringUp();
}

simulated function UpdatePrecacheMaterials()
{
	local int sk;

	Super.UpdatePrecacheMaterials();
	for ( sk = 0; sk < CharacterSkins.Length; sk++ )
	{
		Level.AddPrecacheMaterial( CharacterSkins[sk] );
	}
}

simulated function DoCloaking()
{
//	local int i;
	local Material CloakMaterial;

	if( IsCloaked )
	{
		//Set all skins to the enhanced vision material
		CloakMaterial = Material(DynamicLoadObject("MannyTextures.water.water_distort1", class'Material'));
		SetOverlayMaterial(CloakMaterial, false, 0.0, true, false);
		WeaponAttachment(Weapon.ThirdPersonActor).SetOverlayMaterial( CloakMaterial, false, 0.0, true, false );

		// cloak first person weapon
		CloakMaterial = Material(DynamicLoadObject("PariahWeaponTextures.SniperRifle.SniperCloak01", class'Material') );
		Weapon.SetOverlayMaterial(CloakMaterial, false, 0.0, true, false);

//		log("Cloaking...");
	}
	else
	{
//		Skins.Remove( 0, Skins.Length );
		RemoveOverlayMaterial();
		WeaponAttachment(Weapon.ThirdPersonActor).RemoveOverlayMaterial();
		Weapon.RemoveOverlayMaterial();
//		log("...decloaking");
	}
}

function ToggleCloaking()
{
	IsCloaked = !IsCloaked;
	DoCloaking();
}

function CheckHelmetHit(class<DamageType> DamageType, int Damage)
{
	local float chance;

	chance = RandRange( 0, 100 );

	if ( Helmet == None || HelmetActor == None )
		return;

    // check helmet type for no fall off
    if ( HelmetActor.HelmetType == 2 )
        return;

	if (  Damage > 70 || (HelmetActor.HelmetType == 1) )
		KnockOffHelmet();
	else
	{
		if ( chance < 25 )
			KnockOffHelmet();
	}
}

function KnockOffHelmet()
{
	if ( HelmetActor != None )
	{
		HelmetActor.TornOff();
		HelmetActor = None;
	}
}

function SetHelmet()
{
    if ( Helmet == None )
        return;

	if ( HelmetActor == None )
	{
		HelmetActor = Spawn(HelmetClass,Owner);
		HelmetActor.SetDrawScale(HelmetActor.DrawScale * DrawScale);
	}

	HelmetActor.SetStaticMesh(Helmet);
	AttachToBone(HelmetActor,'bip01 head');
	HelmetActor.SetRelativeLocation(HelmetRelativeLocation);
	HelmetActor.SetRelativeRotation(HelmetRelativeRotation);

}

function bool HasHelmet()
{
    return !(HelmetActor == None);
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	Super.PlayTakeHit(HitLoc,Damage,damageType);
}

defaultproperties
{
     DashSpeed=840.000000
     DashTime=3.000000
     DashRechargeTime=3.000000
     fireDamageFreq=1.000000
     RagdollRunOverLift=512.000000
     RagdollRunOverVelocityTransfer=1.000000
     RadiationTime=30.000000
     jimbox=StaticMesh'BlowoutGeneralMeshes.Engine.jimbox'
     HelmetBone="head"
     HelmetClass=Class'VehicleGame.HelmetAttachment'
     BurnDamageType=Class'VehicleGame.VGBurningDamage'
     HelmetRelativeRotation=(Pitch=49152)
     HavokObjectImpulseScale=(Points=((OutVal=0.125000),(InVal=140.000000,OutVal=0.125000),(InVal=150.000000)))
     bMotionBlurWhileDashing=True
     GibCountCalf=1
     GibCountForearm=1
     GibCountHand=1
     GibCountHead=1
     GibCountTorso=1
     GibCountUpperArm=1
     MultiJumpRemaining=0
     MaxMultiJump=0
     ShieldChargeMax=200.000000
     ShieldStrengthMax=200.000000
     ShieldPenetration=0.250000
     CharTauntAnim="Gesture_Taunt01"
     IdleHeavyAnim="None"
     IdleRifleAnim="None"
     FireHeavyRapidAnim="None"
     FireHeavyBurstAnim="None"
     FireRifleRapidAnim="None"
     FireRifleBurstAnim="None"
     HealingToolFireAnim="HealingTool_Heal"
     FragRifleFireAnim="FragRifle_Fire"
     GrenadeLauncherFireAnim="grenade_fire"
     PlasmaGunFireAnim="Plasma_Fire"
     TitansFistFireAnim="TitansFist_Fire"
     RocketLauncherFireAnim="Rocket_Fire"
     BulldogFireAnim="Bulldog_Fire"
     BoneSawFireAnim="BoneSaw_Fire"
     SniperFireAnim="Sniper_Fire"
     HealingToolIdleAnim="Healing_Tool_Ready"
     FragRifleIdleAnim="FragRifle_Ready"
     GrenadeLauncherIdleAnim="Grenade_Ready"
     PlasmaGunIdleAnim="Plasma_Ready"
     TitansFistIdleAnim="TitansFist_Ready"
     RocketLauncherIdleAnim="Rocket_Ready"
     BulldogIdleAnim="BullDog_Ready"
     BoneSawIdleAnim="BoneSaw_Ready"
     SniperIdleAnim="Sniper_Ready"
     GibGroupClass=Class'VehicleGame.VGGibGroup'
     SoundGroupClass=Class'VehicleGame.PariahSoundGroupMale'
     LeftOffset=(X=10.000000,Y=-40.000000)
     RightOffset=(X=30.000000,Y=20.000000)
     Species=SPECIES_None
     RequiredEquipment(0)="VehicleWeapons.HealingTool"
     RequiredEquipment(1)="VehicleWeapons.BoneSaw"
     LoadOut=1
     HavokCharacterCollisionExtraRadius=20.000000
     GroundSpeed=575.000000
     WaterSpeed=175.000000
     AirSpeed=287.000000
     AccelRate=1024.000000
     JumpZ=500.000000
     WalkingPct=0.500000
     BaseEyeHeight=72.000000
     CrouchRadius=50.000000
     BackwardStrafeBias=0.500000
     DodgeSpeedFactor=1.200000
     AirAnims(0)="Jump_Mid"
     AirAnims(1)="Jump_Mid"
     AirAnims(2)="Jump_Mid"
     AirAnims(3)="Jump_Mid"
     TakeoffAnims(0)="Jump_Mid"
     TakeoffAnims(1)="Jump_Mid"
     TakeoffAnims(2)="Jump_Mid"
     TakeoffAnims(3)="Jump_Mid"
     LandAnims(0)="Jump_Land"
     LandAnims(1)="Jump_Land"
     LandAnims(2)="Jump_Land"
     LandAnims(3)="Jump_Land"
     SlideAnims(0)="WalkF"
     SlideAnims(1)="WalkB"
     SlideAnims(2)="WalkL"
     SlideAnims(3)="WalkR"
     DoubleJumpAnims(0)="JumpF_Takeoff"
     DoubleJumpAnims(1)="Jump_Takeoff"
     DoubleJumpAnims(2)="Jump_Takeoff"
     DoubleJumpAnims(3)="Jump_Takeoff"
     DodgeAnims(0)="RunF"
     DodgeAnims(1)="RunB"
     DodgeAnims(2)="RunL"
     DodgeAnims(3)="RunR"
     TakeoffStillAnim="Jump_Mid"
     IdleWeaponAnim="None"
     SprintAnim="SprintF"
     ControllerClass=Class'VehicleGame.CarBot'
     AutoAimOffset=(Z=35.000000)
     bHavokCharacterCollisions=True
     bUseDriverTurnAnims=True
     bDoStrafeRun=True
     CollisionRadius=50.000000
     CollisionHeight=90.000000
     Mass=25.000000
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Default_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem4
     End Object
     HParams=HavokSkeletalSystem'VehicleGame.HavokSkeletalSystem4'
     bAffectedByEnhancedVision=255
     AmbientGlow=20
     bDisableKarmaEncroacher=True
     bIgnoresPauseTime=True
}
