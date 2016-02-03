// This is the menu that is summoned when the player presses pause/esc/run/start during a game.
// Args: [RESET]

// "Return to Game" (PC Only)
// "Settings"
// "Switch Teams" (MP Only)
// "Add/Delete Server from Favourites" (PC Internet Only)
// "Players List" (XBox Live Only)
// "Friends List" (XBox Live Only)
// "Return to Main Menu" (SP) | "Disconnect" (MP, Not host) | "End Match" (MP, Host) | "Leave Match" (Split)
// "Quit Pariah" (PC Only)

class MenuPause extends MenuTemplateTitledBA
    config;

var() MenuButtonText Options[12];
var() localized String Prompts[12];

var() localized String StringUnSavedProgressWillBeLost;
var() localized String StringGuestWillGoToo;

var() localized String StringGamePaused;
var() localized String StringGameNotPaused;

var() localized String StringAddServerToFavourites;
var() localized String StringRemoveServerFromFavourites;

var() config int Position;

var() MenuText Objectives;
var() localized String StringObjectives;

var() bool bFromSplitProfileMain;

simulated function Init( String Args )
{
    local PlayerController PC;
    local GameReplicationInfo GRI;
    local int i;
    local GameProfile gProfile;

    Super.Init( Args );
    
    bFromSplitProfileMain = (ParseToken(args) ~= "SPLIT_PROFILE_MAIN");
    
    CrossFadeLevel = 1.f;
    CrossFadeDir = TD_None;
        
    for( i = 0; i < ArrayCount(Options); ++i )
    {
        Options[i].ContextId = i;
    }
    
    PC = PlayerController(Owner);
    
    PC.Player.bDominateSplit = true;
    
    GRI = PC.GameReplicationInfo;

    if( PC.Level.Pauser != None )
        MenuTitle.Text = StringGamePaused;
    else
        MenuTitle.Text = StringGameNotPaused;

    if( IsOnConsole() )
    {
        SetVisible( 'HandleInputBack', false );
    }
    else
    {
        SetVisible( 'HandleInputBack', true );
        BLabel.Text = class'MenuTemplateTitledB'.default.BLabel.Text;
    }
    
    if( IsOnConsole() || ( Level.NetMode != NM_Client ) || (InStr(Level.GetLocalURL(), ("?LAN")) > 0) )
    {
        SetVisible( 'OnToggleFavourite', false );
    }
    else
    {
        SetVisible( 'OnToggleFavourite', true );
        UpdateFavouritesOption();
    }

    if( PC.IsSharingScreen() && (Level.Game != None) && !Level.Game.bSinglePlayer)
    {
        if( PC.Player.SplitIndex > 0 ) // splits always leave
        {
            SetVisible( 'OnLeaveMatch', true );
        }
        else if( Level.NetMode == NM_Client )
        {
            i = GetOptionIndex('OnLeaveMatch');
            SetVisible( 'OnLeaveMatch', true );
            Prompts[i] = Prompts[i] @ StringGuestWillGoToo;
        }
        else
        {
            i = GetOptionIndex('OnEndMatch');
            SetVisible( 'OnEndMatch', true );
            Prompts[i] = Prompts[i] @ StringGuestWillGoToo;
        }
        SetVisible( 'OnLoadOut', true );
    }
    else if( (Level.Game != None) && Level.Game.bSinglePlayer )
    {
        if( PC.Player.SplitIndex > 0 ) // splits always leave
        {
            SetVisible( 'OnLeaveMatch', true );
        }
        else
        {
            i = GetOptionIndex('OnReturnToMainMenu');
            
            gProfile = GetCurrentGameProfile();
            if(gProfile != None && gProfile.ShouldSave())
            {
                Prompts[i] = Prompts[i] @ StringUnSavedProgressWillBeLost;
            }
            if(PC.IsSharingScreen())
            {
                Prompts[i] = Prompts[i] $ "\\n" $ StringGuestWillGoToo;
            }
            SetVisible( 'OnReturnToMainMenu', true );
        }
    }
    else if( Level.NetMode == NM_Client )
    {
        SetVisible( 'OnLeaveMatch', true );
        SetVisible( 'OnLoadOut', true );
    }
    else
    {
        SetVisible( 'OnEndMatch', true );
        SetVisible( 'OnLoadOut', true );
    }

    if( GRI.bTeamGame )
	{
        SetVisible( 'OnSwitchTeams', true );
	}
    else
    {
        SetVisible( 'OnSwitchTeams', false );
    }
    
    SetVisible( 'OnFriends', (PC.LiveStatus == LS_SignedIn) && !PC.bIsGuest );
    SetVisible( 'OnPlayers', (PC.LiveStatus == LS_SignedIn) && !PC.bIsGuest && (Level.GetAuthMode() == AM_Live) );
    SetVisible( 'OnSettings', !bFromSplitProfileMain);
    
    LayoutArray( Options[0], 'TitledOptionLayout' );
    
    if(( Level.NetMode == NM_Client ) || (InStr(Level.GetLocalURL(), ("?LAN")) > 0))
        ShowServerInformation();    
    else
        FillOutObjectives();
    
	if( InStr( Args, "RESET" ) >= 0 )
        Position = 0;
    else
        Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
        
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            ;
    }
    
    FocusOnWidget( Options[Position] );
}

simulated function bool IsFavouriteServer()
{
    local String IP;
    local int Port;

    if( !PlayerController(Owner).GetServerNetworkAddress( IP, Port ) )
    {
        return(false);
    }

    return(class'ServerList'.static.IsFavourite(IP, Port));
}

simulated function OnToggleFavourite()
{
    local ServerList Servers;
    local ServerList.ServerResponseLineEx Server;
    
    if( !PlayerController(Owner).GetServerNetworkAddress( Server.IP, Server.Port ) )
    {
        return;
    }

    Server.QueryPort = Server.Port + 1; // FIXME! It is not currently possible to get the info -- IpDrv contains the port but the GRI is in engine.
    
    Server.bFavourite = int(IsFavouriteServer());
    Server.ServerName = PlayerController(Owner).GameReplicationInfo.ServerName;
    
    Servers = Spawn(class'ServerList', Owner);
    
    if( bool(Server.bFavourite) )
    {
        Servers.DelFavourite( Server );
    }
    else
    {
        Servers.AddFavourite( Server );
    }
    
    Servers.Destroy();
    
    UpdateFavouritesOption();
}

simulated function UpdateFavouritesOption()
{
    local int i;
    
    for( i = 0; i < ArrayCount(Options); ++i )
    {
        if( Options[i].OnSelect == 'OnToggleFavourite' )
        {
            if( IsFavouriteServer() )
            {
                Options[i].Blurred.Text = StringRemoveServerFromFavourites;
                Options[i].Focused.Text = StringRemoveServerFromFavourites;
            }
            else
            {
                Options[i].Blurred.Text = StringAddServerToFavourites;
                Options[i].Focused.Text = StringAddServerToFavourites;
            }
        
            return;
        }
    }
    
    Assert(false);
}


simulated function FillOutObjectives()
{
    local PlayerController PC;
    local MenuObjectives ObjectivesMenu;

    PC = PlayerController(Owner);
    Assert( PC != None );
    
    if( PC.MyHud != None )
    {
        ObjectivesMenu = MenuObjectives( PC.MyHud.ObjectivesMenu );
    }

    if( (ObjectivesMenu == None) || (ObjectivesMenu.PrimaryObjective == "") )
    {
        Objectives.bHidden = 1;
        return;
    }

    Objectives.bHidden = 0;

    Objectives.Text = StringObjectives $ "\\n" $ "*" @ ObjectivesMenu.PrimaryObjective;
    
    if( ObjectivesMenu.SubObjective != "" )
    {
        Objectives.Text = Objectives.Text $ "\\n" $ "*" @ ObjectivesMenu.SubObjective;
    }
}

simulated function int GetOptionIndex( Name OnSelect )
{
    local int i;
    
    for( i = 0; i < ArrayCount( Options ); ++i )
    {
        if( Options[i].OnSelect == OnSelect )
        {
            return(i);
        }
    }

    log( "Could not find option for" @ OnSelect, 'Error' );
    return(0);
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

simulated function HandleInputBack()
{
    local PlayerController PC;
    
    PC = PlayerController(Owner);
    
    PC.Player.bDominateSplit = false;
    PC.SetPause( false );
    
    CloseMenu();
    CrossFadeLevel = 0.f;
    CrossFadeDir = TD_None;
}

simulated function OnSettings()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsMain" );
}

simulated function OnSwitchTeams( int ContextId )
{
    local MenuSwitchTeam Question;

    Question = Spawn( class'MenuSwitchTeam', Owner );

    Assert( Prompts[ContextId] != "" );
    Question.SetText( Prompts[ContextId] );

    SavePosition();
    GotoMenu( Question );
}

simulated function OnPlayers()
{
    CallMenuClass( "XInterfaceLive.MenuPlayerList" );
}

simulated function OnFriends()
{
    SavePosition();
    GotoMenuClass( "XInterfaceLive.MenuFriendList", "PAUSE" );
}

function OnReturnToMainMenu( int ContextId )
{
    OnDisconnect( ContextId );
}

simulated function OnDisconnect( int ContextId )
{
    local MenuDisconnect Question;
    
    Assert( Prompts[ContextId] != "" );
    
    Question = Spawn(class'MenuDisconnect', Owner);
    Question.SetText( Prompts[ContextId] );
    
    SavePosition();
    GotoMenu( Question );
}

function OnEndMatch( int ContextId )
{
    OnDisconnect( ContextId );
}

function OnLeaveMatch( int ContextId )
{
    OnDisconnect( ContextId );
}

function OnQuit( int ContextId )
{
    CallMenuClass( "XInterfaceCommon.MenuQuit" );
}

function OnLoadOut( int ContextId )
{
    PlayerController(Owner).Player.bDominateSplit = false;
    GotoMenuClass( "VehicleInterface.LoadOutMenu" );
}

simulated function ShowServerInformation()
{
    local String ServerInformation, IP, ServerName;
    local int Port;

    if( PlayerController(Owner).GetServerNetworkAddress( IP, Port )) 
    {
        ServerName  = PlayerController(Owner).GameReplicationInfo.ServerName;
        ServerInformation = ServerName $"\\n" $IP $":"$Port $"\\n";  
        Objectives.Text = ServerInformation;
    }
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Return to Game"),OnSelect="HandleInputBack",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Settings"),OnSelect="OnSettings")
     Options(2)=(Blurred=(Text="Weapon Load-out"),OnSelect="OnLoadOut",bHidden=1)
     Options(3)=(Blurred=(Text="Switch Teams"),OnSelect="OnSwitchTeams",bHidden=1)
     Options(4)=(OnSelect="OnToggleFavourite",Platform=MWP_PC)
     Options(5)=(Blurred=(Text="Players List"),OnSelect="OnPlayers",Platform=MWP_Xbox)
     Options(6)=(Blurred=(Text="Friends List"),OnSelect="OnFriends",Platform=MWP_Xbox)
     Options(7)=(Blurred=(Text="Return to Main Menu"),OnSelect="OnReturnToMainMenu",bHidden=1)
     Options(8)=(Blurred=(Text="Disconnect"),OnSelect="OnDisconnect",bHidden=1)
     Options(9)=(Blurred=(Text="End Match"),OnSelect="OnEndMatch",bHidden=1)
     Options(10)=(Blurred=(Text="Leave Match"),OnSelect="OnLeaveMatch",bHidden=1)
     Options(11)=(Blurred=(Text="Quit Pariah"),OnSelect="OnQuit",Platform=MWP_PC)
     Prompts(3)="Are you sure you want to switch teams?"
     Prompts(7)="Are you sure you want to quit your single player campaign?"
     Prompts(8)="Are you sure you want to disconnect?"
     Prompts(9)="Leaving the game now will end this session. Are you sure you want to leave?"
     Prompts(10)="Are you sure you want to leave the match?"
     StringUnSavedProgressWillBeLost="Any unsaved progress will be lost!"
     StringGuestWillGoToo="Your guests will be forced to disconnect."
     StringGamePaused="The game has been paused"
     StringGameNotPaused="Could not pause game"
     StringAddServerToFavourites="Add Server to Favourites"
     StringRemoveServerFromFavourites="Delete Server from Favourites"
     Position=7
     Objectives=(DrawColor=(G=150,R=255,A=255),DrawPivot=DP_LowerLeft,PosX=0.100000,PosY=0.840000,ScaleX=0.750000,ScaleY=0.750000,Kerning=-1,MaxSizeX=0.600000,bWordWrap=1)
     StringObjectives="Current Objectives:"
     BLabel=(Text="Return to Game")
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
