class LobbyGRI extends GameReplicationInfo;

var PlayerReplicationInfo PlayerSlots[32];
var int maxSlots;
var string launchArgs;


replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PlayerSlots, maxSlots, launchArgs;
}

function ChangeSlot(Controller C)
{
	local int oldSlot, newSlot;
	local PlayerReplicationInfo PRI;

	PRI = C.PlayerReplicationInfo;

	for(oldSlot = 0; oldSlot < maxSlots; oldSlot++)
	{
		if(PlayerSlots[oldSlot] == PRI)
			break;
	}
	for(newSlot = 0; newSlot < maxSlots; newSlot++)
	{
		if( (PlayerSlots[newSlot] == None) && (oldSlot % 2 != newSlot %2) )
		{
			PlayerSlots[newSlot] = PlayerSlots[oldSlot];
			PlayerSlots[oldSlot] = None;
			break;
		}
	}
}

simulated function AddPlayer(PlayerReplicationInfo newPRI)
{
	local int i;
	
	for(i = 0; i < maxSlots; i++)
	{
		if(PlayerSlots[i] == none)
			break;
	}
	
	PlayerSlots[i] = newPRI;

}

simulated function RemovePlayer(PlayerReplicationInfo exitingPRI)
{
	local int i;
	
	for(i = 0; i < maxSlots; i++)
	{
		if(PlayerSlots[i] == exitingPRI)
			break;
	}
	
	PlayerSlots[i] = None;

}

defaultproperties
{
}
