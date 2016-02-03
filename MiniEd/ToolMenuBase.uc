/*
	ToolMenuBase
	Desc: 
		- Common things that get done for tool menus accessible from the MiniEditor menu
*/
class ToolMenuBase extends MenuTemplate
	native;

var	MiniEdController	C;
var MiniEdInfo			Info;

var	MenuSprite			DrawerBackground;

// Sounds
var Sound				SOpenMenu;
var Sound				SCloseMenu;

//Uses the static mesh bounding box to return the largest dimension out of width, height and depth
//Used to normalize the size of static mesh
native simulated function float GetLargestDim( StaticMesh s );
native simulated function float GetHeight( StaticMesh s );

native simulated function SetHelpText_A( String AButtonText );
native simulated function SetHelpText_B( String BButtonText );
native simulated function SetHelpText_DPAD( String DPADButtonText );

simulated function MakePanelPanIn();
simulated function MakePanelPanOut();


simulated function OnARelease()
{
	Super.HandleInputSelect(); //So that a focused widget can be selected
}


simulated function OnBRelease()
{
	MakePanelPanOut();
}


simulated function OnXRelease();
simulated function OnYRelease();
simulated function OnLTRelease();
simulated function OnRTRelease();
simulated function OnWhiteRelease();

simulated function RetrieveMenuSavedData();
simulated function SaveMenuData();

simulated function Init( String Args )
{
	Super.Init( Args );

	Info = MiniEdInfo(Level.Game);
	RetrieveMenuSavedData();
	
	assert( Owner != None );
	C = MiniEdController(Owner);
    assert( C != None );

	PlaySound( SOpenMenu, SLOT_Pain );
}


simulated function HandleInputSelect()
{
	OnARelease(); //causes double clicks
}


simulated function HandleInputMouseDown()
{
    Super.HandleInputMouseDown();
    OnARelease();
}


simulated function HandleInputBack()
{
	OnBRelease();
}


simulated function CloseMenu()
{
	Super.CloseMenu();
	PlaySound( SCloseMenu, SLOT_Pain );
	SaveMenuData();
}


//Handle button releases for the gamepad
simulated function bool HandleInputGamePad( String ButtonName )
{	
	// B
	if( ButtonName == "B" )
	{
		OnBRelease();
	}
	// X
	else if( ButtonName == "X" )
	{
		OnXRelease();
	}
	// Y
	else if( ButtonName == "Y" )
	{
		OnYRelease();
	}
	// White
	else if( ButtonName == "W" )
	{
		OnWhiteRelease();
	}
	// Left trigger
	else if( ButtonName == "LT" )
	{
		OnLTRelease();
	}
	// Right trigger
	else if( ButtonName == "RT" )
	{
		OnRTRelease();
	}
	return Super.HandleInputGamePad(ButtonName);
}


//Handle button releases for the PC
exec function CheckCollision( String cmd )
{
	ConsoleCommand( "CHECKCOLLISION" );
}


exec function ReleasedA( String cmd )
{
	OnARelease();
}


exec function ReleasedB( String cmd )
{
	OnBRelease();
}


exec function ReleasedX( String cmd )
{
	OnXRelease();
}


exec function ReleasedY( String cmd )
{
	OnYRelease();
}


exec function ReleasedWhite( String cmd )
{
	OnWhiteRelease();
}


exec function ReleasedLT( String cmd )
{
	OnLTRelease();
}


exec function ReleasedRT( String cmd )
{
	OnRTRelease();
}


exec function Released( String cmd )
{
	OnARelease();
}


// change the default HelpIcon.WidgetTexture to the DPad texture Brian will make

defaultproperties
{
     DrawerBackground=(WidgetTexture=Texture'InterfaceContent.Menu.BackFill',RenderStyle=STY_Alpha,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.200000,ScaleX=0.200000,ScaleY=0.200000,ScaleMode=MSM_FitStretch)
     SOpenMenu=Sound'MiniEdSounds.MiniEdDrawerOpen'
     SCloseMenu=Sound'MiniEdSounds.MiniEdDrawerClose'
     SoundTweenOut=None
     SoundOnFocus=None
     SoundOnSelect=None
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
