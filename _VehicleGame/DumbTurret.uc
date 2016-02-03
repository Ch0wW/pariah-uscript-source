class DumbTurret extends actor native placeable;

const FIRING_SOUND_LEVEL	= 1.0; 
const FIRING_SOUND_RADIUS	= 5000;

var	()	float				FireInvRate;
var	()	float				TraceDist;			//used as max acquire range
var	()	vector				TraceOffset;
var	()	int					VehicleDamage;
var	()	int					PersonDamage;
var	()	class<DamageType>	DamageType;
var	()	float				TimerUpdate;
var	()	float				Momentum;
var ()  int					TargetTeam;
var ()  bool				bUseTeams;
var	()	class<MuzzleFlash>	MuzFlashClass;
var	()	class<Actor>		TracerClass;
var class<VGHitEffectBase>	HitEffectClass;
var		MuzzleFlash			MuzFlash;
var		float		LastFireTime;
var		actor		Target;
var		rotator		DefaultRotation;
var		bool		bFire;

//Intermittant fire: when you don't want it to shoot all the time
var()	bool		bIntermittantFire;
var		bool		bFiringPaused;
var		bool		bContinuousFire;
var		float		PauseTimer;
var()	float		FireIntermissionTime;

//Sounds
var   bool			bPlayingBarrelFiring;
var() sound			FiringSound;

//debug
var() bool			bShowDebug;


enum ETurretRace
{
	TURRET_NPC,
	TURRET_Guard,
	TURRET_Clan,
	TURRET_Shroud,
};


var() ETurretRace race;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Target, DefaultRotation;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	DefaultRotation = Rotation;
	SetTimer(TimerUpdate, true);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetTimer(TimerUpdate, true);
}

simulated function Timer()
{
	if(Role == ROLE_Authority)
		AcquireTarget();
	//turn to target and fire
	UpdateRotation();
	if(Target != none)
		bFire = true;
	else
		bFire = false;
}

simulated event Tick( float dt )
{
	if( bIntermittantFire )
	{
		if( (PauseTimer + dt) > FireIntermissionTime )
		{
			PauseTimer = (PauseTimer + dt) - FireIntermissionTime;
			bFiringPaused = !bFiringPaused;
			if( bFiringPaused )
			{
				if( bPlayingBarrelFiring )
					StopFiringSound();
			}
		}
		else
			PauseTimer += dt;
	}
	
	if( !bFiringPaused && bFire )
	{
		if( bContinuousFire )
		{
			Fire();
		}
		else
		{
			if( Level.TimeSeconds >= LastFireTime + FireInvRate)
			{
				Fire();
			}	
		}
	}
}

simulated function UpdateRotation()
{
	if(Target == none)
		DesiredRotation = DefaultRotation;
	else
		DesiredRotation = rotator(Target.Location - Location);

}

//will check current target and update as necessary
native function AcquireTarget();


simulated function PlayFiringSound()
{
	PlayOwnedSound( FiringSound, SLOT_None, FIRING_SOUND_LEVEL, , FIRING_SOUND_RADIUS );
	bPlayingBarrelFiring = true;
}


simulated function StopFiringSound()
{
	StopOwnedSound( FiringSound );
	bPlayingBarrelFiring = false;
}


simulated function FireCommon( vector start, vector end )
{
	local Actor	Other;
	local vector HitLocation, HitNormal, trajectory;
	local rotator TraceRot;
	local Material HitMat;

    //Muzzle flash
	DoFireEffect( start, Rotator(end - start) );

	if( !bPlayingBarrelFiring )
		PlayFiringSound();

	if( Role != ROLE_Authority )
		return;

    Other = Trace(HitLocation, HitNormal, End, Start, true, , HitMat );
	
	if( Other != none && Other != self )
	{
		trajectory = Normal(HitLocation - start);
        if ( !Other.bWorldGeometry )
        {
			if(Other.IsA('VGVehicle'))
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
			else
				Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
        }
        else
        {
        	if( !Other.IsA('Pawn') && HitEffectClass != None )
				HitEffectClass.static.SpawnHitEffect( Other, HitLocation, HitNormal, , HitMat );
        }
	}
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

	TraceRot = rotator(HitLocation - Start);
	
	//Tracer
	spawn(TracerClass,self,,Start, TraceRot);
	
}


simulated function Fire()
{
	local vector start, end;

	LastFireTime = Level.TimeSeconds;

	start = Location + (TraceOffset >> Rotation);
	end = start + TraceDist * Vector(Rotation);

	FireCommon( start, end );
}

simulated function DoFireEffect( vector start, rotator TraceRotation )
{
    if( Level.NetMode == NM_DedicatedServer )
        return;
        
	if( MuzFlash == none )
	{
		MuzFlash = Spawn( MuzFlashClass, self, , Location + (TraceOffset >> Rotation) );
		MuzFlash.SetBase( self );
	}
	MuzFlash.Flash(0);
}


simulated function Destroyed()
{
	Super.Destroyed();
	
	StopFiringSound();
}

defaultproperties
{
     VehicleDamage=1
     PersonDamage=2
     TargetTeam=-1
     FireInvRate=0.300000
     TraceDist=2000.000000
     TimerUpdate=0.100000
     Momentum=100.000000
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     DamageType=Class'Engine.DamageType'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     TracerClass=Class'VehicleGame.Tracer'
     TraceOffset=(X=130.000000,Z=30.000000)
     bUseTeams=True
     DrawScale=0.250000
     DrawScale3D=(X=-1.000000)
     RotationRate=(Pitch=16384,Yaw=16384)
     Physics=PHYS_Rotating
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_SimulatedProxy
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bRotateToDesired=True
}
