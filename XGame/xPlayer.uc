class xPlayer extends UnrealPlayer
	native
    DependsOn(xUtil);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

#exec OBJ LOAD File="MenuSounds.uax"
// attract mode
var actor bbb;
var AttractCamera camlist[20];
var int numcams, curcam;
var Pawn attracttarget;
var float camtime, targettime, gibwatchtime;
var bool autozoom;
var Vector focuspoint;

var bool bShowMemStats;

// combos
var transient int InputHistory[16];
var transient float LastKeyTime;
var transient int OldKey;

struct native ComboExecution
{
	var string ConsoleCommand;		
	var string ConsoleCommandMsg;	// message to display if ConsoleCommand is executed 
    var string Sequence;
    var int keys[16];
};

var() array<ComboExecution> ComboList;

var input byte
	bNext, bPrev, bBomb;

var() Actor LockedTarget; // for special targeting info to be used for HUD drawing shit.

// amb ---
var() xUtil.PlayerRecord PawnSetupRecord;

var() CoopInfo	mCoopInfo;
var() bool      bCoopPlayerReady;

var() float NextStatRequestTime;
var() float MinStatRequestCount;

var() float MaxHOffset, MaxVOffset, HitOffsetRatio, PickTargetAim;
// --- amb

var() int MultiKillLevel;
var() float LastKillTime;

var float LastTauntAnimTime;
var float LastVoiceTime;

var PlayerReplicationInfo LastRequestPRI;
var int WeaponStatNum;
var int PlayerStatCount;

// RJ@BB ---
// DONT'T USE THESE...THEY ARE ONLY HERE SO THAT THE CLASSES GET PRELOADED
// xUtil.cpp creates these internally...unfortunately unless they are defined
// somewhere in UnrealScript the class descriptions don't get properly preloaded
// which means that their children won't be properly referenced during garbage
// collection.
var private const transient CacheMaps plCacheMaps;
var private const transient CachePlayers plCachePlayers;
var private const transient CacheGameTypes plCacheGameTypes;
var private const transient CacheWeapons plCacheWeapons;
var private const transient CacheMutators plCacheMutators;
// --- RJ@BB


// cmr -- for SP, to short circuit player record stuff
var bool bIgnorePlayerRecord;


replication
{
	// client to server
	reliable if ( Role < ROLE_Authority )
		ServerSelectCoopCharacter, ServerCoopReady; //amb
    reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		LockedTarget;
    // amb ---
    reliable if ( Role < ROLE_Authority )
        RequestPlayerStats;
    reliable if ( Role == ROLE_Authority )
        SendPlayerStats, SendWeaponStats;
    // --- amb
}

function Reset()
{
    Super.Reset();
    LockedTarget = None;
}

event InitInputSystem() // if client, ensure player mem limit will allow me locally
{
    local xUtil.PlayerRecord rec;
    local xUtil.PlayerRecord recLoaded;

    local string CharName;

    Super.InitInputSystem();

    if( Level.NetMode != NM_Client )
        return;

    CharName = class'GameInfo'.static.ParseOption( Level.GetLocalURL(), "Character" );

    // get locally preferred character and load it 
    rec = class'xUtil'.static.FindPlayerRecord(CharName);
    recLoaded = class'xUtil'.static.CheckLoadLimits(Level, rec.RecordIndex);
    class'xUtil'.static.LoadPlayerRecordResources(recLoaded.RecordIndex, Level.NetMode != NM_Standalone || !Level.Game.bSinglePlayer);
    log("Preloaded NM_Client character: "$CharName);
}

// Hacky way to get this stat...

function LogMultiKills()
{

	if (Level.NetMode==NM_DedicatedServer)
	{
		if (Level.TimeSeconds - LastKillTime < 3)
		{
			MultiKillLevel++;
			if (Level.Game.GameStats!=None) 
				Level.Game.GameStats.SpecialEvent(PlayerReplicationInfo,"Multikill_"$MultiKillLevel);
		}
		else
			MultiKillLevel=0;
	}
	
	LastKillTime = Level.TimeSeconds;
	
}	
	

function StopFiring()
{
}

simulated function PlayBeepSound(optional Sound Snd)
{
    if( Snd == None )
    {
        Snd = sound'MenuSounds.selectJ';
    }
    ViewTarget.PlaySound(Snd, SLOT_Interface, 1.0,,,,false);
}

simulated function float RateWeapon(Weapon w)
{
    local xPawn xp;
    if (Pawn != None)
        xp = xPawn(Pawn);
    if (xp != None && xp.bUsingSpeciesStats && xp.WepAffinity.WepClass == w.class)
        return 100;
    else
        return w.Priority;
}

exec function SwitchToPriorityGroup(byte p)
{
    local Weapon w;
    local byte priority; 

    if (Pawn == None || Pawn.Weapon == None)
        return;

    w = Pawn.Weapon;

    do
    {
        w = Pawn.Inventory.NextWeapon(None, w);
        priority = w.Priority;
    }
    until (w == Pawn.Weapon || priority == p);

    if (w != None && w != Pawn.Weapon)
    {
        Pawn.PendingWeapon = w;
        if (!Pawn.Weapon.PutDown())
            Pawn.PendingWeapon = None;
    }
} 
// --- amb

exec function Splat()
{
    local Pawn p;
    local float closest;
    local Pawn bestP;

    closest = 999999.9;

    foreach AllActors( class'Pawn', p )
    {
        if( p.Controller != self )
        {
            if( VSize( p.Location - Pawn.Location ) < closest )
            {
                closest = VSize( p.Location - Pawn.Location );
                bestP = p;
            }
        }
    }

    bestP.SetPhysics(PHYS_Falling);
    bestP.TakeDamage( 200, Pawn, bestP.Location + vect(0,0,-40), vect(0,0,100000), class'Burned' );
}

exec function BigSplat()
{
    local Pawn p;
    local Vector m;


    foreach AllActors( class'Pawn', p )
    {
        if( p.Controller != self )
        {
            p.SetPhysics(PHYS_Falling);
            m.X = FRand()*100000.0 - 50000.0;
            m.Y = FRand()*100000.0 - 50000.0;
            m.Z = 100000.0;
            p.TakeDamage( 200, Pawn, p.Location, m, class'Burned' );
        }
    }    
}

native function int GetComboKeyId( string keyletter );
native function HandleCombos();

simulated function AddComboCommand( string Sequence, string ComboCommand, optional string ComboMsg )
{
	local int l;

	l = ComboList.Length;
	ComboList.Length = l + 1;
	ComboList[l].Sequence = Sequence;
	ComboList[l].ConsoleCommand = ComboCommand;
	ComboList[l].ConsoleCommandMsg = ComboMsg;
	// log( "RJ: add combo command "$ComboCommand$" using seq ("$Sequence$")" );
}

simulated function ProcessCombos()
{
    local int c, s, k, keyid;
    local string keyletter;

    for (c = 0; c < ComboList.Length; c++)
    {
        if (ComboList[c].ConsoleCommand == "")
            break;

        s = Len(ComboList[c].Sequence) - 1;
        k = 0;

        while (s >= 0 && k < ArrayCount(ComboList[c].keys))
        {
            ComboList[c].keys[k] = 0;

            while (s >= 0)
            {
                keyletter = Mid(ComboList[c].Sequence, s, 1);
                if (keyletter == " ") break;
				keyid = GetComboKeyId(keyletter);
				if ( keyid == 0 )
				{
					Log("warning: invalid key '"$keyletter$"' in combo "$c);
				}
                ComboList[c].keys[k] = ComboList[c].keys[k] | keyid;

                s--;
            }

            s--;
            k++;
        }
		
		// log( "RJ: processed combo ("$ComboList[c].ConsoleCommand$") with "$k$" key sequence" );
        ComboList[c].keys[k] = 0;
    }
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

	ProcessCombos();
    FillCameraList();
    LastKillTime = -1.0;
}
event PlayerTick( float DeltaTime )
{
	Super.PlayerTick(DeltaTime);

	HandleCombos();
}
simulated event DoComboCommand( string cmd, string msg )
{
	ConsoleCommand( cmd );
	if ( myHUD != None && msg != "" )
	{
		myHUD.LocalizedMessage( class'ComboMessage', 0, None, None, None, msg );
	}
}


exec function BeginAttractMode()
{
    GotoState('Spectating');
}

state Spectating
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
	 ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange,
     Say, TeamSay;

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
	}

	function PlayerMove(float DeltaTime)
	{
        local float deltayaw, destyaw;
        local Rotator newrot;

        if (attracttarget == None)
            return;

        // updates camera yaw to smoothly rotate to the pawn facing
        if (bBehindView)
        {
			if ( attracttarget.controller != None )
			{
				if( attracttarget.controller.Enemy == None )
					NewRot = Rotator(attracttarget.location);
				else
					NewRot = Rotator(attracttarget.controller.Enemy.location - attracttarget.location);
				destyaw = NewRot.Yaw;
				deltayaw = (destyaw & 65535) - (rotation.yaw & 65535);
				if (deltayaw < -32768) deltayaw += 65536;
				else if (deltayaw > 32768) deltayaw -= 65536;

				newrot = rotation;
				newrot.yaw += deltayaw * DeltaTime;
				SetRotation(newrot);
			}
        }
        else if (!class'GameInfo'.default.bAttractAlwaysFirstPerson)
        {
            newrot = CameraTrack(attracttarget, DeltaTime);
            //if (!camlist[curcam].fixed)
            //{
                SetRotation(newrot);
            //}
        }
	}

	exec function NextWeapon()
	{
	}

	exec function PrevWeapon()
	{
	}

	exec function Fire( optional float F )
	{
        // start playing
	}

	exec function AltFire( optional float F )
	{
        Fire(F);
	}

	function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			//UnPossess();
		}
		bCollideWorld = true;
        if ( curcam == -1 )   
        {
            FillCameraList();
            camtime = 0;
            targettime = 0;
            autozoom = true;
            curcam = -1;
        }
        
        Timer();
        SetTimer(0.5, true);
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;		
		bCollideWorld = false;
        curcam = -1;
		FixFOV();
	}

    function Timer()
    {
        local bool switchedbots;
        local Vector newloc;
        local int newcam;

        camtime += 0.5;
        targettime += 0.5;
        bFrozen = false;

        // keep watching a target for a few seconds after it dies
        if (gibwatchtime > 0)
        {
            gibwatchtime -= 0.5;
            if (gibwatchtime <= 0)
                attracttarget = None;
            else
                return;
        }
        else if (attracttarget != None && attracttarget.Health <= 0 && !class'GameInfo'.default.bAttractAlwaysFirstPerson)
        {
            gibwatchtime = 4;
            //Log("attract: watching gib");
        }

        // switch targets //
        if (attracttarget == None
            || targettime > 30
            /*|| attracttarget.Health <= 0*/
            /*|| is unintersting*/)
        {
            attracttarget = PickNextBot(attracttarget);
            switchedbots = true;
            targettime = 0;
            //Log("attract: viewing "$attracttarget);
        }

        // no target //
        if (attracttarget == None)
        {
            return;
        }

        // switch views //
        if (
            switchedbots ||
            camtime > 10 ||
            bBehindView == false && (rotation.pitch < -10000 || !LineOfSight(curcam, attracttarget))
        )
        {
            camtime = 0;
            FovAngle = default.FovAngle;
            SetViewTarget(self);
	    	bBehindView = false;

            // always do first person view
            if (class'GameInfo'.default.bAttractAlwaysFirstPerson)
            {
                curcam = -1;
    		    SetViewTarget(attracttarget);		 
	    	    bBehindView = false;
            }
            // look for a placed camera
            else if (FindFixedCam(attracttarget, newcam))
            {
                focuspoint = attracttarget.Location;
                curcam = newcam;
                SetLocation(camlist[curcam].Location);
                FovAngle = camlist[curcam].ViewAngle;
                //if (camlist[curcam].fixed)
                    //SetRotation(camlist[curcam].rotation);
                //else
                    //SetRotation(Rotator(attracttarget.Location - Location));
        
                SetRotation(CameraTrack(attracttarget, 0));
                //Log("attract: camera "$camlist[curcam]);
            }
            // use a floating camera
            else if (FRand() < 0.5)
            {
                newloc = FindFloatingCam(attracttarget);
                focuspoint = attracttarget.Location;
                curcam = -1;
                SetLocation(newloc);
                //Rotator(attracttarget.Location - Location));
            
                SetRotation(CameraTrack(attracttarget, 0));
                //Log("attract: free camera");
            }
            // chase mode
            else
            {
                curcam = -1;
    		    SetViewTarget(attracttarget);		 
	    	    bBehindView = true;
                SetRotation(attracttarget.rotation);
                CameraDeltaRotation.Pitch = -3000;
                CameraDist = 6;
                //Log("attract: chase camera");
            }

        }

    }
}

state DeadSpectating extends Spectating // sjs
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
        ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange,
        Say, TeamSay;

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

	exec function Fire( optional float F )
	{
		if ( !bFrozen )
			ServerReStartPlayer();
	}
	
	exec function AltFire( optional float F )
	{
		Fire(F);
	}

    function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			//UnPossess();
		}
		bCollideWorld = true;
        if ( curcam == -1 )   
        {
            FillCameraList();
            camtime = 0;
            targettime = 0;
            autozoom = true;
            curcam = -1;
        }
        Timer();
        SetTimer(0.5, true);
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;		
		bCollideWorld = false;
        curcam = -1;
	}
}

state ViewPlayer extends PlayerWalking
{
	function PlayerMove(float DeltaTime)
	{
        Super.PlayerMove(DeltaTime);
        
        CameraSwivel = CameraTrack(pawn, DeltaTime);
    }

    function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        // not calling super
        CameraRotation = CameraSwivel;
        CameraLocation = location; //camlist[curcam].location;
        ViewActor = self;
    }

    function BeginState()
    {
        FillCameraList();
        bBehindView = true;
        SetViewTarget(self);
        curcam = -2;
        autozoom = true;
        Timer();
        SetTimer(0.5, true);
    }

    function EndState()
    {
        CameraSwivel = rot(0,0,0);
        bBehindView = false;
        FixFOV();
        SetViewTarget(pawn);
    }

    function Timer()
    {
        local Vector newloc;
        local int newcam;

        if (curcam == -2 || !LineOfSight(curcam, pawn))
        {
            //Log("attract: switch camera");

            camtime = 0;

            if (FindFixedCam(pawn, newcam))
            {       
                if (curcam != newcam)
                {
                    focuspoint = pawn.Location;
                    curcam = newcam;
                    SetLocation(camlist[curcam].location);
                    FovAngle = camlist[curcam].ViewAngle;
                    //Log("attract: viewing from "$camlist[curcam]);
                }
                else
                {
                    //Log("attract: zoinks! this shouldn't happen");
                }
            }
            else
            {
                newloc = FindFloatingCam(pawn);
                SetLocation(newloc);
                curcam = -1;
                FovAngle = default.FovAngle;
                focuspoint = pawn.Location;
                //Log("attract: floating");
            }

            CameraSwivel = CameraTrack(pawn, 0);
        }
    }

    exec function TogglePlayerAttract()
    {
        GotoState('PlayerWalking');
    }
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

    function BeginState()
    {
	    bFire = 0;
	    bAltFire = 0;
        Super.BeginState();
    }

    function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        // not calling super
        CameraRotation = CameraSwivel;
        CameraLocation = location; //camlist[curcam].location;
        ViewActor = self;
    }

    function PlayerMove(float DeltaTime)
    {
        //Super.PlayerMove(DeltaTime);
        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
        if ( attracttarget != None )
        {
            CameraSwivel = CameraTrack(attracttarget, DeltaTime);
        }
    }

    function FindGoodView()
    {
        local Vector newloc;
        local int newcam;
        local Pawn lookat;

        lookat = Pawn;

        if (lookat == None)
            lookat = Pawn(ViewTarget);

        if (lookat == None)
        {
            //Super.FindGoodView();
            CameraSwivel = Rotation;
            return;
        }

        FillCameraList();
        SetViewTarget(self);
        autozoom = true;
        FovAngle = default.FovAngle;

        if (FindFixedCam(lookat, newcam))
        {       
            curcam = newcam;
            SetLocation(camlist[curcam].location);
            FovAngle = camlist[curcam].ViewAngle;
            //Log("attract: viewing from "$camlist[curcam]);
        }
        else
        {
            newloc = FindFloatingCam(lookat);
            SetLocation(newloc);
            curcam = -1;
            //Log("attract: floating");
        }

        focuspoint = lookat.Location;
        attracttarget = lookat;

        DesiredFov = FovAngle;
        CameraSwivel = CameraTrack(lookat, 0);
        SetRotation(CameraSwivel);
    }

    function EndState()
    {
        CameraSwivel = rot(0,0,0);
        FixFOV();
        Super.EndState();
    }
}


function FillCameraList()
{
    local AttractCamera cam;
    numcams = 0;
    foreach AllActors(class'AttractCamera', cam)
    {
        camlist[numcams++] = cam;
        if (numcams == 20) break;
    }
}

function bool FindFixedCam(Pawn target, out int newcam)
{
    local int c, bestc;
    local float dist, bestdist;

    bestc = -1;

    for (c = 0; c < numcams; c++)
    {
        dist = VSize(target.location - camlist[c].location);

        if ((bestc == -1 || dist < bestdist) && LineOfSight(c, target))
        {
            bestc = c;
            bestdist = dist;
        }
    }

    if (bestc == -1) return false;

    newcam = bestc;
    return true;
}

function Vector FindFloatingCam(Pawn target)
{
    local Vector v1, v2, d;
    local Rotator r;
    local Vector hitloc, hitnormal;
    local Actor hitactor;
    local int tries;

    while (tries++ < 10)
    {
        v1 = target.Location;
        r = target.Rotation;
        r.Pitch = FRand()*12000 - 2000;
        if (VSize(target.Velocity) < 100)
            r.Yaw += FRand()*24000;
        else
            r.Yaw += FRand()*12000;
        d = Vector(r);
        v2 = v1 + d*3000;
        v1 += d*50;

        hitactor = Trace(hitloc, hitnormal, v2, v1, false);

        if (hitactor != None && VSize(hitloc - v1) > 450)
        {
            return (hitloc - d*50);
        }
    }
    // no good spots found, return something reasonable
    if (hitactor != None)
        return (hitloc - d*50);
    else
        return v2;
}

function Pawn PickNextBot(Pawn current)
{
    local Controller con;
    local int b;

    if (current != None) con = current.Controller;
    for (b=0; b<Level.Game.NumBots; b++)
    {
        if (con != None) con = con.NextController;
        if (con == None) con = Level.ControllerList;
        if (con.IsA('Bot') && con.Pawn != None && !con.IsInState('PlayerWaiting'))
        {
            return con.Pawn;
        }
    }
    return None;
}

function bool LineOfSight(int c, Pawn target)
{
    local vector v1, v2;
    local AttractCamera cam;
    //local float d;
    local Vector hitloc, hitnormal;

    if (c >= 0) {
        cam = camlist[c];
        v1 = cam.location;
    } else {
        v1 = self.location;
    }
    v2 = target.location;
    v2.z += target.eyeheight;
    v2 += Normal(v1 - v2) * 100;
    /*if (c >= 0 && cam.fov + cam.maxangle < 360)
    {
        d = Normal(Vector(cam.rotation)*vect(1,1,0)) dot Normal((v2 - v1)*vect(1,1,0));
        if (d < cos((cam.fov + cam.maxangle)/2*PI/180))
        {
            return false;
        }
    }*/
    return (Trace(hitloc, hitnormal, v1, v2, false) == None);
}

function Rotator CameraTrack(Pawn target, float DeltaTime)
{
    local float dist;
    local Vector lead;
    local Rotator newrot;
    local float minzoomdist, maxzoomdist, viewangle, viewwidth;
    //local float deltayaw;
    
    // update focuspoint
    lead = target.location + Vect(0,0,0.8) * Target.CollisionHeight; // + target.Velocity*0.5;
    dist = VSize(lead - focuspoint);
    if (dist > 20)
    {
        focuspoint += Normal(lead - focuspoint) * dist * DeltaTime * 4.0;
    }

    // adjust zoom within bounds (FovAngle 30-100)
    if (autozoom)
    {
        dist = VSize(Location - target.Location);

        if (curcam >= 0)
        {
            minzoomdist = camlist[curcam].minzoomdist;
            maxzoomdist = camlist[curcam].maxzoomdist;
            viewangle = camlist[curcam].ViewAngle; 
        }
        else
        {
            minzoomdist = 500;
            maxzoomdist = 1200;
            viewangle = default.FovAngle;
        }

        if (dist < minzoomdist)
        {
            FovAngle = viewangle;
        }
        else //if (dist < maxzoomdist)
        {
            viewwidth = minzoomdist*Tan(viewangle*PI/180 / 2);
            FovAngle = Atan(viewwidth, dist) * 180/PI * 2;
        }

        DesiredFOV = FovAngle;
    }

    newrot = Rotator(focuspoint - location);

    // clamp yaw to the camera's maxangle
    /*if (curcam >= 0)
    {
        maxangle = camlist[curcam].maxangle*65536/360 / 2;

        deltayaw = (newrot.yaw & 65535) - (camlist[curcam].rotation.yaw & 65535);
        if (deltayaw < -32768) deltayaw += 65536;
        else if (deltayaw > 32768) deltayaw -= 65536;

        if (abs(deltayaw) > maxangle)
        {
            if (deltayaw > 0) newrot.yaw = camlist[curcam].rotation.yaw + maxangle;
            else newrot.yaw = camlist[curcam].rotation.yaw - maxangle;
        }
    }*/

    return newrot;
}


function ViewPlummet(AttractCamera cam)
{
	GotoState('ViewPlayer');
}


/*
function PawnDied()
{
    local Pawn p;

    p = Pawn;
	Super.PawnDied();

    attracttarget = p;

    if (numcams == 0)
        FillCameraList();

    autozoom = true;
    bBehindview = true;

    if (FindFixedCam(attracttarget, curcam))
    {
        log("fixed cam="$curcam);
        SetViewTarget(camlist[curcam]);
        focuspoint = attracttarget.Location;
        SetLocation(camlist[curcam].Location);
        FovAngle = camlist[curcam].ViewAngle;
        CameraTrack(attracttarget, 3.0);
    }
    else
    {
    
        log("float cam");
        curcam = -1;
        SetLocation(FindFloatingCam(attracttarget));
        SetRotation(CameraTrack(attracttarget, 0));
    }

    Enemy = None;		
    bFrozen = true;
	bPressedJump = false;
	bJustFired = false;
	bJustAltFired = false;
	SetTimer(1.0, false);

	// clean out saved moves
	while ( SavedMoves != None )
	{
		SavedMoves.Destroy();
		SavedMoves = SavedMoves.NextMove;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
 
    GotoState('DeadSpectating');
}*/


function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
    if ( Pawn != None )
	{
		Pawn.PlayDying(DamageType, HitLocation);
	}
}

function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;

    LastKillTime = -5.0;

    SetViewTarget(Pawn);
    ClientSetViewTarget(Pawn);

    Super.PawnDied(P);
}


// amb ---
function SetPawnClass(string inClass, string inCharacter, optional string DefaultClass)
{
    local class<xPawn> pClass;
    local xUtil.PlayerRecord recLoaded;
    
    if(Level.Game != None && Level.Game.bSinglePlayer==true)
        return;

	if( IsMiniEd() )
	{
		pClass = class<xPawn>(DynamicLoadObject(inClass, class'Class'));
		if (pClass != None)
			PawnClass = pClass;
		return;
	}

	log("SetPawnClass got "$inclass@incharacter@defaultclass);
	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    
	if(inClass!="") //allow overriden class from user.ini
	{
		pClass = class<xPawn>(DynamicLoadObject(inClass, class'Class'));
		if (pClass != None)
			PawnClass = pClass;
	}
	else //fall back on defaultclass
	{
		assert( DefaultClass != "" );
		pClass = class<xPawn>(DynamicLoadObject(DefaultClass, class'Class'));
		if (pClass != None)
			PawnClass = pClass;
	}

    if (PawnSetupRecord.DefaultName == "")
        PawnSetupRecord = class'xUtil'.static.GetRandPlayerRecord();

    PlayerReplicationInfo.SetCharacterName(PawnSetupRecord.DefaultName);

    //log("xplayer.setpawnclass.... name is:"$PawnSetupRecord.defaultname);

    recLoaded = class'xUtil'.static.CheckLoadLimits(Level, PawnSetupRecord.RecordIndex);
    if (recLoaded.RecordIndex != PawnSetupRecord.RecordIndex)
        PawnSetupRecord = recLoaded;
    class'xUtil'.static.LoadPlayerRecordResources(PawnSetupRecord.RecordIndex, Level.NetMode != NM_Standalone || !Level.Game.bSinglePlayer);
}

function Possess( Pawn aPawn )
{
    local xPawn xp;

    Super.Possess( aPawn );

    xp = xPawn(aPawn);
	//CMR
	if(xp==None || bIgnorePlayerRecord) return;

	if( !IsMiniEd() )
		xp.SetupPlayerRecord(PawnSetupRecord, true);
}

// for changing character on the fly (for next respawn)
exec function ChangeCharacter(string newCharacter)
{
	// cmr
    log("THIS IS A DEBUG FUNCTION ONLY, DO NOT CALL THIS FUNCTION EXCEPT FOR TESTING, ALSO, EXPECT IT TO MALFUNCTION.");
	
	SetPawnClass(string(PawnClass), newCharacter);
	UpdateURL("Character", newCharacter, true);
    
	// cmr
	//SaveConfig(); 
}

simulated event PostNetReceive()
{
    local xUtil.PlayerRecord rec;

//    log(self$" PostNetReceive PlayerReplicationInfo.CharacterName="$PlayerReplicationInfo.CharacterName);
	if (PlayerReplicationInfo != None)
    {
        rec = class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName);
        rec = class'xUtil'.static.CheckLoadLimits(Level, rec.RecordIndex);
        class'xUtil'.static.LoadPlayerRecordResources(rec.RecordIndex, Level.NetMode != NM_Standalone || !Level.Game.bSinglePlayer);	
        bNetNotify = false;
       // log(self$" PNR - load player: "$rec.DefaultName, 'LOADING');
    }
}

exec function JumpStats()
{
    if (Pawn != None)
        xPawn(Pawn).bMeasureJumps = !xPawn(Pawn).bMeasureJumps;
}

//TEMP
exec function ResetBots()
{
    local xbot xb;

    foreach AllActors(class'xbot', xb)
    {
        xb.InitAttribs();
    }
}

//ALSO TEMP
exec function ShowInv()
{
    local Inventory inv;

    log(self$" ShowInv!!!");

    inv = Pawn.Inventory;
    while (inv != None)
    {
        log(self$" inv="$inv);
        inv = inv.Inventory;
    }
}

// jij --- TEMP for testing single player!
exec function WeWin()
{
    local TeamGame tGame;    
    local GameProfile gProfile;
    
    tGame = TeamGame(Level.Game);
    gProfile = GetCurrentGameProfile();
    
    if ( tGame == None || gProfile == None)
        return;

    PlayerReplicationInfo.Score += 1000;
    tGame.Teams[0].Score = tGame.GoalScore;
    tGame.EndGame(PlayerReplicationInfo,"teamscorelimit"); // gam
}

exec function WeLose()
{
    local TeamGame tGame;    
    local GameProfile gProfile;
    
    tGame = TeamGame(Level.Game);
    gProfile = GetCurrentGameProfile();
    
    if ( tGame == None || gProfile == None)
        return;

	PlayerReplicationInfo.Score -= 1000;
    tGame.Teams[1].Score = tGame.GoalScore;
    tGame.EndGame(None,"teamscorelimit");        
}

exec function WinAll()
{
    local TeamGame tGame;    
    local GameProfile gProfile;
    
    tGame = TeamGame(Level.Game);
    gProfile = GetCurrentGameProfile();

    if (tGame == None || gProfile == None)
        return;

	tGame.Teams[0].Score = 20;
    tGame.EndGame(PlayerReplicationInfo,"teamscorelimit"); // gam
}
// --- jij

function UpdateStats()
{
    local PlayerStats PS;
    local PlayerStats.StatData WS;

    if (LastRequestPRI == None)
        return;

    PS = LastRequestPRI.Stats;

    // send player stats every 4 seconds, 1 weapon stat every .5 second
    if (PlayerStatCount <= 0)
    {
        SendPlayerStats(PS.Overall.Frags, Min(255,PS.Overall.Teamkills), Min(255,PS.Overall.Suicides), PS.Efficiency, Min(255,PS.Overall.Specials), LastRequestPRI.PlayTime);
        PlayerStatCount = 8;
    }
    else
    {
        PlayerStatCount--;

        WS = PS.GetWeaponStats(WeaponStatNum);

        if( WS.WeaponClass != None )
        {
            if (WS.Kills > 0 || WS.Deaths > 0 || WS.Accuracy > 0)
                SendWeaponStats(WS.WeaponClass, Min(255,WS.Kills), Min(255,WS.Deaths), Min(255,WS.Accuracy));
        }

        WeaponStatNum++;
        if (WeaponStatNum >= PS.GetNumWeaponStats())
            WeaponStatNum = 0;
    }
}

simulated function GetStats(PlayerReplicationInfo PRI)
{
    if (Role < ROLE_Authority && (Level.TimeSeconds >= NextStatRequestTime || LastRequestPRI != None && LastRequestPRI == PRI && Level.TimeSeconds >= NextStatRequestTime - 2.0))
    {
        NextStatRequestTime = Level.TimeSeconds + MinStatRequestCount;
        LastRequestPRI = PRI;
        RequestPlayerStats(PRI); // RPC to server
    }
}

function RequestPlayerStats(PlayerReplicationInfo PRI)
{
    if (PRI != LastRequestPRI)
    {
        LastRequestPRI = PRI;
        PlayerStatCount = 0;
        WeaponStatNum = 0;
    }
}

function oldRequestPlayerStats(PlayerReplicationInfo PRI)
{
    local BYTE i, n;
    local PlayerStats PS;
    local PlayerStats.StatData WS;

    PS = PRI.Stats;

    for( i=0; i<PS.GetNumWeaponStats(); i++ )
    {
        if( PS.GetWeaponStats(i).WeaponClass != None )
        {
            WS = PS.GetWeaponStats(i);
            if (WS.LastSentFrags != WS.Kills || WS.LastSentDeaths != WS.Deaths || WS.LastSentAcc != WS.Accuracy)
            {
                SendWeaponStats(WS.WeaponClass, Min(255,WS.Kills), Min(255,WS.Deaths), Min(255,WS.Accuracy));
                WS.LastSentFrags = WS.Kills;
                WS.LastSentDeaths = WS.Deaths;
                WS.LastSentAcc = WS.Accuracy;
                PS.SetWeaponStats(i, WS);

                n++;
                if (n >= 3) break;
            }
        }
    }
    SendPlayerStats(PS.Overall.Frags, Min(255,PS.Overall.Teamkills), Min(255,PS.Overall.Suicides), PS.Efficiency, Min(255,PS.Overall.Specials), PRI.PlayTime);
}

function SendPlayerStats(int Frags, byte TeamKills, byte Suicides, byte Efficiency, byte Specials, float PlayTime)
{
    local PlayerStats PS;

    if (LastRequestPRI == None)
        return;

    PS = LastRequestPRI.Stats;
    log("Got Stats"@LastRequestPRI.RetrivePlayerName() );
    if( PS != None )
    {
        PS.Efficiency = Efficiency;
        PS.Overall.Frags = Frags;
        PS.Overall.TeamKills = TeamKills;
        PS.Overall.Suicides = Suicides;
        PS.Overall.Specials = Specials;
        PS.SetPlayerTimeStats(PlayTime);
    }
    
    if (!myHud.bShowPersonalStats && !IsInState('GameEnded'))
    {
        GetStats(None);
    }
}

function SendWeaponStats(class<Weapon> WeaponClass, byte Frags, byte Deaths, byte Accuracy)
{
    local PlayerStats PS;
    local PlayerStats.StatData WS;
    local int i;

    if (LastRequestPRI == None)
        return;

    PS = LastRequestPRI.Stats;
    if( PS != None )
    {
        i = PS.GetWeaponStat(WeaponClass);
        WS = PS.GetWeaponStats(i);
        WS.Kills = Frags;
        WS.Deaths = Deaths;
        WS.Accuracy = Accuracy;
        PS.SetWeaponStats(i, WS);
    }
}


simulated function ClientGameEnded()
{
    local String MapName;
    
    MapName = Left( GetURLMap(), 1 );

	if( (Level.GetAuthMode() == AM_Live) && !PlayerReplicationInfo.bLiveStatsPosted
        && ConsoleCommand("XLIVE INDEX_IS_GUEST"@Player.GamepadIndex) == "FALSE"
        && !(MapName ~= "X") )
    {
	    ConsoleCommand( "XLIVE STAT_WRITE" );
        PlayerReplicationInfo.bLiveStatsPosted = true;
    }

	GotoState('GameEnded');
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

    exec function ThrowWeapon()
    {
    }

    exec function Fire( optional float F )
    {
        if ( Role < ROLE_Authority)
            return;
        if ( !bFrozen )
        {
            ServerReStartGame();
        }
        //else if ( TimerRate <= 0 )
        //    SetTimer(1.5, false);
    }
    
    exec function AltFire( optional float F )
    {
        Fire(F);
    }

    function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
    {
        CameraRotation = CameraSwivel;
        CameraLocation = location;
        ViewActor = self;
    }

    function PlayerMove(float DeltaTime)
    {
        ViewShake(DeltaTime);
        ViewFlash(DeltaTime);
        if ( attracttarget != None )
        {
            CameraSwivel = CameraTrack(attracttarget, DeltaTime);
        }
    }

    function FindGoodView()
    {
        local Vector newloc;
        local int newcam;
        local Pawn lookat;

        lookat = Pawn(ViewTarget);
        if (lookat == None)
        {
            ClientSetBehindView(true);
            Super.FindGoodView();
            return;
        }

        FillCameraList();
        bBehindView = true;
        SetViewTarget(self);
        autozoom = true;
        FovAngle = default.FovAngle;
        
        if (FindFixedCam(lookat, newcam))
        {       
            focuspoint = lookat.Location;
            curcam = newcam;
            SetLocation(camlist[curcam].location);
            FovAngle = camlist[curcam].ViewAngle;
            //Log("attract: viewing from "$camlist[curcam]);
        }
        else
        {
            newloc = FindFloatingCam(lookat);
            SetLocation(newloc);
            curcam = -1;
            focuspoint = lookat.Location;
            //Log("attract: floating");
        }

        attracttarget = lookat;

        DesiredFov = FovAngle;
        CameraSwivel = CameraTrack(lookat, 0);
        ClientSetBehindView(true);
    }
    
    function Timer()
    {
        bFrozen = false;
    }
    
    function BeginState()
    {
        local Pawn P;

        //EndZoom();
        bFire = 0;
        bAltFire = 0;
        if ( Pawn != None )
        {
            Pawn.Velocity = Vect(0,0,0);
            Pawn.Acceleration = Pawn.Velocity;
            if( Pawn.Physics == PHYS_Falling )
            {
                Pawn.SetPhysics(PHYS_None);
                Pawn.SimAnim.AnimRate = 0;
                Pawn.StopAnimating();
                Pawn.bPhysicsAnimUpdate = false;
            }
            else
            {
                Pawn.AnimBlendParams(1, 0.0);
                Pawn.PlayAnim(Pawn.IdleWeaponAnim);
                Pawn.bIsIdle = false;
            }
        }
        bFrozen = true;
        //if ( !bFixedCamera )
        //{
            FindGoodView();
        //    bBehindView = true;
        //}
        if( IsOnConsole() && GetCurrentGameProfile() == None)
            SetTimer(10.0, false);
        else
            SetTimer(1.5, false);
        //SetPhysics(PHYS_None);
        
        ForEach DynamicActors(class'Pawn', P)
        {
            if (P != Pawn)
            {
                P.Velocity = vect(0,0,0);
                P.Acceleration = vect(0,0,0);
                P.bPhysicsAnimUpdate = false;
                P.AnimBlendParams(1, 0.0);
                P.PlayAnim(P.IdleWeaponAnim);
                P.bIsIdle = false;
            }
        }

	    ConsoleCommand( "FULLSCREENVIEWPORT 0" );
        ClientSetMusic("victory", MTRAN_Fade);

        GetStats(PlayerReplicationInfo);
    }

    function EndState()
    {
        CameraSwivel = rot(0,0,0);
        FixFOV();
        ConsoleCommand( "FULLSCREENVIEWPORT -1" );
        Super.EndState();
    }
    
    event PlayerTick(float d)
    {
        bBehindView = true;
        Global.PlayerTick(d);
    }

Begin:
    /* gam
    Sleep(GameReplicationInfo.ScoreBoardDelay(self));
    GameReplicationInfo.SetScoreBoardVisibility(self, true);
    */
}


// Coop stuff...
function ServerSelectCoopCharacter(byte selection);
function ServerCoopReady();

state CoopJoined
{
    function BeginState()
    {
        log("CoopJoined.BeginState");
        myHud.bHideHud = true;
        GameReplicationInfo.SetScoreBoardVisibility(self, false);

        if (Level.NetMode == NM_Client)
            return;

        mCoopInfo = GameReplicationInfo.CoopInfo;
    }

    function EndState()
    {
        myHud.bHideHud = false;    
    }

    function ClientLaunchMenu(string menuName)
    {
        local class<Menu> menuClass;

        if (Level.NetMode == NM_Client)
            return;

        // RPC to launch on remote
		assert(menuName!="");
        menuClass = class<Menu>(DynamicLoadObject(menuName, class'Class'));
        MenuOpen(menuClass);
    }

    function ServerSelectCoopCharacter(byte selection)
    {
        PlayerReplicationInfo.CharSelection = selection;
        //mCoopInfo.SelectionsUpdated();
    }

    function ServerCoopReady()
    {
        bCoopPlayerReady = true;
        ServerRestartPlayer();
    }

    function bool CanRestartPlayer()
    {
        if (!Super.CanRestartPlayer())
            return false;
        return bCoopPlayerReady && mCoopInfo.IsCaptainReady();
    }

    function ServerRestartPlayer()
    {
        if ( Level.TimeSeconds < WaitDelay )
            return;
        if ( Level.NetMode == NM_Client )
            return;
        if ( !CanRestartPlayer() )
            return;
        if ( Level.Game.bWaitingToStartMatch )
            PlayerReplicationInfo.bReadyToPlay = true;
        else
            Level.Game.RestartPlayer(self);
    }

    exec function Fire(optional float F)
    {
        ServerRestartPlayer();
    }

    exec function AltFire(optional float F)
    {
        ServerRestartPlayer();
    }

Begin:
    Sleep(0.5);
    ClientLaunchMenu("XInterfaceSP.MenuCoopPlayerConfig");
}

// AutoAim (UC)...
// returns true if actually hit target, false if target is closest
function bool FindBestTarget(out Actor bestTarget, out vector hitLoc, 
                             Ammunition firedAmmunition, vector projStart, vector fireDir)
{
    local vector hitNormal;
    local float bestAim, bestDist;
    local Actor traceHit;

    traceHit = Trace(hitLoc, hitNormal, projStart + firedAmmunition.MaxRange * fireDir, projStart, true);

//    log("trace best="$besttarget);

    // Actual hit
    if (traceHit != None && traceHit.bProjTarget)
        return true;

    // adjust aim based on FOV
    if( bAutoAim )
    {
        bestAim = firedAmmunition.AutoAim;
    }
    else
    {
            bestAim = 0.995;
    }

    // Find closest
    bestTarget = PickTarget(bestAim, bestDist, fireDir, projStart, firedAmmunition.MaxRange);

    return false; 
}

function rotator GetAim()
{
    if (bBehindView)
        return Pawn.Rotation;
    else
        return Rotation;
}

function vector GetAutoAimSpot(Ammunition firedAmmunition, vector projStart, vector fireDir, Pawn bestTarget)
{
    local vector aimSpot;
    local float projSpeed, projTime;

    if (FiredAmmunition.bTrySplash)
    {
        // aim for feet
        aimSpot = bestTarget.Location - vect(0,0,1) * bestTarget.CollisionHeight;
       // log("feet");
    }
    else if (FiredAmmunition.bTryHeadShot)
    {
        // aim for head
        aimSpot = bestTarget.Location + vect(0,0,0.8) * bestTarget.CollisionHeight;
        //log("head");
    }
    else
    {
        // aim for middle
        aimSpot = bestTarget.Location;
        //log("middle");
    }

    if (FiredAmmunition.bLeadTarget)
    {
        // consider target vel
        projSpeed = firedAmmunition.ProjectileClass.default.Speed;
        projTime = VSize(aimSpot - projStart)/projSpeed;
        aimSpot += Normal(bestTarget.Velocity) * projTime;
       // log("lead");
    }

    return aimSpot;
}

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
    local Actor bestTarget;
    local Pawn bestPawn;
    local vector fireDir, aimSpot, newAim;
    local float maxH, maxV;
    local bool bHit;

    // UC only
    if (!IsOnConsole())
        return Super.AdjustAim(FiredAmmunition, projStart, aimerror);

    fireDir = vector(Rotation);
    bHit = FindBestTarget(bestTarget, aimSpot, firedAmmunition, projStart, fireDir);

    // miss
    if (bestTarget == None)
        return GetAim();

    // warn bots
    firedAmmunition.WarnTarget(bestTarget, Pawn, fireDir);
    if( !bAutoAim )
        return GetAim();

    // get desired hit location 
    bestPawn = Pawn(bestTarget);
    if (bestPawn != None)
    {
        if (!bHit || !firedAmmunition.bInstantHit)
            aimSpot = GetAutoAimSpot(firedAmmunition, projStart, fireDir, bestPawn);

        // reject shots that are way off - taking distance into account
        // and correct the aim gradually
        maxH = MaxHOffset * bestPawn.CollisionRadius;
        maxV = MaxVOffset * bestPawn.CollisionHeight;
        if (!class'xUtil'.static.CorrectAutoAim(newAim, projStart, fireDir, bestPawn, 
                                                aimSpot, maxH, maxV, HitOffsetRatio))
        {
            return GetAim();
        }
        return rotator(newAim);
    }
    else
    {
        return rotator(aimSpot - projStart);
    }
}
// --- amb 

exec function ToggleMemStats()
{
    bShowMemStats = !bShowMemStats;
}

function string ParseChatPercVar(string Cmd)
{
	if (xPawn(Pawn)==None)
		return Cmd;
	
	if (cmd~="%S") // Shield
		return int(XPawn(Pawn).ShieldStrength)@"Shield";


	return Super.ParseChatPercVar(Cmd);
}

exec function LoadUserINI(string fileName)
{
    local string newName, newChar;



    class'xUtil'.static.LoadUserINI(self, fileName, newName, newChar);
    ChangeName(newName);
    
	// cmr -- player not allowed to change their class anymore
	// SetPawnClass(string(PawnClass), newChar);
}

exec function VoiceMenu()
{
    if (Level.TimeSeconds < LastVoiceTime+1.0)
        return;

    if (GameReplicationInfo.bTeamGame)
    {
        if (MyHud != None)
            MyHud.ShowVoiceMenu();
    }
    else
    {
        Speech('AUTOTAUNT', PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(self, false, false), "");
        LastVoiceTime = Level.TimeSeconds;
        Taunt('');
    }
}

exec function NextFreeVoiceChannel()
{    
    if (Level.NetMode == NM_StandAlone)
        return;

    if (MyHud != None)
        MyHud.ShowVoiceChannelMenu();
}

// amb ---
simulated function string GetPlayerRecordDefaultName(int PlayerRecordIndex)
{
    local xUtil.PlayerRecord rec;
    rec = class'xUtil'.static.GetPlayerRecord(PlayerRecordIndex);
    return rec.DefaultName;
}
// --- amb

defaultproperties
{
     curcam=-1
     MinStatRequestCount=5.000000
     maxHoffset=8.000000
     maxVoffset=4.000000
     hitOffsetRatio=0.500000
     PickTargetAim=0.900000
     TeamBeaconTexture=Texture'PariahGameTypeTextures.TeamSymbols.TeamBeaconT'
     TeamBeaconTextureAnimated=Texture'InterfaceContent.LiveIconsAnim.Communicator_a00'
     PlayerReplicationInfoClass=Class'XGame.xPlayerReplicationInfo'
     PawnClass=Class'XGame.xPawn'
     bNetNotify=True
}
