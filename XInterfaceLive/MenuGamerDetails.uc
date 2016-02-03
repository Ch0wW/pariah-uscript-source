class MenuGamerDetails extends MenuTemplateTitledBA
    DependsOn(MenuGamerList);

var() MenuGamerList GamerList;
var() MenuGamerList.Gamer LastGamer;

var() MenuButtonText Options[16];
var() MenuSprite OptionBox;

var() MenuText Info[4];
var() MenuSprite InfoBox;
var() int VoicemailPlaying;

var() localized String StringCancelFriendRequest;
var() localized String StringBlockFriendRequest;
var() localized String StringRemoveFriend;
var() localized String StringCancelInvite;

var() localized String StringGamertagToken;

var() localized String StringSentRequest;
var() localized String StringReceivedRequest;
var() localized String StringSentInvite;
var() localized String StringInviteRejected;
var() localized String StringInviteAccepted;
var() localized String StringReceivedInvite;
var() localized String StringIsPlaying;
var() localized String StringPlayVoicemail;
var() localized String StringStopVoicemail;

var() WidgetLayout OptionsLayout;
var() WidgetLayout InfoLayout;

var() int VoicemailMsgPtr;      // our voicemail message

simulated function Init( String Args )
{
    Super.Init( Args );

    GamerList = MenuGamerList(PreviousMenu);
    LastGamer = GamerList.Gamers[GamerList.CurrentGamer];

    SetOptions();
    SetTimer( 0.33f, true );
}

simulated function StopVoicemailIfPlaying()
{
    log("VoicemailPlaying on exit:" @ VoicemailPlaying);
    if (VoicemailPlaying > 0)  // It's playing we need to stop it
    {
        VoicemailPlaying = 0;
        ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "VMAILCMD Msg=" $ VoicemailMsgPtr @ "Cmd=" $ VoicemailPlaying);
    }
}

simulated function CloseMenu()
{
    StopVoicemailIfPlaying();               // paranoid..
    MenuGamerList(PreviousMenu).RefreshList();
    SetTimer( 0.0, false );
    Super.CloseMenu();
}

simulated function Timer()
{
    if( !GamerList.CurrentGamerIsValid() )
    {
        CloseMenu();
    }
    if (VoicemailMsgPtr > 0)                // Voicemail, show button
    {
        AutoUpdateVoicemailOptionState();
    }
    if( LastGamer == GamerList.Gamers[GamerList.CurrentGamer] )
    {
        return;
    } 
    LastGamer = GamerList.Gamers[GamerList.CurrentGamer];    
    SetOptions();
}

simulated function SetOptions()
{
    local int i;
    local String N;
    local int InfoPos;
    local MenuGamerList GL;
    local PlayerController PC;
    local int LastFocus;
    local int VoiceAttachmentType;  // mjm
    local String cc;

    LastFocus = -1;    

    for( i = 0; i < ArrayCount( Options ); i++ )
    {
        if( Options[i].bHasFocus != 0 )
        {
            LastFocus = i;
            break;
        }
    }
    
    FocusOnNothing();

    GL = MenuGamerList(PreviousMenu);
    PC = PlayerController(Owner);

    for( i = 0; i < ArrayCount( Options ); i++ )
        Options[i].bHidden = 1;

    for( i = 0; i < ArrayCount(Info); i++ )
    {
        Info[i].Text = "";
        Info[i].MaxSizeX = InfoBox.ScaleX * 0.95f;
    }
    
    N = GamerList.Gamers[GamerList.CurrentGamer].Gamertag;

    if( GamerList.Gamers[GamerList.CurrentGamer].bIsFriend == 0 )
    {
        if( GamerList.Gamers[GamerList.CurrentGamer].bSentRequest != 0 )
        {
            Options[12].bHidden = 0;

            Info[InfoPos++].Text = StringSentRequest;
        }
        else if( GamerList.Gamers[GamerList.CurrentGamer].bReceivedRequest != 0 )
        {
            Options[9].bHidden = 0;
            Options[10].bHidden = 0;
            Options[11].bHidden = 0;
            VoiceAttachmentType = 2;    // mjm - this will trigger an attempt to retrieve a voicemail for the friend request

            Info[InfoPos++].Text = StringReceivedRequest;
        }
        else
        {
            Options[8].bHidden = 0;
        }
    }
    else // Already a friend
    {
        SetVisible( 'PublishedCustomMaps', !bool( ConsoleCommand("XLIVE DENY_CUSTOM_CONTENT")) );
        Options[7].bHidden = 0;

        if( GamerList.Gamers[GamerList.CurrentGamer].bInvitable != 0)
            Options[3].bHidden = 0;

        if( GamerList.Gamers[GamerList.CurrentGamer].bSentInvite != 0 )
        {
            if( GamerList.Gamers[GamerList.CurrentGamer].bInviteAccepted != 0 )
                Info[InfoPos++].Text = StringInviteAccepted;
            else if( GamerList.Gamers[GamerList.CurrentGamer].bInviteRejected != 0 )
                Info[InfoPos++].Text = StringInviteRejected;
            else
            {
                Info[InfoPos++].Text = StringSentInvite;
                Options[4].bHidden = 0;
                Options[3].bHidden = 1;
            }
        }

        if( GamerList.Gamers[GamerList.CurrentGamer].bReceivedInvite != 0 )
        {
            // if( GamerList.Gamers[GamerList.CurrentGamer].bJoinable != 0 )
            // {
                 Options[1].bHidden = 0;
            // }
            Options[2].bHidden = 0;
            Info[InfoPos++].Text = StringReceivedInvite;
            VoiceAttachmentType = 1;    // mjm - this will trigger an attempt to retrieve a voicemail for the game invite
        }
        else if( (GamerList.Gamers[GamerList.CurrentGamer].bOnline != 0) && (GamerList.Gamers[GamerList.CurrentGamer].bJoinable != 0) )
        {
            Options[6].bHidden = 0;
        }

        if
        (
            (GamerList.Gamers[GamerList.CurrentGamer].bReceivedInvite != 0) ||
            (
                (GamerList.Gamers[GamerList.CurrentGamer].bOnline != 0) &&
                (
                    (GamerList.Gamers[GamerList.CurrentGamer].bJoinable != 0) ||
                    (GamerList.Gamers[GamerList.CurrentGamer].bPlaying != 0) ||
                    (GamerList.Gamers[GamerList.CurrentGamer].GameTitle != "")
                )
            )
        )
        {
            Info[InfoPos++].Text = StringIsPlaying;
            
            if( GamerList.Gamers[GamerList.CurrentGamer].GameTitle == "" )
                Info[InfoPos++].Text = "...";
            else
                Info[InfoPos++].Text = GamerList.Gamers[GamerList.CurrentGamer].GameTitle;
        }
    }
 
    if (VoiceAttachmentType > 0)    // mjm - Try to extract the voicemail, if exists
    {
        cc = "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "GETVMAIL GAMERTAG=\"" $ N $ "\" TYPE=" $ VoiceAttachmentType;
        log(cc);
        VoicemailMsgPtr = int(ConsoleCommand(cc));
        log("Voicemail Msg Ptr:" @ VoicemailMsgPtr);
    }
    
    if( GL.IsA('MenuPlayerList') )
    {
        if( GamerList.Gamers[GamerList.CurrentGamer].bIsMuted != 0 )
        {
            Options[13].bHidden = 1;
            Options[14].bHidden = 0;
        }
        else
        {
            Options[13].bHidden = 0;
            Options[14].bHidden = 1;
        }

        Options[15].bHidden = 0;
    }
    else
    {
        Options[13].bHidden = 1;
        Options[14].bHidden = 1;
        Options[15].bHidden = 1;
    }

    if (VoicemailMsgPtr > 0)       // Voicemail, show button and also show feedback
    {
        Options[0].bHidden = 0;
        Options[15].bHidden = 0;
    }

    for( i = 0; i < ArrayCount(Info); i++ )
    {
        if( Info[i].Text == "" )
            Info[i].bHidden = 1;
        else
        {
            Info[i].bHidden = 0;
            Info[i].Text = ReplaceSubString( Info[i].Text, StringGamertagToken, N );
        }
    }

    MenuTitle.Text = GamerList.Gamers[GamerList.CurrentGamer].Gamertag;

    bDynamicLayoutDirty = true;

    if( (LastFocus >= 0) && (Options[LastFocus].bHidden == 0) )
    {
        FocusOnWidget( Options[LastFocus] );
    }
    else
    {
        for( i = 0; i < ArrayCount( Options ); i++ )
        {
            if( Options[i].bHidden == 0 )
            {
                FocusOnWidget( Options[i] );
                break;
            }
        }
    }
}

simulated function AutoUpdateVoicemailOptionState()
{
    // State change.. name for voicemail button
    
    if (VoicemailPlaying != int(ConsoleCommand("VOICEMAIL Cmd=6")))
    {   
        if (VoicemailPlaying == 0)  // we aren't stopped, we're playing!
        {
            Options[0].Blurred.Text = StringStopVoicemail;
            VoicemailPlaying = 1;
        }
        else
        {
            Options[0].Blurred.Text = StringPlayVoicemail;
            VoicemailPlaying = 0;
        }
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutArray( Info[0], 'InfoLayout' );
    FitBorderBoxToArray( InfoBox, Info[0], 'InfoLayout' );

    LayoutArray( Options[0], 'OptionsLayout' );
    FitBorderBoxToArray( OptionBox, Options[0], 'OptionsLayout' );
}

simulated function AcceptInvite()
{   
    JoinGame("ACCEPT");
}

simulated function JoinGame(String Command)
{
    local MenuJoiningMatch MM;
    local MenuTravelConfirm MC;
    
    StopVoicemailIfPlaying();
    
    if( InMenuLevel() || (IsMiniEd() && !MiniEdMapIsDirty()) )
    {
        MM = Spawn( class'MenuJoiningMatch', Owner );
        MM.Gamer = GamerList.Gamers[GamerList.CurrentGamer];
        Assert( MM.Gamer.Gamertag != "" );
        CallMenu( MM, Command );
    }
    else
    {
        MC = Spawn( class'MenuTravelConfirm', Owner );
        MC.Gamer = GamerList.Gamers[GamerList.CurrentGamer];
        Assert( MC.Gamer.Gamertag != "" );
        CallMenu( MC, Command );
    }
}

simulated function DeclineInvite()
{
    StopVoicemailIfPlaying();
    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "INVITE DECLINE GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "FRIEND_INVITE_DECLINE_FAILED" );
    else
        CloseMenu();
}

// mjm - check to see if we can send a voicemail, if so - go to the voicemail page first before sending whatever request.
simulated function PassThroughVoicemail(String Cmd, String Err)
{
    // If we're banned from voice communication, just send the invite, else - go to voicemail page - mjm
    if (int(ConsoleCommand("VOICEMAIL Cmd=1 Port=" $ PlayerController(Owner).Player.GamePadIndex)) == 0)
    {
        if( "SUCCESS" != ConsoleCommand(Cmd))
            OverlayErrorMessageBox(Err);
        else
            CloseMenu();
    }
    else
    {   
        CloseMenu();
        GotoMenuClass("XInterfaceLive.MenuAddVoiceAttachment", Cmd);
    }
}

simulated function SendInvite()
{
    PassThroughVoicemail("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "INVITE SEND GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"", "FRIEND_INVITE_SEND_FAILED");
}

simulated function CancelInvite()
{
    local MenuGamerConfirm M;

    M = Spawn( class'MenuGamerConfirm', Owner );

    M.BackClass = class;
    M.Gamer = GamerList.Gamers[GamerList.CurrentGamer];

    M.CommandText = "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "INVITE CANCEL GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"";
    M.FailedOperation = "INVITE_CANCEL_FAILED";

    M.SetText( StringCancelInvite );

    GotoMenu( M );
}

simulated function JoinFriend()
{
    JoinGame("JOIN");
}

simulated function FriendRequest()
{
    PassThroughVoicemail("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYER ADDFRIEND GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"", "FRIEND_REQUEST_FAILED");
}

simulated function RemoveFriend()
{
    local MenuGamerConfirm M;

    StopVoicemailIfPlaying();

    M = Spawn( class'MenuGamerConfirm', Owner );

    M.BackClass = class;
    M.Gamer = GamerList.Gamers[GamerList.CurrentGamer];

    M.CommandText = "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "FRIEND REMOVE GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"";
    M.FailedOperation = "FRIEND_REMOVE_FAILED";

    M.SetText( StringRemoveFriend );

    GotoMenu( M );
}

simulated function AcceptRequest()
{
    StopVoicemailIfPlaying();

    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REQUEST ACCEPT GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "FRIEND_ACCEPT_FAILED" );
    else
        CloseMenu();
}

simulated function DeclineRequest()
{
    StopVoicemailIfPlaying();

    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REQUEST DECLINE GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "FRIEND_DECLINE_FAILED" );
    else
        CloseMenu();
}

simulated function BlockRequest()
{
    local MenuGamerConfirm M;

    StopVoicemailIfPlaying();

    M = Spawn( class'MenuGamerConfirm', Owner );

    M.BackClass = class;
    M.Gamer = GamerList.Gamers[GamerList.CurrentGamer];

    M.CommandText = "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REQUEST BLOCK GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"";
    M.FailedOperation = "FRIEND_BLOCK_FAILED";

    M.SetText( StringBlockFriendRequest );

    GotoMenu( M );
}

simulated function CancelRequest()
{
    local MenuGamerConfirm M;

    M = Spawn( class'MenuGamerConfirm', Owner );

    M.BackClass = class;
    M.Gamer = GamerList.Gamers[GamerList.CurrentGamer];

    M.CommandText = "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "REQUEST CANCEL GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"";
    M.FailedOperation = "FRIEND_CANCEL_FAILED";

    M.SetText( StringCancelFriendRequest );

    GotoMenu( M );
}

simulated function Mute()
{
    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYER MUTE GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "PLAYER_MUTE_FAILED" );
    else
        CloseMenu();
}

simulated function UnMute()
{
    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYER UNMUTE GAMERTAG=\"" $ GamerList.Gamers[GamerList.CurrentGamer].Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "PLAYER_UNMUTE_FAILED" );
    else
        CloseMenu();
}

simulated function SendFeedback()
{
    local MenuPlayerFeedback M;

    StopVoicemailIfPlaying();
    M = Spawn( class'MenuPlayerFeedback', Owner );
    M.Gamer = GamerList.Gamers[GamerList.CurrentGamer];
    CallMenu( M );
}

simulated function PublishedCustomMaps()
{
    CallMenuClass("XInterfaceLive.MenuStorageTask", "XLIVE STORAGE ENUMERATE GAMERTAG=" $ MakeQuotedString( GamerList.Gamers[GamerList.CurrentGamer].Gamertag ) );
}

simulated function HandleInputBack()
{
    StopVoicemailIfPlaying();
    Super.HandleInputBack();
}

// mjm
simulated function ListenVoicemail()
{    
    if (VoicemailPlaying == 0)
    {
        Options[0].Blurred.Text = StringStopVoicemail;
        VoicemailPlaying = 1;
    }
    else
    {
        Options[0].Blurred.Text = StringPlayVoicemail;
        VoicemailPlaying = 0;
    }
    ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "VMAILCMD Msg=" $ VoicemailMsgPtr @ "Cmd=" $ VoicemailPlaying);
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Play enclosed voice attachment"),OnSelect="ListenVoicemail",Style="CenteredTextOption")
     Options(1)=(Blurred=(Text="Accept game invitation"),OnSelect="AcceptInvite")
     Options(2)=(Blurred=(Text="Decline game invitation"),OnSelect="DeclineInvite")
     Options(3)=(Blurred=(Text="Send game invitation"),OnSelect="SendInvite")
     Options(4)=(Blurred=(Text="Cancel game invitation"),OnSelect="CancelInvite")
     Options(5)=(Blurred=(Text="Custom Maps"),OnSelect="PublishedCustomMaps")
     Options(6)=(Blurred=(Text="Join friend's game"),OnSelect="JoinFriend")
     Options(7)=(Blurred=(Text="Remove from friends list"),OnSelect="RemoveFriend")
     Options(8)=(Blurred=(Text="Send friend request"),OnSelect="FriendRequest")
     Options(9)=(Blurred=(Text="Accept friend request"),OnSelect="AcceptRequest")
     Options(10)=(Blurred=(Text="Decline friend request"),OnSelect="DeclineRequest")
     Options(11)=(Blurred=(Text="Block friend request"),OnSelect="BlockRequest")
     Options(12)=(Blurred=(Text="Cancel friend request"),OnSelect="CancelRequest")
     Options(13)=(Blurred=(Text="Mute"),OnSelect="Mute")
     Options(14)=(Blurred=(Text="UnMute"),OnSelect="UnMute")
     Options(15)=(Blurred=(Text="Player feedback"),OnSelect="SendFeedback")
     OptionBox=(Pass=1,Style="DarkBorder")
     Info(0)=(DrawPivot=DP_MiddleMiddle,Pass=2,Style="NormalLabel")
     InfoBox=(Pass=1,Style="DarkBorder")
     StringCancelFriendRequest="Cancel the friend request you sent to <GAMER>?"
     StringBlockFriendRequest="Block all future friend requests from <GAMER>?"
     StringRemoveFriend="Really remove <GAMER> from your friends list?"
     StringCancelInvite="Really cancel the invite to <GAMER>?"
     StringGamertagToken="<GAMER>"
     StringSentRequest="Friend request sent."
     StringReceivedRequest="Friend request received."
     StringSentInvite="Invitation sent."
     StringInviteRejected="Invitation declined."
     StringInviteAccepted="Invitation accepted."
     StringReceivedInvite="Invitation received."
     StringIsPlaying="<GAMER> is playing:"
     StringPlayVoicemail="Play enclosed voice attachment"
     StringStopVoicemail="Stop playing voice attachment"
     OptionsLayout=(PosX=0.500000,PosY=0.630000,SpacingY=0.050000,BorderScaleX=0.700000,Pivot=DP_MiddleMiddle)
     InfoLayout=(PosX=0.500000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.700000,Pivot=DP_MiddleMiddle)
     MenuTitle=(MaxSizeX=0.600000)
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
