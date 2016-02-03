class HoldSpot extends UnrealScriptedSequence
	notplaceable;

function FreeScript()
{
	Destroy();
}

defaultproperties
{
     Begin Object Class=ACTION_MoveToPoint Name=ACTION_MoveToPoint3
     End Object
     Actions(0)=ACTION_MoveToPoint'UnrealGame.ACTION_MoveToPoint3'
     Begin Object Class=ACTION_WaitForTimer Name=ACTION_WaitForTimer3
         PauseTime=3.000000
     End Object
     Actions(1)=ACTION_WaitForTimer'UnrealGame.ACTION_WaitForTimer3'
     bStatic=False
     bCollideWhenPlacing=False
}
