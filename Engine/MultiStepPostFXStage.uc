class MultiStepPostFXStage extends PostFXStage
	native
	editinlinenew
	hidecategories(Object);

struct native AuxRenderTargetInfo {
	var () int		XDownSample;		// amount to downsample from main framebuffer
	var () int		YDownSample;
	var () bool		bCreateClearColor;	// clear color when it's created
	var () bool		bCreateClearDepth;	// clear depth/stencil when it's created
	var () bool		bAlwaysClearColor;	// always clear color in PreRender
	var () bool		bAlwaysClearDepth;	// always clear depth/stencil in PreRender
	var () bool		bPersistent;		// does render target need to persist across frames
	var bool		bChecked;			// native use
	var () color	ClearColor;
};

// an array of render targets
// 
var (Setup) array<AuxRenderTargetInfo>	RenderTargets;

struct native StepTextureStage {
	var () BitmapMaterial		Texture;			// if non null, it's used as stage texture
	var () bool					bUseDepth;			// if true use depth buffer as the stage texture
	var () byte					RenderTargetIndex;	// if Texture == None && bUseDepth is false, use the specified render target as the stage texture
													// - 0 means the PostFXStage's input render target
													// - > 0, refers to RenderTargets(RenderTargetIndex-1)
	var () byte					MipFilter;			// should be ETexFilterType but Unreal sucks
	var () byte					MagFilter;			// ditto
	var () byte					MinFilter;			// ditto
};

struct native StepTriStripVertex
{
	var () float				X;		// normalized screen space coordinate
	var () float				Y;
	var float					Z;
	var () vector				TC[4];	// texture coordinates
};

struct native StepTriStrip
{
	var () array<StepTriStripVertex>	Vertices;
};

struct native StepDescription {
	var () array<Actor>				RenderActors;
	var () array<StepTextureStage>	SourceTextureStages;
	var () int						DestRenderTarget;	// use the specified render target as the destination for this step
														// - -1 indicates we want to write to the PostFXStage's output render target
														// - 0 means the PostFXStage's input render target
														// - > 0, refers to RenderTargets(RenderTargetIndex-1)					
	var () HardwareMaterial			Material;
	var () array<StepTriStrip>		ScreenTriStrips;
	var () bool						SkipStep;
	var () bool						AttachDepthBuffer;	// if true attach depth buffer to the dest render target
};

var (Setup) array<StepDescription>	PostProcessingSteps;

var transient const array<int>		RenderTargetPtrs;
var transient const array<int>		PersistentRenderTargetsToFree;

var const bool						bRuntimeSetup;		// post processing steps and render targets setup at runtime

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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}
