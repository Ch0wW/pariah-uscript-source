/*
	Desc: Ambiant sound selection
	xmatt
*/
class MiniedDrawer_SoundSelect extends ToolMenuBase;


const NUM_SOUNDS = 4;

//Sounds
var MenuText			Label;
var MenuStringList		SoundsList;
//var localized String	L_SoundNames[4]; //kev: use localize() instead

//Scrolling window containing saved maps
var() MenuSprite		BorderBox;
var() MenuSprite		ScrollBorder;		//The area that is behind the scrolling part
var() MenuScrollBar		ScrollBar;			//the purple flashing thing on the scrolling part
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuScrollArea	ScrollArea;
var() MenuActiveWidget	PageUpArea, PageDownArea;

//For saving gui data
var int					SoundSelectedIndex;

//Help text
var localized string	HelpText_SelectSound;
var localized string	HelpText_CloseMenu;

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
	MakeTranslator( 0, MD_Left, 0.5, 0.4 );
	
	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	AddToAnimator( SoundsList );

	MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
	MakeTranslator( 1, MD_Right, 0.5, 0.4 );

	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	AddToAnimator( Label );
	AddToAnimator( SoundsList );
}


simulated function RetrieveMenuSavedData()
{
	//Retrieve saved data for this menu
	SoundSelectedIndex	= Info.FXBrowserDataTwo.SoundSelectedIndex;
}


simulated function SaveMenuData()
{
	//Save the up-to-date data for this menu
	Info.FXBrowserDataTwo.SoundSelectedIndex = SoundSelectedIndex;
}


simulated function Init( String Args )
{
	Super.Init( Args );

	InitSoundList();
	MakePanelPanIn();
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function OnARelease()
{
	local int i;

	//See if a gui from the sound list got pressed
	for( i = 0; i < NUM_SOUNDS; i++ )
	{
		if( SoundsList.Items[i].bHasFocus != 0 )
		{
			SoundSelectedIndex = i;
			PlayMenuSound( Sound(DynamicLoadObject(Info.SoundFileNames[i], class'Sound')) );
			ConsoleCommand("SET AMBIANTSOUND NAME="$Info.SoundFileNames[i]);
		}
	}
}


simulated function UpdateSoundPlaying()
{
	local int i;

	//See if a gui from the sound list got pressed
	for( i = 0; i < NUM_SOUNDS; i++ )
	{
		if( SoundsList.Items[i].bHasFocus != 0 )
		{
			PlayMenuSound( Sound(DynamicLoadObject(Info.SoundFileNames[i], class'Sound')) );
		}
	}
}


simulated function InitSoundList()
{
	local int i;
	local int Last;
	
	//Setup the gui list
	for( i = 0; i < Info.SoundNames.Length; i++ )
	{
		Last = SoundsList.Items.Length;
		SoundsList.Items[ Last ].Blurred.Text = Caps( Info.SoundNames[i] );
		SoundsList.Items[ Last ].Focused.Text = SoundsList.Items[ Last ].Blurred.Text;
		SoundsList.Items[ Last ].OnFocus = 'UpdateSoundPlaying';
	}
	SoundsList.DisplayCount = SoundsList.Items.Length;
	LayoutMenuStringList( SoundsList );
	UpdateScrollBars();
	FocusOnMap(0);
	ScrollListTo(0);
	SetHelpText_A( HelpText_SelectSound );
}


simulated function UpdateScrollBars()
{
    ScrollBar.Position = SoundsList.Position;
    ScrollBar.Length = SoundsList.Items.Length;
    ScrollBar.DisplayCount = SoundsList.DisplayCount;
    
    LayoutMenuScrollBar( ScrollBar );
}


simulated function FocusOnMap( int i )
{
    local int NewPosition;
    
    if( SoundsList.Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, SoundsList.Items.Length - SoundsList.DisplayCount ) );

        SoundsList.Position = NewPosition;

        LayoutMenuStringList( SoundsList );
        UpdateScrollBar();
        
        Assert( SoundsList.Items[i].bHidden == 0 );
    }
    
    FocusOnWidget( SoundsList.Items[i] );
}


simulated function UpdateScrollBar()
{
    ScrollBar.Position = SoundsList.Position;
    ScrollBar.Length = SoundsList.Items.Length;
    ScrollBar.DisplayCount = SoundsList.DisplayCount;
    LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
}


simulated function OnListScroll()
{
    SoundsList.Position = ScrollBar.Position;
    LayoutMenuStringList( SoundsList );
}


simulated function ScrollListTo( int NewPosition )
{
    if( ScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, ScrollBar.Length - ScrollBar.DisplayCount ) );

    if( ScrollBar.Position == NewPosition )
        return;
    
    ScrollBar.Position = NewPosition;
    
    LayoutMenuScrollBar( ScrollBar );
}

simulated function OnListScrollUp()
{
    ScrollListTo( ScrollBar.Position - 1 );
}

simulated function OnListScrollDown()
{
    ScrollListTo( ScrollBar.Position + 1 );
}

simulated function OnListPageUp()
{
    ScrollListTo( ScrollBar.Position - ScrollBar.DisplayCount );
}

simulated function OnListPageDown()
{
    ScrollListTo( ScrollBar.Position + ScrollBar.DisplayCount );
}

simulated function OnAvailableScrollLinesUp( int Lines )
{
    ScrollListTo( ScrollBar.Position - Lines );
}

simulated function OnAvailableScrollLinesDown( int Lines )
{
    ScrollListTo( ScrollBar.Position + Lines );
}

defaultproperties
{
     Label=(Text="Select Sound",DrawPivot=DP_MiddleLeft,PosX=0.670000,PosY=0.242500,Style="MiniedDrawerText")
     SoundsList=(Template=(BackgroundFocused=(PosX=-0.005000,ScaleX=0.320000),OnSelect="OnSoundSelect"),PosX1=0.765000,PosY1=0.310000,PosX2=0.765000,PosY2=0.450000,OnScroll="UpdateScrollBar",Pass=3,Style="SmallButtonList")
     BorderBox=(DrawPivot=DP_MiddleRight,PosX=0.927500,PosY=0.400000,ScaleX=0.300000,ScaleY=0.250000,Style="DarkBorder")
     ScrollBorder=(DrawPivot=DP_MiddleRight,PosX=0.927500,PosY=0.400000,ScaleX=0.030000,ScaleY=0.250000,Style="BlackBorder")
     ScrollBar=(PosX1=0.912800,PosY1=0.300000,PosX2=0.661000,PosY2=0.500000,OnScroll="OnListScroll",Pass=2,Style="NewVerticalScrollBar")
     ScrollBarArrowUp=(Blurred=(PosX=0.913000,PosY=0.290000),OnSelect="OnAvailableScrollUp",Pass=2,Style="VerticalScrollBarArrowUp")
     ScrollBarArrowDown=(Blurred=(PosX=0.913000,PosY=0.510000),OnSelect="OnAvailableScrollDown",Pass=2,Style="VerticalScrollBarArrowDown")
     ScrollArea=(X1=0.015000,Y1=0.578000,X2=0.375000,Y2=0.772000,OnScrollTop="OnAvailableScrollTop",OnScrollPageUp="OnAvailablePageUp",OnScrollLinesUp="OnAvailableScrollLinesUp",OnScrollLinesDown="OnAvailableScrollLinesDown",OnScrollPageDown="OnAvailablePageDown",OnScrollBottom="OnAvailableScrollBottom")
     PageUpArea=(bIgnoreController=1,OnSelect="OnAvailablePageUp",Pass=2)
     PageDownArea=(bIgnoreController=1,OnSelect="OnAvailablePageDown",Pass=2)
     HelpText_SelectSound="Select this ambient sound"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(ScaleX=0.400000,ScaleY=0.400000)
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
