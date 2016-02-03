class WECPointRules extends GameRules;


function PostBeginPlay()
{
	Super.PostBeginPlay();

	log("IIIIIIIIIIIIII LIVVVVVEEEEEEEEEEEEEEE");
}


function ScoreKill(Controller Killer, Controller Killed)
{
	Super.ScoreKill(Killer, Killed);

	Killer.PlayerReplicationInfo.Score += Killed.PlayerReplicationInfo.ThreatLevel;
	log("added "$Killed.PlayerReplicationInfo.ThreatLevel$" points to "$Killer);

}

defaultproperties
{
}
