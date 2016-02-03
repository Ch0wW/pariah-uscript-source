class MenuLiveMain extends MenuTemplateTitledBA;

var() MenuButtonText Options[9];

var() MenuSprite FriendRequestIcon;
var() MenuSprite GameInvitationIcon;
var() float IconSpacing;

var() localized string ConfirmSignOutText;

var() transient float ContentDownloadLastCheckTime;
var() float ContentDownloadIntervalCheckTime;

var() config int Position;

var() bool NewContent;
var() float BlinkRate; // Blinks/sec

// Need to defer init until we're actually logged in.
auto state WaitingForLogin
{
    simulated function BeginState()
    {
        Timer();
        SetTimer( 0.33, true );
    }

    simulated function Timer()
    {
        if( ConsoleCommand("XLIVE GETAUTHSTATE") == "ONLINE" )
            GotoState('LoggedIn');
    }
    
    simulated function EndState()
    {
        SetTimer( 0.33, false );
    }
}

state LoggedIn
{
    simulated function BeginState()
    {
        log("LoggedIn!; initializing");
        
        class'GameEngine'.default.DisconnectMenuClass = "";
        class'GameEngine'.default.DisconnectMenuArgs = "";
        class'GameEngine'.static.StaticSaveConfig();

        // force an immediate content download check every time we get here, then check lazily afterwards
        ContentDownloadLastCheckTime = ContentDownloadIntervalCheckTime;

        SetVisible( 'SettingsOnSelect', false ); // Don't show Settings menu; doing it this lame way to avoid localization changes.

        SetVisible( 'CustomMaps', !bool( ConsoleCommand("XLIVE DENY_CUSTOM_CONTENT") ) );

        Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
        if( Options[Position].bHidden != 0 )
        {
            for( Position = 0; Options[Position].bHidden != 0; Position++ )
                ;
        }
        FocusOnWidget( Options[Position] );
    }
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(Options); Position++ )
    {
        if( Options[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(Options) )
        Position = 0;

    SaveConfig();
}

simulated function QuickMatchOnSelect()
{
    SavePosition();
    GotoMenuClass("XInterfaceLive.MenuMatchMakingQuery", "QUICK_MATCH" );
}

simulated function OptiMatchOnSelect()
{
    SavePosition();
    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatch");
}

simulated function CreateMatchOnSelect()
{
    SavePosition();
    GotoMenuClass( "XInterfaceMP.MenuHostMain", "XBOX_LIVE" );
}

simulated function FriendsOnSelect()
{
    SavePosition();
    GotoMenuClass("XInterfaceLive.MenuFriendList", "LIVE_MAIN");
}

simulated function SettingsOnSelect()
{
    CallMenuClass("XInterfaceSettings.MenuSettingsMain");
}

simulated function HandleInputBack()
{
    SavePosition();
    GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
}

simulated function ContentDownloadOnSelect()
{
    CallMenuClass("XInterfaceLive.MenuLiveContentDownload", MakeQuotedString(""));
}

simulated function StatsOnSelect()
{
    SavePosition();
    CallMenuClass("XInterfaceLive.MenuSelectStats");
}

simulated function Tick( float DT )
{
    local string s;
    local PlayerController PC;
    local float Blink;

    Super.Tick(DT);

    PC = PlayerController(Owner);
    
    ContentDownloadLastCheckTime += DT;
    
    if( IsOnConsole() &&  (ContentDownloadLastCheckTime > ContentDownloadIntervalCheckTime) )
    {
        ContentDownloadLastCheckTime -= ContentDownloadIntervalCheckTime;

        s = ConsoleCommand("XLIVE NEW_CONTENT");
        
        if(s == "YES")
        {
            NewContent = true;
        }
        else
        {
            NewContent = false;
        }
    }
    
    if( NewContent )
    {
        Blink = Lerp( 1.f + Sin( (Level.TimeSeconds * BlinkRate) * Pi2 ) * 0.5f, 127, 160 );
    
        Options[7].Blurred.DrawColor.R = Blink;
        Options[7].Blurred.DrawColor.G = Blink;
        Options[7].Blurred.DrawColor.B = Blink;
    }
    else
    {
        Options[7].Blurred.DrawColor.R = 127;
        Options[7].Blurred.DrawColor.G = 127;
        Options[7].Blurred.DrawColor.B = 127;
    }
    
    if( PC.NumFriendRequests > 0 )
    {
	    if( bool(FriendRequestIcon.bHidden) )
	    {
	        FriendRequestIcon.bHidden = 0;
	        bDynamicLayoutDirty = true;
	    }
    }
    else
    {
	    if( !bool(FriendRequestIcon.bHidden) )
	    {
	        FriendRequestIcon.bHidden = 1;
	        bDynamicLayoutDirty = true;
	    }
    }
    
    if( PC.NumGameInvites > 0 )
    {
	    if( bool(GameInvitationIcon.bHidden) )
	    {
	        GameInvitationIcon.bHidden = 0;
	        bDynamicLayoutDirty = true;
	    }
    }
    else
    {
	    if( !bool(GameInvitationIcon.bHidden) )
	    {
	        GameInvitationIcon.bHidden = 1;
	        bDynamicLayoutDirty = true;
	    }
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local float PosX, PosY;
    local float DX, DY;

    Super.DoDynamicLayout( C );
    
    LayoutArray( Options[0], 'TitledOptionLayout' );

    GetMenuTextSize( C, Options[3].Blurred, DX, DY );

    PosX = Options[3].Blurred.PosX + DX + IconSpacing;
    PosY = Options[3].Blurred.PosY;
    
	if( !bool(FriendRequestIcon.bHidden) )
    {
        FriendRequestIcon.PosX = PosX;
        FriendRequestIcon.PosY = PosY;

        GetMenuSpriteSize( C, FriendRequestIcon, DX, DY );
        PosX += DX + IconSpacing;
    }
    
	if( !bool(GameInvitationIcon.bHidden) )
    {
        GameInvitationIcon.PosX = PosX;
        GameInvitationIcon.PosY = PosY;

        GetMenuSpriteSize( C, GameInvitationIcon, DX, DY );
        PosX += DX + IconSpacing;
    }
}

simulated function CustomMaps()
{
    CallMenuClass("XInterfaceLive.MenuCustomMain");
}

simulated function SignOut()
{
    GotoMenuClass("XInterfaceLive.MenuLiveSignOut");
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Quick Match"),OnSelect="QuickMatchOnSelect",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="OptiMatch"),OnSelect="OptiMatchOnSelect")
     Options(2)=(Blurred=(Text="Create Match"),OnSelect="CreateMatchOnSelect")
     Options(3)=(Blurred=(Text="Friends"),OnSelect="FriendsOnSelect")
     Options(4)=(Blurred=(Text="Statistics"),HelpText="View gametype and overall statistics.",OnSelect="StatsOnSelect")
     Options(5)=(Blurred=(Text="Settings"),HelpText="Xbox Live settings.",OnSelect="SettingsOnSelect")
     Options(6)=(Blurred=(Text="Custom Maps"),HelpText="Manage custom maps.",OnSelect="CustomMaps")
     Options(7)=(Blurred=(Text="Content Download"),HelpText="Download new game content from Xbox Live.",OnSelect="ContentDownloadOnSelect")
     Options(8)=(Blurred=(Text="Sign Out"),HelpText="Sign out of Xbox Live.",OnSelect="SignOut")
     FriendRequestIcon=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbFriendInviteReceived',DrawPivot=DP_MiddleLeft,ScaleX=0.500000,ScaleY=0.500000,Pass=2,bHidden=1)
     GameInvitationIcon=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbGameInviteReceived',DrawPivot=DP_MiddleLeft,ScaleX=0.500000,ScaleY=0.500000,Pass=2,bHidden=1)
     ConfirmSignOutText="Sign out of Xbox Live?"
     ContentDownloadIntervalCheckTime=3.000000
     BlinkRate=1.000000
     MenuTitle=(Text="Xbox Live")
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
