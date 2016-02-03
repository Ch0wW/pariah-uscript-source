class MenuTemplateTitledBA extends MenuTemplateTitledB
    native;

var() MenuSprite            AButtonIcon;
var() MenuText              ALabel;
var() MenuButtonText        AButton;

var() EMenuWidgetPlatform   APlatform;
var() int                   AButtonHidden;

simulated function OnAButton();

simulated function HideAButton(int hide)
{
    AButtonHidden = hide;
    bDynamicLayoutDirty = true;
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
    
    Super.SetButtonBarOpacity( Opacity );
}

simulated function PackButtonBar( Canvas C, float PivotX )
{
    local float UpdatedPivotX;
    
    UpdatedPivotX = PivotX;
    
    PackButton( C, AButtonIcon, ALabel, AButton, APlatform, AButtonHidden, UpdatedPivotX );

    Super.PackButtonBar( C, UpdatedPivotX );
}

simulated event DoDynamicLayout( Canvas C )
{
    PackButtonBar( C, ButtonBarPivotX );
}

defaultproperties
{
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
