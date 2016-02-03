class xDynamicProjector extends Projector;

var transient vector		LastLocation;

var	float		ReattachMinDistChange, ReattachMaxDistChange, ReattachDistChange;

simulated function PostBeginPlay()
{
	ReattachDistChange = RandRange( ReattachMinDistChange, ReattachMaxDistChange );
	Super.PostBeginPlay();
	Enable('Tick');
}

function Tick(float dt)
{
	local bool		bReattach;
	local vector	diffLoc;

	diffLoc = Location - LastLocation;
	if ( (diffLoc Dot diffLoc) > ReattachDistChange )
	{
		bReattach = True;
	}
	if ( bReattach )
	{
		DetachProjector(True);
		AttachProjector();
		LastLocation = Location;
		ReattachDistChange = RandRange( ReattachMinDistChange, ReattachMaxDistChange );
	}
	Super.Tick(dt);
}

defaultproperties
{
}
