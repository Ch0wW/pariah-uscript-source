class MenuPracticeMap extends MenuTemplateTitledBA;

// Args: [MAP]

var() MenuStringList	MapList;
var() MenuScrollArea	ScrollArea;
var() MenuScrollBar		ScrollBar;
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget	PageUpArea, PageDownArea;

var() Array<xUtil.MapRecord> MapRecords;

var() xUtil.GameTypeRecord GameType;

simulated function Init( String Args )
{
    local int Pos;
    local int i;
    local String MapName;

    Super.Init( Args );
    
    class'xUtil'.static.GetMapList( MapRecords, false, false, GameType.MapPrefix $ "-" );

	for( i = 0; i < MapRecords.Length; i++ )
    {
        MapList.Items[i].ContextID = i;
        
        MapList.Items[i].Focused.Text = MapRecords[i].LongName;
        MapList.Items[i].Blurred.Text = MapRecords[i].LongName;

        if( MapName == MapRecords[i].MapName )
        {
            Pos = i;
        }
    }

    LayoutMenuStringList( MapList );
	UpdateScrollBar();
	
	FocusOnMap( Pos );
}

simulated function OnSelect(int ContextID)
{
    local String URL;
    local MenuPracticeDifficulty M;

    RestoreVideo();

    if( bool(GameType.bCustomMaps) )
    {
        URL = MapRecords[ContextID].MapName $ "?Game=" $ GameType.ClassName $ "?PracticeMode=true";
        URL = URL $ "?bAutoNumBots=false";
        
        class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
        class'GameEngine'.default.DisconnectMenuArgs = "";
        class'GameEngine'.static.StaticSaveConfig();

        PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
    }
    else
    {
        M = Spawn(class'MenuPracticeDifficulty', Owner);
        M.GameType = GameType;
        GotoMenu(M, MapRecords[ContextID].MapName);
    }
}

simulated function OnFocus( int MapIndex )
{
    local String MapBink;
    local int i;
    
    MapBink = MapRecords[MapIndex].MapName;

    i = InStr( MapBink, "?" );
    
    if( i > 0 )
    {
        MapBink = Left( MapBink, i );
    }
    
    MapBink = MapBink $ "Loop.bik";
    
    SetBackgroundVideo( MapBink );
}

simulated function HandleInputBack()
{
    local MenuPracticeGameType M;
    
    RestoreVideo();

    M = Spawn(class'MenuPracticeGameType', Owner);
    M.GameTypeName = GameType.ClassName;
    GotoMenu(M);
}

simulated function FocusOnMap( int i )
{
    local int NewPosition;
    
    if( MapList.Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, MapList.Items.Length - MapList.DisplayCount ) );

        MapList.Position = NewPosition;

        LayoutMenuStringList( MapList );
        UpdateScrollBar();
        
        Assert( MapList.Items[i].bHidden == 0 );
    }
    
    FocusOnWidget( MapList.Items[i] );
}

simulated function UpdateScrollBar()
{
    if( MapList.Items.Length <= MapList.DisplayCount )
    {
        ScrollBar.bHidden = 1;
        ScrollBarArrowUp.bHidden = 1;
        ScrollBarArrowDown.bHidden = 1;
        PageUpArea.bHidden = 1;
        PageDownArea.bHidden = 1;
    }
    else
    {
        ScrollBar.bHidden = 0;
        ScrollBarArrowUp.bHidden = 0;
        ScrollBarArrowDown.bHidden = 0;
        PageUpArea.bHidden = 0;
        PageDownArea.bHidden = 0;

        ScrollBar.Position = MapList.Position;
        ScrollBar.Length = MapList.Items.Length;
        ScrollBar.DisplayCount = MapList.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    MapList.Position = ScrollBar.Position;
    LayoutMenuStringList( MapList );
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

simulated function OnListScrollLinesUp( int Lines )
{
    ScrollListTo( ScrollBar.Position - Lines );
}

simulated function OnListScrollLinesDown( int Lines )
{
    ScrollListTo( ScrollBar.Position + Lines );
}

defaultproperties
{
     MapList=(Template=(OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     MenuTitle=(Text="Select Map")
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
