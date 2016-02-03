class VGDamageablePartConstraint extends Object
	abstract;

function Actor CreateConstraint( VGDamageablePart Part, vector VehOffset, rotator VehRot );

function Actor CreateAndActivateConstraint( VGDamageablePart Part, vector VehOffset, rotator VehRot )
{
	local Actor				Con;
	local HavokConstraint	HCon;

	Con = CreateConstraint( Part, VehOffset, VehRot );
	HCon = HavokConstraint( Con );
	if ( HCon != None )
	{
		HCon.SetPhysics( PHYS_Havok );
	}

	return Con;
}

simulated function vector SetupReferenceFrames(	// returns part offset
	Actor					Con,
	VGDamageablePart		Part,
	vector					VehOffset,
	rotator					VehRot
)
{
	local vector PartOffset;

	return PartOffset;
}

defaultproperties
{
}
