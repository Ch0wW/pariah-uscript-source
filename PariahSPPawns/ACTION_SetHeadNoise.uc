class ACTION_SetHeadNoise extends CinematicActions;

var(Action) rotator HeadNoiseAmp;

function bool InitActionFor(ScriptedController C)
{
    if (SPAICinematicController(C) != None){
        SPAICinematicController(C).SetHeadNoise(HeadNoiseAmp);
    }

	return false;
}

function String GetActionString()
{
	return ActionString;
}

defaultproperties
{
     HeadNoiseAmp=(Pitch=910,Yaw=910,Roll=910)
     ActionString="set headnoise"
     bValidForTrigger=False
}
