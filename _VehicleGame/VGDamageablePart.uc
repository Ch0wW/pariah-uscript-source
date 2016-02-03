class VGDamageablePart extends Info
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// vehicle to which part is attached and it's index into
// the vehicle's attached mesh array
//
var VGVehicle					Vehicle;	
var int							VehicleAttachedMeshIndex;

var VGDamageablePartInfo		PartInfo;	// info on how part behaves

var array<int>					StepsDone;	// which steps have been done so far

struct native CreatedConstraint
{
	var int			ID;
	var Actor		Constraint;
};

var array<CreatedConstraint>	CreatedConstraints;	// created constraints and associated ids

var VGDamageablePartPhysics		CreatedPhysicsPart;	// if this part becomes a physical body

enum ControlledMotionSource
{
	CMS_Throttle,
	CMS_Steering
};

struct native PartControlledMotion
{
	var ControlledMotionSource	Source;
	var float					SourceOffset;
	var float					DeltaScale;
	var vector					TranslationScale;
	var rotator					RotationScale;
};

var array<PartControlledMotion>	MotionControllers;
var transient vector			RestOffset;
var transient rotator			RestRotation;

function InitializePart( VGVehicle Owner, VGDamageablePartInfo Info )
{
	local int i;

	Disable('Tick');
	Vehicle = Owner;
	PartInfo = Info;
	StepsDone.Length = PartInfo.DamageSequence.Length;
	for ( i = 0; i < StepsDone.Length; i++ )
	{
		StepsDone[i] = 0;
	}
	UpdatePartDamage( 0, 0 );
}

event UpdatePartDamage(
	float	ImpactDamage,
	float	OtherDamage
)
{
	local int					s, c;
	local Actor					con;
	local Emitter				e;
	local vector				loc;
	local rotator				rot;
	local class<Actor>			aclass;
	local name					ap;

	// go through all steps in damage sequence and execute any that need
	// to be done based on current damage values
	//
	for ( s = 0; s < PartInfo.DamageSequence.Length; s++ )
	{
		if ( 0 == StepsDone[s] &&
			 ( ImpactDamage > PartInfo.DamageSequence[s].RequiredImpactDamage ||
			   OtherDamage >= PartInfo.DamageSequence[s].RequiredOtherDamage ) )
		{
			switch ( PartInfo.DamageSequence[s].Action )
			{
			case DSA_SwitchMesh:
				// IArg1 used as index into PartMeshes
				// Vec used as relative position
				// Rot used as relative rotation
				//
				if ( VehicleAttachedMeshIndex < 0 )
				{
					VehicleAttachedMeshIndex = Vehicle.NewAttachedStaticMesh();
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].UseBaseRotation = True;
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].AlwaysUpdatePosition = True;
				}
				Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseOffset = PartInfo.DamageSequence[s].Vec;
				Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseRotation = PartInfo.DamageSequence[s].Rot;
				Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].StaticMesh = PartInfo.PartMeshes[PartInfo.DamageSequence[s].IArg1];
				break;
			case DSA_AttachMesh:
				// IArg1 used as index into PartMeshes
				// IArg2 used as index into AttachPoints
				// Vec is used as a positional offset from attach point
				// Rot is used as a rotational offset from attach point orientation
				//
				if ( Vehicle.GetAttachPoint( PartInfo.AttachPoints[PartInfo.DamageSequence[s].IArg2], loc, rot ) )
				{
					if ( VehicleAttachedMeshIndex < 0 )
					{
						VehicleAttachedMeshIndex = Vehicle.NewAttachedStaticMesh();
						Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].UseBaseRotation = True;
						Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].AlwaysUpdatePosition = True;
					}
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseOffset = loc + PartInfo.DamageSequence[s].Vec;
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseRotation = rot + PartInfo.DamageSequence[s].Rot;
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].StaticMesh = PartInfo.PartMeshes[PartInfo.DamageSequence[s].IArg1];
				}
				else
				{
					warn( "RJ: DSA_AttachMesh couldn't find attach point "$PartInfo.AttachPoints[PartInfo.DamageSequence[s].IArg2] );
				}
				break;
			case DSA_SwitchSkin:
				// IArg1 used as index into SkinSets
				//
				warn( "RJ: DSA_SwitchSkin not implemented yet" );
				break;
			case DSA_CreateConstraint:
				// IArg1 used as index into ConstraintDescriptions
				// IArg2 used as ID for created constraint
				// Vec used as relative position of constraint
				// Rot used as relative rotation of constraint
				//
				if ( CreatedPhysicsPart != None )
				{
					con = PartInfo.ConstraintDescriptions[PartInfo.DamageSequence[s].IArg1].CreateAndActivateConstraint(
						self, PartInfo.DamageSequence[s].Vec, PartInfo.DamageSequence[s].Rot
						);

					// add to list of created constraints
					//
					CreatedConstraints.Length = CreatedConstraints.Length + 1;
					CreatedConstraints[CreatedConstraints.Length - 1].ID = PartInfo.DamageSequence[s].IArg2;
					CreatedConstraints[CreatedConstraints.Length - 1].Constraint = con;
					Vehicle.AddVehicleActor( con );

					// this will change the number of connected bodies
					//
					Vehicle.InvalidateNumBodies();
				}
				else
				{
					warn( "RJ: DSA_CreateConstraint needs to be preceeded by DSA_TurnOnKarma" );
				}
				break;
			case DSA_RemoveConstraint:
				// IArg2 used as ID for constraints to remove
				//
				for ( c = 0; c < CreatedConstraints.Length; c++ )
				{
					if ( CreatedConstraints[c].Constraint != None && 
						 CreatedConstraints[c].ID == PartInfo.DamageSequence[s].IArg2 )
					{
						CreatedConstraints[c].Constraint.Destroy();
						CreatedConstraints[c].Constraint = None;

						// this will change the number of connected bodies
						//
						Vehicle.InvalidateNumBodies();
					}
				}
				break;
			case DSA_TurnOnKarma:
			case DSA_TurnOnKarmaWithAttachedEmitter:
				// FArg1 used as mass if non-zero
				// Vec used as a force to be applied after turning on Karma
				// IArg1 used as index into Effects - DSA_TurnOnKarmaWithAttachedEmitter ONLY
				// IArg2 used as index into AttachPoints - DSA_TurnOnKarmaWithAttachedEmitter ONLY
				//
				if ( VehicleAttachedMeshIndex >= 0 && CreatedPhysicsPart == None )
				{
					// stop using the associated attached mesh
					//
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].Unused = True;

					if ( PartInfo.DamageSequence[s].Action == DSA_TurnOnKarmaWithAttachedEmitter )
					{
						aclass = PartInfo.Effects[PartInfo.DamageSequence[s].IArg1].EmitterClass;
						ap = PartInfo.AttachPoints[PartInfo.DamageSequence[s].IArg2];
					}
					else
					{
						aclass = None;
						ap = '';
					}
					if ( Level.bNoHavok )
					{
						// create a karma actor and initialize it so that it is identical to the
						// attached static mesh
						//CreatedPhysicsPart = Vehicle.Spawn( class'VGDamageablePartKarma', Vehicle );
					}
					else
					{
						// create a havok actor and initialize it so that it is identical to the
						// attached static mesh
						CreatedPhysicsPart = Vehicle.Spawn( class'VGDamageablePartHavok', Vehicle );
					}
					CreatedPhysicsPart.InitializePart(
						self,
						Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].StaticMesh,
						Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseOffset,
						Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseRotation,
						PartInfo.DamageSequence[s].FArg1,
						PartInfo.DamageSequence[s].Vec,
						aclass, ap
					);
					VehicleAttachedMeshIndex = -1;

				}
				break;
			case DSA_RelMoveMesh:
				// Vec used as relative offset
				//
				if ( VehicleAttachedMeshIndex >= 0 )
				{
					Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseOffset += PartInfo.DamageSequence[s].Vec;
				}
				break;
			case DSA_Destroy:
				// IArg1 used as number of seconds until destruction
				// FArg1 used as amount of fade time
				//
				if ( CreatedPhysicsPart != None )
				{
					CreatedPhysicsPart.DestroyPart(
						PartInfo.DamageSequence[s].IArg1,	// wait time
						PartInfo.DamageSequence[s].FArg1	// fade time
					);
				}
				else
				{
					if ( PartInfo.DamageSequence[s].FArg1 > 0 )
					{
						warn( "RJ: fading not implemented for non-karma damage parts yet" );
					}
					SetTimer( PartInfo.DamageSequence[s].IArg1, False );
				}
				break;
			case DSA_SpawnEmitter:
				// IArg1 used as index into Effects
				// Vec used as relative position
				// Rot used as relative rotation
				e = spawn( PartInfo.Effects[PartInfo.DamageSequence[s].IArg1].EmitterClass, Vehicle,,,);
				if ( e != None )
				{
					Vehicle.AddVehicleActor( e );
					e.SetBase( Vehicle );
					e.SetRelativeLocation( PartInfo.DamageSequence[s].Vec );
					e.SetRelativeRotation( PartInfo.DamageSequence[s].Rot );
				}
				break;
			case DSA_SpawnDamageablePart:
				// IArg1 used as index into DamageableParts
				if ( PartInfo.DamageSequence[s].IArg1 < PartInfo.DamageableParts.Length )
				{
					Vehicle.CreateDamageablePart( PartInfo.DamageableParts[PartInfo.DamageSequence[s].IArg1] );
				}
				else
				{
					warn( "RJ: out of range part index ("$PartInfo.DamageSequence[s].IArg1$") for DSA_SpawnDamageablePart" );
				}
				break;
			case DSA_ThrottleMovesMesh:
				// throttle goes from -1 to 1
				// - Vec is used as the maximum distance moved at full throttle
				// - Rot is used as the maximum rotation at full throttle
				// - FArg1 is used as an offset to apply to the throttle value before it is clamped to [-1,1] and used
				// - IArg1 is used as a "damping" factor, it goes from 0-100 where 0 is no damping and 100 basically
				//   results in no motion
			case DSA_SteeringMovesMesh:
				// steering goes from -1 to 1
				// - Vec is used as the maximum distance moved at full steering
				// - Rot is used as the maximum rotation at full steering
				// - FArg1 is used as an offset to apply to steering value before it is clamped to [-1,1] and used
				// - IArg1 is used as a "damping" factor, it goes from 0-100 where 0 is no damping and 100 basically
				//   results in no motion
				if ( VehicleAttachedMeshIndex >= 0 )
				{
					c = MotionControllers.Length;
					if ( c == 0 )
					{
						RestOffset = Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseOffset;
						RestRotation = Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].BaseRotation;
					}
					MotionControllers.Length = c + 1;
					if ( PartInfo.DamageSequence[s].Action == DSA_ThrottleMovesMesh )
					{
						MotionControllers[c].Source = CMS_Throttle;
					}
					else
					{
						MotionControllers[c].Source = CMS_Steering;
					}
					MotionControllers[c].SourceOffset = PartInfo.DamageSequence[s].FArg1;
					MotionControllers[c].DeltaScale = (100.0 - PartInfo.DamageSequence[s].IArg1) / 100.0;
					MotionControllers[c].TranslationScale = PartInfo.DamageSequence[s].Vec;
					MotionControllers[c].RotationScale = PartInfo.DamageSequence[s].Rot;
					Enable('Tick');
				}
				break;
			}
			StepsDone[s] = 1;
		}
	}
}

simulated function DontCollideWith( Actor act )
{
	if ( CreatedPhysicsPart != None )
	{
		CreatedPhysicsPart.DontCollideWith( act );
	}
}

simulated function Timer()
{
	Destroy();
}

// vehicle calls this when it receives damage that should be passed onto
// damageable parts
//
function bool VehicleDamage(
	int					Damage,
	Pawn				InstigatedBy,
	vector				HitLocation,
	vector				Momentum,
	class<DamageType>	DamageType,
	out float			ImpactDamage,
	out float			OtherDamage
)
{
	local vector	v;
	local float		DistSq, RadSq, PartDamage;
	local vector	PartLoc;
	local staticMesh Mesh;

	glog ( RJ, "VehicleDamage("$Damage$") called with HL="$HitLocation );

	if ( CreatedPhysicsPart != None )
	{
		PartLoc = CreatedPhysicsPart.Location;
		Mesh = CreatedPhysicsPart.StaticMesh;
	}
	else if ( VehicleAttachedMeshIndex >= 0 && !Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].Unused )
	{
		PartLoc = Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].Location;
		Mesh = Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].StaticMesh;
	}
	else
	{
		// nothing to damage
		return False;
	}

	// decide how much if any of this damage should be applied to
	// this part
	//
	v = HitLocation - PartLoc;
	DistSq = v Dot v;
	RadSq = Square( PartInfo.DamageRadius );
	if ( DistSq < RadSq )
	{
		// normalize damage into [0-100] and scale based on distance from hit location
		//
		PartDamage = 100.0 * Damage * ((RadSq - DistSq) / RadSq) / Vehicle.default.Health;
		if ( DamageType == class'RammingDamage' )
		{
			ImpactDamage = PartDamage;
			glog ( RJ, "Mesh="$Mesh$",Hit="$HitLocation$",DistSq="$distSq$",ImpactDamage="$ImpactDamage$"("$PartDamage$"/"$Damage$")" );
		}
		else
		{
			OtherDamage = PartDamage;
			glog ( RJ, "Mesh="$Mesh$",Hit="$HitLocation$",DistSq="$distSq$",OtherDamage="$OtherDamage$"("$PartDamage$"/"$Damage$")" );
		}
		return True;
	}
	else
	{
		return False;
	}
}

simulated event Destroyed()
{
	local int c;

	// destroy created constraints and any karma part still hanging around
	//
	for ( c = 0; c < CreatedConstraints.Length; c++ )
	{
		if ( CreatedConstraints[c].Constraint != None )
		{
			CreatedConstraints[c].Constraint.Destroy();
			CreatedConstraints[c].Constraint = None;
		}
	}
	if ( CreatedPhysicsPart != None )
	{
		CreatedPhysicsPart.Destroy();
		CreatedPhysicsPart = None;
	}

	// stop using the associated attached mesh
	//
	if ( VehicleAttachedMeshIndex >= 0 && Vehicle != None )
	{
		Vehicle.AttachedStaticMeshes[VehicleAttachedMeshIndex].Unused = True;
		VehicleAttachedMeshIndex = -1;
	}

	// this may change the number of connected bodies
	//
	Vehicle.InvalidateNumBodies();
	
	PartInfo = None;
}

defaultproperties
{
     VehicleAttachedMeshIndex=-1
}
