class DynamicLight extends Light
	placeable
	native;

var (LightAttenuation) enum EAttenuationType
{
	DLA_Default,			// use standard unreal attenuation -- ignore these attenuation settings
	DLA_Radius,				// use these attenuation settings scaled by light radius
	DLA_Absolute			// use these attenuation settings independant of light radius
} AttenuationType;

var (LightAttenuation) float Attenuation0;
var (LightAttenuation) float Attenuation1;
var (LightAttenuation) float Attenuation2;

// attenuation starts to get forced to zero when distance from light is within FalloffRange of light's Radius
// - if FalloffRange.Max is 0, attenuation will drop to zero when distance is >= light radius
// - this doesn't work if the D3D fixed function pipeline is used
var (LightAttenuation) range FalloffRange;

var (LightAttenuation) enum ESpotlightType
{
	DLST_Default,			// use standard unreal spotlight -- ignore SpotlightConeAngle
	DLST_LinearFalloff,		// linear falloff from SpotlightConeAngle.Min to SpotlightConeAngle.Max
	DLST_QuadraticFalloff	// quadratic falloff from SpotlightConeAngle.Min to SpotlightConeAngle.Max
} SpotlightType;

var (LightAttenuation) range SpotlightConeAngle;

defaultproperties
{
     SpotlightConeAngle=(Min=60.000000,Max=90.000000)
     bStatic=False
     bDynamicLight=True
     bMovable=True
}
