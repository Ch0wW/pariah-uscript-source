class OverlaySoakMode extends MenuTemplate;

var() MenuSprite Logo;
var() MenuText DontTouch;

simulated function Init( String Args )
{
    Super.Init( Args );
}

defaultproperties
{
     Logo=(WidgetTexture=FinalBlend'InterfaceContent.Logos.Logo',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.210000,ScaleX=1.000000,ScaleY=1.000000)
     DontTouch=(MenuFont=Font'Engine.FontMedium',Text="SOAK TEST IN PROGRESS...DON'T TOUCH!",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.890000)
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
     bRenderLevel=True
}
