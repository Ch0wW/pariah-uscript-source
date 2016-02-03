class MiniedYesNoMenu extends MenuTemplate;

var MenuSprite			Panel;
var MenuText			MenuDescription;
var MenuButtonText		ButtonYes;
var MenuButtonText		ButtonNo;

var	MiniEdController	C;

simulated function Init( String Args )
{
	Super.Init( Args );
	
	C = MiniEdController(Owner);
}


simulated function OnYes()
{
	ConsoleCommand( "DESTROYALLMESHES" );
	CloseMenu();
}


simulated function OnCancel()
{
	CloseMenu();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
	if( ButtonName == "B" )
	{
		CloseMenu();
	}
	return Super.HandleInputGamePad(ButtonName);
}


simulated function HandleInputBack()
{
	CloseMenu();
}


simulated function OnBButton()
{
    HandleInputBack();
}

defaultproperties
{
     Panel=(WidgetTexture=Texture'InterfaceContent.Menu.BackFill',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=0.450000,ScaleY=0.330000,ScaleMode=MSM_FitStretch)
     MenuDescription=(DrawPivot=DP_MiddleLeft,PosX=0.350000,PosY=0.450000,ScaleX=0.600000,ScaleY=0.600000,MaxSizeX=0.800000,bWordWrap=1,Style="LabelText")
     ButtonYes=(Blurred=(Text="Yes",PosX=0.425000,PosY=0.550000),BackgroundBlurred=(ScaleX=0.150000),OnSelect="OnYes",Style="PushButtonRounded")
     ButtonNo=(Blurred=(Text="No",PosX=0.575000,PosY=0.550000),BackgroundBlurred=(ScaleX=0.150000),OnSelect="OnCancel",Style="PushButtonRounded")
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
