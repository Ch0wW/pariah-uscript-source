class HardwareMaterial extends RenderedMaterial
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EHardwareBlendMode
{
	HBM_Zero,
	HBM_One,
	HBM_SourceColor,
	HBM_InvertSourceColor,
	HBM_SourceAlpha,
	HBM_InvertSourceAlpha,
	HBM_DestinationColor,
	HBM_InvertDestinationColor,
	HBM_DestinationAlpha,
	HBM_InvertDestinationAlpha,
	HBM_SourceAlphaSat
};

enum ETexFilterType	
{
	TFT_Default,	// whatever the default is
	TFT_None,
	TFT_Point,
	TFT_Linear
};

struct native TextureStage
{
	var() ETexFilterType			MipFilter;
	var() ETexFilterType			MinFilter;
	var() ETexFilterType			MagFilter;
	var() BitmapMaterial			Texture;
};

struct native RenderPass
{
	var() editinline ProgrammableShaderInstance	VertexShader;

	var() editinline ProgrammableShaderInstance	PixelShader;

	// Texture stages to be used by each pass
	var() array<TextureStage>		Stages;

	var() bool						AlphaBlending;
	var() bool						AlphaTest;
	var() bool						ZTest;
	var() bool						ZWrite;
	var() bool						RWrite;
	var() bool						GWrite;
	var() bool						BWrite;
	var() bool						AWrite;
	var() EHardwareBlendMode		SourceBlend;
	var() EHardwareBlendMode		DestinationBlend;
	var() byte						AlphaReference;
};

var() array<RenderPass>			RenderPasses;

defaultproperties
{
}
