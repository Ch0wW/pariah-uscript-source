class MenuWritingStats extends MenuTemplateTitled;

// Called on disconnect.

var MenuText Message;

simulated function Init( String Args )
{
    Super.Init( Args );
    
    if( Owner==None || PlayerController(Owner).PlayerReplicationInfo == None )
    {
        Exit();
    }
    else
    {
        PlayerController(Owner).ConsoleCommand( "XLIVE STAT_WRITE" );
        PlayerController(Owner).PlayerReplicationInfo.bLiveStatsPosted = true;

        SetTimer( 2.0, true );
    }
}

simulated function Exit()
{
    SetTimer(0,false);
        
    ConsoleCommand( "DISCONNECT" );
    
    PlayerController(Owner).SetPause( false );
    CloseMenu();
}

auto state WaitingForWrite
{
    simulated function Timer()
    {
        local String S;

        if( Owner==None || PlayerController(Owner).PlayerReplicationInfo == None )
        {
            Exit();
        }

        S = PlayerController(Owner).ConsoleCommand( "XLIVE GETAUTHSTATE" );

        if( S != "ONLINE" )
        {
            GotoState('WaitingForFocus');
            return;
        }
        
        S = PlayerController(Owner).ConsoleCommand( "XLIVE STAT_GET_STATE" );

        if( (S == "BAD_STATE") || (S == "ERROR") )
            GotoState('HandleError');
        else if( (S == "DONE") )
            GotoState('WaitingForFocus');
    }
}

state WaitingForFocus
{
    simulated function Timer()
    {
        if( Owner==None || PlayerController(Owner).PlayerReplicationInfo == None )
        {
            Exit();
        }

        if( PlayerController(Owner).Player.Console.CurMenu != self )
            return;

        Exit();
    }
}

state HandleError
{
    simulated function BeginState()
    {
        SetTimer(0,false);
        OverlayErrorMessageBox("");
    }
}

simulated function HandleInputBack();
simulated function HandleInputStart();

defaultproperties
{
     Message=(Text="Updating Xbox Live statistics...",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Style="LabelText")
     MenuTitle=(Text="Please wait...")
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
     bFullscreenOnly=True
}
