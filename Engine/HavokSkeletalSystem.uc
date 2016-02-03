// Havok physical system, imported from a HKE file (from modellers such as Max or Maya) 
// and associated with the skeletal mesh by name. This is most commonly used for
// ragdolls and rigidbody based deformable meshes.

class HavokSkeletalSystem extends HavokParamsCollision
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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const transient int RigidBodySystemNumber;  //the system number (group for rbs in the level) for this body. Set internally. Do not change.
var const transient int RigidBodyRootBoneIndex; //the the index into the skel mesh of the physics root bone. Set internally. Do not change.
var const transient int RigidBodyLastBoneIndex; //the the index into the skel mesh of the physics root bone. Set internally. Do not change.

// internal pointers
var const transient int AnimationHierarchyPtr;
var const transient int AnimationSkeletonPtr;
var const transient int RigidbodyHierarchyPtr;
var const transient int SkeletonSystemPtr;
var const transient int RigidbodyToAnimationMapperPtr;

enum HavokSkeletalSystemState
{
	HSSS_Uninitialized,
	HSSS_Stasis,			
	HSSS_Setup,
	HSSS_PoseSet,
	HSSS_PoseUpdated,
	HSSS_Frozen
};

var const transient HavokSkeletalSystemState	SkelState;

var() string			SkeletonPhysicsFile;// HKE to use for this skeletal actor.

var() float				GravScale;			// Scale how gravity affects this skeleton.

var() float				MaxLinVel;			// maximum linear velocity for skeleton - 0 for no maximum

// internal
var	bool				bDontSyncBones;

var	transient vector	StartLinVel;		// Initial linear velocity for actor
var	transient vector	StartAngVel;		// Initial angular velocity for actor

// If ShotStrength > 0, the skeletal system will try to apply an impulse
// to the skeleton
// - if ShotBone is valid, the impulse is applied to the bone, ShotVec0 is used as the
//   impulse location and ShotVec1 is the impulse direction with strength of ShotStrength
// - if ShotBone is empty, we check the line from ShotVec0 -> ShotVec1 against the skeleton,
//   and apply an impulse with magnitude ShotStrength if we hit a bone.
//
// The ShotStrength is reset to zero afterwards
//
var transient name		ShotBone;
var transient vector	ShotVec0; 
var transient vector	ShotVec1;
var transient float		ShotStrength;

// dumb flag used to record whether the ragdoll was ever simulated (moved)
//
var transient bool		bWasSimulated;

defaultproperties
{
     GravScale=1.000000
}
