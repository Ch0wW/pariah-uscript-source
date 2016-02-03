class Weapon extends Inventory
    abstract
    native
    nativereplication;

#exec Texture Import File=Textures\Weapon.tga Name=S_Weapon Mips=Off Alpha=1

replication
{
    // Things the server should send to the client.
    reliable if( Role==ROLE_Authority )
        Ammo, FireRateAtten, bIsLoadout, LoadOutIdx;
    // Functions called by server on client
    reliable if( Role==ROLE_Authority )
        ClientWeaponSet, ClientWeaponThrown, ClientDefaultWeaponSet, ClientAdjustPlayerDamage, ClientTracerFire, ClientDoReload, ClientAddClip;

    // functions called by client on server
    reliable if( Role<ROLE_Authority )
        ServerStartFire, ServerStopFire, DoReload, ManualReload;
}

const NUM_FIRE_MODES = 2;

var() class<WeaponFire> FireModeClass[NUM_FIRE_MODES];
var() editinline WeaponFire FireMode[NUM_FIRE_MODES];
var() Ammunition Ammo[NUM_FIRE_MODES];

// animation //
var() Name IdleAnim;
var() Name RestAnim;
var() Name AimAnim;
var() Name RunAnim;
var() Name SelectAnim;
var() Name PutDownAnim;

var() float IdleAnimRate;
var() float RestAnimRate;
var() float AimAnimRate;
var() float RunAnimRate;
var() float SelectAnimRate;
var() float PutDownAnimRate;

var() Texture AmmoClipTexture;
var() IntBox AmmoClipCoords;
var() Texture BulletTexture;
var() IntBox BulletCoords;
var() float BulletsScale;
var() int BulletsStartingOffsetX;
var() int BulletsStartingOffsetY;
var() int BulletsPerRow;
var() int BulletSpaceDX;
var() int BulletSpaceDY;


// sounds //
var() Sound SelectSound;

// AI //
var()	int		BotMode; // the fire Mode currently being used for bots
var()	float	AIRating;
var()	bool	bMeleeWeapon;
var()	bool	bSniping;
var		bool	bForceTick;         //XJ so default weapons always update
var		float	CurrentRating;      // rating result from most recent RateSelf()

var() float     AutoAimFactor;      //XJ auto aim
var() float     AutoAimRangeFactor;	//XJ range for AutoAim

var(Zoom) float     ZoomFactor;             // mjm - Divide the FOV by this factor
var() bool      bOnlyTargetVehicles;	//Weapon will only auto aim to vehicles
	
// other useful stuff //
var() vector EffectOffset; // where muzzle flashes and smoke appear. replace by bone reference eventually
var() Localized string MessageNoAmmo;
var() float DisplayFOV;
var() bool bCanThrow;
var() bool bForceSwitch; // if true, this weapon will prevent any other weapon from delaying the switch to it (bomb launcher)
var() enum EWeaponClientState
{
    WS_None,
    WS_Hidden,
    WS_BringUp,
    WS_PutDown,
    WS_ReadyToFire,
	WS_Lowered
} ClientState; // this will always be None on the server

var() config byte ExchangeFireModes;

var float Hand;
var() int CrosshairIndex; // mjm - offset the material by this index * 64

// amb ---
var() config byte Priority;
// --- amb

// gam ---
var() int IconGroup; // 0 => Ungrouped. Allows for 
// --- gam

var transient bool bPendingSwitch;
var() float   FireRateAtten; // sjs

var transient float wTurn, wLookUp, wForward, wStrafe, wUp;
var transient float wTurnAdd, wLookUpAdd, wForwardAdd, wStrafeAdd, wUpAdd;
var transient vector WeaponLocation;
var transient rotator WeaponRotation;

var () float	TurnMax;
var () float	TurnMin;
var () float	TurnSpeedFactor;
var () float	MoveMax;
var () float	MoveMin;
var () float	MoveSpeedFactor;
var () float	MoveUpMax;
var () float	MoveUpMin;
var () float	MoveUpSpeedFactor;


var bool bIsVehicleWeapon; //cmr for hud nativization
var bool bAutoTarget; // flag if we allow weapons to track a target or not (only useful on vehicle weapons)
var bool bAddClip;
var bool bAmmoFromPack;	// determines whether or not the weapon can accept ammo from an ammo pack

var bool bDoMelee;
var bool bDontDrawVehicleReticle;	// vehicle weapon shouldn't have a special reticle drawn for it
var bool bHasWeaponBone;	// indicates that the weapon uses a weapon bone for rotation; needs to be kept in synch with
							// the same flag in the weaponattachment class
var bool bIndependantPitch;
var float RealPitch;

var travel bool bIsLoadout;		// when switching betwixt weapons we skip those that are not in the load out, and much fun is had by all
var travel int LoadOutIdx;		// which slot in the loadout this weapon resides in (purely for getting the menu set up properly)

simulated function EnableAutoAim()
{
	AutoAimFactor = default.AutoAimFactor;
}

simulated function DisableAutoAim()
{
	AutoAimFactor = 0.0;
}

//=================================================================
// AI functions

function float RangedAttackTime()
{
	return 0;
}

function bool RecommendRangedAttack()
{ 
	return false;
}

function bool FocusOnLeader()
{
	return false;
}

simulated function int GetWecLevel()
{
    return 0;
}

function FireHack(byte Mode);

// return true if weapon effect has splash damage (if significant)
// use by bot to avoid hurting self
// should be based on current firing Mode if active
function bool SplashDamage()
{
    return FireMode[Max(0,BotMode)].bSplashDamage;
}

// return true if weapon should be fired to take advantage of splash damage
// For example, rockets should be fired at enemy feet
function bool RecommendSplashDamage()
{
    return FireMode[Max(0,BotMode)].bRecommendSplashDamage;
}

function float GetDamageRadius()
{
    if (FireMode[Max(0,BotMode)].ProjectileClass == None)
        return 0;
    else
        return FireMode[Max(0,BotMode)].ProjectileClass.default.DamageRadius;
}

// Repeater weapons like minigun should be 0.99, other weapons based on likelihood
// of firing again right away
function float RefireRate()
{
    return FireMode[Max(0,BotMode)].BotRefireRate * FireRateAtten;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local int i;
    local string T;
    local name Anim;
    local float frame,rate;

    Canvas.SetDrawColor(0,255,0);
    Canvas.DrawText("WEAPON "$self$" Owner "$Owner$" Instigator "$Instigator);
    YPos += YL * 2;
    Canvas.SetPos(4,YPos);

	Canvas.DrawText("ATTACHMENT "$ThirdPersonActor$" Owner "$ThirdPersonActor.Owner$" Instigator "$ThirdPersonActor.Instigator);
    YPos += YL * 2;
    Canvas.SetPos(4,YPos);
	
	T = "STATE: "$GetStateName()$" Timer: "$TimerCounter;
	switch(ClientState)
	{
	case	WS_None:
			T = T$" ClientState: WS_None";
			break;
	case	WS_Hidden:
			T = T$" ClientState: WS_Hidden";
			break;
	case	WS_BringUp:
			T = T$" ClientState: WS_BringUp";
			break;
	case	WS_PutDown:
			T = T$" ClientState: WS_PutDown";
			break;
	case	WS_ReadyToFire:
			T = T$" ClientState: WS_ReadyToFire";
			break;
	}

	Canvas.DrawText(T);
    YPos += YL;
    Canvas.SetPos(4,YPos);
	/*
	T = "     STATE: "$GetStateName()$" Timer: "$TimerCounter;

    Canvas.DrawText(T);
    YPos += YL;
    Canvas.SetPos(4,YPos);
    
    if ( DrawType == DT_StaticMesh )        
        Canvas.DrawText("     StaticMesh "$GetItemName(string(StaticMesh))$" AmbientSound "$AmbientSound);
    else 
        Canvas.DrawText("     Mesh "$GetItemName(string(Mesh))$" AmbientSound "$AmbientSound);
    YPos += YL;
    Canvas.SetPos(4,YPos);
    */
	if ( Mesh != None )
    {
        // mesh animation
        GetAnimParams(0,Anim,frame,rate);
        T = "AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
        if ( bAnimByOwner )
            T= T$" Anim by Owner";
        
        Canvas.DrawText(T);
        YPos += YL;
        Canvas.SetPos(4,YPos);
    }
	
    for ( i=0; i<NUM_FIRE_MODES; i++ )
    {
        if ( FireMode[i] == None )
        {
            //Canvas.DrawText("NO FIREMODE "$i);
            //YPos += YL;
            //Canvas.SetPos(4,YPos);
        }
        else
            FireMode[i].DisplayDebug(Canvas,YL,YPos);
        
        if ( Ammo[i] == None )
        {
            //Canvas.DrawText("NO AMMO "$i);
            //YPos += YL;
            //Canvas.SetPos(4,YPos);
        }
        else
            Ammo[i].DisplayDebug(Canvas,YL,YPos);
    }
}

simulated function Weapon RecommendWeapon( out float rating )
{
    local Weapon Recommended;
    local float oldRating;

    if( (Instigator == None) || (Instigator.Controller == None) )
        rating = -2;
    else
        rating = RateSelf() + Instigator.Controller.WeaponPreference(self);

    if ( inventory != None )
    {
        Recommended = inventory.RecommendWeapon(oldRating);
        if ( (Recommended != None) && (oldRating > rating) )
        {
            rating = oldRating;
            return Recommended;
        }
    }
    return self;
}

function SetAITarget(Actor T);

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	if ( FRand() < 0.5 )
		return 1;
	return 0;
}


function bool BotFire(bool bFinished, optional name FiringMode)
{
    local int newmode;
    local Controller C;

    C = Instigator.Controller;
	newMode = BestMode();

	if ( newMode == 0 )
	{
		C.bFire = 1;
		C.bAltFire = 0;
	}
	else
	{
		C.bFire = 0;
		C.bAltFire = 1;
	}

	if ( bFinished )
		return true;

    if ( FireMode[BotMode].bIsFiring )
		StopFire(BotMode);
	
    if ( !ReadyToFire(newMode) || ClientState != WS_ReadyToFire )
		return false; 

    StartFire(NewMode);
    BotMode = NewMode;
    return true;
}


// this returns the actual projectile spawn location or trace start
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return FireMode[Max(0,BotMode)].GetFireStart(X,Y,Z);
}

// need to figure out modified rating based on enemy/tactical situation
simulated function float RateSelf()
{
    if ( !HasAmmo() )
        CurrentRating = -2;
	else
		CurrentRating = Instigator.RateWeapon(self);
		
    // log("RateSelf: "@self@CurrentRating);
		
	return CurrentRating;
}

function float GetAIRating()
{
	return AIRating;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
    return 0.0;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
    return 0.0;
}

// return true if recommend jumping while firing to improve splash damage (by shooting at feet)
// true for R.L., for example
function bool SplashJump()
{
    return FireMode[Max(0,BotMode)].bSplashJump;
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    local float Dist, CheckDist;
    local vector HitLocation, HitNormal,X,Y,Z, projStart;
    local actor HitActor;
    local int m;
	local bool bInstantHit;

    if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

    // check that target is within range
    Dist = VSize(Instigator.Location - Other.Location);
    
	if ( ((FireMode[0]) == None || (Dist > FireMode[0].MaxRange())) && ((FireMode[1] == None) || (Dist > FireMode[1].MaxRange())) )
        return false;

    // check that can see target
    if ( !Instigator.Controller.LineOfSightTo(Other) )
        return false;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
		if( FireMode[m] == None)
			continue;
		if ( FireMode[m].bInstantHit )
			bInstantHit = true;
		else
		{
			CheckDist = FMax(CheckDist, 0.5 * FireMode[m].ProjectileClass.Default.Speed);
	        CheckDist = FMax(CheckDist, 300);
	        CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
		}
	}
    // check that would hit target, and not a friendly
    GetAxes(Instigator.Controller.Rotation, X,Y,Z);
    projStart = GetFireStart(X,Y,Z);
    if ( bInstantHit )
        HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);
    else
    {
        // for non-instant hit, only check partial path (since others may move out of the way)
        HitActor = Trace(HitLocation, HitNormal, 
                projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location), 
                projStart, true);
	}

    if ( (HitActor == None) || (HitActor == Other) || (Pawn(HitActor) == None) 
		|| (Pawn(HitActor).Controller == None) || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller) )
        return true;

    return false;
}


//=================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    CreateFireModes();
}

simulated function CreateFireModes()
{
    local int m;
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireModeClass[m] != None)
        {
			if(FireMode[m] == none)
				FireMode[m] = Spawn(FireModeClass[m],self);
			FireMode[m].ThisModeNum = m;
			FireMode[m].Weapon = self;
			FireMode[m].Instigator = Instigator;
			//log("XJ: FireModeClass: "$FireModeClass[m]$" Weapon: "$self$" Instigator: "$Instigator);
		}
    }
}

simulated function Destroyed()
{
    local int m;

    AmbientSound = None;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != None)
        {
            FireMode[m].Weapon = None;
            FireMode[m].Destroy();
            FireMode[m] = None;
        }
        if (Ammo[m] != None)
        {
            Ammo[m].Destroy();
            Ammo[m] = None;
        }
    }
    Super.Destroyed();
}

simulated function Reselect()
{
}

simulated event RenderOverlaysPostFXStage( Canvas Canvas, Object Stage )
{
}

simulated event RenderOverlays( Canvas Canvas )
{
    local int m;
    local PlayerController PC;
    local float ZoomMult;

    if ((Hand < -1.0) || (Hand > 1.0))
        return;

    if (Instigator == None)
        return;

    // draw muzzleflashes/smoke for all fire modes so idle state won't
    // cause emitters to just disappear
    Canvas.DrawActor(None, false, true); // amb: Clear the z-buffer here

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != None)
        {
            FireMode[m].DrawMuzzleFlash(Canvas);
        }
    }
    
    // sjs - calc zoom mult for nicer weapon drawing in the face of zoom ins.
    ZoomMult = 1.0;
    PC = PlayerController(Instigator.Controller);
    if( PC != None )
    {
        ZoomMult = PC.FOVAngle / PC.DefaultFOV;
    }    

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) + WeaponLocation );
    SetRotation( Instigator.GetViewRotation() + WeaponRotation);

    if (Canvas.SizeX < 640)
        LODBias = 0.0;
    else
        LODBias = 1.0;

    bDrawingFirstPerson = true;
    Canvas.DrawActor(self, false, false, DisplayFOV * ZoomMult);
    bDrawingFirstPerson = false;
}

simulated function SetHand(float InHand)
{
    Hand = InHand;
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

simulated function vector GetEffectStart()
{
    local Vector X,Y,Z;

    // jjs - this function should actually never be called in third person views
    // any effect that needs a 3rdp weapon offset should figure it out itself

    // 1st person
    if (Instigator.IsFirstPerson())
    {
        GetViewAxes(X, Y, Z);
        return (Instigator.Location + 
            Instigator.CalcDrawOffset(self) + 
            EffectOffset.X * X + 
            EffectOffset.Y * Y + 
            EffectOffset.Z * Z); 
    }
    // 3rd person
    else
    {
        GetViewAxes(X, Y, Z);
        return (Instigator.Location + 
            Instigator.EyeHeight*Vect(0,0,0.5) + 
            Vector(Instigator.Rotation) * 40.0); 
    }
}

simulated function IncrementFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        WeaponAttachment(ThirdPersonActor).FiringMode = Mode;
        WeaponAttachment(ThirdPersonActor).FlashCount++;
        WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
    }
}

simulated function ZeroFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        WeaponAttachment(ThirdPersonActor).FiringMode = Mode;
        WeaponAttachment(ThirdPersonActor).FlashCount = 0;
        WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
    }
}

simulated function Weapon WeaponChange( byte F, optional Inventory LastCheck )
{   
    local Weapon newWeapon;

    if ( InventoryGroup == F )
    {
        if ( !HasAmmo() )
        {
            if ( Inventory == None )
                newWeapon = None;
            else
                newWeapon = Inventory.WeaponChange(F, LastCheck);

            if ( (newWeapon == None) && Instigator.IsHumanControlled() )
            {
                Instigator.ClientMessage( ItemName$MessageNoAmmo );
            }

            return newWeapon;
        }       
		else
            return self;
    }
    else if ( Inventory == None )
        return None;
    else
        return Inventory.WeaponChange(F, LastCheck);
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
            if ( InventoryGroup == CurrentWeapon.InventoryGroup )
            {
                if ( (GroupOffset < CurrentWeapon.GroupOffset)
                    && (GroupOffset > CurrentChoice.GroupOffset) )
                    CurrentChoice = self;
            }
            else if ( GroupOffset > CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }
        else if ( InventoryGroup > CurrentChoice.InventoryGroup )
        {
            if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
                && (InventoryGroup < CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
    }
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
            if ( InventoryGroup == CurrentWeapon.InventoryGroup )
            {
                if ( (GroupOffset > CurrentWeapon.GroupOffset)
                    && (GroupOffset < CurrentChoice.GroupOffset) )
                    CurrentChoice = self;
            }
            else if ( GroupOffset < CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }

        else if ( InventoryGroup < CurrentChoice.InventoryGroup )
        {
            if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
                && (InventoryGroup > CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;

    }
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}


function HolderDied()
{
    local int m;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != none && FireMode[m].bIsFiring)
        {
            StopFire(m);
            if (FireMode[m].bFireOnRelease)
                FireMode[m].ModeDoFire();
			AmbientSound=none;
        }
    }
}

simulated function bool CanThrow()
{
    return (bCanThrow && (ClientState == WS_ReadyToFire || Level.NetMode == NM_DedicatedServer));
}

function DropFrom(vector StartLocation)
{
    local int m;
	local Pickup Pickup;

    if (!bCanThrow || !HasAmmo())
        return;

    ClientWeaponThrown();

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != none && FireMode[m].bIsFiring)
            StopFire(m);
    }

	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);	
	}	

	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
		Pickup.Velocity = Velocity;
    	Pickup.InitDroppedPickupFor(self);
        if (Instigator.Health > 0)
            WeaponPickup(Pickup).bThrown = true;
    }

    Destroy();
}

function RemoveFrom()
{
	local int m;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != none && FireMode[m].bIsFiring)
            StopFire(m);
    }

	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);	
		Instigator.DeleteInventory(self);
	}	

	SetDefaultDisplayProperties();
	Instigator = None;
	StopAnimating();
	GotoState('');
}

simulated function ClientTracerFire(vector HitLocation)
{
}

simulated function ClientWeaponThrown()
{
    local int m;

    AmbientSound = None;

    if( Level.NetMode != NM_Client )
        return;

    Instigator.DeleteInventory(self);
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (Ammo[m] != None)
            Instigator.DeleteInventory(Ammo[m]);
    }
}

// for single player use - put weapon in loadout if there's a free spot (otherwise, happily do nothing!  nothing I say!)
function PlaceInLoadout(Pawn JustSomePawn)
{
	local bool bSinglePlayer;
	local Inventory Inv;
	local int loadcount;

	// set initial loadout flag hrmmm....
	bSinglePlayer = (Level != none && Level.Game != none && Level.Game.bSinglePlayer);
	if(!bSinglePlayer) {
		bIsLoadout = true;
	}
	else {
		// in single player games, weapons aren't loadout unless there's less than two loadout already
		for(Inv = JustSomePawn.Inventory; Inv != none; Inv = Inv.Inventory) {
			if(Inv.IsA('Weapon') && Weapon(Inv).bIsLoadout)
				loadcount++;
		}

//		log("-> Found "$loadcount$" weapon(s) in loadout already");
		if(loadcount < 2 && !bIsLoadout && !IsA('HealingTool') && !IsA('VirusPower') && !IsA('BoneSaw') ) {
			bIsLoadout = true;
			LoadOutIdx = loadcount;
//			log("   "$self$" added to loadout out, slot "$LoadOutIdx);
		}
	}
}

function GiveTo(Pawn Other, optional Pickup Pickup, optional bool bNoInventory)
{
    local int m;
    local weapon w;
    local bool bPossiblySwitch;

    Instigator = Other;

    w = Weapon(Instigator.FindInventoryType(class));
    if (w == None)
    {
        Super.GiveTo(Other,Pickup,bNoInventory);
		PlaceInLoadout(Other);
        bPossiblySwitch = true;
    }
    else
    {
        if (!W.HasAmmo())
            bPossiblySwitch = true;
    }

    if ( PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).bNeverSwitchOnPickup )
        bPossiblySwitch = false;

    if ( Pickup == None )
        bPossiblySwitch = true;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != None)
        {
            FireMode[m].Instigator = Instigator;

            if (WeaponPickup(Pickup) != None)
                FireMode[m].DroppedAmmoCount = WeaponPickup(Pickup).AmmoAmount[m];

            GiveAmmo(m);
        }
    }
	//XJ
	if(bNoInventory)
	{
		ClientDefaultWeaponSet();
		bForceTick = true;
		bPossiblySwitch = false;
		return;
	}

    ClientWeaponSet(bPossiblySwitch);
}

simulated function ClientDefaultWeaponSet()
{
	local int Mode;

	Instigator = Pawn(Owner);

	if( Instigator == None )
    {
        GotoState('PendingClientDefaultWeaponSet');
        return;
    }

    for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
    {
        if( FireModeClass[Mode] != None )
        {
            if( ( FireMode[Mode] == None ) || ( FireMode[Mode].AmmoClass != None ) && ( Ammo[Mode] == None ) )
            {
                GotoState('PendingClientDefaultWeaponSet');
                return;
            }
		}
		if(FireMode[Mode] != none)
			FireMode[Mode].Instigator = Instigator;
    }

	ClientState = WS_Hidden;
	bForceTick = true;
	GotoState('Hidden');

	if( Level.NetMode == NM_DedicatedServer )
		return;

	BringUp();
}

function GiveAmmo(int m)
{
    local bool bJustSpawnedAmmo;
    local int addAmount;

    if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
    {
        Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
    
        if ( Ammo[m] == None )
        {
            Ammo[m] = Spawn(FireMode[m].AmmoClass, FireMode[m]);
            Instigator.AddInventory(Ammo[m]);
            bJustSpawnedAmmo = true;
        }

        if (bJustSpawnedAmmo || m == 0)
        {
            if (FireMode[m].DroppedAmmoCount > 0)
            {
                addAmount = FireMode[m].DroppedAmmoCount;
                FireMode[m].DroppedAmmoCount = 0;
            }
            else
            {
                addAmount = Ammo[m].InitialAmount;
            }
            
            Ammo[m].AddAmmo(addAmount);
            Ammo[m].GotoState('');
        }
    }
}   

simulated function ClientWeaponSet(bool bPossiblySwitch)
{
    local int Mode;

    Instigator = Pawn(Owner);

    bPendingSwitch = bPossiblySwitch;

    if( Instigator == None )
    {
        GotoState('PendingClientWeaponSet');
        return;
    }

    for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
    {
        if( FireModeClass[Mode] != None )
        {
            if( ( FireMode[Mode] == None ) || ( FireMode[Mode].AmmoClass != None ) && ( Ammo[Mode] == None ) )
            {
                GotoState('PendingClientWeaponSet');
                return;
            }
		}
		if(FireMode[Mode] != none)
			FireMode[Mode].Instigator = Instigator;
    }
 
    ClientState = WS_Hidden;
    GotoState('Hidden');

    if( Level.NetMode == NM_DedicatedServer || !Instigator.IsHumanControlled() )
        return;

    if( Instigator.Weapon == self || Instigator.PendingWeapon == self ) // this weapon was switched to while waiting for replication, switch to it now
    {
        if (Instigator.PendingWeapon != None)
            Instigator.ChangedWeapon();
        else
            BringUp();
        return;
    }

    if( Instigator.PendingWeapon != None && Instigator.PendingWeapon.bForceSwitch )
        return;

    if( Instigator.Weapon == None )
    {
        Instigator.PendingWeapon = self;
        Instigator.ChangedWeapon();
    }
    else if ( bPossiblySwitch )
    {
        if ( Instigator.PendingWeapon != None )
        {
            if ( RateSelf() > Instigator.PendingWeapon.RateSelf() )
            {
                Instigator.PendingWeapon = self;
                Instigator.Weapon.PutDown();
            }
        }
        else if ( RateSelf() > Instigator.Weapon.RateSelf() )
        {
            Instigator.PendingWeapon = self;
            Instigator.Weapon.PutDown();
        }
    }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    if (ClientState == WS_Hidden)
    {
		if(PrevWeapon != none)
		{
			PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);

			if (Instigator.IsLocallyControlled())
			{
				if (HasAnim(SelectAnim))
					PlayAnim(SelectAnim, SelectAnimRate, 0.0);
			}
		}
        ClientState = WS_BringUp;
        SetTimer(0.3, false);
    }
}

simulated function bool PutDown()
{
    local int Mode;

    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
    {
        if (Instigator.PendingWeapon == None || !Instigator.PendingWeapon.bForceSwitch)
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring)
                    return false;
            }
        }

        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                    ClientStopFire(Mode);
            }

            if (ClientState != WS_BringUp && HasAnim(PutDownAnim))
                PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
        }

        ClientState = WS_PutDown;

        SetTimer(0.3, false);
    }
    return true; // return false if preventing weapon switch
}

simulated function LowerWeapon()
{
    local int Mode;

	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                    ClientStopFire(Mode);
            }

            if (ClientState != WS_BringUp && HasAnim(PutDownAnim))
                PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
        }
        ClientState = WS_Lowered;
	}
}

simulated function RaiseWeapon()
{
    if (ClientState == WS_Lowered)
    {
		PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);
		if (Instigator.IsLocallyControlled())
		{
			if (HasAnim(SelectAnim))
				PlayAnim(SelectAnim, SelectAnimRate, 0.0);
		}
        //ClientState = WS_BringUp;
		if(Instigator.PendingWeapon !=none)
			Timer();
		else
	        SetTimer(0.3, false);
    }
}

/*
simulated function Tick(float dt)
{
    if ((FireMode[0].bIsFiring || FireMode[1].bIsFiring) && Instigator.Weapon != self)
    {
        log(self@"firing while not active");
    }
}*/

simulated function Fire(float F)
{
}

simulated function AltFire(float F)
{
}

simulated event WeaponTick(float dt) // only called on currently held weapon
{
	local rotator	WeaponRot;
	//local float		TurnMax, TurnMin, TurnSpeedFactor;
	//local float		MoveMax, MoveMin, MoveSpeedFactor;

//	local int		Mode;

	if(Instigator.Controller.IsA('PlayerController') && Instigator.IsLocallyControlled())
	{
		// Rotation adjustments
		//Yaw
		wTurnAdd = CalcMovementValues(dt, wTurnAdd, wTurn, TurnMax, TurnMin, TurnSpeedFactor, false, true);
		//Pitch
		wLookUpAdd = CalcMovementValues(dt, wLookUpAdd, wLookUp, TurnMax, TurnMin, TurnSpeedFactor, false, true);

		//Location adjustments
		// forward (x)
		wForwardAdd = CalcMovementValues(dt, wForwardAdd, wForward, MoveMax, MoveMin, MoveSpeedFactor, true);
		// strafe (y)
		wStrafeAdd = CalcMovementValues(dt, wStrafeAdd, wStrafe, MoveMax, MoveMin, MoveSpeedFactor, true);
		// up (z) doesn't work
		wUpAdd = CalcMovementValues(dt, wUpAdd, wUp, MoveUpMax, MoveUpMin, MoveUpSpeedFactor, true);
//		wForwardAdd = 0;
//		wStrafeAdd = 0;
//		wUpAdd = 0;

		// change location offset values to world space
		WeaponRot = Instigator.GetViewRotation();
		WeaponLocation.X = -wForwardAdd*0.85;
		WeaponLocation.Y = -wStrafeAdd*0.85;
		WeaponLocation.Z = -wUpAdd*0.8;
		WeaponLocation = WeaponLocation >> WeaponRot;
		//set the rotation offset
		WeaponRotation.Yaw = wTurnAdd;
		WeaponRotation.Pitch = wLookUpAdd;
		WeaponRotation.Roll = 0;
	}
	//Check zoom stuff and break zoom if necessary
//	if( Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).bzoomed && (wForward != 0 || wStrafe != 0) )
//	{
//		PlayerController(Instigator.Controller).ClientEndZoom();
//		for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
//      {
//          if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
//              ClientStopFire(Mode);
//      }
//	}

//	log("Ya!");
}

simulated function SetMovementValues(float aTurn, float aLookUp, float aForward, float aStrafe, float aUp)
{
	wTurn = aTurn;
	wLookUp = aLookUp;
	wForward = aForward;
	wStrafe = aStrafe;
	wUp = aUp;
}

simulated function float CalcMovementValues(float dt, float currentVal, float dir, float Max, float Min, float SpeedFactor, optional bool bInverse, optional bool bNonLinear)
{
	local float InterpVal;
	local float	MidVal;
	local float Alpha;
	local float MoveDiff;

	MoveDiff = Abs(currentVal - dir);
	SpeedFactor = 6;
	if(bNonLinear)
	{
		// ... this block of code is just wrong...

		// get the mid value, well almost in this case
		MidVal = Max / 2.0;
		// get a 1 to 0 value where 0 is the mid point and 1 the extremes
		// add on a fudge value so the squre doesn't reduce decimals too much
		Alpha = Abs((Abs(currentVal) - MidVal) / MidVal) + 0.5;
		// square and invert the values, also make sure Alpha is always positive
		Alpha = (-1 * Square(Alpha)) + Alpha + 1.8;
		
		InterpVal = /*Max*/ MoveDiff * dt * SpeedFactor * Alpha;
	}
	else
	{
		InterpVal = Max * dt * SpeedFactor;
	}

	if((dir > 0 && !bInverse) || (dir < 0 && bInverse))
	{
		if(currentVal < Max)
			currentVal += InterpVal;
		else
			currentVal = Max;
	}
	else if((dir < 0 && !bInverse) || (dir > 0 && bInverse))
	{
		if(currentVal > -Max)
			currentVal -= InterpVal;
		else
			currentVal = -Max;
	}
	else
	{
		if(currentVal > 0)
		{
			currentVal -= InterpVal;
			if(currentVal < Min)
				currentVal = 0.0;
		}
		else if(currentVal < 0)
		{
			currentVal += InterpVal;
			if(currentVal > -Min)
				currentVal = 0.0;
		}
	}
	
	// do a last bit of sanity checking to make sure currentVal is never outside of the allowable range
	if(currentVal > Max)
		currentVal = Max;
	if(currentVal < -Max)
		currentVal = -Max;

	return currentVal;
}

// amb ---
simulated function OutOfAmmo()
{
    if (!Instigator.IsLocallyControlled())
        return;

    if (HasAmmo())
        return;

    DoAutoSwitch();
}

simulated function DoAutoSwitch()
{
    Instigator.Controller.SwitchToBestWeapon();
}
// --- amb

//// client only ////
simulated event ClientStartFire(int Mode)
{
//	log("ClientStartFire");
    if (!Pawn(Owner).Controller.CanFire())
        return;

//	log(" - canfire!");
        
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            //Log("ClientStartFire"@Level.TimeSeconds);
            ServerStartFire(Mode);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

simulated event ClientStopFire(int Mode)
{
//	log("ClientStopFire");
    if (Role < ROLE_Authority)
    {
        //Log("ClientStopFire"@Level.TimeSeconds);
        StopFire(Mode);
    }
    ServerStopFire(Mode);    
}

//// server only ////
event ServerStartFire(byte Mode)
{
//	log("ServerStartFire");
    if (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime)
    {
        if (!FireMode[Mode].bIsFiring)
        {
//            log(" - Start Delayed");
            FireMode[Mode].bServerDelayStartFire = true;
        }
    }
    else if (StartFire(Mode))
    {
        //Log("ServerStartFire"@Level.TimeSeconds);
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
//		log(" - StartFireTime = "$Level.TimeSeconds);
    }
}

function ServerStopFire(byte Mode)
{
//	log("ServerStopFire");
    // if a stop was received on the same frame as a start then we need to delay the stop for one frame
    if (FireMode[Mode].bServerDelayStartFire || FireMode[Mode].ServerStartFireTime == Level.TimeSeconds)
    {
//        log(" - Stop Delayed");
        FireMode[Mode].bServerDelayStopFire = true;
    }
    else
    {
        //Log("ServerStopFire"@Level.TimeSeconds);
        StopFire(Mode);
//		log(" - Stop now: "$Level.TimeSeconds);
    }
}

simulated function bool ReadyToFire(int Mode)
{
    local int alt;

    if (Mode == 0) 
        alt = 1; 
    else 
        alt = 0;

	if(FireMode[alt] != none)
	{
		if ( (FireMode[alt].bModeExclusive && FireMode[alt].bIsFiring)	
			|| !FireMode[Mode].AllowFire()
			|| (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime) )
		{
			return false;
		}
	}
	else if(!FireMode[Mode].AllowFire() || (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime))
	{
		return false;
	}
	return true;
}

//Note: Called for client & server
simulated function bool StartFire(int Mode)
{
    local int alt;

//	log("StartFire");

    if (!ReadyToFire(Mode))
        return false;

//	log(" - ReadyToFire");

    if (Mode == 0) 
        alt = 1; 
    else 
        alt = 0;

    FireMode[Mode].bIsFiring = true;
    FireMode[Mode].NextFireTime = Level.TimeSeconds + FireMode[Mode].PreFireTime;

    if (FireMode[alt] != none && FireMode[alt].bModeExclusive)
    {
        // prevents rapidly alternating fire modes
        FireMode[Mode].NextFireTime = FMax(FireMode[Mode].NextFireTime, FireMode[alt].NextFireTime);
    }

    if (Instigator != none && Instigator.IsLocallyControlled())
    {
        if (FireMode[Mode].PreFireTime > 0.0 || FireMode[Mode].bFireOnRelease)
        {
            FireMode[Mode].PlayPreFire();
        }
        FireMode[Mode].FireCount = 0;
    }
    return true;
}


simulated event StopFire(int Mode)
{
//	log("StopFire");
    if (Instigator != none && Instigator.IsLocallyControlled() && !FireMode[Mode].bFireOnRelease)
    {
        FireMode[Mode].PlayFireEnd();
    }
    FireMode[Mode].bIsFiring = false;
    FireMode[Mode].StopFiring();
//    if (!FireMode[Mode].bFireOnRelease)
        ZeroFlashCount(Mode);
}

simulated function StopFireEffects()
{
	if(FireMode[0] != none) {
		ClientStopFire(0);
		StopFire(0);
	}

	if(FireMode[1] != none) {
		ClientStopFire(1);
		StopFire(1);
	}
}

simulated function Timer()
{
	local int Mode;
	
    if (ClientState == WS_BringUp)
    {
		for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
		{
			if(FireMode[Mode] != none)
				FireMode[Mode].InitEffects();
		}
        PlayIdle();
        ClientState = WS_ReadyToFire;
    }
    else if (ClientState == WS_PutDown)
    {
		if ( Instigator.PendingWeapon == None )
		{
			PlayIdle();
			ClientState = WS_ReadyToFire;
		}
		else
		{
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
			{
				if(FireMode[Mode] != none)
					FireMode[Mode].DestroyEffects();
			}
		}
    }
	else if (ClientState == WS_Lowered)
	{
		if ( Instigator.PendingWeapon == None )
		{
			PlayIdle();
			ClientState = WS_ReadyToFire;
		}
		else
		{
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
			{
				if(FireMode[Mode] != none)
					FireMode[Mode].DestroyEffects();
			}
		}
	}
}


simulated function bool IsFiring() // called by pawn animation, mostly
{
    return  ( ClientState == WS_ReadyToFire && ((FireMode[0] != none && FireMode[0].IsFiring()) || (FireMode[1] != none && FireMode[1].IsFiring())) );
}

function bool IsRapidFire() // called by pawn animation
{
    if (FireMode[1] != None && FireMode[1].bIsFiring) 
        return FireMode[1].bPawnRapidFireAnim;
    else if (FireMode[0] != None)
        return FireMode[0].bPawnRapidFireAnim;
    else
        return false;
}

function bool IsAimed() // called by pawn animation
{
    return true;
}

function ConsumeAmmo(int Mode, float load)
{
    if (Ammo[Mode] != None)
        Ammo[Mode].UseAmmo(int(load));
}

// amb ---
simulated function bool HasAmmo()
{
    return ( (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
          || (Ammo[1] != None && FireMode[1] != None && Ammo[1].AmmoAmount >= FireMode[1].AmmoPerFire) );

    /*return (FireMode[Mode] != None && 
            Ammo[Mode] != None &&
            Ammo[Mode].AmmoAmount >= FireMode[Mode].AmmoPerFire);*/
}
// --- amb


// called every time owner takes damage while holding this weapon - used by link gun and shield gun
function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, 
                             out Vector Momentum, class<DamageType> DamageType)
{
}

simulated function ClientAdjustPlayerDamage(int Damage)
{
}

// called every time owner picks up health or shield - used by link gun
function bool DistributeHealth(out int HealAmount, int HealMax)
{
    return false;
}
function bool DistributeShield(out int ShieldAmount, int ShieldMax)
{
    return false;
}

simulated function StartBerserk()
{
    if (FireMode[0] != None)
        FireMode[0].StartBerserk();
    if (FireMode[1] != None)
        FireMode[1].StartBerserk();
}

simulated function StopBerserk()
{
    if (FireMode[0] != None)
        FireMode[0].StopBerserk();
    if (FireMode[1] != None)
        FireMode[1].StopBerserk();
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        if (FireMode[0] != none && anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
        {
            PlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        }
        else if (FireMode[1] != none && anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
        {
            PlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        }
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}

simulated function PlayIdle()
{
    LoopAnim(IdleAnim, IdleAnimRate, 0.2);
}

state PendingClientWeaponSet
{
    simulated function Timer()
    {
        if ( Pawn(Owner) != None )
            ClientWeaponSet(bPendingSwitch);
    }

    simulated function BeginState()
    {
        SetTimer(0.05, true);
    }

    simulated function EndState()
    {
        SetTimer(0.0, false);
    }
}

state PendingClientDefaultWeaponSet
{
    simulated function Timer()
    {
        if ( Pawn(Owner) != None )
            ClientDefaultWeaponSet();
    }

    simulated function BeginState()
    {
        SetTimer(0.05, true);
    }

    simulated function EndState()
    {
        SetTimer(0.0, false);
    }
}

state Hidden
{
}

function Actor GetHitEffectOwner()
{
    return None;
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int AmmoDrain )
{
    return false;
}

function DoReflectEffect(int Drain)
{

}

static function bool CollectStats()
{
    return true;
}

// amb --- 
function bool HandlePickupQuery( pickup Item )
{
    local WeaponPickup wpu;

	if (class == Item.InventoryType)
    {
        if(Ammo[0] != None && Ammo[0].AmmoAmount == Ammo[0].MaxAmmo) // sjs
        {
            return(true);
        }
        wpu = WeaponPickup(Item);
        if (wpu != None)
            return !wpu.AllowRepeatPickup();
        else
            return false;
    }

    if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

static simulated function StaticPreLoadData()
{
	Super.StaticPreLoadData();
    PreLoad(default.IconMaterial);
}
// --- amb

simulated function StopBlur()
{
}

simulated function bool CanOverheat()
{
	if(Pawn(Owner) == none)
		return false;

	return !Pawn(Owner).bNoOverheat;
}

// reload the weapon
simulated function DoReload()
{
	if(!IsInState('Reload') ) {
		GotoState('Reload');
		StopFireEffects();
		if(Level.NetMode != NM_Client) {
//			log("---> attempting to replicate reload");
			ClientDoReload();
		}
	}
}

simulated function ClientDoReload()
{
	if(Level.NetMode == NM_Client) {
//		log("---> reload replicated, yay!");
//		FireMode[0].PlayFiring();	// make sure the fire animation gets played
		GotoState('Reload');
	}
}

simulated function CompletedReload()
{
    if(Ammo[0] != None)
    {
        Ammo[0].CompletedReload();
    }
}

simulated function ClientAddClip()
{
	bAddClip = true;
	if(Level.NetMode == NM_Client)
		GotoState('Reload');
}

// this needs to be overridden by weapons for it to do anything useful
function SwitchFireMode()
{
}

simulated function ManualReload()
{
}

simulated function bool CanReload()
{
    return(true);    
}

// handle an EMP (plasma gun) hit - needs to be overridden to do anything useful
simulated function EMPHit(bool bEnhanced)
{
}

simulated function Actor GetSeekTarget(int index)
{
    return(None);
}

simulated function Vector GetSeekPosition()
{
    local Vector V;
    Assert(false);
    return(V);
}

simulated function bool FilterBlindness( Name BlindType )
{
    return(false);
}

defaultproperties
{
     LoadOutIdx=-1
     IdleAnimRate=1.000000
     RestAnimRate=1.000000
     AimAnimRate=1.000000
     RunAnimRate=1.000000
     SelectAnimRate=1.500000
     PutDownAnimRate=1.500000
     AIRating=0.500000
     CurrentRating=0.500000
     AutoAimRangeFactor=1.000000
     DisplayFOV=90.000000
     FireRateAtten=1.000000
     TurnMax=900.000000
     TurnMin=30.000000
     TurnSpeedFactor=2.000000
     MoveMax=3.000000
     MoveSpeedFactor=4.000000
     MoveUpMax=3.000000
     MoveUpSpeedFactor=8.000000
     IdleAnim="Idle"
     RestAnim="rest"
     AimAnim="Aim"
     RunAnim="Run"
     SelectAnim="Up"
     PutDownAnim="Down"
     MessageNoAmmo=" has no ammo"
     bCanThrow=True
     bAmmoFromPack=True
     AttachmentClass=Class'Engine.WeaponAttachment'
     InventoryGroup=1
     ScaleGlow=1.500000
     NetPriority=3.000000
     DrawType=DT_Mesh
     AmbientGlow=20
     MaxLights=6
}
