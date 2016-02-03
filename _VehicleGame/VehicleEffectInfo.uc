class VehicleEffectInfo extends ControlledEffectInfo
	hidecategories(Object)
	native
	editinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EVehicleEffectControlType
{
	VEC_EngineRPS,
	VEC_EngineTorque,
	VEC_VehicleSpeed,
	VEC_Turbo,
	VEC_TurboTime,
	VEC_TurboTimeLeft,
	VEC_Throttle,
	VEC_Health
};

struct native ControlRangeVector
{
	var () bool						Enabled;	
	var () rangevector				RangeBase;
	var () rangevector				RangeScale;
};

struct native ControlRangeModifier
{
	var () bool						Enabled;	
	var () range					RangeBase;
	var () range					RangeScale;
};

struct native ControlFloatModifier
{
	var () bool						Enabled;
	var () float					Base;
	var () float					Scale;
};

var (Effect) EVehicleEffectControlType	ControlType;
var (Effect) range						ControlRange;
var (Effect) range						ControlClamp;
var (Effect) float						PPSBase;
var (Effect) float						PPSScale;
var (Effect) float						PPSSpeedCompensation;
var (Effect) ControlRangeVector			StartVelocityRange;
var (Effect) ControlRangeModifier		LifetimeRange;
var (Effect) ControlFloatModifier		FadeOutStartTime;
var (Effect) ControlFloatModifier		FadeInEndTime;

// hopefully nobody will really want this as a value
const UnsetFloatValue = -537;

// UnsetFloatValue doesn't work in defaultproperties
//

defaultproperties
{
     ControlRange=(Min=-537.000000,Max=-537.000000)
     ControlClamp=(Min=-537.000000,Max=-537.000000)
}
