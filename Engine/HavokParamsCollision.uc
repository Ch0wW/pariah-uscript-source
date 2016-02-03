//=============================================================================
// The Havok Collision parameters class.
// This provides 'extra' parameters needed to create Havok collision for this Actor.
// You can _only_ turn on collision, not dynamics.
// NB: All parameters are in HAVOK scale!
//=============================================================================

class HavokParamsCollision extends Object
	editinlinenew
	native;

// Used internally for Havok stuff - DO NOT CHANGE!
var const transient int				HavokData;

var() float		Friction;
var() float		Restitution;		// 'Bouncy-ness' - Normally between 0 and 1
var() float		ImpactThreshold;	// threshold velocity magnitude to call HImpact event
var() bool		bWantContactEvent;	// if true, call HHandleContact event for this actor		

enum EHavokCollisionLayer
{
	HK_LAYER_NONE,
	HK_LAYER_STATIC,
	HK_LAYER_DYNAMIC,		
	HK_LAYER_PLAYER,
	HK_LAYER_AI,
	HK_LAYER_KEYFRAME,
	HK_LAYER_DEBRIS,
	HK_LAYER_FAST_DEBRIS,
	HK_LAYER_EFFECTS,		// purely for visual effect
	HK_LAYER_SEMI_STATIC	// doesn't block fast debris
};

defaultproperties
{
     Friction=1.000000
     ImpactThreshold=1000000.000000
}
