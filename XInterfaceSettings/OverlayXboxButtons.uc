class OverlayXboxButtons extends MenuBase
    DependsOn(MenuSettingsControlsXbox);

var() MenuSprite    ButtonSprite;

var() MenuText      ButtonLabels[12];

var() MenuText      PovUpLabel;
var() MenuText      PovDownLabel;
var() MenuText      PovLeftLabel;
var() MenuText      PovRightLabel;

simulated function SetConfig( MenuSettingsControlsXbox.ButtonConfig Config )
{
    local int i;
    
    for( i = 0; i < ArrayCount(ButtonLabels); ++i )
    {
        ButtonLabels[i].Text = class'MenuSettingsControlsXbox'.static.GetButtonBind( Config.Buttons[i] );
    }

    PovUpLabel.Text = class'MenuSettingsControlsXbox'.static.GetButtonBind( Config.PovUp );
    PovDownLabel.Text = class'MenuSettingsControlsXbox'.static.GetButtonBind( Config.PovDown );
    PovLeftLabel.Text = class'MenuSettingsControlsXbox'.static.GetButtonBind( Config.PovLeft );
    PovRightLabel.Text = class'MenuSettingsControlsXbox'.static.GetButtonBind( Config.PovRight );
}

defaultproperties
{
     ButtonSprite=(WidgetTexture=Texture'PariahInterface.XboxController.ButtonsOverlay',DrawPivot=DP_MiddleMiddle,PosX=0.499000,PosY=0.613000)
     ButtonLabels(0)=(DrawPivot=DP_MiddleLeft,PosX=0.660000,PosY=0.510000,Style="SmallLabel")
     ButtonLabels(1)=(DrawPivot=DP_MiddleLeft,PosX=0.680000,PosY=0.576000,Style="SmallLabel")
     ButtonLabels(2)=(DrawPivot=DP_MiddleLeft,PosX=0.690000,PosY=0.635000,Style="SmallLabel")
     ButtonLabels(3)=(DrawPivot=DP_MiddleLeft,PosX=0.650000,PosY=0.450000,Style="SmallLabel")
     ButtonLabels(4)=(DrawPivot=DP_MiddleLeft,PosX=0.691000,PosY=0.695000,Style="SmallLabel")
     ButtonLabels(5)=(DrawPivot=DP_MiddleLeft,PosX=0.691000,PosY=0.758000,Style="SmallLabel")
     ButtonLabels(6)=(DrawPivot=DP_MiddleRight,PosX=0.410000,PosY=0.380000,Style="SmallLabel")
     ButtonLabels(7)=(DrawPivot=DP_MiddleLeft,PosX=0.595000,PosY=0.380000,Style="SmallLabel")
     ButtonLabels(8)=(DrawPivot=DP_MiddleRight,PosX=0.308000,PosY=0.634000,Style="SmallLabel")
     ButtonLabels(9)=(DrawPivot=DP_MiddleRight,PosX=0.320000,PosY=0.570000,Style="SmallLabel")
     ButtonLabels(10)=(DrawPivot=DP_MiddleRight,PosX=0.330000,PosY=0.507000,Style="SmallLabel")
     ButtonLabels(11)=(DrawPivot=DP_MiddleLeft,PosX=0.691000,PosY=0.820000,Style="SmallLabel")
     PovUpLabel=(DrawPivot=DP_MiddleRight,PosX=0.307000,PosY=0.697000,Style="SmallLabel")
     PovDownLabel=(DrawPivot=DP_MiddleRight,PosX=0.307000,PosY=0.823000,Style="SmallLabel")
     PovLeftLabel=(DrawPivot=DP_MiddleRight,PosX=0.307000,PosY=0.757000,Style="SmallLabel")
     PovRightLabel=(DrawPivot=DP_MiddleLeft,PosX=0.415000,PosY=0.825000,Style="SmallLabel")
     CrossFadeLevel=0.000000
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
