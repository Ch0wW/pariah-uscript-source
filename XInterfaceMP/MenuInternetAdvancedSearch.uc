class MenuInternetAdvancedSearch extends MenuSelectGameTypeEx
    DependsOn(MenuInternetServerList);

// For consistency we'll put all the config vars we need in this class.
// NOTE: GameTypeName is already defined by the base class.

enum Trinary { T_False, T_True, T_Any };

var() config Trinary PrivateGames;
var() config bool ShowOnlyDedicatedServers;
var() config bool ShowGamesWithBots;
var() config Trinary FriendlyFire;
var() config Trinary InitialWecs;

var() config int MinOpenSlots;
var() config int MaxPlayers;
var() config int MinPlayers;
var() config int MaxPing; // Not filtered on the server, filtered on the client.

simulated function HandleInputBack()
{
    GotoMenuClass("XInterfaceMP.MenuInternetMain");
}

simulated function GotoNextMenu()
{
    GotoMenuClass("XInterfaceMP.MenuInternetAdvancedOptionsA");
}

static function StartQuery( MenuBase PrevMenu, MenuInternetServerList.EServerListMode ListMode )
{
    local MenuInternetServerList M;
    local int i;
    local String ShortGameType;
 
    M = PrevMenu.Spawn( class'MenuInternetServerList', PrevMenu.Owner );
    M.ListMode = ListMode;

    if( default.GameTypeName != "All" )
    {
        i = InStr( default.GameTypeName, "." );
        if( i > 0 )
        {
            ShortGameType = Right( default.GameTypeName, Len(default.GameTypeName) - (i + 1) );
        }
        
        M.AddQueryTerm( "gametype", QT_Equals, ShortGameType );
    }
    
    if( default.PrivateGames == T_False )
    {
	    M.AddQueryTerm( "password", QT_Equals, "false" );
	}    
    else if( default.PrivateGames == T_True )
    {
	    M.AddQueryTerm( "password", QT_Equals, "true" );
	}
	
	if( default.ShowOnlyDedicatedServers )
	{
	    M.AddQueryTerm( "custom", QT_Equals, "dedicated" );
	}
    
    if( !default.ShowGamesWithBots )
    {
	    M.AddQueryTerm( "custom", QT_Equals, "nobots" );
    }

    if( default.FriendlyFire == T_False )
    {
	    M.AddQueryTerm( "friendlyfire", QT_Equals, "false" );
	}    
    else if( default.FriendlyFire == T_True )
    {
	    M.AddQueryTerm( "friendlyfire", QT_Equals, "true" );
	}

    if( default.InitialWecs == T_False )
    {
	    M.AddQueryTerm( "initialwecs", QT_Equals, "false" );
	}    
    else if( default.InitialWecs == T_True )
    {
	    M.AddQueryTerm( "initialwecs", QT_Equals, "true" );
	}
    
    if( default.MinOpenSlots > 0 )
    {
        M.AddQueryTerm( "freespace", QT_GreaterThanEquals, default.MinOpenSlots );
    }
    
    if( default.MinPlayers > 0 )
    {
        M.AddQueryTerm( "currentplayers", QT_GreaterThanEquals, default.MinPlayers );
    }
    
    if( default.MaxPlayers < 32 )
    {
        M.AddQueryTerm( "currentplayers", QT_LessThanEquals, default.MaxPlayers );
    }
    
    M.MaxPing = default.MaxPing;
    
    PrevMenu.GotoMenu( M );
}

defaultproperties
{
     ShowGamesWithBots=True
     FRIENDLYFIRE=T_Any
     InitialWecs=T_Any
     MaxPlayers=32
     MaxPing=500
     MenuTitle=(Text="Advanced Search")
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
