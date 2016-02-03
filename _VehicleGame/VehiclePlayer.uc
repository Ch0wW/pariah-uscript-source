class VehiclePlayer extends xPlayer
	native
	config(User);

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
// (cpptext)

const AxisScaleFactor = 1.4142135623730950488016887242097; // 2/root(2) or 1/Cos(45)

var input float aSteer, aThrottle;

var input byte bHandBrake;
var input byte bTurboButton;
var input byte bDodge;
var input byte bLookBehind;

// silly variables to track whether keys for combo letters are pressed or not
var transient bool bComboKey_U;
var transient bool bComboKey_D;
var transient bool bComboKey_R;
var transient bool bComboKey_L;

var bool bExitVehiclePlease; //cmr
var bool bExitingByAnimation; //cmr

//stuff for the temporary load out interface.

//stuff to store last camera calculations, so that if PlayerCalcView is called multiple times per frame, it doesn't throw the calculations off.

var int lastcamyaw;

var actor LastViewActor;
var vector LastCamLocation;
var rotator LastCamRotation;

var float VehicleFOV;
var float TargetCamFOV;

var bool bNoCam;
var bool bLeaveCam;

//cam interp vars

var vector CamInterpOffset; // a value added to the proper cam location to represent interp transition
var vector CamInterpStartPos;
var float InterpCenterAlpha;
var bool bCamInterping;


// we want to interp the center from the player to the vehicle, while moving outwards from the center
// to reach the designated distance.  This is a bitch, because I don't actually know a distance before
// hand, and it's just ending up at a magical distance.  This will have to be represented by a 
// total percentage or something equivalent.  This shouldn't be as difficult.

//vehicle cam vars
var Rotator SmoothRot;
var config bool bUseSmoothRot;
var Vector SmoothPos;
var config bool bUseSmoothPos;

//3rd person cam vars

var config float	thirdyawspeed;
var	config float	thirddist;
var config int		thirdpitch;
var config vector	thirdfocusoffset;
var float	thirdwallhack;
var int		thirdminpitch;
var int		thirdmaxpitch;

struct native GraphInfo
{
	var string	GraphName;
	var string	GraphStats;
	var string	ExtraArgs;
	var string	ExtraCmds;
};

var int		GraphType;
var transient array<GraphInfo>	 Graphs;

var private VGVehicle	CDrivenVehicle;
var private VGVehicle	LastDrivenVehicle;
var private bool		bBeginControlCalled;
var rotator SavedVehicleRotation;
var bool bUpdateDriverRotation;

var config	MapList	OurMapList;

//loadout info
var	bool			bLoadedOut;		//has the controller already chosen weapons
var bool            bResetWecs;
var	array<string>	LoadedWeapons;	//weapons loadedout to the controller
var	int				LoadedWeaponCount;
var array< class<Weapon> >	LoadedPlayerWeaponClass;
var Menu			LoadoutMenu;

var array<int>		Tweak1;
var array<int>		Tweak2;
var array<int>		Tweak3;
var array<int>		Tweak4;
var array<int>		TweakAvail;

// new camera shake stuff
var Vector RandomShakeMag,RandomShakePosition;
var float RandomShakeTimeStart, RandomShakeTimeLeft;

var Rotator RecoilRotation;
var float FCumulativeRecoilPitch; //to avoid framerate dependencies because of numerical inaccuracy of shorts
var int RecoilDir;
const RECOILSPEED = 22200;
var int RecoilPitch;
var float RecoilTime, RecoilTimeLeft;

var bool bInSelectionMenu;

var bool bCarStats;

// networking
var VehicleSavedMove SavedVehicleMoves;   // buffered moves pending position updates
var VehicleSavedMove FreeVehicleMoves;    // freed moves, available for buffering
var VehicleSavedMove PendingVehicleMove;  

// these are similar in function to the ones in PlayerController...just wanted to keep them separate
//
var float	VPCurrentTimeStamp, VPLastUpdateTime;
var bool	bUpdateVehiclePosition;

var		float	DeltaSum;
var	()	float 	TargetUpdateTime;

const WarningCheckTimerSlot = 0;
const ExitVehicleTimerSlot = 1;
const ExitGunnerTimerSlot = 2;


var bool	bShouldDoFlyBy;
var bool	bSceneManagerHidesHud;

var		bool	bFlashed;
var		float	FlashTime;
var	()	float	FlashDuration, FlashFadeInTime;

//Weapon Energy Core
//const		MAXWECCOUNT = 4;
//var int	WECCount[MAXWECCOUNT];
var int	WECCount;	//only have to worry about one wec count now

// for native access
var const name PlayerInVehicleStateName;
var const name PlayerInTurretStateName;

var bool bUnlimitedAmmo;

// jjs - postfx stages used by weapons. moved here because weapons are bad at cleaning up.
var transient PostFXStage TitanPostFX;
var transient PostFXStage SniperPostFX;

var bool bStartInVehicle;
var bool bInSpecialVehicleScene;

var struct native CameraState
{
	var int lastcamyaw;
	
	var bool bUse3rdPersonCam;
	var bool bBehindView;

	var actor ViewTarget;

	var actor LastViewActor;
	var vector LastCamLocation;
	var rotator LastCamRotation;

	var vector CamInterpOffset; 
	var vector CamInterpStartPos;
	var float InterpCenterAlpha;
	var bool bCamInterping;

	var Rotator SmoothRot;
	var Vector SmoothPos;

	var bool bIsValidState;
	var bool bUseRiderCamera;

	var bool bUseYawLimit;
	var int CenterYaw;
	var int MaxYaw;

}StoredCameraState;

var bool bDestroyingCtrl;

struct native LastWecConfig
{
    var class<VGWeapon> WeaponClass;
    var int             WecLevel;
};
var LastWecConfig   WecConfigs[3];

// nasty hack
var Pawn MatineePawn;


replication
{
    // functions client can call
	reliable if ( Role < ROLE_Authority )
		LoadPlayerWeapon, MPAmmoCheat, ServerExec, ServerWECLevelUp, ServerSetModel;

	reliable if( Role==ROLE_Authority )
		CDrivenVehicle,ServerDoLoadout, CoolWeapon, ClientSetYawLimit;

		// functions client can call
    reliable if( Role<ROLE_Authority )
		ExitVehicleWorker;

	//things the client should know about
    reliable if (Role==ROLE_Authority)
		WECCount;
}

exec function SetModel(string mod)
{
	ServerSetModel(mod);	
	//Pawn.bNetNotify=true;
}

function ServerSetModel(string mod)
{
	SetPawnClass("VehicleGame.VGPawn", mod);
	//SetupPlayerRecord(class'xUtil'.static.FindPlayerRecord(PRI.CharacterName));
	
	Suicide();
}

// jjs - postfx stages used by weapons
function PostFXStage GetTitanPostFX(class<PostFXStage> StageClass)
{
    if(TitanPostFX == None)
    {
	    TitanPostFX = new StageClass;
    }
    return TitanPostFX;
}

function PostFXStage GetSniperPostFX(class<PostFXStage> StageClass)
{
    if(SniperPostFX == None)
    {
	    SniperPostFX = new StageClass;
    }
    return SniperPostFX;
}

function StoreCameraState()
{
	StoredCameraState.lastcamyaw=lastcamyaw;
	
	StoredCameraState.bUse3rdPersonCam=bUse3rdPersonCam;
	StoredCameraState.bBehindView=bBehindView;

	StoredCameraState.ViewTarget=ViewTarget;

	StoredCameraState.LastViewActor=LastViewActor;
	StoredCameraState.LastCamLocation=LastCamLocation;
	StoredCameraState.LastCamRotation=LastCamRotation;

	StoredCameraState.CamInterpOffset=CamInterpOffset; 
	StoredCameraState.CamInterpStartPos=CamInterpStartPos;
	StoredCameraState.InterpCenterAlpha=InterpCenterAlpha;
	StoredCameraState.bCamInterping=bCamInterping;

	StoredCameraState.SmoothRot=SmoothRot;
	StoredCameraState.SmoothPos=SmoothPos;
	StoredCameraState.bUseRiderCamera=bUseRiderCamera;

	StoredCameraState.bUseYawLimit=bUseYawLimit;
	StoredCameraState.CenterYaw=CenterYaw;
	StoredCameraState.MaxYaw=MaxYaw;

	StoredCameraState.bIsValidState = true;
}

function RestoreCameraState()
{
	if(StoredCameraState.bIsValidState == false) return;

	lastcamyaw=StoredCameraState.lastcamyaw;

	bUse3rdPersonCam=StoredCameraState.bUse3rdPersonCam;
	bBehindView=StoredCameraState.bBehindView;

	SetViewTarget(StoredCameraState.ViewTarget);

	LastViewActor=StoredCameraState.LastViewActor;
	LastCamLocation=StoredCameraState.LastCamLocation;
	LastCamRotation=StoredCameraState.LastCamRotation;

	CamInterpOffset=StoredCameraState.CamInterpOffset; 
	CamInterpStartPos=StoredCameraState.CamInterpStartPos;
	InterpCenterAlpha=StoredCameraState.InterpCenterAlpha;
	bCamInterping=StoredCameraState.bCamInterping;

	SmoothRot=StoredCameraState.SmoothRot;
	SmoothPos=StoredCameraState.SmoothPos;

	bUseRiderCamera=StoredCameraState.bUseRiderCamera;

	bUseYawLimit=StoredCameraState.bUseYawLimit;
	CenterYaw=StoredCameraState.CenterYaw;
	MaxYaw=StoredCameraState.MaxYaw;

	StoredCameraState.bIsValidState = false;

}

function ClientSetYawLimit(int Center, int Max)
{
	if(max != 0)
		bUseYawLimit = true;
	else 
		bUseYawLimit = false;
	CenterYaw = center;
	MaxYaw = max;
}


function SetRiderCamYawLimit(int center, int max)
{
	if(max != 0)
		bUseYawLimit = true;
	else 
		bUseYawLimit = false;
	CenterYaw = center;
	MaxYaw = max;
	ClientSetYawLimit(CenterYaw, MaxYaw);
}

function SetRiderCamStuff(Pawn target, bool on)
{

	//log("--------setting rider cam stuff"@target@on);
	
	ClientSetViewTarget(target);
	ClientSetThirdPersonCamera(on,true);

}

function CalculateThreatLevel()
{
	if(Pawn != none && Pawn.Weapon != none && Pawn.Weapon.IsA('PersonalWeapon'))
	{
		PlayerReplicationInfo.ThreatLevel = PersonalWeapon(Pawn.Weapon).WECLevel;
	}
}

function ViewFlash(float DeltaTime)
{
	local float diff;
	Super.ViewFlash(DeltaTime);
	if(bFlashed)
	{
		if(FlashTime > Level.TimeSeconds + FlashFadeInTime)
		{
			FlashScale=vect(0.0,0,0);
			FlashFog=vect(255,255,255);
		}
		else if(FlashTime > Level.TimeSeconds)
		{
			diff = Level.TimeSeconds - FlashTime;
			diff = diff / FlashFadeInTime + 1.0;
			FlashScale=vect(0.0,0,0);
			FlashScale.X = diff;
			FlashFog=vect(255,255,255);
		}
		else
		{
			bFlashed = false;
		}
	}
}

function FlashHit()
{
	bFlashed = true;
	FlashTime = Level.TimeSeconds + FlashDuration;
}

function ClearFlash()
{
	bFlashed = false;
	FlashTime = Level.TimeSeconds - FlashDuration - FlashFadeInTime;
	FlashScale=vect(0.0,0,0);
	FlashFog=vect(255,255,255);
}

function PawnDied(Pawn P)
{
    if(TitanPostFX != None)
    {
        RemovePostFXStage( TitanPostFX );
    }
    if(SniperPostFX != None)
    {
        RemovePostFXStage( SniperPostFX );
    }

	Super.PawnDied(P);
	ClearFlash();
}

exec function TglFlyByHud()
{
	bSceneManagerHidesHud = !bSceneManagerHidesHud;
}

exec function TglHavokHitFX()
{
	class'xPawn'.default.SkeletalBlendingEnabled = !class'xPawn'.default.SkeletalBlendingEnabled;
}

simulated event PostBeginPlay()
{
	if ( !IsShipping() )
	{
        AddCheats();
	}

	Super.PostBeginPlay();
}

exec function ServerExec(string s)
{
	if ( !IsShipping() )
	{
        ConsoleCommand(s);
    }
}

exec function HurtSelf(int num)
{
    if(Pawn == None)
    {
        return;
    }
    Pawn.TakeDamage(num, none, Location, vect(0,0,0), class'Fell');
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	bBehindView=bUse3rdPersonCam;
	InitGraphs();
	SetTimer( 1, True );
	SetMultiTimer( WarningCheckTimerSlot, 1, True );
}

simulated event RenderOverlays( Canvas C )
{
	if( !bCarStats || Pawn == None || !Pawn.IsA('VGVehicle') ) 
		return;

	VGVehicle(Pawn).DrawVehicleStats( C );
}

//Weapon Energy Core


simulated function AddWEC(int Ammount)
{
    if(Role == ROLE_Authority)
    {
	    WECCount += Ammount;
    }
    // TODO: possible show a localmessage if they can upgrade a gun here?
}

simulated function bool HasWEC()
{
	return WECCount > 0;
}							  

exec function CarStats()
{
	bCarStats=!bCarStats;
}

exec function ShowObjectivesOr( String AltCmd )
{
	ConsoleCommand( AltCmd );
}

function RandomShake(Vector Mag, float time)
{
	//log("new shake "$Mag$" time "$time);
	RandomShakeMag = Mag;
	RandomShakeTimeStart = time;
	RandomShakeTimeLeft = time;
}

exec function TestShake()
{
	RandomShake(Vect(50,50,50), 0.5);
}

exec function what()
{
	log("I am "$self$" and I am in state "$GetStateName());
}


function ExplosionShake(vector explodepos, float radius, optional float time)
{
	local float impulsemag, dist, realtime;
	local actor cam;
	local vector camloc, v;
	local rotator camrot;

	v = Vect(1,1,1);
	//get camera location
	PlayerCalcView(cam, camloc, camrot);
	
	dist = VSize(camloc - explodepos);

	if(dist < (2.0*radius))
	{
		impulsemag = 40.0 * (1.0 - (dist / (2.0*radius)));

		if(time == 0)
			realtime = 0.5;
		else
			realtime = time;
		RandomShake( v*impulsemag, realtime);
	}



} 


function UpdateRandomShake(float dt)
{
	local float scale;

	if(RandomShakeTimeLeft <= 0.0) return;

	//get shake scaler (based on time left)
	
	scale = RandomShakeTimeLeft / RandomShakeTimeStart;

	//get a new shake position
	RandomShakePosition.X = rand(RandomShakeMag.X*2.0 * scale) - RandomShakeMag.X * scale;
	RandomShakePosition.Y = rand(RandomShakeMag.Y*2.0 * scale) - RandomShakeMag.Y * scale;
	RandomShakePosition.Z = rand(RandomShakeMag.Z*2.0 * scale) - RandomShakeMag.Z * scale;

	//log(shakeposition);

	RandomShakeTimeLeft -= dt;
}

function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;
	local rotator NewCamShakeRot;
	
    GetAxes(Rotation, x, y, z);

    if( bNewCamShake ) //xmatt
    {
		NewCamShakeRot.Pitch = Vertical_cam_spring.spring_pos.X * 50;
		NewCamShakeRot.Yaw = Vertical_cam_spring.spring_pos.Y * 50;
		
   		CameraRotation = Normalize( Rotation + ShakeRot + NewCamShakeRot );
		CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob +
						RandomShakePosition.X * x +
						RandomShakePosition.Y * y +
						RandomShakePosition.Z * z;
    }
    else
    {
		CameraRotation = Normalize(Rotation + ShakeRot + RecoilRotation); // XJ put the shake rotation back
		CameraLocation = CameraLocation + Pawn.EyePosition() + Pawn.WalkBob + // amb
						RandomShakePosition.X * x +
						RandomShakePosition.Y * y +
						RandomShakePosition.Z * z + 
						ShakeOffset.X * x +
						ShakeOffset.Y * y +
						ShakeOffset.Z * z;
	}
}

function RecoilShake(int Pitch, float Time)
{
	if(RecoilDir != 0) return;
	RecoilRotation.pitch = 0;
	FCumulativeRecoilPitch = 0;
	RecoilPitch = Pitch;
	//RecoilTime = Time;
	RecoilDir=1;
	//RecoilTimeLeft = Time;
}


function ViewShake(float DeltaTime)
{
    Super.ViewShake(DeltaTime);
	CalculateRecoilShake(DeltaTime);
}

function CalculateRecoilShake(float DeltaTime)
{
	local float errortime;
	local int error;
	if(RecoilDir == -1) //returning
	{
		FCumulativeRecoilPitch -= RECOILSPEED * 0.1 * DeltaTime; //RecoilPitch * ( RecoilTimeLeft / RecoilTime );
		//RecoilTimeLeft -= DeltaTime;
		//if(RecoilTimeLeft <= 0.0)
		if(FCumulativeRecoilPitch <= 0.0)
		{
			FCumulativeRecoilPitch = 0.0;
			RecoilDir = 0;
		}
		RecoilRotation.pitch = GetCosineRecoilPitch(FCumulativeRecoilPitch);
	}
	else if(RecoilDir == 1)//recoiling
	{
		FCumulativeRecoilPitch += RECOILSPEED * DeltaTime;
		if(FCumulativeRecoilPitch >= RecoilPitch)
		{
			error = RecoilPitch - FCumulativeRecoilPitch;
			FCumulativeRecoilPitch = RecoilPitch;
			//RecoilTimeLeft = RecoilTime;
			RecoilDir = -1;
			errortime = error / RECOILSPEED;
		}
		RecoilRotation.pitch = GetCosineRecoilPitch(FCumulativeRecoilPitch);
		if(error != 0.0)
			CalculateRecoilShake(errortime);
	}

}

function int GetCosineRecoilPitch(float realpitch)
{
	
	return RecoilPitch * ( 
		( 
		Cos( ( ((RecoilPitch - realpitch) / RecoilPitch)*0.5 + 0.5 ) * PI ) 
		+  1.0 
		) 
		/ 2.0 
		);
}

auto state PlayerWaiting
{
	function PlayerTick(float dT)
	{
		Super.Tick(dT);
		if(bShouldDoFlyBy)
		{
			bShouldDoFlyBy = false;
			DoFlyBy();
		}
	}
	exec function Fire(optional float f)
	{
        if( PlayerReplicationInfo == None )
        {
            return;
        }
        
        if( GameReplicationInfo == None )
        {
            return;
        }
            	
		if(!bLoadedOut)		
			DoLoadout();		
	}

	exec function AltFire(optional float f)
	{
		Fire(f);		
	}

	function bool CanRestartPlayer()
	{
		if(!Super.CanRestartPlayer())
			return False;

		return bLoadedOut;// || !ShouldStartWithVehicle();
	}

	function MenuMessage(string msg)
	{
		
		//local class<Menu> MenuMidGameClass;
		if(msg == "DONELOADOUT")
		{
			bLoadedOut=true;
			if(GameReplicationInfo.bTeamGame==true)
			{
				if(PlayerReplicationInfo.Team.TeamIndex==0)
					ReceiveLocalizedMessage(class'PlayerInfoMessage', 2, PlayerReplicationInfo);
				else if(PlayerReplicationInfo.Team.TeamIndex==1)
					ReceiveLocalizedMessage(class'PlayerInfoMessage', 3, PlayerReplicationInfo);
			}
			ServerRestartPlayer();
		}
		else if(msg == "DONEWEAPONSELECT")
		{
			bLoadedOut=true;
			ServerRestartPlayer();
		}
	}

	function BeginState()
	{
		local string SkipLoadout;
		
		Super.BeginState();

		// I use this hook to skip loadout while doing network testing (rj@bb)
		//
		SkipLoadout = GetUrlOption("SkipLoadout");
		if ( Caps(SkipLoadout) == "TRUE" )
		{
			bLoadedOut=true;
			
			ServerRestartPlayer();
		}
	}

	function EndState()
	{
		bFire=0;
		bAltFire=0;
		Super.EndState();
		skipMatinee();
	}

	simulated function PlayLoadOutFlyBy()
	{
		bShouldDoFlyBy = true;
	}

	simulated function DoFlyBy()
	{
		local bool bLocalPlayer, bLinearizedPC ;
		bLocalPlayer = (Viewport(Player) != None) ;

		bLinearizedPC = (Role == ROLE_Authority && Level.NetMode==NM_Client);
		if(bLinearizedPC)
		{
			log("MIKEH SKIP FLYBY FOR THIS PLAYERCONTROLLER");
			return;
		}
		if(IsSharingScreen())
		{
		    return;
		}

		//Start up flyby before entering game.
		if( bLocalPlayer )
		{	
			log("MIKEH TRIGGERING FLYBY");
			TriggerEvent(Level.LoadoutFlyByTag, self, None);
		}	
	}

	simulated function skipMatinee()
	{
		local SceneManager sceneMgr;
		local bool bLocalPlayer;
		
		bLocalPlayer = (Viewport(Player) != None) ;
		
		if( bLocalPlayer )
		{
			ForEach DynamicActors(class'SceneManager',sceneMgr)
			{
				if( sceneMgr.bIsRunning)
				{
					sceneMgr.bIsRunning = false;
					sceneMgr.SceneEnded();
				}
			}
		}


		
	}

	//Overridden from Actor to avoid state change.
	simulated function StartInterpolation()
	{
		SetCollision(True,false,false);
		bCollideWorld = False;
		bInterpolating = true;
		SetPhysics(PHYS_None);
		
		//A bit of a hack to make the OverlayPreGame stay showing during the flyby
		MyHud.bHideHUD = bSceneManagerHidesHud;
	}

	simulated function DoLoadout()
	{
		Global.DoLoadout();
	}
}

function MenuMessage(string msg)
{
	if(msg == "DONELOADOUT")
	{
		bLoadedOut=true;
	}
	else if(msg == "DONEWEAPONSELECT")
	{
		bLoadedOut=true;
	}
	bResetWecs = true;
}


function ServerDoLoadout() //called from the server to force the client to do his loadout
{
	DoLoadout();
}

exec function DebugGiveVehicle() //debug function to give a player a vehicle
{
	log("DEBUGGIVEVEHICLE HAS BEEN DEPRECATED.  IF YOU NEED THIS FUNCTION RE-IMPLEMENTED PLEASE TALK TO CHARLES."); //deprecated like a motherfucker yo
}

exec function DoLoadout()
{
	local class<Menu> MenuMidGameClass;

	bInSelectionMenu=True;
	MenuMidGameClass = class<Menu>( DynamicLoadObject( "VehicleInterface.LoadOutMenu", class'Class' ) );

	if( MenuMidGameClass == None )
	{
		log( "Could not load VehicleInterface.LoadOutMenu!", 'Error' );
		return;
	}
	MenuOpen( MenuMidGameClass );
	LoadoutMenu = CurrentMenu();
}

simulated function CoolWeapon(float amount)
{
	local Pawn P;
	local VGWeaponFire fire;

	P = Pawn;


	if (P.Weapon != None )
    {
        
		if(P.Weapon.FireMode[0]!=None && P.Weapon.FireMode[0].IsA('VGWeaponFire'))
		{
			fire = VGWeaponFire(P.Weapon.FireMode[0]);
			log("cooling weapon on client "$amount);
			fire.HeatTime -= amount * fire.MaxHeatTime;
			
			if(fire.HeatTime < 0) fire.HeatTime = 0;
			
		}

    }
	
}

function GiveLoadOut()
{
	local int i;
	//log("XJ: GiveLoadOut() Called");
	if(bLoadedOut)
	{
		if(Pawn.IsA('VGVehicle'))
		{
			//log("XJ: GiveWeapon: "$LoadedWeapons[i]);
			for(i=0;i<LoadedWeapons.Length;i++)
			{
				Pawn.GiveWeapon(LoadedWeapons[i]);
				//log("XJ: GiveWeapon: "$LoadedWeapons[i]);
			}
			VGVehicle(Pawn).GiveDefaultWeapon();
		}
	}
}

function GivePlayerLoadout()
{
	local UnrealPawn unPawn;
	local int i;

	if(bLoadedOut)
	{
		if(Pawn.IsA('VGVehicle'))
		{
			unPawn = VGVehicle(Pawn).Driver;
		}
		else
		{
			unPawn = UnrealPawn(Pawn);
		}

		if(unPawn != None)
		{
			for(i = 0; i < LoadedPlayerWeaponClass.Length; i++)
			{
				unPawn.GiveWeaponByClass( LoadedPlayerWeaponClass[i] );
			}
			SwitchWeapon(Weapon(unPawn.FindInventoryType(LoadedPlayerWeaponClass[0]) ).InventoryGroup);
		}
	}
}

simulated function LoadPlayerWeapon(class<Weapon> wClass, int WeaponCount)
{
	LoadedPlayerWeaponClass[WeaponCount] = wClass;
}

simulated function MPAmmoCheat(optional bool bNoOverheat)
{
	bUnlimitedAmmo = true;
	Pawn.bNoOverheat = bNoOverheat;
}

simulated function ClientLoadPlayerWeapon(class<Weapon> wClass, int WeaponCount)
{
	LoadedPlayerWeaponClass[WeaponCount] = wClass;
}

//throwing the weapon out.
exec function ThrowWeapon()
{
	if( Level.NetMode == NM_Client )
		return;
	if( Pawn.Weapon==None || !Pawn.Weapon.bCanThrow )
		return;
	//Pawn.Weapon.bTossedOut = true;
	Pawn.TossWeapon((-Vector(Rotation) + vect(0,0,1)) * 750);
	if ( Pawn.Weapon == None )
		SwitchToBestWeapon();
}

function NotifyRestarted()
{
  	local string startwecs;
  	local int appliedWecs;
  	local int baseWecs;
  	
	GivePlayerLoadout();
	
	if(Caps(GetUrlOption("LooseWECS")) == "TRUE")
	{
	    WECCount = 0;
    }

  	startwecs = GetURLOption("StartWECCount");
  	if(startwecs!="")
	{
	    baseWecs = int(startwecs);
	    appliedWecs = GetNumAppliedWecs();
	    baseWecs -= appliedWecs;
		WECCount = Max(WECCount, baseWecs);
		//log("WEC INIT: "@baseWecs@appliedWecs@WECCount);
	}
	
	if(bResetWecs)
	{
	    ResetWecConfig();
	    bResetWecs = false;
    }
    else
    {
	    ApplyLastWecConfig();
    }
	
	CalculateThreatLevel();
}

function int GetNumAppliedWecs()
{
    local int i;
    local int w;
    local class<VGWeapon> WepClass;
    local int AppliedSpecs;
    
    AppliedSpecs = 0;
    for( i = 0; i < ArrayCount(WecConfigs); ++i )
    {
        WepClass = WecConfigs[i].WeaponClass;
        if(WepClass != None)
        {
            for(w = 0; w < WecConfigs[i].WecLevel; ++w)
            {
                AppliedSpecs += WepClass.default.WECPerLevel[w];
            }
        }
    }
    return(AppliedSpecs);
}

function ApplyLastWecConfig()
{
    local int i;
    local VGWeapon Wep;
    
    if(Level.Game != None && Level.Game.bSinglePlayer)
    {
        return;
    }
    
    for( i = 0; i < ArrayCount(WecConfigs); ++i )
    {
        if(WecConfigs[i].WeaponClass == None)
        {
            continue;
        }
        Wep = VGWeapon(Pawn.FindInventoryType(WecConfigs[i].WeaponClass));
        if(Wep != None)
        {
            Wep.SetWecLevel(WecConfigs[i].WecLevel);
            //log(">>> Applying WEC:"@WecConfigs[i].WecLevel@WECCount);
        }
    }
}

function ResetWecConfig()
{
    local int i;
    local int w;
    local class<VGWeapon> WepClass;
    
    for( i = 0; i < ArrayCount(WecConfigs); ++i )
    {
        WepClass = WecConfigs[i].WeaponClass;
        if(WepClass != None)
        {
            for(w = 0; w < WecConfigs[i].WecLevel; ++w)
            {
                WECCount += WepClass.default.WECPerLevel[w];
            }
        }
        WecConfigs[i].WeaponClass = None;
        WecConfigs[i].WecLevel = 0;
    }
}

exec function WECUp()
{
	local VGWeapon	VW;
	if(Pawn.IsA('VGPawn') && Pawn.Weapon != none && Pawn.Weapon.IsA('VGWeapon') )
	{
		VW = VGWeapon(Pawn.Weapon);
    	ClientWECLevelUp(VW);
	}
}


function ClientWECLevelUp(VGWeapon W)
{
    if(Role < ROLE_Authority)
    {
        W.WECLevelUp(true);
    }
    ServerWECLevelUp(W);
}

function ServerWECLevelUp(VGWeapon W)
{
    local int freeIndex;
    local int i;
    
    if( W.WECLevel >= W.WECMaxLevel )
    {
        return;
    }
    
    if( WecCount < W.WECPerLevel[W.WECLevel] ) 
    {
        return;
    }

    WECCount -= W.WECPerLevel[W.WECLevel];
    W.WECLevelUp(true);
    
    freeIndex = 0;
    
    for( i = 0; i < ArrayCount(WecConfigs); ++i )
    {
        if(WecConfigs[i].WeaponClass == W.class)
        {
            WecConfigs[i].WecLevel = W.WECLevel;
            //log(">>>>>"@WecConfigs[i].WeaponClass@W.WECLevel);
            return;
        }
        else if(WecConfigs[i].WeaponClass == None)
        {
            freeIndex = i;
        }
    }
    WecConfigs[freeIndex].WeaponClass = W.class;
    WecConfigs[freeIndex].WecLevel = W.WECLevel;
    //log("<>>"@WecConfigs[freeIndex].WeaponClass@W.WECLevel);
}


native function bool IsDrivenVehicleValid();
native function bool InValidVehicleState();

event PlayerTick( float DeltaTime )
{
	local vector X,Y,Z;

	// - if the controller's pawn is a vehicle but we aren't in a valid vehicle state,
	//   ignore this tick and restart
	// - this only seems to happen in a network game on the client when the controller's
	//   pawn is updated before the state is changed
	// - TODO: find a better way to cope with this
	//
	if ( VGVehicle( Pawn ) == None || InValidVehicleState() )
	{
	    //XJ only update target every so often
	    //xmatt: No targetting for the MiniEd (I get a crash in execUpdateTarget because my VehiclePlayer
	    //doesn't have a "Team", can't figure out where a TeamInfo should be given to my VehiclePlayer)
	    DeltaSum += DeltaTime;
	    if(Viewport(Player) != None 			//controlled locally
		    && DeltaSum >= TargetUpdateTime
		    && Pawn != none && Pawn.Weapon != none
		    && !bMiniEdEditing )
	    {
		    DeltaSum = 0.0;
		    //update target
		    GetAxes(Rotation, X, Y, Z);
		    UpdateTarget(Pawn.Weapon.GetFireStart(X,Y,Z), Pawn.Weapon);
	    }

		Super.PlayerTick( DeltaTime );
	}
	else
	{
		Restart();
	}
	
    if(Pawn != None && Pawn.Health > 0 && Pawn.Health <= 25)
	{
	    MyHud.SetLocation(Pawn.Location);
		MyHud.AmbientSound = Sound'PariahWeaponSounds.HealthAlarmB';
	}
	else
	{
	    MyHud.AmbientSound = None;
	}
}

event MultiTimer( int Slot )
{
	local int i;
	local string msg;

	switch ( Slot )
	{
	case WarningCheckTimerSlot:
		if ( myHUD != None )
		{
			for ( i = myHud.LocalizedMessageSlotsAvailable(); i > 1; i-- )
			{
				// check if there are any warnings 
				//
				msg = ConsoleCommand( "NEXTVISUALWARNING" );
				if ( msg != "" )
				{
					myHUD.LocalizedMessage( class'TakeNoticeMessage', 0, None, None, None, msg );
				}
				else
				{
					break;
				}
			}
		}
		break;
	case ExitVehicleTimerSlot:
		bExitingByAnimation=false;
		if(CDrivenVehicle != none)	
			CDrivenVehicle.DriverExits();
		break;
	case ExitGunnerTimerSlot:
		bExitingByAnimation=false;

		VGPawn(Pawn).RiddenVehicle.EndRide(VGPawn(Pawn));

		Pawn.SetPhysics(PHYS_Falling);
		Pawn.bForcePhysicsRep=True;
		Pawn.SetBase(None);
		Pawn.bForceBaseRep=True;
		bIsRidingVehicle=False;


		break;
	}
}

event ProcessVehicleMove(
	float	DeltaTime,
	float	NewThrottle,
	float	NewSteering,
	float	NewTurn
)
{
}

function ResetCameraHacks()
{
	SmoothPos = Pawn.Location;
}


simulated function CameraInVehicle(float deltat )
{
    local VGVehicle car;
	local Rotator HackRot;
	local Rotator rDesired;
	local Rotator rFinal;
	local float yawalpha;
	local vector vFinal;
	local actor TraceHit;

	local vector v, height;

    local vector HitLocation, HitNormal;

	local float YawInterpSpeed;
	
	local float speed, fovalpha;

//	if(Role < ROLE_Authority) {
//		rotYaw = Rotation.Yaw;
//		rotPitch = Rotation.Pitch;
//	}

	//if no viewtarget return and the camera will stay at it's last pos/rot
	if(ViewTarget==None || bLeaveCam) return;

	//DesiredFOV = VSize(Pawn.Velocity)

	if(!(bUseRiderCamera && bIsRidingVehicle))
	{
		speed = VSize(Pawn.Velocity);

		if(speed < 600)
		{
			TargetCamFOV = 70;
		}
		else if(speed < 1200)
		{
			TargetCamFOV = 85;
		}
		else if(speed < 1800)
		{
			TargetCamFOV = 85;
		}
		else
		{
			TargetCamFOV = 85;
		}

		fovalpha = 1.0 - (1.0/(2.0**(deltat*1.5)));

		FOVAngle += (TargetCamFOV - FOVAngle) * fovalpha;
		DesiredFOV = FOVAngle;
	}
	
	if(bUseRiderCamera && bIsRidingVehicle) // urk
	{
//		log("I'm in the vehicle camera, and my stuff is: "$ViewTarget);
	}


	if(bCamInterping)
	{
		if(CamInterpOffset == Vect(0,0,0)) //need to initialize
		{
			CamInterpOffset = CamInterpStartPos - ViewTarget.Location;
			InterpCenterAlpha = 0.6;
		}
		SmoothPos = ViewTarget.Location + CamInterpOffset*InterpCenterAlpha;
	}
	else
	{
		SmoothPos=ViewTarget.Location;
	}
	
	
	/* NOTES
		-- subtracting yaw values moves in clockwise direction.
		-- steering is -1 when steering right, 1 when steering left.
		-- if going forward (+ vel), and turning right (-1) yaw is -
		-- if going forward (+) and turning left (+) yaw is +
		-- if going backward (-) and turning right (-), yaw is +
		-- if going backward (-) and turning left (+), yaw is -
	*/

	if ( Pawn != None )
	{
		Pawn.BecomeViewTarget();
	}

	LastViewActor = ViewTarget;

	car = VGVehicle(ViewTarget);

	if(car==none) return;

	if(bCamInterping)
	{
		YawInterpSpeed = 4.5;
	}
	else
	{
		YawInterpSpeed = car.caminterpyawspeed;
	}


	if(bUseSmoothRot==False || bLookSteer || (bUseRiderCamera && bIsRidingVehicle))
	{
		SmoothRot.Yaw=0;
		SmoothRot.Pitch=0;
		SmoothRot.Roll=0;
	}
	else
	{
		
		SmoothRot.pitch=InterpToDesired(SmoothRot.pitch, car.Rotation.pitch, 1.0 - (1.0/(2.0**(deltat*5.0))));
		SmoothRot.yaw = Car.Rotation.yaw;

	}

	yawalpha = 1.0 - (1.0/(2.0**(deltat*YawInterpSpeed)));
 	
	height.z = car.camheight;


	//calculate the desired rotation
	if ( bLookSteer || (bUseRiderCamera && bIsRidingVehicle) )
	{
		rDesired = Rotation;
		rDesired.Roll = 0;
		HackRot.pitch = rDesired.Pitch;
	}
	else
	{
		rDesired.yaw = car.Rotation.yaw;
		rDesired.pitch = car.campitch;
		HackRot.pitch = SmoothRot.pitch;
	}
	
	
	rFinal = rDesired;
	
	
	rFinal.yaw = InterpToDesired(lastcamyaw, rDesired.yaw,yawalpha);
	rFinal.pitch = rDesired.Pitch + SmoothRot.pitch;

	HackRot.yaw = rFinal.yaw;
	
	v = Vector(Hackrot);
	 
	vFinal = (SmoothPos + (height>>SmoothRot)) + v*-car.camdist;
	
	
	lastcamyaw = rFinal.yaw;
	
	if(bLookBehind!=0)
	{
		rFinal.yaw = (rFinal.yaw + 32768)&65535;
		HackRot.yaw = rFinal.yaw;

		v = Vector(Hackrot);
		vFinal = (SmoothPos + height) + v*-car.camdist;

	}

	if(bCamInterping)
	{
		//calculate the wanted final position

		vFinal = SmoothPos + ((vFinal - SmoothPos) * (1.0 - InterpCenterAlpha));
		
		
		InterpCenterAlpha -= 1.0 - (1.0/(2.0**(deltat*1.0)));

		//log("alpha is now "$InterpCenterAlpha);

		if(InterpCenterAlpha <= 0.0)
		{
			EndCamInterp();
		}
	}

	TraceHit=Trace( HitLocation, HitNormal, vFinal, (SmoothPos + height), false );
	if( TraceHit != None )
	{
		if( !(TraceHit.IsA('StaticMeshActor') && StaticMeshActor(TraceHit).bBlocksCamera==False) )
		{
			//log("a;dsflkjas;dflkajsd;flkajdsf;k");
			vFinal = HitLocation;
			//bump camera out from wall (so cam plane doesn't clip through)
			vFinal += HitNormal*4.0;
		}
	}
	
	LastCamRotation = rFinal;
	LastCamLocation = vFinal;

}

exec function driversinfo()
{
	local VGPawn adriver;

	ForEach AllActors(class'VGPawn', adriver)
	{
		if(adriver.DrivenVehicle == None)
			continue;

		log("NEW DRIVER");
		log("------------");
		
		log("Driver is "$adriver);
		log("DrivenVehicle is "$adriver.DrivenVehicle);
		log("RelativeLocation is "$adriver.RelativeLocation);
		log("RelativeLocation should probably be "$(adriver.DrivenVehicle.DrivePos + Vect(0,0,80)));
		log("Driver is at "$adriver.Location$" Vehicle is at "$adriver.DrivenVehicle.Location);
		log("Difference is "$adriver.DrivenVehicle.Location - adriver.Location);
	}
}


simulated function CameraTurret(float deltat)
{
	local LevelTurret turret;
	local vector RotX, RotY, RotZ;
	local vector FinalCamOffset;
	
	//log("CAMERA");

	turret = LevelTurret(ViewTarget);

	if(turret==None)
	{
		log("CHARLES: Turret Cam being called for non-turret!!");
		return;
	}

	//turret.UpdateTurret(deltat);
	if(LastCamRotation != turret.rotation)
		LastCamRotation=turret.rotation;
	//log("ViewActor is "$ViewTarget.Name$" and is at "$ViewTarget.Location.X$" "$ViewTarget.Location.Y$" "$ViewTarget.Location.Z);
	//log(CameraRotation);
	
	LastViewActor = ViewTarget;

	GetAxes(turret.Rotation, RotX, RotY, RotZ);

	FinalCamOffset = RotX * turret.CameraOffset.X + RotY * turret.CameraOffset.Y + RotZ * turret.CameraOffset.Z;
	LastCamLocation = ViewTarget.Location + FinalCamOffset/* + turret.WeaponMountOffset[0]*/;
	//LastCamRotation = turret.Rotation;
	LastCamRotation = Rotation;
}

//ripped from unrealplayer.uc
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	function bool NotifyLanded(vector HitNormal)
	{
		if ( Global.NotifyLanded(HitNormal) )
			return true;
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
			Pawn.Velocity *= 0.1;
		}
		else
			DoubleClickDir = DCLICK_None;
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local rotator r;

		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UnrealPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}
		if(bDodge != 0)
		{
			ButtonDodge();
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
		
		if(bIsRidingVehicle && bExitVehiclePlease && !Pawn.bPlayingEnterExitAnim)
		{
//			log("GETTING OUT OF THE RIDER SPOT ASDLFKJASL;DFJ");
			bExitVehiclePlease = False;
			if(Role==ROLE_Authority)
			{
				//log(VGPawn(Pawn).RiddenVehicle.IsGunnerSpot[ VGPawn(Pawn).RiddenVehicleSpot ]);

				if( VGPawn(Pawn).RiddenVehicle.CheckExitSpot(true, VGPawn(Pawn).RiddenVehicleSpot) )
				{
					bExitingByAnimation=true;
			
					SetMultiTimer(ExitGunnerTimerSlot, 1.0, false);
					Pawn.SetAnimAction(VGPawn(Pawn).RiddenVehicle.GunnerExitAnim);
					Pawn.bPlayingEnterExitAnim = true;


				}
				else
				{
					VGPawn(Pawn).RiddenVehicle.EndRide(VGPawn(Pawn));

					Pawn.SetPhysics(PHYS_Falling);
					Pawn.bForcePhysicsRep=True;
					Pawn.SetBase(None);
					Pawn.bForceBaseRep=True;
					bIsRidingVehicle=False;
				}
			}
		}

		if(bExitVehiclePlease && VGPawn(Pawn).RiddenTurret != none) {
			log("!! Want to exit "$VGPawn(Pawn).RiddenTurret);
			VGPawn(Pawn).RiddenTurret.EndRide(VGPawn(Pawn) );

			Pawn.SetPhysics(PHYS_Falling);
			Pawn.bForcePhysicsRep = True;
			Pawn.SetBase(None);
			Pawn.bForceBaseRep = True;
			bIsRidingVehicle = False;
			bExitVehiclePlease = false;
		}

		// when walking, the rotation roll of the pawn and/or camera should be zero (rj@bb)
		// TODO: figure out why it becomes non-zero in the first place
		//
		if(!bIsRidingVehicle)
		{
			if ( Pawn != None )
			{
				if ( Pawn.Rotation.Roll != 0 )
				{
					// log( "RON: "$Pawn$"'s roll is non-zero ("$Pawn.Rotation.Roll$")!!" );
					r = Pawn.Rotation;
					r.Roll = 0;
					Pawn.SetRotation( r );
				}
			}
			if ( Rotation.Roll != 0 )
			{
				// log( "RON: "$self$"'s roll is non-zero ("$Rotation.Roll$")!!" );
				r = Rotation;
				r.Roll = 0;
				SetRotation( r );
			}
		}
	}

	function BeginState()
	{
		glog( RJ2, ""$GetStateName()$"::BeginState" );
		Super.BeginState();
	}

	function EndState()
	{
		glog( RJ2, ""$GetStateName()$"::EndState" );
		Super.EndState();
	}
}

function ButtonDodge()
{
	local bool bForward,bBack,bLeft,bRight;
	local UnrealPawn uPawn;
	local float fForwardSize;
	local float fStrafeSize;

	uPawn=UnrealPawn(Pawn);

	if(uPawn==None) return;

	fForwardSize=Abs(aForward);
	fStrafeSize=Abs(aStrafe);

	bForward = (aForward > 0);
	bBack = (aForward < 0);
	bLeft = (aStrafe > 0);
	bRight = (aStrafe < 0);

	if(fForwardSize > fStrafeSize)
	{
		if(bForward)
			uPawn.Dodge(DCLICK_Forward);
		else if(bBack)
			uPawn.Dodge(DCLICK_Back);
	}
	else if(fStrafeSize >= fForwardSize)
	{
		if(bLeft)
			uPawn.Dodge(DCLICK_Left);
		else if(bRight)
			uPawn.Dodge(DCLICK_Right);
	}

}

function UpdateRotation(float DeltaTime, float MaxPitch)
{
	local Rotator r;

	Super.UpdateRotation(DeltaTime, MaxPitch);

	//clamp PlayerController pitch

	if(!bUse3rdPersonCam) return;

	if(VGPawn(Pawn) != none && VGPawn(Pawn).RiddenTurret != none)
		// ignore this if we're in a turret
		return;

	r = Rotation;

	r.pitch = r.pitch&65535;
	if(r.pitch >= 32768) // looking down
	{
		//don't ask don't tell
		r.pitch=max(r.pitch, thirdmaxpitch+thirdpitch);
	}
	else
	{
		//don't ask don't tell
		r.pitch=min(r.pitch, thirdminpitch + thirdpitch);
	}

	SetRotation(r);
}

exec function Toggle3rd()
{
	bUse3rdPersonCam = !bUse3rdPersonCam;
	bBehindView = !bBehindView;
}

function ResetView()
{
	bBehindView = bUse3rdPersonCam;
}

function Camera3rdPerson(float deltat)							 
{
	local vector v,pos;
	local rotator radjust, r;
	local float yawalpha;
	local vector hitpos, hitnorm;

	yawalpha = 1.0 - (1.0/(2.0**(deltat*thirdyawspeed)));

	SetViewTarget(Pawn);

	if(VGPawn(Pawn) != none && VGPawn(Pawn).RiddenTurret != none)
		radjust.pitch = 0;
	else
		radjust.pitch = thirdpitch;
	LastViewActor = Pawn;

	r = Rotation + radjust;

	r.yaw = InterpToDesired(lastcamyaw, Rotation.yaw,yawalpha);

	v = Vector(r);

	pos = LastViewActor.Location - v*thirddist + thirdfocusoffset;

	lastcamyaw = r.yaw;
	if(bLookBehind!=0)
	{
		r.yaw = (r.yaw + 32768)&65535;
		v = Vector(r);
		pos = LastViewActor.Location - v*thirddist+thirdfocusoffset;
	}


	if( Trace( hitpos, hitnorm, pos, (LastViewActor.Location + thirdfocusoffset), false ) != None )
	{
		pos = hitpos;
		//bump camera out from wall (so cam plane doesn't clip through)
		pos += (hitnorm*thirdwallhack);
	}
	

	LastCamLocation = pos;
	LastCamRotation = r;

}


event CameraTick(float DeltaTime)
{
	if(bNoCam) return;
	if(IsInState('PlayerInVehicle') || (bUseRiderCamera && bIsRidingVehicle) )
	{
//		log("doing cam in vehicle");
		CameraInVehicle(DeltaTime);
	}
	else if(IsInState('PlayerInTurret'))
	{
//		CameraTurret(DeltaTime);
		CameraInVehicle(DeltaTime);
	}
	else if ( Pawn != None && bUse3rdPersonCam && bBehindView )
	{
		Camera3rdPerson(DeltaTime);
	}

	UpdateRandomShake(DeltaTime);

}

function StartCamInterp()
{
	CamInterpOffset = Vect(0,0,0);
	CamInterpStartPos = SmoothPos;
	bCamInterping = True;
}

function EndCamInterp()
{
	bCamInterping = False;
	InterpCenterAlpha = 0.0;
}

exec function NoCam()
{
	bNoCam=!bNoCam;
}

exec function LookSteer()
{
	bLookSteer=!bLookSteer;
}

exec function LeaveCam()
{
	bLeaveCam=!bLeaveCam;
}

function int LimitYaw(int yaw, float deltat)
{
	local int turretyaw, clampyaw;
	local int LadderYawAdjust;
	local int BaseYaw;

	if(Pawn != none && Pawn.IsA('VGPawn') && VGPawn(Pawn).RiddenTurret != none) {
		LadderYawAdjust = 16000;
		turretyaw = VGPawn(Pawn).RiddenTurret.Rotation.yaw;
		clampyaw = ClampRotationValue(yaw, turretyaw - LadderYawAdjust, turretyaw + LadderYawAdjust);

		return clampyaw;
	}

	if(bIsRidingVehicle && bUseYawLimit)
	{
		BaseYaw = VGPawn(Pawn).RiddenVehicle.Rotation.Yaw;
		
		//log(
		clampyaw = ClampRotationValue(yaw, BaseYaw + CenterYaw - MaxYaw, BaseYaw + CenterYaw + MaxYaw);

		return clampyaw;
	}

	return Super.LimitYaw(yaw, deltat);
}


event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local PlayerTurret pTurret;

	if(bNoCam || bInterpolating)
	{
		Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		return;
	}
	
	if(!InValidVehicleState() && !IsInState('Dead') && !bUse3rdPersonCam)
	{
		Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		if(Pawn != none && Pawn.IsA('VGPawn') && VGPawn(Pawn).RiddenTurret != none) {
			pTurret = VGPawn(Pawn).RiddenTurret;
			CameraLocation.Z += 60;
			CameraLocation -= vector(pTurret.Rotation)*50;
		}
		LastCamLocation = CameraLocation;
		LastCamRotation = CameraRotation;
//		log("CamRot = "$CameraRotation);
		return;
	}

	if(LastViewActor != None)
		ViewActor = LastViewActor;
	else if(Pawn != None)
		ViewActor = Pawn;
	else ViewActor = self;

	CameraLocation = LastCamLocation + RandomShakePosition;
	//SetLocation(CameraLocation);
	
	CameraRotation = LastCamRotation + ShakeRot;
	//SetRotation(CameraRotation);

	if(Pawn != none && Pawn.IsA('VGPawn') && VGPawn(Pawn).RiddenTurret != none) {
		// bit of a hack... temp fix to bump up the position of the camera on the turret
		LastCamLocation = CameraLocation;
		LastCamRotation = CameraRotation;
		CameraLocation += VGPawn(Pawn).RiddenTurret.TurretCameraOffset;
	}
}


state GameEnded
{
    function BeginState()
    {
        DoLogoutCleanup();
        
        if( GetStateName() != 'GameEnded' )
        {
            // Ram us back!
            GotoState('GameEnded');
        }
        
        Super.BeginState();
    }

	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
	}
}

simulated native function VehicleSavedMove GetFreeVehicleMove();

//
// - prepare to replicate this client's desired movement to the server.
// - because of the way Karma objects are updated we only prepare to
//   replicate the move...it is finished off when we find out that
//   all Karma simulation is done
//
simulated native function ReplicateVehicleMove
(
	float	DeltaTime,
	float	NewThrottle,
	float	NewSteering,
	float	NewTurn
);

// function only executed on server
//
event ServerVehicleMove(
	float	TimeStamp,
	float	NewThrottle,
	float	NewSteering,
	float	NewTurn,
	bool	NewbHandBrake,
	bool	NewbTurboButton,
	bool	NewbPressedJump
)
{
	local float DeltaTime;

	flog( RJ, "ServerVehicleMove("$TimeStamp$") called" );
	if ( !InValidVehicleState() )
	{
		warn("RON: ServerVehicleMove called outside valid vehicle state");
		return;
	}
	if ( !IsDrivenVehicleValid() )
	{
		warn("RON: ServerVehicleMove called with invalid DrivenVehicle");
		return;
	}

	// If this move is outdated, discard it.
	if ( VPCurrentTimeStamp >= TimeStamp )
	{
		return;
	}

	DeltaTime = TimeStamp - VPCurrentTimeStamp;
	VPCurrentTimeStamp = TimeStamp;

	if ( Level.Pauser == None && DeltaTime > 0 )
	{
		DriveAutonomous(
			DeltaTime, NewThrottle, NewSteering, NewTurn,
			NewbHandBrake, NewbTurboButton, NewbPressedJump );
	}
}

// called on server from DrivenVehicle when it wants to take control of an autonomous vehicle
native function AdjustAutonomousVehicleState();

// called on client from DrivenVehicle when it receives an update from the server
native function bool ClientShouldAdjustVehiclePosition(
	float		TimeStamp,
	vector		NewLocation, 
	vector		NewVelocity
);

event PawnTornOff()
{
	Pawn = None;
	if ( !IsInState('GameEnded') && !IsInState('Dead') )
	{
		GotoState('Dead');
	}
}

final function DriveAutonomous
(   
	float	DeltaTime,
	float	NewThrottle,
	float	NewSteering,
	float	NewTurn,
	bool	NewbHandBrake,
	bool	NewbTurboButton,
	bool	NewbPressedJump
)
{
	flog( RJ, "DriveAutonomous("$DeltaTime$") called" );

	if ( NewbHandBrake )
	{
		bHandBrake = 1;
	}
	else
	{
		bHandBrake = 0;
	}

	if ( NewbTurboButton )
	{
		bTurboButton = 1;
	}
	else
	{
		bTurboButton = 0;
	}
	bPressedJump = NewbPressedJump;
	ProcessVehicleMove( DeltaTime, NewThrottle, NewSteering, NewTurn );
	if(CDrivenVehicle != none)
	{
		CDrivenVehicle.MoveVehicleAutonomous( DeltaTime );
	}
}

simulated native function ClientUpdateVehiclePosition();

function ExitVehicleWorker( string AltCmd ) 
{
	local VGPawn vp;

	vp=VGPawn(Pawn);

	if(vp.RiddenVehicle!=None)
	{
		bExitVehiclePlease=True;
//		log("*** ExitVehicleWorker ***");
	}
	else if(vp.RiddenTurret != none)
		bExitVehiclePlease = true;
	else
		ConsoleCommand( AltCmd );
}

exec function ExitVehicle()
{
//	log("--- ExitVehicle ---");
	ExitVehicleWorker("");
}

exec function ExitVehicleOr( string AltCmd )
{
	local VGVehicle tempVehicle;

//	log("@@@ ExitVehicle @@@");

	tempVehicle = CDrivenVehicle;

	ExitVehicleWorker(AltCmd);
	if(Role < ROLE_Authority) 
	{
		ConsoleCommand( AltCmd );
	}

	if(tempVehicle != none) {
		VehicleWeaponAttachment(tempVehicle.Weapon.ThirdPersonActor).SetTracking(false);
//		log("HAHA!");
	}
}


state PlayerInVehicle
{
	ignores ServerMove;

	function bool ValidVehicle()
	{
		local bool	 bValid;

		bValid = IsDrivenVehicleValid();
		if ( bValid )
		{
			if ( !bBeginControlCalled )
			{
				BeginControl();
			}
		}
		else
		{
			// - the driven vehicle isn't valid so restart and see what happens
			// - not sure why this is needed, I would think that unpossessing the
			//   vehicle and possessing the driver would kick us out of this state???
			//
			Restart();
		}
		return bValid;
	}
 
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)   
    {
    }

	function ExitVehicleWorker( string AltCmd ) 
	{
//		log("!!! ExitVehicleWorker !!! Driven = "$CDrivenVehicle);
		if(CDrivenVehicle != none)
			VehicleWeaponAttachment(CDrivenVehicle.Weapon.ThirdPersonActor).SetTracking(false);
	 	if ( Role < ROLE_Authority )
		{
			warn( "CHARLES: "$self$"::ExitVehicleWorker("$altcmd$") CALLED ON CLIENT!!!" );
		}
		
		CDrivenVehicle.bBrake=True;
		bExitVehiclePlease=True;
	}

	function PlayerMove( float DeltaTime )
	{        
		local float NewThrottle, NewSteering, NewTurn;
		local rotator r;

		if ( !ValidVehicle() ) return;

		if ( bUpdateVehiclePosition )
		{
			ClientUpdateVehiclePosition();
		}

		if(aThrottle!= 0)
		{
			//XJ Scale the throttle so it's still full even if analog stick is at 45 degrees
			NewThrottle = FClamp( (aThrottle * AxisScaleFactor) / 24000.0, -1.0, 1.0 );
		}
		else
		{
			NewThrottle = 0;
		}
			
		if ( bLookSteer )
		{
			// steer in the direction we are looking
			r = Normalize(Rotation - CDrivenVehicle.Rotation);
			NewSteering = r.Yaw;
			if ( NewSteering > 32768 )
			{
				NewSteering -= 65536;
			}
			else if ( NewSteering < -32768 )
			{
				NewSteering += 65536;
			}
			// if throttle is reversing, switch steering direction
			if ( NewThrottle < 0 )
			{
				NewSteering = -NewSteering;
			}
			// vehicles steer left with positive steering values, sw we need to switch sign
			//
			NewSteering = FClamp( -NewSteering / CDrivenVehicle.LookAngleForMaxSteer, -1, 1 );
		}
		else
		{
			if(aSteer != 0)
			{
				//XJ Scale the steering so it's still full even if analog stick is at 45 degrees
				NewSteering = FClamp( -(aSteer * AxisScaleFactor) / 24000.0, -1.0, 1.0 );
			}
			else
			{
				NewSteering = 0;
			}
		}

		if(aTurn != 0)
		{
			NewTurn = FClamp( aTurn / 24000.0, -1.0, 1.0 );
		}
		else
		{
			NewTurn = 0;
		}


		if ( Role < ROLE_Authority ) // then save this move and replicate it
		{
			ReplicateVehicleMove( DeltaTime, NewThrottle, NewSteering, NewTurn );
		}
		else
		{
			ProcessVehicleMove( DeltaTime, NewThrottle, NewSteering, NewTurn );
		}
		bPressedJump = False;

		ViewShake(DeltaTime);
	    ViewFlash(deltaTime);

		if(bNoCam || bLookSteer)
		{
			UpdateRotation(DeltaTime, 2);
		}
		else
		{
			//controllers rotation must be updated here, so that it gets replicated
			//log("PC -Client- VehiclePlayer:ProcessVehicleMove"@Pawn.Rotation@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			SetRotation(Pawn.Rotation);
		}
	}

	function UpdateRotation(float DeltaTime, float MaxPitch)
	{
		local rotator r;

		Super.UpdateRotation( DeltaTime, MaxPitch );
		if ( bLookSteer )
		{
			r = Normalize( Rotation );
			r.Pitch = Clamp( r.Pitch, CDrivenVehicle.LookSteerMinPitch, CDrivenVehicle.LookSteerMaxPitch );
			SetRotation( r );
		}
	}

	event ProcessVehicleMove(
		float	DeltaTime,
		float	NewThrottle,
		float	NewSteering,
		float	NewTurn
	)
	{
		if ( !ValidVehicle() ) return;

		if(bExitingByAnimation)
		{
			CDrivenVehicle.bHandBrake=true;
			CDrivenVehicle.Throttle=0;
		}
		else if( bExitVehiclePlease && Role == ROLE_Authority && VSize(CDrivenVehicle.Velocity) < 400.0 && !CDrivenVehicle.Driver.bPlayingEnterExitAnim)
        {
			bExitVehiclePlease = False;
			
			//check if player can get out with animation
			
			if(CDrivenVehicle.CheckExitSpot(false))
			{
				bExitingByAnimation=true;
			
			
				SetMultiTimer(ExitVehicleTimerSlot, 1.0, false);
				CDrivenVehicle.Driver.SetAnimAction(CDrivenVehicle.DriverExitAnim);
				CDrivenVehicle.Driver.bPlayingEnterExitAnim = true;
			}
			else
			{
				if(CDrivenVehicle != none)	
					CDrivenVehicle.DriverExits();
			}

        }
		else
		{	
			if(CDrivenVehicle.IsInState('DelayingDeath'))
				return;
			
			CDrivenVehicle.bHandBrake = bHandBrake != 0;
			CDrivenVehicle.bTurboButton = bTurboButton != 0;
			
			CDrivenVehicle.Throttle = NewThrottle;
			CDrivenVehicle.Steering = NewSteering;
			CDrivenVehicle.Turn = NewTurn;
			
			if(!bNoCam && !bLookSteer)
			{
				//log("PC -Server- VehiclePlayer:ProcessVehicleMove"@Pawn.Rotation@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
				SetRotation(Pawn.Rotation);
			}
		}
	}

	exec function ResetVehicle()
	{
		if ( !ValidVehicle() ) return;

		CDrivenVehicle.StartFlip();
	}
	
	exec function HideVehicle()
	{
		local int i;

		if ( !ValidVehicle() ) return;

		CDrivenVehicle.bHidden = !CDrivenVehicle.bHidden;
		for ( i = CDrivenVehicle.VehicleActors.Length - 1; i >= 0; i-- )
		{
			CDrivenVehicle.VehicleActors[i].bHidden = !CDrivenVehicle.VehicleActors[i].bHidden;
		}
	}

	exec function EditVehicle()
	{
		if ( !ValidVehicle() ) return;

		ConsoleCommand( "editactor CLASS="$CDrivenVehicle.Class$" "$CDrivenVehicle.Name );
	}

	exec function SaveVehicle()
	{
		if ( !ValidVehicle() ) return;

		ConsoleCommand( "saveobjprop relativeto=1 file="$CDrivenVehicle.Class$".uc obj="$CDrivenVehicle.Name );
	}

	function BeginControl()
	{
		glog( RJ2, "PlayerInVehicle::BeginControl called - CDrivenVehicle = "$CDrivenVehicle );

		CleanOutSavedVehicleMoves();

		bBeginControlCalled = True;	// prevent multiple calls

		ClientEndZoom();
		bBehindView = True;
		ResetCameraHacks();
		//lastcamyaw = CDrivenVehicle.Rotation.yaw;

		lastcamyaw = LastCamRotation.Yaw;
		StartCamInterp();

		SetFOVAngle(VehicleFOV);

		assert( CDrivenVehicle != None );
		CDrivenVehicle.BeginControlOfVehicle( self );
		LastDrivenVehicle = CDrivenVehicle;
	}

	function BeginState()
	{
		glog( RJ2, ""$GetStateName()$"::BeginState" );

		if ( Role == ROLE_Authority )
		{
			CDrivenVehicle = VGVehicle(Pawn);
		}
		if ( CDrivenVehicle != None )
		{
			if ( !bBeginControlCalled )
			{
				BeginControl();
			}
		}
	}

	function EndControl()
	{
		
		if ( CDrivenVehicle != None && Level.NetMode==NM_Standalone)
		{
			SavedVehicleRotation.yaw=CDrivenVehicle.Rotation.yaw;
			bUpdateDriverRotation=True;
		}
		if ( bBeginControlCalled )
		{
			glog( RJ2, "PlayerInVehicle::EndControl called - CDrivenVehicle="$CDrivenVehicle$", LastDrivenVehicle="$LastDrivenVehicle );
			CleanOutSavedVehicleMoves();
			LastDrivenVehicle = None;
			bBeginControlCalled = False;
			ClientEndZoom();			//fixes wrong FOV when getting out of a car in a net game
			RestoreFOV();
			//XJ vehicle cross hair
			myHUD.bVehicleCrosshairShow = False;
			//myHUD.bCrosshairShow = True;
		}
	}

	function EndState()
	{
		glog( RJ2, ""$GetStateName()$"::EndState" );
		if(!bDestroyingCtrl)
		{
			EndControl();
		}
	}
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
	//log("XJ: LongClientAdjustPosition Pawn "$Pawn$" State "$GetStateName()$" loc "$NewLocX@NewLocY@NewLocZ);
	if (!Pawn.IsA('LevelTurret'))
	{
		Super.LongClientAdjustPosition
			(
				TimeStamp, 
				newState, 
				newPhysics,
				NewLocX, 
				NewLocY, 
				NewLocZ, 
				NewVelX, 
				NewVelY, 
				NewVelZ,
				NewBase,
				NewFloorX,
				NewFloorY,
				NewFloorZ
			);
	}
}

state PlayerInTurret
{
	function bool ValidVehicle()
	{
		local bool	 bValid;

		bValid = IsDrivenVehicleValid();
		if ( bValid )
		{
			if ( !bBeginControlCalled )
			{
				BeginControl();
			}
		}
		else
		{
			// - the driven vehicle isn't valid so restart and see what happens
			// - not sure why this is needed, I would think that unpossessing the
			//   vehicle and possessing the driver would kick us out of this state???
			//
			Restart();
		}
		return bValid;
	}

	function UpdateRotation(float DeltaTime, float MaxPitch)
	{
 		local rotator newRot;//, GunRot, BaseRot;

		Super.UpdateRotation(DeltaTime, MaxPitch);

		newRot=Rotation;
		//BaseRot=rot(0,0,0);
		//GunRot=rot(0,0,0);

		//BaseRot.Yaw=Clamp(Rotation.Yaw, LevelTurret(Pawn).AbsMinYaw, LevelTurret(Pawn).AbsMaxYaw);
		newRot.Yaw=Clamp(Rotation.Yaw, LevelTurret(Pawn).AbsMinYaw, LevelTurret(Pawn).AbsMaxYaw);
		//if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		//	Pawn.FaceRotation(BaseRot, DeltaTime);

		PitchUpLimit = LevelTurret(Pawn).AbsMaxPitch;
		PitchDownLimit = LevelTurret(Pawn).AbsMinPitch;
		//GunRot.Pitch = LimitPitch(Rotation.Pitch);
		newRot.Pitch = LimitPitch(Rotation.Pitch, DeltaTime);
		PitchUpLimit = default.PitchUpLimit;
		PitchDownLimit = default.PitchDownLimit;

		//newRot.Yaw = BaseRot.Yaw;
		//newRot.Pitch = GunRot.Pitch;
		if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
			Pawn.FaceRotation(newRot, DeltaTime);
		SetRotation(newRot);

		return;
	}

	function ExitVehicleWorker( string AltCmd ) 
	{
//		log("### ExitVehicleWorker ###");
	 	if ( Role < ROLE_Authority )
		{
			warn( "CHARLES: "$self$"::ExitVehicleWorker("$altcmd$") CALLED ON CLIENT!!!" );
		}

		bExitVehiclePlease=True;
	}

	function PlayerMove( float DeltaTime )
	{
		local rotator oldRotation;
		local vector NewAccel;

		if ( !ValidVehicle() ) return;

		NewAccel = vect(0,0,0);
        oldRotation = Rotation;
        UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		ViewShake(DeltaTime);
		bPressedJump = false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( !ValidVehicle() ) return;

		if( bExitVehiclePlease && Role == ROLE_Authority )
        {
//			log("Calling DriverExits");
			bExitVehiclePlease = False;
			if(CDrivenVehicle != none)
				CDrivenVehicle.DriverExits();
        }
		//Super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	}

	function BeginControl()
	{
		glog( RJ2, "PlayerInVehicle::BeginControl called - CDrivenVehicle = "$CDrivenVehicle );

		CleanOutSavedMoves();

		bBeginControlCalled = True;	// prevent multiple calls

		ClientEndZoom();
		bBehindView = True;
		ResetCameraHacks();
		lastcamyaw = CDrivenVehicle.Rotation.yaw;
		SetFOVAngle(VehicleFOV);

		assert( CDrivenVehicle != None );
		CDrivenVehicle.BeginControlOfVehicle( self );
		LastDrivenVehicle = CDrivenVehicle;
	}

	function BeginState()
	{
		glog( RJ2, ""$GetStateName()$"::BeginState" );

		if ( Role == ROLE_Authority )
		{
			CDrivenVehicle = VGVehicle(Pawn);
		}
		if ( CDrivenVehicle != None )
		{
			if ( !bBeginControlCalled )
			{
				BeginControl();
			}
		}
		//Super.BeginState();
	}

	function EndControl()
	{
		
		if ( CDrivenVehicle != None && Level.NetMode==NM_Standalone)
		{
			SavedVehicleRotation.yaw=CDrivenVehicle.Rotation.yaw;
			bUpdateDriverRotation=True;
		}
		if ( bBeginControlCalled )
		{
			glog( RJ2, "PlayerInVehicle::EndControl called - CDrivenVehicle="$CDrivenVehicle$", LastDrivenVehicle="$LastDrivenVehicle );
			CleanOutSavedMoves();
			ClientEndZoom();
			RestoreFOV();
			LastDrivenVehicle = None;
			bBeginControlCalled = False;
		}
	}

	function EndState()
	{
		glog( RJ2, ""$GetStateName()$"::EndState" );
		EndControl();
		//Super.EndState();
	}
}

function Possess(Pawn aPawn)
{
	if(bUpdateDriverRotation)
	{
		if(Level.NetMode==NM_Standalone)
			aPawn.SetRotation(SavedVehicleRotation);

		bUpdateDriverRotation=False;
	}

	Super.Possess(aPawn);
}

function UnPossess(optional bool bTemporary)
{
	//zero out the view flash.
	DesiredFlashScale = 1;
	DesiredFlashFog = Vect(0,0,0);
	FlashScale = Vect(1,1,1);
	FlashFog = Vect(0,0,0);

	Super.UnPossess(bTemporary);
	if ( CDrivenVehicle != None )
	{
		bBehindView = bUse3rdPersonCam;
		CDrivenVehicle.EndControlOfVehicle( self );
		CDrivenVehicle = None;
		RestoreFOV();
	}
}

exec function JoyButton( int b )
{
	log( "Joy Button "$b$" pressed" );
}

// used from ini file
exec function Nop()
{
}

exec function IfInVehicle( string s )
{
	local string	 cmd;
	local int		 i;
	
	if(Pawn == None)
	{
	    return;
	}

	i = InStr( s, ";" );
	if ( InValidVehicleState() ||
         Pawn.Weapon != None && Pawn.Weapon.IsA('VehicleWeapon') )
	{
		if ( i != -1 )
		{
			cmd = Left( s, i );
		}
		else
		{
			cmd = s;
		}
	}
	else
	{
		if ( i != -1 )
		{
			cmd = Mid( s, i+1 );
		}
	}

	if ( Len( cmd ) > 0 )
	{
		ConsoleCommand( cmd );
	}
}

exec function NextMap()
{
    SwitchToNextMap();
}

exec function SwitchToNextMap()
{
    if( Level.Game != None )
    {
        Level.Game.RestartGame();
    }
}

///////////
// Xavier: 
// The Ammunition variable will have to be changed to a VehicleWeapon.
// the AimError should also be a float, and will be used for the "bestAim"
// should probably have a flag on weapons, since we may not want auto
// aiming for some.
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local vector	fireDir, aimSpot;
	local actor		bestTarget;
	local float		bestDist, bestAim;

	//if not using auto aim, everything will use it for now.
	//if ( AimingHelp == 0 )
	//	return Rotation;

	fireDir = vector(Rotation); //should be changed to the the direction the weapon is facing
	bestAim = 0.9935;			//will probably be replaced with the aimerror

	// need to change "FiredAmmunition" to a weapon later.
	//if ( FiredAmmunition.bInstantHit )
	//{
//RJ		bestTarget = PickTarget(bestAim, bestDist, fireDir, projStart);
		bestTarget = PickTarget(bestAim, bestDist, fireDir, projStart, FiredAmmunition.MaxRange);
		if(bestTarget == none)
		{
			return Rotation;
		}
		AimSpot = bestTarget.Location;
		FiredAmmunition.WarnTarget(bestTarget,Pawn,(aimSpot - projStart) );
		return rotator(aimSpot - projStart);
	//}
	/*
	else 
	{
		bestTarget = PickTarget(bestAim, bestDist, fireDir, projStart);
		if(bestTarget == none)
		{
			return Rotation;
		}
		projSpeed = FiredAmmunition.ProjectileClass.default.speed;
		bestDist = vsize(bestTarget.Location + bestTarget.Velocity * FMin(2, 0.02 + bestDist/projSpeed) - projStart); 
		fireDir = bestTarget.Location + bestTarget.Velocity * FMin(2, 0.02 + bestDist/projSpeed) - projStart;
		aimSpot = projStart + bestDist * Normal(fireDir);
		return rotator(aimSpot - projStart);
	}
	*/
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------
// Added by Charles
//----------------------------------------------------------------------------------------------------------------------------------------------------------

function string GCCmd( string cmd )
{
	return ConsoleCommand( "GRAPH "$cmd );
}

function AddStats( string StatsToAdd, string Extra, bool Filter, OUT string FilterString )
{
	local string stats, token, statname, args;
	local int i;

	// add everything and filter out stuff we don't want to see
	// - only need to add once but this isn't time critical
	//
	stats=StatsToAdd;
	while ( Len( stats ) > 0 )
	{
		i = InStr( stats, ";" );
		if ( i != -1 )
		{
			token = Left( stats, i );
			stats = Mid( stats, i + 1 );
		}
		else
		{
			token = stats;
			stats="";
		}
		
		args=Extra;

		// check for name
		//
		i = InStr( token, "=" );
		if ( i != -1 )
		{
			statname = Left( token, i );
			args=args$" NAME=\""$statname$"\"";
			token = Mid( token, i + 1 );
		}
		else
		{
			statname="";
		}
		GCCmd( "ADDSTAT=\""$token$"\" "$args );
		if ( Filter )
		{
			if ( statname == "" )
			{
				statname=token;
			}
			FilterString = FilterString$" "$statname;
		}
	}
}

exec function gstat( string type )
{
	local int i;

	for ( i = 0; i < Graphs.Length; i++ )
	{
		if ( Caps( type ) == "NONE" )
		{
			ShowGraph( 0 );
		}
		else if ( Caps( type ) == Graphs[i].GraphName )
		{
			ShowGraph( i + 1 );
			break;
		}
	}
}

exec function ShowGraph( int g )
{
	local bool	 IsGraphOn;
	local int	 i;
	local string filter, cmds, cmd;

	IsGraphOn = int(GCCmd( "ISSHOW" )) != 0;

	GraphType = g;
	if ( GraphType < 0 || GraphType > Graphs.Length )
	{
		GraphType = 0;
	}

	if ( GraphType == 0 )
	{
		if ( IsGraphOn )
		{
			GCCmd("SHOW");
		}
	}
	else
	{
		if ( !IsGraphOn )
		{
			if ( int(GCCmd( "ISLOCKSCALE" )) == 0 )
			{
				GCCmd( "LOCKSCALE" );
			}
			if ( int(GCCmd( "ISAUTOCOLOR" )) == 0 )
			{
				GCCmd( "AUTOCOLOR" );
			}
			if ( int(GCCmd( "ISKEYOVERGRAPH" )) == 0 )
			{
				GCCmd( "KEYOVERGRAPH" );
			}
			GCCmd( "SHOW" );
			GCCmd( "XPOS=25" );
			GCCmd( "XSIZE=-50" );
			GCCmd( "YPOS=-25" );
			GCCmd( "YSIZE=-75" );
			GCCmd( "ZEROY=0.1" );
			GCCmd( "ALPHA=0" );
			GCCmd( "XRANGE=150" );
			GCCmd( "KEYSORTINTERVAL=0.5" );
			GCCmd( "KEYUPDATEINTERVAL=0.1" );
		}

		for ( i = 0; i < Graphs.Length; i++ )
		{
			AddStats( Graphs[i].GraphStats, Graphs[i].ExtraArgs, i == (GraphType - 1), filter );
		}
		GCCmd( "FILTER=\""$filter$"\"" );

		GCCmd( "CLEARTICKS" );

		// do any extra graph commands
		//
		cmds=Graphs[GraphType-1].ExtraCmds;
		while ( Len( cmds ) > 0 )
		{
			i = InStr( cmds, ";" );
			if ( i != -1 )
			{
				cmd = Left( cmds, i );
				cmds = Mid( cmds, i + 1 );
			}
			else
			{
				cmd = cmds;
				cmds="";
			}

			GCCmd( cmd );
		}
	}
}

exec function CycleGraph()
{
	local int g;

	g = GraphType + 1;
	ShowGraph( g );
}

function Timer()
{
	GCCmd( "RESCALE" );
}

simulated function AddGraphInfo( string GraphStats, string ExtraArgs, string ExtraCmds, optional string GraphName )
{
	local int	i;

	i = Graphs.Length;
	Graphs.Length = i + 1;
	Graphs[i].GraphStats = GraphStats;
	Graphs[i].ExtraArgs = ExtraArgs;
	Graphs[i].ExtraCmds = ExtraCmds;
	Graphs[i].GraphName = GraphName;
}

simulated function InitGraphs()
{
	AddGraphInfo(
		"FrameTime=Frame Frame,Frame Stats_Render,-;FPS=1000,FrameTime,/;",
		"SMOOTH=20",
		"ADDREPEATTICK=5",
		"FPS"
	);
	AddGraphInfo(
		"Game Script;Game Actor;Game ScriptTick;Game Path;Game See;Game Spawning;Game Audio;Game CleanupDestroyed;Game Net;"$
		"Game Particle;Game Canvas;Game Move;Game Physics;Game MLChecks;Game MPChaecks;Game RenderData;Game HUD_PostRender;"$
		"Game CameraTick;Game PlayerTick;Game AI;Game xParticle",
		"MINDRAWVALUE=0.1",
		"ADDREPEATTICK=5;ADDTICK=33.3 RED=255 GREEN=0 BLUE=0;ADDTICK=16.7 RED=255 GREEN=255 BLUE=0",
		"GAME"
	);
	AddGraphInfo(
		"Audio PlaySound;Audio Occlusion;Audio Update;Audio XACT",
		"MINDRAWVALUE=0.0",
		"ADDREPEATTICK=0.5",
		"AUDIO"
	);
	AddGraphInfo(
		"Total Render=Frame Render,Frame Stats_Render,-;StaticMesh BatchedRender;StaticMesh UnbatchedRender;Terrain Render;DecoLayer Render;Projector Render;"$
		"Stencil Render;BSP Render;Game Audio;Hardware Present;Hardware Clear;Hardware Lock;"$
		"Hardware Unlock;Visibility Setup;Visibility Traverse;ParticleRender=Particle Render,xParticle xRender,+;Mesh Skel;Game HUD_PostRender;"$
		"CoronaRender=Corona Render,Corona Visibility,+;Fluid Render;"$
		"Unaccounted Render=Total Render,StaticMesh BatchedRender,StaticMesh UnbatchedRender,"$
		"Terrain Render,DecoLayer Render,Stencil Render,BSP Render,Game Audio,Hardware Present,"$
		"Hardware Clear,Hardware Lock,Hardware Unlock,Visibility Setup,Visibility Traverse,"$
		"ParticleRender,Mesh Skel,Game HUD_PostRender,CoronaRender,Fluid Render,+,+,+,+,+,+,+,+,+,+,+,+,+,+,+,+,+,-",
		"SMOOTH=10 MINDRAWVALUE=0.25",
		"ADDREPEATTICK=5;ADDTICK=33.3 RED=255 GREEN=0 BLUE=0;ADDTICK=16.7 RED=255 GREEN=255 BLUE=0",
		"RENDER"
	);
	AddGraphInfo(
		"_Audio=Game Audio;"$
		"_Clear=Hardware Clear,Game Audio,+;"$
		"_Stencil=Stencil Render,_Clear,+;"$
		"_Present=Hardware Present,_Stencil,+;"$
		"_Mesh=Mesh Skel,_Present,+;"$
		"_Fluid=Fluid Render,_Mesh,+;"$
		"_Vis Setup=Visibility Setup,_Fluid,+;"$
		"_Vis Traverse=Visibility Traverse,_Vis Setup,+;"$
		"_Projector=Projector Render,_Vis Traverse,+;"$
		"_Particle=Particle Render,xParticle xRender,_Projector,+,+;"$
		"_HUD=Game HUD_PostRender,_Particle,+;"$
		"_BSP=BSP Render,_HUD,+;"$
		"_Corona=Corona Render,_BSP,+;"$
		"_Terrain=Terrain Render,_Corona,+;"$
		"_DecoLayer=DecoLayer Render,_Terrain,+;"$
		"_StaticMesh=StaticMesh BatchedRender,StaticMesh UnbatchedRender,_DecoLayer,+,+;"$
		"Total Render=Frame Render,Frame Stats_Render,-;",
		"SMOOTH=10 MINDRAWVALUE=0.25",
		"ADDREPEATTICK=5;ADDTICK=33.3 RED=255 GREEN=0 BLUE=0;ADDTICK=16.7 RED=255 GREEN=255 BLUE=0"
	);
	AddGraphInfo(
		"Karma Collision;Karma Dynamics;Karma CntctGen;Karma TrilistGen;Karma RagdollTrilist;Karma physKarma;"$
		"Total Karma=Karma Dynamics,Karma Collision,Karma RagdollTrilist,Karma physKarma,Karma physKarma_Constraint,Karma physKRgdol,+,+,+,+,+;"$
		"Karma physKarma_Constraint;Karma physKRgdol;K Timestep=Karma Timestep,10,/;"$
		"K Total_Rows=Karma TotMatrixRows,10,/;K Max_Rows=Karma MaxMatrixRows,10,/;",
		"SMOOTH=10 MINDRAWVALUE=0.0",
		"ADDREPEATTICK=5;ADDTICK=33.3 RED=255 GREEN=0 BLUE=0;ADDTICK=16.7 RED=255 GREEN=255 BLUE=0",
		"KARMA"
	);
	AddGraphInfo(
		"Total Havok=Havok Step,Havok RBActor,Havok SkelActor,Havok Keyframe,Havok CharProxy,Havok SaveXforms,Havok Debug,+,+,+,+,+,+;"$
		"Havok Step;Havok RBActor;Havok SkelActor;Havok Keyframe;Havok CharProxy;Havok SaveXforms;Havok Debug;"$
		"Frame Frame;",
		"MINDRAWVALUE=0.0",
		"ADDREPEATTICK=5;ADDTICK=33.3 RED=255 GREEN=0 BLUE=0;ADDTICK=16.7 RED=255 GREEN=255 BLUE=0",
		"HAVOK"
		);
	AddGraphInfo(
		"Net InBytes;Net OutBytes;",
		"SMOOTH=0 MINDRAWVALUE=0",
		"ADDREPEATTICK=1000",
		"NET"
	);
	AddGraphInfo(
		"XBox Percent_GPU;XBox Percent_GPU_Swap_Stall;XBox Percent_GPU_Backend;XBox Percent_GPU_Frontend;XBox Percent_CPU;XBox Frames;"$
		"Frame Frame;Unreal Frames=1000,Frame Frame,/;",
		"SMOOTH=0 MINDRAWVALUE=0",
		"ADDREPEATTICK=10",
		"XBOX"
		);
}

function CleanOutSavedVehicleMoves()
{
	local VehicleSavedMove Next;

	// clean out saved moves
	while ( SavedVehicleMoves != None )
	{
		Next = SavedVehicleMoves.NextMove;
		SavedVehicleMoves.Destroy();
		SavedVehicleMoves = Next;
	}
	if ( PendingVehicleMove != None )
	{
		PendingVehicleMove.Destroy();
		PendingVehicleMove = None;
	}
}

event PreNetDestroy()
{
	DoLogoutCleanup();
}

//called from PreNetDestroy() only on server. 
function DoLogoutCleanup()
{
//	local VGVehicle v;
	local VGPawn p;
	if(Pawn == None) 
	{
		return;
	}

	if(Pawn.IsA('VGVehicle')) //then we are currently a driver. 
	{
		CDrivenVehicle.DriverExits(); //this will let go of the vehicle and make the pawn which is destroyed on logout in to the vgpawn
	}
	else //pawn is a VGPawn
	{
		p = VGPawn(Pawn);

		if(p.RiddenVehicle != None) //riding a vehicle, get out
		{
			p.RiddenVehicle.EndRide(p);
		}

		if(p.RiddenTurret != None )
		{
			p.RiddenTurret.EndRide(p);
		}
	}	
}

simulated event Destroyed()
{
	local VehicleSavedMove Next;

	while ( FreeVehicleMoves != None )
	{
		Next = FreeVehicleMoves.NextMove;
		FreeVehicleMoves.Destroy();
		FreeVehicleMoves = Next;
	}
	while ( SavedVehicleMoves != None )
	{
		Next = SavedVehicleMoves.NextMove;
		SavedVehicleMoves.Destroy();
		SavedVehicleMoves = Next;
	}

	Super.Destroyed();
}

simulated function PrepareForMatinee()
{
	Super.PrepareForMatinee();
	
	StoreCameraState();

	bBehindView=false;
	bUse3rdPersonCam=false;
	SetViewTarget(self);
}


simulated function RecoverFromMatinee()
{
	Super.RecoverFromMatinee();

	RestoreCameraState();

	// cmr TODO camera reinitialization to center

    // jjs - ch5 teleport into nearest vehicle
    if(bStartInVehicle)
    {
        VGPawn(Pawn).SetCollision(false, false, false);
        VGPawn(Pawn).EnterNearestVehicle();
        bStartInVehicle = false;
    }
}

// for split-screen buddy, load profile here
simulated function bool SplitLoadLastProfile()
{
    local string lastProfileName;
    local string profileState;
    
    assert(IsSharingScreen());
    
    // grab the name of the last one
    lastProfileName = ConsoleCommand("SPLIT_LAST_PROFILE "$Player.GamePadIndex);
    if( lastProfileName == "" )
    {
        // no prev profile
        return(false);
    }

    // check that it is valid and unused
    profileState = ConsoleCommand("LOADSAVE GET_STATE NAME="$lastProfileName);
    if(profileState == "LOADED")
    {
        // this is the primary player - already loaded
        return(true);
    }
    else if(profileState != "VALID")
    {
        // not avail (missing/corrupt/inuse)
        return(false);
    }
    
    // load it
    if(bool(ConsoleCommand("LOADSAVE LOAD NAME=" $ lastProfileName @ "GAMEPADINDEX=" $ Player.GamePadIndex)))
    {
        // success
        return(true);
    }
    
    // failed for unknown reason
    warn("Failed to load profile" @ lastProfileName);
    assert(false);
    return(false);
}

defaultproperties
{
     thirdpitch=-4000
     thirdminpitch=12000
     thirdmaxpitch=58000
     VehicleFOV=75.000000
     thirdyawspeed=40.000000
     thirddist=550.000000
     thirdwallhack=4.000000
     TargetUpdateTime=0.150000
     FlashDuration=0.200000
     FlashFadeInTime=5.000000
     PlayerInVehicleStateName="PlayerInVehicle"
     PlayerInTurretStateName="PlayerInTurret"
     thirdfocusoffset=(Z=80.000000)
     bUseSmoothRot=True
     bUseSmoothPos=True
     CheatClass=Class'VehicleGame.VGCheatManager'
}
