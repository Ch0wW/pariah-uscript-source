//
// This is an instance of a programmable shader which is basically a reference
// to the programmable shader combined with a set of constants
// 
class ProgrammableShaderInstance extends Object
	editinlinenew
	native;

enum EShaderConstantType
{
	ESC_Unused,							// not used
	ESC_Constant,						// constant is defined explicitly defined
	ESC_WorldViewProjMatrix,			// 4 registers
	ESC_WorldMatrix,					// 4 registers
	ESC_WorldViewMatrix,				// 4 registers
	ESC_InvWorldRotMatrix,				// 3 registers
	ESC_Texture0Matrix,					// 3 registers
	ESC_Texture1Matrix,
	ESC_Texture2Matrix,
	ESC_Texture3Matrix,
	ESC_Texture4Matrix,
	ESC_Texture5Matrix,
	ESC_Texture6Matrix,
	ESC_Texture7Matrix,
	ESC_Texture0Size,					// 1 registers
	ESC_Texture1Size,
	ESC_Texture2Size,
	ESC_Texture3Size,
	ESC_Texture4Size,
	ESC_Texture5Size,
	ESC_Texture6Size,
	ESC_Texture7Size,
	ESC_RenderTargetSize,
	ESC_RealTime,
	ESC_GameTime,
	ESC_NoMoreUsed						// this register and all after are unused
};

/**
* Used to specify constants for a programmable shader. 
*/ 
struct native ShaderConstantInfo
{
	var() EShaderConstantType Type;
	var() Plane Value;
};

var() editinline ProgrammableShader		Shader;
var() array<ShaderConstantInfo>			Constants;

defaultproperties
{
}
