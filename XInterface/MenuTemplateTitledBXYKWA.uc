class MenuTemplateTitledBXYKWA extends MenuTemplateTitledBX
    native;

var() MenuSprite            YButtonIcon;
var() MenuText              YLabel;
var() MenuButtonText        YButton;

var() EMenuWidgetPlatform   YPlatform;
var() int                   YButtonHidden;

var() MenuSprite            KButtonIcon;
var() MenuText              KLabel;
var() MenuButtonText        KButton;

var() EMenuWidgetPlatform   KPlatform;
var() int                   KButtonHidden;

var() MenuSprite            WButtonIcon;
var() MenuText              WLabel;
var() MenuButtonText        WButton;

var() EMenuWidgetPlatform   WPlatform;
var() int                   WButtonHidden;

var() MenuSprite            AButtonIcon;
var() MenuText              ALabel;
var() MenuButtonText        AButton;

var() EMenuWidgetPlatform   APlatform;
var() int                   AButtonHidden;

simulated function OnYButton();
simulated function OnAButton();
simulated function OnKButton();
simulated function OnWButton();

simulated function HideYButton(int hide)
{
    YButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function HideAButton(int hide)
{
    AButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function HideKButton(int hide)
{
    KButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function HideWButton(int hide)
{
    WButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "Y" )
    {
        OnYButton();
        return( true );
    }
    
    if( ButtonName ~= "K" )
    {
        OnKButton();
        return( true );
    }
    
    if( ButtonName ~= "W" )
    {
        OnWButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

/* DON'T DO THIS! It will subvert input from widgets on the page (buttons/spinners etc)!
simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}
*/

simulated function SetButtonBarOpacity( float Opacity )
{
    AButtonIcon.DrawColor.A = 255 * Opacity;
    ALabel.DrawColor.A = 255 * Opacity;
    AButton.Blurred.DrawColor.A = 255 * Opacity;
    AButton.Focused.DrawColor.A = 255 * Opacity;
    AButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    AButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;
    
    YButtonIcon.DrawColor.A = 255 * Opacity;
    YLabel.DrawColor.A = 255 * Opacity;
    YButton.Blurred.DrawColor.A = 255 * Opacity;
    YButton.Focused.DrawColor.A = 255 * Opacity;
    YButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    YButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;
    
    KButtonIcon.DrawColor.A = 255 * Opacity;
    KLabel.DrawColor.A = 255 * Opacity;
    KButton.Blurred.DrawColor.A = 255 * Opacity;
    KButton.Focused.DrawColor.A = 255 * Opacity;
    KButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    KButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;
    
    WButtonIcon.DrawColor.A = 255 * Opacity;
    WLabel.DrawColor.A = 255 * Opacity;
    WButton.Blurred.DrawColor.A = 255 * Opacity;
    WButton.Focused.DrawColor.A = 255 * Opacity;
    WButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    WButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;

    Super.SetButtonBarOpacity( Opacity );
}

simulated function PackButtonBar( Canvas C, float PivotX )
{
    local float UpdatedPivotX;
    
    UpdatedPivotX = PivotX;
    
    PackButton( C, AButtonIcon, ALabel, AButton, APlatform, AButtonHidden, UpdatedPivotX );
    PackButton( C, WButtonIcon, WLabel, WButton, WPlatform, WButtonHidden, UpdatedPivotX );
    PackButton( C, KButtonIcon, KLabel, KButton, KPlatform, KButtonHidden, UpdatedPivotX );
    PackButton( C, YButtonIcon, YLabel, YButton, YPlatform, YButtonHidden, UpdatedPivotX );

    Super.PackButtonBar( C, UpdatedPivotX );
}

simulated event DoDynamicLayout( Canvas C )
{
    PackButtonBar( C, ButtonBarPivotX );
}

defaultproperties
{
     YButtonIcon=(Pass=2,Style="XboxButtonY")
     YLabel=(Text="Select",Pass=2,Style="LabelText")
     YButton=(bIgnoreController=1,OnSelect="OnYButton",Pass=1,Style="PushButtonRounded")
     KButtonIcon=(Pass=2,Style="XboxButtonBlack")
     KLabel=(Pass=2,Style="LabelText")
     KButton=(bIgnoreController=1,OnSelect="OnKButton",Pass=1,Style="PushButtonRounded")
     WButtonIcon=(Pass=2,Style="XboxButtonWhite")
     WLabel=(Pass=2,Style="LabelText")
     WButton=(bIgnoreController=1,OnSelect="OnWButton",Pass=1,Style="PushButtonRounded")
     AButtonIcon=(Pass=2,Style="XboxButtonA")
     ALabel=(Text="Select",Pass=2,Style="LabelText")
     AButton=(bIgnoreController=1,OnSelect="OnAButton",Pass=1,Style="PushButtonRounded")
     APlatform=MWP_Console
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
