class VGRocketRadiationArea extends Actor;

var	()	int				RadiationDamage;
var		PoisonEmitter	GasEffect;
var     Controller		InstigatorController;

var const bool          bUseOurRotationForGasEffect;

replication {
	reliable if(Role == ROLE_Authority)
		RadiationDamage, GasEffect;
}

simulated function PostBeginPlay()
{
    local rotator r;

	if(Role == ROLE_Authority)
	{
		SetTimer(1, true);
	}
	if(Level.NetMode != NM_DedicatedServer)
	{
        if ( bUseOurRotationForGasEffect )
        {
            r = Rotation;
        }
        else
        {
            r = rot(16384, 0, 0);
        }
		GasEffect = spawn(class'VehicleEffects.PoisonEmitter', self, , Location, rot(16384, 0, 0) );
		GasEffect.SetBase(self);
		if(GasEffect != none)
		{
//			GasEffect.mPosDev.X = CollisionRadius*0.5;
//			GasEffect.mPosDev.Y = CollisionRadius*0.5;
//			GasEffect.mPosDev.Z = CollisionHeight*0.5;
		}
	}

	if(Instigator != none)
		InstigatorController = Instigator.Controller;
}

simulated function Destroyed()
{
	if(GasEffect != none) {
		GasEffect.Kill();
		GasEffect = none;
	}
}

function Timer()
{
	local int i;
	if(Role == ROLE_Authority)
	{
		for(i=0; i<Touching.Length; i++)
		{
			if(Touching[i] == none || !Touching[i].IsA('VGPawn') )
				continue;

			// if there less than a second between now and the last poison time, don't poison again
			if( (Level.TimeSeconds-VGPawn(Touching[i]).lastPoisonTime) < 1.0)
				continue;

			if(VGPawn(Touching[i]).Health > 0 && (!VGPawn(Touching[i]).Controller.SameTeamAs(InstigatorController) || Pawn(Touching[i]).Controller == InstigatorController) ) {
				Touching[i].TakeDamage(RadiationDamage, Instigator, vect(0,0,0), vect(0,0,0), class'VGRocketLauncherDamage',,true);
				VGPawn(Touching[i]).lastPoisonTime = Level.TimeSeconds;
			}
		}
	}
}

defaultproperties
{
     RadiationDamage=20
     LifeSpan=10.000000
     CollisionRadius=250.000000
     CollisionHeight=150.000000
     RemoteRole=ROLE_SimulatedProxy
     bHidden=True
     bCollideActors=True
     bUseCylinderCollision=True
}
