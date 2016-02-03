class GasMine extends Mine;

var Array<Actor> TrackedActors; //keep track of areas in our space so we can kill if they go too far
var bool bEnableTrackedKill;

var float NextTickTime;

var() bool bPreventRunPast;
function DoExplodeDamage()
{
	local GasMineCloud gas;
	gas=Spawn(class'GasMineCloud',self,,Location);
	SetTimer(gas.LifeSpan, false);
	gas.SetBase(self);	
	bEnableTrackedKill = true;
}

event Timer()
{
	bEnableTrackedKill = false;
}

function AddTrackedActor(Actor a)
{
	local int i;

	for(i = 0; i < TrackedActors.Length; i++)
	{
		if(TrackedActors[i] == None)
		{
			TrackedActors[i] = a;
			return;
		}
	}
	TrackedActors[TrackedActors.Length] = a;
}

event Tick(float dt)
{
	local int i;
	local float dotp;
	local Vector vdir, vloc;
	local Array<Actor> RemoveList;

	if(bPreventRunPast && (!bEnableTrackedKill || Level.TimeSeconds < NextTickTime)) return;


	vdir = Vector(Rotation);
	for( i = 0; i < TrackedActors.Length; i++ )
	{
		if(TrackedActors[i] == None) continue;
		vloc = Normal(TrackedActors[i].Location - Location);

		dotp = vdir dot vloc;

		if(dotp < 0.0)
		{
			RemoveList[RemoveList.Length] = TrackedActors[i];
			TrackedActors[i].TakeDamage(1000, None, Location, Vect(0,0,0), class'BarrelExplDamage');
		}
	}


	for( i = 0; i < RemoveList.Length; i++ )
	{
		RemoveTrackedActor(RemoveList[i]);
	}

}

function RemoveTrackedActor(Actor a)
{
	local int i;

	for(i = 0; i < TrackedActors.Length; i++)
	{
		if(TrackedActors[i] == a)
		{
			TrackedActors[i] = None;
			return;
		}
	}
}


function AreaViolated(Actor Other, MineCollisionArea area)
{
	if(bPreventRunPast) AddTrackedActor(Other);
	Super.AreaViolated(Other, area);
}

function AreaUnviolated(Actor Other, MineCollisionArea area)
{
	if(bPreventRunPast) RemoveTrackedActor(Other);
	Super.AreaUnviolated(Other, area);
}

defaultproperties
{
     MineCollisionRadius=512.000000
     ExplodeEmitter=None
     ExplosionDistortionClass=None
     bDestroyOnExplode=False
     bKeepCollisionArea=True
     StaticMesh=StaticMesh'PariahGametypeMeshes.GasMine.GasMine'
     AmbientSound=Sound'PariahGameSounds.Mines.GasMineLoop'
     bDirectional=True
}
