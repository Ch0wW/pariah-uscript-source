class FrameBufferEffects extends PostProcessingEffect
	native
	editinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EBloomFilterType
{
	BFT_1PassBox,
	BFT_2PassBox,
	BFT_3PassBox,
	BFT_4PassBox,
	BFT_1PassGaussian,
	BFT_2PassGaussian,
	BFT_3PassGaussian,
};

enum EBloomDrawType
{
	BDT_Bloom1x,
	BDT_Bloom2x,
	BDT_Bloom3x,
	BDT_Extracted,
	BDT_Filtered
};

var(Bloom) bool				bEnableBloom;
var(Bloom) EBloomFilterType	BloomFilter;
var(Bloom) EBloomDrawType	BloomDrawType;
var(Bloom) float			BloomHotLevel;
var(Bloom) float			BloomStrength;
var(Bloom) bool				bBloomAfterimage;
var(Bloom) float			BloomAfterimageDecayRate;
var(Bloom) float			BloomAfterimageBuildupRate;
var(Bloom) float			BloomBlurStrength;

// this contains bloom state that can be safely changed at runtime
//
struct native FBBloomState
{
	var bool				bEnableBloom;
	var	bool				bBloomAfterimage;
	var EBloomFilterType	BloomFilter;
	var EBloomDrawType		BloomDrawType;
	var float				BloomHotLevel;
	var	float				BloomStrength;
	var	float				BloomAfterimageDecayRate;
	var	float				BloomAfterimageBuildupRate;
	var	float				BloomBlurStrength;
};

var(MotionBlur) bool		bEnableMotionBlur;
var(MotionBlur) float		MotionBlurDecayRate;
var(MotionBlur) float		MotionBlurBuildupRate;

// this contains motion blur state that can be safely changed at runtime
//
struct native FBMotionBlurState
{
	var float		MotionBlurDecayRate;
	var float		MotionBlurBuildupRate;
	var bool		bEnableMotionBlur;
};

// this contains distortion state that can be changed at runtime
//
struct native FBDistortionState
{
	var bool			bEnableDistortion;
	var bool			bDistortionScaledByDistance;
	var bool			bDistortionAttachedToSky;
	var bool			bDistortionIsolateToHorizon;
	var bool			bDistortionFitToView;
	var BitmapMaterial	DistortionMap;
	var float			DistortionScale;
	var float			DistortionSpeedX;
	var float			DistortionSpeedY;
	var float			DistortionYFadePoints[4];
	var float			DistortionNearDistance;
	var float			DistortionFarDistance;
	var float			DistortionSkyDistance;
};

var(Distortion) bool			bEnableDistortion;
var(Distortion) BitmapMaterial	DistortionMap;
var(Distortion) float			DistortionScale;
var(Distortion) float			DistortionSpeedX;
var(Distortion) float			DistortionSpeedY;
var(Distortion) float			DistortionYFadePoints[4];
var(DistortionDepth) bool		bDistortionScaledByDistance;
var(DistortionDepth) float		DistortionNearDistance;
var(DistortionDepth) float		DistortionFarDistance;
var(DistortionSky) bool			bDistortionAttachedToSky;
var(DistortionSky) float		DistortionSkyDistance;
var(Distortion) bool			bDistortionIsolateToHorizon;
var(Distortion) bool			bDistortionFitToView;

native function GetBloomState( out FBBloomState s );
native function SetBloomState( FBBloomState s );

event ConvertToPostFXManager( LevelInfo li )
{
	local PostFXManager		 mgr;
	local BloomPostFXStage	 bloom;
	local FBBloomState		 bloomState;

	mgr = class'PostFXManager'.static.GetPostFXManager( li );

	if ( bEnableBloom )
	{
		bloom = BloomPostFXStage( mgr.GetStage( class'BloomPostFXStage' ) );
		GetBloomState( bloomState );
		bloom.SetBloomState( bloomState );
	}
}

defaultproperties
{
     BloomHotLevel=0.800000
     BloomStrength=1.000000
     BloomAfterimageDecayRate=0.750000
     BloomAfterimageBuildupRate=0.250000
     BloomBlurStrength=1.000000
     MotionBlurDecayRate=0.750000
     MotionBlurBuildupRate=0.250000
     DistortionScale=0.050000
     DistortionYFadePoints(2)=1.000000
     DistortionYFadePoints(3)=1.000000
     DistortionNearDistance=0.975000
     DistortionFarDistance=1.000000
     BloomFilter=BFT_1PassGaussian
}
