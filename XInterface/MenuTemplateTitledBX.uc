class MenuTemplateTitledBX extends MenuTemplateTitledB
    native;

var() MenuSprite            XButtonIcon;
var() MenuText              XLabel;
var() MenuButtonText        XButton;

var() EMenuWidgetPlatform   XPlatform;
var() int                   XButtonHidden;

simulated function OnXButton();

simulated function HideXButton(int hide)
{
    XButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "X" )
    {
        OnXButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function SetButtonBarOpacity( float Opacity )
{
    XButtonIcon.DrawColor.A = 255 * Opacity;
    XLabel.DrawColor.A = 255 * Opacity;
    XButton.Blurred.DrawColor.A = 255 * Opacity;
    XButton.Focused.DrawColor.A = 255 * Opacity;
    XButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    XButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;
     
    Super.SetButtonBarOpacity( Opacity );
}

simulated function PackButtonBar( Canvas C, float PivotX )
{
    local float UpdatedPivotX;
    
    UpdatedPivotX = PivotX;
    
    PackButton( C, XButtonIcon, XLabel, XButton, XPlatform, XButtonHidden, UpdatedPivotX );

    Super.PackButtonBar( C, UpdatedPivotX );
}

simulated event DoDynamicLayout( Canvas C )
{
    PackButtonBar( C, ButtonBarPivotX );
}

defaultproperties
{
     XButtonIcon=(Pass=2,Style="XboxButtonX")
     XLabel=(Text="Options",Pass=2,Style="LabelText")
     XButton=(bIgnoreController=1,OnSelect="OnXButton",Pass=1,Style="PushButtonRounded")
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
