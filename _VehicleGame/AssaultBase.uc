class AssaultBase extends NavigationPoint
	placeable;

var() Array<PlayerStart> PlayerStarts;
var() byte TeamIndex;

function EnableSpawn(bool enable, byte team)
{
	local int i;

	for(i=0;i<PlayerStarts.Length;i++)
	{
		PlayerStarts[i].bEnabled=enable;	
		PlayerStarts[i].TeamNumber=team;
	}
}

function listspawninfo()
{
	local int i;
	for(i=0;i<PlayerStarts.length;i++)
	{
		log(PlayerStarts[i].Name$" Enabled:"$PlayerStarts[i].bEnabled$" Team:"$PlayerStarts[i].TeamNumber);
	}
}

defaultproperties
{
}
