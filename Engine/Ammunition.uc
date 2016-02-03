//=============================================================================
// Ammunition: the base class of weapon ammunition
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================

//modified XJ

class Ammunition extends Inventory
	abstract
	native
	nativereplication;

var travel int MaxAmmo;						// Max amount of ammo
var travel int AmmoAmount;
var int InitialAmount; // sjs					// Amount of Ammo current available
var travel int PickupAmmo;					// Amount of Ammo to give when this is picked up for the first time	

// Used by Bot AI

var		bool	bRecommendSplashDamage;
var		bool	bTossed;
var		bool	bTrySplash;
var		bool	bLeadTarget;
var		bool	bInstantHit;
var		bool	bSplashDamage;	
var     bool    bCanTargetTeammates;  // for auto-aiming. might as well be bIsLinkGun

// Damage and Projectile information

var class<Projectile> ProjectileClass;
var class<DamageType> MyDamageType;
var float WarnTargetPct;
var float RefireRate;
////////////////////////////////////////////

var Sound FireSound;

var float AutoAim;  //jjs
var float MaxRange; //amb: for autoaim
var bool  bTryHeadShot; //amb

var class<Projectile> ComboTargetClass;

// XJ: regenrating ammo vars
var ()	float	RegenRate;
var		float	RegenTimer;
var ()	int		RegenAmmount;
var		bool	bRegen;


// Network replication
//

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		AmmoAmount;
}

// amb ---
simulated function CheckOutOfAmmo()
{
    if (AmmoAmount <= 0)
        Pawn(Owner).Weapon.OutOfAmmo();
}

simulated function PostNetReceive()
{
    CheckOutOfAmmo();
}

simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
    if (bAmountNeededIsMax && AmmoAmount < AmountNeeded)
        AmountNeeded = AmmoAmount;
        
	if (AmmoAmount < AmountNeeded)
        return false;   // Can't do it
    
    AmmoAmount -= AmountNeeded;
    
    if (Level.NetMode == NM_StandAlone || Level.NetMode == NM_ListenServer)
        CheckOutOfAmmo();
	
    return true;
}
// --- amb

// Commented out as part of UC merge (RJ)
//
////added XJ
////if we have any ammo use it
//function bool UseAmmo(int AmountNeeded)
//{
//	if (HasAmmo())
//	{
//		AmmoAmount -= AmountNeeded;
//		if (AmmoAmount < 0) AmmoAmount = 0;
//		return true;
//	}
//	return false;
//}


simulated function bool HasAmmo()
{
	return ( AmmoAmount > 0 );
}

function float RateSelf(Pawn Shooter, out byte RecommendedFiringMode)
{
	return 0.5;
}

function WarnTarget(Actor Target,Pawn P ,vector FireDir)
{
	if ( bInstantHit )
		return;
	if ( (FRand() < WarnTargetPct) && (Pawn(Target) != None) && (Pawn(Target).Controller != None) ) 
		Pawn(Target).Controller.ReceiveWarning(P, ProjectileClass.Default.Speed, FireDir); 
}

function SpawnProjectile(vector Start, rotator Dir)
{
	AmmoAmount -= 1;
	Spawn(ProjectileClass,,, Start,Dir);	
}

function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	AmmoAmount -= 1;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("Ammunition "$GetItemName(string(self))$" amount "$AmmoAmount$" Max "$MaxAmmo);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}
	
function bool HandlePickupQuery( pickup Item )
{
    local int AdjustedAmount;
	if ( class == item.InventoryType ) 
	{
		if (AmmoAmount==MaxAmmo) 
			return true;
        AddAmmo(Ammo(item).AmmoAmount);
        AdjustedAmount = Ammo(item).AmmoAmount;
        if( MaxAmmo > default.MaxAmmo ) // ammo affinity
        {
            AdjustedAmount = Ceil(float(AdjustedAmount) * MaxAmmo / default.MaxAmmo);
        }
		item.AnnouncePickup(Pawn(Owner), AdjustedAmount);
        item.SetRespawn(); //amb
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// If we can, add ammo and return true.  
// If we are at max ammo, return false
//
function bool AddAmmo(int AmmoToAdd)
{
    if( MaxAmmo > default.MaxAmmo ) // ammo affinity
    {
        //log("AmmoToAdd increased due to affinity:"@AmmoToAdd);
        AmmoToAdd = Ceil(float(AmmoToAdd) * MaxAmmo / default.MaxAmmo);
        //log("AmmoToAdd now:"@AmmoToAdd);
    }

	AmmoAmount = Min(MaxAmmo, AmmoAmount+AmmoToAdd);

	return true;
}

// regen's a weapon's ammo over time (intent is to have it regened whilst communing with an ammo station)
function Regen(float dt)
{
	RegenTimer += dt;
	if(RegenTimer > RegenRate) 
	{
		// add a clip
		AddAmmo(PickupAmmo);
		RegenTimer = 0;
	}
}

simulated function bool AllowFire(int Required)
{
    return(AmmoAmount >= Required);
}

simulated function CompletedReload()
{
}

simulated function bool CheckReload()
{
	return false;
}

function float GetDamageRadius()
{
	if ( ProjectileClass != None )
		return ProjectileClass.Default.DamageRadius;

	return 0;
}

simulated function ManualReload()
{
}

defaultproperties
{
     InitialAmount=10
     WarnTargetPct=0.500000
     RefireRate=0.500000
     AutoAim=0.950000
     RegenRate=1.000000
     MyDamageType=Class'Engine.DamageType'
     bNetNotify=True
}
