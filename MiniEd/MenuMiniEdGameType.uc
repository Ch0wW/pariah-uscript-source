class MenuMiniEdGameType extends MenuSelectGameType;

simulated function Init( String Args )
{
    if( Len(Args) > 0 )
    {
        GameTypeName = Args;
    }
    Super.Init(Args);
}

simulated function LoadGameTypes()
{
    local int i, j;

    Super.LoadGameTypes();

    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        if( !bool(GameTypeRecords[i].bCustomMaps) )
        {
            GameTypeRecords.Remove(i, 1);
            --i;
        }
    }

    // Remove bisexual gametypes like TDM -- a DM map can be played either way so only show the 1st GT w/ same prefix
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        for( j = i + 1; j < GameTypeRecords.Length; ++j )
        {
            if( GameTypeRecords[j].MapPrefix ~= GameTypeRecords[i].MapPrefix )
            {
                GameTypeRecords.Remove(j, 1);
                --j;
            }
        }
    }    
}

simulated function HandleInputBack()
{
    Super.HandleInputBack();
    GotoMenuClass("MiniEd.MenuMiniEdMain");
}

simulated function GotoNextMenu()
{
    GotoMenuClass("MiniEd.MenuMiniEdBaseMap", GameTypeName);
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
