class MenuStorageTask extends MenuTemplateTitled;

// Args: <XLIVE STORAGE COMMAND>

// If this command is ENUMERATE the next menu will be either MenuCustomMaps (on Sucesss) or MenuLiveMain (OnCancel)
// Otherwise it will CloseMenu on Success or GotoMenu the error menu (which will CloseMenu).

// TODO: When is it legal to show "cancel/back?" ?

var() MenuText      Message;
var() MenuSlider    ProgressSlider;

var() localized String  StringEnumerating;
var() localized String  StringPublishing;
var() localized String  StringUnpublishing;
var() localized String  StringDownloading;

simulated function Init( String Args )
{
    Super.Init(Args);
 
    if( (InStr(Args, "XLIVE STORAGE DOWNLOAD") == 0) && !HaveSpaceToSaveMap() )
    {
        GotoMenuClass( "XInterfaceLive.MenuStorageError", "OUT_OF_CLIENT_SPACE" );
        return;
    }
 
    GotoState('WaitingToStartQuery');
    
    UpdateMessage(Args);
    UpdateProgress(-1.f);
    
    // TODO: Initialize progress message
}

simulated function UpdateMessage( String Command )
{
    if( InStr(Args, "XLIVE STORAGE ENUMERATE") == 0 )
    {
        Message.Text = StringEnumerating;
    }
    else if( InStr(Args, "XLIVE STORAGE PUBLISH") == 0 )
    {
        Message.Text = StringPublishing;
    }
    else if( InStr(Args, "XLIVE STORAGE UNPUBLISH") == 0 )
    {
        Message.Text = StringUnpublishing;
    }
    else if( InStr(Args, "XLIVE STORAGE DOWNLOAD") == 0 )
    {
        Message.Text = StringDownloading;
    }
    else
    {
        log( "Unknown storage command:" @ Command );
        Message.Text = "";
    }
}

simulated function UpdateProgress( float Progress )
{
    if( Progress >= 0.f )
    {
        // TEMP: Ugly and doesn't move ProgressSlider.bHidden = 0;
        ProgressSlider.Value = Progress;
    }
    else
    {
        ProgressSlider.bHidden = 1;
    }
}

simulated function HandleInputBack()
{
}

simulated function GotoNextMenu()
{
    local MenuCustomMaps M;
    local String NewArgs;

    if( InStr(Args, "XLIVE STORAGE ENUMERATE") == 0 )
    {
        NewArgs = Right( Args, Len(Args) - Len("XLIVE STORAGE ENUMERATE ") );
        GotoMenuClass( "XInterfaceLive.MenuCustomMaps", NewArgs );
    }
    else
    {
        // Tell the CustomMap menu to refresh BEFORE we start the xfade.
        M = MenuCustomMaps(PreviousMenu);
        Assert( M != None );
        M.Refresh();
        CloseMenu();
    }
}

simulated exec function Pork()
{
    GotoNextMenu();
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
        if( Level.TimeSeconds > PlayerController(Owner).NextStorageCommandTime )
            GotoState('WaitingForResults');
    }
}

state WaitingForResults
{
    simulated function BeginState()
    {
        PlayerController(Owner).NextStorageCommandTime = Level.TimeSeconds + class'PlayerController'.default.TimeBetweenStorageCommands;    

        ConsoleCommand( Args );
        SetTimer( 0.1, true );
    }

    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
        local String StorageState;
        
        StorageState = ConsoleCommand("XLIVE STORAGE GETSTATE");
        
        if( !IsOnConsole() )
        {
            return;
        }
        
        if( StorageState == "BUSY" )
        {
            UpdateProgress( float(ConsoleCommand("XLIVE STORAGE GETPROGRESS")) );
            return;
        }
        
        SetTimer( 0, false );
        
        log("StorageState:" @ StorageState);
        
        if( StorageState == "COMPLETE" )
        {
            GotoNextMenu();
            return;
        }
        
        GotoMenuClass( "XInterfaceLive.MenuStorageError", StorageState );
    }
}

defaultproperties
{
     Message=(Style="MessageText")
     ProgressSlider=(Style="ProgressBarSlider")
     StringEnumerating="Checking for published custom maps..."
     StringPublishing="Publishing custom map..."
     StringUnpublishing="Unpublishing custom map..."
     StringDownloading="Downloading custom map..."
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
}
