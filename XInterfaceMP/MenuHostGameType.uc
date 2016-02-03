class MenuHostGameType extends MenuSelectGameType;

var MenuHostMain HostMain;

simulated function Init( String Args )
{
    HostMain = MenuHostMain(PreviousMenu);
    Assert( HostMain != None );

    GameTypeName = HostMain.GameSettings[HostMain.GameTypeIndex].GameType;
    
    Super.Init("");

    // For PC we want slightly different behaviour; change B to a "Cancel" button, otherwise B == A
    // This doesn't quite do what we want because we don't slam focus on PC.
    
    if( !IsOnConsole() )
    {
        BLabel.Text = StringCancel;
        bDynamicLayoutDirty = true;
    }
    else
    {
        HideBButton(1);
    }
}

simulated function LoadGameTypes()
{
    local int i;

    Super.LoadGameTypes();
    
    if( HostMain.DenyCustomContent )
    {
        for( i = 0; i < GameTypeRecords.Length; ++i )
        {
            if( bool(GameTypeRecords[i].bCustomMaps) )
            {
                GameTypeRecords.Remove(i, 1);
                --i;
            }
        }
    }
}

simulated function HandleInputBack()
{
    if( LastInputSource == IS_Controller )
    {
        HandleInputSelect();
    }
    else
    {
        CloseMenu();
    }
}

simulated function GotoNextMenu()
{
    for( HostMain.GameTypeIndex = 0; HostMain.GameTypeIndex < HostMain.GameSettings.Length; ++HostMain.GameTypeIndex)
    {
        if( HostMain.GameSettings[HostMain.GameTypeIndex].GameType ~= GameTypeName )
        {
            break;
        }
    }
    
    Assert( HostMain.GameTypeIndex < HostMain.GameSettings.Length );
    log("Changing GameType to" @ GameTypeName @ "[" $ HostMain.GameTypeIndex $ "]");

    HostMain.Refresh();
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
