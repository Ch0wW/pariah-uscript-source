//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1


var()	export	editinline	array<ParticleEmitter>	Emitters;

var		(Global)	bool				AutoDestroy;
var		(Global)	bool				AutoReset;
var		(Global)	bool				DisableFogging;
var		(Global)	rangevector			GlobalOffsetRange;
var		(Global)	range				TimeTillResetRange;

var		transient	int					Initialized;
var		transient	box					BoundingBox;
var		transient	float				EmitterRadius;
var		transient	float				EmitterHeight;
var		transient	bool				ActorForcesEnabled;
var		transient	vector				GlobalOffset;
var		transient	float				TimeTillReset;
var		transient	bool				UseParticleProjectors;
var		transient	ParticleMaterial	ParticleMaterial;
var		transient	bool				DeleteParticleEmitters;

var		transient	vector				InitialLocation;
var		transient	rotator				InitialRotation;

//cmr -- wheeeeeeeeeeeeeeeee

var() float CameraShakeRadius;
var() float CameraShakeTime;
var() bool bCameraShakeOnTrigger;
//-- cmr

enum EEmitterDropDetail
{
	PTDT_Never,
	PTDT_LevelDropDetailSet,
	PTDT_LevelAggressiveLODSet
};

var		(Global)	EEmitterDropDetail	RenderThrottle;

enum EEmitterPostFXType
{
	PTFT_None,
	PTFT_Distortion		// the rendered particles indicate how and where to distort the screen
};

var		(Global)	EEmitterPostFXType	PostEffectsType;

// Stop and Start the emission
// note: if it does exist somewhere already let me know (xmatt)
native function bool IsActive();
native function Stop();
native function Start();

// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill();
 

function ShakeLocalPlayers()
{
    local Controller C;
    for( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if(C.IsA('PlayerController'))
        {
            C.ExplosionShake(Location, CameraShakeRadius, CameraShakeTime);
        }
    }
}

// cmr -- 
function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if(CameraShakeRadius > 0.0)
	{
		ShakeLocalPlayers();
	}

	InitialRotation = Rotation;
	InitialLocation = Location;
}
// -- cmr

event Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	
	if(bCameraShakeOnTrigger && CameraShakeRadius > 0.0)
	{
		ShakeLocalPlayers();
    }

	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].Trigger();
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_Emitter'
     DrawType=DT_Particle
     RemoteRole=ROLE_None
     Style=STY_Particle
     bNoDelete=True
     bUnlit=True
}
