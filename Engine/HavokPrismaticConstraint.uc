// Havok Prismatic constraint. This constraint keeps the object
// on a given orientation and lateral movement (along primary axis)

class HavokPrismaticConstraint extends HavokConstraint
	native
	placeable;

#exec Texture Import File=Textures\S_HkPrismaticConstraint.pcx Name=S_HkPrismaticConstraint Mips=Off MASKED=1

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     Texture=Texture'Engine.S_HkPrismaticConstraint'
     bDirectional=True
}
