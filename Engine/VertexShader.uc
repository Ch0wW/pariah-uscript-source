class VertexShader extends ProgrammableShader
	editinlinenew
	collapsecategories
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EVertexStream
{
	EVS_Position,
	EVS_Normal,
	EVS_Diffuse,
	EVS_Specular,
	EVS_TexCoord0,
	EVS_TexCoord1,
	EVS_TexCoord2,
	EVS_TexCoord3,
	EVS_TexCoord4,
	EVS_TexCoord5,
	EVS_TexCoord6,
	EVS_TexCoord7,
	EVS_Tangent0
};

var() editinline string VertexShaderProgram;	// the vertex shader program

/** 
* Indexed array of where the streams will show up
* if StreamMapping[0] == EVS_Normal then v0 will contain the vertex normal
*/
var() editinline array<EVertexStream> StreamMapping;

defaultproperties
{
}
