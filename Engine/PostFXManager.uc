class PostFXManager extends CameraEffect
	native
	editinlinenew
	hidecategories(Object);

var() bool									bDisablePostFX;

var() editinline array<PostFXStage>			Stages;

// this is the list of stages used at runtime
// - Stages will be copied here
// - PostFXStages created in-game need to be added here
//
var transient const array<PostFXStage>		RuntimeStages;

var transient const int				AuxRenderTargetPtrs[2];	
var transient const int				StageInputPtr;			
var transient const int				DepthTexturePtr;		
var transient const int				SceneNodePtr;			
var transient const int				RenderInterfacePtr;		
var transient const int				SceneDepthRenderTargetPtr;

// actor's whose rendering was deferred because they are supposed to be used 
// for post processing effects
// - updated every frame
var transient const array<Actor>	PostProcessingEffectActors;

var transient const bool			bPushedState;	
var transient const bool			CurAuxRT;		// native use - used to determine which AuxRenderTarget is the current render target
var transient const int				CurStage;

struct native PersistentRTInfo
{
	var const int	PostFXStagePtr;
	var const int	RenderTargetPtr;
};

struct native FreeRTInfo
{
	var const int	RenderTargetPtr;
	var const int	Lifetime;
};

var transient const array<PersistentRTInfo>	PersistentRenderTargets;
var transient const array<int>				TemporaryRenderTargets;	
var transient const array<FreeRTInfo>		FreeRenderTargetPool;

// names of stages that should be created at runtime
//
var array<string>					RequiredRuntimeStages;
var transient bool					bRequiredRuntimeStagesCreated;

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

simulated static function PostFXManager GetPostFXManager( LevelInfo li, optional bool bCheckOnly )
{
	local PostFXManager		mgr;

	mgr = li.PostEffects;
	if ( mgr == None )
	{
		mgr = li.RuntimePostEffects;
		
		if ( mgr == None && !bCheckOnly )
		{
			// there was no artist or runtime generated one, so create one now
			//
			mgr = new class'PostFXManager';
			li.RuntimePostEffects = mgr;
		}
	}
	return mgr;
}

simulated function PostFXStage FindStage( class<PostFXStage> StageClass )
{
	local int			st;
	local PostFXStage	stage;

	for ( st = 0; st < RuntimeStages.Length; st++ )
	{
		if ( ClassIsChildOf( RuntimeStages[st].Class, StageClass ) )
		{
			stage = RuntimeStages[st];
			break;
		}
	}
	return stage;
}

// get a stage of the type specified
// - if there isn't already one, create one, add it and return it
//
simulated function PostFXStage GetStage( class<PostFXStage> StageClass )
{
	local PostFXStage	stage;

	stage = FindStage( StageClass );
	if ( stage == None )
	{
		stage = new StageClass;
		AddStage( stage );
	}

	return stage;
}

native function AddStage( PostFXStage NewStage );
native function RemoveStage( PostFXStage ExStage );

event CreateRequiredRuntimeStages()
{
	local int					rrs;
	local class<PostFXStage>	StageClass;

	for ( rrs = 0; rrs < RequiredRuntimeStages.Length; ++rrs )
	{
		StageClass = class<PostFXStage>(DynamicLoadObject( RequiredRuntimeStages[rrs], class'Class' ));
		if ( StageClass != None )
		{
			GetStage( StageClass );	// this will create it if it isn't already there
		}
	}
}

defaultproperties
{
     RequiredRuntimeStages(0)="VehicleGame.BloomPostFXStage"
     RequiredRuntimeStages(1)="VehicleGame.MotionBlurPostFXStage"
     RequiredRuntimeStages(2)="VehicleGame.DistortionPostFXStage"
     FinalEffect=True
}
