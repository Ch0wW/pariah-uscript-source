class MostlyDeadPawn extends VGPawn;

// how this works:  the dialogueName must be set to be the same as the tag for a corresponding Dialogue actor
// thus, when the pawn is revived we need but trigger the dialogue event and the existing dialogue system kicks in
var(Dialogue) Name dialogueName;

// this is where we play the revival animation and show a short dialog
simulated function Revive(optional Pawn RevivedBy)
{
	log("I'm alive!");
	log("RevivedBy = "$RevivedBy$", Ctrl = "$RevivedBy.Controller);
	Health = 100;	// so the player doesn't accidentally (or otherwise) waste more healing tool ammo trying to heal the pawn

    TriggerEvent(dialogueName, self, RevivedBy);
}

defaultproperties
{
     Health=0
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem13
     End Object
     HParams=HavokSkeletalSystem'PariahSP.HavokSkeletalSystem13'
}
