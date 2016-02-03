class SPAIProtectorDrone extends SPAIDrone;


var Actor InterceptTarget;
var Vector InterceptLocation;

var float MaxInterceptDist;

function class<SPPawnDrone> GetDronePawnClass()
{
	return class'SPPawnProtectorDrone';
}


function bool CaresAbout(Actor Other)
{
	if(Other.IsA('VGRocket') || Other.IsA('GrenadeProjectile') )
	{
		return true;	
	}
	return false;
}

function EnteredArea(Actor Other)
{
	local float dir;

	dir = Normal(Pawn.Location - Other.Location) dot Normal(Other.Velocity);

	if(dir <= 0) //rocket is on exact plane as Drone, or moving past, can't possibly intercept
		return;


	InterceptLocation = GetInterceptPoint( Other.Location, Other.Velocity );
	InterceptTarget = Other;

	GotoState('Intercepting', 'BEGIN');
}

function Vector GetInterceptPoint(Vector Start, Vector Dir)
{
	local Vector PlaneNormal;

	PlaneNormal = Normal(-Dir);
	return Start + Dir * ( ( (Pawn.Location - Start) dot PlaneNormal) / ( Dir dot PlaneNormal ) );
}

state Intercepting
{
	function BeginState()
	{
		// periodically recheck the intercept
		SetTimer(0.025, true);
	}

	function EndState()
	{
		Pawn.Airspeed=Pawn.default.Airspeed;
		Pawn.AccelRate=Pawn.default.AccelRate;
		Pawn.bFlyingBrake=false;
		SetTimer(0, false);
	}

	function Timer()
	{
		if(InterceptTarget != none)
			InterceptLocation = GetInterceptPoint(InterceptTarget.Location, InterceptTarget.Velocity);
	}

BEGIN:
	Pawn.Airspeed=10000;
	Pawn.AccelRate=60000.000000;

	MoveTo(InterceptLocation, InterceptTarget);
	Pawn.Airspeed=Pawn.default.Airspeed;
	Pawn.AccelRate=Pawn.default.AccelRate;
	Pawn.bFlyingBrake=true;

	sleep(2);

	PickNewAction();
}

state DisabledByEMP
{
	function bool CaresAbout(Actor Other)
	{
		return false;
	}

	function BeginState()
	{
		Pawn.SetPhysics( PHYS_Falling );
		SPPawnProtectorDrone(Pawn).StartEMP();
//		SetTimer(5, false);
	}

	function Timer()
	{
		GotoState('DroneWander','BEGIN');
	}

	event bool NotifyLanded(vector HitNormal)
	{
		Pawn.SetPhysics( PHYS_None );
		return false;
	}

	function EndState()
	{
		Pawn.SetPhysics(PHYS_Flying);
		SPPawnProtectorDrone(Pawn).EndEMP();
	}
}

function bool CanIntercept( float Dist, float Time )
{
	local float t; 

	t = Dist / Pawn.AirSpeed;

	log("CanIntercept got "$Dist@t@Time);

	if(t < Time)
		return true;
	else 
		return false;

}

defaultproperties
{
     MaxInterceptDist=1000.000000
}
