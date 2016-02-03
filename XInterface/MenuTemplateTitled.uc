class MenuTemplateTitled extends MenuTemplate
    native;

#exec LOAD FILE="VideoTextures.utx"

var() MenuText      MenuTitle;
var() MenuSprite    TopBar;
var() MenuSprite    BottomBar;
var() MenuSprite    MenuTitleLine;
var() MenuSprite    Background;

var() MenuSprite	ControllerIcon;
var() MenuSprite	XBLFriendsRequest;
var() MenuSprite	XBLGameInvitation;
var() MenuText      GamertagText;
var() MenuText      GamerOnlineStatusText;
var() MenuText      ControllerNumText;
var() MenuText      CurrentProfileText;

var() float         VideoChangeCountdown;
var() float         VideoChangeDelay;
var() String        NextVideo;

var localized string CurrentProfile;
var localized String LiveStatusStrings[4];

// Pivot for MiddleRight:
var() float ButtonBarPivotX;
var() float ButtonBarPivotY;

// Gap between buttons:
var() float ButtonBarDX;

// Extra size for background:
var() float ButtonBackgroundPaddingDX;

// Gap between icon and text:
var() float ButtonIconDX;

simulated function Init( String Args )
{
	Super.Init(Args);
	UpdateLiveInfo();

    RestoreVideo();
}

simulated function Destroyed()
{    
    Super.Destroyed();
}

simulated function Tick(float deltaTime)
{
    local VideoTexture VT;

	Super.Tick(deltaTime);

	UpdateLiveInfo();
    
    SetButtonBarOpacity(1.0-HelpTextOpacity);

    if( VideoChangeCountdown > 0.f )
    {
        VideoChangeCountdown -= deltaTime;
        
        if( VideoChangeCountdown < 0 )
        {
            VT = VideoTexture(Background.WidgetTexture);
            VT.PlaySoundTrack = false;
            VT.OverrideVideoFile = NextVideo;
            NextVideo = "";
        }
    }
}

simulated function UpdateLiveInfo()
{
    local PlayerController PC;

    PC = PlayerController(Owner);

    if( bVignette || (GetPlatform() != MWP_Xbox) || (PC == None) || (PC.Player == None) || (PC.bIsGuest) )
    {
        GamertagText.bHidden = 1;
        GamerOnlineStatusText.bHidden = 1;
        ControllerNumText.bHidden = 1;
        ControllerIcon.bHidden = 1;
        XBLFriendsRequest.bHidden = 1;
        XBLGameInvitation.bHidden = 1;
        return;
    }

    GamertagText.bHidden = default.GamertagText.bHidden;
    GamerOnlineStatusText.bHidden = default.GamerOnlineStatusText.bHidden;

    if( GamerOnlineStatusText.Text != LiveStatusStrings[PC.LiveStatus] )
    {
        GamerOnlineStatusText.Text = LiveStatusStrings[PC.LiveStatus];
    }
	
    if( GamertagText.Text != PC.Gamertag )
    {
        GamertagText.Text = PC.Gamertag;
    }
    
    if( GamertagText.Text == "" )
    {
        GamerOnlineStatusText.PosY = GamertagText.PosY;
    }
    else
    {
        GamerOnlineStatusText.PosY = default.GamerOnlineStatusText.PosY;
    }
    
    if( PC.Player.GamePadIndex < 0 )
    {
        ControllerNumText.bHidden = 1;
        ControllerIcon.bHidden = 1;
    }
    else
    {
        ControllerNumText.Text = String(PC.Player.GamePadIndex + 1);
        ControllerNumText.bHidden = default.ControllerNumText.bHidden;
        ControllerIcon.bHidden = default.ControllerIcon.bHidden;
    }
    
    if( (PC.LiveStatus == LS_SignedIn) && (PC.NumGameInvites > 0) )
    {
        XBLGameInvitation.bHidden = default.XBLGameInvitation.bHidden;
        HelpTextState = HTS_Hidden;
    }
    else
    {
        XBLGameInvitation.bHidden = 1;
    }        
    
    if( (PC.LiveStatus == LS_SignedIn) && (PC.NumFriendRequests > 0) )
    {
        XBLFriendsRequest.bHidden = default.XBLFriendsRequest.bHidden;
        HelpTextState = HTS_Hidden;
        
        if( XBLGameInvitation.bHidden != 0 )
        {
            XBLFriendsRequest.PosX = XBLGameInvitation.PosX;
        }
        else
        {
            XBLFriendsRequest.PosX = default.XBLFriendsRequest.PosX;
        }
    }
    else
    {
        XBLFriendsRequest.bHidden = 1;
    }        
}

simulated function SetButtonBarOpacity(float Opacity)
{
}

native simulated function PackButton
(
    Canvas C,
    out MenuSprite Icon,
    out MenuText Label,
    out MenuButtonText Button,
    EMenuWidgetPlatform Platform,
    int bHidden,
    out float PivotX
);

simulated function PackButtonBar( Canvas C, float PivotX )
{
}

simulated function SetBackgroundVideo( String NewVideoFile )
{
    local VideoTexture VT;

    if( CrossFadeDir == TD_Out )
        return;

    VT = VideoTexture(Background.WidgetTexture);
    
    if( VT == None )
    {
        return;
    }

    NextVideo = NewVideoFile;

    if( VideoChangeCountdown < 0 )
    {
        VT.PlaySoundTrack = false;
        VT.OverrideVideoFile = NewVideoFile;
        VideoChangeCountdown = VideoChangeDelay;
        return;
    }
    
    // Defer it for a while:
    VideoChangeCountdown = VideoChangeDelay;
}

simulated function RestoreVideo()
{
    local VideoTexture VT;
    
    VT = VideoTexture(Background.WidgetTexture);
    
    if( VT == None )
    {
        return;
    }

    VT.PlaySoundTrack = false;
    
    if( IsMiniEd() )
    {
        VT.VideoFile = "MiniEdLoop.bik";
    }
    else
    {
        VT.VideoFile = "PariahMenuLoop.bik";
    }
    
    VT.OverrideVideoFile = "";
    VideoChangeCountdown = -1;
}

function ShowCurrentProfile(string profileName)
{
    if(NameIsReserved(profileName) || PlayerController(Owner).IsSharingScreen())
    {
        return;
    }
    CurrentProfileText.bHidden = 0;
    CurrentProfileText.Text = CurrentProfile;
    UpdateTextField(CurrentProfileText.Text, "<ProfileName>", profileName);    
}

defaultproperties
{
     MenuTitle=(PosX=0.080000,PosY=0.130000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,Style="NormalLabel")
     TopBar=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(A=255),ScaleX=1.000000,ScaleY=0.155000,ScaleMode=MSM_Fit,Pass=1)
     BottomBar=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(A=255),DrawPivot=DP_LowerLeft,PosY=1.000000,ScaleX=1.000000,ScaleY=0.155000,ScaleMode=MSM_Fit,Pass=1)
     MenuTitleLine=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=100,G=100,R=100,A=255),PosY=0.155000,ScaleX=80.000000,ScaleY=0.100000,Pass=2,bHidden=1)
     Background=(WidgetTexture=VideoTexture'VideoTextures.MenuBackground',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=96),PosY=0.155000,ScaleX=1.000000,ScaleY=0.690000,ScaleMode=MSM_Fit)
     ControllerIcon=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.ControllerIcon',DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.910000,PosY=0.110000,ScaleX=1.000000,ScaleY=1.000000,Pass=3)
     XBLFriendsRequest=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbFriendInviteReceived',DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.125000,PosY=0.894000,ScaleX=0.450000,ScaleY=0.450000,Pass=3)
     XBLGameInvitation=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbGameInviteReceived',DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.080000,PosY=0.894000,ScaleX=0.450000,ScaleY=0.450000,Pass=3)
     GamertagText=(DrawPivot=DP_MiddleRight,PosX=0.870000,PosY=0.135000,MaxSizeX=0.600000,Pass=3,Style="SmallLabel")
     GamerOnlineStatusText=(DrawPivot=DP_MiddleRight,PosX=0.870000,PosY=0.100000,MaxSizeX=0.600000,Pass=3,Style="SmallLabel")
     ControllerNumText=(DrawColor=(B=213,G=208,R=163,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.885000,PosY=0.100000,Pass=4,Style="LabelText")
     CurrentProfileText=(DrawPivot=DP_MiddleLeft,PosX=0.080000,PosY=0.090000,MaxSizeX=0.600000,Pass=3,bHidden=1,Style="SmallLabel")
     VideoChangeCountdown=-1.000000
     VideoChangeDelay=0.500000
     CurrentProfile="Current Profile: <ProfileName>"
     LiveStatusStrings(0)="Not Signed In"
     LiveStatusStrings(1)="Not Signed in : Passcode Needed"
     LiveStatusStrings(2)="Signed In"
     LiveStatusStrings(3)="Sign In Failed"
     ButtonBarPivotX=0.950000
     ButtonBarPivotY=0.896000
     ButtonBarDX=0.035000
     ButtonBackgroundPaddingDX=0.020000
     ButtonIconDX=0.001000
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
