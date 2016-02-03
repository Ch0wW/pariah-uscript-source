class PlayerPlasmaChain extends PlayerPlasma;

var () float ChainRange;	// range for target chaining
var () float MaxChainRange;	// max range for target chaining (at fully charged)
var () float RangeDecay;	// decay of chaining range at each target
var () float PowerDecay;	// decay of power at each target
var () float SpeedDecay;	// decay of speed at each target
var Actor Trailer[2];

var int chainCount;			// number of times we've chained so far
var bool bAllowChain;		// try to prevent infinite recursive spawning if the projectile spawns within a collision

var int WECLevel;

const CHAIN_MAX = 3;		// maximum steps in the chain

simulated function PostBeginPlay()
{
    local int i;
	Super.PostBeginPlay();
	bAllowChain = true;
	for(i = 0; i < ArrayCount(Trailer); ++i)
	{
	    Trailer[i] = Spawn(class'VehicleEffects.PlasmaGodRays',self);
    }
}

simulated function Destroyed()
{
    local int i;
    Super.Destroyed();
    for(i = 0; i < ArrayCount(Trailer); ++i)
	{
	    Trailer[i].Destroy();
    }
}

function Blind()
{
    local Controller C;
    for ( C=Level.ControllerList; C!=None; C=C.nextController )
    {
        if(C.Pawn != None)
        {
            C.CalcBlinded(Instigator, Location, 3000.0, 3.0, 'Plasma');
        }
    }
}

simulated function HitWall( Vector HitNormal, Actor Wall )
{
    Spawn(class'PlayerPlasmaBlast',,, Location);
    Super.HitWall(HitNormal, Wall);
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local Pawn Victim;
	local Vector Momentum, RelLoc;
	local Emitter effect,effectB;
	
	if(Other == Instigator)
	{
	    Super.ProcessTouch(Other, HitLocation);
	    return;
	}
	
	Blind();
	Spawn(class'PlayerPlasmaBlast',,, Location);
	
	if(Instigator != none && Other != Instigator && (Other.IsA('VGPawn') || Other.IsA('VGVehicle') ) ) 
	{
		// initiate a chain

		// instant hit chain damage to anything within striking distance
		foreach VisibleCollidingActors(class'Pawn', Victim, ChainRange, HitLocation) 
		{
			if(Victim != Instigator) 
			{
				Momentum = Normal(Victim.Location-HitLocation)*MomentumTransfer;
				Victim.TakeDamage(SplashDamage, Instigator, HitLocation, Momentum, MyDamageType);
				effect = Spawn(class'PlayerPlasmaBlast',,, Victim.Location);
				effect.Tag='Lightning';
				effectB= Spawn(class'PlayerPlasmaChainEffect',,, HitLocation);
				RelLoc = Victim.Location - HitLocation;

				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.X.Min = RelLoc.x;
				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.X.Max = RelLoc.X;
				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.Y.Min = RelLoc.Y;
				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.Y.Max = RelLoc.Y;
				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.Z.Min = RelLoc.Z;
				BeamEmitter(effectB.Emitters[0]).BeamEndPoints[0].offset.Z.Max = RelLoc.Z;
			}
		}
	}

	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
     ChainRange=700.000000
     MaxChainRange=2000.000000
     RangeDecay=0.750000
     PowerDecay=0.900000
     SpeedDecay=0.650000
     TrailClass=Class'VehicleEffects.PlasmaGlobules'
     VehicleDamage=20
     PersonDamage=15
     SplashDamage=12.000000
     Speed=1000.000000
     DamageRadius=100.000000
     MomentumTransfer=7500.000000
     LightBrightness=255.000000
     LifeSpan=20.000000
     DrawScale=4.000000
     AmbientSound=Sound'PariahWeaponSounds.hit.PlasmaRifleEnergyBall'
     LightHue=28
     LightSaturation=255
}
