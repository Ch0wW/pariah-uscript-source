class MenuTemplateTitledB extends MenuTemplateTitled
    native;

var() MenuSprite            BButtonIcon;
var() MenuText              BLabel;
var() MenuButtonText        BButton;

var() EMenuWidgetPlatform   BPlatform;
var() int                   BButtonHidden;

simulated function OnBButton()
{
    HandleInputBack();
}

simulated function HideBButton(int hide)
{
    BButtonHidden = hide;
    bDynamicLayoutDirty = true;
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function SetButtonBarOpacity( float Opacity )
{
    BButtonIcon.DrawColor.A = 255 * Opacity;
    BLabel.DrawColor.A = 255 * Opacity;
    BButton.Blurred.DrawColor.A = 255 * Opacity;
    BButton.Focused.DrawColor.A = 255 * Opacity;
    BButton.BackgroundFocused.DrawColor.A = 255 * Opacity;
    BButton.BackgroundBlurred.DrawColor.A = 255 * Opacity;
    
    Super.SetButtonBarOpacity( Opacity );
}

simulated function PackButtonBar( Canvas C, float PivotX )
{
    local float UpdatedPivotX;
    
    UpdatedPivotX = PivotX;
    
    PackButton( C, BButtonIcon, BLabel, BButton, BPlatform, BButtonHidden, UpdatedPivotX );

    Super.PackButtonBar( C, UpdatedPivotX );
}

simulated event DoDynamicLayout( Canvas C )
{
    PackButtonBar( C, ButtonBarPivotX );
}

defaultproperties
{
     BButtonIcon=(Pass=2,Style="XboxButtonB")
     BLabel=(Text="Back",Pass=2,Style="LabelText")
     BButton=(bIgnoreController=1,OnSelect="OnBButton",Pass=1,Style="PushButtonRounded")
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
