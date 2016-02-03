class VGDamageablePartPhysics extends VGVehiclePart;

var transient float				FadeTime;	// used to fade out part before destruction

var transient Actor				AttachedActor;	// usually an emitter

simulated function SetupPhysics( VGDamageablePart Part, float PartMass, vector InitialForce );
simulated function DontCollideWith( Actor act );

simulated function InitializePart(
	VGDamageablePart		Part,
	StaticMesh				PartMesh,
	vector					PartLoc,
	rotator					PartRot,
	float					PartMass,
	vector					InitialForce,
	optional class<Actor>	ActClass,		// an actor to attach to this part
	optional name			ActAttachPt		// where to attach this actor
)
{
	local VGVehicle	Vehicle;
	local vector loc;
	local rotator rot;

	Vehicle = Part.Vehicle;
	Vehicle.AddVehicleActor( self );
	SetBase( Vehicle );
	SetStaticMesh( PartMesh );
	SetRelativeLocation( PartLoc );
	SetRelativeRotation( PartRot );
	SetDrawType( DT_StaticMesh );

	// turn on collide with actor's attribute
	//
	SetCollision( True );

	// setup the physics for this object
	//
	SetupPhysics( Part, PartMass, InitialForce );

	// this may change the number of connected bodies
	//
	Vehicle.InvalidateNumBodies();

	// if an actor class was passed in to be created and attached, do that now
	//
	if ( ActClass != None )
	{
		AttachedActor = spawn( ActClass, self,,,);
		AttachedActor.SetBase( Self );
		GetAttachPoint( ActAttachPt, loc, rot );
		AttachedActor.SetRelativeLocation( loc );
		AttachedActor.SetRelativeRotation( rot );
	}
}

simulated function DestroyPart(
	float				WaitTime,
	float				InFadeTime
)
{
	local int i;

	FadeTime = InFadeTime;
	if ( FadeTime > WaitTime )
	{
		FadeTime = WaitTime;
	}
	WaitTime -= FadeTime;
	if ( WaitTime <= 0 )
	{
		WaitTime = 0.05;
	}
	if ( FadeTime > 0 )
	{
		CreateStyle(class'ColorModifier');
		for(i=0;i<StyleModifier.Length;i++)
		{
			ColorModifier(StyleModifier[i]).Color.R = 128;
			ColorModifier(StyleModifier[i]).Color.G = 128;
			ColorModifier(StyleModifier[i]).Color.B = 128;
			ColorModifier(StyleModifier[i]).Color.A = 255;
		}
	}
	SetTimer( WaitTime, False );
}

simulated event Destroyed()
{
	if ( AttachedActor != None )
	{
		AttachedActor.Destroy();
		AttachedActor = None;
	}
}

const	FadeInterval = 0.05;

simulated function Timer()
{
	local int Alpha, i;

	if ( FadeTime > 0 )
	{
		Alpha = ColorModifier(StyleModifier[i]).Color.A;
		if( Alpha < 15 )
		{
			FadeTime = 0;
		}
		else
		{
			Alpha -= FadeInterval * Alpha / FadeTime;
			FadeTime -= FadeInterval;
			AdjustAlphaFade( Alpha );
		}
	}
	if ( FadeTime > 0 )
	{
		SetTimer( FadeInterval, False );
	}
	else
	{
		Destroy();
	}
}

defaultproperties
{
     DrawType=DT_None
}
