class SinglePlayer extends GameInfo;

struct NPCData
{
	var Pawn p;
	var name CharID;
};

var array<NPCData> NPCs;
var array<Stage>    Stages;

var bool bSpecialBotCombatScene;

var array<PlayerController> QueuedJoins;

struct ForwardingEntry
{
    var PlayerController Target;
    var PlayerController Other;
};
var array<ForwardingEntry> ForwardingQueue;

// ugly duplicity with profiles
struct WeaponInfo
{
	var class<VGWeapon>	WeaponClass;
	var int				WECLevel;
	var int             AmmoAmount;
	var int             RemainingMagAmmo;
	var int             MagAmount;
};

struct RespawnSave
{
    var int                 Valid;
	var int					WECCount;
	var float				ShieldStrength;
	var float				DashTime;
	var array<WeaponInfo>	Weapons;
};

var RespawnSave RespawnStates[2];

// this is horrible - rj
//
enum AssassinCloakMode
{
	ACM_CloakingAI,	// allow AI to control cloaking
	ACM_CloakingOn,	// turn cloaking on and leave it on
	ACM_CloakingOff	// turn cloaking off and leave it off
};
var AssassinCloakMode	AssassinCloakingMode;
const SaveGameTimerSlot = 0;

event PreBeginPlay()
{
    local Stage stg;

    ForEach AllActors( class'Stage', stg)
	{
        Stages[Stages.Length] = stg;
	}
}

function bool ShouldRespawn( Pickup Other )
{
    if( Other.IsA('VehicleWeaponPickupPlaceable') && Level.IsCoopSession() && !Other.bDropped )
    {
        Other.bPickupOnce = false;
        VehicleWeaponPickupPlaceable(Other).bWeaponStay = true;
        return true;
    }
    return Super.ShouldRespawn(Other);
}

event SetInitialState()
{
	// do this in SetInitialState() instead of PostBeginPlay() since SetInitialState() isn't called
	// for actors loaded from a save game
	//
	TriggerEvent('SinglePlayerStartEvent', self, None);
	Super.SetInitialState();
}

event PostBeginPlay()
{
    local xUtil.PlayerRecord PlayerRecord;
    local Array <xUtil.WeaponRecord> WeaponRecords;

	log( "Precaching singleplayer resources..." );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("Mason");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
        	
	class'xUtil'.static.GetWeaponList( WeaponRecords );

	Super.PostBeginPlay();
}

function RegisterNPC(name CharID, Pawn p)
{
	local int i;

	log("got RegisterNPC with "$CharID@p);

	//find an empty spot

	for(i=0;i<NPCs.Length;i++)
	{
		if(NPCs[i].CharID=='')
			break;
	}


	NPCs[i].p = p;
	NPCs[i].CharID = CharID;


}

function UnRegisterNPC(name CharID)
{
	local int i;

	//find the char
	for(i=0;i<NPCs.Length;i++)
	{
		if(NPCs[i].CharID==CharID)
			break;
	}

	NPCs[i].p = None;
	NPCs[i].CharID = '';
}

function Pawn GetNPCPawn(name CharID)
{
	local int i;

	log("looking for "$CharID);

	//find the char
	for(i=0;i<NPCs.Length;i++)
	{
		log("  check against "$NPCs[i].CharID);
		if(NPCs[i].CharID==CharID)
			return NPCs[i].p;
	}
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);

    if ( P != None )
	{
        if ( P.bSinglePlayerStart )
		{
			if ( P.bEnabled )
				return 1000;
			return 20;
		}

		return 10;
	}
	return 0;
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
	local VGSPAIController bot;

	Super.NotifyKilled(Killer,  Killed,  KilledPawn);

	foreach DynamicActors( class'VGSPAIController', bot )
	{
		bot.NotifyKilled(Killer,  Killed,  KilledPawn);
	}
}


//cmr -- will need to be jiggered for co-op play
function bool IsFriendly(pawn p1, pawn p2)
{
	local Pawn player;
	local SPPawn bot1, bot2;

	if(( p1 == None ) || ( p2 == None ))
	{
	    return false;
	}

	if(p1.IsA('VGVehicle'))
		p1 = VGVehicle(p1).Driver;
	else if(p1.IsA('PlayerTurret') )
		p1 = PlayerTurret(p1).PawnGunner;

	if(p2.IsA('VGVehicle'))
		p2 = VGVehicle(p2).Driver;
	else if(p2.IsA('PlayerTurret') )
		p2 = PlayerTurret(p2).PawnGunner;

	if(p1 == None || p2 == None) return false; //if it's an undriven vehicle, rape away


	if(p1.IsA('SPPlayerPawn'))
	{
		player = p1;
		bot1 = SPPawn(p2);
	}
	else if(p2.IsA('SPPlayerPawn'))
	{
		player = p2;
		bot1 = SPPawn(p1);
	}
	else
	{
		bot1 = SPPawn(p1);
		bot2 = SPPawn(p2);
	}

	if(player != None)
	{
		if(bot1 != none && bot1.race == R_NPC)
			return true;
		else
			return false;
	}
	else
	{
		if(bot1 != none && bot2 != none && bot1.race == bot2.race)
			return true;
		else
			return false;
	}

	return false;
}



function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType , optional out int bPlayHitEffects )
{
	if(injured.InGodMode()) // sjs - early out here because following checks still send notifications that we want ignored for godmode AI
	{
		return 0;
	}

	if( injured != instigatedby && IsFriendly(instigatedby, injured))
	{
        if( injured.Controller != None )
            injured.Controller.NotifyTakeHit(instigatedBy, HitLocation, 0, DamageType, Momentum);
		return 0;
	}



	//cmr -- if special bot combat scene, don't let bots damage each other.
	if(bSpecialBotCombatScene && injured.Controller!=None && injured.Controller.IsA('VGSPAIBase') && instigatedBy.Controller!=None && instigatedBy.Controller.IsA('VGSPAIBase') )
	{
		bPlayHitEffects=1;
        return 0;
	}

    if( injured.Controller!=None && injured.Controller.IsA('VGSPAIBase') && !(injured.Controller.IsA('SPAIStockton')) && instigatedBy!=None && instigatedBy.Controller!=None && instigatedBy.Controller.IsA('SinglePlayerController'))
    {
        if(Difficulty < 2.5)
        {
            Damage *= 1.1;
        }
        else if(Difficulty < 5)
        {
            
            Damage *= 1.0;
        }
        else if(Difficulty < 7)
        {
            Damage *= 0.9;
        }
        else
        {
            Damage *= 0.8;
        }
    }


	return Super.ReduceDamage(Damage, injured, instigatedby,hitlocation,momentum,damagetype);
}

function AddToJoinQueue(PlayerController aPlayer)
{
    local int i;
    for(i = 0; i < QueuedJoins.Length; ++i)
    {
        if(QueuedJoins[i] == aPlayer)
        {
            log("AddToJoinQueue: Duplicate, not adding: "@aPlayer);
            return;
        }
    }
    log("AddToJoinQueue: "@aPlayer);
    QueuedJoins[QueuedJoins.Length] = aPlayer;
}

function QueueBringForward(PlayerController Target, PlayerController Other)
{
    local ForwardingEntry fe;
    local int i;
    
    for(i = 0; i < ForwardingQueue.Length; ++i)
    {
        if(ForwardingQueue[i].Other == Other)
        {
            log("QueueBringForward: Duplicate, not adding: "@Other);
            return;
        }
    }
    log("QueueBringForward: "@Other);
    
    fe.Target = Target;
    fe.Other = Other;
    ForwardingQueue[ForwardingQueue.Length] = fe;
}

function vector GetPossibleStartPoint(Pawn Target, vector X, vector Y, int Attempt)
{
	local float radius;
	local VGPawn vg;

	radius = Target.CollisionRadius * 2.5;
	if(Target.IsA('VGPawn'))
	{
		vg = VGPawn(Target);
		if(vg.DrivenVehicle != None || vg.RiddenVehicle != None || vg.RiddenTurret != None)
		{
			radius = 550; // science
		}
	}

    switch(Attempt)
    {
        case 0:
            return Target.Location - X * radius;
        case 1:
            return Target.Location - (X + Y) * radius;
        case 2:
            return Target.Location - (X - Y) * radius;
        case 3:
            return Target.Location + Y * radius;
        case 4:
            return Target.Location - Y * radius;
    }
    return Target.Location - X * radius;
}

function bool ConfirmReachability(vector Pos, Pawn From)
{
    // line of sight to position?
    if(!FastTrace(Pos + From.default.EyeHeight * vect(0,0,0.8), From.Location + From.default.EyeHeight * vect(0,0,0.8)))
    {
        return false;
    }
    
    // will I fall to my death?
    if(FastTrace(Pos - vect(0,0,200), Pos + vect(0,0,4)))
    {
        return false;
    }
    
    return(true);
}

function bool TrySpawnForCoop(PlayerController aPlayer)
{
    local PlayerController Friend;
    local Vector Pos;
    local Rotator Rot;
    local Rotator FriendRot;
    local int attempts;
    local Vector X, Y, Z;
    local Color WarpColor;
    
	log("CoopSpawn called for controller "@aPlayer@aPlayer.PawnClass);
	
	Friend = Level.GetLivingLocalPlayer();
	if(Friend == aPlayer)
	{
	    log("***** ERROR!!!!");
	}
	if(Friend == None)
	{
	    return false;
	}

    if(SinglePlayerController(Friend).bInSpecialVehicleScene) // jjs - ch5 spawn player next to vehicle
    {
        Pos = Friend.Pawn.Location + Vect(0,0,400);
	    aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,Pos, Rot);
        SinglePlayerController(aPlayer).bInSpecialVehicleScene = true;
    }
    else
    {
	    FriendRot = Friend.Pawn.Rotation;
	    FriendRot.Roll = 0;
	    FriendRot.Pitch = 0;
	    GetAxes(FriendRot, X, Y, Z);
	    for(attempts = 0; attempts < 5; ++attempts)
	    {
	        Pos = GetPossibleStartPoint(Friend.Pawn, X, Y, attempts);
	        if(!ConfirmReachability(Pos, Friend.Pawn))
	        {
	            continue;
	        }
	        Rot = BringForwardRotation(Friend, Pos);
	        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,Pos, Rot);
	        if(aPlayer.Pawn != None)
	        {
	            break;
	        }
        }
    }

    if(aPlayer.Pawn == None)
	{
	    return false;
	}
		
    aPlayer.Pawn.Anchor = aPlayer.StartSpot;
	aPlayer.Pawn.LastStartSpot = PlayerStart(aPlayer.StartSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;
    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;
    aPlayer.Pawn.SetPhysics(PHYS_Falling);
    WarpColor.R = 255;
    WarpColor.G = 255;
    WarpColor.B = 255;
    WarpColor.A = 255;
    aPlayer.myHud.QueueCinematicFade(-1.0, WarpColor);
    
    AddDefaultInventory(aPlayer.Pawn);
	if(!RestoreRespawnState(aPlayer.Pawn))
	{
		aPlayer.NotifyRestarted();
	}

    // jjs - ch5 start coop player in vehicle
    if(SinglePlayerController(Friend).bInSpecialVehicleScene)
    {
	    aPlayer.Pawn.SetCollision(False, False, False);
        VehiclePlayer(aPlayer).bStartInVehicle = true;
        VGPawn(aPlayer.Pawn).EnterNearestVehicle();
        VehiclePlayer(aPlayer).bStartInVehicle = false;
    }

    return true;
}

function Rotator BringForwardRotation(Controller Friend, vector Pos)
{
    local Rotator Rot;
    Rot = Rotator(Friend.Pawn.Location - Pos);
    Rot.Pitch = 0;
    Rot.Roll = 0;
    if(FRand() > 0.5)
    {
        Rot.Yaw += 6000;
    }
    else
    {
        Rot.Yaw -= 6000;
    }
    return Rot;
}

function bool TryBringForward(ForwardingEntry fe)
{
    local PlayerController Friend;
    local Vector Pos;
    local Rotator Rot;
    local Rotator FriendRot;
    local int attempts;
    local Vector X, Y, Z;
    local PlayerController aPlayer;
    local Color WarpColor;
    
    Friend = fe.Target;
	aPlayer = fe.Other;
	log("TryBringForward called for controller: "@aPlayer@aPlayer.PawnClass@Friend);
	
	if(aPlayer.Pawn.IsA('VGVehicle'))
	{
		VGVehicle(aPlayer.Pawn).DriverExits();
		log("Kicking coop player out of the car!");
    }
	else if(VGPawn(aPlayer.Pawn).RiddenVehicle != None)
	{
        VGPawn(aPlayer.Pawn).RiddenVehicle.EndRide(VGPawn(aPlayer.Pawn));
		aPlayer.Pawn.SetPhysics(PHYS_Falling);
		aPlayer.Pawn.bForcePhysicsRep = true;
		aPlayer.Pawn.SetBase(None);
		aPlayer.Pawn.bForceBaseRep = true;
		VehiclePlayer(aPlayer).bIsRidingVehicle = false;
		log("Kicking coop player out of the car!");
	}
	
	if(Friend == fe.Other)
	{
	    log("***** ERROR!!!!");
	}
	
	if(Friend == None || fe.Other == None || fe.Other.Pawn == None || fe.Other.Pawn.Health <= 0 || fe.Other.IsInState('Dead'))
	{
	    return true;  // abandon it?
	}
	FriendRot = Friend.Pawn.Rotation;
	FriendRot.Roll = 0;
	FriendRot.Pitch = 0;
	GetAxes(FriendRot, X, Y, Z);
	for(attempts = 0; attempts < 5; ++attempts)
	{
	    Pos = GetPossibleStartPoint(Friend.Pawn, X, Y, attempts);
	    if(!ConfirmReachability(Pos, Friend.Pawn))
	    {
	        continue;
	    }
	    Rot = BringForwardRotation(Friend, Pos);
    	if(aPlayer.Pawn.SetLocation(Pos))
    	{
    	    aPlayer.SetRotation(Rot);
    	    aPlayer.Pawn.SetPhysics(PHYS_Falling);
    	    WarpColor.R = 255;
    	    WarpColor.G = 255;
    	    WarpColor.B = 255;
    	    WarpColor.A = 255;
    	    aPlayer.myHud.QueueCinematicFade(-1.0, WarpColor);
    	    break;
    	}
    }
    
    if(attempts == 5)
	{
	    return false;
	}
    
    return true;
}

function UpdateCoopSpawn()
{
    local int i;
    
    for(i = 0; i < QueuedJoins.Length; ++i)
    {
        if(TrySpawnForCoop(QueuedJoins[i]))
        {
            QueuedJoins.Remove(i, 1);
        }
        return;
    }
}

function UpdateForwarding()
{
    local int i;
    
    for(i = 0; i < ForwardingQueue.Length; ++i)
    {
        if(TryBringForward(ForwardingQueue[i]))
        {
            ForwardingQueue.Remove(i, 1);
        }
        return;
    }
}


function SaveRespawnState(SPPlayerPawn inPawn)
{
	local int index;
	local VGPawn Pawn;
	local Inventory inv;
	local VGWeapon Weapon;
	local int w;

    log(self$" ************************* SaveRespawnState inpawn="$inPawn);
    
	Pawn = inPawn;

	if(Pawn.Controller == None)
	{
		log("SaveRespawnState failed");
		return;
	}
    index = PlayerController(Pawn.Controller).Player.SplitIndex;
	log("SaveRespawnState:"@index@Pawn.Controller);
	
	RespawnStates[index].Valid = 1;
	RespawnStates[index].WECCount = VehiclePlayer(Pawn.Controller).WECCount;
	RespawnStates[index].ShieldStrength = Pawn.ShieldStrength;
	RespawnStates[index].DashTime = Pawn.DashTime;
	RespawnStates[index].Weapons.Length = 0;
	for(inv = Pawn.Inventory; inv != None; inv = inv.Inventory)
	{
		Weapon = VGWeapon(inv);
		if(Weapon == None)
		{
			continue;
		}
		w = RespawnStates[index].Weapons.Length;
		RespawnStates[index].Weapons.Length = w + 1;
		RespawnStates[index].Weapons[w].WeaponClass = Weapon.class;
		RespawnStates[index].Weapons[w].WECLevel = Weapon.WECLevel;
		RespawnStates[index].Weapons[w].AmmoAmount = Weapon.Ammo[0].AmmoAmount;
		if(Weapon.Ammo[0].IsA('AmmoClip'))
        {
	        RespawnStates[index].Weapons[w].RemainingMagAmmo = AmmoClip(Weapon.Ammo[0]).RemainingMagAmmo;
	        RespawnStates[index].Weapons[w].MagAmount = AmmoClip(Weapon.Ammo[0]).MagAmount;
        }
	}
	
	log("RespawnStates[index].Weapons.Length:"@RespawnStates[index].Weapons.Length);
	for(w = 0; w < RespawnStates[index].Weapons.Length; ++w)
    {
        log(RespawnStates[index].Weapons[w].WeaponClass);
    }
}

function bool RestoreRespawnState(Pawn inPawn)
{
	local int index;
	local VGPawn Target;
	local VGWeapon Weapon;
	local int w;

    log(self$" ************************* RestoreRespawnState inpawn="$inPawn);

	Target = VGPawn(inPawn);
	index = PlayerController(Target.Controller).Player.SplitIndex;
	log("RestoreRespawnState:"@index@Target.Controller);

	log("RespawnStates[index].Weapons.Length:"@RespawnStates[index].Weapons.Length);
	for(w = 0; w < RespawnStates[index].Weapons.Length; ++w)
    {
        log(RespawnStates[index].Weapons[w].WeaponClass);
    }
    
	if(RespawnStates[index].Valid == 0)
	{
	    log("    Not valid!");
	    return false;
	}
	
	VehiclePlayer(Target.Controller).WECCount = RespawnStates[index].WECCount;
	Target.ShieldStrength = RespawnStates[index].ShieldStrength;
	Target.DashTime = RespawnStates[index].DashTime;
	for(w = 0; w < RespawnStates[index].Weapons.Length; ++w)
	{
		Target.GiveWeaponByClass( RespawnStates[index].Weapons[w].WeaponClass );
		Weapon = VGWeapon( Target.FindInventoryType( RespawnStates[index].Weapons[w].WeaponClass ) );
		Weapon.SetWecLevel(RespawnStates[index].Weapons[w].WecLevel);
		Weapon.Ammo[0].AmmoAmount = RespawnStates[index].Weapons[w].AmmoAmount;
		if(Weapon.Ammo[0].IsA('AmmoClip'))
		{
			AmmoClip(Weapon.Ammo[0]).RemainingMagAmmo = RespawnStates[index].Weapons[w].RemainingMagAmmo;
			AmmoClip(Weapon.Ammo[0]).MagAmount = RespawnStates[index].Weapons[w].MagAmount;
		}
	}
	
	if(Target.Weapon != None)
	{
	    Target.Weapon.Ammo[0].CheckOutOfAmmo();
    }
	
	return true;
}

function SpawnPlayerPawn(Controller aPlayer)
{
	aPlayer.PawnClass = class'PariahSP.SPPlayerPawn';
	if(Level.IsCoopSession())
	{	
	    AddToJoinQueue(PlayerController(aPlayer));
	    SetTimer(1.0, true);
	    return;
	}
	log("SpawnPlayerPawn called for controller "$aPlayer);
	super.SpawnPlayerPawn(aPlayer);
    TriggerEvent('PlayerSpawned', self, None);

    if(aPlayer.StartSpot.IsA('PlayerStart') && PlayerStart(aPlayer.StartSpot).bPrimaryStart)
    {
        aPlayer.Pawn.Health = Level.PrimaryStartHealth;
    }
}

function RestartPlayer( Controller aPlayer )
{
    bRestartLevel = false;
    Super.RestartPlayer(aPlayer);
}

event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
	local PlayerController PC;

	PC = Super.Login(Portal, Options, Error);

	// reset assassin cloaking mode
	//
	AssassinCloakingMode=ACM_CloakingAI;

	return PC;
}

function ChangeLevel(string NewLevel)
{
	local GameProfile	    gProfile;
	local string		    launchURL;
	local PlayerController  pc;

    pc = Level.GetLocalPlayerByIndex(0);
	gProfile = GetCurrentGameProfile();
	if ( gProfile != None )
	{
		if ( NewLevel == "" )
		{
	        class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
			class'GameEngine'.default.DisconnectMenuArgs = "";
			class'GameEngine'.static.StaticSaveConfig();

			pc.ConsoleCommand( "REALLYDISCONNECT" );
		}
		else
		{
		    if(gProfile.ChangeLevel(self, NewLevel))
		    {
		        UpdateGameProfile();
		    }
			launchURL = gProfile.GetNextURL(NewLevel);
			`log("RJ ChangeLevel::LaunchURL="$launchURL);
            pc.ClientTravel( launchURL, TRAVEL_Absolute, false );
		}
	}
	else
	{
		pc.ClientTravel( NewLevel, TRAVEL_Absolute, false );
	}
}

simulated function SaveGame(string description)
{
    local GameProfile gProfile;
    local PlayerController pc;
    local string saveMsg;
    local string saveMsgPt1;
    local string saveMsgPt2;
    
    gProfile = GetCurrentGameProfile();
	if(gProfile != None && gProfile.ShouldSave())
	{
	    log("SavePoint" @ description @ "will be saving shortly...");
	    
	    pc = Level.GetLocalPlayerByIndex(0);
	    if(IsOnConsole())
	    {
            saveMsg = class'XboxMsg'.default.XBOX_SAVING_CONTENT;
            UpdateTextField(saveMsg, "<CONTENT>", gProfile.GetName());
            
            // zero hour hack, LocalizedMessages don't support linefeeds for 'WWWWWWWWWWWWWWWW' style profile names
            // overflows in a few languages, opted to hack string instead of trying to squeeze the font smaller
            // this message is a TCR required message so couldn't abbreviate.
            // eg: Sauvegarde de WWWWWWWWWWWWWWW en cours. Ne pas éteindre la console Xbox.
            
            saveMsgPt1 = Left( saveMsg, InStr(saveMsg, ".") );
            saveMsgPt2 = Mid( saveMsg, InStr(saveMsg, ".") + 1 );
    	    
	        pc.myHUD.LocalizedMessage( class'SaveCheckpointMessage', 0, None, None, None, saveMsgPt1 );
	        pc.myHUD.LocalizedMessage( class'SaveCheckpointMessage', 0, None, None, None, saveMsgPt2 );
    	    
	        pc = Level.GetLocalPlayerByIndex(1);
		    if(pc != None)
		    {
			    pc.myHUD.LocalizedMessage( class'SaveCheckpointMessage', 0, None, None, None, saveMsgPt1 );
			    pc.myHUD.LocalizedMessage( class'SaveCheckpointMessage', 0, None, None, None, saveMsgPt2 );
		    }
        }
        else
        {
            saveMsg = class'SinglePlayerController'.default.SavingPlayerProfile;
	        pc.myHUD.LocalizedMessage( class'SavePlayerProfileMessage', 0, None, None, None, saveMsg );
        }
            	    
	    SetMultiTimer( SaveGameTimerSlot, 0.25, False );	
	}
	else
	{
		warn("Trying to save with NULL GameProfile! Launch from the menus to get saving to work!");
	}
}

function MultiTimer(int i)
{
	switch ( i )
	{
	    case SaveGameTimerSlot:
		    SaveProgress();
		    break;

	    default:
		    Super.MultiTimer( i );
		    break;
	}
}

function GuaranteePawn(PlayerController PC)
{
    local NavigationPoint   node;
    local NavigationPoint   bestNode;
    local float             dist;
    local Pawn              newPawn;
    
    if(PC.Pawn != None || Level.GetLivingLocalPlayer() == None)
    {
        return;
    }
    
    PC.myHUD.KillMessages();
    
    log("Must GuaranteePawn for: "@PC);
    
    // spawn behind living player, if success we're done
    if(TrySpawnForCoop(PC))
    {
        log("   - GuaranteePawn CoopSpawn success: "@PC);
        return;
    }
    
    // we MUST be alive before saving, do stuff
    PC.PawnClass = class'PariahSP.SPPlayerPawn';
	Super.SpawnPlayerPawn(PC);
	
	if(PC.Pawn == None)
	{
	    // if this fails, the living player is sitting on the spawn point so use any used save point as the spawn position!
	    dist = 9999999.9;
	    foreach AllActors(class'NavigationPoint', node)
	    {
	        if(VSize(node.Location - Level.GetLivingLocalPlayer().Pawn.Location) < dist)
	        {
	            dist = VSize(node.Location - Level.GetLivingLocalPlayer().Pawn.Location);
	            bestNode = node;
	        }
	    }
	    newPawn = Spawn(PC.PawnClass,,,bestNode.Location,bestNode.Rotation);
	    PC.Pawn.LastStartTime = Level.TimeSeconds;
        PC.Possess(newPawn);
	}
	
	QueueBringForward(PC, Level.GetLivingLocalPlayer());
	log("   - GuaranteePawn spawned at start point and queued a bringforward: "@PC);
}

function SaveProgress()
{
    local GameProfile gProfile;
    local int index;
    local Pawn p;
    local bool skipGifts;
    local StartInventory si;
    
    log(self$" really save progress!");
    
    if(	(Level.GetLocalPlayerByIndex(0) == None || Level.GetLocalPlayerByIndex(0).Pawn == None) &&
		(Level.GetLocalPlayerByIndex(1) == None || Level.GetLocalPlayerByIndex(1).Pawn == None) )
    {
        log("All players died before save timer expired (not saving)!");
        return;
    }
    
    skipGifts = false;
    foreach AllActors(class'StartInventory', si)
	{
		if ( si.bForceInventory )
		{
		    skipGifts = true;
			break;
		}
	}
	        
    for(index = 0; index < 2; ++index)
    {
        if(Level.GetLocalPlayerByIndex(index) != None)
        {
            GuaranteePawn(Level.GetLocalPlayerByIndex(index));
            p = Level.GetLocalPlayerByIndex(index).Pawn;

            if(!skipGifts)
            {
                p.GiveWeapon("VehicleWeapons.BoneSaw");
                p.GiveWeapon("VehicleWeapons.HealingTool");
            }
            
            if ( Level.GetLocalPlayerByIndex(index).PlayerReplicationInfo != None )
	        {
		        p.PlayerReplicationInfo = Level.GetLocalPlayerByIndex(index).PlayerReplicationInfo;
		        p.OwnerName = string(Level.GetLocalPlayerByIndex(index).Player.SplitIndex);
	        }
	        log("Saving pawn for:"@Level.GetLocalPlayerByIndex(index)@p.OwnerName);
        }
    }
    
    gProfile = GetCurrentGameProfile();
    assert(gProfile != None);
    
    gProfile.LogSavedData();
    
    if(gProfile.ShouldSave())
    {
        StopWatch();
        gProfile.SaveProgress();
        if(!bool(ConsoleCommand("LOADSAVE UPDATE_PROGRESS")))
        {
            warn("Cannot update save game");
        }
        StopWatch("UPDATE_PROGRESS", true);
    }
    else
    {
        log(self$" gProfile says don't save!!!");
    }
}
 
function bool PickupQuery( Pawn Other, Pickup item )
{
	// don't let bots get pickups in single player.
	if(Other == None)
	{
	    return false;
	}
	if( Other.Controller.IsA('PlayerController') || (Other.Controller.IsA('SPAIKarina') && Other.Controller.Pawn.IsA('VGVehicle'))) //cmr -- allow karina driving vehicle to get pickups
		return Super.PickupQuery(Other, item);
	return false;
}

simulated function Timer()
{
    Super.Timer();
    UpdateForwarding();
    UpdateCoopSpawn();
}

function PostLogin(PlayerController NewPlayer)
{
	local SPObjectiveList objectiveList;

    super.PostLogin(NewPlayer);
    Log("PostLogin ====");
    class'AssassinMgr'.default.CombinedAttackCount = 0;
    class'AssassinMgr'.default.iNumberOfAttacks = 0;
    //class'AssassinMgr'.default.TheChargingAssassin = none;
    class'AssassinMgr'.default.iNumberOfAssassins = 0;
    class'AssassinMgr'.default.bSpawnedAssassins = false;
    class'AssassinMgr'.default.bAllowedToAttack = true;
    class'AssassinMgr'.default.bSpawnedBoss = false;
    
	foreach AllActors( class'SPObjectiveList', objectiveList )
	{
		objectiveList.DisplayCurrentObjective( true );
		break;
	}
}

defaultproperties
{
     FearMarkerClass=Class'PariahSP.SPAvoidMarker'
     DefaultPlayerClassName="VehicleGame.VGPawn"
     HUDType="PariahSP.HudASinglePlayer"
     MapPrefix="SP"
     GameName="SinglePlayer"
     PlayerControllerClassName="PariahSP.SinglePlayerController"
     ScreenshotName="PariahMapThumbNails.Wasteland_thumbnail"
     Acronym="SP"
     bDelayedStart=False
     bSinglePlayer=True
}
