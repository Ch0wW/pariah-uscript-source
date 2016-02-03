/*
    LightingMenu
    Desc: 
        - camera speed
    xmatt
*/
class LightingMenu extends ToolMenuBase;


const NUM_COLORS            = 3;

//Light colors
var() MenuText              TextColors;
var() MenuCheckBoxSprite    Colors[NUM_COLORS];
var() INT					CurrentLightColor;
var Material				PureWhite;
var Material				DaySelected;
var Material				NightSelected;

//Brightness control
var() MenuSlider            BrightnessSlider;
var() MenuSliderArrow       BrightnessArrowLeft;
var() MenuSliderArrow       BrightnessArrowRight;

//Night-Day choice
var() MenuText              TextTime;
var() MenuCheckBoxSprite    TimeOfDay[2];
var() string                NightAndDayTexFiles[2];

//For saving gui data
var() int                   LightColorSelected;
var() int                   BrightnessSliderValue;

//Help text
var localized String		HelpText_OnLightColor;
var localized String		HelpText_OnBrightnessSlider;
var localized String		HelpText_OnDay;
var localized String		HelpText_OnNight;
var localized string HelpText_CloseMenu;

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
    InitTimeOfDay();
	MakePanelPanIn();

	FocusOnWidget( Colors[0] );
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function MakePanelPanIn()
{
    local int i;

    MakeTranslator( 0, MD_Left, 0.5, 0.4 );
    
    //Add the widgets to the animator
    AddToAnimator( DrawerBackground );
    AddToAnimator( TextColors );
    for( i=0; i < ArrayCount(Colors); i++ )
        AddToAnimator( Colors[i] );
    AddToAnimator( BrightnessSlider );
    AddToAnimator( BrightnessArrowLeft );
    AddToAnimator( BrightnessArrowRight );
    AddToAnimator( TextTime );
    for( i=0; i < ArrayCount(TimeOfDay); i++ )
        AddToAnimator( TimeOfDay[i] );

    MoveAnimatedDir( MD_Right, 0.4 );
    
}


simulated function RetrieveMenuSavedData()
{
    //Retrieve saved data for this menu
    LightColorSelected  = Info.LightingData.LightColorSelected;
    BrightnessSliderValue  = Info.LightingData.BrightnessSliderValue;
    BrightnessSlider.Value = BrightnessSliderValue;

	UpdateSliderRange();
    
    if ( Info.isDay )
        SelectWidget( TimeOfDay[0] );
	else
		SelectWidget( TimeOfDay[1] );	

	SelectWidget( Colors[LightColorSelected] );
}


simulated function SaveMenuData()
{
    //Save the up-to-date data for this menu
    Info.LightingData.LightColorSelected            = LightColorSelected;
    Info.LightingData.BrightnessSliderValue		    = BrightnessSlider.Value;
}


simulated function MakePanelPanOut()
{
    local int i;

    MakeTranslator( 1, MD_Right, 0.5, 0.4 );

    //Add the widgets to the animator
    AddToAnimator( DrawerBackground );
    AddToAnimator( TextColors );
    for( i=0; i < ArrayCount(Colors); i++ )
        AddToAnimator( Colors[i] );
    AddToAnimator( BrightnessSlider );
    AddToAnimator( BrightnessArrowLeft );
    AddToAnimator( BrightnessArrowRight );
    AddToAnimator( TextTime );
    for( i=0; i < ArrayCount(TimeOfDay); i++ )
        AddToAnimator( TimeOfDay[i] );
    SaveMenuData();
}


simulated function InitColors()
{
    local float spacingX, spacingY, PosX;
    local int i;

    spacingX = 0.067;
    spacingY = 0.082;

    for( i = 0; i < NUM_COLORS; i++ )
    {
        PosX = 0.6 + (i+1) * spacingX;
		InitCheckboxButtonSprite( Colors[i], PosX, 0.37, 0.06, 0.08, PureWhite, 'LIGHTCOLORS' );
		Colors[i].Blurred.DrawColor = Info.LightRGBColors[i];
		Colors[i].Blurred.DrawColor.A = 255;
		Colors[i].Focused.DrawColor = Info.LightRGBColors[i];
		Colors[i].Focused.DrawColor.A = 255;
		Colors[i].SelectedBlurred.DrawColor = Info.LightRGBColors[i];
		Colors[i].SelectedBlurred.DrawColor.A = 255;
		Colors[i].SelectedFocused.DrawColor = Info.LightRGBColors[i];
		Colors[i].SelectedFocused.DrawColor.A = 255;
		Colors[i].OnFocus = 'OnColor';
    }
}


simulated function InitTimeOfDay()
{
    local Material M;
	M = Material(DynamicLoadObject( NightAndDayTexFiles[0], class'Material') );
	InitCheckboxButtonSprite( TimeOfDay[0], 0.675, 0.68, 0.08, 0.1, M, 'TIME' );
	TimeOfDay[0].SelectedBlurred.WidgetTexture = DaySelected;
	TimeOfDay[0].SelectedFocused.WidgetTexture = DaySelected;

	M = Material(DynamicLoadObject( NightAndDayTexFiles[1], class'Material') );
	InitCheckboxButtonSprite( TimeOfDay[1], 0.77, 0.68, 0.08, 0.1, M, 'TIME' );
	TimeOfDay[1].SelectedBlurred.WidgetTexture = NightSelected;
	TimeOfDay[1].SelectedFocused.WidgetTexture = NightSelected;
}


simulated function OnColor()
{
	SetHelpText_A( HelpText_OnLightColor );
}


simulated function SelectedColor0()
{
	ConsoleCommand( "SETLIGHT COLOR VALUE=0" );
	LightColorSelected = 0;
}


simulated function SelectedColor1()
{
	ConsoleCommand( "SETLIGHT COLOR VALUE=1" );
	LightColorSelected = 1;
}


simulated function SelectedColor2()
{
	ConsoleCommand( "SETLIGHT COLOR VALUE=2" );
	LightColorSelected = 2;
}


simulated function OnARelease()
{
    Super.OnARelease();
}


simulated function OnBrightnessSlider()
{
	SetHelpText_DPAD( HelpText_OnBrightnessSlider );
}


simulated function UpdateBrightness()
{
    ConsoleCommand( "SETLIGHT INTENSITY VALUE=" $ BrightnessSlider.Value );
}


simulated function OnDay()
{
	SetHelpText_A( HelpText_OnDay );
}


simulated function SelectedDay()
{
    if( Info.IsDay )
        return;

    Info.IsDay = true;
	BrightnessSlider.Value = Info.GetDayDefaultBrightness();
	UpdateSliderRange();
	UpdateBrightness();

    ConsoleCommand( "SET TIME DAY" );

    //Change the sky texture 
    ConsoleCommand( "SKY TEXTURE " $ Info.SkiesRecords[Info.FXBrowserDataTwo.SkyButtonSelected].DayVersionName );
}


simulated function OnNight()
{
	SetHelpText_A( HelpText_OnNight );
}


simulated function SelectedNight()
{
    if( !Info.IsDay )
        return;

    Info.IsDay = false;

	BrightnessSlider.Value = Info.GetNightDefaultBrightness();
	UpdateSliderRange();
    UpdateBrightness();
    ConsoleCommand( "SET TIME NIGHT" );

    //Change the sky texture
    ConsoleCommand( "SKY TEXTURE " $ Info.SkiesRecords[Info.FXBrowserDataTwo.SkyButtonSelected].NightVersionName );
}


simulated function UpdateSliderRange()
{
	if( Info.IsDay )
	{
		BrightnessSlider.MinValue = 130;
		BrightnessSlider.MaxValue = 210;
	}
	else
	{
		BrightnessSlider.MinValue = 70;
		BrightnessSlider.MaxValue = 130;
	}
}

defaultproperties
{
     TextColors=(Text="Select Light Color",PosX=0.640000,PosY=0.300000,Style="MiniEdLabel")
     Colors(0)=(OnSelect="SelectedColor0")
     Colors(1)=(OnSelect="SelectedColor1")
     Colors(2)=(OnSelect="SelectedColor2")
     PureWhite=Texture'MiniEdTextures.GUI.PureWhite'
     DaySelected=Texture'MiniEdTextures.GUI.DayHighlight'
     NightSelected=Texture'MiniEdTextures.GUI.NightHighllight'
     BrightnessSlider=(MinValue=130.000000,MaxValue=210.000000,Delta=10.000000,OnSlide="UpdateBrightness",Blurred=(Text="Brightness",PosX=0.640000,PosY=0.450000),OnFocus="OnBrightnessSlider",Style="MiniEdSlider")
     BrightnessArrowLeft=(WidgetName="BrightnessSlider",Blurred=(PosX=0.650000,PosY=0.498000),Style="MiniEdSliderLeft")
     BrightnessArrowRight=(WidgetName="BrightnessSlider",Blurred=(PosX=0.910000,PosY=0.498000),Style="MiniEdSliderRight")
     TextTime=(MenuFont=Font'Engine.FontSmall',Text="Select Night / Day",DrawPivot=DP_MiddleLeft,PosX=0.640000,PosY=0.600000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     TimeOfDay(0)=(Group="TIMES",OnFocus="OnDay",OnSelect="SelectedDay")
     TimeOfDay(1)=(Group="TIMES",OnFocus="OnNight",OnSelect="SelectedNight")
     NightAndDayTexFiles(0)="MiniEdTextures.GUI.day"
     NightAndDayTexFiles(1)="MiniEdTextures.GUI.night"
     HelpText_OnLightColor="Select this light color"
     HelpText_OnBrightnessSlider="Vary light brightness"
     HelpText_OnDay="Set to day conditions"
     HelpText_OnNight="Set to night conditions"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(PosY=0.250000,ScaleX=0.400000,ScaleY=0.500000)
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
