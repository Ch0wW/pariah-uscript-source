class ACTION_StopShooting extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.bShootTarget = false;
	C.bShootSpray = false;
    C.Target = None;
	return false;	
}

defaultproperties
{
}
