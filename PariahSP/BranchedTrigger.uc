class BranchedTrigger extends SinglePlayerTriggers
	placeable;


struct BranchEntry
{
	var() name EventName;
	var() float Chance;
};

var() array<BranchEntry> Entries;
var() bool bUseChance;

function PostBeginPlay()
{
	local int i;
	local float Total;
	//check to make sure that the chances are set up properly if being used

	assert(Entries.Length > 0);

	if(bUseChance)
	{
		for(i = 0; i < Entries.Length; i++) 
		{
			assert(Entries[i].Chance > 0.0);
			Total+=Entries[i].Chance;
		}
		assert(Total <= 1.0);

		if(DebugLogging)
			log("Branched Trigger "$self$" initialized with total chance of "$Total);
	}
	else
	{

	}

}

function Trigger( actor Other, pawn EventInstigator )
{
	local int index;
	local float total, f;

	if(!bUseChance)
	{
		index = Rand(Entries.Length);

		if(DebugLogging)
			log("Branched Trigger "$self$" triggering random event index="$index$" name="$Entries[index].EventName);

		TriggerEvent(Entries[index].EventName, Other, EventInstigator);
	}
	else
	{
		f = FRand();

		for(index=0;index < Entries.Length; index++)
		{
			total += Entries[index].Chance;
			if(f < total)
			{
				if(DebugLogging)
					log("Branched Trigger "$self$" triggering random event chance="$f$" name="$Entries[index].EventName);
				TriggerEvent(Entries[index].EventName, Other, EventInstigator);
				break;	
			}
		}

		if(DebugLogging && index >= Entries.Length)
		{
			log("Branched Trigger "$self$" didn't trigger random event, chance out of range ( chance="$f$" total="$total$" )");
		}
	}

}

defaultproperties
{
}
