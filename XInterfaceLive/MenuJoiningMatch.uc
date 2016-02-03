class MenuJoiningMatch extends MenuTemplateTitledB;

var() MenuText Message;

var() MenuGamerList.Gamer Gamer;
var() String Command; // [JOIN | ACCEPT ]

simulated function Init( String Args )
{
    local String S;
    
    Super.Init(Args);
    log("Args:" @ Args);
    Command = Args;
    if(Command == "CROSS_TITLE")
    {
        S = ConsoleCommand( "XLIVE GET_CROSS_TITLE_INVITE_INFO" );
        Gamer.GamerTag = ParseToken( S );
        assert(Gamer.GamerTag != "");
    }
    GotoState('WaitingToStartQuery');
}

simulated exec function ConnectionFailed()
{
    log("ConnectionFailed");
    GotoMenuClass("XInterfaceLive.MenuCantJoinUnavailable");
}

simulated function HandleInputBack()
{
}

// TCR: We must make sure they don't hammer the servers.
state WaitingToStartQuery
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 1.0, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        if( Level.TimeSeconds > PlayerController(Owner).NextMatchmakingQueryTime )
            GotoState('WaitingForResults');
    }

    simulated function HandleInputBack()
    {
        SetTimer( 0, false );
        CloseMenu();
    }
}

state WaitingForResults
{
    simulated function BeginState()
    {
        PlayerController(Owner).NextMatchmakingQueryTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenMatchmakingQueries;    

        Assert( Gamer.Gamertag != "" );

        // Now it's time to kick off the answer. It _might_ be better to do this after all the query bullshit but
        // we submit tomorrow so let's play safe!

        if( Args == "ACCEPT" )
        {
            if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "INVITE ACCEPT GAMERTAG=" $ MakeQuotedString(Gamer.Gamertag) ) )
                OverlayErrorMessageBox( "FRIEND_INVITE_ACCEPT_FAILED" );
        }
        else if( Args == "JOIN" )
        {
            if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "FRIEND JOIN GAMERTAG=" $ MakeQuotedString(Gamer.Gamertag) ) )
                OverlayErrorMessageBox( "FRIEND_FRIEND_JOIN_FAILED" );
        }
        
        // Start a current-match query to ensure that enough slots are available for split
        // and the custom-content banning is repsected; this will also get the XNETSESSION
        // args so that once this is done we know where to connect.

        // NOTE: This query must be careful to handle cross-title joins! In that case
        // it just has do a generic match query which will return player counts etc.

        if( bool(Gamer.bIsInDifferentTitle) )
        {
            if( "SUCCESS" != ConsoleCommand( "XLIVE ACCEPT_CROSS_TITLE_INVITE" @ PlayerController(Owner).Player.GamePadIndex ) )
            {
                log("ACCEPT_CROSS_TITLE_INVITE failed!");
                OverlayErrorMessageBox( "FRIEND_ACCEPT_CROSS_TITLE_INVITE_FAILED" );
            }
        }
        
        ConsoleCommand("XLIVE RUN_QUERY_CURRENT_MATCH GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "GAMERTAG=" $ MakeQuotedString(Gamer.Gamertag) @ "COMMAND="$Command );

        class'VignetteConnecting'.default.ServerName = Gamer.Gamertag;
        class'VignetteConnecting'.static.StaticSaveConfig();

        if( bool(Gamer.bIsInDifferentTitle) )
        {
            class'GameEngine'.default.DisconnectMenuClass = "XInterfaceLive.MenuLiveMain";
            class'GameEngine'.default.DisconnectMenuArgs = Args;
            class'GameEngine'.static.StaticSaveConfig();
        }
        else
        {
            class'GameEngine'.default.DisconnectMenuClass = "XInterfaceLive.MenuFriendList";
            class'GameEngine'.default.DisconnectMenuArgs = "LIVE_MAIN";
            class'GameEngine'.static.StaticSaveConfig();
        }
        
        SetTimer( 0.25, true );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }
    
    simulated function Timer()
    {
        local String S;
        local MenuInsertDisc M;
        
        S = ConsoleCommand("XLIVE GETMATCHSTATE");
        
        if( S == "QUERY" )
        {
            return;
        }

        SetTimer( 0, false );
        
        if( S != "QUERYRESULTS" )
        {
            log("XLIVE GETMATCHSTATE was not QUERYRESULTS!", 'Error');
            GotoMenuClass("XInterfaceLive.MenuCantJoinUnavailable");
            return;
        }
        
        S = ConsoleCommand("XLIVE GET_CURRENT_MATCH_RESULTS");

        log("XLIVE GET_CURRENT_MATCH_RESULTS:" @ S );

        if( S == "OK" )
        {
            if( bool(Gamer.bIsInDifferentTitle) )
            {
                M = Spawn( class'MenuInsertDisc', Owner );
                M.Gamer = Gamer;
                GotoMenu( M, Command );
                return;
            }
            else
            {
                GotoState('WaitingForConnection');
                return; // Ok! Wait for the magic to happen!
            }
        }
        
        if( S == "SLOTS_FULL" )
        {
            GotoMenuClass("XinterfaceLive.MenuCantJoinSlotsFull");
            return;
        }
        
        if( S == "LOCKED_CUSTOM" )
        {
            GotoMenuClass("XinterfaceLive.MenuCantJoinLockedCustom");
            return;
        }
        
        if( S != "INVALID_SESSION_ID" )
        {
            log( "GET_CURRENT_MATCH_RESULTS returned unknown error:" @ S );
        }
        
        GotoMenuClass("XInterfaceLive.MenuCantJoinUnavailable");
    }


    simulated function HandleInputBack()
    {
        ConsoleCommand("XLIVE CANCEL_QUERY" );
        SetTimer( 0, false );
        CloseMenu();
    }
}

state WaitingForConnection
{
    simulated function HandleInputBack()
    {
        ConsoleCommand("XLIVE CANCEL_QUERY" );
        SetTimer( 0, false );
        CloseMenu();
    }
}

defaultproperties
{
     Message=(Text="Connecting to match...",Style="MessageText")
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
