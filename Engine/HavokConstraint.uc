// Havok base class for Constraints.
// Some constraints use only a sub set of the given data.
// The constraint is between hkAttachedActorA and option hkAttachedActorB.
// You can also specify option sub parts of the actors by name. The subparts
// are only taken into account if the Mesh of the attached actor is skeletal 
// and the Physics of the attached Actor is PHYS_HavokSkeletal. In that way
// you can constrain ragdolls together, or to other rigid bodies or the world.


class HavokConstraint extends HavokActor
	abstract
	placeable
	native;

#exec Texture Import File=Textures\S_HkConstraint.pcx Name=S_HkConstraint Mips=Off MASKED=1

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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var transient const int hkConstraintPtr;

// Actors joined effected by this constraint (could be NULL for 'World')
var(HavokConstraint) edfindable Actor hkAttachedActorA; // may be a sub system, like a skeletal mesh. If so, the subpoart name will be used.
var(HavokConstraint) name hkAttachedSubPartA; // usually a bone name
var(HavokConstraint) edfindable Actor hkAttachedActorB; // may be a sub system, like a skeletal mesh. If so, the subpoart name will be used.
var(HavokConstraint) name hkAttachedSubPartB; // usually a bone name

// Disable collision between joined
var(HavokConstraint) bool  bDisableCollisions; // not implimented yet
// Breakable constraints
var(HavokConstraint) float fMaxForceToBreak; // 0 == doesn't break
// Varing stength constraints
var(HavokConstraint) float fSpecificStrength; // 0 = no special (malleable) tau (strength)
var(HavokConstraint) float fSpecificDamping; // 0 = no specail (malleable) damping.

var(HavokConstraint) enum EAutoComputeConstraint
{
	HKC_DontAutoCompute, // Just use the Local values as specified.
	HKC_AutoComputeFromThisActor, // This is most common in the editor. Compute both A and B local values from the transform for this Constraint Actor.
	HKC_AutoComputeAFromB,  // Compute the local values for A from the values given for B
	HKC_AutoComputeBFromA   // Compute the local values for B from the values given for A
} AutoComputeLocals;

// Constraint position/orientation, as defined in each body's local reference frame
// Local to actor (or the actor subpart space if name given, ie: bone name), and are in Unreal space.
// May be Autocomputed from one another, or from the constraint actor itself.

// BodyA frame
var(HavokConstraint) vector LocalPosA;  // Local pivot point in A
var(HavokConstraint) vector LocalAxisA;  // Primary constraint axis in A
var(HavokConstraint) vector LocalPerpAxisA; // Secondary (perpendicular to Primary) axis for A

// BodyB frame
var(HavokConstraint) vector LocalPosB;  // Local pivot point in B
var(HavokConstraint) vector LocalAxisB; // Primary constraint axis in B
var(HavokConstraint) vector LocalPerpAxisB; // Secondary (perpendicular to Primary) axis for B

// Call this function when you change a parameter to get 
// it to actually take effect (it intenally recreates the constraint)
native function UpdateConstraintDetails();

defaultproperties
{
     LocalAxisA=(X=1.000000)
     LocalPerpAxisA=(Y=1.000000)
     LocalAxisB=(X=1.000000)
     LocalPerpAxisB=(Y=1.000000)
     AutoComputeLocals=HKC_AutoComputeFromThisActor
     bDisableCollisions=True
     Texture=Texture'Engine.S_HkConstraint'
     DrawType=DT_Sprite
     bHidden=True
     bNoDelete=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockKarma=False
}
