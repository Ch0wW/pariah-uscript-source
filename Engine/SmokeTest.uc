class SmokeTest extends Actor
	placeable
    native;

var const native transient private int mFileHandle;

native function Triggered(name eventName);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

simulated function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent )
{
    Triggered(realevent);
}

defaultproperties
{
     bHasHandlers=True
}
