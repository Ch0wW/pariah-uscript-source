class Admin extends AdminBase;

/*
event PostBeginPlay()
{
	Super.PostBeginPlay();
	AddCheats();
}
*/

// Execute an administrative console command on the server.
exec function DoLogin( string Password )
{
	if (Level.Game.AccessControl.AdminLogin(Outer, "", Password))
	{
		bAdmin = true;
		Level.Game.AccessControl.AdminEntered(Outer, "");
	}	
}

exec function DoLogout()
{
	if (Level.Game.AccessControl.AdminLogout(Outer))
	{
		bAdmin = false;
		Level.Game.AccessControl.AdminExited(Outer);
	}
}

exec function KickBan( string S )
{
	Level.Game.KickBan(S);
}
/*
// center print admin messages which start with #
exec function Say( string Msg )
{
	local controller C;

	if ( left(Msg,1) == "#" )
	{
		Msg = right(Msg,len(Msg)-1);
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.IsA('PlayerController') )
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(6);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
			}
		return;
	}
	Super.Say(Msg);
}
 */
exec function Kick( string S )
{
	Level.Game.Kick(S);
}

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log("Player List:");
	ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
		log(PRI.RetrivePlayerName()@"( ping"@PRI.Ping$")");
}

exec function RestartMap()
{
	ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function Switch( string URL )
{
	Level.ServerTravel( URL, false );
}

defaultproperties
{
}
