/*
	Desc: sky selection menu
*/
class MiniedDrawer_SkySelect extends ToolMenuBase;


const NUM_SKIES_PACKAGE = 3;

//Sky
var MenuText			TextChangeSky;
var MenuCheckBoxSprite	SkyButtons[NUM_SKIES_PACKAGE];

//For saving gui data
var int					SkyButtonSelected;

//Help text
var localized string	HelpText_SelectSky;
var localized string	HelpText_CloseMenu;

simulated function InitSkiesButtons()
{
	local array<String> SkyTexNames;
	local Material M;
	
	//If it is the day
	if( Info.IsDay )
	{
		SkyTexNames[0] = Info.SkiesRecords[0].DayVersionThumbName;
		SkyTexNames[1] = Info.SkiesRecords[1].DayVersionThumbName;
		SkyTexNames[2] = Info.SkiesRecords[2].DayVersionThumbName;
	}
	//If it is the night
	else
	{
		SkyTexNames[0] = Info.SkiesRecords[0].NightVersionThumbName;
		SkyTexNames[1] = Info.SkiesRecords[1].NightVersionThumbName;
		SkyTexNames[2] = Info.SkiesRecords[2].NightVersionThumbName;
	}
	
	M = Material( DynamicLoadObject(SkyTexNames[0],class'Material' ) );
	InitCheckboxButtonSprite( SkyButtons[0], 0.77, 0.35, 0.16, 0.20, M, 'SKIES' );
	M = Material( DynamicLoadObject(SkyTexNames[1],class'Material') );
	InitCheckboxButtonSprite( SkyButtons[1], 0.77, 0.55, 0.16, 0.20, M, 'SKIES' );
	M = Material( DynamicLoadObject(SkyTexNames[2],class'Material') );
	InitCheckboxButtonSprite( SkyButtons[2], 0.77, 0.75, 0.16, 0.20, M, 'SKIES' );
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
	AddToAnimator( TextChangeSky );
	for( i=0; i < ArrayCount(SkyButtons); i++ )
		AddToAnimator( SkyButtons[i] );

	MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
	local int i;

	MakeTranslator( 1, MD_Right, 0.5, 0.4 );

	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	AddToAnimator( TextChangeSky );
	for( i=0; i < ArrayCount(SkyButtons); i++ )
		AddToAnimator( SkyButtons[i] );
}


simulated function RetrieveMenuSavedData()
{
	//Retrieve saved data for this menu
	SkyButtonSelected	= Info.FXBrowserDataTwo.SkyButtonSelected;

	if( SkyButtonSelected != -1 )
		SelectWidget( SkyButtons[SkyButtonSelected] );
}


simulated function SaveMenuData()
{
	//Save the up-to-date data for this menu
	Info.FXBrowserDataTwo.SkyButtonSelected = SkyButtonSelected;
}


simulated function Init( String Args )
{
	Super.Init( Args );
	InitSkiesButtons();
	MakePanelPanIn();
	FocusOnWidget( SkyButtons[0] );
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function OnARelease()
{
	local int i;
	
	//See if a gui from the skies buttons got pressed
	for( i = 0; i < NUM_SKIES_PACKAGE; i++ )
	{
		if( SkyButtons[i].bHasFocus != 0 )
		{
			SkyButtonSelected = i;
			if( Info.IsDay )
				ConsoleCommand( "SKY TEXTURE " $ Info.SkiesRecords[i].DayVersionName );
			else
				ConsoleCommand( "SKY TEXTURE " $ Info.SkiesRecords[i].NightVersionName );
		}
	}
	AutoUpdateFogSettings();
}

simulated function AutoUpdateFogSettings()
{
	// only updating the color - intensity is changed from Fog menu
	local int i,j;
	i = SkyButtonSelected;
	j = Info.FXBrowserData.SelectedColorIndex;
	if ( Info.IsDay )
		ConsoleCommand( "SETFOG COLOR R=" $ Info.SkiesRecords[i].DayFogColors[j].R $ " G=" $ Info.SkiesRecords[i].DayFogColors[j].G $ " B=" $ Info.SkiesRecords[i].DayFogColors[j].B );
	else
		ConsoleCommand( "SETFOG COLOR R=" $ Info.SkiesRecords[i].NightFogColors[j].R $ " G=" $ Info.SkiesRecords[i].NightFogColors[j].G $ " B=" $ Info.SkiesRecords[i].NightFogColors[j].B );
}

simulated function OnSky()
{
	SetHelpText_A( HelpText_SelectSky );
}

defaultproperties
{
     TextChangeSky=(Text="Select Sky",DrawPivot=DP_MiddleLeft,PosX=0.695000,PosY=0.230000,Style="MiniedDrawerText")
     SkyButtons(0)=(OnFocus="OnSky")
     SkyButtons(1)=(OnFocus="OnSky")
     SkyButtons(2)=(OnFocus="OnSky")
     HelpText_SelectSky="Select this sky"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(ScaleX=0.350000,ScaleY=0.680000)
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
