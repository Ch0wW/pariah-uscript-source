class TriggerDispatcher extends SinglePlayerTriggers;


#exec Texture Import File=Textures\DispatcherA.pcx Name=S_Dispatcher Mips=Off MASKED=1


struct DispatchInfo
{
	var() name EventName;
	var() float EventWait;
};


var() Array<DispatchInfo> DispatchList;
var() bool bStartEnabled;
var() bool bLoop;
var() int LoopCount;


var int CurrentIndex;
var int LoopsRemaining;
var float CurrentTime;
var float NextEventTime;
var bool bRunning;


function Reset()
{
	CurrentIndex=0;
	CurrentTime=0.0;
	GotoState('');
}

function Start()
{
	if(DebugLogging)
		log("DispatchInfo Starting Up");
	LoopsRemaining = LoopCount;
	CurrentTime=0;
	bRunning=true;
	CurrentIndex=0;
	NextEventTime = DispatchList[0].EventWait;
	GotoState('Running');
}

function SetInitialState()
{
    if(bStartEnabled==True)
		Start();

}

state Running
{
	function Tick(float dt)
	{
		CurrentTime+=dt;

		while(NextEventTime <= CurrentTime)
		{
			if(DebugLogging)
				log("DispatchInfo calling event "$DispatchList[CurrentIndex].EventName$" at "$CurrentTime$" (wait time was "$DispatchList[CurrentIndex].EventWait$")");
			
			if(DispatchList[CurrentIndex].EventName != '')
				TriggerEvent(DispatchList[CurrentIndex].EventName, self, None);
			CurrentIndex++;

			if(CurrentIndex == DispatchList.Length) //end of list
			{
				if(DebugLogging)
					log("DispatchInfo end of list...");
				LoopOrEnd();
				return;
			}
			else
			{
				NextEventTime += DispatchList[CurrentIndex].EventWait;
			}
		}
	}


	function LoopOrEnd()
	{
		if(!bLoop)
		{
			if(DebugLogging)
				log("DispatchInfo ending...");
			GotoState('');
		}
		else
		{
			LoopsRemaining--;

			if(LoopsRemaining==0 && LoopCount>0) //if bLoop and LoopCount is 0 it will go forever
			{
				if(DebugLogging)
					log("DispatchInfo ending (no more loops)...");
				Reset();
			}
			else
			{
				if(DebugLogging)
					log("DispatchInfo restarting (loops left)...");
				CurrentTime=0;
				CurrentIndex=0;
				NextEventTime = DispatchList[0].EventWait;

			}
		}
	}

	function Trigger(Actor other, Pawn eventinstigator)
	{
	}


}

function Trigger(Actor other, Pawn eventinstigator)
{
	Start();
}

defaultproperties
{
     Texture=Texture'PariahSP.S_Dispatcher'
}
