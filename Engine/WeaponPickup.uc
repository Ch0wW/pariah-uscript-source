class WeaponPickup extends Pickup
	notplaceable
	abstract;

var() bool	  bWeaponStay;
var() bool	  bThrown; // true if deliberatly thrown, not dropped from kill
var() int     AmmoAmount[2];

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
	MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

function SetWeaponStay()
{
    bWeaponStay = bWeaponStay || Level.Game.bWeaponStay;
}

// amb ---
function StartSleeping()
{
    if (bDropped)
        Destroy();
    else if (!bWeaponStay)
	    GotoState('Sleeping');
}

function bool AllowRepeatPickup()
{
    return (!bWeaponStay || (bDropped && !bThrown));
}
// --- amb

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local Weapon AlreadyHas;

	AlreadyHas = Weapon(Other.FindInventoryType(InventoryType)); 
	if ( (AlreadyHas != None)
		&& (bWeaponStay || (AlreadyHas.Ammo[0].AmmoAmount > 0)) )
		return 0;
	if ( AIController(Other.Controller).PriorityObjective()
		&& ((Other.Weapon.AIRating > 0.5) || (PathWeight > 400)) )
		return 0;
	if ( class<Weapon>(InventoryType).Default.AIRating > Other.Weapon.AIRating )
		return class<Weapon>(InventoryType).Default.AIRating/PathWeight;
	return class<Weapon>(InventoryType).Default.AIRating/PathWeight;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType)); 
	if ( AlreadyHas != None )
	{
		if ( Bot.Controller.bHuntPlayer )
			return 0;
			
		// can't pick it up if weapon stay is on
		if ( !AllowRepeatPickup() )
			return 0;
		if ( (RespawnTime < 10) 
			&& ( bHidden || (AlreadyHas.Ammo[0] == None) 
				|| (AlreadyHas.Ammo[0].AmmoAmount >= AlreadyHas.Ammo[0].MaxAmmo)) )
			return 0;

		if ( AlreadyHas.Ammo[0] == None )
			return 0.25 * desire;

		// bot wants this weapon for the ammo it holds
		if( ( AlreadyHas.Ammo[0].AmmoAmount > 0 ) && ( AlreadyHas.Ammo[0].PickupClass != None ) ) // gam
			return FMax( 0.25 * desire, 
					AlreadyHas.Ammo[0].PickupClass.Default.MaxDesireability
					 * FMin(1, 0.15 * AlreadyHas.Ammo[0].MaxAmmo/AlreadyHas.Ammo[0].AmmoAmount) ); 
		else
			return 0.05;
	}
	if ( Bot.Controller.bHuntPlayer && (MaxDesireability * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;
	
	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

function float GetRespawnTime()
{
	if ( (Level.NetMode != NM_Standalone) || (Level.Game.Difficulty > 3.f) )
		return ReSpawnTime;
	return RespawnTime * (0.33 + 0.22 * Level.Game.Difficulty); 
}

function InitDroppedPickupFor(Inventory Inv)
{
    local Weapon W;
    W = Weapon(Inv);
    if (W != None)
    {
        if (W.Ammo[0] != None)
            AmmoAmount[0] = W.Ammo[0].AmmoAmount;
        if (W.Ammo[1] != None && W.Ammo[1] != W.Ammo[0])
            AmmoAmount[1] = W.Ammo[1].AmmoAmount;
    }
    Super.InitDroppedPickupFor(None);
}

function Reset()
{
    AmmoAmount[0] = 0;
    AmmoAmount[1] = 0;
    Super.Reset();
}

function inventory SpawnCopy( pawn Other )
{
    local inventory inv;
    local weapon w;

    inv = Other.FindInventoryType(InventoryType);
    if (inv != None)
    {
        w = weapon(inv);

        if (w.Ammo[0] != None)
        {
			if(bDropped)
			{
            	w.Ammo[0].AddAmmo(w.Ammo[0].default.PickupAmmo);
			}
			else
            {
				w.Ammo[0].AddAmmo(w.Ammo[0].default.InitialAmount);
            }
        }

        return inv;
    }
    else
    {
        return Super.SpawnCopy(Other);
    }
}

defaultproperties
{
     MaxDesireability=0.500000
     RespawnTime=30.000000
     PickupMessage="You got a weapon."
     CantPickupMessage="You already have this weapon."
     bPredictRespawns=True
     Texture=Texture'Engine.S_Weapon'
     RotationRate=(Yaw=32768)
     Physics=PHYS_Rotating
     AmbientGlow=64
}
