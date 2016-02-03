//=============================================================================
// TeamPlayerReplicationInfo.
//=============================================================================
class TeamPlayerReplicationInfo extends PlayerReplicationInfo;

var SquadAI Squad;
var bool bHolding;

replication
{
	reliable if ( Role == ROLE_Authority )
		Squad, bHolding;
}

defaultproperties
{
}
