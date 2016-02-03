class VignetteConnecting extends VignetteLoading
    config;

var() config String ServerName;

var() MenuSprite            BButtonIcon;
var() MenuText              BLabel;
var() MenuButtonText        BButton;
var() EMenuWidgetPlatform   BPlatform;
var() int                   BButtonHidden;

var() MenuSprite            AButtonIcon;
var() MenuText              ALabel;
var() MenuButtonText        AButton;
var() EMenuWidgetPlatform   APlatform;
var() int                   AButtonHidden;

var() MenuText              ConnectionFailedMessage;

var() localized String StringConnecting;
var() localized String StringConnectingTo;

const URLPrefix = "UNREAL://";

simulated function Init( String Args )
{
    Super.Init( Args );
    
    if( ServerName == "" )
    {
        MenuTitle.Text = StringConnecting;
    }
    else
    {
        MenuTitle.Text = ReplaceSubstring( StringConnectingTo, "<SERVERNAME>", ServerName );
    }
    
    RollBink();
}

simulated exec function ConnectionFailed()
{
    log("ConnectionFailed");

    Background.WidgetTexture = default.Background.WidgetTexture;
    Background.DrawColor = class'MenuTemplateTitled'.default.Background.DrawColor;
    ConnectionFailedMessage.bHidden = 0;

    HideAButton(0);
    HideBButton(1);
}

simulated function LogMessage( String Text )
{
    if( BButtonHidden != 0 )
        return;

    MenuTitle.Text = Text;
}

simulated function SetProgress( String Str1, String Str2 )
{
    if( Str1 == Str2 )
        Str2 = "";

    if( Str1 == "" )
    {
        Str1 = Str2;
        Str2 = "";
    }
        
    if( Str1 == "" )
        return;
        
    if( Left(Caps(Str1), Len(URLPrefix)) == Caps(URLPrefix) )
        return; // Can't show URLs on Xbox
   
    MenuTitle.Text = Str1;
}

simulated function NotifyProgress( String Str1, String Str2 )
{
    Str1 = Str1;
    Str2 = Str2;

    if( Str1 == Str2 )
        Str2 = "";

    if( Str1 == "" )
    {
        Str1 = Str2;
        Str2 = "";
    }
        
    if( Str1 == "" )
        return;

    MenuTitle.Text = Str1;
}

simulated function OnAButton()
{
    if( AButtonHidden != 0 )
    {
        return;
    }

    ConsoleCommand( "DISCONNECT" );
}

simulated function OnBButton()
{
    if( BButtonHidden != 0 )
    {
        return;
    }

    ConsoleCommand( "DISCONNECT" );
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function HideBButton(int hide)
{
    BButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function HideAButton(int hide)
{
    AButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function PackButtonBar( Canvas C, float PivotX )
{
    local float UpdatedPivotX;
    
    UpdatedPivotX = PivotX;
    
    PackButton( C, BButtonIcon, BLabel, BButton, BPlatform, BButtonHidden, UpdatedPivotX );
    PackButton( C, AButtonIcon, ALabel, AButton, APlatform, AButtonHidden, UpdatedPivotX );
}

simulated event DoDynamicLayout( Canvas C )
{
    PackButtonBar( C, ButtonBarPivotX );
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "B" )
    {
        OnBButton();
        return( true );
    }
    
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     BButtonIcon=(Pass=2,Style="XboxButtonB")
     BLabel=(Text="Cancel",Pass=2,Style="LabelText")
     BButton=(bIgnoreController=1,OnSelect="OnBButton",Pass=1,Style="PushButtonRounded")
     AButtonIcon=(Pass=2,Style="XboxButtonA")
     ALabel=(Text="Continue",Pass=2,Style="LabelText")
     AButton=(bIgnoreController=1,OnSelect="OnAButton",Pass=1,Style="PushButtonRounded")
     AButtonHidden=1
     ConnectionFailedMessage=(Text="This game session is no longer available.",bHidden=1,Style="LongMessageText")
     StringConnecting="Connecting..."
     StringConnectingTo="Connecting to <SERVERNAME>..."
     MenuTitle=(MaxSizeX=0.840000)
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
