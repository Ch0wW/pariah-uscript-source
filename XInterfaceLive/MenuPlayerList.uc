class MenuPlayerList extends MenuGamerList;

simulated function Init( String Args )
{
    Super.Init( Args );
    ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REALTIMEUPDATE TRUE");
    SetTimer( 0.33, true );
    RefreshList();
}

simulated function CloseMenu()
{
    ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REALTIMEUPDATE FALSE");
    SetTimer( 0.0, false );
    Super.CloseMenu();
}

simulated function Timer()
{
    local String rc;

    rc = ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYERSISDIRTY");

    if( (rc == "") || !bool(rc) )
        return;

    RefreshList();
}

simulated function OnBButton()
{
    CloseMenu();
}

defaultproperties
{
     TextEmptyList="Nobody has played with you yet."
     ExecMode="PLAYER"
     MenuTitle=(Text="Players")
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
