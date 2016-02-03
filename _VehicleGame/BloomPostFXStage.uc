class BloomPostFXStage extends UtilPostFXStage
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
// (cpptext)
// (cpptext)

var() FrameBufferEffects.EBloomFilterType	BloomFilter;
var() FrameBufferEffects.EBloomDrawType		BloomDrawType;
var() float									BloomHotLevel;
var() float									BloomStrength;
var() bool									bBloomAfterimage;
var() float									BloomAfterimageDecayRate;
var() float									BloomAfterimageBuildupRate;
var() float									BloomBlurStrength;

var transient const int		BloomMaxFilterPasses;
var transient const int		BloomMaxFilterRenderTargets;
var transient const int		BloomAfterimageInitStep;


// references to various hardware materials that are filled in based on property settings
// and used in post processing steps
var HardwareMaterial ExtractHotMaterial;
var HardwareMaterial FourTapTemplate;
var HardwareMaterial RecombineMaterial[3];

var transient array<FrameBufferEffects.FBBloomState>	SavedBloomStates;

native function PushBloomState();
native function GetBloomState( out FrameBufferEffects.FBBloomState s );
native function SetBloomState( FrameBufferEffects.FBBloomState s );
native function PopBloomState();

simulated static function BloomPostFXStage GetBloomPostFXStage( LevelInfo li )
{
	local PostFXManager		 mgr;
	local BloomPostFXStage	 bloom;

	mgr = class'PostFXManager'.static.GetPostFXManager( li );
	bloom = BloomPostFXStage( mgr.GetStage( class'BloomPostFXStage' ) );

	return bloom;
}

function SetBloomParameters(
	bool								bEnableBloom,
	FrameBufferEffects.EBloomFilterType	BloomFilter,
	FrameBufferEffects.EBloomDrawType	BloomDrawType,
	float								BloomHotLevel,
	float								BloomStrength,
	float								BloomBlurStrength,
	optional bool						bBloomAfterimage,
	optional float						BloomAfterimageBuildupRate,
	optional float						BloomAfterimageDecayRate
)
{
	local FrameBufferEffects.FBBloomState	bstate;

	bstate.bEnableBloom = bEnableBloom;
	bstate.BloomFilter = BloomFilter;
	bstate.BloomDrawType = BloomDrawType;
	bstate.BloomHotLevel = BloomHotLevel;
	bstate.BloomStrength = BloomStrength;
	bstate.BloomBlurStrength = BloomBlurStrength;
	bstate.bBloomAfterimage = bBloomAfterimage;
	bstate.BloomAfterimageDecayRate = BloomAfterimageDecayRate;
	bstate.BloomAfterimageBuildupRate = BloomAfterimageBuildupRate;
	SetBloomState( bstate );
}

defaultproperties
{
     BloomHotLevel=0.800000
     BloomStrength=1.000000
     BloomAfterimageDecayRate=0.750000
     BloomAfterimageBuildupRate=0.250000
     BloomBlurStrength=1.000000
     ExtractHotMaterial=HardwareMaterial'VehicleGame.ExtractHotMaterial'
     FourTapTemplate=HardwareMaterial'VehicleGame.FourTapMaterial'
     RecombineMaterial(0)=HardwareMaterial'VehicleGame.Recombine0Material'
     RecombineMaterial(1)=HardwareMaterial'VehicleGame.Recombine1Material'
     RecombineMaterial(2)=HardwareMaterial'VehicleGame.Recombine2Material'
     BloomFilter=BFT_1PassGaussian
}
