class VGHavokVehicle extends VGVehicle
	abstract
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
// (cpptext)
// (cpptext)

var float			OutputThrottle;
var float			OutputSteering;

native function InitializeHavokVehicle();

event UpdateRiderEffects()
{
	if(Driver != None)
	{
		Driver.PawnSteering = OutputSteering;
	}
}

simulated function InitializeVehicle()
{
	Super.InitializeVehicle();

	SetPhysics( PHYS_Havok );
	InitializeHavokVehicle();
}

simulated event KPawnArtUpdateParams()
{
	Super.KPawnArtUpdateParams();
}

simulated function DriverEntered()
{
	Super.DriverEntered();
}

simulated function DriverExited()
{
	Super.DriverExited();
	OutputThrottle = 0;
	OutputSteering = 0;
}

event HImpact( actor other, vector pos, vector impactVel, vector impactNorm, Material HitMaterial )
{
	ImpactEvent(other, pos, impactVel, impactNorm, HitMaterial );
}

defaultproperties
{
     FlipTorque=400.000000
     FlipTimeScale=0.500000
     DefaultWeapons(0)="VehicleWeapons.Puncher"
}
