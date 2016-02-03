/*
	Desc: Drop ship that attacks
	Note:
		- It has 2 thrusters which depend on rotation for sexier motion
		- It has a laser and a dual rocket firing mode
		- It performs the custom physics in performPhysics()
	xmatt
*/

class OffensiveDropShip extends Pawn
	native
	exportstructs
	placeable;

const UNREALGRAVITY = -950.0;
const MAXSHIELDHITS = 4;
const MULTITIMER_TURN = 1111;

//Sounds
const THRUSTER_SOUND_LEVEL		= 0.5;
const THRUSTER_SOUND_RADIUS		= 10000;
const EXPLOSION_SOUND_LEVEL		= 1.0;
const EXPLOSION_SOUND_RADIUS	= 10000;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum ETilt
{
	Tilt_Not,
	Tilt_Down,
	Tilt_Backup
};

enum ERoll
{
	Roll_Not,
	Roll_Start,
	Roll_Hold,
	Roll_End
};

enum EWeapons
{
	DSRockets,
	DSLasers,
	DSNoWeapon
};

struct TTrusterInfo
{
	var bool	active;			//Is it in function
	var bool	bTimed;			//Activated until timer runs out
	var float	thrustTime;		//how long should it be active for
	var float	thrustTimer;
};

struct ShipEmitterDesc
{
	var() name AttachPoint;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

struct TShieldHitParticles
{
	var() Emitter Electricity;
	var() Emitter Distortion;
};

//Postfx
var() DistortionPostFXStage distort;

//Movement
var		bool		bThrusterModel;
var()	float		MaxSpeed;				//maximum speed
var()	float		AeroDynamicResistance;	//the greater the less easily it moves through air (range = [0,1.0])
var		float		BackThrusterAcc;		//acceleration magnitude provided by back thruster
var		float		BottomThrusterAcc;		//acceleration magnitude provided by bottom thruster
var	TTrusterInfo	BackThrusterInfo;
var	TTrusterInfo	BottomThrusterInfo;
var()	name		MovingAreaName;
var	DropShipArea	CoveredArea;
var vector			AreaCenter;
var bool			LeftThrusterOn, RightThrusterOn;
var()	float		SpeedMult_MovingToDrop;
var()	float		AccMult_Approaching;
var()	float		AccMult_MovingToDrop;
var()	float		AccMult_FlyingAround;
var()	float		AccMult_ZoomBy;
var()	float		AccMult_Charging;
var()	float		AccMult_Evading;
var	DropShipArea	MonitoredArea;
var		bool		bDoneTurning;

//Shield
var()	bool		bHasShield;		//This dropship uses a shield
var		bool		bShieldOn;		//Shield is up
var		TShieldHitParticles	ShieldHits[MAXSHIELDHITS];	//List of shield hits
var		int			OlderSlot;		//Which slot of ShieldHits contains the oldest hit shield effect
var()	int			ShieldHealth;

//Health
var()	int			ShipHealth;
var()	int			HealthDropCausingExplosion;
var		int			HealthDrop;

//Zip lines
var		bool				bPreparingToDrop;
var()	name				StageToJoinName;
var		Stage				StageToJoin;
var()	bool				bUsesZipLines;
var		bool				bDroppingPawns;
var		bool				bDetachedPawns;
var		SPPawnZipLineDropper DroppedPawn[4];
var		MiniEdStaticMesh	ZipLine[4];
var		vector				ZipLineFallPoint[4];
var		byte				bDetachedFromZipLine[4];
var		byte				bZipLineBackUp[4];
var		int					ZipLineDropSpeed[4];
var		float				ZipLineHeight[4];
var		float				ZipLineMaxHeight[4];
var()	int					ZipLinesDropSpeed;
var		int					ZipLineDropSpeedVariance;
var		float				ZipLineRiseSpeed;
var()	int					ZipLineStartRiseSpeed;
var()	int					ZipLineRiseAcceleration;
var()	float				ZipLineRiseTimer[4];
var		int					bHitGround[4];
var()	float				UnhookingTime;
var		float				UnhookingTimer[4];

var		StaticMesh				ZipLineMesh;
var		NoiseVertexModifier		ZipLineNoiseTexture;

var		float		DroppingTimer;
var		name		GetReadyToHook;
var		name		HookingAnim;
var		name		DescentAnim;

//Firing
var		float			ContinuousFiringTimer;
var()	float			MaxContinuousFiringTime;
var		float			RocketFireTimer;
var()	float			RocketFireTime;
var()	int				RocketSeekingError;
var		bool			bPanelIsDown;
var		EWeapons		DropShipWeaponsState;


//Rotation
var() int	RotationSpeed;
var()		rotator NewRotation;

//Turning
var			int		StartOrientation;
var			int		DesiredYaw;
var()		float	TurnSpeedFactor;
var			float	TurnTime;
var			float	TurnTimer;
var			bool	TurningCW;

//Tilting
var			int		StartPitch;
var			int		DesiredPitch;
var()		float	TiltSpeedFactor;
var			float	TiltTime;
var			float	TiltTimer;
var			ETilt	TiltState;

//Rolling
var			bool	bWorthRolling;
var			int		RollSpeed;
var			int		MaxRoll;
var			float	RollTimer;
var			ERoll	RollState;

var(Turret) editinline VGDropShipTurret Turret;
var(Turret) vector TurretRelativePosition;

//Emitters
var() editinline Array<ShipEmitterDesc> Emitters;
var() class<Emitter>	SmokeEmitterClass;
var() class<Emitter>	Smoke2EmitterClass;
var() class<Actor>		ExplosionBurstClass;
var() class<Actor>		ExplosionBurst2Class;
var() class<Actor>		SmallExplosionClass;
var array<Actor>		SmallExplosions;
var array<Emitter>		SmokeTrails;
var array<Emitter>		LiveEmitters;
var() vector			SmokeStart;
var() vector			SmokebStart;

//Dying
var bool				bDying;
var float				ShipBlowupTimer;
var() float				ShipBlowupTime;
var bool				bExplosion1Done;
var bool				bExplosion2Done;
var float				Explosion1Time;
var float				Explosion2Time;
var(Events) name		OnDeathEvent;

var		MuzzleFlash				MuzFlash;
var	()	class<MuzzleFlash>		MuzFlashClass;
var	()	class<Actor>			ChunkClass;

var ()	class<DropShipChunks>	SMeshClass[10];
var ()	CollisionStaticMesh		HiddenDropShipCollision;

//Sounds
var	()	sound			EXPLSound;
var	()	sound			EXPL2Sound;
var	()	sound			ShipBlowupSound;
var ()	sound			BackThrusterSound;
var ()	sound			BottomThrusterSound;
var ()	sound			SideThrusterSound;

//debug
var() bool bShowDebug;
var vector StartLocation;

//Rocket Damage Properties
var (Damage) int	VehicleDamage;
var (Damage) int	PersonDamage;
var (Damage) float	SplashDamage;
var (Damage) float	DamageRadius;
var (Damage) float	MomentumTransfer;

//Animations
var Name			Floating;
var Name			LowerPanel;
var Name			Float_PanelDown;
var Name			RaisePanel;


native simulated function ResetTilt( INT desiredPitch, INT Speed );
native simulated function ResetTurn( INT desiredYaw, INT Speed );
native simulated function bool Tilt( FLOAT deltaTime );
native simulated function bool Turn( FLOAT deltaTime );

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	//Place the turret
	Turret = Spawn(class'VGDropShipTurret');

	//This bone needs to be changed once an Artist adds the appropriate bone.
	AttachtoBone( Turret, 'LaserTurret' );

	//The base of the turret must be the ship
	//Turret.SetBase( Self );

	LoopAnim( Floating, , , 0 );
	AnimBlendParams( 0, 1.0 );
	AnimBlendParams( 2, 1.0, , , 'DropDown' );
}


function AttachThis(Actor A, vector offset, rotator rotation)
{
	A.SetBase(self);
	A.SetRelativeLocation(offset);
	A.SetRelativeRotation(rotation);
}


simulated function PostBeginPlay()
{
	local int i;
	local coords ZipLineCoords;
	local vector ZipLinePos;
	local rotator ZipLineRot;
	local coords DropperCoords;
	local vector DropperPos;
	local rotator DropperRot;
	local Stage S;

	Super.PostBeginPlay();
	LiveEmitters[LiveEmitters.Length] = spawn( Emitters[0].EmitterClass, self );
	AttachtoBone(LiveEmitters[0],'PEmitter01');
	LiveEmitters[LiveEmitters.Length] = spawn( Emitters[1].EmitterClass, self );
	AttachtoBone(LiveEmitters[1],'PEmitter02');
	LiveEmitters[LiveEmitters.Length] = spawn( Emitters[2].EmitterClass, self );
	AttachtoBone(LiveEmitters[2],'ThrusterFrontRight');
	LiveEmitters[LiveEmitters.Length] = spawn( Emitters[3].EmitterClass, self );
	AttachtoBone(LiveEmitters[3],'ThrusterFrontLeft');

	//Turn off the thrusters' emitters
	for( i = 0; i < LiveEmitters.length; i++ )
		LiveEmitters[i].Stop();

	StartLocation = Location;

	//Find the moving area it is assigned to
	foreach AllActors( class'DropShipArea', CoveredArea )
	{
		if( MovingAreaName == CoveredArea.Tag )
		{
			MonitoredArea = CoveredArea;
			AreaCenter = CoveredArea.Location;

			//The turret needs to know about the covered area too
			Turret.CoveredArea = CoveredArea;
			break;
		}
		else
			CoveredArea = None;
	}
	if( CoveredArea == None )
		bPaused = true;

	distort = class'DistortionPostFXStage'.static.GetDistortionPostFXStage( Level );

	//Zip lines
	if( bUsesZipLines )
	{
		//Place the zip lines and droppers
		
		ZiplineCoords = GetBoneCoords('zip01');
		ZiplinePos = ZiplineCoords.origin;
		ZiplineRot = GetBoneRotation('zip01');
		DropperCoords = GetBoneCoords('p01');
		DropperPos = DropperCoords.origin;
		DropperRot = GetBoneRotation('p01');
		SetupZipLine( 0, ZiplinePos );
		SetFallPoint( 0, ZiplinePos, DropperPos );
		SetupDroppingPawn( 0, DropperPos, DropperRot );

		ZiplineCoords = GetBoneCoords('zip02');
		ZiplinePos = ZiplineCoords.origin;
		ZiplineRot = GetBoneRotation('zip02');
		DropperCoords = GetBoneCoords('p02');
		DropperPos = DropperCoords.origin;
		DropperRot = GetBoneRotation('p02');
		SetupZipLine( 1, ZiplinePos );
		SetFallPoint( 1, ZiplinePos, DropperPos );
		SetupDroppingPawn( 1, DropperPos, DropperRot );

		ZiplineCoords = GetBoneCoords('zip03');
		ZiplinePos = ZiplineCoords.origin;
		ZiplineRot = GetBoneRotation('zip03');
		DropperCoords = GetBoneCoords('p03');
		DropperPos = DropperCoords.origin;
		DropperRot = GetBoneRotation('p03');
		SetupZipLine( 2, ZiplinePos );
		SetFallPoint( 2, ZiplinePos, DropperPos );
		SetupDroppingPawn( 2, DropperPos, DropperRot );

		ZiplineCoords = GetBoneCoords('zip04');
		ZiplinePos = ZiplineCoords.origin;
		ZiplineRot = GetBoneRotation('zip04');
		DropperCoords = GetBoneCoords('p04');
		DropperPos = DropperCoords.origin;
		DropperRot = GetBoneRotation('p04');
		SetupZipLine( 3, ZiplinePos );
		SetFallPoint( 3, ZiplinePos, DropperPos );
		SetupDroppingPawn( 3, DropperPos, DropperRot );

		DroppedPawn[0].LoopAnim('Idle_Search_Alert', , 1 );
		DroppedPawn[1].LoopAnim('Crouch', , 1 );
		DroppedPawn[2].LoopAnim('Turret_Sit', , 1 );
		DroppedPawn[3].LoopAnim('Crouch', , 1 );

		//Find the stage to join
		//log( "Looking for this stage with tag name: " $ StageToJoinName );
		ForEach AllActors( class'Stage', S )
		{
			if( S.StageName == StageToJoinName )
			{
				StageToJoin = S;
				log( "Droppers found a stage to join: " $ StageToJoinName );
				break;
			}
		}
	}

	HiddenDropShipCollision = Spawn( class'CollisionStaticMesh', Self, , Location, Rotation );
	HiddenDropShipCollision.SetStaticMesh( StaticMesh'PariahDropShipMeshes.ZipLineDropShipMeshes.DropShip_ZipLine' );
	AttachtoBone( HiddenDropShipCollision, 'RootDummy' );
	
	//AttachtoBone( HiddenDropShipCollision, 'MCDCXDropShipBody17' );

	HiddenDropShipCollision.DamageLinkActor = self;

	bPaused = true;
}


simulated function SetFallPoint( int id, vector ZiplinePos, vector DropperPos )
{
	ZipLineFallPoint[id] = ZiplinePos-Location;
	ZipLineFallPoint[id].Z = ZiplinePos.Z - DropperPos.Z;
}


simulated function SetupZipLine( int id, vector ZipLineLoc )
{
	//Spawn zip lines at the four attach points
	ZipLine[id] = Spawn( class'MiniEdStaticMesh', , , ZipLineLoc );

	//The base of the turret must be the ship
	AttachThis( ZipLine[id], ZipLineLoc-Location, rot(0,0,0) );
	ZipLine[id].SetStaticMesh( ZipLineMesh );
	ZipLine[id].SetCollision( false, false, false );
	ZipLine[id].bCollideWorld = false;
	ZipLine[id].bHidden = false;
}


simulated function SetupDroppingPawn( int id, vector Loc, rotator Rot )
{
	local vector L;

	L.z +=50;
	L += Loc;
	DroppedPawn[id] = Spawn( class'SPPawnZipLineDropper', , , L, Rot );

	if( DroppedPawn[id] != None )
		log( "Dropper " $ id $ " spawned correctly" );
	else
		log( "Dropper " $ id $ " spawned IN-correctly" );
	DroppedPawn[id].SetPhysics( Phys_None );
	DroppedPawn[id].SetCollision( false, false, false );
	DroppedPawn[id].bBlockNonZeroExtentTraces = false;
	DroppedPawn[id].bBlockZeroExtentTraces = false;
	DroppedPawn[id].bCollideWorld = false;
	AttachThis( DroppedPawn[id], Loc-Location, Rot );
	DroppedPawn[id].Controller.ClientSwitchToBestWeapon();
}


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent )
{
	Super.TriggerEx( sender, instigator, handler, realevent );

	switch( handler )
	{
	case 'StartMoving':
		log( "** StartMoving **" );
		bPaused = false;
		GoToState('Approaching'); //watch out
		break;

	case 'DropGuys':
		log("DropGuys was Triggered");
		if( bUsesZipLines )
		{
			bPaused = false;
			GoToState('PreparingToDropPawns');
		}
		break;
	}
}


simulated function Reset()
{
	local int i;
	//log("---RESET---");
	TiltState = Tilt_Not;

	BackThrusterInfo.active = false;
	BackThrusterAcc = 0;
	BackThrusterInfo.thrustTime = 0;

	BottomThrusterInfo.active = false;
	BottomThrusterAcc = 0;
	BottomThrusterInfo.thrustTime = 0;

	//Turn off the thrusters' emitters
	for( i = 0; i < LiveEmitters.length; i++ )
		LiveEmitters[i].Stop();

	NewRotation = rot(0,0,0);
	SetRotation( rot(0,0,0) );
	SetLocation( StartLocation );
	Velocity = vect(0,0,0);
}


//-----------------------------------------------------------------------
//							STATES
//-----------------------------------------------------------------------
//watch out
state Approaching
{
	simulated function BeginState()
	{
		local rotator TowardsMarker;

		//log("_________________");
		//log("BEGIN Approaching");

		//Turn off back thruster to turn
		TurnOffBackThruster();

		//Choose a desired orientation
		TowardsMarker = Rotator( AreaCenter - Location );
		ResetTurn( (TowardsMarker.Yaw & 65535), 1000 );
		SetTimer(1.0,true);
		TurnOnBottomThruster( -UNREALGRAVITY, false );
	}
	simulated function Tick(float dt)
	{
		Global.Tick(dt);
		UpdateThrusters( dt );

		//If done turning go forward
		if( Turn(dt) )
		{
			if( !BackThrusterInfo.active )
			{
				//When done turning go towards the area
				TurnOnBackThruster( AccMult_Approaching*400, false );
			}
		}
	}
	function Timer()
	{
		local vector XYDist;
		if( BackThrusterInfo.active )
		{
			XYDist = AreaCenter - Location;
			XYDist.Z = 0;
			if( VSize(XYDist) < CoveredArea.Radius )
			{
				GoToState('FlyingAround');
			}
		}
	}
	function EndState()
	{
		//log("End Approaching");
	}
}


state FlyingAround
{
	simulated function BeginState()
	{
		//log("__________________");
		//log("BEGIN FlyingAround");

		//Use the bottom thruster to break the freefall
		TurnOffBackThruster();

		SetTimer(4.0,false);
	}
	simulated function Tick(float dt)
	{
		Global.Tick(dt);

		UpdateThrusters( dt );

		//If the thruster is off it's turning so turn
		if( BackThrusterInfo.active == false && Turn(dt) )
		{
			//When done turning turn on the back thruster
			TurnOnBackThruster( AccMult_FlyingAround*400.0, true, 8.0 );
			SetTimer(3.0,false);
		}
	}
	function Timer()
	{
		local rotator TowardsMarker;
		local vector DistFromCenter2D;
		local float AngleLimitFactor;
		local int PickedOrientation;
		local int ShiftInYaw;

		//Only change the orientation when it's not already changing,
		//which happens when the back thruster is off
		if( BackThrusterInfo.active == false )
			return;

		//If a pawn showed up in the monitoring area change state
		if( MonitoredArea.AnEnemyIsIn() )
			GoToState('Attacking');

		//Choose between three angles
		//Note: the farther the ship is from the center, the more it will point towards it,
		//		that way when it is closer to the perimeter, it attempts to stay within the circle
		TowardsMarker = Rotator( AreaCenter - Location );
		DistFromCenter2D = AreaCenter - Location;
		DistFromCenter2D.Z = 0;
		AngleLimitFactor = FClamp( -VSize(DistFromCenter2D) / CoveredArea.Radius + 1.0, 0.0, 1.0 );
		ShiftInYaw = 16384 * (2.0*FRand()-1.0) * AngleLimitFactor;
		PickedOrientation = (((TowardsMarker.Yaw & 65535) + ShiftInYaw)) & 65535;

		ResetTurn( PickedOrientation, 1000 );
		TurnOffBackThruster();
	}
	function EndState()
	{
		//log("FlyingAround - Endstate");
	}
}


state PreparingToAttack
{
	function BeginState()
	{
		local vector TowardsTarget;
		local rotator TowardsTargetRot;

		log("BEGIN PreparingToAttack");
		TowardsTarget = MonitoredArea.Targetted.Location - Location;
		TowardsTargetRot = Rotator(TowardsTarget);
		log( "TowardsTargetRot.Yaw=" $ TowardsTargetRot.Yaw );
		ResetTurn( TowardsTargetRot.Yaw & 65535, 1000 );

		TurnOffBackThruster();
	}
	simulated function Tick(float dt)
	{
		Global.Tick(dt);
		UpdateThrusters( dt );

		//If done turning charge
		if( Turn(dt) )
		{
			//When done turning start charging
			GoToState('Attacking');
		}
	}
}

state Attacking
{
	function BeginState()
	{
		log( "BEGIN ATTACKING MODE" );
		TurnOffBackThruster();
		SetTimer(1.0,true);
		SetMultiTimer( MULTITIMER_TURN, 3.0, true );
	}

	simulated function Tick(float dt)
	{
		Global.Tick(dt);
		UpdateThrusters( dt );

		//If done turning charge
		Turn(dt);

		if( DropShipWeaponsState == DSRockets && bPanelIsDown )
		{
			RocketFireTimer += dt;
			if( RocketFireTimer >= RocketFireTime )
			{
				LaunchRockets();
				RocketFireTimer = 0;
			}
		}
	}

	simulated function Timer()
	{
		if( !MonitoredArea.AnEnemyIsIn() )
			GoToState('FlyingAround');

		if( MonitoredArea.Targetted == None )
		{
			log( "set a target: " $ MonitoredArea.Targetted );
			MonitoredArea.SetATarget();
		}

		if ( InsideCone() && ReasonablyFar() )
		{
			if( DropShipWeaponsState != DSRockets )
			{
				DropShipWeaponsState = DSRockets;
				PlayAnim( LowerPanel, , , 2 );
				Turret.SetActive(false);
				bPanelIsDown = true;
				RocketFireTimer = 2.5;
				log("DSRockets");
			}
		}
		else if ( WithinTurretRange() )
		{
			if( DropShipWeaponsState != DSLasers )
			{
				DropShipWeaponsState = DSLasers;
				PlayAnim( RaisePanel, , , 2 );
				Turret.bIsOn = true;
				Turret.SwitchTo_Sweeping();
				bPanelIsDown = false;
				log("DSLasers");
			}
		}
		else if ( DropShipWeaponsState != DSNoWeapon )
		{
			DropShipWeaponsState = DSNoWeapon;
			PlayAnim( RaisePanel, , , 2 );
			Turret.SetActive(false);
			bPanelIsDown = false;
			log("DSNoWeapon");
		}
	}

	function MultiTimer( int timerID )
	{
		local vector TowardsTarget;
		local rotator TowardsTargetRot;

		if( timerID != MULTITIMER_TURN )
		{
			global.MultiTimer( timerID );
			return;
		}
		
		//If the angle between the target and the ship is enough that it
		//won't look stupid to turn
		TowardsTarget = MonitoredArea.Targetted.Location - Location;
		TowardsTargetRot = Rotator(TowardsTarget);
		if( SmallestAngle( Rotation.Yaw, TowardsTargetRot.Yaw ) > 4000  && bDoneTurning == true )
			ResetTurn( TowardsTargetRot.Yaw & 65535, 1000 );
	}

	function EndState()
	{
		//Turn off the sweeper
		Turret.bIsOn = false;
	}
}


simulated function bool InsideCone()
{

	local vector d, t;
	d = Normal( Vector( Rotation ));
	t = Normal( MonitoredArea.Targetted.Location - ( Location + ( vect(700,0,0) >> Rotation ) ));

	return (d dot t) > cos(( 60/180 ) * PI );
}

simulated function bool ReasonablyFar()
{
	return (VSize( MonitoredArea.Targetted.Location - Location ) > 1000);
}

 
simulated function bool WithinTurretRange()
{
	return VSize( MonitoredArea.Targetted.Location - Location ) <= Turret.Range;
}


simulated function LaunchRockets()
{
	local coords Rocket1Start, Rocket2Start;
	local vector DSRocketError;
		
	DSRocketError = RocketSeekingError * VRand();
	Rocket1Start = GetBoneCoords( 'FX01' );
	Rocket2Start = GetBoneCoords( 'FX02' );
	LaunchRocket( Rocket1Start.Origin, DSRocketError );
	LaunchRocket( Rocket2Start.Origin, DSRocketError );
}


simulated function LaunchRocket( vector Loc, vector DSRocketError )
{
	local VGRocketSeeking Rocket;
	local RocketMuzzlePuff puff;

	Rocket = Spawn( class'VGRocketSeeking',,, Loc, Rotation );
	Rocket.SetParams(VehicleDamage, PersonDamage, SplashDamage, DamageRadius, MomentumTransfer);
	Rocket.bInitialLob = true;
	Rocket.LobDuration = 2.5;
	Rocket.Seeking = MonitoredArea.Targetted;
	Rocket.Velocity_correction = 0.1;
	Rocket.Acceleration_correction = 1000;
	Rocket.Imprecision = DSRocketError;
	Rocket.ProjOwner = Instigator.Controller;
	Rocket.Instigator = Instigator;

	if( Rocket != None )
	{
		puff = Spawn( class'RocketMuzzlePuff', self );
		if( puff != None )
		{
			puff.SetLocation(Rocket.Location);
			puff.SetRotation(Rocket.Rotation);
		}
	}
}


/*
	Desc: orient the ship towards the middle of the area
*/
state PreparingToDropPawns
{
	function BeginState()
	{
		local rotator TowardsMarker;

		//log("BEGIN RotateTowardsCenter");

		//Face the center of the area
		TowardsMarker = Rotator( AreaCenter - Location );
		ResetTurn( (TowardsMarker.Yaw & 65535), 1000 );
        SetTimer( 0.3, true );
		TurnOnBottomThruster( -UNREALGRAVITY, false );
		//ChangeStaticMeshCollision(false);
	}

	function Tick( float dt )
	{
		Global.Tick(dt);
		UpdateThrusters( dt );

		//If done turning
		if( Turn(dt) )
		{
			GoToState('DroppingPawns');
		}
	}

	function EndState()
	{
		//log("END PreparingToDropPawns");
	}
}

simulated function ChangeStaticMeshCollision( bool IsOn )
{
	HiddenDropShipCollision.SetCollision( IsOn, IsOn, IsOn );
	HiddenDropShipCollision.bDisableKarmaEncroacher = !IsOn;
	HiddenDropShipCollision.bBlockNonZeroExtentTraces = IsOn;
	HiddenDropShipCollision.bBlockZeroExtentTraces = IsOn;
	HiddenDropShipCollision.bCheckOverlapWithBox = IsOn;
}

/*
	Desc: drops pawns that come down on zip lines
*/
state DroppingPawns
{
	function BeginState()
	{
		bThrusterModel = false;
		DroppingTimer = 0;
	}

	function Tick( float dt )
	{
		local int	 i;
		local bool	 done;

		Global.Tick(dt);

		//If the animations for preparing the droppers to drop is done
		if( !bPreparingToDrop )
		{
			//If the ship has reached its destination it drops the pawns
			if( bDroppingPawns )
			{
				DroppingTimer += dt;

				if( !bDetachedPawns )
				{
					for( i=0; i < 4; i++ )
					{
						DroppedPawn[i].SetBase( none );
					}
					bDetachedPawns = true;
				}

				done = true;
				for( i=0; i < 4; i++ )
				{
					if( DroppedPawn[i] != None && bZipLineBackUp[i] == 0 )
					{
						UpdateZipLine( i, dt );
						done = false;
					}
					if( DroppedPawn[i] != None && bDetachedFromZipLine[i] == 0 )
						UpdateDropped( i, dt );
				}

				//If the zip lines are back up
				if( done )
				{
					log("zip lines are back up");
					GoToState( 'FlyingAround' );
				}
			}
			else
			{
				Velocity = SpeedMult_MovingToDrop * (AreaCenter - Location);
			}
		}
	}

	function EndState()
	{
		//log("END DROPPING PAWNS");
		bThrusterModel = true;
		//ChangeStaticMeshCollision(true);
	}

BEGIN:
	while( true )
	{
		Sleep(0.0);
		if( (VSize(AreaCenter - Location) <= 50) )
		{
			//log("goto GETREADY" );
			Goto('GETREADY');
		}
	}

GETREADY:
	log( "GETREADY" );
	bPreparingToDrop = true;
	log("DroppedPawn[1] " $DroppedPawn[1]);
	
	GettingReady();
	sleep(1.46); //hardcoding the length of animation: is there a better way?

	log("DroppedPawn[1] " $DroppedPawn[1]);

	Hooking();
	sleep(0.8); //hardcoding the length of animation: is there a better way?

	log("DroppedPawn[1] " $DroppedPawn[1]);

	bPreparingToDrop = false;
	SetupDescent();
	log("DroppedPawn[1] " $DroppedPawn[1]);
}


simulated function GettingReady()
{
	local int i;
	AnimStopLooping(1);
	
	//Play the getting ready to hook animation
	for( i=0; i < 4; i++ )
	{
		log( "GettingReady to drop" );
		DroppedPawn[i].PlayAnim( GetReadyToHook, , 0.1, 1 );
	}
}


simulated function Hooking()
{
	local int i;
	//Then play the getting hooked animation
	log( "Hooking function" );
	for( i=0; i < 4; i++ )
		DroppedPawn[i].PlayAnim( HookingAnim, , 0.1, 1 );
}


simulated function SetupDescent()
{
	local int i;
	local VGSPAIController C;

	Velocity.X = 0;
	Velocity.Y = 0;
	bDroppingPawns = true;
	//log( "SetupDescent" );

	for( i=0; i < 4; i++ )
	{
		//Choose a speed
		ZipLineDropSpeed[i] = ZipLinesDropSpeed + ZipLineDropSpeedVariance*(2.0*FRand() - 1.0);
		log("Do the descent animation");
		//Animation for the descent
		DroppedPawn[i].LoopAnim( DescentAnim, , 0.1, 1 );
		
		//Make a controller for the pawn
		C = Spawn( class'VGSPAIController',,,, );
		C.Possess( DroppedPawn[i] );
		
		ZipLineFallPoint[i] = ZipLine[i].Location + vect(0,0,-100);
	}

	AttachtoBone( DroppedPawn[0], 'zip01' );
	AttachtoBone( DroppedPawn[1], 'zip02' );
	AttachtoBone( DroppedPawn[2], 'zip03' );
	AttachtoBone( DroppedPawn[3], 'zip04' );
	
}


simulated function UpdateZipLine( int id, float dt )
{
	local vector scale;
	local float ZipLineSpeed;

	scale.X = 1.0;
	scale.Y = 1.0;
	log("ZipLineHeight[id]" $ ZipLineHeight[id]);
	//If the guy has hit the ground
	if( bHitGround[id] == 1 )
	{
		//If the guy is detached from the zip line
		if( bDetachedFromZipLine[id] == 1 )
		{
			ZipLineRiseTimer[id] += dt;
			ZipLineSpeed = ZipLineStartRiseSpeed + ZipLineRiseAcceleration * ZipLineRiseTimer[id];
			ZipLineHeight[id] = ZipLineMaxHeight[id] - (1.0/200.0) * ZipLineSpeed * ZipLineRiseTimer[id];

			//If the line has rolled back up
			if( ZipLineHeight[id] < 0 )
			{
				ZipLineHeight[id] = 0;
				bZipLineBackUp[id] = 1;
				ZipLine[id].Destroy();
			}
		}
		else
		{
			ZipLineHeight[id] = ZipLineMaxHeight[id];
		}
	}
	//If the dropper is still going down
	else
	{
		ZipLineHeight[id] = (1.0/200.0) * (ZipLine[id].Location.Z - DroppedPawn[id].Location.Z);
		//ZipLineHeight[id] = (1.0/200.0) * ZipLineDropSpeed[id] * DroppingTimer;
	}

	scale.Z = ZipLineHeight[id];
	ZipLine[id].SetDrawScale3D( scale );
}


simulated function UpdateDropped( int id, float dt )
{
	//If the guy hit the ground wait before letting the rope back up
	//change: get Dennis to make the animation send a notification instead
	if( bHitGround[id] == 1 )
	{
		UnhookingTimer[id] += dt;
		if( bDetachedFromZipLine[id] == 0 && (UnhookingTimer[id] > UnhookingTime) )
		{
			bDetachedFromZipLine[id] = 1;
			DroppedPawn[id].Controller.ClientSwitchToBestWeapon();
			StageToJoin.JoinStage( VGSPAIController(DroppedPawn[id].Controller) );
		}

	}
	else
	{
		//To detect if the pawn went through the terrain, if this time the distance to it
		//is bigger, it must have gone through
		if( DroppedPawn[id].bDetached )
		{
			ZipLine[id].SetSkin(0,ZipLineNoiseTexture); //watch out
			bHitGround[id] = 1;
			ZipLineMaxHeight[id] = ZipLineHeight[id];
		}
		else
		{
			DroppedPawn[id].SetLocation( (ZipLineFallPoint[id]) - vect(0,0,1)*ZipLineDropSpeed[id]*DroppingTimer );
		}
		if (id == 0)
			log("DroppedPawn[0].Location" $DroppedPawn[0].Location);
	}
	if( ZipLineFallPoint[id].Z - DroppedPawn[id].Location.Z > 200 && DroppedPawn[id].bCollideWorld == false )
	{
		log("Setting collision on");
		DroppedPawn[id].bCollideWorld = true;
		DroppedPawn[id].SetCollision( true, true, true );
		DroppedPawn[id].bBlockNonZeroExtentTraces = true;
		DroppedPawn[id].bBlockZeroExtentTraces = true;
	}
}


//-----------------------------------------------------------------------
//							Thrusters
//-----------------------------------------------------------------------
simulated function TurnOnBackThruster( float acceleration, bool bUseTimer, optional float thrustTime )
{
	if( BackThrusterInfo.active )
	{
		//log("Back thruster is already active");
		return;
	}

	//log("Back thruster turned on");

	BackThrusterInfo.active = true;
	BackThrusterInfo.bTimed = bUseTimer;
	BackThrusterAcc = acceleration;

	if( bUseTimer )
		BackThrusterInfo.thrustTime = thrustTime;
	else
		BackThrusterInfo.thrustTime = -1;

	//Start the particle emitter
	LiveEmitters[1].Start();
	//LiveEmitters[5].Start();

	//log( "Turn on back thruster sound" );
	PlayOwnedSound( BackThrusterSound, SLOT_None, THRUSTER_SOUND_LEVEL + 0.2, , THRUSTER_SOUND_RADIUS, , false );
}


simulated function VaryBackAcceleration( float acceleration )
{
	BackThrusterAcc = acceleration;
}


simulated function VaryBottomAcceleration( float acceleration )
{
	BottomThrusterAcc = acceleration;
}


simulated function TurnOnBottomThruster( float acceleration, bool bUseTimer, optional float thrustTime )
{
	if( BottomThrusterInfo.active )
	{
		//log("Bottom thruster ALREADY active");
		return;
	}

	BottomThrusterInfo.active = true;
	BottomThrusterInfo.bTimed = bUseTimer;
	BottomThrusterAcc = acceleration;

	if( bUseTimer )
		BottomThrusterInfo.thrustTime = thrustTime;
	else
		BottomThrusterInfo.thrustTime = -1;

	//Start the particle emitter
	LiveEmitters[0].Start();

	log("bottom thruster sound");
	PlayOwnedSound( BottomThrusterSound, SLOT_None, THRUSTER_SOUND_LEVEL, , THRUSTER_SOUND_RADIUS, , false );
}



simulated function TurnOffBottomThruster()
{
	BottomThrusterAcc = 0;
	BottomThrusterInfo.active = false;

	//Start the particle emitter
	LiveEmitters[0].Stop();

	log( "Stop bottom thruster sound" );
	StopOwnedSound( BottomThrusterSound );
}


simulated function TurnOffBackThruster()
{
	BackThrusterAcc = 0;
	BackThrusterInfo.active = false;

	//Start the particle emitter
	//log("turning off the back thruster");
	LiveEmitters[1].Stop();


	StopOwnedSound( BackThrusterSound );
}


simulated function UpdateThrusters( float dt )
{
	if( BottomThrusterInfo.active && BottomThrusterInfo.bTimed )
	{
		BottomThrusterInfo.thrustTimer += dt;
		if( BottomThrusterInfo.thrustTimer >= BottomThrusterInfo.thrustTime )
		{
			//Thrusting time expired
			TurnOffBottomThruster();
			BottomThrusterInfo.thrustTimer = 0;
		}
	}

	if( BackThrusterInfo.active && BackThrusterInfo.bTimed )
	{
		BackThrusterInfo.thrustTimer += dt;
		if( BackThrusterInfo.thrustTimer >= BackThrusterInfo.thrustTime )
		{
			//Thrusting time expired
			TurnOffBackThruster();
			BackThrusterInfo.thrustTimer = 0;
		}
	}
}


//-----------------------------------------------------------------------
//							MISC
//-----------------------------------------------------------------------
simulated function Tick( float dt )
{
	if( bShowDebug )
		DrawDebugArrow( Location, AreaCenter, 255,255,255 );

	if( bDying )
	{
		ShipBlowupTimer += dt;
		//log("ShipBlowupTimer="$ShipBlowupTimer);
		if ( !bExplosion1Done && (ShipBlowupTimer >= Explosion1Time) )
		{
			bExplosion1Done = true;
			log( "Drop ship Explosion 1 !!!" );
			spawn( ExplosionBurstClass, , , Location );
			PlayOwnedSound( EXPLSound, SLOT_None, EXPLOSION_SOUND_LEVEL, , EXPLOSION_SOUND_RADIUS, , false );
		}

		if ( !bExplosion2Done && (ShipBlowupTimer >= Explosion2Time) )
		{
			bExplosion2Done = true;
			log( "Drop ship Explosion 2 !!!" );
			spawn( ExplosionBurstClass, , , Location );
			PlayOwnedSound( EXPL2Sound, SLOT_None, EXPLOSION_SOUND_LEVEL, , EXPLOSION_SOUND_RADIUS, , false );
		}

		if ( ShipBlowupTimer >= ShipBlowupTime )
		{
			log("ship explosion");
			BlowUpShip();
		}
	}
}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum,
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	local vector HitNormal;  // approximation to hitnormal
	log("TakeDamage");
	if( bDying )
		return;

	HitNormal = Normal(Hitlocation - Location) ;

	//If the shield is on spawn shield hit effets
	if( bShieldOn )
	{
		log("TakeDamage - bShieldOn");
		//Kill the older shield hit
		ShieldHits[OlderSlot].Electricity.Kill();
		ShieldHits[OlderSlot].Distortion.Kill();

		//Spawn a new one
		ShieldHits[OlderSlot].Electricity = Spawn( class'VehicleEffects.shield_hit_energy', , , HitLocation + 50 * HitNormal, Rotator(HitNormal) );
		ShieldHits[OlderSlot].Distortion = Spawn( class'VehicleEffects.shield_hit_distortion', , , HitLocation + 50 * HitNormal, Rotator(HitNormal) );

		//Update which hit effect is the oldest
		OlderSlot = (OlderSlot++) % MAXSHIELDHITS;

		HealthDrop += Damage;
		if( HealthDrop >= HealthDropCausingExplosion )
		{
			HealthDrop = 0;
			spawn( ExplosionBurstClass, , , HitLocation );
		}
		ShieldHealth -= Damage;

		if( ShieldHealth <= 0 )
			bShieldOn = false;
	}
	else
		ShipHealth -= Damage;


	log("ShipHealth "$ShipHealth);
	log("ShieldHealth "$ShieldHealth);

	if( ShipHealth < 0 )
	{
		EmitSmokeAtHitPoint( HitLocation );

		//First explosion happens randomly within the period [0, 0.5*ShipBlowupTime ]
		Explosion1Time = (0.5 * FRand()) * ShipBlowupTime;

		//First explosion happens randomly within the period [0.5*ShipBlowupTime, 0.8*ShipBlowupTime ]
		Explosion2Time = (0.5 + 0.3 * FRand()) * ShipBlowupTime;

		HiddenDropShipCollision.Destroy();
		bDying = true;
	}
}


simulated function EmitSmokeAtHitPoint( vector FinalHitLocation )
{
	//Smoke
	SmokeTrails[SmokeTrails.Length] = spawn( SmokeEmitterClass, self,, FinalHitLocation, );
	SmokeTrails[SmokeTrails.Length-1].SetBase( self );
	SmokeTrails[SmokeTrails.Length] = spawn( Smoke2EmitterClass, self,, FinalHitLocation, );
	SmokeTrails[SmokeTrails.Length-1].SetBase( self );

	//Explosion
	SmallExplosions[SmallExplosions.Length] = spawn( SmallExplosionClass, , , FinalHitLocation );
}


simulated function BlowUpShip()
{
	local int i;
	local DropShipChunks SM;

	StopOwnedSound( BackThrusterSound );
	StopOwnedSound( BottomThrusterSound );

	log("Should have blown up by now!");

	Turret.Destroy();

	//Send a death event out
	if( OnDeathEvent != '' )
		TriggerEvent( OnDeathEvent, self, None );

	PlayOwnedSound( ShipBlowupSound, SLOT_None, EXPLOSION_SOUND_LEVEL, , EXPLOSION_SOUND_RADIUS, , false );

	if( ExplosionBurst2Class != None )
		spawn( ExplosionBurst2Class, , , Location );

	for( i=0; i < SmokeTrails.Length; i++ )
		SmokeTrails[i].Kill();

	for( i=0; i < SmallExplosions.Length; i++ )
		SmallExplosions[i].Destroy();

	for( i=0; i<10; i++ )
	{
		SM = Spawn( SMeshClass[i],Self );

		if ( SM!=None )
			SM.SetLocation( Location + SM.ELoc );
	}

	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();

	for( i=0; i<4; i++ )
	{
		if( !DroppedPawn[i].bDetached )
			DroppedPawn[i].Destroy();
	}

	for( i=0; i<4; i++ )
	{
		if( ZipLine[i] != None )
			ZipLine[i].Destroy();
	}

	Destroy();
}

defaultproperties
{
     ShieldHealth=200
     ShipHealth=200
     HealthDropCausingExplosion=50
     ZipLinesDropSpeed=600
     ZipLineDropSpeedVariance=300
     ZipLineStartRiseSpeed=300
     ZipLineRiseAcceleration=50
     RocketSeekingError=110
     RollSpeed=2000
     MaxRoll=4000
     VehicleDamage=40
     PersonDamage=20
     MaxSpeed=400.000000
     AeroDynamicResistance=0.150000
     SpeedMult_MovingToDrop=1.000000
     AccMult_Approaching=1.000000
     AccMult_MovingToDrop=1.000000
     AccMult_FlyingAround=1.000000
     AccMult_ZoomBy=1.000000
     AccMult_Charging=1.000000
     AccMult_Evading=1.000000
     UnhookingTime=3.000000
     MaxContinuousFiringTime=5.000000
     RocketFireTime=3.500000
     TurnSpeedFactor=2.000000
     TiltSpeedFactor=1.000000
     ShipBlowupTime=1.100000
     SplashDamage=30.000000
     DamageRadius=400.000000
     MomentumTransfer=5000.000000
     ZipLineMesh=StaticMesh'PariahDropShipMeshes.SmallDropShip.zip_line01'
     ZipLineNoiseTexture=NoiseVertexModifier'MannyTextures.vertex_shaders.zip_linemove1'
     EXPLSound=Sound'Sounds_Library.Weapon_Sounds.73-longer_dynamite_blast5'
     EXPL2Sound=Sound'Sounds_Library.Weapon_Sounds.91-fireball1'
     ShipBlowupSound=Sound'Sounds_Library.Weapon_Sounds.73-longer_dynamite_blast5'
     BackThrusterSound=Sound'GeneralAmbience.firefx12'
     BottomThrusterSound=Sound'PariahDropShipSounds.Millitary.ThrusterMediumA'
     SideThrusterSound=Sound'MiniEdSounds.MiniEdTerrainEditLoopA'
     MovingAreaName="DropShipArea2"
     GetReadyToHook="GRToJump"
     HookingAnim="JumpOnLine"
     DescentAnim="IdleOnLIne"
     Floating="Float_Idle"
     LowerPanel="Deploy"
     Float_PanelDown="Deploy_Idle"
     RaisePanel="PutAway"
     SmokeEmitterClass=Class'VehicleEffects.ShipDamageSmoke'
     Smoke2EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     ExplosionBurstClass=Class'VehicleEffects.ShipBurst'
     ExplosionBurst2Class=Class'VehicleEffects.Ship2ndBurst'
     SmallExplosionClass=Class'VehicleEffects.LobBurst'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     ChunkClass=Class'VehicleEffects.DropShipChunks'
     SMeshClass(0)=Class'VehicleEffects.DSChunk_a'
     SMeshClass(1)=Class'VehicleEffects.DSChunk_b'
     SMeshClass(2)=Class'VehicleEffects.DSChunk_c'
     SMeshClass(3)=Class'VehicleEffects.DSChunk_d'
     SMeshClass(4)=Class'VehicleEffects.DSChunk_e'
     SMeshClass(5)=Class'VehicleEffects.DSChunk_f'
     SMeshClass(6)=Class'VehicleEffects.DSChunk_g'
     SMeshClass(7)=Class'VehicleEffects.DSChunk_h'
     SMeshClass(8)=Class'VehicleEffects.DSChunk_i'
     SMeshClass(9)=Class'VehicleEffects.DropShipChunks'
     Emitters(0)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(1)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(2)=(AttachPoint="ThrusterFrontLeft",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(3)=(AttachPoint="ThrusterFrontRight",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     TurretRelativePosition=(X=600.000000,Z=-280.000000)
     SmokeStart=(X=40.000000,Y=800.000000,Z=-100.000000)
     SmokebStart=(X=240.000000,Y=-750.000000,Z=-100.000000)
     DropShipWeaponsState=DSNoWeapon
     bThrusterModel=True
     bHasShield=True
     bShieldOn=True
     bUsesZipLines=True
     race=R_Guard
     TransientSoundVolume=2.000000
     Mesh=SkeletalMesh'PariahDropShips.ZipLineDropShip'
     Begin Object Class=HavokParams Name=VGHavokDebrisHParams
         Mass=40.000000
         LinearDamping=0.300000
         AngularDamping=0.300000
         StartEnabled=True
         Restitution=1.000000
         ImpactThreshold=100000.000000
     End Object
     HParams=HavokParams'PariahSPPawns.VGHavokDebrisHParams'
     EventBindings(0)=(EventName="StartDropshipX",HandledBy="StartMoving")
     EventBindings(1)=(EventName="UseDropShipXZipLines",HandledBy="DropGuys")
     DrawScale3D=(X=2.000000,Y=2.000000,Z=2.000000)
     bDisableSorting=True
     bHasHandlers=True
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
}
