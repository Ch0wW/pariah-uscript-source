//=============================================================================
// Pickup items.
//
// Pickup is the base class of actors that when touched by an appropriate pawn, 
// will create and place an Inventory actor in that pawn's inventory chain.  Each 
// pickup class has an associated inventory class (its InventoryType).  Pickups are 
// placed by level designers.  Pickups can only interact with pawns when in their 
// default Pickup state.  Pickups verify that they can give inventory to a pawn by 
// calling the GameInfo's PickupQuery() function.  After a pickup spawns an inventory 
// item for a pawn, it then queries the GameInfo by calling the GameInfo's 
// ShouldRespawn() function about whether it should remain active, enter its Sleep 
// state and later become active again, or destroy itself.
//
// When navigation paths are built, each pickup has an InventorySpot (a subclass 
// of NavigationPoint) placed on it and associated with it 
// (the Pickup's MyMarker== the InventorySpot, 
// and the InventorySpot's markedItem == the pickup).     
//
//=============================================================================
class Pickup extends Actor
	native
	abstract
	placeable
	native
	nativereplication;

//-----------------------------------------------------------------------------
// AI related info.

var  float		  MaxDesireability;		// Maximum desireability this item will ever have.
var	  InventorySpot MyMarker;
var	  NavigationPoint PickupCache;		// used for dropped pickups
var() class<Inventory> InventoryType;
var() bool		bInstantRespawn;	  // Can be tagged so this item respawns instantly.
var	  bool		bOnlyReplicateHidden;	// only replicate changes in bHidden (optimization for level pickups)
var(Display) bool bAmbientGlow;		  // Whether to glow or not.
var		bool	bDropped;
var		bool	bPredictRespawns;	  // high skill bots may predict respawns for this item
var() float     RespawnTime;          // Respawn after this time, 0 for instant.
var() bool		bPickupOnce;			//should only be picked up once
var() float		DroppedLifeTime;

var() localized string PickupMessage; // Human readable description when picked up.
var() localized string CantPickupMessage;   // You have it already! Can't pick it up! -mjm
var() sound PickupSound;
var() string PickupForce;  // jdf
//var() xPickUpBase PickUpBase;          // Pick-up base which spawned this pickup. - jij
var() class<xEmitter> RespawnFXClass;
//-----------------------------------------------------------------------------
// Ambient glow related info.

native final function AddToNavigation();			// cache dropped inventory in navigation network
native final function RemoveFromNavigation();

simulated function PostBeginPlay()
{
    if (InventoryType != None)
        InventoryType.static.Precache();
        
    Super.PostBeginPlay();
    if (IsOnConsole())
    {
        SetCollisionSize(default.CollisionRadius*2.f, default.CollisionHeight);
    }
}

function RespawnEffect()
{
    //log("Pickup::RespawnEffect!");
    if( RespawnFXClass != None )
    {
        Spawn(RespawnFXClass,,,Location);
    }
}

function Destroyed()
{
	if (MyMarker != None )
		MyMarker.markedItem = None;	
	if (Inventory != None )
		Inventory.Destroy();	

    Super.Destroyed(); // gam
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( Inventory != None )
		destroy();
	else
	{
		GotoPickupState(); //amb
		Super.Reset();
	}
}

// Turns the pickup into a different type of pickup - specificly used by the WildcardCharger
function Pickup Transmogrify(class<Pickup> NewClass) // de
{
	local Pickup NewPickup;

	NewPickup = Spawn(NewClass);
	//NewPickup.PickupBase = PickupBase;
	NewPickup.RespawnTime = RespawnTime;

	if (MyMarker != None )
	{
		MyMarker.markedItem = NewPickup;
		NewPickup.MyMarker = MyMarker;
		MyMarker = None;
	}
	Destroy();

	return NewPickup;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	return 0;
}

/* Pickups have an AI interface to allow AIControllers, such as bots, to assess the 
 desireability of acquiring that pickup.  The BotDesireability() method returns a 
 float typically between 0 and 1 describing how valuable the pickup is to the 
 AIController.  This method is called when an AIController uses the 
 FindPathToBestInventory() navigation intrinsic.
*/
function float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local float desire;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		AlreadyHas = Bot.FindInventoryType(InventoryType); 
		if ( AlreadyHas != None ) 
		{
			if ( Inventory != None )
			{
				if( Inventory.Charge <= AlreadyHas.Charge )
					return -1;
			}
			else if ( InventoryType.Default.Charge <= AlreadyHas.Charge )
				return -1;
		}
	}
	return desire;
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;


	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));

	Copy.GiveTo( Other, self );

	return Copy;
}

function StartSleeping()
{
    if (bDropped)
        Destroy();
    else
	    GotoState('Sleeping');
}

// amb ---
function GotoPickupState()
{
    GotoState('Pickup');
}
// --- amb

function AnnouncePickup( Pawn Receiver, optional int Amount )
{
	Receiver.HandlePickup(self, Amount);
	PlaySound( PickupSound, SLOT_Interact ); // gam
}

//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
	if( Level.Game.ShouldRespawn(self) && !bPickupOnce )
		StartSleeping(); //amb
	else
		Destroy();
}

// HUD Messages

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
    bDropped = true;
	GotoState('Flying');
}

function bool ReadyToPickup(float MaxWait)
{
	return false;
}

event Landed(Vector HitNormal)
{
    GotoPickupState(); //amb
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    GotoPickupState();
}

function GiveToPawn(Pawn Other)
{
	local Inventory Copy;
	Copy = SpawnCopy(Other);
	AnnouncePickup(Other);
    SetRespawn(); //amb
	Copy.PickupFunction(Other);

}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		//BBTODO find a non hack way of doing this

		if(Pawn(Other).bDriver ) // then he is driving and should funnel the pickup stuff to the vehicle
		{
			if( Level.Game.PickupQuery(Pawn(Other.Base), self) )
			{
				TriggerEvent(Event, self, Pawn(Other.Base));
				return true;
			}
		}	
		else 
		{	
			// make sure game will let player pick me up			
			if( Level.Game.PickupQuery(Pawn(Other), self) )
			{
				TriggerEvent(Event, self, Pawn(Other));
				return true;
			}
		}
		return false;
	}
		
	// When touched by an actor.
	function Touch( actor Other )
	{
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			GiveToPawn(Pawn(Other));
		}
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
			Touch(P);
	}

	function Timer()
	{
		if(bPickupOnce)
		{
			Destroy();
			return;
		}

		if ( bDropped )
			GotoState('FadeOut');
	}

	function BeginState()
	{
		if ( bDropped || bPickupOnce )
        {
			AddToNavigation();
			if(DroppedLifeTime > 0)
			{
			    SetTimer(DroppedLifeTime, false);
			}
        }
	}
	
	function EndState()
	{
		if ( bDropped || bPickupOnce)
			RemoveFromNavigation();
	}

Begin:
	CheckTouching();
}

State FadeOut extends Pickup
{
	function Tick(float DeltaTime)
	{
		SetDrawScale(FMax(0.01, DrawScale - Default.DrawScale * DeltaTime));
	}
	
	function BeginState()
	{
		RotationRate.Yaw=60000;
		SetPhysics(PHYS_Rotating);
		LifeSpan = 1.0;
	}
	
	function EndState()
	{
		LifeSpan = 0.0;
		SetDrawScale(Default.DrawScale);
		if ( Physics == PHYS_Rotating )
			SetPhysics(PHYS_None);
	}
}

//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.
function float GetRespawnTime()
{
	return RespawnTime; 
}

State Sleeping
{
	ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return ( bPredictRespawns && (LatentFloat < MaxWait) );
	}

	function StartSleeping() {}

	function BeginState()
	{
		bHidden = true;
	}
	function EndState()
	{
		bHidden = false;
	}			
Begin:

    // jij ---
    //if (PickUpBase != None)
    //    PickUpBase.TurnOff();
    // --- jij

	Sleep( GetReSpawnTime()-0.1 );
    RespawnEffect();
    Sleep( 0.1 );
	    
    // jij --- (we could turn it back on before the spawn effect is played too...)
    //if (PickUpBase != None)
    //    PickUpBase.TurnOn();
    // --- jij	
    // sjs rem'd GoToState( 'Pickup' );
    
    GotoPickupState(); //amb
}

state Flying
{
	function Timer()
	{
		if ( bDropped )
			GotoState('FadeOut');
	}

	function BeginState()
	{
		if ( bDropped )
		    SetTimer(DroppedLifeTime, false);
	}
}

defaultproperties
{
     MaxDesireability=0.100000
     DroppedLifeTime=120.000000
     PickupMessage="Snagged an item."
     CantPickupMessage="You already have this item."
     bOnlyReplicateHidden=True
     CullDistance=4000.000000
     NetPriority=1.400000
     NetUpdateFrequency=8.000000
     Texture=Texture'Engine.S_Inventory'
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
     DrawType=DT_Mesh
     bOrientOnSlope=True
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     bShouldBaseAtStartup=True
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
     bFixedRotationDir=True
}
