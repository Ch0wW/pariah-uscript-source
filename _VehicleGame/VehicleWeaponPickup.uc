class VehicleWeaponPickup extends VehiclePickup;

var() bool	  bWeaponStay;
var() bool	  bThrown; // true if deliberatly thrown, not dropped from kill
var() int     AmmoAmount[2];

// if HMass is > 0, the weapon is put into havok mode until it becomes inactive
// - currently only in single player game
//
var float		HMass;
var float		HFriction;
var float		HRestitution;
var float		HLinearDamping;
var float		HAngularDamping;
var float		HGravScale;
var float		HBuoyancy;
var float       HImpactThreshold;
var Sound       ImpactSound;
var float       ImpactSoundVolScale;
var float		HavokStartTime;
var vector		HavokLastLoc;
var int			HavokNoMotionCount;
var transient float LastImpact;
var float PulseAccum;
var float PulseDir;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
	CreateStyle(class'ColorModifier');

	PulseDir=1;
	MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

auto state Pickup
{

	function Tick(float dt)
	{
		local byte c;
		local int i;


		if(PulseDir == 1.0)
		{
			PulseAccum+=dt;

			if(PulseAccum >= 1.0) 
			{
				PulseDir *= -1;
				PulseAccum = 1.0;
			}
			c = PulseAccum * 255.0;

		}
		else
		{
			PulseAccum-=dt;

			if(PulseAccum <= 0.0) 
			{
				PulseAccum = 0.0;
				PulseDir *= -1;
			}
			c = PulseAccum * 255.0;
		}

		c = float(c) * 0.5 + 63.0;

		for(i=0;i<StyleModifier.Length;i++)
		{
			ColorModifier(StyleModifier[i]).Color.R = c;
			ColorModifier(StyleModifier[i]).Color.G = c;
			ColorModifier(StyleModifier[i]).Color.B = c;
			ColorModifier(StyleModifier[i]).Color.A = 255;
		}



	}
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

    if( Other.IsA('SPPawn') )
	{
		return 0;
	}
	if( (!bVehiclePickup && Other.IsA('VGVehicle')) ||
		(!bCharacterPickup && Other.IsA('VGPawn')) )
	{
		return 0;
	}

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

	if( (!bVehiclePickup && Bot.IsA('VGVehicle')) ||
		(!bCharacterPickup && Bot.IsA('VGPawn')) )
	{
		return 0;
	}

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
	if ( Level.Game.bSinglePlayer && HMass > 0 )
	{
		SetPhysics(PHYS_Havok);
		HWake();
		HSetMass( HMass );
		HSetFriction( HFriction );
		HSetRestitution( HRestitution );
		HSetDampingProps( HLinearDamping, HAngularDamping );
		HSetRBVel( Velocity, (65536+Rand(65536)) * VRand() );
		HavokParams(HParams).GravScale = HGravScale;
		HavokParams(HParams).Buoyancy = HBuoyancy;
		if ( HImpactThreshold > 0 )
		{
			HavokParams(HParams).ImpactThreshold = HImpactThreshold;
		}

		// this was lifted from Pickup::InitDroppedPickupFor()
		//
		Inventory = Inv;
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;
		bDropped = true;
		GotoState('HavokFlying');
	}
	else
	{
		Super.InitDroppedPickupFor(None);
	}
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

// this will only be called if this actor's physics is PHYS_Havok and the impact is greater than it's HParam's ImpactThresold 
//
simulated event HImpact(actor other, vector pos, vector ImpactVel, vector ImpactNorm, Material HitMaterial)
{
	local float Vol;
	
	if ( ImpactSound != None && Level.TimeSeconds > LastImpact + 1.0 )
	{
		Vol = VSize(ImpactVel);
		if ( ImpactSoundVolScale > 0 )
		{
			Vol /= ImpactSoundVolScale;
		}
		PlaySound(ImpactSound,,Vol);
        LastImpact = Level.TimeSeconds;
	}
}

state HavokFlying
{
	function Timer()
	{
		if ( bDropped )
		{
			if ( DroppedLifeTime > 0 && (Level.TimeSeconds - HavokStartTime) > DroppedLifeTime )
			{
				// if it's stayed active longer than DroppedLifeTime, start fading it out
				//
				GotoState('FadeOut');
			}
			else if ( !HIsAwake() )
			{
				// if it's inactive, go to pickup state
				//
				GotoPickupState();
			}
			else 
			{
				if ( VSize(Location - HavokLastLoc) < 1 )
				{
					HavokNoMotionCount++;
				}
				else
				{
					HavokLastLoc = Location;
					HavokNoMotionCount = 0;
				}
				if ( HavokNoMotionCount > 1 )   //jds- reduce time required that you are not allowed to pick it up.
				{
					// hasn't moved very much, assume it is caught up in some active havok island
					// so just go to pickup state
					//
					GotoPickupState();
				}
				else
				{
					SetTimer( 0.1, false );
				}
			}
		}
	}

	function BeginState()
	{
		if ( bDropped )
		{
			HavokStartTime = Level.TimeSeconds;
			HavokLastLoc = Location;
			SetTimer( 0.2, false );
		}
	}

	function EndState()
	{
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     HMass=10.000000
     HFriction=0.500000
     HRestitution=0.200000
     HLinearDamping=0.200000
     HAngularDamping=0.200000
     HGravScale=1.500000
     HBuoyancy=0.500000
     HImpactThreshold=100.000000
     ImpactSound=Sound'HavokObjectSounds.WeaponDrop.WeaponDropA'
     hudtex=Texture'VehicleGameTextures.HUD.pickup_label_small'
     hudcolor=(B=55,G=255,R=55,A=200)
     MaxDesireability=0.500000
     PickupMessage="You got a weapon"
     CantPickupMessage="You already have this weapon."
     PickupForce="Pickup"
     bPredictRespawns=True
     DrawScale=1.000000
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     Texture=Texture'Engine.S_Weapon'
     MessageClass=Class'VehicleGame.PickupMessage'
     Physics=PHYS_None
     AmbientGlow=64
     bDisableKarmaEncroacher=True
}
