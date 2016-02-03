class VGDamageablePartHavok extends VGDamageablePartPhysics;

var transient vector			PendingForce;

var KRigidBodyState				ReceiveState;
var bool						bReceiveStateNew;
var bool						bReceiveStateOnlyVelocityValid;

const ApplyForceTimerSlot = 0;

simulated function SetupPhysics(
	VGDamageablePart		Part,
	float					PartMass,
	vector					InitialForce
)
{
	local VGVehicle	Vehicle;

	Vehicle = Part.Vehicle;

	// now turn on Havok
	//
	SetPhysics( PHYS_Havok );

	// if PartMass not 0, use as mass
	//
	if ( PartMass != 0 )
	{
		HSetMass( PartMass );
	}

	// make it's Karma velocity (both linear and angular) the same as the vehicle
	//
	Vehicle.HGetRigidBodyState( ReceiveState );
	bReceiveStateNew = True;
	bReceiveStateOnlyVelocityValid = True;

	// if InitialForce is non zero, use it as a force
	//
	if ( InitialForce != vect(0,0,0) )
	{
		// vec is relative to vehicle
		//
		PendingForce = InitialForce << Vehicle.Rotation;
		SetMultiTimer( ApplyForceTimerSlot, 0.1, False );
	}
}

simulated function DontCollideWith( Actor act )
{
}

// This event is for updating the state (position, velocity etc.) of the part's karma
// body 
simulated event bool HUpdateState(out KRigidBodyState newState)
{
	local KRigidBodyState	 CurrentState;

	if(!bReceiveStateNew)
		return False;

	if(bReceiveStateOnlyVelocityValid)
	{
		HGetRigidBodyState( CurrentState );
		ReceiveState.Position = CurrentState.Position;
		ReceiveState.Quaternion = CurrentState.Quaternion;
		bReceiveStateOnlyVelocityValid = False;
	}
	newState = ReceiveState;
	bReceiveStateNew = False;

	return True;
}

event bool HApplyForce( out vector Force, out vector Torque )
{
	if ( PendingForce != vect(0,0,0) )
	{
		Force = PendingForce;
		return true;
	}
	else
	{
		return false;
	}
}

event MultiTimer( int Slot )
{
	switch ( Slot )
	{
	case ApplyForceTimerSlot:
		PendingForce = vect(0,0,0);
		break;
	}
}

defaultproperties
{
     Begin Object Class=HavokParams Name=HavokDamageablePart
         GravScale=1.700000
         CollisionLayer=HK_LAYER_FAST_DEBRIS
         StartEnabled=True
         Restitution=0.600000
     End Object
     HParams=HavokParams'VehicleGame.HavokDamageablePart'
     bDisableKarmaEncroacher=True
}
