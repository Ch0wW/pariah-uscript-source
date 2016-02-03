class FinalBlend extends Modifier
	showcategories(Material)
	native;

enum EFrameBufferBlending
{
	FB_Overwrite,
	FB_Modulate,
	FB_AlphaBlend,
	FB_AlphaModulate_MightNotFogCorrectly,
	FB_Translucent,
	FB_Darken,
	FB_Brighten,
	FB_Invisible,
};

var() EFrameBufferBlending FrameBufferBlending;
var() bool ZWrite;
var() bool ZTest;
var() bool AlphaTest;
var() bool TwoSided;
var() byte AlphaRef;

enum EPostFXType
{
	PFT_None,			// no post effect
	PFT_Distortion		// this material indicates how and where to distort the screen
};

var() EPostFXType PostEffectsType;

defaultproperties
{
     ZWrite=True
     ZTest=True
}
