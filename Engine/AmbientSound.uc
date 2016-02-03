//=============================================================================
// Ambient sound -- Extended to support random interval sound emitters (gam).
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class AmbientSound extends Keypoint
	native
	exportstructs
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Wind,Display)
;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

#exec Texture Import File=Textures\Ambient.pcx Name=S_Ambient Mips=Off MASKED=1

// Sound will trigger every EmitInterval +/- Rand(EmitVariance) seconds.

struct SoundEmitter
{
    var() float EmitInterval;
    var() float EmitVariance;
    
    var transient float EmitTime;

    var() Sound EmitSound; // Manually re-order because Dan turned off property sorting and broke binary compatibility.
};

var(Sound) Array<SoundEmitter> SoundEmitters;

var(Events) editconst const Name hStartSound;
var(Events) editconst const Name hStopSound;


//internal vars

var() bool bRunning;
var Sound SaveSound;


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hStartSound:
		if(AmbientSound==None)
		{
			AmbientSound = SaveSound;
		}
		bRunning=True;
		break;
	case hStopSound:
		if(AmbientSound!=None)
		{
			SaveSound = AmbientSound;
			AmbientSound = None;
		}
		bRunning=False;
		break;
	}

}

defaultproperties
{
     hStartSound="START_SOUND"
     hStopSound="STOP_SOUND"
     bRunning=True
     Texture=Texture'Engine.S_Ambient'
     RemoteRole=ROLE_None
     SoundVolume=100
     bStatic=False
     bNoDelete=True
     bHasHandlers=True
}
