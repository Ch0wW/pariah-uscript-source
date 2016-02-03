////////////////////////////////////
// Pickup class for Vehicle Game
//
// The super class for pickups, since we'll have both
// characters and vehicles we need to overide some of
// the default functionality.
////////////////////////////////////
class VehiclePickup extends Pickup
	native
	abstract;

#exec OBJ LOAD FILE=..\StaticMeshes\PariahWeaponMeshes.usx



var ()	bool	bVehiclePickup;
var ()	bool	bCharacterPickup;

var	Emitter			Emitter;
var class<Emitter>	EmitterClass;
var vector			EmitterOffset;
var	rotator			EmitterRotation;

var Effects			Effect;
var class<Effects>	EffectClass;

//respawn effect
var	xEmitter		RespawnEmitter;
var class<xEmitter>	RespawnEmitterClass;

var Color hudcolor;
var Texture hudtex;

var float alpha;
var bool bIsOnScreen;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	/*if(EmitterClass != none)
	{
		Emitter = spawn(EmitterClass, self);
		Emitter.SetBase(self);
		Emitter.SetRelativeLocation(EmitterOffset);
		Emitter.SetRelativeRotation(EmitterRotation);
	}
	*/
}

simulated function Destroyed()
{
	Super.Destroyed();
	if(Emitter != none)
		Emitter.Destroy();
	if(Effect != none)
		Effect.Destroy();
}

function DrawHUDLocator(Canvas Canvas, Vector ScreenPos);


function GiveToPawn(Pawn Other)
{
	Super.GiveToPawn(Other);
}

function actor GetRealOther(actor Other)
{
	return Other;
}

function float BotDesireability( pawn Bot )
{

	if( (!bVehiclePickup && Bot.IsA('VGVehicle')) ||
		(!bCharacterPickup && Bot.IsA('VGPawn')) )
	{
		return 0;
	}

	return Super.BotDesireability(Bot);

}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	if( Other.IsA('SPPawn') )
	{
		return 0;
	}

	if( (!bVehiclePickup && Other.IsA('VGVehicle')) ||
		(!bCharacterPickup && Other.IsA('VGPawn')) )
	{
		return 0;
	}

	return MaxDesireability/PathWeight;
}

auto state Pickup
{
	function DrawHUDLocator(Canvas Canvas, Vector ScreenPos){}
	
	function bool ValidTouch( actor Other )
	{
		local actor RealOther;
		
		RealOther=GetRealOther(Other);

		// make sure its a live player
		if ( (Pawn(RealOther) == None) || !Pawn(RealOther).bCanPickupInventory || (Pawn(RealOther).Health <= 0) )
		{
			return False;
		}

		// make sure not touching through wall
		if ( !FastTrace(RealOther.Location, Location) )
		{
			return False;
		}

		if((RealOther.IsA('VGVehicle') && !bVehiclePickup) 
			|| (RealOther.IsA('VGPawn') && (!bCharacterPickup)))
		{
			return False;
		}
		
		if( Level.Game.PickupQuery(Pawn(RealOther), self) )
		{
			TriggerEvent(Event, self, Pawn(RealOther));
			return True;
		}
		return False;
	}

	function BeginState()
	{
		local int i;
		Super.BeginState();
		if(Emitter != none)
		{
			for(i=0;i<Emitter.Emitters.Length;i++)
			{
				Emitter.Emitters[i].Disabled=false;
			}
		}
		if(Effect == none || Effect.bDeleteMe==1)
			Effect = spawn(EffectClass,self,,Location,Rotation);
		if(RespawnEmitter != none)
			RespawnEmitter.mRegen = false;
	}

	function EndState()
	{
		local int i;
		Super.EndState();
		if(Emitter != none)
		{
			for(i=0;i<Emitter.Emitters.Length;i++)
			{
				Emitter.Emitters[i].Disabled=true;
			}
		}
		if(Effect != none)
			Effect.Destroy();
	}
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

	Sleep( GetReSpawnTime()-2.2 );
    RespawnEffect();
    Sleep( 2.2 );
    GotoPickupState(); //amb
}

defaultproperties
{
     bVehiclePickup=True
     RespawnTime=30.000000
     PickupSound=Sound'VehicleGameSounds.Pickups.DefaultPickupSound'
     DrawScale=0.500000
     CollisionRadius=100.000000
     CollisionHeight=100.000000
     RotationRate=(Yaw=25000)
     Physics=PHYS_Rotating
     DrawType=DT_StaticMesh
     bShouldBaseAtStartup=False
}
