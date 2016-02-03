class TexEnvMap extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() enum ETexEnvMapType
{
	EM_WorldSpace,
	EM_CameraSpace,
} EnvMapType;

defaultproperties
{
     TexCoordCount=TCN_3DCoords
}
