/*
	Desc: Can select a weather effect: rain, snow, dust
	xmatt
*/
class MiniedDrawer_WeatherSelect extends ToolMenuBase;

const NUM_PARTICLES = 4;

//Weathers
var String				WeatherIconNames[NUM_PARTICLES];
var String				WeatherSelectedIconNames[NUM_PARTICLES];
var MenuText			Label;
var MenuCheckBoxSprite	Weathers[NUM_PARTICLES];

enum ESoundIndex
{
    SI_Rain,
    SI_Snow,
    SI_Dust,
    SI_NoEffect
};


//Sounds
var Sound				MESound[3];

//For saving gui data
var int					SelectedWeatherIndex;

//Help text
var localized string	HelpText_SelectRain;
var localized string	HelpText_SelectSnow;
var localized string	HelpText_SelectDust;
var localized string	HelpText_SelectNone;
var localized string	HelpText_CloseMenu;


simulated function InitWeathers()
{
	local float spacingY, OffsetY, PosY;
	local int i;
	local Material M;

	spacingY = 0.14;
	OffsetY = 0.4;
	for( i = 0; i < NUM_PARTICLES; i++ )
	{
		PosY = i * spacingY + OffsetY;
		M = Material(DynamicLoadObject( WeatherIconNames[i], class'Material') );
		InitCheckboxButtonSprite( Weathers[i], 0.725, PosY, 0.10, 0.12, M, 'NOTHING' );
		M = Material(DynamicLoadObject( WeatherSelectedIconNames[i], class'Material') );
		Weathers[i].SelectedBlurred.WidgetTexture = M;
		Weathers[i].SelectedFocused.WidgetTexture = M;
	}
}


event AnimatorDone( int Id )
{
	switch( Id )
	{
	case 1:
		CloseMenu();		
		break;
	}
}


simulated function MakePanelPanIn()
{
	local int i;

	MakeTranslator( 0, MD_Left, 0.5, 0.4 );
	
	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	AddToAnimator( Label );
	for( i=0; i < ArrayCount(Weathers); i++ )
		AddToAnimator( Weathers[i] );

	MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
	local int i;

	MakeTranslator( 1, MD_Right, 0.5, 0.4 );

	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	AddToAnimator( Label );
	for( i=0; i < ArrayCount(Weathers); i++ )
		AddToAnimator( Weathers[i] );
}

simulated function RetrieveMenuSavedData()
{
	//Retrieve saved data for this menu
	SelectedWeatherIndex	= Info.FXBrowserData.SelectedWeatherIndex;

	if( SelectedWeatherIndex != -1 )
		SelectWidget( Weathers[SelectedWeatherIndex] );
}


simulated function SaveMenuData()
{
	//Save the up-to-date data for this menu
	Info.FXBrowserData.SelectedWeatherIndex		= SelectedWeatherIndex;
}


simulated function Init( String Args )
{
	Super.Init( Args );

	//Weather
	InitWeathers();

	MakePanelPanIn();
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function SetWeatherEffects( ESoundIndex PlayNow )
{
    if ( SelectedWeatherIndex == PlayNow )
        return;

    StopAmbientSound();

    if( PlayNow < SI_NoEffect )
        PlayAmbientSound( MESound[PlayNow] );

    SelectedWeatherIndex = Playnow;
}


simulated function OnRain()
{
	SetHelpText_A( HelpText_SelectRain );
}


simulated function SelectRain()
{
    SetWeatherEffects( SI_Rain );
	ConsoleCommand( "SET WEATHER INDEX=0" );
    ConsoleCommand( "SET AMBIANTSOUND NAME=" $MESound[0] );
}


simulated function OnSnow()
{
	SetHelpText_A( HelpText_SelectSnow );
}


simulated function SelectSnow()
{
    SetWeatherEffects( SI_Snow );
	ConsoleCommand( "SET WEATHER INDEX=1" );
    ConsoleCommand( "SET AMBIANTSOUND NAME=" $MESound[1] );
}


simulated function OnDust()
{
	SetHelpText_A( HelpText_SelectDust );
}

simulated function SelectDust()
{
    SetWeatherEffects( SI_Dust );
    ConsoleCommand( "SET WEATHER INDEX=2" );
    ConsoleCommand( "SET AMBIANTSOUND NAME=" $MESound[2] );
}


simulated function OnNoEffect()
{
	SetHelpText_A( HelpText_SelectNone );
}


simulated function SelectNoEffect()
{
	ConsoleCommand( "SET WEATHER INDEX=3" );
    ConsoleCommand( "SET AMBIANTSOUND NAME=" );
    SetWeatherEffects( SI_NoEffect );
	SelectedWeatherIndex = 3;
}

defaultproperties
{
     WeatherIconNames(0)="MiniEdTextures.GUI.rain"
     WeatherIconNames(1)="MiniEdTextures.GUI.snow"
     WeatherIconNames(2)="MiniEdTextures.GUI.dust"
     WeatherIconNames(3)="MiniEdTextures.GUI.noeffect"
     WeatherSelectedIconNames(0)="MiniEdTextures.GUI.rainHighlighted"
     WeatherSelectedIconNames(1)="MiniEdTextures.GUI.snowHighlight"
     WeatherSelectedIconNames(2)="MiniEdTextures.GUI.dustHightlight"
     WeatherSelectedIconNames(3)="MiniEdTextures.GUI.noeffect"
     Label=(Text="Select Weather",DrawPivot=DP_MiddleLeft,PosX=0.680000,PosY=0.287500,Pass=3,Style="MiniedDrawerText")
     Weathers(0)=(Group="WEATHER",OnFocus="OnRain",OnSelect="SelectRain")
     Weathers(1)=(Group="WEATHER",OnFocus="OnSnow",OnSelect="SelectSnow")
     Weathers(2)=(Group="WEATHER",OnFocus="OnDust",OnSelect="SelectDust")
     Weathers(3)=(Group="WEATHER",OnFocus="OnNoEffect",OnSelect="SelectNoEffect")
     MESound(0)=Sound'MiniEdSounds.MiniEdAmbientRain'
     MESound(1)=Sound'MiniEdSounds.MiniEdAmbientSnow'
     MESound(2)=Sound'MiniEdSounds.MiniEdAmbientWind'
     HelpText_SelectRain="Select rain"
     HelpText_SelectSnow="Select snow"
     HelpText_SelectDust="Select dust"
     HelpText_SelectNone="No weather"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(ScaleX=0.350000,ScaleY=0.750000)
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
