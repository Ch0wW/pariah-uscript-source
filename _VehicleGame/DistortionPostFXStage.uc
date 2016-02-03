class DistortionPostFXStage extends UtilPostFXStage
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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var transient array<FrameBufferEffects.FBDistortionState>	SavedDistortionStates;

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
var transient const bool		bDistortionPushed;
var transient const bool		bNeedUpdate;

// ********* NATIVE USE VARIABLES *********
var transient const int			DepthDistortStep;
var transient const int			DistortStep;
var transient const int			DistortCopyStep;
var transient const float		DistortionScrollX;
var transient const float		DistortionScrollY;
var transient const vector		LastViewOrigin;		
var transient const rotator		LastViewRotation;
var transient const float		DistortWidthZMult;
var transient const float		DistortHeightZMult;

var HardwareMaterial DepthDistortMaterial;
var HardwareMaterial DistortFromTexMaterial;
var HardwareMaterial DistortFromRTMaterial;

var transient HardwareMaterial DistortFromTexMaterialCopy;
var transient HardwareMaterial DistortFromRTMaterialCopy;

native function PushDistortionState();
native function GetDistortionState( out FrameBufferEffects.FBDistortionState s );
native function SetDistortionState( FrameBufferEffects.FBDistortionState s );
native function PopDistortionState();

simulated static function DistortionPostFXStage GetDistortionPostFXStage( LevelInfo li )
{
	local PostFXManager			mgr;
	local DistortionPostFXStage	distortion;

	mgr = class'PostFXManager'.static.GetPostFXManager( li );
	distortion = DistortionPostFXStage( mgr.GetStage( class'DistortionPostFXStage' ) );

	return distortion;
}

defaultproperties
{
     DistortionScale=0.050000
     DistortionYFadePoints(2)=1.000000
     DistortionYFadePoints(3)=1.000000
     DistortionNearDistance=0.975000
     DistortionFarDistance=1.000000
     DepthDistortMaterial=HardwareMaterial'VehicleGame.DepthDistortMaterial'
     DistortFromTexMaterial=HardwareMaterial'VehicleGame.DistortMaterial0'
     DistortFromRTMaterial=HardwareMaterial'VehicleGame.DistortMaterial1'
}
