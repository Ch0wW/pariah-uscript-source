class LobbyPlayer extends PlayerController;


replication
{
	// client functions
	reliable if( Role<ROLE_Authority)
		ChangeSlot;
}

function ChangeSlot()
{
	local LobbyGRI lgri;

	lgri = LobbyGRI(Level.Game.GameReplicationInfo);
	lgri.ChangeSlot(self);
}


state WaitingInLobby
{
	function BeginState()
	{
		DoMenu();
	}


	simulated function DoMenu()
	{
		local class<Menu> MenuClass;
		if(Level.NetMode != NM_DedicatedServer)
		{
			if(GameReplicationInfo.bTeamGame)
			{
				MenuClass = class<Menu>( DynamicLoadObject( "VehicleInterface.MenuLobbyTeam", class'Class' ) );
			}
			else
			{
				MenuClass = class<Menu>( DynamicLoadObject( "VehicleInterface.MenuLobby", class'Class' ) );
			}
			MenuOpen(MenuClass);
		}
	}
}

defaultproperties
{
}
