class MenuGamerList extends MenuTemplateTitledBA
    abstract;
#exec OBJ LOAD FILE=..\Textures\PariahInterface.utx

struct Gamer
{
    var() String UID;
    var() String Gamertag;
    var() String NickName; // DEPRICATED!!!
    var() String GameTitle;
    var() int bIsInDifferentTitle;
    var() int bInviteAccepted;
    var() int bInviteRejected;
    var() int bJoinable;
    var() int bInvitable;
    var() int bOnline;
    var() int bReceivedRequest;
    var() int bSentRequest;
    var() int bPlaying;
    var() int bReceivedInvite;
    var() int bSentInvite;
    var() int bHasVoice;
    var() int bIsFriend;
    var() int bIsMuted;
    var() int bIsGuest;
    var() int bIsTalking;
};

var() Array<Gamer> Gamers;
var() int CurrentGamer;

var() Material IconCommunicatorMuted;
var() Material IconCommunicatorOn;
var() Material IconCommunicatorTalking;
var() Material IconCommunicatorTv;
var() Material IconFriendInviteReceived;
var() Material IconFriendInviteSent;
var() Material IconFriendOnline;
var() Material IconGameInviteReceived;
var() Material IconGameInviteSent;

const FRIEND_COLUMN_COUNT = 3;
const FRIEND_ROW_COUNT = 5;

const FC_Name = 0;
const FC_CommunicatorStatus = 1;
const FC_PresenceStatus = 2;

var() MenuSprite        GamerListBorder;
var() MenuSprite        GamerListScrollBorder;
var() MenuStringList    GamerListColumns[FRIEND_COLUMN_COUNT];
var() MenuButtonSprite  GamerListArrows[2];
var() MenuScrollBar     GamerListScrollBar;
var() MenuActiveWidget  GamerListPageUp, GamerListPageDown;
var() MenuScrollArea    GamerScrollArea;

var() MenuSprite        GamerInfoBorder;
var() MenuText          GamerInfoText;

var() localized String  TextEmptyList;
var() localized String  TextReceivedInvite;
var() localized String  TextReceivedRequest;
var() localized String  TextOnline;
var() localized String  TextFriend;
var() localized String  TextOffline;
var() localized String  TextSentInvite;
var() localized String  TextSentRequest;
var() localized String  TextVoiceOn;
var() localized String  TextVoiceOff;
var() localized String  TextVoiceTV;
var() localized String  TextVoiceMuted;
var() localized String  TextInviteAccepted;
var() localized String  TextInviteRejected;
var() localized String  TextPlaying;
var() localized String  TextPlayingGame;

var() Color OfflineColor;
var() Color OnlineColor;

var() String ExecMode; // FRIEND | GAMER

simulated function int FindFocus()
{
    local int i;
    
    for( i = 0; i < GamerListColumns[FC_Name].Items.Length; i++ )
    {
        if( GamerListColumns[FC_Name].Items[i].bHasFocus != 0 )
            return i;
    }
    return -1;
}

simulated function bool CurrentGamerIsValid()
{
    return( (CurrentGamer >= 0) && (CurrentGamer < Gamers.Length) );
}

simulated function RefreshList()
{
    local int i;
    local String LastGamertag;
    local String GamerString;

    CurrentGamer = FindFocus();

    if( CurrentGamer >= 0 )
    {
        LastGamertag = Gamers[CurrentGamer].Gamertag;
    }

    Gamers.Length = int(ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "GET" $ ExecMode $ "COUNT") );

    for( i = 0; i < Gamers.Length; ++i )
    {
        GamerString = ConsoleCommand("XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "GET" $ ExecMode @ i);
        
        Gamers[i].UID = ParseToken(GamerString);
        Gamers[i].Gamertag = ParseToken(GamerString);
        Gamers[i].NickName = ParseToken(GamerString);
        Gamers[i].GameTitle = ParseToken(GamerString);
        Gamers[i].bIsInDifferentTitle = int(ParseToken(GamerString));
        Gamers[i].bInviteAccepted = int(ParseToken(GamerString));
        Gamers[i].bInviteRejected = int(ParseToken(GamerString));
        Gamers[i].bJoinable = int(ParseToken(GamerString));
        Gamers[i].bInvitable = int(ParseToken(GamerString));
        Gamers[i].bOnline = int(ParseToken(GamerString));
        Gamers[i].bReceivedRequest = int(ParseToken(GamerString));
        Gamers[i].bSentRequest = int(ParseToken(GamerString));
        Gamers[i].bPlaying = int(ParseToken(GamerString));
        Gamers[i].bReceivedInvite = int(ParseToken(GamerString));
        Gamers[i].bSentInvite = int(ParseToken(GamerString));
        Gamers[i].bHasVoice = int(ParseToken(GamerString));
        Gamers[i].bIsFriend = int(ParseToken(GamerString));
        Gamers[i].bIsMuted = int(ParseToken(GamerString));
        Gamers[i].bIsGuest = int(ParseToken(GamerString));
        Gamers[i].bIsTalking = int(ParseToken(GamerString));
        
        if( ParseToken(GamerString) != "###" )
            log( "*** ParseList error, terminator not found!", 'Error' );
    }
    
    CurrentGamer = -1;
    
    for( i = 0; i < Gamers.Length; i++ )
    {
        if( Gamers[i].Gamertag == LastGamertag )
        {
            CurrentGamer = i;
            break;
        }
    }
 
    RefreshColumns();
}

simulated exec function Pork()
{
    local int i, c;
    Gamers.Length = 0;

    c = Rand(20) + 10;
    
    for( i = 0; i < c; i++ )
    {
        Gamers[i].UID = "";
        Gamers[i].Gamertag = "AssTagAssTagGG" $ Rand(1000);

        Gamers[i].bIsFriend = Rand(2);

        Gamers[i].bOnline = Rand(2);
        
        if( Gamers[i].bOnline != 0 )
        {
            Gamers[i].GameTitle = "Shitty Crapgame" @ Rand(1000);
            Gamers[i].bIsInDifferentTitle = Rand(2);
            
            if( Gamers[i].bIsFriend != 0 )
            {
                Gamers[i].bJoinable = Rand(2);
                Gamers[i].bInviteAccepted = Rand(2);
                Gamers[i].bInviteRejected = Rand(2);
                Gamers[i].bInvitable = Rand(2);
                Gamers[i].bReceivedInvite = Rand(2);
                Gamers[i].bSentInvite = Rand(2);
            }            
            else
            {
                Gamers[i].bReceivedRequest = Rand(2);

                if( Gamers[i].bReceivedRequest == 0 )
                    Gamers[i].bSentRequest = Rand(2);
            }
                        
            Gamers[i].bPlaying = Rand(2);

            Gamers[i].bIsMuted = Rand(2);
            Gamers[i].bIsGuest = Rand(2);
            
            Gamers[i].bHasVoice = Rand(2);
            
            if( Gamers[i].bHasVoice != 0 )
                Gamers[i].bIsTalking = Rand(2);
        }
    }

    RefreshColumns();
}

simulated function UpdateInfoText()
{
    local int i;
    
    if( Gamers.Length == 0 )
    {
        GamerInfoText.Text = TextEmptyList;
        HideAButton( 1 );
        return;
    }
    
    HideAButton( 0 );

    for( i = 0; i < GamerListColumns[FC_Name].Items.Length; i++ )
    {
        if( GamerListColumns[FC_Name].Items[i].bHasFocus != 0 )
        {
            GetInfoText( Gamers[i], GamerInfoText.Text );
            return;
        }
    }
    
    GamerInfoText.Text = "";
}

simulated function FocusOnGamer( int i )
{
    local int NewPosition;
    
    if( i >= GamerListColumns[FC_Name].Items.Length )
        return;
    
    if( GamerListColumns[FC_Name].Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, GamerListColumns[FC_Name].Items.Length - GamerListColumns[FC_Name].DisplayCount ) );

        ScrollGamerListTo( NewPosition );
        Assert( GamerListColumns[FC_Name].Items[i].bHidden == 0 );
    }

    FocusOnWidget( GamerListColumns[FC_Name].Items[i] );
}

simulated function RefreshColumns()
{
    local int i;
   
    FocusOnNothing();

    for( i = 0; i < FRIEND_COLUMN_COUNT; i++ )
        GamerListColumns[i].Items.Remove( 0, GamerListColumns[i].Items.Length );

    for( i = 0; i < Gamers.Length; i++ )
    {
        GamerListColumns[FC_Name].Items[i].Blurred.Text = Gamers[i].Gamertag;
        GamerListColumns[FC_Name].Items[i].Focused.Text = GamerListColumns[FC_Name].Items[i].Blurred.Text;
        GamerListColumns[FC_Name].Items[i].Blurred.DrawColor = OnlineColor;
        GamerListColumns[FC_Name].Items[i].Focused.DrawColor = OnlineColor;
        GamerListColumns[FC_CommunicatorStatus].Items[i].Blurred.Text = " ";
        GamerListColumns[FC_PresenceStatus].Items[i].Blurred.Text = " ";
    }

    for( i = 0; i < ArrayCount( GamerListColumns ); i++ )
    {
        GamerListColumns[i].DisplayCount = FRIEND_ROW_COUNT;
        LayoutMenuStringList( GamerListColumns[i] );
        GamerListColumns[i].Position = -1; // To force a re-position/re-draw.
    }
    
    SetListPosition( 0 );

    GamerListScrollBar.Position = GamerListColumns[0].Position;
    GamerListScrollBar.Length = GamerListColumns[0].Items.Length;
    GamerListScrollBar.DisplayCount = FRIEND_ROW_COUNT;

    LayoutMenuScrollBarEx( GamerListScrollBar, GamerListPageUp, GamerListPageDown ); // Will trigger a redraw.

    if( CurrentGamerIsValid() )
        FocusOnGamer(CurrentGamer);
    else if( Gamers.Length > 0 )
        FocusOnGamer(0);

    UpdateInfoText();
}


simulated function Material GetCommunicatorIcon( out Gamer G )
{
    if( G.bIsMuted != 0 )
        return( IconCommunicatorMuted );
    else if( G.bOnline == 0 )
        return( None );
    else if( G.bIsTalking != 0 )
        return( IconCommunicatorTalking );
    else if( G.bHasVoice != 0 )
        return( IconCommunicatorOn );
    else
        return( None );
}

simulated function Material GetPresenceIcon( out Gamer G )
{
    if( G.bReceivedInvite != 0 )
        return( IconGameInviteReceived );
    else if( G.bReceivedRequest != 0 )
        return( IconFriendInviteReceived );
    else if( (G.bSentInvite != 0) && (G.bInviteAccepted == 0) && (G.bInviteRejected == 0) )
        return( IconGameInviteSent );
    else if( G.bSentRequest != 0 )
        return( IconFriendInviteSent );
    else if( G.bOnline == 0 )
        return( None );
    else if( G.bIsFriend != 0 )
        return( IconFriendOnline );
    else
        return( None );
}

simulated function GetInfoText( out Gamer G, out String S )
{
    S = G.Gamertag $ ":";

    if( G.bOnline == 0 )
        S = S @ TextOffline;
    else
        S = S @ TextOnline;

    if( G.bIsFriend != 0 )
        S = S @ TextFriend;

    if( G.bIsMuted != 0 )
        S = S @ TextVoiceMuted;
    else if( G.bOnline != 0 )
    {
        if(  G.bHasVoice != 0 )
           S = S @ TextVoiceOn;
        else
           S = S @ TextVoiceOff;
    }

    if( G.bIsFriend == 0 )
    {
        if( G.bSentRequest != 0 )
            S = S @ TextSentRequest;
        else if( G.bReceivedRequest != 0 )
            S = S @ TextReceivedRequest;
    }
    else
    {
        if( G.bReceivedInvite != 0 )
            S = S @ TextReceivedInvite;

        if( G.bSentInvite != 0 )
        {
            if( G.bInviteAccepted != 0 )
                S = S @ TextInviteAccepted;
            else if( G.bInviteRejected != 0 )
                S = S @ TextInviteRejected;
            else
                S = S @ TextSentInvite;
        }
    }
    
    if( G.GameTitle != "")
        S = S @ TextPlayingGame @ G.GameTitle $ ",";
    else if( G.bPlaying != 0 )
        S = S @ TextPlaying;

    if( Right( S, 1 ) == "," )
    {
        S = Left( S, Len(S) - 1 ) $ ".";
    }
}

simulated function SetListPosition( int NewPosition )
{
    local int i, j;
    local Material M;
    
    for( i = 0; i < ArrayCount( GamerListColumns ); i++ )
    {
        if( GamerListColumns[i].Position != NewPosition )
        {
            GamerListColumns[i].Position = NewPosition;
            LayoutMenuStringList( GamerListColumns[i] );

            for( j = 0; j < Gamers.Length; j++ )
            {
                if( Gamers[j].bOnline == 0 )
                {
                    GamerListColumns[FC_Name].Items[j].Blurred.DrawColor = OfflineColor;
                }

                M = GetCommunicatorIcon( Gamers[j] );
               
                GamerListColumns[FC_CommunicatorStatus].Items[j].Blurred.Text = " ";                
                GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.bHidden = 0;
                GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.WidgetTexture = M;
                GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.TextureCoords.X2 = 0;
                GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.TextureCoords.Y2 = 0;

                if( Gamers[j].bOnline == 0 )
                {
                    GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.DrawColor = OfflineColor;              
                }else
                {
                    GamerListColumns[FC_CommunicatorStatus].Items[j].BackgroundBlurred.DrawColor =  OnlineColor;
                }
                
                M = GetPresenceIcon( Gamers[j] );

                GamerListColumns[FC_PresenceStatus].Items[j].Blurred.Text = " ";
                GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.bHidden = 0;
                GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.WidgetTexture = M;
                GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.TextureCoords.X2 = 0;
                GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.TextureCoords.Y2 = 0;

                if( Gamers[j].bOnline == 0 )
                    GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.DrawColor = OfflineColor;
                else
                {
                    GamerListColumns[FC_PresenceStatus].Items[j].BackgroundBlurred.DrawColor = OnlineColor;
                }

            }
        }
        
        if( i == 0 )
            continue;
            
        for( j = 0; j < GamerListColumns[i].Items.Length; j++ )
            GamerListColumns[i].Items[j].bDisabled = 1;
    }
}

simulated function UpdateScrollBar()
{
    SetListPosition( GamerListColumns[0].Position );

    GamerListScrollBar.Position = GamerListColumns[0].Position;
    GamerListScrollBar.Length = GamerListColumns[0].Items.Length;
    GamerListScrollBar.DisplayCount = GamerListColumns[0].DisplayCount;
    
    LayoutMenuScrollBarEx( GamerListScrollBar, GamerListPageUp, GamerListPageDown ); // Will trigger a redraw.
}

simulated function OnGamerListScroll()
{
    SetListPosition( GamerListScrollBar.Position );
}


simulated function ScrollGamerListTo( int NewPosition )
{
    if( GamerListScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, GamerListScrollBar.Length - GamerListScrollBar.DisplayCount ) );

    if( GamerListScrollBar.Position == NewPosition )
        return;
    
    GamerListScrollBar.Position = NewPosition;
    
    LayoutMenuScrollBar( GamerListScrollBar );
}

simulated function OnGamerListScrollUp()
{
    ScrollGamerListTo( GamerListScrollBar.Position - 1 );
}

simulated function OnGamerListScrollDown()
{
    ScrollGamerListTo( GamerListScrollBar.Position + 1 );
}

simulated function OnGamerListPageUp()
{
    ScrollGamerListTo( GamerListScrollBar.Position - GamerListScrollBar.DisplayCount );
}

simulated function OnGamerListPageDown()
{
    ScrollGamerListTo( GamerListScrollBar.Position + GamerListScrollBar.DisplayCount );
}

simulated function OnGamerListScrollLinesUp( int Lines )
{
    ScrollGamerListTo( GamerListScrollBar.Position - Lines );
}

simulated function OnGamerListScrollLinesDown( int Lines )
{
    ScrollGamerListTo( GamerListScrollBar.Position + Lines );
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function OnAButton()
{
    CurrentGamer = FindFocus();

    if( CurrentGamer < 0 )
        return;

    CallMenuClass( "XInterfaceLive.MenuGamerDetails" );
}

defaultproperties
{
     IconCommunicatorMuted=Texture'InterfaceContent.LiveIcons.CommunicatorMuted'
     IconCommunicatorOn=Texture'InterfaceContent.LiveIcons.CommunicatorOn'
     IconCommunicatorTalking=Texture'InterfaceContent.LiveIconsAnim.Communicator_a00'
     IconCommunicatorTv=Texture'InterfaceContent.LiveIcons.CommunicatorTv'
     IconFriendInviteReceived=FinalBlend'InterfaceContent.LiveIcons.fbFriendInviteReceived'
     IconFriendInviteSent=Texture'InterfaceContent.LiveIcons.FriendInviteSent'
     IconFriendOnline=Texture'InterfaceContent.LiveIcons.FriendOnline'
     IconGameInviteReceived=FinalBlend'InterfaceContent.LiveIcons.fbGameInviteReceived'
     IconGameInviteSent=Texture'InterfaceContent.LiveIcons.GameInviteSent'
     GamerListBorder=(DrawColor=(A=255),DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.200000,ScaleX=0.790000,ScaleY=0.360000,Pass=1,Style="Border")
     GamerListScrollBorder=(DrawColor=(A=255),DrawPivot=DP_UpperMiddle,PosX=0.875000,PosY=0.200000,ScaleX=0.040000,ScaleY=0.360000,Pass=2,Style="Border")
     GamerListColumns(0)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.600000),BackgroundFocused=(DrawPivot=DP_MiddleLeft,PosX=-0.023500,ScaleX=0.747000,ScaleY=0.060000),OnFocus="UpdateInfoText",OnSelect="OnAButton"),PosX1=0.130000,PosY1=0.240000,PosX2=0.130000,PosY2=0.520000,OnScroll="UpdateScrollBar",Pass=2,Style="CyanButtonListWide")
     GamerListColumns(1)=(Template=(BackgroundBlurred=(DrawPivot=DP_MiddleMiddle,PosY=-0.004000,ScaleX=0.500000,ScaleY=0.500000),bDisabled=1),PosX1=0.760000,PosX2=0.760000,OnScroll="DoNothing")
     GamerListColumns(2)=(Template=(BackgroundBlurred=(DrawPivot=DP_MiddleMiddle,PosY=-0.004000,ScaleX=0.500000,ScaleY=0.500000),bDisabled=1),PosX1=0.820000,PosX2=0.820000,OnScroll="DoNothing")
     GamerListArrows(0)=(Blurred=(PosX=0.875000,PosY=0.220000),bIgnoreController=1,OnSelect="OnGamerListScrollUp",Pass=3,Style="TitledStringListArrowUp")
     GamerListArrows(1)=(Blurred=(PosY=0.545000),OnSelect="OnGamerListScrollDown",Style="TitledStringListArrowDown")
     GamerListScrollBar=(PosX1=0.875000,PosY1=0.230000,PosX2=0.875000,PosY2=0.540000,OnScroll="OnGamerListScroll",Pass=3,Style="VerticalScrollBar")
     GamerListPageUp=(bIgnoreController=1,OnSelect="OnGamerListPageUp",Pass=2)
     GamerListPageDown=(bIgnoreController=1,OnSelect="OnGamerListPageDown",Pass=2)
     GamerScrollArea=(X1=0.029000,Y1=0.200000,X2=0.971000,Y2=0.800000,OnScrollPageUp="OnGamerListPageUp",OnScrollLinesUp="OnGamerListScrollLinesUp",OnScrollLinesDown="OnGamerListScrollLinesDown",OnScrollPageDown="OnGamerListPageDown")
     GamerInfoBorder=(DrawColor=(A=255),DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.580000,ScaleX=0.790000,ScaleY=0.210000,Pass=1,Style="Border")
     GamerInfoText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),PosX=0.130000,PosY=0.580000,ScaleX=0.700000,ScaleY=0.700000,MaxSizeX=0.740000,bWordWrap=1,Pass=3)
     TextReceivedInvite="game invite received,"
     TextReceivedRequest="friend request received,"
     TextOnline="online,"
     TextFriend="friend,"
     TextOffline="offline,"
     TextSentInvite="game invite sent,"
     TextSentRequest="friend request sent,"
     TextVoiceOn="voice on,"
     TextVoiceOff="voice off,"
     TextVoiceTV="voice through tv,"
     TextVoiceMuted="voice muted,"
     TextInviteAccepted="game invite accepted,"
     TextInviteRejected="game invite declined,"
     TextPlaying="playing,"
     TextPlayingGame="playing"
     OfflineColor=(B=127,G=127,R=127,A=255)
     OnlineColor=(B=255,G=255,R=255,A=255)
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
