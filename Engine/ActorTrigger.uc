class ActorTrigger extends NetTrigger;

#exec Texture Import File=Textures\Trigger.pcx Name=S_Trigger Mips=Off MASKED=1

var() Actor TargetActor;

// various flags that indicate which properties should be set in the target actor when we are triggered
var() bool bSetLightHue;	
var() bool bSetLightSaturation;	
var() bool bSetLightBrightness;	

simulated event PostNetBeginPlay()
{
	GLog( RJ3, "PostNetBeginPlay() called, TargetActor="$TargetActor );
	if( TargetActor != None )
	{
		TargetActor.Reset();
	}
	Super.PostNetBeginPlay();
}

simulated function bool EquivalentTrigger( NetTrigger t )
{
	// t is an equivalent trigger if it an ActorTrigger affecting the same TargetActor
	// - TODO: should also look at the properties that the two triggers set
	//
	local ActorTrigger at;

	at = ActorTrigger( t );
	return at != None && at.TargetActor == TargetActor;
}

simulated function Triggered()
{
	GLog( RJ3, "Triggered() called, TargetActor="$TargetActor );
	if( TargetActor != None )
	{
		if ( bSetLightHue )			TargetActor.LightHue = LightHue;
		if ( bSetLightSaturation )	TargetActor.LightSaturation = LightSaturation;
		if ( bSetLightBrightness )	TargetActor.LightBrightness = LightBrightness;
	}
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	Super.Trigger( Other, EventInstigator );
	if( TargetActor != None )
	{
		TargetActor.Trigger( Other, EventInstigator );
	}
}

defaultproperties
{
     bTriggersPersistentState=True
     Texture=Texture'Engine.S_Trigger'
     bCollideActors=False
}
