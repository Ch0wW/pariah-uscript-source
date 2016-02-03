class MenuDisconnect extends MenuQuestionYesNo;

simulated function Init( String Args )
{
    Super.Init( Args );
}

simulated function OnYes()
{
    local String MapName;
    
    MapName = Left( GetURLMap(), 1 );
    
    if( (Level.GetAuthMode() == AM_Live) 
        && ConsoleCommand("XLIVE INDEX_IS_GUEST"@PlayerController(Owner).Player.GamepadIndex) == "FALSE"
        && !PlayerController(Owner).PlayerReplicationInfo.bLiveStatsPosted
        && !(MapName ~= "X") )
    {
        GotoMenuClass( "XInterfaceLive.MenuWritingStats" );
    }
    else
    {        
		PlayerController(Owner).WarnDisconnect();
        ConsoleCommand( "DISCONNECT" );
        
        PlayerController(Owner).SetPause( false );
        CloseMenu();
    }
}

simulated function OnNo()
{
    GotoMenuClass("XInterfaceCommon.MenuPause");
}

defaultproperties
{
     CrossFadeDir=TD_In
     CrossFadeRate=20.000000
     CrossFadeLevel=0.000000
     ModulateRate=0.000000
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
