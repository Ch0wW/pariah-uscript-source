//=============================================================================
// LevelInfo contains information about the current level. There should
// be one per level and it should be actor 0. UnrealEd creates each level's
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	showcategories(Karma,Havok)
	nativereplication;

// Textures.
#exec Texture Import File=Textures\WireframeTexture.tga
#exec Texture Import File=Textures\S_Vertex.tga Name=LargeVertex

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.
var			  float	PauseDelay;		// time at which to start pause

//-----------------------------------------------------------------------------
// Level Summary Info (gam)

var(LevelSummary) localized String Title;
var(LevelSummary) String Author;

var(LevelSummary) Material Screenshot; // Depricated!
var(LevelSummary) Material Vignette;
var(LevelSummary) String VideoFile;

var(LevelSummary) int IdealPlayerCountMin;
var(LevelSummary) int IdealPlayerCountMax;

var(LevelSummary) bool HideFromMenus;

var(SplitScreen) int MaxViewports;

var(SinglePlayer) int   PrimaryStartHealth;

var() config enum EPhysicsDetailLevel
{
	PDL_Low,
	PDL_Medium,
	PDL_High
} PhysicsDetailLevel;

// Karma - jag
// - these only apply to karma ragdolls
var float KarmaTimeScale;		// Karma physics timestep scaling.
var float RagdollTimeScale;		// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var float KarmaGravScale;		// Allows you to make ragdolls use lower friction than normal.
var bool  bKStaticFriction;		// Better rag-doll/ground friction model, but more CPU.

var(Karma) bool	 bKNoInit;				// Start _NO_ Karma for this level. Only really for the Entry level.
// jag

var(Havok) bool	 bNoHavok;				// No Havok support for this level.
var(Havok) bool	 bHavokSimulateOnLoad;	// should Havok start simulating on load (used for debugging)

// define Havok broadphase...this must encompass the entire world
var(Havok) vector	HavokBroadPhaseMin;	// min corner for Havok broadphase
var(Havok) vector	HavokBroadPhaseMax;	// min corner for Havok broadphase

var(Ragdolls) int   MaxSimulatedRagdolls;   // Maximum number of simulated ragdolls.
var(Ragdolls) int	MaxFrozenRagdolls;		// Maximum number of frozen ragdolls

// The following 3 properties determine when ragdolls are destroyed
// - RagdollLifeSpan is the maximum time a ragdoll can stay around
// - ragdoll will be destroyed if it doesn't satisfy BOTH the following two parameters
//   - RagdollNotSeenLimit (if ragdoll has been seen within this time limit)
//   - RagdollDistanceLimit (if ragdoll is within this distance from the player)
//
var(Ragdolls) float RagdollLifeSpan;
var(Ragdolls) private float RagdollNotSeenLimit;	// if ragdoll has been seen within this time limit, it stays around
var(Ragdolls) private float RagdollDistanceLimit;	// if ragdoll is within this distance from the player, it stays around

struct native HavokMoppCode
{
	var name		Tag;				// some way to identify who this mopp code is for
	var vector		Scale;				// used to detect different instances of the same objects at different scales
	var float		MoppOffset[4];
	var int			MoppEndian;
	var array<byte>	MoppCode;
};
var noexport array<HavokMoppCode>	HavokPrecomputedMoppCodes;		// precomputed mopp codes

var() localized string LevelEnterText;			// Message to tell players when they enter.
var             PlayerReplicationInfo Pauser;	// If paused, name of person pausing the game.
var             PlayerReplicationInfo QueuedPauser;	// If paused, next pauser in line (for co-op)
var				LevelSummary Summary;
var				string VisibleGroups;			// List of the group names which were checked when the level was last saved
//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var	bool			 bPathsRebuilt;	  // True if path network is valid
var bool			 bHasPathNodes;	  // gam
var transient const bool		 bPhysicsVolumesInitialized;	// true if physicsvolume list initialized

// rj@bb ---
// this is a backwards compatibility flag
// - if it's set, the ambient colors for all actors in the level will be "correct"
//
var(ZoneLight) bool bMakeActorAmbientCorrect;
// --- rj@bb

// rj@bb ---
// level specific flags which control whether various actor types should have exclusive lighting enforced
var (ZoneLight) bool bVehiclesExclusivelyLit;
var (ZoneLight) bool bFirstPersonWeaponsExclusivelyLit;
var (ZoneLight) bool bThirdPersonWeaponsExclusivelyLit;
var (ZoneLight) bool bCharactersExclusivelyLit;
// --- rj@bb

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;

var texture DefaultTexture;
var texture WireframeTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

var transient GameReplicationInfo GRI; //amb

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;

enum EAuthMode
{
    AM_None,            // no auth (ie: SP or !Xbox)
	AM_SystemLink,      // System link play
	AM_Live,            // Xbox Live
};

var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var GameInfo Game;
var() bool bStartWithVehicles;
var() int VehiclesPerTeam;
var() name LoadoutFlyByTag;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var private transient const int NumNavigationPoints;	// not guaranteed to be correct
var const Controller ControllerList;
var PhysicsVolume PhysicsVolumeList;
var private PlayerController LocalPlayerController;		// player who is client here

// mh ---
struct native PathNodeObstacleRelation
{
	var ReachSpec path;
	var Actor	obstacle;
};

var	array<PathNodeObstacleRelation> PathObstacles;
// --- mh

//-----------------------------------------------------------------------------

var() float KillZ;		// any actor falling below this level gets destroyed
var() eKillZType KillZType;	// passed by FellOutOfWorldEvent(), to allow different KillZ effects

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Global object recycling pool.

var ObjectPool	ObjectPool;

//-----------------------------------------------------------------------------
// Additional materials to precache (e.g. Playerskins).

var transient array<material>	PrecacheMaterials;

//-----------------------------------------------------------------------------
// For delaying loading of player resources
var transient array<PlayerReplicationInfo> DelayedPlayers;

// sjs --- in order to cap max number of unique characters
var() transient int NumLoadedPlayerRecords;
var() int MaxLoadedPlayerRecords;
var() const transient Array<int>    LoadedPlayerRecords;

// gam ---
var() bool bMergeGamepadInput;  // Set by attract-mode & live login/logout. !bMergeGamepadInput implies get mad if controller is removed.
// --- gam

var	transient	Array<Actor>		NetPawns;

// rj ---
// PostProcessingEffect is being replaced by PostEffects
// - once all maps have been converted these two can be removed
var export editinline PostProcessingEffect		PostProcessingEffect;

var() export editinline PostFXManager			PostEffects;
var transient PostFXManager						RuntimePostEffects;

var private bool bInCinematic;
var() bool bDrawWeaponAfterPostFX; // sjs - workaround for screenspace distortion, some levels use it for water and it looks bad with 1st gun.
var string LastPlayedSong;

// --- rj

var() Array<String> VideoSkipList;

// rj@bb ---
// used for log groups
//
const NumLogGroups = 5;

struct native LogGroupInfo
{
	var transient float CurrentTimeSeconds;
	var transient float	NextTimeSeconds;
	var transient int LogID;
	var transient string Name;
};

var transient LogGroupInfo LogGroups[NumLogGroups];

enum ELogGroupAction
{	LGA_Log,
	LGA_LogIfTriggered,
	LGA_Trigger,
	LGA_IntervalTrigger
};

native simulated function int AddLogGroup( string GroupName );
native simulated function int LogGroupNameToIndex( string GroupName, optional bool bCreate );
native simulated function RemoveLogGroup( string GroupName );
native simulated function bool GroupNameLog(
	Actor Act,
	string Msg,
	string GroupName,
	ELogGroupAction Action,
	optional bool bCreate,
	optional float DeltaTime
);

// --- rj@bb

// mjm --   Redo the cinematic video skip list

// Ultra hardcore haxxor. Is the video given by sVideoName appear lower or higher on the list
// than sLastSkippableVideo in the player controller? If so, allow skip. If not, don't skip, add to
// list and save via triggering a multi-timer.

private function int GetVideoNumber(string sVideoName)
{
    local int i;

    for (i = 0; i < VideoSkipList.Length; i++)
    {
        if (VideoSkipList[i] == sVideoName)
        {
            return i;
        }

    }
    return -1; // No video is a negative value, can never be skipped
}
private function bool SkipVideo(string sVideoName)
{
	local PlayerController pc;
    pc = GetLocalPlayerController();

    log("Comparing last skippable" @ pc.sLastSkippableVideo @ "with" @sVideoName);

    if (GetVideoNumber(pc.sLastSkippableVideo) >= GetVideoNumber(sVideoName))
    {
        log("Skip this video!");
        return true;
    }
    else
    {
        log("Don't skip, next time!");
        pc.sLastSkippableVideo = sVideoName;
        pc.SetMultiTimer(555, 0.5, false);
    }
}

// -- mjm

//Prof. Jesse J.LaChapelle Esquire, Sept 20, 2004

/*****************************************************************
 * PlayVideo
 * Takes the name of a .bik video and attempts to play this video
 * VideoName      - The unqualified name of the video.
 * bInterruptible - If the video should skip if the user
 *                  presses a button.
 *****************************************************************
 */
native private function bool PlayVideo(string VideoName, bool bInterruptible);

/*****************************************************************
 * PlayVideos
 * Takes an array of names of .bik videos and attempts to play this video
 * VideoNames     - Array of unqualified names of the videos.
 * bInterruptible - If the video should skip if the user
 *                  presses a button.
 *****************************************************************
 */
native private function bool PlayVideos(array<string> VideoNames, bool bInterruptible);

/*****************************************************************
 * StopVideo
 * StopVideo attempts to stop the current video
 *****************************************************************
 */
native private function bool StopVideo();

/*****************************************************************
 * VideoComplete
 * Callback function that notifies script when the video has completed
 *****************************************************************
 */
event VideoComplete()
{
    bInCinematic = false;
    Level.Game.SetPause(false,Level.GetLocalPlayerController());
    StopAllMusic(0.0);
    PlayMusic(LastPlayedSong, 0.1);
    ConsoleCommand( "UnPauseSounds");
}

/*****************************************************************
 * PlayCinematic
 * Wrapper to the Playvideo functionality that handles pausing and
 * will likely manage whether the video should be skipped or not.
 * Returns true if the video started successfully
 *****************************************************************
 */
function bool PlayCinematic(string VideoName, bool bPauseDuringPlay,bool bInterrupt)
{
    local bool bInterruptible;

    //if this video is specified as NEVER interruptible
    if (bInterrupt == false)
    {
        bInterruptible = false;
    } 
    else //the Video is in the skip list then it can be interrupted (i.e. seen once by the player)
    {
        bInterruptible = SkipVideo(VideoName);
    }
    if (PlayVideo(VideoName, bInterruptible))
    {
        if (bPauseDuringPlay)
        {
            StopAllMusic(0.1);
            ConsoleCommand( "PauseSounds");
            Level.Game.SetPause(true,Level.GetLocalPlayerController());
        }
        bInCinematic = true;
        return true;
    }
    return false;
}

function bool PlayCinematics(array<string> VideoNames, bool bPauseDuringPlay,bool bInterrupt)
{
    local bool bInterruptible;
	local int i;

    //if this video is specified as NEVER interruptible
    if (bInterrupt == false)
    {
        bInterruptible = false;
    } 
    else //the Video is in the skip list then it can be interrupted (i.e. seen once by the player)
    {
		bInterruptible = true;
		for ( i = 0; i < VideoNames.Length; i++ )
		{
			if (!SkipVideo(VideoNames[i]))
			{
				bInterruptible = false;
			}
		}
    }
    if (PlayVideos(VideoNames, bInterruptible))
    {
        if (bPauseDuringPlay)
        {
            StopAllMusic(0.1);
            ConsoleCommand( "PauseSounds");
            Level.Game.SetPause(true,Level.GetLocalPlayerController());
        }
        bInCinematic = true;
        return true;
    }
    return false;
}

/*****************************************************************
 * PlayLocalizedCinematic
 * implemented for the one video that has one word that requires
 * localization.
 *****************************************************************
 */
function PlayLocalizedCinematic(string English, string French, string German,
                                string Italian, string Spanish, array<string> ExtraCinematics, 
								bool bPauseDuringPlay, bool bInterruptible){

    //check language
    local string CurrentLanguage, LocalizedCinematic;
	local array<string> Cinematics;
	local int v;
    CurrentLanguage = GetLocalPlayerController().ConsoleCommand("GET_LANGUAGE");

    //call PlayCinematic with video selected on the current language
    if ( CurrentLanguage == "det"){
		LocalizedCinematic = German;
    } else if ( CurrentLanguage == "frt") {
		LocalizedCinematic = French;
    } else if ( CurrentLanguage == "itt") {
		LocalizedCinematic = Italian;
    } else if ( CurrentLanguage == "est") {
		LocalizedCinematic = Spanish;
    } else { //international
		LocalizedCinematic = English;
    }
	if ( ExtraCinematics.Length > 0 )
	{
		Cinematics.Length = ExtraCinematics.Length + 1;
		Cinematics[0] = LocalizedCinematic;
		for ( v = 0; v < ExtraCinematics.Length; v++ )
		{
			Cinematics[v+1] = ExtraCinematics[v];
		}
		PlayCinematics( Cinematics, bPauseDuringPLay, bInterruptible );
	}
	else
	{
		PlayCinematic( LocalizedCinematic, bPauseDuringPLay, bInterruptible );
	}
}

function PlayAttractVideo(string VideoName)
{
    if (PlayVideo(VideoName,true))
    {
        StopAllMusic(0.1);
        ConsoleCommand( "PauseSounds");
        Level.Game.SetPause(true, Level.GetLocalPlayerController());
        bInCinematic = true;
    }
}

/*****************************************************************
 * StopCinematic
 * Wrapper to the StopVideo that handles pausing the game. Returns
 * true if the video successfully stopped. False if there was no video
 *****************************************************************
 */
function bool StopCinematic()
{
    if (StopVideo())
    {
        bInCinematic = false;
        Level.Game.SetPause(false,Level.GetLocalPlayerController());
        StopAllMusic(0.1);
        PlayMusic(LastPlayedSong,0.1);
        ConsoleCommand( "UnPauseSounds");
        return true;
    }
    return false;
}

/*****************************************************************
 * InCinematic
 * Returns true if the system is playing a cinematic
 *****************************************************************
 */
 
simulated event bool IsPausable()
{
    return(!(InCinematic() || InMatinee()));
}

simulated function bool InCinematic()
{
    return(bInCinematic);
}

simulated function bool InMatinee()
{
    local Controller c;

    for(c = ControllerList; c != None; c = c.NextController)
    {
        if(c.PlayingMatinee())
        {
            return(true);
        }
    }
    return(false);
}

//-----------------------------------------------------------------------------
// Functions.

simulated function int FindDelayedPlayer(PlayerReplicationInfo pri)
{
    local int i;

    for (i=0; i<DelayedPlayers.Length; i++)
{
        if (DelayedPlayers[i] == pri)
            break;
    }
    return i;
}

simulated function AddDelayedPlayer(PlayerReplicationInfo pri)
{
    local int i;

    if (NetMode == NM_DedicatedServer)
        return;

    i = FindDelayedPlayer(pri);
    if (i < DelayedPlayers.Length)
        return;
    DelayedPlayers.Insert(i,1);
    DelayedPlayers[i] = pri;
	}

simulated function RemoveDelayedPlayer(PlayerReplicationInfo pri)
	{
    local int i;

    if (NetMode == NM_DedicatedServer)
        return;

    i = FindDelayedPlayer(pri);
    if (i >= DelayedPlayers.Length)
        return;
    DelayedPlayers.Remove(i,1);
}

simulated function LoadDelayedPlayers()
{
    local int i;

    if (NetMode == NM_DedicatedServer)
        return;

    //log(self$" - Loading delayed players...", 'LOADING');
    for (i=0; i<DelayedPlayers.Length; i++)
        DelayedPlayers[i].LoadPlayer();

    DelayedPlayers.Remove(0,DelayedPlayers.Length);
//    log(self$" - Done loading delayed players!", 'LOADING');
}

event FillPrecacheMaterialsArray()
{
	local Actor A;

	//"PrecacheMaterials.Empty();"
	ForEach AllActors(class'Actor',A)
		A.UpdatePrecacheMaterials();
}

event PostFXNeeded()
{
	// this will make sure the post fx manager is available
	//
	class'PostFXManager'.static.GetPostFXManager( self );
}

simulated function AddPrecacheMaterial(Material mat)
{
    local int Index;

    if (mat == None)
        return;

    Index = Level.PrecacheMaterials.Length;
    PrecacheMaterials.Insert(Index, 1);
	PrecacheMaterials[Index] = mat;
}

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();
native simulated function QuickDecal( Vector point, Vector normal, Actor HitActor, float size, float Life, Material mat, INT HitSurfaceType, INT WeaponType ); // sjs
native simulated function int TimedDecal( Vector point, Vector normal, Actor HitActor, float size, float Life, Material mat, INT HitSurfaceType, INT WeaponType ); // jim
native simulated function KillTimedDecal( INT iIndex, float fTimeToDeath ); // jim
native simulated function BloodDecal( Vector start, Vector direction, float size, Actor HitActor, Material mat ); // jim
native simulated function int FuelDecal( Vector start, Vector normal, float size, float life, Actor HitActor, Material mat ); // jim

native function bool AllowStartMenu(); // gam

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
    local PlayerController P;

	if( NextURL=="" )
	{
		// gam ---
		if( (Game != None) && ((NetMode == NM_DedicatedServer) || (NetMode == NM_ListenServer) ) )
		{
            if( !Game.PreServerTravel() )
            {
                foreach DynamicActors( class'PlayerController', P )
                {
                    if( NetConnection(P.Player)!=None )
                        continue;

                    P.ClientTravel( "MenuLevel?Menu=XInterfaceLive.MenuLiveErrorMessage", TRAVEL_Absolute, false );
                    return;
                }
                return;
            }
        }
        // --- gam

		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}

simulated function AddPhysicsVolume(PhysicsVolume NewPhysicsVolume)
{
	local PhysicsVolume V;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
		if ( V == NewPhysicsVolume )
			return;

	NewPhysicsVolume.NextPhysicsVolume = PhysicsVolumeList;
	PhysicsVolumeList = NewPhysicsVolume;
}

simulated function RemovePhysicsVolume(PhysicsVolume DeletedPhysicsVolume)
{
	local PhysicsVolume V,Prev;

	for ( V=PhysicsVolumeList; V!=None; V=V.NextPhysicsVolume )
	{
		if ( V == DeletedPhysicsVolume )
		{
			if ( Prev == None )
				PhysicsVolumeList = V.NextPhysicsVolume;
			else
				Prev.NextPhysicsVolume = V.NextPhysicsVolume;
			return;
		}
		Prev = V;
	}
}
//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation;

	reliable if( bNetInitial && Role==ROLE_Authority )
		RagdollTimeScale, KarmaTimeScale, KarmaGravScale;
}


/*****************************************************************
 * PreBeginPlay
 * Need a class that is configured to store data in a user specific
 * profile to store video information.
 *****************************************************************
 */
simulated event PreBeginPlay()
{
	// Create the object pool.
	if ( ObjectPool == None )
	{
		ObjectPool = new class'ObjectPool';  // sjs[sg]
	}

    // gam ---
    if( (Title == "") || (Title == default.Title) )
    {
        Title = String(self);
        Title = Left( Title, InStr(Title, ".") );
    }
    // --- gam
}

simulated function ObjectPool GetObjectPool() // sjs[sg]
{
    if(ObjectPool == None)
    {
        ObjectPool = new class'ObjectPool';
    }
    return ObjectPool;
}

simulated function Object AllocateObject(class ObjClass)
{
	return(GetObjectPool().AllocateObject(ObjClass));
}

simulated function FreeObject(Object Obj)
{
	GetObjectPool().FreeObject(Obj);
}

simulated function PlayerController GetLocalPlayerController()
{
	local Controller C;

	if ( Level.NetMode == NM_DedicatedServer )
		return None;
	if ( LocalPlayerController != None )
		return LocalPlayerController;

	for ( C=ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
		{
			LocalPlayerController = PlayerController(C);
			break;
		}
	}
	return LocalPlayerController;
}

// note: controllerlist does not exist for NetMode == NM_Client
simulated function int GetLocalPlayerCount()
{
	local Controller C;
	local int Count;
	
	Count = 0;
	
	for ( C=ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
		{
		    Count++;
		}
	}
	return Count;
}

simulated function bool IsCoopSession() // sjs - note, this rudely overlaps with IsCoopGame (but it is profile centric)
{
    return(GetLocalPlayerCount() > 1);
}

simulated function PlayerController GetLivingLocalPlayer()
{
   local Controller C;

	if ( Level.NetMode == NM_DedicatedServer )
		return None;

	for ( C=ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
		{
		    if(PlayerController(C).Pawn != None && PlayerController(C).Pawn.Health > 0 && !PlayerController(C).IsInState('Dead'))
		    {
			    return(PlayerController(C));
			}
		}
	}
	return None; 
}

simulated function PlayerController GetLocalPlayerByIndex(int index)
{
   local Controller C;

	if ( Level.NetMode == NM_DedicatedServer )
		return None;

	for ( C=ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) )
		{
			if(index == PlayerController(C).Player.SplitIndex)
			{
				return(PlayerController(C));
			}
		}
	}
	return None; 
}

function Pawn RandomPlayerPawn()
{
	local Controller c;
	local Pawn	SPPawns[8];
	local int	NumPawns;

	NumPawns = 0;
	for( c=Level.ControllerList; c!=None; c=c.NextController )
	{
		if(c.Pawn != None && PlayerController(c) != None)
		{
			SPPawns[NumPawns] = c.Pawn;
			NumPawns++;
			if(NumPawns == 8)
			{
				break;
			}
		}
	}
	if(NumPawns == 0)
	{
		return(None);
	}
	return(SPPawns[Rand(NumPawns)]);
}

simulated function float GetRagdollNotSeenLimit()
{
    if ( bAggressiveLOD )
    {
        return RagdollNotSeenLimit / 4;
    }
    else if ( bDropDetail )
    {
        return RagdollNotSeenLimit / 2;
    }
    else
    {
        return RagdollNotSeenLimit;
    }
}

simulated function float GetRagdollDistanceLimit()
{
    if ( bAggressiveLOD )
    {
        return RagdollDistanceLimit / 4;
    }
    else if ( bDropDetail )
    {
        return RagdollDistanceLimit / 2;
    }
    else
    {
        return RagdollDistanceLimit;
    }
}

native function bool IsCustomMap();
native function String GetCustomMap();
native function EAuthMode GetAuthMode();

defaultproperties
{
     IdealPlayerCountMin=6
     IdealPlayerCountMax=10
     MaxViewports=2
     PrimaryStartHealth=100
     MaxSimulatedRagdolls=4
     MaxFrozenRagdolls=6
     VehiclesPerTeam=3
     MaxLoadedPlayerRecords=8
     TimeDilation=1.000000
     KarmaTimeScale=0.900000
     RagdollTimeScale=1.000000
     KarmaGravScale=1.000000
     RagdollLifeSpan=2500000.000000
     RagdollNotSeenLimit=10.000000
     RagdollDistanceLimit=1024.000000
     Brightness=1.000000
     KillZ=-10000.000000
     DefaultTexture=Texture'Engine.DefaultTexture'
     WireframeTexture=Texture'Engine.WireframeTexture'
     LargeVertex=Texture'Engine.LargeVertex'
     VideoSkipList(0)="Chapter01Scene0.bik"
     VideoSkipList(1)="Chapter01Scene0Hip.bik"
     VideoSkipList(2)="Chapter01Scene1.bik"
     VideoSkipList(3)="Chapter01Scene1det.bik"
     VideoSkipList(4)="Chapter01Scene1est.bik"
     VideoSkipList(5)="Chapter01Scene1frt.bik"
     VideoSkipList(6)="Chapter01Scene1itt.bik"
     VideoSkipList(7)="Chapter01Scene2.bik"
     VideoSkipList(8)="Chapter01Scene4.bik"
     VideoSkipList(9)="Chapter03Scene2.bik"
     VideoSkipList(10)="Chapter04Scene1.bik"
     VideoSkipList(11)="Chapter05bScene4.bik"
     VideoSkipList(12)="Chapter05Scene1.bik"
     VideoSkipList(13)="Chapter05Scene2.bik"
     VideoSkipList(14)="Chapter06Scene2.bik"
     VideoSkipList(15)="Chapter06Scene4.bik"
     VideoSkipList(16)="Chapter08Scene1.bik"
     VideoSkipList(17)="Chapter08Scene4.bik"
     VideoSkipList(18)="Chapter09Scene1.bik"
     VideoSkipList(19)="Chapter11Scene1.bik"
     VideoSkipList(20)="Chapter12Scene1.bik"
     VideoSkipList(21)="Chapter13Scene1.bik"
     VideoSkipList(22)="Chapter14Scene1.bik"
     VideoSkipList(23)="Chapter15Scene1.bik"
     VideoSkipList(24)="Chapter15Scene3.bik"
     VideoSkipList(25)="Chapter16Scene1.bik"
     VideoSkipList(26)="Chapter17Scene1.bik"
     HavokBroadPhaseMin=(X=-250000.000000,Y=-250000.000000,Z=-250000.000000)
     HavokBroadPhaseMax=(X=250000.000000,Y=250000.000000,Z=250000.000000)
     Title="Untitled"
     Author="Anonymous"
     VisibleGroups="None"
     PhysicsDetailLevel=PDL_Medium
     bKStaticFriction=True
     bKNoInit=True
     bHavokSimulateOnLoad=True
     bHighDetailMode=True
     bStartWithVehicles=True
     RemoteRole=ROLE_DumbProxy
     bWorldGeometry=True
     bAlwaysRelevant=True
     bHiddenEd=True
}
