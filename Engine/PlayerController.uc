//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
    config(user)
    native
    nativereplication
    exportstructs
    DependsOn(Interactions);

var globalconfig string sLastSkippableVideo;

//Mini-Ed
var bool bMiniEdEditing; //Editing mode?

var bool bNoOverlay; //Way to prevent overlays from being spawned (Don't want them in the MiniEd)(xmatt)
var WeaponDynLight MuzzleFlashLight; //A dynamic light that highlights the bump when the muzzle flash is on (xmatt)

// Player info.
var const player Player;

// player input control
var globalconfig    bool    bLookUpStairs;  // look up/down stairs (player)
var globalconfig    bool    bSnapToLevel;   // Snap to level eyeheight when not mouselooking
var globalconfig    bool    bAlwaysMouseLook;
var globalconfig    bool    bKeyboardLook;  // no snapping when true
var globalconfig    bool    bAutoAim;

var bool                    bCenterView;
var bool bUse3rdPersonCam;

//auto aiming
var ()	float	AutoAimHorizontal;
var ()	float	AutoAimVertical;
var ()	float	AutoAimMaxDistance;

var float	CurrentAimVert, CurrentAimHorz;
var float	DesiredAimVert,	DesiredAimHorz;

// Player control flags
var bool        bBehindView;    // Outside-the-player view.
var bool        bFrozen;        // set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool        bPressedJump;
var	bool		bDoubleJump;
var bool        bUpdatePosition;
var bool        bIsTyping;
var bool        bFixedCamera;   // used to fix camera in position (to view animations)
var bool        bJumpStatus;    // used in net games
var bool        bUpdating;
var globalconfig bool   bNeverSwitchOnPickup;   // if true, don't automatically switch to picked up weapon

var globalconfig bool bRelativeRadar;
var globalconfig bool bHideDialogue;

var bool        bZooming;
var bool		bEnhancedVisionIsOn; //State of enhanced vision (ms)

var globalconfig bool bAlwaysLevel;
var bool        bSetTurnRot;
var bool        bCheatFlying;   // instantly stop in flying mode
var bool        bFreeCamera;    // free camera when in behindview mode (for checking out player models and animations)
var bool        bZeroRoll;
var bool        bCameraPositionLocked;
var	bool		bViewBot;
var bool		bClientDemo;

var bool		bSetZoomRot;
var Pawn		LastTarget;			//Last target we used for AutoPivot
var () float	MaximumAutoPivot;	//Out of 32, maximum ratio of AutoRotation to regular rotation

var float MaxResponseTime;
var float WaitDelay;            // Delay time until can restart

var input float
    aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY,
    aForward, aTurn, aStrafe, aUp, aLookUp;

var input byte
    bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest, bXAxis, bYAxis;

var EDoubleClickDir DoubleClickDir;     // direction of movement key double click (for special moves)

// Camera info.
var int ShowFlags;
var int Misc1,Misc2;
var int RendMap;
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var const Controller RealViewTarget;
var PlayerController DemoViewer;
var float CameraDist;       // multiplier for behindview camera dist
var transient array<CameraEffect> CameraEffects;    // A stack of camera effects.

var float DesiredFOV;
var config float DefaultFOV;
var float       ZoomLevel;

var bool bUseYawLimit;
var int CenterYaw;
var int MaxYaw;

// Fixed visibility.
var vector	FixedLocation;
var rotator	FixedRotation;
var matrix	RenderWorldToCamera;
var bool	UseFixedVisibility;

// Screen flashes
var vector FlashScale, FlashFog;
var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;

// Distance fog fading.
var color	LastDistanceFogColor;
var float	LastDistanceFogStart;
var float	LastDistanceFogEnd;
var float	CurrentDistanceFogEnd;
var float	TimeSinceLastFogChange;
var int		LastZone;

// Remote Pawn ViewTargets
var rotator     TargetViewRotation;
var float       TargetEyeHeight;
var vector      TargetWeaponViewOffset;

var transient HUD myHUD;  // heads up display info

var float LastPlaySound;
var float LastPlaySpeech;
var globalconfig int AnnouncerVolume;

// Music info.
var string              Song;
var EMusicTransition    Transition;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;   // buffered moves pending position updates
var SavedMove FreeMoves;    // freed moves, available for buffering
var SavedMove PendingMove;
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;
var Weapon OldClientWeapon;
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string  ProgressMessage[4];
var color   ProgressColor[4];
var float   ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// Stats Logging
var globalconfig private string StatsUsername;
var globalconfig private string StatsPassword;

var class<LocalMessage> LocalMessageClass;

// view shaking (affects roll, and offsets camera position)
var float   MaxShakeRoll; // max magnitude to roll camera
var vector  MaxShakeOffset; // max magnitude to offset camera position
var float   ShakeRollRate;  // rate to change roll
var vector  ShakeOffsetRate;
var vector  ShakeOffset; //current magnitude to offset camera from shake
var float   ShakeRollTime; // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var vector  ShakeOffsetTime;
// amb ---
var vector  ShakeOffsetMax;
var vector  ShakeRotRate;
var vector  ShakeRotMax;
var rotator ShakeRot;
var vector  ShakeRotTime;
// --- amb

/*
	camera shake variables for spring model
	Important: For this method to work, the frame rate must be higher than "10/PI*sqrt(k/m)"
	xmatt
*/
struct Spring
{
	var() float spring_k;
	var() float spring_m;
	var() float spring_d;
	var() float spring_p;
	var() float spring_s;
	var() float spring_f;
	var() Vector spring_pos; // sjs
	var() Vector spring_force; // sjs
};
var() Spring	Vertical_cam_spring;
var bool		bNewCamShake;

var Pawn        TurnTarget;
var config int  EnemyTurnSpeed;
var int         GroundPitch;
var rotator     TurnRot180;
var vector		PivotLocation;

var vector OldFloor;        // used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
var /*private*/ CheatManager    CheatManager;   // Object within playercontroller that manages "cheat" commands
var class<CheatManager>     CheatClass;     // class of my CheatManager
var /*private*/ transient PlayerInput   PlayerInput;    // Object within playercontroller that manages player input.
var config class<PlayerInput>       InputClass;     // class of my PlayerInput
var private AdminBase		AdminManager;

// amb---
// Camera control for debugging/tweaking

// BehindView Camera Adjustments
var bool    bFreeCam;               // In FreeCam mode to adjust the cam rotator
var bool    bFreeCamZoom;           // In zoom mode
var bool    bFreeCamSwivel;         // In swivel mode
var rotator CameraDeltaRotation;    // The rotator delta adjustment
var float   CameraDeltaRad;         // The zoom delta adjustment
var rotator CameraSwivel;           // The swivel adjustment

// For drawing player names
struct PlayerNameInfo
{
    var string mInfo;
    var color  mColor;
    var float  mXPos;
    var float  mYPos;
};

var(TeamBeacon) globalconfig float      TeamBeaconMaxDist;
var(TeamBeacon) globalconfig float      TeamBeaconPlayerInfoMaxDist;
var(TeamBeacon) Texture    TeamBeaconTexture; // sjs - made non config to avoid suspected lin problems
var(TeamBeacon) Texture    TeamBeaconTextureAnimated; 
var(TeamBeacon) globalconfig Color      TeamBeaconTeamColors[2];
var(TeamBeacon) globalconfig Color      TeamBeaconCustomColor;
var(TeamBeacon) globalconfig bool       TeamBeaconUseCustomColor;

var array<PlayerNameInfo> PlayerNameArray;
// --- amb

// Demo recording view rotation
var int DemoViewPitch;
var int DemoViewYaw;

var bool bQuickFire;
var byte QuickReturn;

var	byte HealingToolGroup;
var byte MeleeGroup;
var byte VirusGroup;
var byte LastWeaponGroup;


var Security PlayerSecurity;	// Used for Cheat Protection

// gam ---
var globalconfig bool bNoVoiceMessages;
var globalconfig bool bNoVoiceTaunts;
var globalconfig bool bNoAutoTaunts;
var globalconfig bool bAutoTaunt;
var globalconfig bool bNoMatureLanguage;
// --- gam

// amb ---
var int PitchUpLimit;
var int PitchDownLimit;
// --- amb

// jij ---
var globalconfig int VoiceMask;
var int VoiceChannel;
var globalconfig int OnlineStatus;
// --- jij
// mh ---
//This value should reflect on of the enum values from the speech bank header file. There
//doesn't seem to be a way to keep them automatically in sync, which is ugly.
var globalconfig int SRVocabulary;
// --- mh

// jdf ---
var(ForceFeedback) globalconfig bool bEnablePickupForceFeedback;
var(ForceFeedback) globalconfig bool bEnableWeaponForceFeedback;
var(ForceFeedback) globalconfig bool bEnableDamageForceFeedback;
var(ForceFeedback) globalconfig bool bEnableGUIForceFeedback;
var(ForceFeedback) bool bForceFeedbackSupported;  // true if a device is detected
// --- jdf

// rj ---
var globalconfig string UserSoundtrack;
var globalconfig bool bRandomizeUserSoundtrack;

// if driving a vehicle, use Halo style steering
// - this is here so it gets saved in profile
var globalconfig bool bLookSteer;
// --- rj

// gam -- vendor-specific official map unlocking refixes
var globalconfig Array<string> OfficialMapVendorPrefixes;

// gam --- Xbox Live stuff
var String xuid;
var String Gamertag;

enum ELiveStatus
{
    LS_NotSignedIn,
    LS_PassCodeNeeded,
    LS_SignedIn,
    LS_SignInFailed
};

var ELiveStatus LiveStatus;

var bool bIsGuest;
var int GuestNum;
var bool bHasVoice;
var globalconfig int Skill;
var int NumFriendRequests;
var int NumGameInvites;

var float NextMatchmakingQueryTime;
var float TimeBetweenMatchmakingQueries;

var float NextStatsQueryTime;
var float TimeBetweenStatsQueries;

var float NextStorageCommandTime;
var float TimeBetweenStorageCommands;

var bool bWasInvited; // If joined current game as a result of a game invite.
var int NetSplitID; // sjs - to map replicated playercontrollers to their correct controller ports
// --- gam

var() float ForcedRespawnTime;

var		bool	bZoomed;		//XJ zoom
var		float	ZoomTime, ZoomDevPitch, ZoomDevYaw;
var		rotator DefaultZoomRotation;



// cmr stuff added to support some matinee actions

struct MatineeText
{
	var	color	Color;
	var float	X, Y;
	var String TextID;    //this is going to be a problem. It'll need to be localized... but not statically.  An ID perhaps?
	var EDrawPivot Pivot;
};

var array<MatineeText> MatineeTextArray;

struct MatineeMaterial
{
	var color Color;
	var float X, Y;
	var int Width, Height;
	var Material M;
	var EDrawPivot Pivot;
};

var array<MatineeMaterial> MatineeMaterialArray;

var bool bAllowTitans;

var bool bMigratedWithServer;

// cmr -- stuff added for using objects

var float UseDistance, UseRadius, UseLimit;

var bool bReverseLadder;
var bool bGoingUpLadder;

var int LadderPitchAdjust;
var int LadderYawAdjust;

// allow respawning from the "MostlyDead" state with only one button press
var bool bAutoSpawn;

replication
{
    // Things the server should send to the client.
    reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
        ViewTarget, GameReplicationInfo, NetSplitID;
    unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
        TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;
    reliable if( bDemoRecording && Role==ROLE_Authority )
        DemoViewPitch, DemoViewYaw;

    // Functions server can call.
    reliable if( Role==ROLE_Authority )
        ClientSetHUD,ClientReliablePlaySound, FOV, StartZoom,
        ToggleZoom, StopZoom, EndZoom, ClientSetMusic, ClientRestart,
        ClientAdjustGlow,
        ClientSetBehindView, ClientSetFixedCamera, ClearProgressMessages,
        SetProgressMessage, SetProgressTime,
        GivePawn, ClientGotoState,
		ClientChangeVoiceChatter,
		ClientLeaveVoiceChat,
        ClientChangeChannel,
		ClientValidate,
        ClientSetViewTarget,// sjs
		ClientSetThirdPersonCamera, //cmr
		bAllowTitans;
    reliable if ( (Role == ROLE_Authority) && (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) )
        ClientMessage, TeamMessage, ReceiveLocalizedMessage;
    unreliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientPlaySound;
    reliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientTravel;
    unreliable if( Role==ROLE_Authority )
        SetFOVAngle, RestoreFOV, ClientDamageShake, ClientFlash, ClientInstantFlash, ClientSetFlash,  //amb
        ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition, ClientAdjustPositionWalking; // sjs
    reliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
        ClientHearSound,ClientHearSound2,ClientHearSound3,PlayAnnouncement;
    reliable if( bClientDemoRecording && ROLE==ROLE_Authority )
		DemoClientSetHUD;
    // jdf ---
    unreliable if( Role==ROLE_Authority && bForceFeedbackSupported )
        ServerPlayForceFeedback, ServerStopForceFeedback;
    // --- jdf

    // Functions client can call.
    unreliable if( Role<ROLE_Authority )
        ShortServerMove, ServerMove, ServerMoveFrequent, ServerMoveNoDelta, Say, TeamSay, ServerSetHandedness, ServerViewNextPlayer, ServerViewSelf,ServerUse,ServerDrive;
    reliable if( Role<ROLE_Authority )
        Speech, Pause, SetPause,
        PrevItem, ActivateItem, ServerReStartGame, AskForPawn,
        ChangeName, ChangeTeam, Suicide,
        ServerThrowWeapon, BehindView, Typing,
		ServerChangeChannel, // jij
		ServerValidationResponse,
		ServerSetClientDemo,
        ServerCallVote, ServerCastVote;// sjs

    // jdf ---
    reliable if( Role<ROLE_Authority )
        UpdateForceFeedbackProperties, UpdateSwitchWeaponOnPickup, ServerSetAutotaunt;
    reliable if( Role==ROLE_Authority )
		RequestForceFeedbackProperties;
    reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
        bForceFeedbackSupported, bEnableWeaponForceFeedback,
        bEnablePickupForceFeedback, bEnableDamageForceFeedback,
        bEnableGUIForceFeedback;
    // --- jdf

	// Server Admin replicated functions
	reliable if( Role<ROLE_Authority )
		Admin, AdminLogin, AdminLogout;


	//brainbox replications, might need tweaking

	reliable if( Role<ROLE_Authority )
		MenuMessage;

	reliable if( Role<ROLE_Authority )
		ServerStartZoom, ServerEndZoom;	//XJ zoom stuff
	reliable if( Role==ROLE_Authority )
		ClientEndZoom;

	// mh --- UTrace replication
	reliable if( Role<ROLE_Authority )
         ServerUTrace;
	// --- mh

    
    reliable if (Role < ROLE_Authority)
        ServerSetHasVoice;
}

// --- rj E3

native final function string GetPlayerIDHash();
native final function string GetPlayerNetworkAddress();
native simulated final function bool GetServerNetworkAddress(out String IP, out int Port);
native function string ConsoleCommand( string Command );
native final function LevelInfo GetEntryLevel();
native(544) final function ResetKeyboard();
native final function SetViewTarget(Actor NewViewTarget);
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native final function string GetDefaultURL(string Option);
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();

// XJ: get resolution, only X & Y values used Z is 0;
native function vector GetResolution();

// Validation.
private native event ClientValidate(string C);
private native event ServerValidationResponse(string R);

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
native(524) final function int FindStairRotation(float DeltaTime);

native function bool IsSharingScreen(); // gam

native event ClientHearSound (
    actor Actor,
    int Id,
    sound S,
    vector SoundLocation,
    vector Parameters,
    bool Attenuate
);

native event ClientHearSound2
(
    sound S,
    vector SoundLocation,
	byte SoundVol
);

native event ClientHearSound3
(
	int Slot,
    sound S,
    vector SoundLocation,
	byte SoundVol
);

native final exec function LoadSplitConfig(); // sjs
native final exec function SaveSplitConfig(); // sjs

//alpha is between 0 and 1, 0 being current, 1 being desired.
simulated native function int InterpToDesired(int current, int desired, float alpha); //cmr

// mjm ---
event ClientSetHasVoice(bool flag)
{
    log("ClientHasVoice" @ flag);
    bHasVoice = flag;
    if (PlayerReplicationInfo != None)
    {
        PlayerReplicationInfo.bHasVoice = flag;
    }

    if(Role < ROLE_Authority)
    {
        ServerSetHasVoice(flag);
    }
}

function ServerSetHasVoice(bool flag)
{
    log("ServerSetHasVoice" @ flag);
    bHasVoice = flag;
    if (PlayerReplicationInfo != None)
    {
        PlayerReplicationInfo.bHasVoice = flag;
    }
}
// --- mjm 


// mh --- for UTrace
function ServerUTrace()
{
	if( Level.NetMode != NM_Standalone && AdminManager == None )
		return;

	UTrace();
}
exec function UTrace()
{
	// If they're running with "-log", be sure to turn it off
	ConsoleCommand("HideLog");
	if( Role!=ROLE_Authority )
		ServerUTrace();
	SetUTracing( !IsUTracing() );
	log("UTracing changed to "$IsUTracing()$" at "$Level.TimeSeconds);
}
// --- mh

   //CMR:  A message pump that can be called from menus to tell the player controller things.
function MenuMessage(string msg);
event PostBeginPlay()
{
    Super.PostBeginPlay();

	//Create the weapon dynamic light
	MuzzleFlashLight = Spawn( class'WeaponDynLight', self, , );

    if (TeamBeaconTexture == None)
    {
        //log("TeamBeaconTexture is None!",'Error');
        TeamBeaconTexture = Texture(DynamicLoadObject("PariahGameTypeTextures.TeamSymbols.TeamBeaconT", class'Texture')); // sjs - sorry
    }
    
    if (TeamBeaconTextureAnimated == None)
    {
        //log("TeamBeaconTexture is None!",'Error');
        TeamBeaconTextureAnimated = Texture(DynamicLoadObject("InterfaceContent.LiveIconsAnim.Communicator_a00", class'Material')); // sjs - sorry
    }

    SpawnDefaultHUD();
    if (Level.LevelEnterText != "" )
        ClientMessage(Level.LevelEnterText);

    DesiredFOV = DefaultFOV;
    SetViewTarget(self);  // MUST have a view target!
    if ( Level.NetMode == NM_Standalone )
        AddCheats();

	Vertical_cam_spring.spring_m = 0.6;
	Vertical_cam_spring.spring_d = 7.5;
	Vertical_cam_spring.spring_k = 40;
}

exec function TglPostFX()
{
	local PostFXManager			mgr;

	mgr = class'PostFXManager'.static.GetPostFXManager( Level, true );

	if ( mgr != None )
	{
		mgr.bDisablePostFX = !mgr.bDisablePostFX;
	}
}

function PendingStasis()
{
    bStasis = true;
    Pawn = None;
    GotoState('Scripting');
}

function AddCheats()
{
    if ( CheatManager == None )
        CheatManager = new CheatClass;
}

function bool HaveCheats()
{
    return( CheatManager != None );
}

function MakeAdmin()
{
	if ( AdminManager == None && Level != None && Level.Game != None && Level.Game.AccessControl != None)
	  if (Level.Game.AccessControl.AdminClass == None)
		Log("AdminClass is None");
	  else
		AdminManager = new Level.Game.AccessControl.AdminClass;
}

function ClientSetViewTarget( Actor a ) // sjs
{
	SetViewTarget( a );
}

function ClientSetThirdPersonCamera(bool B, bool UseRiderCam)
{
	bUse3rdPersonCam = B;
	bBehindView = B;

	if(UseRiderCam)
	{
		bUseRiderCamera=B;
	}
}


/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
    // gam ---
    local class<HUD> HudClass;
    if ( myHUD != None )
        myHUD.Destroy();

    HudClass = class<HUD>(DynamicLoadObject( "XInterfaceHuds.HudADeathmatch", class'Class'));
    assert( HudClass != None );
    myHUD = Spawn(HudClass,self);
    assert( myHUD != None );
    // --- gam
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/

function Reset()
{
    PawnDied(Pawn);
    Super.Reset();
    SetViewTarget(self);
    ResetView();
    WaitDelay = Level.TimeSeconds + 2;
	GotoState('PlayerWaiting');
}
function CleanOutSavedMoves()
{
    local SavedMove Next;

	// clean out saved moves
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
}

function UpdateSwitchWeaponOnPickup( bool bSwitch ) // RPC from client
{
    bNeverSwitchOnPickup = bSwitch;
}

// jdf ---
function UpdateForceFeedbackProperties( bool bSupported, bool bEnableWeapon, bool bEnablePickup, bool bEnableDamage, bool bEnableGUI )
{
    bForceFeedbackSupported = bSupported && (bEnableWeapon || bEnablePickup || bEnableDamage || bEnableGUI);
    bEnableWeaponForceFeedback = bEnableWeapon;
    bEnablePickupForceFeedback = bEnablePickup;
    bEnableDamageForceFeedback = bEnableDamage;
    bEnableGUIForceFeedback = bEnableGUI;
}

simulated function RequestForceFeedbackProperties()
{
	if (Level.NetMode != NM_DedicatedServer)
    {
        // sjs - here I update other prefs on the server... wah
        log("Sending Force/switch/taunt settings to server.");
        UpdateForceFeedbackProperties( ForceFeedbackSupported(), bEnableWeaponForceFeedback, bEnablePickupForceFeedback, bEnableDamageForceFeedback, bEnableGUIForceFeedback );  // jdf
        UpdateSwitchWeaponOnPickup(bNeverSwitchOnPickup);
        ServerSetAutotaunt(bAutoTaunt);
    }
}
// --- jdf

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/
event InitInputSystem()
{
    PlayerInput = new InputClass;
}

/* ClientGotoState()
server uses this to force client into NewState
*/
function ClientGotoState(name NewState, name NewLabel)
{
    GotoState(NewState,NewLabel);
}

function AskForPawn()
{
    if ( Pawn != None )
        GivePawn(Pawn);
    else if ( IsInState('GameEnded') )
        ClientGotoState('GameEnded', 'Begin');
    else if ( IsInState('Dead') )
    {
        bFrozen = false;
        ServerRestartPlayer();
    }
}

function GivePawn(Pawn NewPawn)
{
    if ( NewPawn == None )
        return;
    Pawn = NewPawn;
    NewPawn.Controller = self;
    ClientRestart();
}

/* GetFacingDirection()
returns direction faced relative to movement dir
0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
    local vector X,Y,Z, Dir;

    GetAxes(Pawn.Rotation, X,Y,Z);
    Dir = Normal(Pawn.Acceleration);
    if ( Y Dot Dir > 0 )
        return ( 49152 + 16384 * (X Dot Dir) );
    else
        return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
    if ( PlayerReplicationInfo.bOnlySpectator )
        return;

    SetRotation(aPawn.Rotation);
    aPawn.PossessedBy(self);
    Pawn = aPawn;
    Pawn.bStasis = false;
    PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
    ServerSetHandedness(Handedness);
    ServerSetAutoTaunt(bAutoTaunt);
	Restart();
}

// cmr -- a function for repossessing a pawn that you recently unpossessed; skips a bunch of shite that fucks things up.
// note:  This function basically assumes that the pawn doesn't change significantly during the time in between.
function Repossess(Pawn LastPawn)
{
    if ( PlayerReplicationInfo.bOnlySpectator )
        return;

    SetRotation(LastPawn.Rotation);
    LastPawn.PossessedBy(self);
    Pawn = LastPawn;
    Pawn.bStasis = false;
    PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
    ServerSetHandedness(Handedness);
    ServerSetAutoTaunt(bAutoTaunt);

	ServerTimeStamp = 0;
    TimeMargin = 0;
    ResetView();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess(optional bool bTemporary)
{
    if ( Pawn != None )
    {
        SetLocation(Pawn.Location);
        Pawn.RemoteRole = ROLE_SimulatedProxy;
        Pawn.UnPossessed();
        if ( Viewtarget == Pawn )
            SetViewTarget(self);
    }
    Pawn = None;
	if(!bTemporary)
	{
		GotoState('Spectating');
	}
}

function ViewNextBot()
{
	if ( CheatManager != None )
		CheatManager.ViewBot();
}

function PreDying(Pawn P);

// unpossessed a pawn (because pawn was killed)
function PawnDied(Pawn P)
{
	if ( P != Pawn )
		return;
    //EndZoom();
	ClientEndZoom();
    if ( Pawn != None )
        Pawn.RemoteRole = ROLE_SimulatedProxy;
    if ( ViewTarget == Pawn )
        bBehindView = true;

    ServerStopForceFeedback();  // jdf
	bEnhancedVisionIsOn = false;

    Super.PawnDied(P);
}

// gam ---
simulated function ClientSetHUD(class<HUD> newHUDClass, class<Menu> newScoringClass, class<Menu> newPersonalStatsClass )
{
    if ( myHUD != None )
        myHUD.Destroy();

    if (newHUDClass == None)
        myHUD = None;
    else
    {
        myHUD = spawn (newHUDClass, self);

        if (myHUD == None)
        {
            log ("PlayerController::ClientSetHUD(): Could not spawn a HUD of class "$newHUDClass, 'Error');
        }
        else
        {
            myHUD.SetScoreBoardClass( newScoringClass, newPersonalStatsClass );
            if( !bNoOverlay )
            {
				myHUD.SpawnOverlays();
			}
        }
    }
}
// --- gam

// jdf ---
// Server ignores this call, client plays effect
simulated function ClientPlayForceFeedback( String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
        PlayFeedbackEffect( EffectName );
}

simulated function ClientStopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
    {
		if (EffectName != "")
			StopFeedbackEffect( EffectName );
		else
			StopFeedbackEffect();
	}
}

// Server RPCs client, client plays effect
function ServerPlayForceFeedback( String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
	    PlayFeedbackEffect( EffectName );
}

function ServerStopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
    {
		if (EffectName != "")
        StopFeedbackEffect( EffectName );
		else
			StopFeedbackEffect();
	}
}
// --- jdf

function HandlePickup(Pickup pick, optional int Amount)
{
    // jdf ---
    if( bEnablePickupForceFeedback )
        ServerPlayForceFeedback( pick.PickupForce );
    // --- jdf
/*
    // mjm - If we have the gun already then say you picked up some ammo, otherwise, you picked up the gun.
    // ARGH!! We can't do it here, cause it happens too late... come back to this later if I have time.
    log("Handling pickup...");

    if (Pawn.Inventory != None && Pawn.FindInventoryType(pick.InventoryType) != None)
    {   
        ReceiveLocalizedMessage(pick.MessageClass, Amount, None, None, class'Ammo');
        return;    
    }
*/
    ReceiveLocalizedMessage( pick.MessageClass, Amount, None, None, pick.Class );
}


function ViewFlash(float DeltaTime)
{
    local vector goalFog;
    local float goalscale, delta;


    delta = FMin(0.1, DeltaTime);
    goalScale = 1 + DesiredFlashScale + ConstantGlowScale;
    goalFog = DesiredFlashFog + ConstantGlowFog;

	if(myHud != None && myHud.bInMatinee)
		return;

    if ( Pawn != None )
    {
        goalScale += Pawn.HeadVolume.ViewFlash.X;
        goalFog += Pawn.HeadVolume.ViewFog;
    }

    DesiredFlashScale -= DesiredFlashScale * 2 * delta;
    DesiredFlashFog -= DesiredFlashFog * 2 * delta;
    FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
    FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
    InstantFlash = 0;
    InstantFog = vect(0,0,0);

    if ( FlashScale.X > 0.981 )
        FlashScale.X = 1;
    FlashScale = FlashScale.X * vect(1,1,1);

    if ( FlashFog.X < 0.019 )
        FlashFog.X = 0;
    if ( FlashFog.Y < 0.019 )
        FlashFog.Y = 0;
    if ( FlashFog.Z < 0.019 )
        FlashFog.Z = 0;

	//log("viewflash"@FlashFog@FlashScale);


}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    if( Player == None )
        return;

    Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event ClientMessage( coerce string S, optional Name Type )
{
    if (Type == '')
        Type = 'Event';

    TeamMessage(PlayerReplicationInfo, S, Type);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
    myHUD.Message( PRI, S, Type );

    if ( (Type == 'Say') || (Type == 'TeamSay') )
        S = PRI.RetrivePlayerName()$": "$S;

    Player.Console.Message( S, 6.0 );

// FIXME - remove InteractionMaster entirely
//    if ( Player.InteractionMaster != None )
//	{
//        Player.InteractionMaster.Process_Message( S,6.0, Player.LocalInteractions);
//	}
}

simulated function PlayBeepSound(optional Sound Snd)
{
    if( Snd == None )
    {
        return;
    }
    ViewTarget.PlaySound(Snd, SLOT_Interface, 1.0,,,,false);
}

simulated function PlayAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
    //if ( AnnouncementLevel > AnnouncerLevel )
    //	return;
    //if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
    //    return;
    LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
    LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements

	//CMR - short circuiting the announcer for E3 build

    ClientPlaySound(ASound,,,SLOT_Talk);
}


//CMR in case I have to do special dialogue stuffs.
simulated function PlayVoice(sound ASound)
{
    ClientPlaySound(ASound,,,SLOT_Talk);
}

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bVolumeControl, optional float inAtten, optional ESoundSlot slot )
{
    local float atten;

    atten = 0.9;
    if( bVolumeControl )
        atten = FClamp(inAtten,0,1);

    ViewTarget.PlaySound(ASound, slot, atten,,,,false);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
    ClientPlaySound(ASound, bVolumeControl);
}

simulated function WarnDisconnect();

simulated event Destroyed()
{
    local SavedMove Next;

	if (AdminManager != None)
	{
		AdminManager.DoLogout();
		AdminManager = None;
	}

    ClientStopForceFeedback();  // jdf

    if ( Pawn != None )
    {
		Pawn.Health = 0;
		Pawn.Died( self, class'Suicided', Pawn.Location );
    }
    myHud.Destroy();

    while ( FreeMoves != None )
    {
        Next = FreeMoves.NextMove;
        FreeMoves.Destroy();
        FreeMoves = Next;
    }
    while ( SavedMoves != None )
    {
        Next = SavedMoves.NextMove;
        SavedMoves.Destroy();
        SavedMoves = Next;
    }

    // gam ---
    if( PlayerSecurity != None )
    {
        PlayerSecurity.Destroy();
        PlayerSecurity = None;
    }
    // --- gam
    
    if(MuzzleFlashLight != None)
    {
        MuzzleFlashLight.Destroy();
    }

    Super.Destroyed();
}

// rj ---
simulated function string GetUserSoundtrack()
{
	local int num, n;
	local string soundtrack;

	// check if we have a user soundtrack
	if ( UserSoundtrack != "" )
	{
		// check if it's valid
		num = int(ConsoleCommand("NUMSOUNDTRACKS"));
		for ( n = 0; n < num; n++ )
		{
			soundtrack = ConsoleCommand("GETSOUNDTRACKNAME "$n);
			if ( soundtrack == UserSoundtrack )
			{
				break;
			}
		}
		if ( n == num )
		{
			UserSoundtrack = "";
		}
	}

	return UserSoundtrack;
}

simulated function PlaySong()
{
	local string soundtrack, shuffle;

	StopAllMusic( 1.0 );

	// check if we have a user soundtrack
	soundtrack = GetUserSoundtrack();
	if ( soundtrack != "" )
	{
		if ( bRandomizeUserSoundtrack )
		{
			shuffle = "SHUFFLESOUNDTRACK ON";
		}
		else
		{
			shuffle = "SHUFFLESOUNDTRACK OFF";
		}
		ConsoleCommand( shuffle );
		PlayMusic( soundtrack, 3.0 );
	}
	else
	{
		PlayMusic( Song, 3.0 );
	}
}
// --- rj

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
    if( IsSharingScreen() || ( Player.SplitIndex != 0 ) )
        return;

    log("Starting music for"@ PlayerReplicationInfo.RetrivePlayerName() );

    // StopAllMusic( 0.0 );
	Song = NewSong;

	PlaySong();
    Transition  = NewTransition;
}

// just for testing framerate hit!!
exec function TglSoundtrack()
{
	local string temp;

	if ( UserSoundtrack != "" )
	{
		temp = Song;
		Song = UserSoundtrack;
		UserSoundtrack = temp;
		StopAllMusic( 1.0 );
		PlayMusic( UserSoundtrack, 3.0 );
	}
}


// ------------------------------------------------------------------------
// Zooming/FOV change functions

//XJ Zoom stuff, need to know on the server if a player is zoomed so...
function ClientToggleZoom()
{
	if(Pawn.Weapon.ZoomFactor <= 1.0)
		return;
	bSetZoomRot = false;

	if(!bZoomed)
	{
		bZoomed = true;
		bZooming = true;

		if(Role < ROLE_Authority)
			ServerStartZoom();
	}
	else
		ClientEndZoom();
}

function ClientEndZoom()
{
	bZooming = false;
	bZoomed = false;	
	DesiredFOV = default.DefaultFOV;

	if(Role < ROLE_AUTHORITY)
	{
		ServerEndZoom();
	}
}

//don't need a server side for this.
function ClientStopZoom()
{
    bZooming = false;
}

event ServerStartZoom()
{
	bZoomed = true;
	bZooming = true;
}

event ServerEndZoom()
{
	bZoomed = false;
	bZooming = false;
}
//XJ end zoom stuff

function ToggleZoom()
{
    if ( DefaultFOV != DesiredFOV )
	{
		EndZoom();
	}
    else
	{
        StartZoom();
	}
}

function StartZoom()
{
    ZoomLevel = 0.0;
    bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
    bZooming = false;
	DesiredFOV = DefaultFOV;	
}

function FixFOV()
{
    FOVAngle = Default.DefaultFOV;
    DesiredFOV = Default.DefaultFOV;
    DefaultFOV = Default.DefaultFOV;
}

exec function FOV(float F)
{
    if( (F >= 70.0) || (Level.Netmode==NM_Standalone) || PlayerReplicationInfo.bOnlySpectator )
    {
        DefaultFOV = FClamp(F, 1, 170);
        DesiredFOV = DefaultFOV;
        SaveConfig();
    }
}

exec function SetSensitivity(float F)
{
    PlayerInput.SetSensitivityX(F);
    PlayerInput.SetSensitivityY(F);
}

// gam ---
exec function SetMouseSmoothing( int Mode )
{
    PlayerInput.UpdateSmoothing( Mode );
}

native function GetInputAction( out Interactions.EInputAction Action, out Interactions.EInputKey Key, float Delta );


// --- gam

exec function ForceReload()
{
    if ( (Pawn != None) && (Pawn.Weapon != None) )
    {
        //Pawn.Weapon.ForceReload(); //merge_hack
    }
}

// ------------------------------------------------------------------------
// Messaging functions

// Send a message to all players.
exec function Say( string Msg )
{
	local controller C;

	// center print admin messages which start with #
	if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
	{
		Msg = right(Msg,len(Msg)-1);
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.IsA('PlayerController') )
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(6);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
			}
		return;
	}
    Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
	if( !GameReplicationInfo.bTeamGame )
	{
		Say( Msg );
		return;
	}

    Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( self, Msg ) , 'TeamSay');
}

function ServerSetAutoTaunt(bool Value)
{
	bAutoTaunt = Value;
}

function bool AutoTaunt()
{
	return bAutoTaunt;
}
// ------------------------------------------------------------------------

function ServerSetHandedness( float hand)
{
    Handedness = hand;
    if ( Pawn.Weapon != None )
        Pawn.Weapon.SetHand(Handedness);
}

function SetHand()
{
    // gam ---
    if( (Pawn != None) && (Pawn.Weapon != None) )
        Pawn.Weapon.SetHand(Handedness);
    // --- gam

    ServerSetHandedness(Handedness);
}

exec function SetWeaponHand ( string S )
{
    if ( S ~= "Left" )
        Handedness = -1;
    else if ( S~= "Right" )
        Handedness = 1;
    else if ( S ~= "Center" )
        Handedness = 0;
    else if ( S ~= "Hidden" )
        Handedness = 2;
    SetHand();
}

exec function ShowGun ()
{
    if( Handedness == 2 )
        Handedness = 1;
    else
        Handedness = 2;

    SetHand();
}

exec function ToggleFist()
{
	bAllowTitans = !bAllowTitans;
}

event PreClientTravel()
{
    UpdatePlayerProfile();
	ConsoleCommand( "FULLSCREENVIEWPORT 0" );
    ServerStopForceFeedback();  // jdf
}

function ClientSetFixedCamera(bool B)
{
    bFixedCamera = B;
}

function ClientSetBehindView(bool B)
{
    bBehindView = B;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
    //local VoicePack V;

    //if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
    //    return;
    //
    //V = Spawn(Sender.voicetype, self);
    //if ( V != None )
    //    V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
    LastUpdateTime = Level.TimeSeconds - 10;
}

function TestPack()
{
    local Rotator R;
    local int i;

    R.Yaw = 8192;
    R.Pitch = 8192;
    R.Roll = 16000;

    i = PackRotation(R);
    log("** Packed: "@ R.Roll @ R.Pitch @ R.Yaw @i);
    R = UnPackRotation(i);
    log("Unpacked" @ R.Roll @ R.Pitch @ R.Yaw );
}

function int PackRotation(Rotator R)
{
    return (((R.Roll >> 8) & 255) << 24) | (((R.Pitch >> 8) & 255) << 16) | (32767 & (R.Yaw/2));
    /*
    Roll = (R.Roll >> 8) & 255;
    Pitch = (R.Pitch >> 8) & 255;
    return 32767 & (Roll << 8) + Pitch) * 32768 + (32767 & (Rotation.Yaw/2));
    */
}

function Rotator UnPackRotation(int PR)
{
    local Rotator R;

    R.Roll  = ((PR >> 24) & 255) << 8;
    R.Pitch = ((PR >> 16) & 255) << 8;
    R.Yaw   = (PR & 32767) * 2;

    return R;
}

function ServerMoveFrequent // sjs
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    byte ClientRoll,
    int View,
    byte OldTimeDelta,
    int OldAccel
)
{
    ServerMove(TimeStamp,InAccel,ClientLoc,false,false,false,false,DCLICK_None,ClientRoll,View,OldTimeDelta,OldAccel);
}

function ServerMoveNoDelta // sjs
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    byte ClientRoll,
    int View
)
{
    ServerMove(TimeStamp,InAccel,ClientLoc,false,false,true,false,DCLICK_None,ClientRoll,View);
}

function ServerMoveWithDelta
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    byte ClientRoll,
    int View,
    byte OldTimeDelta,
    int OldAccel
)
{
    ServerMove(TimeStamp, InAccel, ClientLoc, false, false, false, false, DCLICK_None, ClientRoll,View, OldTimeDelta, OldAccel);
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
    float TimeStamp,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    byte ClientRoll,
    int View
)
{
    ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,false,DCLICK_None,ClientRoll,View);
}

/* ServerMove()
- replicated function sent by client to server - contains client movement and firing info
Passes acceleration in components so it doesn't get rounded.
*/
function ServerMove
(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
)
{
    local float DeltaTime, clientErr, OldTimeStamp;
    local rotator DeltaRot, Rot, ViewRot;
    local vector Accel, LocDiff, ClientVel, ClientFloor;
    local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump, OldbRun, OldbDoubleJump;
    local eDoubleClickDir OldDoubleClickMove;
    local actor ClientBase;
    local ePhysics ClientPhysics;

    // If this move is outdated, discard it.
    if ( CurrentTimeStamp >= TimeStamp )
        return;

    // if OldTimeDelta corresponds to a lost packet, process it first
    if (  OldTimeDelta != 0 )
    {
        OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
        if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
        {
            // split out components of lost move (approx)
            Accel.X = OldAccel >>> 23;
            if ( Accel.X > 127 )
                Accel.X = -1 * (Accel.X - 128);
            Accel.Y = (OldAccel >>> 15) & 255;
            if ( Accel.Y > 127 )
                Accel.Y = -1 * (Accel.Y - 128);
            Accel.Z = (OldAccel >>> 7) & 255;
            if ( Accel.Z > 127 )
                Accel.Z = -1 * (Accel.Z - 128);
            Accel *= 20;

            OldbRun = ( (OldAccel & 64) != 0 );
            OldbDoubleJump = ( (OldAccel & 32) != 0 );
            NewbPressedJump = ( (OldAccel & 16) != 0 );
            if ( NewbPressedJump )
                bJumpStatus = NewbJumpStatus;
            switch (OldAccel & 7)
            {
                case 0:
                    OldDoubleClickMove = DCLICK_None;
                    break;
                case 1:
                    OldDoubleClickMove = DCLICK_Left;
                    break;
                case 2:
                    OldDoubleClickMove = DCLICK_Right;
                    break;
                case 3:
                    OldDoubleClickMove = DCLICK_Forward;
                    break;
                case 4:
                    OldDoubleClickMove = DCLICK_Back;
                    break;
            }
            //log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
            OldTimeStamp = FMin(OldTimeStamp, CurrentTimeStamp + MaxResponseTime);
            MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, (bDuck == 1), NewbPressedJump, OldbDoubleJump, OldDoubleClickMove, Accel, rot(0,0,0));
            CurrentTimeStamp = OldTimeStamp;
        }
    }

    // View components
    ViewPitch = View/32768;
    ViewYaw = 2 * (View - 32768 * ViewPitch);
    ViewPitch *= 2;

    // Make acceleration.
    Accel = InAccel/10;

    NewbPressedJump = (bJumpStatus != NewbJumpStatus);
    bJumpStatus = NewbJumpStatus;

    // Save move parameters.
    DeltaTime = FMin(MaxResponseTime,TimeStamp - CurrentTimeStamp);

    /*
    if ( ServerTimeStamp > 0 )
    {
        // allow 1% error
        TimeMargin = FMax(0,TimeMargin + DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp));
        if ( TimeMargin > MaxTimeMargin )
        {
            // player is too far ahead
            TimeMargin -= DeltaTime;
            if ( TimeMargin < 0.5 )
                MaxTimeMargin = Default.MaxTimeMargin;
            else
                MaxTimeMargin = 0.5;
            DeltaTime = 0;
        }
    }*/

    CurrentTimeStamp = TimeStamp;
    ServerTimeStamp = Level.TimeSeconds;
    ViewRot.Pitch = ViewPitch;
    ViewRot.Yaw = ViewYaw;
    ViewRot.Roll = 0;
    SetRotation(ViewRot);

    if ( Pawn != None )
    {
        Rot.Roll = 256 * ClientRoll;
        Rot.Yaw = ViewYaw;
        if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
            maxPitch = 2;
        else
            maxPitch = 0;
        If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
        {
            If (ViewPitch < 32768)
                Rot.Pitch = maxPitch * RotationRate.Pitch;
            else
                Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
        }
        else
            Rot.Pitch = ViewPitch;
        DeltaRot = (Rotation - Rot);
        Pawn.SetRotation(Rot);
    }

    // Perform actual movement
    if ( (Level.Pauser == None) && (DeltaTime > 0) )
        MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, DoubleClickMove, Accel, DeltaRot);

	if( Pawn!=None && Pawn.Physics == PHYS_RidingBase )// we will trust that the vehicles correct themselves nicely, and that any riders position is automatically correct
	{
		//keep the last update time current incase it's used for something else

		if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
			LastUpdateTime = Level.TimeSeconds;
		//log("Skipping adjustposition for "$Pawn);
		return;

	}


    // Accumulate movement error.
    if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
        ClientErr = 10000;
    else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
    {
        if ( Pawn == None )
            LocDiff = Location - ClientLoc;
        else
            LocDiff = Pawn.Location - ClientLoc;
        ClientErr = LocDiff Dot LocDiff;
    }

    // If client has accumulated a noticeable positional error, correct him.
    if ( ClientErr > 3 )
    {
        if ( Pawn == None )
        {
            ClientPhysics = Physics;
            ClientLoc = Location;
            ClientVel = Velocity;
        }
        else
        {
            ClientPhysics = Pawn.Physics;
            ClientVel = Pawn.Velocity;
            ClientBase = Pawn.Base;
            if ( Mover(Pawn.Base) != None )
                ClientLoc = Pawn.Location - Pawn.Base.Location;
            else
                ClientLoc = Pawn.Location;
            ClientFloor = Pawn.Floor;
        }
        //log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
        LastUpdateTime = Level.TimeSeconds;

        if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
        {
            if ( ClientVel == vect(0,0,0) )
            {
                ShortClientAdjustPosition
                (
                    TimeStamp,
                    GetStateName(),
                    ClientPhysics,
                    ClientLoc.X,
                    ClientLoc.Y,
                    ClientLoc.Z,
                    ClientBase
                );
            }
            else if ( GetStateName()=='PlayerWalking' ) // sjs - quantize velocity and assume walking
            {
                ClientAdjustPositionWalking
                (
                    TimeStamp,
                    ClientPhysics,
                    ClientLoc.X,
                    ClientLoc.Y,
                    ClientLoc.Z,
                    ClientVel * 100.0,
                    ClientBase
                );
            }
            else
            {
                ClientAdjustPosition
                (
                    TimeStamp,
                    GetStateName(),
                    ClientPhysics,
                    ClientLoc.X,
                    ClientLoc.Y,
                    ClientLoc.Z,
                    ClientVel.X,
                    ClientVel.Y,
                    ClientVel.Z,
                    ClientBase
                );
            }
        }
        else
            LongClientAdjustPosition
            (
                TimeStamp,
                GetStateName(),
                ClientPhysics,
                ClientLoc.X,
                ClientLoc.Y,
                ClientLoc.Z,
                ClientVel.X,
                ClientVel.Y,
                ClientVel.Z,
                ClientBase,
                ClientFloor.X,
                ClientFloor.Y,
                ClientFloor.Z
            );
    }
    //log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}

// Only executed on server
function ServerDrive(float InForward, float InStrafe, bool InJump)
{
	ProcessDrive(InForward, InStrafe, InJump);
}

function ProcessDrive(float InForward, float InStrafe, bool InJump)
{
	Log("ProcessDrive Not Valid Outside State PlayerDriving");
}

function ProcessMove ( float DeltaTime, vector newAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
    if ( Pawn != None )
        Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(
    float DeltaTime,
    bool NewbRun,
    bool NewbDuck,
    bool NewbPressedJump,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    vector newAccel,
    rotator DeltaRot
)
{
    if ( NewbRun )
        bRun = 1;
    else
        bRun = 0;

    if ( NewbDuck )
        bDuck = 1;
    else
        bDuck = 0;
    bPressedJump = NewbPressedJump;
    bDoubleJump = NewbDoubleJump;
    HandleWalking();
    ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
    if ( Pawn != None )
        Pawn.AutonomousPhysics(DeltaTime);
    else
        AutonomousPhysics(DeltaTime);
    bDoubleJump = false;
    //log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

function ClientAdjustPositionWalking // sjs
(
    float TimeStamp,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    Vector NewVel,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    NewVel *= 0.01;

    LongClientAdjustPosition(TimeStamp,'PlayerWalking',newPhysics,NewLocX,NewLocY,NewLocZ,NewVel.X,NewVel.Y,NewVel.Z,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
    float TimeStamp,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase
)
{
    local vector Floor;

    if ( Pawn != None )
        Floor = Pawn.Floor;
    LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase,
    float NewFloorX,
    float NewFloorY,
    float NewFloorZ
)
{
    local vector NewLocation, NewVelocity, NewFloor;
    local Actor MoveActor;
    local SavedMove CurrentMove;

    if ( Pawn != None )
    {
        if ( Pawn.bTearOff )
        {
            Pawn = None;
			if ( !IsInState('GameEnded') && !IsInState('Dead') )
			{
            	GotoState('Dead');
            }
            return;
        }
        MoveActor = Pawn;
        if ( (ViewTarget != Pawn)
			&& ((ViewTarget == self) || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Health <= 0))) )
		{
			bBehindView = false;
			SetViewTarget(Pawn);
		}
    }
    else
    {
        MoveActor = self;
 	   	if( GetStateName() != newstate )
		{
		    if ( NewState == 'GameEnded' )
			    GotoState(NewState);
			else if ( IsInState('Dead') )
			{
		    	if ( (NewState != 'PlayerWalking') && (NewState != 'PlayerSwimming') && (NewState != 'MostlyDead') )
		        {
				    GotoState(NewState);
		        }
		        return;
			}
			else if ( NewState == 'Dead' || NewState == 'MostlyDead')
				GotoState(NewState);
		}
	}
    if ( CurrentTimeStamp > TimeStamp )
        return;
    CurrentTimeStamp = TimeStamp;

    NewLocation.X = NewLocX;
    NewLocation.Y = NewLocY;
    NewLocation.Z = NewLocZ;
    NewVelocity.X = NewVelX;
    NewVelocity.Y = NewVelY;
    NewVelocity.Z = NewVelZ;

	// skip update if no error
    CurrentMove = SavedMoves;
    while ( CurrentMove != None )
    {
        if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
			if ( CurrentMove.TimeStamp == CurrentTimeStamp )
			{
				if ( (VSize(CurrentMove.SavedLocation - NewLocation) < 3)
					&& (VSize(CurrentMove.SavedVelocity - NewVelocity) < 3)
					&& (GetStateName() == NewState) )
				{
					FreeMoves.Clear();
					return;
				}
				FreeMoves.Clear();
				CurrentMove = None;
			}
			else
			{
				FreeMoves.Clear();
				CurrentMove = SavedMoves;
			}
        }
        else
			CurrentMove = None;
    }

    NewFloor.X = NewFloorX;
    NewFloor.Y = NewFloorY;
    NewFloor.Z = NewFloorZ;
    MoveActor.SetBase(NewBase, NewFloor);
    if ( Mover(NewBase) != None )
        NewLocation += NewBase.Location;

    //log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$MoveActor.Location);
    MoveActor.bCanTeleport = false;
    MoveActor.SetLocation(NewLocation);
    MoveActor.bCanTeleport = true;

	// Hack. Don't let network change physics mode of karma stuff on the client.
	if( MoveActor.Physics != PHYS_Karma && MoveActor.Physics != PHYS_KarmaRagDoll &&
		newPhysics != PHYS_Karma && newPhysics != PHYS_KarmaRagDoll )
	{
	    MoveActor.SetPhysics(newPhysics);
	}

    MoveActor.Velocity = NewVelocity;

    if( GetStateName() != newstate
		&& !Pawn.IsA('VGVehicle') )
        GotoState(newstate);

    bUpdatePosition = true;
}

function ClientUpdatePosition()
{
    local SavedMove CurrentMove;
    local int realbRun, realbDuck;
    local bool bRealJump;

	// Dont do any network position updates on things running PHYS_Karma
	if( Pawn != None && (Pawn.Physics == PHYS_Karma || Pawn.Physics == PHYS_KarmaRagDoll || Pawn.IsA('VGVehicle')) )
		return;

    bUpdatePosition = false;
    realbRun= bRun;
    realbDuck = bDuck;
    bRealJump = bPressedJump;
    CurrentMove = SavedMoves;
    bUpdating = true;
    while ( CurrentMove != None )
    {
        if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
            FreeMoves.Clear();
            CurrentMove = SavedMoves;
        }
        else
        {
            if ( (Pawn != None) && (Pawn.Physics != CurrentMove.SavedPhysics) &&
				 (CurrentMove.SavedPhysics != PHYS_None) && (CurrentMove.SavedPhysics != PHYS_Karma) &&
				 Pawn.Physics != PHYS_Karma && Pawn.Physics != PHYS_KarmaRagDoll )
			{
 				Pawn.SetPhysics(CurrentMove.SavedPhysics);
			}
            MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.bDoubleJump, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
            CurrentMove = CurrentMove.NextMove;
        }
    }
    if ( PendingMove != None )
    {
        if ( (Pawn != None) && (Pawn.Physics != PendingMove.SavedPhysics) &&
			 (PendingMove.SavedPhysics != PHYS_None) && (PendingMove.SavedPhysics != PHYS_Karma) &&
			 Pawn.Physics != PHYS_Karma && Pawn.Physics != PHYS_KarmaRagDoll )
		{
			Pawn.SetPhysics(PendingMove.SavedPhysics);
		}
        MoveAutonomous(PendingMove.Delta, PendingMove.bRun, PendingMove.bDuck, PendingMove.bPressedJump, PendingMove.bDoubleJump, PendingMove.DoubleClickMove, PendingMove.Acceleration, rot(0,0,0));
    }

    //log("Client updated "$Pawn$"'s position to "$Pawn.Location);
    bUpdating = false;
    bDuck = realbDuck;
    bRun = realbRun;
    bPressedJump = bRealJump;
}

function AdjustRadius(float MaxMove)
{
/*	local Pawn P;
    local vector Dir, VelDir;

    // if other pawn moving away from player, push it away if its close
    // since the client-side position is behind the server side position
    VelDir = Normal(Pawn.Velocity);
    ForEach DynamicActors(class'Pawn', P)
        if ( (P != Pawn) && (P.Velocity != vect(0,0,0)) && (P.CollisionRadius = P.Default.CollisionRadius) )
        {
            Dir = Normal(P.Location - Pawn.Location);
            if ( (VelDir Dot Dir > 0.7) && (Normal(P.Velocity) Dot Dir > 0.7) )
			{
				P.SetCollisionSize(0.5 * P.CollisionRadius, P.CollisionHeight);
				P.bClientCollision = true;
            }
        }
*/
}

function ReAdjustRadius()
{
    local Pawn P;

    ForEach DynamicActors(class'Pawn', P)
        if ( P.bClientCollision )
        {
			P.SetCollisionSize(P.Default.CollisionRadius, P.CollisionHeight);
            P.bClientCollision = false;
        }
}

final function SavedMove GetFreeMove()
{
    local SavedMove s, first;
    local int i;

    if ( FreeMoves == None )
    {
        // don't allow more than 30 saved moves
        For ( s=SavedMoves; s!=None; s=s.NextMove )
        {
            i++;
            if ( i > 30 )
            {
                first = SavedMoves;
                SavedMoves = SavedMoves.NextMove;
                first.Clear();
                first.NextMove = None;
                // clear out all the moves
                While ( SavedMoves != None )
                {
                    s = SavedMoves;
                    SavedMoves = SavedMoves.NextMove;
                    s.Clear();
                    s.NextMove = FreeMoves;
                    FreeMoves = s;
                }
                return first;
            }
        }
        return Spawn(class'SavedMove');
    }
    else
    {
        s = FreeMoves;
        FreeMoves = FreeMoves.NextMove;
        s.NextMove = None;
        return s;
    }
}

function int CompressAccel(int C)
{
    if ( C >= 0 )
        C = Min(C, 127);
    else
        C = Min(abs(C), 127) + 128;
    return C;
}

/*
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove()
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position,
and sets the bUpdatePosition flag to true.

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
    float DeltaTime,
    vector NewAccel,
    eDoubleClickDir DoubleClickMove,
    rotator DeltaRot
)
{
    local SavedMove NewMove, OldMove, LastMove;
    local byte ClientRoll;
    local float OldTimeDelta, NetMoveDelta;
    local int OldAccel;
    local vector BuildAccel, AccelNorm, MoveLoc;

	// find the most recent move, and the most recent interesting move
    if ( SavedMoves != None )
    {
        LastMove = SavedMoves;
        AccelNorm = Normal(NewAccel);
        while ( LastMove.NextMove != None )
        {
            // find most recent interesting move to send redundantly
            if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
                || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
                OldMove = LastMove;
            LastMove = LastMove.NextMove;
        }
        if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
            || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
            OldMove = LastMove;
    }
    // Get a SavedMove actor to store the movement in.
    if ( PendingMove != None )
        PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

    //if ( (Pawn != None) && (Pawn.Weapon != None) ) // approximate pointing so don't have to replicate
        //Pawn.Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));

    // Simulate the movement locally.
    bDoubleJump = false;
    ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);

    if ( Pawn != None )
        Pawn.AutonomousPhysics(NewMove.Delta);
    else
        AutonomousPhysics(DeltaTime);

    //log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

    if ( PendingMove == None )
        PendingMove = NewMove;
    else
    {
        NewMove.NextMove = FreeMoves;
        FreeMoves = NewMove;
        FreeMoves.Clear();
        NewMove = PendingMove;
    }
    NewMove.PostUpdate(self);
    NetMoveDelta = FMax(100.0/Player.CurrentNetSpeed, 0.025);

    // Decide whether to hold off on move
    // send if double click move, jump, or fire unless really too soon, or if newmove.delta big enough
    // on client side, save extra buffered time in LastUpdateTime
    if ( !PendingMove.bPressedJump && !PendingMove.bDoubleJump
		&& ((PendingMove.DoubleClickMove == DCLICK_None) || (PendingMove.DoubleClickMove == DCLICK_Active))
		&& ((PendingMove.Acceleration == NewAccel) || ((Normal(NewAccel) Dot Normal(PendingMove.Acceleration)) > 0.95))
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
        return;
    }
    else
    {
        ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
        if ( SavedMoves == None )
            SavedMoves = PendingMove;
        else
            LastMove.NextMove = PendingMove;
        PendingMove = None;
    }

    // check if need to redundantly send previous move
    if ( OldMove != None )
    {
        // log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
        // old move important to replicate redundantly
        OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
        BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
        OldAccel = (CompressAccel(BuildAccel.X) << 23)
                    + (CompressAccel(BuildAccel.Y) << 15)
                    + (CompressAccel(BuildAccel.Z) << 7);
        if ( OldMove.bRun )
            OldAccel += 64;
        if ( OldMove.bDoubleJump )
            OldAccel += 32;
        if ( OldMove.bPressedJump )
            OldAccel += 16;
        OldAccel += OldMove.DoubleClickMove;
    }
    //else
    //  log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);
    //log("Replicate move at "$NewMove.TimeStamp$" location "$Pawn.Location);
    // Send to the server
    ClientRoll = (Rotation.Roll >> 8) & 255;
    if ( NewMove.bPressedJump )
        bJumpStatus = !bJumpStatus;

    if ( Pawn == None )
        MoveLoc = Location;
    else
        MoveLoc = Pawn.Location;

    if ( (NewMove.Acceleration == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) && !NewMove.bDoubleJump )
        ShortServerMove
        (
            NewMove.TimeStamp,
            MoveLoc,
            NewMove.bRun,
            NewMove.bDuck,
            bJumpStatus,
            ClientRoll,
            (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))
        );
    else if ( OldTimeDelta==0 && NewMove.bRun==false && NewMove.bDuck==false && bJumpStatus==true && NewMove.bDoubleJump==false && NewMove.DoubleClickMove==DCLICK_None )
    {
        ServerMoveNoDelta
        (
            NewMove.TimeStamp,
            NewMove.Acceleration * 10,
            MoveLoc,
            ClientRoll,
            (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))
        );
    }
    else if ( NewMove.bRun==false && NewMove.bDuck==false && bJumpStatus==false && NewMove.bDoubleJump==false && NewMove.DoubleClickMove==DCLICK_None )
    {
        ServerMoveFrequent
        (
            NewMove.TimeStamp,
            NewMove.Acceleration * 10,
            MoveLoc,
            ClientRoll,
            (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
            OldTimeDelta,
            OldAccel
        );
    }
    else
    {
        //log("ServerMove: "@OldTimeDelta@NewMove.bRun@NewMove.bDuck@bJumpStatus@NewMove.bDoubleJump@NewMove.DoubleClickMove);
        ServerMove
        (
            NewMove.TimeStamp,
            NewMove.Acceleration * 10,
            MoveLoc,
            NewMove.bRun,
            NewMove.bDuck,
            bJumpStatus,
            NewMove.bDoubleJump,
            NewMove.DoubleClickMove,
            ClientRoll,
            (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
            OldTimeDelta,
            OldAccel
        );
    }
}

function HandleWalking()
{
    if ( Pawn != None )
        Pawn.SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') );
}

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
	DesiredFOV = newFOV;
}

function RestoreFOV()
{
    DesiredFOV = DefaultFOV;
	FOVAngle = DesiredFOV;
}

function ClientFlash( float scale, vector fog )
{
	DesiredFlashScale = scale;
    DesiredFlashFog = 0.001 * fog;
}

function ClientSetFlash(vector Scale, vector Fog)
{
    FlashScale=Scale;
    FlashFog=Fog;
}

function ClientInstantFlash( float scale, vector fog )
{
    InstantFlash = scale;
    InstantFog = 0.001 * fog;
}

function ClientAdjustGlow( float scale, vector fog )
{
    ConstantGlowScale += scale;
    ConstantGlowFog += 0.001 * fog;
}

// amb ---
function DamageShake(int damage) //send type of damage too!
{
    ClientDamageShake(damage);
}

// function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)

private function ClientDamageShake(int damage)
{
    // todo: add properties!
	ShakeView( 100 * vect(0.8,0.8,0.8),
               1000 * vect(1,1,1),
               0.15 + 0.02 * damage,
               100 * vect(0.05,0.05,0.05),
               vect(1000,1000,1000),
               2);
}


/*
     ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
     ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
     ShakeRotTime=2
     ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
     ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
     ShakeOffsetTime=2
*/

/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
function ShakeView(vector shRotMag,    vector shRotRate,    float shRotTime,
                   vector shOffsetMag, vector shOffsetRate, float shOffsetTime)
{
	if ( VSize(shRotMag) > VSize(ShakeRotMax) )
    {
		ShakeRotMax  = shRotMag;
        ShakeRotRate = shRotRate;
        ShakeRotTime = shRotTime * vect(1,1,1);
    }

    if ( VSize(shOffsetMag) > VSize(ShakeOffsetMax) )
    {
        ShakeOffsetMax  = shOffsetMag;
        ShakeOffsetRate = shOffsetRate;
        ShakeOffsetTime = shOffsetTime * vect(1,1,1);
    }
}
// --- amb

function damageAttitudeTo(pawn Other, float Damage)
{
    if ( (Other != None) && (Other != Pawn) && (Damage > 0) )
        Enemy = Other;
}

function Typing( bool bTyping )
{
    bIsTyping = bTyping;
    if ( bTyping && (Pawn != None) && !Pawn.bTearOff )
        Pawn.ChangeAnimation();

}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function Jump( optional float F )
{
    if ( Level.Pauser == PlayerReplicationInfo )
        SetPause(False);
    else
        bPressedJump = true;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( name Type, int Index, string Callsign )
{
	if( Pawn != None && Pawn.Health > 0 && PlayerReplicationInfo.VoiceType != None )
		PlayerReplicationInfo.VoiceType.static.PlayerSpeech( Type, Index, Callsign, Self );
}

exec function RestartLevel()
{
    if( Level.Netmode==NM_Standalone )
        ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
    if( Level.Netmode==NM_Standalone )
        ClientTravel( URL, TRAVEL_Relative, true );
}

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
exec function QuickSave()
{
    if ( (Pawn.Health > 0)
        && (Level.NetMode == NM_Standalone) )
    {
        ClientMessage(QuickSaveString);
        ConsoleCommand("SaveGame 9");
    }
}

/* QuickLoad()
Load game from slot 9
*/
//exec function QuickLoad()
//{
//    if ( Level.NetMode == NM_Standalone )
//        ClientTravel( "?load=9", TRAVEL_Absolute, false);
//}

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games. // gam -- What you say?
 */
function bool SetPause( BOOL bPause )
{
    if( Level.Game == None )
        return false;

    bFire = 0;
    bAltFire = 0;
    return(Level.Game.SetPause(bPause, self));
}

/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
    local bool WasPaused;

    WasPaused = (Level.Pauser != None);

    // sjs - don't allow split-screen players to unpause for others
    if( WasPaused && (Level.Pauser != PlayerReplicationInfo) )
        return;

    // Don't let them pause if they're in a menu.
    if( !WasPaused && (Player.Console != None) && (Player.Console.curMenu != None) )
        return;

    if( !SetPause(!WasPaused) )
    {
        // Only bitch if they were trying to pause.
        if( !WasPaused )
            ClientMessage(NoPauseMessage);
    }
}

simulated function PauseAndShowMenu( String MenuClassName, String Args )
{
    local class<Menu> MenuClass;
    local bool WasPaused;

    WasPaused = (Level.Pauser != None);

    // Don't allow split-screen players to unpause for others
    if( WasPaused && (Level.Pauser != PlayerReplicationInfo) )
        return;

    // Don't let them pause if they're in a menu.
    if( !WasPaused && (Player.Console != None) && (Player.Console.curMenu != None) )
        return;

    SetPause(!WasPaused);
    
	// Open the menu if they were trying to pause.
	if( !WasPaused )
	{
		ClientStopForceFeedback();

		MenuClass = class<Menu>( DynamicLoadObject( MenuClassName, class'Class' ) );

		if( MenuClass == None )
		{
			log( "Could not load" @ MenuClassName, 'Error' );
			return;
		}
		MenuOpen( MenuClass, Args );
	}
}

exec function ShowVoiceMenu()
{
    local class<Menu> MenuClass;
    local String MenuClassName;

    if (Level == None || Level.InCinematic() || MyHud.bInMatinee)
    {
        return;
    }

    if( (Level.Game != None) && Level.Game.bSinglePlayer )
    {
        return;
    }
    
    if (CurrentMenu() != None || Pawn == None)
    {
        return;
    }
    
    bFire = 0;
    bAltFire = 0;

    MenuClassName = "XInterfaceHuds.OverlayVoiceChannelMenu";

	MenuClass = class<Menu>( DynamicLoadObject( MenuClassName, class'Class' ) );

	if( MenuClass == None )
	{
		log( "Could not load" @ MenuClassName, 'Error' );
		return;
	}
	
	MenuOpen( MenuClass, "" );
}

simulated function int WeaponCount()
{
    local Inventory i;
    local int Count;
    
    for( i = Pawn.Inventory; i != None; i = i.Inventory )
    {
        if( I.IsA('Weapon') )
        {
            ++Count;
        }
    }
    
    return(Count);
}

exec function ShowWeaponMenu()
{
    local class<Menu> MenuClass;
    local String MenuClassName;

    if(Level == None || Level.InCinematic() || MyHud.bInMatinee || IsInState('GameEnded') || Pawn.Physics == PHYS_ladder) //cmr -- no changing on ladder
    {
        return;
    }

    if( CurrentMenu() != None )
    {
        return;
    }
    
    if(Pawn == None)
    {
        return;
    }
 
    if( WeaponCount() == 0 )
    {
        return;
    }
    
	if(Pawn.Weapon.IsA('VehicleWeapon') )
	{
		return;
    }
    
    bFire = 0;
    bAltFire = 0;
    
    MenuClassName = "XInterfaceHuds.OverlayWeaponPie";

	MenuClass = class<Menu>( DynamicLoadObject( MenuClassName, class'Class' ) );

	if( MenuClass == None )
	{
		log( "Could not load" @ MenuClassName, 'Error' );
		return;
	}
	
	MenuOpen( MenuClass, "" );
}

exec function ShowMenu()
{
    if
    (
        IsMiniEd() || 
        Level == None ||
        !Level.IsPausable() ||
        !Level.AllowStartMenu() || 
        CurrentMenu() != None
    )
    {
        return;
    }
    PauseAndShowMenu("XInterfaceCommon.MenuPause", "RESET");
}

/*
	Desc: For MiniEd. If done trying the map, call this to return to editing
*/
exec function PressedStart()
{
	if( !bMiniEdEditing )
	{
		bMiniEdEditing = true;
		ConsoleCommand( "TRYMAP OUT" );
	}
}


// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
    local Powerups Inv;

    Inv = Powerups(Pawn.FindInventoryType(InvItem));
    if ( Inv != None )
        Inv.Activate();
}

// ------------------------------------------------------------------------
// Weapon changing functions

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/

// amb ---
exec function ThrowWeapon()
{
    if (Pawn == None || !Pawn.CanThrowWeapon())
        return;

    ServerThrowWeapon();
}

function ServerThrowWeapon()
{
    local Vector TossVel;

    if (Pawn.CanThrowWeapon())
    {
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
        Pawn.TossWeapon(TossVel);
        ClientSwitchToBestWeapon();
    }
}
// --- amb

// sjs --- vote methods
exec function CallVote(Name VoteType, int ContextID)
{
    if( PlayerReplicationInfo.NextVoteCallTime > Level.TimeSeconds )
    {
        log("CallVote throttled vote",'Voting');
        return;
    }
    PlayerReplicationInfo.NextVoteCallTime = Level.TimeSeconds + PlayerReplicationInfo.VoteCallThrottle;
    ServerCallVote( VoteType, ContextID );
}

function ServerCallVote(Name VoteType, int ContextID)
{
    log("ServerCallVote "$VoteType$" "$ContextID,'Voting');
    Level.Game.GameReplicationInfo.CallVote( self, VoteType, ContextID );
}

exec function CastVote(int VoteID)
{
    ServerCastVote( VoteID );
}

function ServerCastVote(int VoteID)
{
    log("ServerCastVote "$VoteID,'Voting');
    Level.Game.GameReplicationInfo.CastVote( self, VoteID );
}
// --- sjs


/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
    if( Level.Pauser!=None )
        return;

	if(Pawn.Weapon.IsA('VehicleWeapon') || Pawn.Physics == PHYS_Ladder) //cmr - no switch on ladders
		// don't switch weapons if operating a vehicle mounted weapon
		return;

    if ( Pawn.Weapon == None )
    {
        SwitchToBestWeapon();
        return;
    }
    if ( Pawn.PendingWeapon != None )
    {
        if (Pawn.PendingWeapon.bForceSwitch)
            return;
        Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.PendingWeapon);
    }
    else
        Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.Weapon);

    if ( Pawn.PendingWeapon != None )
    {
        Pawn.Weapon.PutDown();
    }
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
    if( Level.Pauser!=None )
        return;

	if(Pawn.Weapon.IsA('VehicleWeapon') || Pawn.Physics==PHYS_Ladder) //cmr - no switch on ladders
		// don't switch weapons if operating a vehicle mounted weapon
		return;

	if ( Pawn.Weapon == None )
    {
        SwitchToBestWeapon();
        return;
    }
    if ( Pawn.PendingWeapon != None )
    {
        if (Pawn.PendingWeapon.bForceSwitch)
            return;
        Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.PendingWeapon);
    }
    else
        Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.Weapon);

    if ( Pawn.PendingWeapon != None )
    {
        Pawn.Weapon.PutDown();
		//For now only use weapon dynamic light if it is the bulldog
		//if( Pawn.Weapon.IsA ('VGAssaultRifle') )
		//	SetupWeaponDynLight();
    }
}

// The player wants to switch to weapon group number F.
exec function SwitchWeapon (byte F )
{
    local weapon newWeapon;

    if ( (Pawn == None) || (Pawn.Inventory == None) )
        return;

    if( Pawn.Weapon != None && Pawn.Weapon.IsA('VehicleWeapon') )
		// don't switch weapons if operating a vehicle mounted weapon
		return;

    if ( (Pawn.Weapon != None) && (Pawn.Weapon.Inventory != None) )
        newWeapon = Pawn.Weapon.Inventory.WeaponChange(F);
    else
        newWeapon = None;
    if ( newWeapon == None && Pawn.Inventory != None && Pawn.Weapon != None )
        newWeapon = Pawn.Inventory.WeaponChange(F, Pawn.Weapon.Inventory);

    if ( newWeapon == None )
        return;

    if ( Pawn.PendingWeapon != None && Pawn.PendingWeapon.bForceSwitch )
        return;

    // reset lastweapongroup so you can switch from bonesaw to a different weapon properly with wheel menu
    // 20 = grenade detonator
    if(F != MeleeGroup && F != HealingToolGroup && F != 20)
    {
        LastWeaponGroup = F;
    }

    if ( Pawn.Weapon == None )
    {
        Pawn.PendingWeapon = newWeapon;
        Pawn.ChangedWeapon();
    }
    else if ( Pawn.Weapon != newWeapon || Pawn.PendingWeapon != None )
    {
        Pawn.PendingWeapon = newWeapon;
        Pawn.Weapon.PutDown();
    }
    else if ( Pawn.Weapon == newWeapon )
    {
        Pawn.Weapon.Reselect(); // sjs
    }
}

exec function ToggleHealingTool()
{
	if(Pawn.Weapon.InventoryGroup == HealingToolGroup)
	{
	    log("ToggleHealingTool: SwitchWeapon(LastWeaponGroup)");
		SwitchWeapon(LastWeaponGroup);
	}
	else
	{
		if(Pawn.Weapon.InventoryGroup != MeleeGroup && Pawn.Weapon.InventoryGroup != VirusGroup)
			LastWeaponGroup = Pawn.Weapon.InventoryGroup;
		SwitchWeapon(HealingToolGroup);
		log("ToggleHealingTool: SwitchWeapon(HealingToolGroup)");
	}
}

exec function Melee()
{
    if(Pawn == None || Pawn.Weapon == None)
    {
        return;
    }
	if(Pawn.Weapon.InventoryGroup == MeleeGroup) 
	{
		SwitchWeapon(LastWeaponGroup);
	}
	else 
	{
		// switch to the melee weapon
		SwitchWeapon(MeleeGroup);
	}
}

simulated function StopMelee()
{
    if(Pawn != None && Pawn.PendingWeapon != None)
    {
        SwitchWeapon(Pawn.PendingWeapon.InventoryGroup);
    }
    else
    {
	    SwitchWeapon(LastWeaponGroup);
    }
}

exec simulated function SwitchFireMode()
{
	if(Pawn.Weapon != none)
		// switch the fire mode for the current weapon - cycles through any available mode
		Pawn.Weapon.SwitchFireMode();
}

exec function Virus()
{
	if(Pawn.Weapon.InventoryGroup == VirusGroup)
		SwitchWeapon(LastWeaponGroup);
	else {
//		log("Trying to use virus power!");
		if(Pawn.Weapon.InventoryGroup != MeleeGroup && Pawn.Weapon.InventoryGroup != VirusGroup)
			LastWeaponGroup = Pawn.Weapon.InventoryGroup;
		SwitchWeapon(VirusGroup);
	}
}

simulated function VirusEnd()
{
	if(Pawn.Weapon.InventoryGroup != MeleeGroup && Pawn.Weapon.InventoryGroup != HealingToolGroup)
		SwitchWeapon(LastWeaponGroup);
}

exec simulated function ReloadWeapon()
{
	if(Pawn.Weapon != none && Pawn.Weapon.CanReload() && Pawn.Physics != PHYS_Ladder && Pawn.DashState != DSX_Dashing) //cmr no reloading on ladder	 or while dashing
		Pawn.Weapon.ManualReload();
	else
	    PlayBeepSound();
}

exec function QuickFire(byte F)
{
	if(Pawn.IsA('VGVehicle'))
	{
		bQuickFire = true;
		QuickReturn = Pawn.Weapon.InventoryGroup;
		SwitchWeapon(F);
	}
	Fire();
}

exec function QuickBack()
{
	if(bQuickFire)
	{
		if(Pawn.IsA('VGVehicle'))
		{
			SwitchWeapon(QuickReturn);
		}
		bQuickFire = false;
	}
	Fire();
}

//XJ using keys to give weapons.
exec function GiveWeapon(String weaponString)
{
	Pawn.GiveWeapon(weaponString);
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
    local Inventory Inv;

    if ( (Pawn.Inventory == None) || (NewWeaponClass == None) )
        return;

	if(Pawn.Weapon.IsA('VehicleWeapon') )
		// don't switch weapons if operating a vehicle mounted weapon
		return;

    if ( (Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass) && (Pawn.PendingWeapon == None) )
    {
        Pawn.Weapon.Reselect();
        return;
    }

    if ( Pawn.PendingWeapon != None && Pawn.PendingWeapon.bForceSwitch )
        return;

    for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        if ( Inv.Class == NewWeaponClass )
        {
            Pawn.PendingWeapon = Weapon(Inv);
            if ( !Pawn.PendingWeapon.HasAmmo() )
            {
                ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
                Pawn.PendingWeapon = None;
                return;
            }
            Pawn.Weapon.PutDown();
            return;
        }
    }
}

// The player wants to select previous item
exec function PrevItem()
{
    local Inventory Inv;
    local Powerups LastItem;

    if ( Level.Pauser!=None )
        return;
    if (Pawn.SelectedItem==None)
    {
        Pawn.SelectedItem = Pawn.Inventory.SelectNext();
        Return;
    }
    if (Pawn.SelectedItem.Inventory!=None)
        for( Inv=Pawn.SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory )
        {
            if (Inv==None) Break;
            if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
        }
    for( Inv=Pawn.Inventory; Inv!=Pawn.SelectedItem; Inv=Inv.Inventory )
    {
        if (Inv==None) Break;
        if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
    }
    if (LastItem!=None)
        Pawn.SelectedItem = LastItem;
}

// The player wants to active selected item
exec function ActivateItem()
{
    if( Level.Pauser!=None )
        return;
    if ( (Pawn != None) && (Pawn.SelectedItem!=None) )
        Pawn.SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
    //don't fire if you are actually trying to end a
    //cinematic
    if (Level.StopCinematic()){
        bFire=0;
        bAltFire=0;
    } else {
        //otherwise do normal fire stuff
        if ( Level.Pauser == PlayerReplicationInfo )
        {
            SetPause(false);
            return;
        }
	    if( bDemoOwner || Pawn == None || Pawn.Weapon == None )
		    return;
            Pawn.Weapon.Fire(F);
        }
    }

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }
	if( bDemoOwner || Pawn == None || Pawn.Weapon == None )
		return;
        Pawn.Weapon.AltFire(F);
}

// The player wants to use something in the level.

exec function Use()
{
	if( FindUsable() )
	{
		ServerUse();
    }
}

simulated function bool FindUsable()
{
    local Actor A;
	local Vector Center;
	local bool bUsed;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return true;
    }

    if (Pawn==None)
        return true;

	Center = Pawn.Location + ((Vect(1,0,0)*UseDistance) >> Pawn.Rotation);

	ForEach Pawn.CollidingActors(class'Actor',A, UseRadius, Center)
	{
		//cmr potentially put a distance limit in here, so we use a half sphere or something instead.
		log(A);
		if(A.bUsable)
		{
			if(VSize(A.Location - Pawn.Location) < UseLimit)
			{
				log("Found Usable");
				bUsed = true;
			}
		}
	}

	return bUsed;
}

function bool ServerUse()
{
    local Actor A;
	local Vector Center;
	local bool bUsed;
	//local origin o;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return true;
    }

    if (Pawn==None)
        return true;

	Center = Pawn.Location + ((Vect(1,0,0)*UseDistance) >> Pawn.Rotation);

	//o = spawn(class'Origin',,,Center);
	//o.LifeSpan=10;

	//o = spawn(class'Origin',,,Center + ((Vect(1,0,0)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;
	//o = spawn(class'Origin',,,Center + ((Vect(-1,0,0)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;
	//o = spawn(class'Origin',,,Center + ((Vect(0,1,0)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;
	//o = spawn(class'Origin',,,Center + ((Vect(0,-1,0)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;

	//o = spawn(class'Origin',,,Center + ((Vect(0,0,1)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;
	//o = spawn(class'Origin',,,Center + ((Vect(0,0,-1)*Radius) >> Pawn.Rotation));
	//o.LifeSpan=10;

	ForEach Pawn.CollidingActors(class'Actor',A, UseRadius, Center)
	{
		//cmr potentially put a distance limit in here, so we use a half sphere or something instead.
		log(A);
		if(A.bUsable)
		{
			if(VSize(A.Location - Pawn.Location) < UseLimit)
			{
				log("Usable");
				A.UsedBy(Pawn);
				bUsed = true;
			}
		}
	}

	return bUsed;
}

exec function Suicide()
{
    Pawn.KilledBy( Pawn );
}

exec function Name( coerce string S )
{
    ChangeName(S);
    UpdateURL("Name", S, true);
    SaveConfig();
}

exec function SetName( coerce string S)
{
    ChangeName(S);
    UpdateURL("Name", S, true);
    SaveConfig();
}

function ChangeName( coerce string S )
{
    if ( Len(S) > 28 )
        S = left(S,28);
    S = ReplaceSubstring(S, " ", "_");

    log(self$" ChangeName called s="$s);
    
    Level.Game.ChangeName( self, S, false );
}

exec function SwitchTeam()
{

	if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
        ChangeTeam(0);
    else
        ChangeTeam(1);

}

exec function ChangeTeam( int N )
{
    local TeamInfo OldTeam;
    local XBoxAddr EmptyAddr;

    OldTeam = PlayerReplicationInfo.Team;
    Level.Game.ChangeTeam(self, N);

    if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
    {
        
		if(Pawn != None)
			Pawn.Died( None, class'DamageType', Pawn.Location );

		// cmr -- change pawn class to reflect team change
        SetPawnClass("", Level.Game.GetCharacterClass(PlayerReplicationInfo.Team), Level.Game.DefaultPlayerClassName);



        // jij ---
        // also, force the client to cycle to the next available voice channel
        ServerChangeChannel(Self, EmptyAddr, 0, -3 );
        // --- jij
    }
}


exec function SwitchLevel( string URL )
{
    if( Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
        Level.ServerTravel( URL, false );
}

exec function ClearProgressMessages()
{
    local int i;

    for (i=0; i<ArrayCount(ProgressMessage); i++)
    {
        ProgressMessage[i] = "";
        ProgressColor[i] = class'Canvas'.Static.MakeColor(255,255,255);
    }
}

exec event SetProgressMessage( int Index, string S, color C )
{
    if ( Index < ArrayCount(ProgressMessage) )
    {
        ProgressMessage[Index] = S;
        ProgressColor[Index] = C;
    }
}

exec event SetProgressTime( float T )
{
    ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
    Super.Restart();
    //log("PlayerController::Restart"@self@GetStateName());
    ServerTimeStamp = 0;
    TimeMargin = 0;
    EnterStartState();
    SetViewTarget(Pawn);
    ResetView();
	//EndZoom();
    ClientRestart();
}

function EnterStartState()
{
    local name NewState;

    if ( Pawn.PhysicsVolume.bWaterVolume )
    {
        if ( Pawn.HeadVolume.bWaterVolume )
            Pawn.BreathTime = Pawn.UnderWaterTime;
        NewState = Pawn.WaterMovementState;
    }
    else
        NewState = Pawn.LandMovementState;

    if ( IsInState(NewState) )
        BeginState();
    else
        GotoState(NewState);
}

function ClientRestart()
{
    if ( Pawn == None )
    {
        GotoState('WaitingForPawn');
        return;
    }
    Pawn.ClientRestart();
    CleanOutSavedMoves(); // sjs - MP
    SetViewTarget(Pawn);
    ResetView();
    EnterStartState();
}

exec function BehindView( Bool B )
{
    bBehindView = B;
    ClientSetBehindView(bBehindView);
}

//=============================================================================
// functions.

// Just changed to pendingWeapon
function ChangedWeapon()
{
    if ( Pawn.PendingWeapon != None )
        Pawn.PendingWeapon.SetHand(Handedness);
}

event TravelPostAccept()
{
    if ( Pawn.Health <= 0 )
        Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
	local float localAUp;
    PlayerInput.PlayerInput(DeltaTime);
    if ( bUpdatePosition )
        ClientUpdatePosition();
    PlayerMove(DeltaTime);
	if(Pawn != none && Pawn.Weapon != none)
	{
		localAUp = aUp;
		if(Pawn.Physics == PHYS_Falling)
		{
			if(Pawn.Velocity.Z > 0)
				localAUp = 24000.0;
			else
				localAUp = -24000.0;
		}

		Pawn.Weapon.SetMovementValues(aTurn, aLookUp, aForward, aStrafe, localAUp);
	}
}

event CameraTick( float DeltaTime )
{

}

function PlayerMove(float DeltaTime);

//
/* 774Aim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
    local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
    local actor BestTarget;
    local float bestAim, bestDist, projspeed;
    local actor HitActor;
    local bool bNoZAdjust, bLeading;
    local rotator AimRot;

    FireDir = vector(Rotation);
    if ( FiredAmmunition.bInstantHit )
        HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
    else
        HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
    if ( (HitActor != None) && HitActor.bProjTarget )
    {
        BestTarget = HitActor;
        bNoZAdjust = true;
        OldAim = HitLocation;
        BestDist = VSize(BestTarget.Location - Pawn.Location);
    }
    else
    {
        // adjust aim based on FOV
        bestAim = 0.90;
        if ( bAutoAim )
        {
            bestAim = 0.93;
            if ( FiredAmmunition.bInstantHit )
                bestAim = 0.97;
            if ( FOVAngle < DefaultFOV - 8 )
                bestAim = 0.99;
        }
        else if ( FiredAmmunition.bInstantHit )
                bestAim = 1.0;
        BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart, FiredAmmunition.MaxRange); //amb
        if ( BestTarget == None )
        {
            if (bBehindView)
                return Pawn.Rotation;
            else
				return Rotation;
        }
        OldAim = projStart + FireDir * bestDist;
    }
	FiredAmmunition.WarnTarget(BestTarget,Pawn,FireDir);
    if( !bAutoAim )
    {
        if (bBehindView)
            return Pawn.Rotation;
        else
            return Rotation;
    }

    // aim at target - help with leading also
    if ( !FiredAmmunition.bInstantHit )
    {
        projspeed = FiredAmmunition.ProjectileClass.default.speed;
        BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart);
        bLeading = true;
        FireDir = BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
        // if splash damage weapon, try aiming at feet - trace down to find floor
        if ( FiredAmmunition.bTrySplash
            && ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
        {
            HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
            if ( (HitActor != None)
				&& FastTrace(HitLocation + vect(0,0,4),projstart) ) {
                return rotator(HitLocation + vect(0,0,6) - projStart);
			}
        }
    }
    else
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }
    AimOffset = AimSpot - OldAim;

    // adjust Z of shooter if necessary
    if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
        AimSpot.Z = OldAim.Z;
    else if ( AimOffset.Z < 0 )
        AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
    else
        AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

    if ( !bLeading )
    {
        // if not leading, add slight random error ( significant at long distances )
        if ( !bNoZAdjust )
        {
            AimRot = rotator(AimSpot - projStart);
            if ( FOVAngle < DefaultFOV - 8 )
                AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
            else
                AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
            return AimRot;
        }
    }
    else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
    {
        FireDir = BestTarget.Location - projStart;
        AimSpot = projStart + bestDist * Normal(FireDir);
    }

    return rotator(AimSpot - projStart);
}

function bool NotifyLanded(vector HitNormal)
{
    return bUpdating;
}

function UpdateTarget(vector ProjStart, Weapon FiredWeapon)
{
	local	vector	fireDir;
	local	float	CorrectedHorzRange,CorrectedVertRange, CorrectedRange;

	local	Actor	HitActor;
	local	Pawn	HitPawn;
	local	vector	HitLocation, HitNormal;

	CurrentAimVert = DesiredAimVert;
	CurrentAimHorz = DesiredAimHorz;

	if(FiredWeapon == none)
	{
		Target = none;
		return;
	}

	fireDir = vector(FiredWeapon.Rotation);

	HitActor = Trace(HitLocation, HitNormal, projStart + AutoAimMaxDistance * FireDir, projStart, true);
	HitPawn = Pawn(HitActor);
	if ( (HitPawn != None) && HitPawn.bProjTarget && (!FiredWeapon.bOnlyTargetVehicles || HitPawn.IsA('VGVehicle'))
		&& (HitPawn.PlayerReplicationInfo != None) )
		//&& ((PlayerReplicationInfo.Team == None)
		//|| (HitPawn.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)) )
	{
		Target = HitActor;
		return;
	}

	//no autoaim, so use default values
	if(FiredWeapon.AutoAimFactor == 0.0)
	{
		CorrectedHorzRange = AutoAimHorizontal;
		CorrectedVertRange = AutoAimVertical;
		CorrectedRange = AutoAimMaxDistance;
	}
	else
	{
		CorrectedHorzRange = AutoAimHorizontal * FiredWeapon.AutoAimFactor;
		CorrectedVertRange = AutoAimVertical * FiredWeapon.AutoAimFactor;
		CorrectedRange = AutoAimMaxDistance * FiredWeapon.AutoAimRangeFactor;
	}

	if(Pawn.IsA('VGVehicle') && Pawn.Weapon.bAutoTarget)
	{
		CorrectedHorzRange *= 10.0;
		CorrectedVertRange *= 10.0;	//need much more vert aiming
	}
	target = SelectTarget(CorrectedHorzRange,CorrectedVertRange,CorrectedRange,ProjStart,fireDir,FiredWeapon.bOnlyTargetVehicles,true);
}

function rotator AutoAim(vector ProjStart, Weapon FiredWeapon)
{
	local	rotator TempRotation;

	if(FiredWeapon != none && FiredWeapon.IsA('VehicleWeapon') )
    {
		TempRotation = FiredWeapon.ThirdPersonActor.Rotation;
	}
	else
    {
		TempRotation = Rotation;
	}

	if(FiredWeapon.bIndependantPitch)
    {
		TempRotation.Pitch += FiredWeapon.RealPitch;
	}

	return TempRotation;
}

//=============================================================================
// Player Control


function ResetView()
{
    bBehindView = Pawn.PointOfView();
}



// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
    local float OldDesiredFOV;
       
    if(bZooming && Pawn.Weapon.ZoomFactor > 1.0f)  // mjm - if zooming is active, zoom in!
    {
        DesiredFOV = DefaultFOV / Pawn.Weapon.ZoomFactor;
    }
    
    OldDesiredFOV = DesiredFOV;
    
    if(Pawn != None && Pawn.Weapon != None && Pawn.Weapon.IsInState('Reload'))
    {
        DesiredFOV = DefaultFOV;
    }
    
    if ( FOVAngle != DesiredFOV )
    {
        if ( FOVAngle > DesiredFOV )
            FOVAngle = FOVAngle - FMax(5, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
        else
            FOVAngle = FOVAngle - FMin(-5, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
        if ( Abs(FOVAngle - DesiredFOV) <= 3 )
            FOVAngle = DesiredFOV;
    }
    DesiredFOV = OldDesiredFOV;
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist;
    local vector globalX,globalY,globalZ;
    local vector localX,localY,localZ;

    CameraRotation = Rotation;

    // add view rotation offset to cameraview (amb)
    CameraRotation += CameraDeltaRotation;

    View = vect(1,0,0) >> CameraRotation;

    // add view radius offset to camera location and move viewpoint up from origin (amb)
    Dist += CameraDeltaRad;

    if( ViewTarget.Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;
    CameraLocation -= (ViewDist - 30) * View;

    // add view swivel rotation to cameraview (amb)
    GetAxes(CameraSwivel,globalX,globalY,globalZ);
    localX = globalX >> CameraRotation;
    localY = globalY >> CameraRotation;
    localZ = globalZ >> CameraRotation;
    CameraRotation = OrthoRotation(localX,localY,localZ);
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;

    GetAxes(Rotation, x, y, z);

    // First-person view.
    CameraRotation = Normalize(Rotation + ShakeRot); // amb
    CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob + // amb
                     ShakeOffset.X * x +
                     ShakeOffset.Y * y +
                     ShakeOffset.Z * z;
}

event AddCameraEffect(CameraEffect NewEffect,optional bool RemoveExisting)
{
    if(RemoveExisting)
        RemoveCameraEffect(NewEffect);

    CameraEffects.Length = CameraEffects.Length + 1;
    CameraEffects[CameraEffects.Length - 1] = NewEffect;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
    local int   EffectIndex;

    for(EffectIndex = 0;EffectIndex < CameraEffects.Length;EffectIndex++)
        if(CameraEffects[EffectIndex] == ExEffect)
        {
            CameraEffects.Remove(EffectIndex,1);
            return;
        }
}

exec function CreateCameraEffect(class<CameraEffect> EffectClass)
{
    AddCameraEffect(new EffectClass);
}

simulated function PostFXStage FindPostFXStage( class<PostFXStage> StageClass )
{
	local PostFXManager		 mgr;

	mgr = class'PostFXManager'.static.GetPostFXManager( Level );
	return mgr.FindStage( StageClass );
}

simulated function AddPostFXStage( PostFXStage NewStage )
{
	local PostFXManager		 mgr;

	mgr = class'PostFXManager'.static.GetPostFXManager( Level );
	mgr.AddStage( NewStage );
}

simulated function RemovePostFXStage( PostFXStage ExStage )
{
	local PostFXManager		 mgr;

	mgr = class'PostFXManager'.static.GetPostFXManager( Level );
	mgr.RemoveStage( ExStage );
}

function rotator GetViewRotation()
{
    if ( bBehindView && (Pawn != None) )
        return Pawn.Rotation;
    return Rotation;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local Pawn PTarget;

	// If desired, call the pawn's own special callview
	if( Pawn != None && Pawn.bSpecialCalcView )
	{
		// try the 'special' calcview. This may return false if its not applicable, and we do the usual.
		if( Pawn.SpecialCalcView(ViewActor, CameraLocation, CameraRotation) )
			return;
	}

    if ( ViewTarget == None )
    {
        log("No VIEWTARGET in PlayerCalcView");
        if ( bViewBot && (CheatManager != None) )
			CheatManager.ViewBot();
        else if ( Pawn != None )
            SetViewTarget(Pawn);
        else
            SetViewTarget(self);
    }

    ViewActor = ViewTarget;
    CameraLocation = ViewTarget.Location;

    if ( ViewTarget == Pawn )
    {
        if( bBehindView ) //up and behind
            CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
        else
            CalcFirstPersonView( CameraLocation, CameraRotation );
        return;
    }
    if ( ViewTarget == self )
    {
        if ( bCameraPositionLocked )
            CameraRotation = CheatManager.LockedRotation; // sjs - was merge_hack ?
        else
            CameraRotation = Rotation;
        return;
    }

    if ( ViewTarget.IsA('Projectile') && !bBehindView ) // sjs
    {
        CameraLocation += (ViewTarget.CollisionHeight) * vect(0,0,1);
        CameraRotation = Rotation;
        return;
    }

    CameraRotation = ViewTarget.Rotation;
    PTarget = Pawn(ViewTarget);
    if ( PTarget != None )
    {
        if ( Level.NetMode == NM_Client )
        {
            if ( PTarget.IsPlayerPawn() )
            {
                PTarget.SetViewRotation(TargetViewRotation);
                CameraRotation = TargetViewRotation;
            }
            PTarget.EyeHeight = TargetEyeHeight;
            if ( PTarget.Weapon != None )
                PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
        }
        else if ( PTarget.IsPlayerPawn() )
            CameraRotation = PTarget.GetViewRotation();
        if ( !bBehindView )
            CameraLocation += PTarget.EyePosition();
    }
    if ( bBehindView )
    {
        CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
        CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
    }
}

function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time, float dt)
{
    if ( abs(Offset) < abs(MaxOffset) )
        return;

    Offset = MaxOffset;
    if ( Time > 1 )
    {
        if ( Time * abs(MaxOffset/Rate) <= 1 )
            MaxOffset = MaxOffset * (1/Time - 1);
        else
            MaxOffset *= -1;
        Time -= dt;
        Rate *= -1;
    }
    else
    {
        MaxOffset = 0;
        Offset = 0;
        Rate = 0;
    }
}

// amb ---
function UpdateShakeRotComponent(out float max, out int current, out float rate, out float time, float dt)
{
    local float fCurrent;

    current = ((current & 65535) + rate * dt) & 65535;
    if ( current > 32768 )
    current -= 65536;

    fCurrent = current;
    CheckShake(max, fCurrent, rate, time, dt);
    current = fCurrent;
}

function ViewShake(float DeltaTime)
{
    if ( ShakeOffsetRate != vect(0,0,0) )
    {
        // modify shake offset
        ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
        CheckShake(ShakeOffsetMax.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X, DeltaTime);

        ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
        CheckShake(ShakeOffsetMax.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y, DeltaTime);

        ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
        CheckShake(ShakeOffsetMax.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z, DeltaTime);
    }

    if ( ShakeRotRate != vect(0,0,0) )
    {
        UpdateShakeRotComponent(ShakeRotMax.X, ShakeRot.Pitch, ShakeRotRate.X, ShakeRotTime.X, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Y, ShakeRot.Yaw,   ShakeRotRate.Y, ShakeRotTime.Y, DeltaTime);
        UpdateShakeRotComponent(ShakeRotMax.Z, ShakeRot.Roll,  ShakeRotRate.Z, ShakeRotTime.Z, DeltaTime);
    }
}
// --- amb

function bool TurnTowardNearestEnemy();

function ZoomLock(out rotator ViewRotation, float deltaTime)
{
	//this version will snap the target into the view when zooming
	local float FOVScale, PitchDiff, YawDiff, PitchYeild, YawYeild;
	local rotator TargetRotation;
	
	bSetZoomRot = true;
	
	return; // disable zoom lock

	log("selecting target from zoomlock");
	Target = SelectTarget(50,50,9000,Pawn.Location + Pawn.EyePosition(),vector(ViewRotation),false);
	if(Target == none)
		return;

	FOVScale = DesiredFOV * 0.01111; // 0.01111 = 1/90 are we going to use this??
	PitchYeild = 3000.0 * FOVScale;
	YawYeild = 3000.0 * FOVScale;
	TargetRotation = rotator(Target.Location - Pawn.Location);

	YawDiff = (TargetRotation.Yaw & 65535) - (ViewRotation.Yaw & 65535);
	PitchDiff = (TargetRotation.Pitch & 65535) - (ViewRotation.Pitch & 65535);

	if (YawDiff < -32768) yawDiff += 65536;
        else if (yawDiff > 32768) YawDiff -= 65536;

	if (PitchDiff < -32768) pitchDiff += 65536;
        else if (pitchDiff > 32768) PitchDiff -= 65536;


	if(abs(PitchDiff) > PitchYeild)
	{
		if(PitchDiff < 0)
			PitchDiff = PitchDiff + PitchYeild;
		else
			PitchDiff = PitchDiff - PitchYeild;
	}
	else
		PitchDiff = 0.0f;

	if(abs(YawDiff) > YawYeild)
	{
		if(YawDiff < 0)
			YawDiff = YawDiff + YawYeild;
		else
			YawDiff = YawDiff - YawYeild;
	}
	else
		YawDiff = 0.0f;

	ViewRotation.Pitch += PitchDiff;
	ViewRotation.Yaw += YawDiff;
}

function CheckZoomTarget()
{
	local Pawn	pTarget;
	pTarget = Pawn(Target);
	if(pTarget == none)
	{
		Target = none;
		return;
	}
	if(pTarget.Health <= 0)
	{
		Target = none;
		return;
	}
	if(pTarget.LastRenderTime + 0.2 < Level.TimeSeconds)
	{
		Target = none;
		return;
	}
}

function bool AutoPivot(out rotator ViewRotation, float deltaTime)
{
	local vector	TraceStart;
	local pawn		Other;
	local rotator	newRotation;
	local float		yawDiff, pitchDiff, ratio;
	local float		testFloat;


	if(Pawn == None || (aTurn == 0.0 && aStrafe == 0.0 && aForward == 0.0) || !bAutoAim)
		return false;

	TraceStart = Pawn.Location+Pawn.EyePosition();

	Other = Pawn(Target);
	if ( Other != None && (Other.PlayerReplicationInfo != None) && ((PlayerReplicationInfo.Team == None) || (Other.PlayerReplicationInfo.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex)) )
	{
		if ( !bSetTurnRot || Other != LastTarget )
		{
			//PivotLocation = HitLocation;
			LastTarget = Other;
			PivotLocation = TraceStart + Vector(Rotation) * VSize(Other.Location - TraceStart);
			// XJ seeing if using the AutoAimOffset I just made helps
			//PivotLocation = Other.Location + Other.AutoAimOffset;

			bSetTurnRot = true;
		}

		//Predict other's new location;
		PivotLocation += Other.Velocity*deltaTime;

		//Not actually moving the aim around
		//Autopivot to stay mostly on target
		if( aTurn == 0.0 && aLookUp == 0)
		{
			ratio = VSize( PivotLocation - (Pawn.Location+Pawn.EyePosition()) );

			//Mikes magic function attempting to make farther distances drop off quicker.
			//ratio = 1.0 - ratio / 5000.0;
			ratio = 1 - sin(ratio *2*pi/20000);

			ratio *= MaximumAutoPivot;
			newRotation = Rotator(PivotLocation - ( Pawn.Location+Pawn.EyePosition()));

			yawDiff = (newRotation.Yaw & 65535) - (ViewRotation.Yaw & 65535);
			pitchDiff = (newRotation.Pitch & 65535) - (ViewRotation.Pitch & 65535);

			if (yawDiff < -32768) yawDiff += 65536;
				else if (yawDiff > 32768) yawDiff -= 65536;

			if (pitchDiff < -32768) pitchDiff += 65536;
				else if (pitchDiff > 32768) pitchDiff -= 65536;

			ViewRotation.Yaw += ratio * DeltaTime * yawDiff;
			ViewRotation.Yaw += (32.0 -ratio) * DeltaTime * aTurn;

			ratio = 2.0;
			ViewRotation.Pitch += ratio * DeltaTime * pitchDiff;
			ViewRotation.Pitch += (32.0-ratio)* DeltaTime * aLookUp;

		}
		else //player is actually trying to aim
		{
			//slow down aim while "on target" for finer control
			testFloat = 12.0; //32.0
			ViewRotation.Yaw += testFloat * DeltaTime * aTurn;
			ViewRotation.Pitch += testFloat * DeltaTime * aLookUp;
			PivotLocation = TraceStart + Vector(Rotation) * VSize(Other.Location - TraceStart);

		}

		return true;
	}
	return false;
}

function TurnAround()
{
    if ( !bSetTurnRot )
    {
        TurnRot180 = Rotation;
        TurnRot180.Yaw += 32768;
        bSetTurnRot = true;
    }

    DesiredRotation = TurnRot180;
    bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}

// amb ---
function int LimitPitch(int pitch, float deltat)
{
    pitch = pitch & 65535;

    if (pitch > PitchUpLimit && pitch < PitchDownLimit)
    {
        if (aLookUp > 0)
            pitch = PitchUpLimit;
        else
            pitch = PitchDownLimit;
    }

    return pitch;
}
// --- amb

function int LimitYaw(int yaw, float deltat)
{
	return yaw;
}


function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation, ViewRotation;

    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // amb---
    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bFreeCamZoom == True)
        {
            CameraDeltaRad += DeltaTime * 0.25 * aLookUp;
        }
        else if (bFreeCamSwivel == True)
        {
            CameraSwivel.Yaw += 16.0 * DeltaTime * aTurn;
            CameraSwivel.Pitch += 16.0 * DeltaTime * aLookUp;
        }
        else
        {
            CameraDeltaRotation.Yaw += 32.0 * DeltaTime * aTurn;
            CameraDeltaRotation.Pitch += 32.0 * DeltaTime * aLookUp;
        }
    }
    // ---amb
    else
    {
        ViewRotation = Rotation;
        DesiredRotation = ViewRotation; //save old rotation
        if ( bTurnToNearest != 0 )
            TurnTowardNearestEnemy();
        else if ( bTurn180 != 0 )
            TurnAround();
		else if(bZoomed && !bSetZoomRot)
		{
			ZoomLock(ViewRotation, DeltaTime);
			bSetTurnRot = false;
		}
		//else if (AutoPivot(ViewRotation, DeltaTime))
		//{
			//bSetZoomRot = false;
		//}
        else
        {
			if(bZoomed || !AutoPivot(ViewRotation, DeltaTime))
			{
				TurnTarget = None;
				bRotateToDesired = false;
				bSetTurnRot = false;
				//bSetZoomRot = false;
				ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
				if (bSnapToLevel)
					ViewRotation.Pitch = aLookUp;
				else
					ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;

				//if(aLookUp == 0.0 && LadderPitchAdjust != 0)
				//{
				//
				//	ViewRotation.Pitch = InterpToDesired(ViewRotation.Pitch, -2000, 1.0 - (1.0/(2.0**(DeltaTime*5.0))) );

				//	if(ViewRotation.Pitch == 0)
				//		LadderPitchAdjust = 0;
				//}
				//else
				//	LadderPitchAdjust = 0;
			}
        }
        ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch, DeltaTime); //amb
		ViewRotation.Yaw = LimitYaw(ViewRotation.Yaw, DeltaTime);

        SetRotation(ViewRotation);

        ViewShake(deltaTime);
        ViewFlash(deltaTime);

        NewRotation = ViewRotation;
        NewRotation.Roll = Rotation.Roll;

        if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
            Pawn.FaceRotation(NewRotation, deltatime);
    }
}

function ClearDoubleClick()
{
    if (PlayerInput != None)
        PlayerInput.DoubleClickTimer = 0.0;
}

// gam ---
simulated function bool DodgingIsEnabled()
{
    return( (PlayerInput != None) && PlayerInput.bEnableDodging );
}

simulated function SetDodging( bool Enabled )
{
    if( PlayerInput != None)
        PlayerInput.bEnableDodging = Enabled;

    //InputClass.default.bEnableDodging = Enabled;
    //InputClass.static.StaticSaveConfig();
}

simulated function float GetSensitivityX()
{
    return(PlayerInput.GetSensitivityX());
}

simulated function float GetSensitivityY()
{
    return(PlayerInput.GetSensitivityY());
}

simulated function SetSensitivityX( float Sensitivity )
{
    PlayerInput.SetSensitivityX(Sensitivity);
}

simulated function SetSensitivityY( float Sensitivity )
{
    PlayerInput.SetSensitivityY(Sensitivity);
}

// --- gam

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;
        local bool OldCrouch;

        OldAccel = Pawn.Acceleration;
        Pawn.Acceleration = NewAccel;
		if ( bDoubleJump && (bUpdating || Pawn.CanDoubleJump()) )
			Pawn.DoDoubleJump(bUpdating);
        else if ( bPressedJump )
			Pawn.DoJump(bUpdating);

        Pawn.ViewPitch = Clamp(Rotation.Pitch / 256, 0, 255);
		Pawn.ViewYaw = Clamp( (Rotation.Yaw&65535) / 256, 0, 255);

        if ( Pawn.Physics != PHYS_Falling )
        {
            OldCrouch = Pawn.bWantsToCrouch;
            if (bDuck == 0)
                Pawn.ShouldCrouch(false);
            else if ( Pawn.bCanCrouch )
                Pawn.ShouldCrouch(true);
        }

        if( PlayerReplicationInfo != None )
            PlayerReplicationInfo.PlayTime += DeltaTime / Level.TimeDilation;
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        // gam ---
        if( Pawn == None )
        {
            if(!bInterpolating)
				GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }
        // --- gam

		//DesiredAimVert = aLookUp;
		//DesiredAimHorz = aTurn;
		DesiredAimVert = aBaseZ;
		DesiredAimHorz = aBaseX;

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
        NewAccel = aForward*X + aStrafe*Y;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);
        DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);

        GroundPitch = 0;
        ViewRotation = Rotation;
        if ( Pawn.Physics == PHYS_Walking )
        {
            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
            if ( bLookUpStairs && !bSnapToLevel && Pawn.Acceleration != Vect(0,0,0) )
            {
                GroundPitch = FindStairRotation(deltaTime);
                ViewRotation.Pitch = GroundPitch;
                //log("GroundPitch"@GroundPitch);
            }
            else if ( bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( Abs(ViewRotation.Pitch) < 1000 )
                    ViewRotation.Pitch = 0;
            }
        }
        else
        {
            if ( !bKeyboardLook && (bLook == 0) && bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( Abs(ViewRotation.Pitch) < 1000 )
                    ViewRotation.Pitch = 0;
            }
        }
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
       	DoubleClickDir = DCLICK_None;
       	bPressedJump = false;
       	GroundPitch = 0;
        bFire = 0;
        bAltFire = 0;
		if ( Pawn != None )
		{
            if ( Pawn.Mesh == None )
                Pawn.SetMesh();
            Pawn.ShouldCrouch(false);
            if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Karma) // FIXME HACK!!!
                Pawn.SetPhysics(PHYS_Walking);
		}
    }

    function EndState()
    {

        GroundPitch = 0;
        if ( Pawn != None && bDuck==0 )
        {
            Pawn.ShouldCrouch(false);
        }
    }
}


function int ClampRotationValue(int val, int min, int max)
{
	local int ret;
	local bool swap;

	val=val&65535;
	min=min&65535;
	max=max&65535;

	ret=val;

	//log(val@min@max@((float(max - min) / 65536.0)*360.0)@dir);

	if(min > max) //wrapped around, swap
	{
		swap=true;
	}

	if(swap)
	{
		if(val > max && val < min)
		{
			//str=str@"within the range; clamp;";


			if( 65536 - val + max > val + 65536 - min )
			{
				//str="max;"@str;
				ret=max;
			}
			else
			{
				//str="min;"@str;
				ret=min;
			}


		}
		else
		{
			//str=str@"noclamp;";
		}
	}
	else
	{

		if(val > max) //above the range
		{
			//str=str@"above the range;";
			//str=str@"clamp;";

			if(val - max < min + 65536 - val)
			{
				//str="max;"@str;
				ret=max;
			}
			else
			{
				//str="min;"@str;
				ret=min;
			}
		}
		else if(val < min) //below the range
		{
			//str=str@"below the range;";
			//str=str@"clamp;";

			if(min - val  <  val + 65536 - max)
			{
				//str="min;"@str;
				ret=min;
			}
			else
			{
				ret=max;
				//str="max;"@str;
			}


		}
		//else //within the range
		//{
		//	//str=str@"within the range;";
		//	if(swap)
		//	{
		//		//str=str@"swap clamp;";

		//		//check angle around the other way
		//		if(min + 65536 - val < val + 65536 - max)
		//		{
		//			//str="min;"@str;
		//			ret=min;
		//		}
		//		else
		//		{
		//			ret=max;
		//			//str="max;"@str;
		//		}

		//	}
		//}
	}
	//log(str@val@min@max);

	return ret;
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	function int LimitYaw(int yaw, float deltat)
	{
		local int ladderyaw, clampyaw;

		ladderyaw = Pawn.OnLadder.WallDir.yaw;

		clampyaw = ClampRotationValue(yaw, ladderyaw - LadderYawAdjust, ladderyaw + LadderYawAdjust);


		if(LadderYawAdjust > 10000)
		{
			LadderYawAdjust -= FMax(1, deltat*32000.0);
			if(LadderYawAdjust < 10000)
				LadderYawAdjust = 10000;
		}




		return clampyaw;
	}


    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        else
            GotoState(Pawn.LandMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;

        OldAccel = Pawn.Acceleration;
        Pawn.Acceleration = NewAccel;

        if ( bPressedJump )
        {
            Pawn.DoJump(bUpdating);
            if ( Pawn.Physics == PHYS_Falling )
                GotoState('PlayerWalking');
        }
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;
		local float reverse;

		reverse=1;

		if(bReverseLadder)
		{
			reverse=-1;

			if((!bGoingUpLadder && aForward <= 10) || (bGoingUpLadder && aForward >= -10))
			{
				reverse=1;
				bReverseLadder=false;
			}

		}

        GetAxes(Rotation,X,Y,Z);

        // Update acceleration.
        if ( Pawn.OnLadder != None )
            NewAccel = reverse*aForward*Pawn.OnLadder.ClimbDir;// + aStrafe*(Vector(Pawn.OnLadder.WallDir) cross (Vect(0,0,-1)));
        else
            NewAccel = aForward*X + aStrafe*Y;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        ViewRotation = Rotation;

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
		Pawn.Weapon.LowerWeapon();

		Pawn.ShouldCrouch(false);
        bPressedJump = false;
		LadderYawAdjust=32000;
		LadderPitchAdjust = 6000;
		if(Vector(Pawn.Rotation) dot Pawn.OnLadder.LookDir <= 0.9)
		{
			bReverseLadder = true;

			bGoingUpLadder=!Pawn.OnLadder.IsAtTop(Pawn);
		}

	}

    function EndState()
    {

		bReverseLadder=false;
        if ( Pawn != None )
		{
			Pawn.Weapon.RaiseWeapon();
            Pawn.ShouldCrouch(false);
		}
    }
}

// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

    event bool NotifyHitWall(vector HitNormal, actor HitActor)
    {
        Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetBase(HitActor, HitNormal);
        return true;
    }

    // if spider mode, update rotation based on floor
    function UpdateRotation(float DeltaTime, float maxPitch)
    {
        local rotator ViewRotation;
        local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

        if ( bInterpolating || Pawn.bInterpolating )
        {
            ViewShake(deltaTime);
            return;
        }

        TurnTarget = None;
        bRotateToDesired = false;
        bSetTurnRot = false;

        if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
            MyFloor = vect(0,0,1);
        else
            MyFloor = Pawn.Floor;

        if ( MyFloor != OldFloor )
        {
            // smoothly change floor
            RealFloor = MyFloor;
            MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
            if ( (RealFloor Dot MyFloor) > 0.999 )
                MyFloor = RealFloor;

            // translate view direction
            CrossDir = Normal(RealFloor Cross OldFloor);
            FwdDir = CrossDir Cross MyFloor;
            OldFwdDir = CrossDir Cross OldFloor;
            ViewX = MyFloor * (OldFloor Dot ViewX)
                        + CrossDir * (CrossDir Dot ViewX)
                        + FwdDir * (OldFwdDir Dot ViewX);
            ViewX = Normal(ViewX);

            ViewZ = MyFloor * (OldFloor Dot ViewZ)
                        + CrossDir * (CrossDir Dot ViewZ)
                        + FwdDir * (OldFwdDir Dot ViewZ);
            ViewZ = Normal(ViewZ);
            OldFloor = MyFloor;
            ViewY = Normal(MyFloor Cross ViewX);
        }

        if ( (aTurn != 0) || (aLookUp != 0) )
        {
            // adjust Yaw based on aTurn
            if ( aTurn != 0 )
                ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

            // adjust Pitch based on aLookUp
            if ( aLookUp != 0 )
            {
                OldX = ViewX;
                ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
                ViewZ = Normal(ViewX Cross ViewY);

                // bound max pitch
                if ( (ViewZ Dot MyFloor) < 0.707   )
                {
                    OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
                    if ( (ViewX Dot MyFloor) > 0)
                        ViewX = Normal(OldX + MyFloor);
                    else
                        ViewX = Normal(OldX - MyFloor);

                    ViewZ = Normal(ViewX Cross ViewY);
                }
            }

            // calculate new Y axis
            ViewY = Normal(MyFloor Cross ViewX);
        }
        ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
        SetRotation(ViewRotation);
        ViewShake(deltaTime);
        ViewFlash(deltaTime);
        Pawn.FaceRotation(ViewRotation, deltaTime );
    }

    function bool NotifyLanded(vector HitNormal)
    {
        Pawn.SetPhysics(PHYS_Spider);
        return bUpdating;
    }

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
            GotoState(Pawn.WaterMovementState);
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;

        OldAccel = Pawn.Acceleration;
        Pawn.Acceleration = NewAccel;

        if ( bPressedJump )
            Pawn.DoJump(bUpdating);
    }

    function PlayerMove( float DeltaTime )
    {
        local vector NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

		GroundPitch = 0;
        ViewRotation = Rotation;

        if ( !bKeyboardLook && (bLook == 0) && bCenterView )
        {
            // FIXME - center view rotation based on current floor
        }
        Pawn.CheckBob(DeltaTime,vect(0,0,0));

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);

        // Update acceleration.
        NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    function BeginState()
    {
        if ( Pawn.Mesh == None )
            Pawn.SetMesh();
        OldFloor = vect(0,0,1);
        GetAxes(Rotation,ViewX,ViewY,ViewZ);
        DoubleClickDir = DCLICK_None;
        Pawn.ShouldCrouch(false);
        bPressedJump = false;
        if (Pawn.Physics != PHYS_Falling)
            Pawn.SetPhysics(PHYS_Spider);
        GroundPitch = 0;
        Pawn.bCrawler = true;
        Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
    }

    function EndState()
    {
        GroundPitch = 0;
        if ( Pawn != None )
        {
            Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
            Pawn.ShouldCrouch(false);
            Pawn.bCrawler = Pawn.Default.bCrawler;
        }
    }
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

    function bool WantsSmoothedView()
    {
        return ( !Pawn.bJustLanded );
    }

    function bool NotifyLanded(vector HitNormal)
    {
        if ( Pawn.PhysicsVolume.bWaterVolume )
            Pawn.SetPhysics(PHYS_Swimming);
        else
            GotoState(Pawn.LandMovementState);
        return bUpdating;
    }

    function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        local actor HitActor;
        local vector HitLocation, HitNormal, checkpoint;

        if ( !NewVolume.bWaterVolume )
        {
            Pawn.SetPhysics(PHYS_Falling);
            if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
            {
                Pawn.velocity.Z = FMax(Pawn.JumpZ,420) + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
                GotoState(Pawn.LandMovementState);
            }
            else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
                GotoState(Pawn.LandMovementState);
            else //check if in deep water
            {
                checkpoint = Pawn.Location;
                checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
                HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
                if (HitActor != None)
                    GotoState(Pawn.LandMovementState);
                else
                {
                    Enable('Timer');
                    SetTimer(0.7,false);
                }
            }
        }
        else
        {
            Disable('Timer');
            Pawn.SetPhysics(PHYS_Swimming);
        }
        return false;
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector X,Y,Z, OldAccel;

        GetAxes(Rotation,X,Y,Z);
        OldAccel = Pawn.Acceleration;
        Pawn.Acceleration = NewAccel;
        Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
        if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
            NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);

        PlayerReplicationInfo.PlayTime += DeltaTime / Level.TimeDilation;
    }

    function PlayerMove(float DeltaTime)
    {
        local rotator oldRotation;
        local vector X,Y,Z, NewAccel;

		GetAxes(Rotation,X,Y,Z);

        NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);

        //add bobbing when swimming
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        oldRotation = Rotation;
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
        bPressedJump = false;
    }

    function Timer()
    {
        if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
            GotoState(Pawn.LandMovementState);

        Disable('Timer');
    }

    function BeginState()
    {
        Disable('Timer');
        Pawn.SetPhysics(PHYS_Swimming);
    }
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

        Pawn.Acceleration = aForward*X + aStrafe*Y;
        if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Acceleration = vect(0,0,0);
        if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
            Pawn.Velocity = vect(0,0,0);
        // Update rotation.
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }

    function BeginState()
    {
        Pawn.SetPhysics(PHYS_Flying);
    }
}

state PlayerHelicoptering extends PlayerFlying
{
    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

        Pawn.Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
        if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Acceleration = vect(0,0,0);
        if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
            Pawn.Velocity = vect(0,0,0);
        // Update rotation.
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }
}

function bool IsSpectating()
{
	return false;
}

state BaseSpectating
{
	function bool IsSpectating()
	{
		return true;
	}

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        /*if (ViewTarget != None)
        {
            Global.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
            return;
        }*/

        Acceleration = NewAccel;
        MoveSmooth(Acceleration * DeltaTime);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;

        /*if (ViewTarget != None)
        {
            Global.PlayerMove(DeltaTime);
            return;
        }*/

        GetAxes(Rotation,X,Y,Z);

        Acceleration = 0.02 * (FClamp(aForward,-32000,32000)*X + FClamp(aStrafe,-32000,32000)*Y + aUp*vect(0,0,1));

        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
    }
}

state Scripting
{
    // FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
    exec function Fire( optional float F )
    {
    }

    exec function AltFire( optional float F )
    {
        Fire(F);
    }
}

function ServerViewNextPlayer()
{
    local Controller C;
    local Pawn Pick;
    local bool bFound, bRealSpec;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    PlayerReplicationInfo.bOnlySpectator = true;

    // view next player
    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        log("Check spectate "$C.Pawn$" can "$Level.Game.CanSpectate(self,true,C.Pawn));
        if ( (C.Pawn != None) && Level.Game.CanSpectate(self,true,C.Pawn) )
        {
            if ( Pick == None )
                Pick = C.Pawn;
            if ( bFound )
            {
                Pick = C.Pawn;
                break;
            }
            else
                bFound = ( ViewTarget == C.Pawn );
        }
    }
    log("best is "$Pick);
    SetViewTarget(Pick);
    log("Viewtarget is "$ViewTarget);
    if ( ViewTarget == self )
        ResetView();
    else
        bBehindView = true; //bChaseCam;
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;

}

function ServerViewSelf()
{
    bBehindView = false;
    SetViewtarget(self);
    ClientMessage(OwnCamera, 'Event');
}

state Spectating extends BaseSpectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
        bBehindView = true;
        ServerViewNextPlayer();
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
        bBehindView = false;
        ServerViewSelf();
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        bCollideWorld = true;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

auto state PlayerWaiting extends BaseSpectating
{
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon;

    exec function Jump( optional float F )
    {
        /*local Pawn P;
        foreach DynamicActors(class'Pawn', P)
        {
            if (P != ViewTarget)
                break;
        }
        SetViewTarget(P);
        bBehindView = true;*/
    }

    exec function Suicide()
    {
    }

    //function ChangeTeam( int N )
    //{
    //    Level.Game.ChangeTeam(self, N);
    //}

    function ServerReStartPlayer()
    {
        if ( Level.TimeSeconds < WaitDelay )
            return;
        if ( Level.NetMode == NM_Client )
            return;
        if ( Level.Game.bWaitingToStartMatch )
			PlayerReplicationInfo.bReadyToPlay = true;
        else
            Level.Game.RestartPlayer(self);
    }

    exec function Fire(optional float F)
    {
        if( PlayerReplicationInfo == None )
        {
            return;
        }
        
        if( GameReplicationInfo == None )
        {
            return;
        }
        
		Level.LoadDelayedPlayers();
        ServerReStartPlayer();
    }

    exec function AltFire(optional float F)
    {
        Fire(F);
    }

    function EndState()
    {
        if ( Pawn != None )
            Pawn.SetMesh();
        if ( PlayerReplicationInfo != None )
            PlayerReplicationInfo.SetWaitingPlayer(false);
        bCollideWorld = false;
    }

    function BeginState()
    {
	    bFire = 0;
	    bAltFire = 0;
        if ( PlayerReplicationInfo != None )
            PlayerReplicationInfo.SetWaitingPlayer(true);
        bCollideWorld = true;
    }
}

// amb ---
state CoopJoined extends BaseSpectating
{
}
// --- amb

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

    exec function Fire( optional float F )
    {
    }

    exec function AltFire( optional float F )
    {
    }

    function LongClientAdjustPosition
    (
        float TimeStamp,
        name newState,
        EPhysics newPhysics,
        float NewLocX,
        float NewLocY,
        float NewLocZ,
        float NewVelX,
        float NewVelY,
        float NewVelZ,
        Actor NewBase,
        float NewFloorX,
        float NewFloorY,
        float NewFloorZ
    )
    {
    }

    function PlayerTick(float DeltaTime)
    {
        Global.PlayerTick(DeltaTime);

        if ( Pawn != None )
        {
            Pawn.Controller = self;
            ClientRestart();
        }
    }

    function Timer()
    {
        AskForPawn();
    }

    function BeginState()
    {
        SetTimer(0.2, true);
    }

    function EndState()
    {
        SetTimer(0.0, false);
    }
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide, SwitchWeapon, NextWeapon, PrevWeapon; // gam

	function bool IsSpectating()
	{
		return true;
	}

    exec function ThrowWeapon()
    {
    }

    function ServerReStartGame()
    {
        Level.Game.RestartGame();
    }

    exec function Fire( optional float F )
    {
        if ( Role < ROLE_Authority)
            return;
        if ( !bFrozen )
            ServerReStartGame();
        else if ( TimerRate <= 0 )
            SetTimer(1.5, false);
    }

    exec function AltFire( optional float F )
    {
        Fire(F);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local Rotator ViewRotation;

		GetAxes(Rotation,X,Y,Z);
        // Update view rotation.

        if ( !bFixedCamera )
        {
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch, DeltaTime); //amb
            SetRotation(ViewRotation);
        }
        else if ( ViewTarget != None )
            SetRotation(ViewTarget.Rotation);

        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        bPressedJump = false;
    }

    function ServerMove
    (
        float TimeStamp,
        vector InAccel,
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus,
        bool NewbDoubleJump,
        eDoubleClickDir DoubleClickMove,
        byte ClientRoll,
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {
        Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus, NewbDoubleJump,
                            DoubleClickMove, ClientRoll, View);

    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        bFrozen = false;
    }

    function BeginState()
    {
        local Pawn P;

        //EndZoom();
		ClientEndZoom();
		FOVAngle = DesiredFOV;
        bFire = 0;
        bAltFire = 0;
        if ( Pawn != None )
        {
            Pawn.SimAnim.AnimRate = 0;
            Pawn.bPhysicsAnimUpdate = false;
            Pawn.StopAnimating();
            Pawn.SetCollision(false,false,false);
        }
        bFrozen = true;
        if ( !bFixedCamera )
        {
            FindGoodView();
            bBehindView = true;
        }
        if( IsOnConsole() && GetCurrentGameProfile() == None)
            SetTimer(10.0, false);
        else
            SetTimer(1.5, false);
        SetPhysics(PHYS_None);
        ForEach DynamicActors(class'Pawn', P)
        {
            P.Velocity = vect(0,0,0);
            P.SetPhysics(PHYS_None);
        }
    }

Begin:
    /* gam ---
    Sleep(GameReplicationInfo.ScoreBoardDelay(self));
    GameReplicationInfo.SetScoreBoardVisibility(self, true);
    */
}

state MostlyDead
{
	ignores KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	function ServerReStartPlayer()
	{
		if(Level.NetMode == NM_Client)
			return;
		Level.Game.RestartPlayer(self);
	}

	// respawn
	exec function Fire(optional float F)
	{
		bAutoSpawn = true;
		if(Pawn != none) {
//			Pawn.Timer();
			Pawn.DemandRespawn();
		}
//        Level.LoadDelayedPlayers();
//        ServerReStartPlayer();
	}

	// also respawn
	exec function AltFire(optional float F)
	{
		bAutoSpawn = true;
		if(Pawn != none)
			Pawn.Timer();
//        Level.LoadDelayedPlayers();
//        ServerReStartPlayer();
	}

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local rotator ViewRotation;

		if ( !bFrozen )
        {
            if ( bPressedJump )
            {
                Fire(0);
                bPressedJump = false;
            }
            GetAxes(Rotation,X,Y,Z);
            // Update view rotation.
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch, DeltaTime); //amb
            SetRotation(ViewRotation);
            if ( Role < ROLE_Authority ) // then save this move and replicate it
                ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        }
        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ////log("Find good death scene view");
        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

	function BeginState()
    {
		EndZoom();
		FOVAngle = DesiredFOV;
        Enemy = None;
        bBehindView = true;
        bFrozen = true;
        bPressedJump = false;
        FindGoodView();
//        SetTimer(1.0, false); // jjs

		CleanOutSavedMoves();
		log("I'm not dead yet...");
    }

    function EndState()
    {
		CleanOutSavedMoves();
        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        bBehindView = false;
        bPressedJump = false;
		bFrozen = false;
        GameReplicationInfo.SetScoreBoardVisibility(self, false);
        //Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
    }
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

    function ServerRestartPlayer()
    {
		if(Level.NetMode == NM_Client)
			return;
		Level.Game.RestartPlayer(self);
//        Super.ServerRestartPlayer();
    }

    exec function Fire( optional float F )
    {
        Level.LoadDelayedPlayers();
        ServerReStartPlayer();
    }

    exec function AltFire( optional float F )
    {
        if (!bFrozen)
            Fire(F);
        else
            Timer();
    }

	function Tick(float dt)
	{
		if(bAutoSpawn) {
			bAutoSpawn = false;
			Fire(0.f);
		}
	}

    function ServerMove
    (
        float TimeStamp,
        vector Accel,
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus,
        bool NewbDoubleJump,
        eDoubleClickDir DoubleClickMove,
        byte ClientRoll,
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {
        Global.ServerMove(
                    TimeStamp,
                    Accel,
                    ClientLoc,
                    false,
                    false,
                    false,
                    false,
                    DoubleClickMove,
                    ClientRoll,
                    View);
    }

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z;
        local rotator ViewRotation;

		if ( !bFrozen )
        {
            if ( bPressedJump )
            {
                Fire(0);
                bPressedJump = false;
            }
            GetAxes(Rotation,X,Y,Z);
            // Update view rotation.
            ViewRotation = Rotation;
            ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
            ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
            ViewRotation.Pitch = LimitPitch(ViewRotation.Pitch, DeltaTime); //amb
            SetRotation(ViewRotation);
            if ( Role < ROLE_Authority ) // then save this move and replicate it
                ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
        }
        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
    }

    function FindGoodView()
    {
        local vector cameraLoc;
        local rotator cameraRot, ViewRotation;
        local int tries, besttry;
        local float bestdist, newdist;
        local int startYaw;
        local actor ViewActor;

        ////log("Find good death scene view");
        ViewRotation = Rotation;
        ViewRotation.Pitch = 56000;
        tries = 0;
        besttry = 0;
        bestdist = 0.0;
        startYaw = ViewRotation.Yaw;

        for (tries=0; tries<16; tries++)
        {
            cameraLoc = ViewTarget.Location;
            PlayerCalcView(ViewActor, cameraLoc, cameraRot);
            newdist = VSize(cameraLoc - ViewTarget.Location);
            if (newdist > bestdist)
            {
                bestdist = newdist;
                besttry = tries;
            }
            ViewRotation.Yaw += 4096;
        }

        ViewRotation.Yaw = startYaw + besttry * 4096;
        SetRotation(ViewRotation);
    }

    function Timer()
    {
        if (!bFrozen)
        {
            Fire(0.f);
            // Force respawn!!
            return;
        }

        bFrozen = false;
        bPressedJump = false;
        SetTimer(ForcedRespawnTime, false); // gam
    }

    function BeginState()
    {
		EndZoom();
		FOVAngle = DesiredFOV;
        Enemy = None;
        bBehindView = true;
        bFrozen = true;
        bPressedJump = false;
        FindGoodView();
        SetTimer(1.0, false); // jjs

		CleanOutSavedMoves();

		if(bAutoSpawn) {
			bAutoSpawn = false;
	        Level.LoadDelayedPlayers();
		    ServerReStartPlayer();
//			Fire(0.f);
		}
    }

    function EndState()
    {
		CleanOutSavedMoves();
        Velocity = vect(0,0,0);
        Acceleration = vect(0,0,0);
        bBehindView = false;
        bPressedJump = false;
        GameReplicationInfo.SetScoreBoardVisibility(self, false);
        //Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
    }
Begin:
    /* gam
    Sleep(GameReplicationInfo.ScoreBoardDelay(self));
    GameReplicationInfo.SetScoreBoardVisibility(self, true);
    */
}

//------------------------------------------------------------------------------
// Control options
function ChangeStairLook( bool B )
{
    bLookUpStairs = B;
    if ( bLookUpStairs )
        bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
    bAlwaysMouseLook = B;
    if ( bAlwaysMouseLook )
        bLookUpStairs = false;
}


// amb ---
// Camera control for debugging/tweaking
exec function ModalFreeCam()
{
    if (bBehindView == True)
    {
        if (bFreeCam == True)
        {
            if (bFreeCamZoom == True)
            {
                bBehindView = False;
                bFreeCam = False;
                bFreeCamZoom = False;
            }
            else
                bFreeCamZoom = True;
        }
        else
            bFreeCam = True;
    }
    else
        bBehindView = True;
}

// Toggle BehindView on/off
exec function ToggleBehindView()
{
    // todo: this statement is just a hack for some problem in the spectacting logic...
    //if ((GetStateName() != 'PlayerWalking') && (GetStateName() != 'PlayerHovering'))
    //    return;

    if (bBehindView == True)
    {
        bBehindView = False;
        bFreeCam = False;
        bFreeCamZoom = False;
        bFreeCamSwivel = False;
    }
    else
    {
        bBehindView = True;
    }
}

// Toggle the FreeCam mode on/off
exec function ToggleFreeCam()
{
    if (!bBehindView)
        return;

    if (bFreeCam == True)
    {
        bFreeCam = False;
        // Zooming only works in freeCam mode
        bFreeCamZoom = False;
        bFreeCamSwivel = False;
    }
    else
    {
        bFreeCam = True;
    }
}

// Toggle the FreeCam zoom mode on/off
exec function ToggleFreeCamZoom()
{
    if (bFreeCamZoom == True)
        bFreeCamZoom = False;
    // Zooming only works in freeCam mode
    else if (bFreeCam == True)
        bFreeCamZoom = True;
}

// Toggle the FreeCam swivel mode on/off
exec function ToggleFreeCamSwivel()
{
    if (bFreeCamSwivel == True)
        bFreeCamSwivel = False;
    // Swivel only works in freeCam mode
    else if (bFreeCam == True)
        bFreeCamSwivel = True;
}
// --- amb

// gam ---

simulated event MenuOpen (class<Menu> MenuClass, optional String Args)
{
    if (Player == None)
    {
        log ("PlayerController::MenuOpen: can't open menu without a player", 'Error');
        return;
    }

    if (Player.Console == None)
    {
        log ("PlayerController::MenuOpen: can't open menu without a console", 'Error');
        return;
    }

    Player.Console.MenuOpen (MenuClass, Args);
}

simulated event MenuClose()
{
    if (Player == None)
    {
        log ("PlayerController::MenuClose: can't close menu without a player", 'Error');
        return;
    }

    if (Player.Console == None)
    {
        log ("PlayerController::MenuClose: can't close menu without a console", 'Error');
        return;
    }

    Player.Console.MenuClose ();
}
// --- gam

// rj@bb ---
simulated function Menu CurrentMenu()
{
	local Menu m;

    if ( Player != None && Player.Console != None )
    {
		m = Player.Console.CurMenu;
    }
	return m;
}
// --- rj@bb

// amb ---
exec function InvertLook()
{
    local bool result;

    result = PlayerInput.InvertLook();

    if (IsOnConsole())
    {
        class'XBoxPlayerInput'.default.bInvertVLook = result;
        class'XBoxPlayerInput'.static.StaticSaveConfig();
    }
}

function bool GetInvertLook()
{
    return(PlayerInput.GetInvertLook());
}

function SetInvertLook(bool invert)
{
    PlayerInput.SetInvertLook(invert);
}

function bool IsCoopCaptain()
{
    return (Level.Game != None) &&
        Level.Game.IsCoopGame() &&
        (Viewport(Player) != None);
}

function bool CanRestartPlayer()
{
    if( myHud.UtilityOverlay != None && myHud.UtilityOverlay.GetStateName() == 'SelectingProfile' )
        return false;
    return !PlayerReplicationInfo.bOnlySpectator;
}
// --- amb

// jij ---
event ServerChangeChannel( PlayerController Player, XboxAddr XbAddr, int PortNo, int Channel )
{
    XbAddr.Gamertag = Player.Gamertag;

    if( (XbAddr.Gamertag == "") && (Player.PlayerReplicationInfo != None) )
    {
        // Hacks for system link!
        XbAddr.Gamertag = Player.PlayerReplicationInfo.GetPrivatePlayerName();
    }

    if( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
    {
        if (Channel == -1)
        {
            // select the best channel for this client to be in
            Level.Game.JoinBestVoiceChannel(Player, xbAddr, PortNo, true);
        }
        else if (Channel == -2)
        {
            // client wants to leave the channel, notify everyone
            Level.Game.LeaveVoiceChannel(Player, xbAddr, PortNo, Channel, true);
        }
        else if (Channel == -3)
        {
            // client wants to join best channel, but from script (so no XboxAddr/PortNo)
            Level.Game.JoinBestVoiceChannel(Player, xbAddr, PortNo, false);
        }
        else if (Channel <= -4)
        {
            // client wants to join a specific channel, but from script (so no XboxAddr/PortNo)
            Channel = -Channel;
            Channel -= 4;
            Level.Game.JoinVoiceChannel(Player, xbAddr, PortNo, Channel, false);
        }
        else
        {
            // try to join the specified channel, if it is not already full
            Level.Game.JoinVoiceChannel(Player, xbAddr, PortNo, Channel, true);
        }
    }
}

simulated function ClientChangeVoiceChatter( XboxAddr xbAddr, int PortNo, bool Add )
{
	ChangeVoiceChatter( xbAddr, PortNo, Add );
}

simulated function ClientLeaveVoiceChat()
{
	LeaveVoiceChat();
}

simulated function ClientChangeChannel(int Channel)
{
    VoiceChannel = Channel;
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.VoiceChannel = Channel;
}

native final function LeaveVoiceChat();
native final function ChangeVoiceChatter( XboxAddr xbAddr, int PortNo, bool Add );
// --- jij
event SpeechRecognized(int wordID)
{
	log("SpeechRecognized:"@wordID);
}

// mh ---
// Called during OverlayPreGame
simulated function PlayLoadOutFlyBy();

/////////////////////////////////////////////////////////////////////////////
// Admin Handling : Was previously in Admin.uc
//
//
//

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
local string Result;

	if (AdminManager != None)
	{
		Log("Doing Admin Command!:"@CommandLine);
		Result = ConsoleCommand( CommandLine );
		if( Result!="" )
			ClientMessage( Result );
	}
}

exec function AdminLogin(string CmdLine)
{
	if (AdminManager == None)
	{
	  MakeAdmin();
	  ConsoleCommand("DoLogin"@CmdLine);
	  if (!AdminManager.bAdmin)
		  AdminManager = None;
	  else
		  AddCheats();
	}
}

exec function AdminLogout()
{
  if (AdminManager != None)
  {
	ConsoleCommand("DoLogout");
	if (!AdminManager.bAdmin)
		AdminManager = None;
  }
}

simulated event UpdatePlayer(string newName, optional string newChar)
{
    log(self$" UpdatePlayer called newName="$newName$" newChar="$newChar);
    
    if (GetCurrentGameProfile() != None)
    {
        return;
    }
    
    ChangeName(newName);
    if(Pawn != None)
    {
        Pawn.OwnerName = string(Player.SplitIndex);
    }

	if (Level.NetMode != NM_DedicatedServer)
    {
        log("Sending Force/switch/taunt settings to server.");
        UpdateForceFeedbackProperties( ForceFeedbackSupported(), bEnableWeaponForceFeedback, bEnablePickupForceFeedback, bEnableDamageForceFeedback, bEnableGUIForceFeedback );  // jdf
        UpdateSwitchWeaponOnPickup(bNeverSwitchOnPickup);
		ServerSetAutotaunt(bAutoTaunt);
		PlaySong();
    }
}

exec simulated function FakeLiveFriendRequest()
{
    NumFriendRequests++;
}

exec simulated function FakeLiveGameInvite()
{
    NumGameInvites++;
}

// amb ---
simulated function string GetPlayerRecordDefaultName(int PlayerRecordIndex);
// --- amb

/* StartInterpolation()
when this function is called, the actor will start moving along an interpolation path
beginning at Dest
*/
simulated function StartInterpolation()
{
	//GotoState('');
	SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}

simulated function StopEffects()
{
	local Inventory inv;

	// go through each weapon and stop its effects
	if(Pawn != none) {
		for(inv = Pawn.Inventory; inv != none; inv = inv.Inventory) {
			if(inv.IsA('Weapon') ) {
				Weapon(inv).StopFireEffects();
				Weapon(inv).StopBlur();
			}
		}

		Pawn.StopBlur();
	}

	// make sure zoom is turned off
	if(bZoomed)
		ClientEndZoom();
}

simulated function PrepareForMatinee()
{
	Super.PrepareForMatinee();

	StopEffects();

}

/*
	To test the vertical camera spring
	xmatt
*/
exec function spring_f( float strength )
{
	Vertical_cam_spring.spring_f = strength;
}

exec function KickSpring( float X )
{
	Vertical_cam_spring.spring_force += VRand() * X;
}

simulated function AddSpringForce( Vector v )
{
    Vertical_cam_spring.spring_force += v;
}


/*
	Apply external force on the vertical camera spring
	xmatt
*/
simulated function AddImpulse( float strength )
{
	Vertical_cam_spring.spring_f = strength;
}

//--------------------- Demo recording stuff

// Called on the client during client-side demo recording
simulated event StartClientDemoRec()
{
	// Here we replicate functions which the demo never saw.
	DemoClientSetHUD( MyHud.Class, MyHud.ScoreBoard.Class );
	
	// tell server to replicate more stuff to me
	bClientDemo = true;
	ServerSetClientDemo();
}

function ServerSetClientDemo()
{
	bClientDemo = true;
}

// Called on the playback client during client-side demo playback
simulated function DemoClientSetHUD(class<HUD> newHUDClass, class<Menu> newScoringClass )
{
	if( MyHUD == None )
		ClientSetHUD( newHUDClass, newScoringClass, None);
}

event Blinded(Pawn Instigator, float Duration, Name BlindType) // blinding grenade effects
{
    if( MyHUD != None && Pawn != None)
    {    
        MyHUD.Blinded(Duration, BlindType);
    }
}

simulated function bool SplitLoadLastProfile();

simulated function bool PlayingMatinee()
{
    return
    (
        Level != None && 
        Level.Game != None && 
        Level.Game.bSinglePlayer && 
        MyHUD != None && 
        MyHUD.bInMatinee
    );
}

defaultproperties
{
     AnnouncerVolume=4
     EnemyTurnSpeed=45000
     PitchUpLimit=18000
     PitchDownLimit=49153
     OnlineStatus=1
     SRVocabulary=-1
     NetSplitID=-1
     AutoAimHorizontal=25.000000
     AutoAimVertical=25.000000
     AutoAimMaxDistance=8000.000000
     MaximumAutoPivot=6.000000
     MaxResponseTime=0.700000
     OrthoZoom=40000.000000
     CameraDist=9.000000
     DesiredFOV=70.000000
     DefaultFOV=70.000000
     MaxTimeMargin=1.000000
     ProgressTimeOut=8.000000
     TeamBeaconMaxDist=20000.000000
     TeamBeaconPlayerInfoMaxDist=10000.000000
     TimeBetweenMatchmakingQueries=2.500000
     TimeBetweenStatsQueries=15.000000
     TimeBetweenStorageCommands=5.000000
     ForcedRespawnTime=20.000000
     UseDistance=300.000000
     UseRadius=300.000000
     UseLimit=250.000000
     LocalMessageClass=Class'Engine.LocalMessage'
     CheatClass=Class'Engine.CheatManager'
     InputClass=Class'Engine.PlayerInput'
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
     TeamBeaconTeamColors(0)=(R=180,A=255)
     TeamBeaconTeamColors(1)=(B=200,G=80,R=80,A=255)
     TeamBeaconCustomColor=(G=255,R=255,A=255)
     sLastSkippableVideo="Chapter09Scene1.bik"
     QuickSaveString="Quick Saving"
     NoPauseMessage="Game is not pauseable"
     ViewingFrom="Now viewing from"
     OwnCamera="Now viewing from own camera"
     HealingToolGroup=5
     MeleeGroup=14
     VirusGroup=15
     bAlwaysMouseLook=True
     bKeyboardLook=True
     bAutoAim=True
     bRelativeRadar=True
     bZeroRoll=True
     bNoVoiceTaunts=True
     bNoAutoTaunts=True
     bEnablePickupForceFeedback=True
     bEnableWeaponForceFeedback=True
     bEnableDamageForceFeedback=True
     bEnableGUIForceFeedback=True
     bLookSteer=True
     bAllowTitans=True
     FovAngle=70.000000
     Handedness=1.000000
     bIsPlayer=True
     bCanOpenDoors=True
     bCanDoSpecial=True
     NetPriority=3.000000
     bTravel=True
}
