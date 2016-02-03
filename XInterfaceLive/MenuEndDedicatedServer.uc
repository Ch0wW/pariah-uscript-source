class MenuEndDedicatedServer extends MenuQuestionYesNo;

var() float StatWriteTimeout;
var() float StatTimeout;

simulated function OnYes()
{
    local String MapName;
    
    MapName = Left( GetURLMap(), 1 );

    // jim: Glen made me do it!  Custom maps should always start with X
    if(Level.GetAuthMode() == AM_Live && !(MapName ~= "X"))
    {
        log("MenuEndDedicatedServer going to state WritingDHMStats");
        GotoState('WritingDHMStats');
    }
    else
    {
        QuitDHM();
    }
}

simulated function QuitDHM()
{
    CloseMenu();
    ConsoleCommand("DISCONNECT");
}

simulated function OnNo()
{
    CloseMenu();
}

state WritingDHMStats
{
    function BeginState()
    {
        ConsoleCommand("XLIVE STAT_DHM_WRITE");
        MenuTitle = class'MenuWritingStats'.default.MenuTitle;
        Question.Text = class'MenuWritingStats'.default.Message.Text;
        StatTimeout = Level.TimeSeconds + StatWriteTimeout;
        SetTimer(0.2,true);
    }

    function Timer()
    {
        local string s;

        s = ConsoleCommand("XLIVE STAT_GET_STATE");
        if( s == "WRITING_STATS" || s == "READING_STATS" )
            return;
        GotoState('');
        QuitDHM();
    }
}

defaultproperties
{
     StatWriteTimeout=60.000000
     Question=(Text="Shutdown the dedicated server and disconnect any connected players?")
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
