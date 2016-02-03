class MenuSelectGameTypeEx extends MenuSelectGameType;

// Same as MenuSelectGameType but includes All option -- and has new layout.

var() MenuText          AllTitle;
var() MenuButtonText    AllGameTypes;

var() WidgetLayout      NormalGametypesLayout;
var() WidgetLayout      CustomGametypesLayout;

var() float             TitleOffsetX;
var() float             TitleOffsetY;

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );

    LayoutArray( NormalGameTypes[0], 'NormalGametypesLayout' );
    LayoutArray( CustomGameTypes[0], 'CustomGametypesLayout' );

    NormalTitle.PosX = NormalGameTypes[0].Blurred.PosX + TitleOffsetX;
    NormalTitle.PosY = NormalGameTypes[0].Blurred.PosY + TitleOffsetY;

    CustomTitle.PosX = CustomGameTypes[0].Blurred.PosX + TitleOffsetX;
    CustomTitle.PosY = CustomGameTypes[0].Blurred.PosY + TitleOffsetY;

    AllTitle.PosX = AllGameTypes.Blurred.PosX + TitleOffsetX;
    AllTitle.PosY = AllGameTypes.Blurred.PosY + TitleOffsetY;
}

simulated function OnSelectAll()
{
	GameTypeName = "All";
	SaveConfig();
    GotoNextMenu();
}

defaultproperties
{
     AllTitle=(Text="All Gametypes",DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.700000,ScaleY=0.700000,Pass=2,Style="TitleText")
     AllGameTypes=(Blurred=(Text="All",PosX=0.100000,PosY=0.300000),OnFocus="ShowGameTypeDetails",OnSelect="OnSelectAll",Style="TitledTextOption")
     NormalGametypesLayout=(PosX=0.100000,PosY=0.450000,SpacingY=0.050000)
     CustomGametypesLayout=(PosX=0.540000,PosY=0.450000,SpacingY=0.050000)
     TitleOffsetX=-0.040000
     TitleOffsetY=-0.060000
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
