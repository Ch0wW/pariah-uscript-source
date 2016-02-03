// HavokSkeletalSystem that can be blended with it's associated animated skeletal mesh
//
class HavokBlendedSkeletalSystem extends HavokSkeletalSystem
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const transient int BlendedSkeletonSystemPtr;

// rigid body bones that stay keyframed to the animation bones
var() array<name> KeyframedBones;

var() enum EHavokSkelBlending
{
	HSB_None,				// no blending
	HSB_GlobalGain,			// set all gains to same value
	HSB_GlobalScaleGain,	// scale all gains by same value
	HSB_BoneGain,			// set gains for bones in GainBones
	HSB_BoneScaleGain		// scale gains for bones in GainBones
} BlendType;

// global gain values 
// if BlendType == HSB_GlobalGain they replace all non-keyframed bones gain values
// if BlendType == HSB_GlobalScaleGain they modulate all non-keyframed bones gain values
// if BlendType == HSB_BoneGain they replace gain values for bones in GainBones
// if BlendType == HSB_BoneScaleGain they modulate gain values for bones in GainBones
//
var() float		GlobalVelocityGain;
var() float		GlobalHierarchyGain;

var() array<name>	BoneGainBones;
var() int			BoneGainFalloff;	// number of surrounding bones to adjust

// maximum velocities for rigidbodies making up the skeleton
var() float		MaxLinearVelocity;
var() float		MaxAngularVelocity;		// radians/sec

var const transient bool	bAllBonesKeyframed;

defaultproperties
{
     GlobalVelocityGain=1.000000
     GlobalHierarchyGain=1.000000
     MaxLinearVelocity=20000.000000
     MaxAngularVelocity=100.000000
}
