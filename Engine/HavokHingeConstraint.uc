// Havok Hinge constraint. This enforces a postional constraint 
// about the pivot and reduces the freedom of the object further
// by only allowing rotation about the given primary axis.

class HavokHingeConstraint extends HavokConstraint
	native
	placeable;

#exec Texture Import File=Textures\S_HkHingeConstraint.pcx Name=S_HkHingeConstraint Mips=Off MASKED=1

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     Texture=Texture'Engine.S_HkHingeConstraint'
     bDirectional=True
}
