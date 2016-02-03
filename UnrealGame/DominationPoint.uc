class DominationPoint extends GameObjective;

var byte PrimaryTeam;
var   bool bControllable;         // will be 'true' if and when the domination point can be captured
var   TeamInfo ControllingTeam;   // information for team currently controlling this point
var   Pawn ControllingPawn;       // controller who last touched this control point
var   Name OrderObjectiveName;    // what order command will get a bot to go to this point

replication
{
	reliable if( Role==ROLE_Authority )
		ControllingTeam, bControllable; // domletter,domring
}

function bool CheckPrimaryTeam(byte TeamNum)
{
	return (TeamNum == PrimaryTeam);
}

simulated function String GetPointName()
{
    return "";
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	if ( bControllable || (VSize(B.Pawn.Location - Location) > 400) )
		return B.Squad.FindPathToObjective(B,self);
	if ( B.Enemy != None )
		return false;
	B.WanderOrCamp(true);
	return true;
}

defaultproperties
{
}
