//=============================================================================
// SceneManager
//
// Manages a matinee scene.  Contains a list of action items that will
// be played out in order.
//=============================================================================
class SceneManager extends Info
	placeable
	native;

#exec Texture Import File=Textures\SceneManager.pcx  Name=S_SceneManager Mips=Off

// Graphics for UI
#exec Texture Import File=Textures\S_MatineeIP.pcx Name=S_MatineeIP Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeIPSel.pcx Name=S_MatineeIPSel Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeTimeMarker.pcx Name=S_MatineeTimeMarker Mips=Off MASKED=1
#exec Texture Import File=Textures\ActionCamMove.pcx  Name=S_ActionCamMove Mips=Off
#exec Texture Import File=Textures\ActionCamPause.pcx  Name=S_ActionCamPause Mips=Off
#exec Texture Import File=Textures\PathLinear.pcx  Name=S_PathLinear Mips=Off MASKED=1
#exec Texture Import File=Textures\PathBezier.pcx  Name=S_PathBezier Mips=Off MASKED=1
#exec Texture Import File=Textures\S_BezierHandle.pcx  Name=S_BezierHandle Mips=Off MASKED=1
#exec Texture Import File=Textures\SubActionIndicator.pcx  Name=SubActionIndicator Mips=Off MASKED=1

struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var int MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
};

struct Interpolator
{
	var() int bDone;
	var() float _value;
	var() float _remainingTime;
	var() float _totalTime;
	var() float _speed;
	var() float _acceleration;
};

// Exposed vars
var()	export	editinline	array<MatAction>	Actions;
var()	config	enum EAffect
{
	AFFECT_ViewportCamera,
	AFFECT_Actor,
	AFFECT_ViewportCameraNoMove,
} Affect;
var()	Actor	AffectedActor;			// The name of the actor which will follow the matinee path (if Affect==AFFECT_Actor)
var()	bool	bLooping;				// If this is TRUE, the path will looping endlessly
var()	bool	bCinematicView;			// Should the screen go into letterbox mode when playing this scene?
var()   name	PlayerScriptTag;		// Tag of sequence that player's pawn should use during sequence
var()	name	NextSceneTag;			// The tag of the next scenemanager to execute when this one finishes
var()	name	EventStart;				// Fired when the scene starts
var()	name	EventEnd;				// Fired when the scene ends
var()	bool	bUseMoveActor;			// cmr -- hack for level 2, forces scenemanager to move Viewer using MoveActor instead of FarMoveActor; solves some collision issues with volumes.
var()   vector  RotationNoiseSpeed;     // sjs
var()   vector  RotationNoiseScale;     // sjs

// These vars are set by the SceneManager in it's Tick function.  Don't mess with them directly.
var		float				PctSceneComplete;	// How much of the scene has finished running
var		mataction			CurrentAction;		// The currently executing action
var		float				SceneSpeed;
var		float				TotalSceneTime;		// The total time the scene will take to run (in seconds)
var		Actor				Viewer;				// The actor viewing this scene (the one being affected by the actions)
var		Pawn				OldPawn;			// The pawn we need to repossess when scene is over
var		bool				bIsRunning;			// If TRUE, this scene is executing.
var		bool				bIsSceneStarted;	// If TRUE, the scene has been initialized and is running
var		float				CurrentTime;		// Keeps track of the current time using the DeltaTime passed to Tick
var		array<vector>		SampleLocations;	// Sampled locations for camera movement
var		array<MatSubAction>	SubActions;			// The list of sub actions which will execute during this scene
var		Orientation			CamOrientation;		// The current camera orientation
var		Orientation			PrevOrientation;	// The previous orientation that was set
var		Interpolator		RotInterpolator;	// Interpolation helper for rotations
var		vector				CameraShake;		// The SubActionCameraShake effect fills this var in each frame
var     vector              LastShake;          // running value of camerashake that was added to the last frame
var     bool                bSmooth;            // make camera shake additive and use the lastshake value
var		vector				DollyOffset;		// How far away we are from the actor we are locked to

// Native functions
native function float GetTotalSceneTime();

simulated function BeginPlay()
{
	Super.BeginPlay();

	if( Affect == AFFECT_Actor && AffectedActor == None )
		log( "SceneManager : Affected actor is NULL!" );

	//
	// Misc set up
	//

	TotalSceneTime = GetTotalSceneTime();
	bIsRunning = false;
	bIsSceneStarted = false;
}

function Trigger( actor Other, Pawn EventInstigator )
{
	// log( "RJ: Trigger("$Other$","$EventInstigator$") called" );

	bIsRunning = true;
	bIsSceneStarted = false;
	Disable( 'Trigger' );
}

function FreezeCoop()
{
    local PlayerController Other;
    
    if(!Level.IsCoopSession() || Level.Game == None || !Level.Game.bSinglePlayer)
    {
        return;    
    }
    
    Other = Level.GetLocalPlayerByIndex(1);
    Other.PrepareForMatinee();
    Other.TurnTarget = Other.Pawn;
	if ( Other.Pawn != None )
	{
		Other.Pawn.Velocity = vect(0,0,0);
		Other.Pawn.Acceleration = vect(0,0,0);
		Other.Pawn.bMatineeProtected = true;
		Other.UnPossess(true);
	}
	Other.MyHud.bHideHUD = true;
	Other.MyHud.bInMatinee = true;
	Other.StartInterpolation();
}

function UnFreezeCoop()
{
    local PlayerController Other;

    if(!Level.IsCoopSession() || Level.Game == None || !Level.Game.bSinglePlayer)
    {
        return;    
    }
    
    Other = Level.GetLocalPlayerByIndex(1);
    if ( Other.TurnTarget != None )
	{
		Other.TurnTarget.bMatineeProtected = false;
		Other.Repossess( Other.TurnTarget );
		Other.TurnTarget = None;
	}
	Other.bInterpolating = false;
	Other.MyHud.bHideHUD = false;
	Other.MyHud.bInMatinee = false;
	
	if( Affect!=AFFECT_ViewportCameraNoMove )
	{
		Other.FinishedInterpolation();
		Other.RecoverFromMatinee();
	}
}

// Events
event SceneStarted()	// Called from C++ when the scene starts.
{
	local Controller P;
	local AIScript S;

	// Figure out who our viewer is.
	Viewer = None;
	if( Affect==AFFECT_Actor )
	{
		Viewer = AffectedActor;
		Viewer.PrepareForMatinee();
		Viewer.StartInterpolation();
	}
	else if( Affect==AFFECT_ViewportCamera )
	{
//		for( P = Level.ControllerList ; P != None ; P = P.nextController )
		foreach DynamicActors(class'Controller', P)
		{
			if( P.IsA('PlayerController')  )
			{
				log("MIKEH SceneManager PlayerController:"@P@P.PlayerReplicationInfo.RetrivePlayerName() );
				Viewer = P;

				Viewer.PrepareForMatinee();


				OldPawn = PlayerController(Viewer).Pawn;
				if ( OldPawn != None )
				{
					OldPawn.Velocity = vect(0,0,0);
					OldPawn.Acceleration = vect(0,0,0);
					OldPawn.bMatineeProtected = true;
					PlayerController(Viewer).UnPossess(true);
					if ( PlayerScriptTag != 'None' )
					{
						ForEach DynamicActors( class'AIScript', S, PlayerScriptTag )
							break;
						if ( S != None )
							S.TakeOver(OldPawn);
					}
				}
				PlayerController(Viewer).MyHud.bHideHUD = true;
				PlayerController(Viewer).MyHud.bInMatinee = true;

				Viewer.StartInterpolation();
                FreezeCoop();
				break;
			}
        }
	}
	else if( Affect == AFFECT_ViewportCameraNoMove )//cmr leave playercontroller alone
	{
		foreach DynamicActors(class'Controller', P)
			if( P.IsA('PlayerController')  )
			{
				log("MIKEH SceneManager PlayerController:"@P@P.PlayerReplicationInfo.RetrivePlayerName());
				Viewer = P;
				PlayerController(Viewer).MyHud.bHideHUD = true;
				PlayerController(Viewer).MyHud.bInMatinee = true;
				break;
			}
	}
	
	TriggerEvent( EventStart, Self, None);
}

event SceneEnded()		// Called from C++ when the scene ends.
{
	bIsSceneStarted = false;

	if( Affect==AFFECT_ViewportCamera )
	{
		if ( PlayerController(Viewer) != None )
		{
			if ( OldPawn != None )
			{
				OldPawn.bMatineeProtected=false;
				PlayerController(Viewer).Repossess( OldPawn );
			}
		    PlayerController(Viewer).bInterpolating = false;
		    PlayerController(Viewer).MyHud.bHideHUD = false;
			PlayerController(Viewer).MyHud.bInMatinee = false;
			UnFreezeCoop();
        }
	}
	else if( Affect == AFFECT_ViewportCameraNoMove)
	{
		PlayerController(Viewer).MyHud.bHideHUD = false;
		PlayerController(Viewer).MyHud.bInMatinee = false;
	}

	if( Affect!=AFFECT_ViewportCameraNoMove ) //cmr not actually interpolating in this mode
	{
		Viewer.FinishedInterpolation();
		Viewer.RecoverFromMatinee();
	}

	Enable( 'Trigger' );

	TriggerEvent( EventEnd, Self, None);
}

defaultproperties
{
     SceneSpeed=1.000000
     Texture=Texture'Engine.S_SceneManager'
     RemoteRole=ROLE_Authority
     bNoDelete=True
}
