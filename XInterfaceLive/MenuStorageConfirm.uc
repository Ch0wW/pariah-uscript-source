class MenuStorageConfirm extends MenuQuestionYesNo;

var() String Command;
var() bool ShowProgress;

simulated function OnYes()
{
    local MenuCustomMaps M;
    local String MapName;

    if( ShowProgress )
    {
        GotoMenuClass( "XInterfaceLive.MenuStorageTask", Command );
        return;
    }
    
    // Special case delete -- it's handled by xUtil since it's for non-live maps too!
    if( InStr( Command, "DELETE" ) == 0 )
    {
        ParseToken( Command );
        MapName = ParseToken( Command );
        MapName = GetCustomMapName( MapName );
        Assert( MapName != "" );
        class'xUtil'.static.DeleteCustomMap( true, MapName );
    }
    else
    {
        ConsoleCommand( Command );
    }

    // Tell the CustomMap menu to refresh BEFORE we start the xfade.
    M = MenuCustomMaps(PreviousMenu);
    Assert( M != None );
    M.Refresh();
    CloseMenu();
}

simulated function OnNo()
{
    CloseMenu();
}

defaultproperties
{
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
