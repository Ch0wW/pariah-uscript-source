class SurfaceEffectInfo extends ControlledEffectInfo
	abstract
	native
	hidecategories(Object)
	editinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var (Effect) array<Actor.ESurfaceTypes>		SurfaceTypes;
var (Effect) bool							SurfaceTypesAreExcluded;

// return true if emitter should keep running
simulated event bool UpdateSubEmitters(
	Actor					Actor,
	Emitter					TheEmitter
);

simulated native function UpdateEmitter(
	Actor					Actor,
	Emitter					TheEmitter,
	Actor.ESurfaceTypes		SurfaceType,
	optional vector			RelLoc,
	optional bool			bUseRelLoc
);

defaultproperties
{
}
