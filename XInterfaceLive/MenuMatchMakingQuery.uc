class MenuMatchMakingQuery extends MenuTemplateTitledB;

var() MenuText PleaseWaitText;

simulated function Init( String Args )
{
    Super.Init( Args );
    GotoState('WaitingToStartQuery');
}

state WaitingToStartQuery
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 1.0, true );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds > PlayerController(Owner).NextMatchmakingQueryTime )
            GotoState('WaitingForResults');
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    }
}

state WaitingForResults
{
    simulated function BeginState()
    {
        PlayerController(Owner).NextMatchmakingQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenMatchmakingQueries;    
        ConsoleCommand("XLIVE RUN_QUERY_QUICK_MATCH");
        SetTimer( 0.1, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        local String QueryState;
        local int ResultCount;
        
        QueryState = ConsoleCommand("XLIVE GETMATCHSTATE");
        
        if( QueryState == "QUERY" ) // Still waiting.
            return;

        SetTimer( 0, false );

        if( QueryState != "QUERYRESULTS" )
        {
            GotoMenuClass("XInterfaceLive.MenuLiveMain");
            OverlayErrorMessageBox("");
            return;
        }
        
        ResultCount = int( ConsoleCommand("XLIVE GETQUERYCOUNT") );

        if( ResultCount == 0 )
            GotoMenuClass("XInterfaceLive.MenuMatchMakingNoMatches", "QUICK_MATCH" );
        else
            GotoMenuClass( "XInterfaceLive.MenuMatchMakingMatchDetails", "QUICK_MATCH" );
    }

    simulated function HandleInputBack()
    {
        ConsoleCommand("XLIVE CANCEL_QUERY" );

        SetTimer( 0, false );
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    }
}

defaultproperties
{
     PleaseWaitText=(Text="Getting list of matches.\nPlease stand by...",Style="MessageText")
     BLabel=(Text="Cancel")
     MenuTitle=(Text="Please wait")
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
