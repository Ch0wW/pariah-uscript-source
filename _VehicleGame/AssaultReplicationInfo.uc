class AssaultReplicationInfo extends GameReplicationInfo;


var Vector Team0NextPoint;
var vector Team1NextPoint;
var byte AssaultBar; // cmr

replication
{
	unreliable if(Role==ROLE_Authority)
		Team0NextPoint, Team1NextPoint,AssaultBar;
}

defaultproperties
{
}
