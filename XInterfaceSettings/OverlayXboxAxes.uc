class OverlayXboxAxes extends MenuBase
    DependsOn(MenuSettingsControlsXbox);

var() MenuSprite    AxesSprite;

var() MenuText      JoyXLabel;
var() MenuText      JoyYLabel;
var() MenuText      JoyULabel;
var() MenuText      JoyVLabel;

simulated function SetConfig( MenuSettingsControlsXbox.AxesConfig Config )
{
    JoyXLabel.Text = class'MenuSettingsControlsXbox'.static.GetAxisBind( Config.JoyX );
    JoyYLabel.Text = class'MenuSettingsControlsXbox'.static.GetAxisBind( Config.JoyY );
    JoyULabel.Text = class'MenuSettingsControlsXbox'.static.GetAxisBind( Config.JoyU );
    JoyVLabel.Text = class'MenuSettingsControlsXbox'.static.GetAxisBind( Config.JoyV );
}

defaultproperties
{
     AxesSprite=(WidgetTexture=Texture'PariahInterface.XboxController.StickOverlay',DrawPivot=DP_MiddleMiddle,PosX=0.499000,PosY=0.613000)
     JoyXLabel=(DrawPivot=DP_MiddleMiddle,PosX=0.140000,PosY=0.580000,MaxSizeX=0.200000,bWordWrap=1,TextAlign=TA_Center,Style="SmallLabel")
     JoyYLabel=(DrawPivot=DP_MiddleRight,PosX=0.480000,PosY=0.440000,Style="SmallLabel")
     JoyULabel=(DrawPivot=DP_MiddleLeft,PosX=0.700000,PosY=0.630000,MaxSizeX=0.250000,bWordWrap=1,TextAlign=TA_Center,Style="SmallLabel")
     JoyVLabel=(DrawPivot=DP_MiddleLeft,PosX=0.510000,PosY=0.440000,Style="SmallLabel")
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
