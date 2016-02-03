class HavokParams extends HavokParamsCollision
	editinlinenew
	native;

var() float		Mass;
var() bool		StabilizedInertia;	// false by default, but you can use this special Inertia computation mode for more unstable configurations like long thin objects
var() float		LinearDamping;
var() float		AngularDamping;

var() bool		StartEnabled;

var() bool			Keyframed;			// transform taken from Unreal when Actor moves? Use this mode for Movers etc.
var transient bool	Keyframing;			// used internally to determine if this body is actively being keyframed

var() vector	StartLinVel;		// Initial linear velocity for actor
var() vector	StartAngVel;		// Initial angular velocity for actor

var() float		GravScale;		    // Scale how gravity affects this actor.
var() float		Buoyancy;			// Applies in water volumes. 0 = no buoyancy. 1 = neutrally buoyant

var() EHavokCollisionLayer	CollisionLayer;

defaultproperties
{
     Mass=1.000000
     LinearDamping=0.200000
     AngularDamping=0.200000
     GravScale=1.000000
     CollisionLayer=HK_LAYER_DYNAMIC
}
