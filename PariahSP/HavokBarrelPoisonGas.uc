class HavokBarrelPoisonGas extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

var Sound   LeakSound;

var bool    bPunctured;
var float   LastCloudTime;
var vector  LastCloudLoc;

var Emitter InteriorGas;

const LEAK_DURATION = 15;
const CLOUD_RESPAWN_DISTANCE = 100;
const CLOUD_RESPAWN_TIME = 7.5;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	InteriorGas=Spawn(class'GasBarrelInteriorGas',self,,Location+(vect(0,0,60)>>Rotation), Rotation);
	InteriorGas.SetBase( self );
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	Super.TakeDamage(0, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);

	if ( !bPunctured )
	{
		InteriorGas.Stop();
		GotoState('Punctured');
	}
}

simulated function CreateGasCloud()
{
    local HavokBarrelPoisonGasCloud gas;

    gas=Spawn(class'HavokBarrelPoisonGasCloud',self,,Location, Rotation);
	gas.SetBase(self);
    LastCloudLoc = Location;
    LastCloudTime = Level.TimeSeconds;
}

state Punctured
{
	function BeginState()
	{
        bPunctured = true;

        CreateGasCloud();

		SetMultiTimer(0, 0.2, true);
		SetMultiTimer(1, LEAK_DURATION, false);

		AmbientSound=LeakSound;
	}

	function MultiTimer(int slot)
	{
        switch(slot)
		{
		case 0:
			if (VSize(LastCloudLoc - Location) > CLOUD_RESPAWN_DISTANCE || (Level.TimeSeconds - LastCloudTime) > CLOUD_RESPAWN_TIME )
			{
                CreateGasCloud();
			}
			break;
		case 1:
			GotoState('Empty');
			break;
		}
	}

}

function bool IsEmpty()
{
	return False;
}

state Empty
{
	function bool IsEmpty()
	{
		return True;
	}

	function BeginState()
	{
		AmbientSound=None;
		if ( InteriorGas != None )
		{
			InteriorGas.Destroy();
			InteriorGas = None;
		}
	}
}

defaultproperties
{
     HFriction=0.700000
     ImpactSoundVolScale=1024.000000
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     CollisionRadius=42.000000
     StaticMesh=StaticMesh'HavokObjectsPrefabs.Barrels.GasBarrel'
     Physics=PHYS_Havok
     bWorldGeometry=False
}
