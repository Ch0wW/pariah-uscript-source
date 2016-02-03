class TireEffectInfo extends SurfaceEffectInfo
	hidecategories(Object)
	native
	editinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum ETireEffectControlType
{
	TEC_TireSlip,
	TEC_TireSpeed
};

var (Effect) ETireEffectControlType			ControlType;
var (Effect) Range							TireSlipRange;
var (Effect) float							TireSlipScale;
var (Effect) Range							TireSpeedRange;
var (Effect) float							TireSpeedScale;

defaultproperties
{
     TireSlipRange=(Min=-1.000000,Max=-1.000000)
     TireSpeedRange=(Min=-1.000000,Max=-1.000000)
}
