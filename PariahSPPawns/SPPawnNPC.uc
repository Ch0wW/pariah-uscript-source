class SPPawnNPC extends SPPawn
    abstract;

var() name CharID;

function PostBeginPlay()
{
	log("SPPawnNPC postbeginplay registering self");
	SinglePlayer(Level.Game).RegisterNPC(CharID, self);
	Super.PostBeginPlay();
}

defaultproperties
{
     CharID="GenericNPC"
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAggressive'
     Health=5000
     ControllerClass=Class'PariahSPPawns.SPAIAssaultRifle'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem108
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem108'
}
