class SPKarinaTrigger extends SinglePlayerTriggers
    placeable;

var() Name NewScriptTag;

var SPPawnNPC karina;
var UnrealScriptedSequence NewScript;

function BeginPlay()
{
    local SPPawnNPC K;
    local UnrealScriptedSequence curSequence;

    ForEach AllActors(class'SPPawnNPC',K)
    {
		if (K.IsA('SPPawnKarina') )
		{
		   karina = K;
		    break;
		}
    }
    ForEach AllActors( class'UnrealScriptedSequence', curSequence ) {
        if ( curSequence.Tag == NewScriptTag ) {
            NewScript = curSequence;
        }
    }

}

function Trigger( actor Other, pawn EventInstigator )
{
	ScriptedController(karina.Controller).ActionNum = 0;
    ScriptedController(karina.Controller).SetNewScript( NewScript);
    ScriptedController(karina.Controller).GotoState('Scripting');
}

defaultproperties
{
}
