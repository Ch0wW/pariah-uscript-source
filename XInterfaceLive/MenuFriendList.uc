class MenuFriendList extends MenuGamerList;

// Args: [PAUSE | LIVE_MAIN | CUSTOM_MAPS]

// Need to defer poll startup until we're actually logged in.
auto state WaitingForLogin
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 0.33, true );
        RefreshList();
    }

    simulated function Timer()
    {
        if( ConsoleCommand("XLIVE GETAUTHSTATE") == "ONLINE" )
            GotoState('LoggedIn');
    }
}

state LoggedIn
{
    simulated function BeginState()
    {
        local PlayerController PC;
        
        PC = PlayerController(Owner);
        
        ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PC.Player.GamePadIndex @ "REALTIMEUPDATE TRUE");
        RefreshList();
        log(string(Gamers.Length)@ "friends loaded.");
    }

    simulated function Timer()
    {
        local String rc;

        rc = ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "FRIENDSISDIRTY");

        if( (rc == "") || !bool(rc) )
            return;

        RefreshList();
    }
}

simulated function Shutdown()
{
    ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REALTIMEUPDATE FALSE");
    SetTimer( 0.0, false );
}

simulated function OnBButton()
{
    if( InStr( Args, "PAUSE" ) >= 0 )
    {
        Shutdown();
        GotoMenuClass( "XInterfaceCommon.MenuPause" );
    }
    else if( InStr( Args, "LIVE_MAIN" ) >= 0 )
    {
        Shutdown();
        GotoMenuClass( "XInterfaceLive.MenuLiveMain" );
    }
    else
    {
        Shutdown();
        CloseMenu();
    }
}

defaultproperties
{
     TextEmptyList="Your friends list is empty."
     ExecMode="FRIEND"
     MenuTitle=(Text="Friends")
     XBLFriendsRequest=(bHidden=1)
     XBLGameInvitation=(bHidden=1)
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
