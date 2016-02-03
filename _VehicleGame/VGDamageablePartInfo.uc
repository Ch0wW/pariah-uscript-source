class VGDamageablePartInfo extends Object
	hidecategories(Object)
	editinlinenew;

enum DamageStepAction
{
	DSA_SwitchMesh,
	DSA_SwitchSkin,
	DSA_CreateConstraint,
	DSA_RemoveConstraint,
	DSA_TurnOnKarma,
	DSA_RelMoveMesh,
	DSA_Destroy,
	DSA_SpawnEmitter,
	DSA_SpawnDamageablePart,
	DSA_AttachMesh,
	DSA_TurnOnKarmaWithAttachedEmitter,
	DSA_ThrottleMovesMesh,
	DSA_SteeringMovesMesh
};

struct DamageStep
{
	var () int					RequiredImpactDamage;
	var () int					RequiredOtherDamage;
	var () DamageStepAction		Action;

	// various values whose use depends on Action
	//
	var () int					IArg1;
	var () int					IArg2;
	var () float				FArg1;
	var () vector				Vec;
	var () rotator				Rot;
};

struct DamageSkins
{
	var () array<Material>	 Skins;
};

struct DamageEffect
{
	var () class<Emitter>	 EmitterClass;
};

var (Damage) export editinline array<DamageSkins>					SkinSets;
var (Damage) array<StaticMesh>										PartMeshes;
var (Damage) array<DamageEffect>									Effects;
var (Damage) array<name>											AttachPoints;
var (Damage) export editinline array<VGDamageablePartInfo>			DamageableParts;
var (Damage) export editinline array<VGDamageablePartConstraint>	ConstraintDescriptions;

// sequence of damage steps that should be performed at various damage levels
//
var (Damage) export editinline array<DamageStep>					DamageSequence;
var (Damage) float													DamageRadius;

defaultproperties
{
}
