class MenuMiniEdLowStorage extends MenuLowStorage
    DependsOn(MenuMiniEdMain);

var() MenuMiniEdMain.ESaveAction SaveAction;

simulated function InitText()
{
    local int freeSpace;

    freeSpace = int(LoadSaveCommand("SPACE_FREE"));
    mNeededSpace = int(LoadSaveCommand("CUSTOM_MAP_SPACE_NEEDED"));
    
    assert(freeSpace < mNeededSpace);

    // always ask for the maximum number of blocks needed
    mMessage.Text = class'XboxMsg'.default.XBOX_NOT_ENOUGH_FREE_BLOCKS_CUSTOM_MAP;
    UpdateTextField( mMessage.Text, "<BLOCKS>", String(mNeededSpace) );
}

simulated function ContinueWithoutSaving()
{
    class'MenuMiniEdMain'.static.FinishSaveAction( self, SaveAction );
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
