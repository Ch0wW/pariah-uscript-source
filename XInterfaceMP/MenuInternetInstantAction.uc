class MenuInternetInstantAction extends MenuSelectGameTypeEx;

simulated function HandleInputBack()
{
    GotoMenuClass("XInterfaceMP.MenuInternetMain");
}

simulated function GotoNextMenu()
{
    local MenuInternetServerList M;
    local String ShortGameType;
    local int i;
 
    M = Spawn( class'MenuInternetServerList', Owner );
    M.ListMode = SLM_InstantAction;

    if( GameTypeName != "All" )
    {
        i = InStr( GameTypeName, "." );
        if( i > 0 )
        {
            ShortGameType = Right( GameTypeName, Len(GameTypeName) - (i + 1) );
        }
        
        M.AddQueryTerm( "gametype", QT_Equals, ShortGameType );
    }

	M.AddQueryTerm( "password", QT_Equals, "false" );
	// sjs - QT_GreaterThan did not work if there were > 0 real players, but this does?!!! TODO: Could it be underflow (MaxPlayers not set?)?
    M.AddQueryTerm( "freespace", QT_NotEquals, "0" );

    GotoMenu( M );
}

defaultproperties
{
     MenuTitle=(Text="Instant Action")
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
}
