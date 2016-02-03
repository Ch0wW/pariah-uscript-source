class MotionBlurPostFXStage extends UtilPostFXStage
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

var() float		MotionBlurDecayRate;
var() float		MotionBlurBuildupRate;

var transient array<FrameBufferEffects.FBMotionBlurState>	SavedMotionBlurStates;

native function PushMotionBlurState();
native function GetMotionBlurState( out FrameBufferEffects.FBMotionBlurState s );
native function SetMotionBlurState( FrameBufferEffects.FBMotionBlurState s );
native function PopMotionBlurState();

simulated static function MotionBlurPostFXStage GetMotionBlurPostFXStage( LevelInfo li )
{
	local PostFXManager				mgr;
	local MotionBlurPostFXStage		mb;

	mgr = class'PostFXManager'.static.GetPostFXManager( li );
	mb = MotionBlurPostFXStage( mgr.GetStage( class'MotionBlurPostFXStage' ) );

	return mb;
}

function SetMotionBlurParams( bool bEnable, float buildupRate, float decayRate )
{
	local FrameBufferEffects.FBMotionBlurState	mbstate;

	mbstate.bEnableMotionBlur = bEnable;
	mbstate.MotionBlurBuildupRate = buildupRate;
	mbstate.MotionBlurDecayRate = decayRate;
	SetMotionBlurState( mbstate );
}

defaultproperties
{
     MotionBlurDecayRate=0.750000
     MotionBlurBuildupRate=0.250000
}
