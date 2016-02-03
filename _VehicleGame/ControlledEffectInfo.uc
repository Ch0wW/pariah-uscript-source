class ControlledEffectInfo extends Object
	hidecategories(Object)
	native
	abstract
	editinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var (Effect) class<Emitter>			EmitterClass;
var (Effect) float					MaxPPS;

simulated function CreateEmitterAt( Actor Owner, vector Loc, rotator Rot, out Emitter TheEmitter )
{
	local int				e;
	local ParticleEmitter	SubEmitter;
	local float				pps;
	local bool				calcMaxPPS;

	if ( EmitterClass != None )
	{
		TheEmitter = Owner.Spawn( EmitterClass, Owner );
		calcMaxPPS = MaxPPS <= 0;

		TheEmitter.SetPhysics( PHYS_None );
		TheEmitter.SetBase( Owner );
		TheEmitter.SetRelativeLocation( Loc );
		TheEmitter.SetRelativeRotation( Rot );

		TheEmitter.AutoReset = True;
		TheEmitter.AutoDestroy = False;
		for ( e = 0; e < TheEmitter.Emitters.Length; e++ )
		{
			SubEmitter=TheEmitter.Emitters[e];
			SubEmitter.AutoDestroy=True;
			SubEmitter.AutoReset=False;
			SubEmitter.AutomaticInitialSpawning=False;
			SubEmitter.RespawnDeadParticles=False;
			SubEmitter.ResetAfterChange=True;
			if ( calcMaxPPS )
			{
				pps = SubEmitter.MaxParticles / SubEmitter.LifetimeRange.Max;
				if ( MaxPPS <= 0 || pps < MaxPPS )
				{
					MaxPPS = pps;
				}
			}
		}
	}
}

simulated function CreateEmitter( Actor Owner, out Emitter TheEmitter )
{
	local vector	 loc;
	local rotator	 rot;

	CreateEmitterAt( Owner, loc, rot, TheEmitter );
}

simulated native function StopEmitter( Actor Owner, Emitter TheEmitter );

defaultproperties
{
}
