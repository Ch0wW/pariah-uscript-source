class CounterTrigger extends SinglePlayerTriggers
	placeable;

#exec Texture Import File=Textures\CounterA.pcx Name=CounterIcon Mips=Off MASKED=1

var() int Count; 
var() bool Repeat;


var int CountsReceived;


function Reset()
{
	CountsReceived = 0;
	Super.Reset();
}

function Trigger( actor Other, pawn EventInstigator )
{
	CountsReceived++;

	if(DebugLogging)
		log("Counter Trigger "$self$" was Triggered by Tag:"$tag);

	if(CountsReceived == Count)
	{
		if(DebugLogging)
			log("    Calling event "$event$" after Count: "$CountsReceived);
		TriggerEvent(Event, self, None);


		if(Repeat)
		{
			if(DebugLogging)
				log("        Setting to repeat");
			Reset();
		}
		else
		{
			if(DebugLogging)
				log("        Setting to disabled");
			DisableTrigger();
		}
	}
}

//===================
// Default Properties
//===================

defaultproperties
{
     Texture=Texture'PariahSP.CounterIcon'
}
