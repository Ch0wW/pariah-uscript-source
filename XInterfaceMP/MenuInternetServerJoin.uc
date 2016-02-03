class MenuInternetServerJoin extends MenuTemplateTitledBA;

var() ServerList Servers;
var() ServerList.ServerResponseLineEx Server;
var() bool bLANGame;

var() MenuText      Instructions;

var() localized String PasswordInstructions;
var() localized String StringNoPasswordEntered;
var() MenuEditBox   PasswordBox;
var() float         PasswordDY;

var() localized String WaitingForSpaceInstructions;

var() localized String JoiningServer;

const URLPrefix = "UNREAL:";

simulated function Init( String Args )
{
    Super.Init( Args );

    SetTimer(0.5, true);
 
    Servers.AddRecent( Server );
 
    if( Server.MaxPlayers == 0 )
    {
        GotoState('WaitingForPing');
    }
    else if( bool(Server.bPrivate) )
    {
        GotoState('WaitingForPassword');
    }
    else if( Server.CurrentPlayers >= Server.MaxPlayers )
    {
        GotoState('WaitingForSpace');
    }
    else
    {
        GotoState('Joining');
    }
}

simulated function Timer()
{
    Refresh();
}

simulated function Refresh()
{
    Servers.RefreshServer( Server );
}

simulated function SetProgress( String Str1, String Str2 )
{
    log("Ignoring suprious SetProgress", 'Warning');
}

state WaitingForPing
{
    simulated function BeginState()
    {
        HideAButton(1);
        
        ALabel.Text = StringCancel;
        bDynamicLayoutDirty = true;
        
        Instructions = class'MenuDefaults'.default.MessageText;
        Instructions.Text = JoiningServer;
    }

    simulated function HandleInputBack()
    {
        GotoState('Closing');
        PlayerController(Owner).ConsoleCommand( "CANCEL" );
        CloseMenu();
    }
    
    simulated function Timer()
    {
        global.Timer();
        
        if( Server.MaxPlayers == 0 )
        {
            return;
        }

        if( bool(Server.bPrivate) )
        {
            GotoState('WaitingForPassword');
        }
        else if( Server.CurrentPlayers >= Server.MaxPlayers )
        {
            GotoState('WaitingForSpace');
        }
        else
        {
            GotoState('Joining');
        }
    }
}

state WaitingForPassword
{
    simulated function BeginState()
    {
        Instructions = class'MenuDefaults'.default.LongMessageText;
        Instructions.Text = ReplaceSubstring( PasswordInstructions, "<SERVERNAME>", Server.ServerName );
     
        PasswordBox.bHidden = 0;
        ALabel.Text = StringContinue;
        HideAButton(0);
     
        bDynamicLayoutDirty = true;
    }

    simulated function EndState()
    {
        PasswordBox.bHidden = 1;
    }
    
    simulated function DoDynamicLayout( Canvas C )
    {
        local float DY;
    
        Super.DoDynamicLayout(C);
            
        DY = GetWrappedTextHeight( C, Instructions );

        PasswordBox.Blurred.PosX = Instructions.PosX;
        
        if( bool(PasswordBox.bRelativeBackgroundCoords) )
        {
            PasswordBox.Blurred.PosX -= PasswordBox.BackgroundBlurred.PosX;
        }
        
        PasswordBox.Blurred.PosY = Instructions.PosY + DY + PasswordDY;
        
        PasswordBox.Focused.PosX = PasswordBox.Blurred.PosX;
        PasswordBox.Focused.PosY = PasswordBox.Blurred.PosY;
    }

    simulated function Timer()
    {
        global.Timer();
        
        if( !bool(Server.bPrivate) )
        {
            GotoNextState();
        }
    }
    
    simulated function OnAButton()
    {
        local MenuMessageBox MessageBox;
        
        if( PasswordBox.Blurred.Text == "" )
        {
            MessageBox = Spawn( class'XInterfaceCommon.MenuMessageBox', Owner );
            MessageBox.SetText( StringNoPasswordEntered );
            CallMenu( MessageBox );
        }
        else
        {
            GotoNextState();
        }
    }
    
    simulated function GotoNextState()
    {
        if( Server.CurrentPlayers >= Server.MaxPlayers )
        {
            GotoState('WaitingForSpace');
        }
        else
        {
            GotoState('Joining');
        }
    }
}

state WaitingForSpace
{
    simulated function BeginState()
    {
        Instructions = class'MenuDefaults'.default.MedMessageText;
        Instructions.Text = ReplaceSubstring( WaitingForSpaceInstructions, "<SERVERNAME>", Server.ServerName );
     
        HideAButton(1);
    }
    
    simulated function Timer()
    {
        global.Timer();
        
        if( Server.CurrentPlayers < Server.MaxPlayers )
        {
            GotoState('Joining');
        }
    }
}

state Joining
{
    simulated function BeginState()
    {
        local String URL;
        
        HideAButton(1);
        
        ALabel.Text = StringCancel;
        bDynamicLayoutDirty = true;
        
        Instructions = class'MenuDefaults'.default.MessageText;
        Instructions.Text = JoiningServer;
        
        URL = Server.IP $ ":" $ Server.Port;
        
        if( bool(Server.bPrivate) )
        {
            URL = URL $ "?password=" $ PasswordBox.Blurred.Text;
        }
        
        if( bLANGame )
        {
            URL = URL $ "?LAN";
        }

        class'VignetteConnecting'.default.ServerName = Server.ServerName;
        class'VignetteConnecting'.static.StaticSaveConfig();

        PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
    }
    
    simulated function HandleInputBack()
    {
        GotoState('Closing');
        PlayerController(Owner).ConsoleCommand( "CANCEL" );
        CloseMenu();
    }
    
    simulated function RemoveURLS( out String S )
    {
        if( Left(Caps(S), Len(URLPrefix)) == Caps(URLPrefix) )
	    {
	        S = "";
	    }
    }
        
    simulated event SetText( String TitleText, String Text )
    {
        local int i, j;

        MenuTitle.Text = TitleText;
            
        i = CountOccurances( Text, "\\n\\n" );
        j = CountOccurances( Text, "\\n" );
        
        if( i > 1 )
        {
            Instructions = class'MenuDefaults'.default.LongMessageText;
            Instructions.Text = Text;
        }
        else if( (i == 1) || (j > 1) )
        {
            Instructions = class'MenuDefaults'.default.MedMessageText;
            Instructions.Text = Text;
        }
        else
        {
            Instructions = class'MenuDefaults'.default.MessageText;
            Instructions.Text = Text;
        }
    }

    simulated function SetProgress( String Str1, String Str2 )
    {
        RemoveURLS( Str1 );
        RemoveURLS( Str2 );

        if( Str1 == Str2 )
            Str2 = "";

        if( Str1 == "" )
        {
            Str1 = Str2;
            Str2 = "";
        }
            
        if( Str1 == "" )
        {
            return;
        }
        
        SetText( Str1, Str2 );
    }
}

state Closing
{
    simulated function SetProgress( String Str1, String Str2 )
    {
        // Hack to prevent further SetProgress events.
    }
}

simulated exec function ConnectionFailed()
{
    log("ConnectionFailed");
}

defaultproperties
{
     Instructions=(PosX=0.100000,MaxSizeX=0.800000,Style="LongMessageText")
     PasswordInstructions="<SERVERNAME> is a private server and requires a password to join it."
     StringNoPasswordEntered="You must enter a password before you can continue."
     PasswordBox=(bNoSpaces=1,MaxLength=15,MinLength=1,OnSelect="OnAButton",Style="NormalEditBox")
     PasswordDY=0.050000
     WaitingForSpaceInstructions="<SERVERNAME> is currently at full capacity. Please stand by; if space becomes available you will be connected automatically."
     JoiningServer="Joining game..."
     APlatform=MWP_All
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
