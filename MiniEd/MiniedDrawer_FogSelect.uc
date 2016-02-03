/*
    Desc: Change the fog color and its intensity
	Each sky will have a fog color associated with it which will mod the color
	The color will automatically change with the SKY selection.
	The slider will be Fog intensity.
	Six fog colors per sky (three for day, three for night)
	(three skies yields 18 combinations)
*/
class MiniedDrawer_FogSelect extends ToolMenuBase
	exportstructs
    native;

const NUM_COLORS            = 3;	
const NUM_COLORS_PER_ROW    = 3;
const SPREAD                = 0.68;
const NEAR_PLANE_MIN		= -120000.0f;
const NEAR_PLANE_MAX		= 30000.0f;
const FAR_PLANE				= 60000.0f;

//Fog colors
var() String                ColorsTexFiles[NUM_COLORS];
var() MenuText              TextFogColors;
var() MenuCheckBoxSprite    FogColors[NUM_COLORS];
var() Color                 ColorValues[NUM_COLORS];
var() Color                 CurrentFogColor;
var() bool                  bFogOn;


//Fog planes
var() MenuSlider            NearFogSlider;
var() MenuSliderArrow       NearFogArrowLeft;
var() MenuSliderArrow       NearFogArrowRight;
var() float					NearPlane;


//For saving gui data
var() int                   SelectedFogColorIndex;

//Help text
var localized string		HelpText_PickFogColor;
var localized string		HelpText_ChangeFogIntensity;
var localized string		HelpText_CloseMenu;


var struct T_ColorVariance 
{
	var int MinR;
	var int MaxR;
	var int MinG;
	var int MaxG;
	var int MinB;
	var int MaxB;
}ColorVariance;



native simulated function GetDefaultFogColor( out vector OutColor );

event AnimatorDone( int Id )
{
    switch( Id )
    {
    case 1:
        CloseMenu();
        break;
    }
}

simulated function Init( String Args )
{
    Super.Init( Args );
	RetrieveMenuSavedData();
    InitColors();
    MakePanelPanIn();
	ChangedColorIntensity();
	FocusOnWidget( FogColors[0] );
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function MakePanelPanIn()
{
	local int i;
    MakeTranslator( 0, MD_Left, 0.5, 0.4 );
    
    //Add the widgets to the animator
	AddToAnimator( TextFogColors );
    for( i=0; i < ArrayCount(FogColors); i++ )
        AddToAnimator( FogColors[i] );
    AddToAnimator( DrawerBackground );
    AddToAnimator( NearFogSlider );
    AddToAnimator( NearFogArrowLeft );
    AddToAnimator( NearFogArrowRight );
    MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
    local int i;
	MakeTranslator( 1, MD_Right, 0.5, 0.4 );
	
    //Add the widgets to the animator
	AddToAnimator( TextFogColors );
    for( i=0; i < ArrayCount(FogColors); i++ )
        AddToAnimator( FogColors[i] );
    AddToAnimator( DrawerBackground );
    AddToAnimator( NearFogSlider );
    AddToAnimator( NearFogArrowLeft );
    AddToAnimator( NearFogArrowRight );
}

simulated function RetrieveMenuSavedData()
{
    //Retrieve saved data for this menu
	//Save the actual value so that it can be used by the game.  Slider value goes from 0-100.
    NearPlane = Info.FXBrowserData.NearFogSliderValue;
	NearFogSlider.Value = 100.0 * ( 1 - ( Info.FXBrowserData.NearFogSliderValue - NEAR_PLANE_MIN )/( NEAR_PLANE_MAX - NEAR_PLANE_MIN ));
	SelectedFogColorIndex = Info.FXBrowserData.SelectedColorIndex;
}


simulated function SaveMenuData()
{
    //Save the up-to-date data for this menu
    Info.FXBrowserData.SelectedColorIndex = SelectedFogColorIndex;
}


simulated function InitColors()
{
    local float spacingX, spacingY, OffsetY, PosX, PosY;
    local int i;
    local Material M;
	local Color SelectedFogColor;
	
    spacingX = 0.067;
    spacingY = 0.082;
    OffsetY = 0.38;

	for( i = 0; i < NUM_COLORS; i++ )
	{
		PosX = 0.6 + ((i%NUM_COLORS_PER_ROW)+1) * spacingX;
		PosY = (i/NUM_COLORS_PER_ROW) * spacingY + OffsetY;
		M = Material(DynamicLoadObject( ColorsTexFiles[i], class'Material') );
		InitCheckboxButtonSprite( FogColors[i], PosX, PosY, 0.06, 0.08, M, 'COLOR' );
		
		
		if ( Info.IsDay )
			SelectedFogColor = Info.SkiesRecords[Info.FXBrowserDataTwo.SkyButtonSelected].DayFogColors[i];
		else
			SelectedFogColor = Info.SkiesRecords[Info.FXBrowserDataTwo.SkyButtonSelected].NightFogColors[i];
	
		FogColors[i].Blurred.DrawColor = SelectedFogColor;
		FogColors[i].Blurred.DrawColor.A = 255;
		FogColors[i].Focused.DrawColor = SelectedFogColor;
		FogColors[i].Focused.DrawColor.A = 255;
		FogColors[i].SelectedBlurred.DrawColor = SelectedFogColor;
		FogColors[i].SelectedBlurred.DrawColor.A = 255;
		FogColors[i].SelectedFocused.DrawColor = SelectedFogColor;
		FogColors[i].SelectedFocused.DrawColor.A = 255;
		FogColors[i].OnFocus = 'OnFogColor';
	}
}

simulated function OnFogColor()
{
	SetHelpText_A( HelpText_PickFogColor );
}


simulated function OnNearFog()
{
	SetHelpText_DPAD( HelpText_ChangeFogIntensity );
}


simulated function ChangedNearSlider()
{
	//Distance in front of the camera that fog becomes visible
    NearPlane = lerp( 1.0f - NearFogSlider.Value / 100.0f, NEAR_PLANE_MIN, NEAR_PLANE_MAX, true );
	Info.FXBrowserData.NearFogSliderValue = NearPlane;
    ConsoleCommand( "SETFOG NEARPLANE " $ NearPlane );
    ConsoleCommand( "SETFOG FARPLANE " $ FAR_PLANE );
}


simulated function ChangedColorIntensity()
{
	local int i,j;
	i = Info.FXBrowserDataTwo.SkyButtonSelected;
	j = SelectedFogColorIndex;
	if ( Info.IsDay )
		ConsoleCommand( "SETFOG COLOR R=" $ Info.SkiesRecords[i].DayFogColors[j].R $ " G=" $ Info.SkiesRecords[i].DayFogColors[j].G $ " B=" $ Info.SkiesRecords[i].DayFogColors[j].B );
	else
		ConsoleCommand( "SETFOG COLOR R=" $ Info.SkiesRecords[i].NightFogColors[j].R $ " G=" $ Info.SkiesRecords[i].NightFogColors[j].G $ " B=" $ Info.SkiesRecords[i].NightFogColors[j].B );
}

simulated function OnARelease()
{
    Super.OnARelease();
    SaveMenuData();
}

simulated function SelectedFogColor0()
{
	SelectedFogColorIndex = 0;
	ChangedColorIntensity();
}


simulated function SelectedFogColor1()
{
	SelectedFogColorIndex = 1;
	ChangedColorIntensity();
}


simulated function SelectedFogColor2()
{
	SelectedFogColorIndex = 2;
	ChangedColorIntensity();
}

defaultproperties
{
     ColorsTexFiles(0)="MiniEdTextures.GUI.PureWhite"
     ColorsTexFiles(1)="MiniEdTextures.GUI.PureWhite"
     ColorsTexFiles(2)="MiniEdTextures.GUI.PureWhite"
     TextFogColors=(Text="Select Fog Color",DrawPivot=DP_MiddleLeft,PosX=0.640000,PosY=0.300000,Style="MiniedDrawerText")
     FogColors(0)=(OnSelect="SelectedFogColor0")
     FogColors(1)=(OnSelect="SelectedFogColor1")
     FogColors(2)=(OnSelect="SelectedFogColor2")
     CurrentFogColor=(B=255,G=255,R=255)
     NearFogSlider=(Value=100.000000,OnSlide="ChangedNearSlider",Blurred=(Text="Fog Intensity",PosX=0.640000,PosY=0.535000,Style="MiniedDrawerText"),OnFocus="OnNearFog",Style="MiniEdSlider")
     NearFogArrowLeft=(WidgetName="NearFogSlider",Blurred=(PosX=0.650000,PosY=0.583000),Style="MiniEdSliderLeft")
     NearFogArrowRight=(WidgetName="NearFogSlider",Blurred=(PosX=0.910000,PosY=0.583000),Style="MiniEdSliderRight")
     SelectedFogColorIndex=-1
     HelpText_PickFogColor="Pick this fog color"
     HelpText_ChangeFogIntensity="Vary fog intensity"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(PosY=0.250000,ScaleX=0.400000,ScaleY=0.400000)
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
