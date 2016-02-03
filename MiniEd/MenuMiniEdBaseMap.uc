class MenuMiniEdBaseMap extends MenuTemplateTitledBA;

var() String            GameType;

var() MenuText          Headings[2];
var() MenuSprite        HeadingSeperator;

var() MenuStringList	LongNames;
var() MenuStringList	Themes;
var() MenuScrollArea	ScrollArea;
var() MenuScrollBar		ScrollBar;
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget	PageUpArea, PageDownArea;

var() Array<xUtil.MapRecord> MapRecords;
var() String GameTypePrefix;

simulated function Init( String Args )
{
    local Array<xUtil.GameTypeRecord> GameTypeRecords;
    local xUtil.MiniEdMapRecord MiniEdRecord;
    local int i;
    local String MapPrefix;

    GameType = Args;

    class'xUtil'.static.GetGameTypeList( GameTypeRecords );
    Assert( GameTypeRecords.Length != 0 );
    
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        if( GameTypeRecords[i].ClassName ~= GameType )
        {
            GameTypePrefix = GameTypeRecords[i].MapPrefix;
            MapPrefix = GameTypePrefix $ "-";
        }
    }
    
    Assert( Len(MapPrefix) > 0 );
    
    class'xUtil'.static.GetMapList( MapRecords, false, false, MapPrefix );

    for( i = 0; i < MapRecords.Length; ++i )
    {
        if( MapRecords[i].MapClass != MC_NonCustom )
        {
            MapRecords.Remove( i, 1 );
            --i;
        }
    }
    
    Assert( MapRecords.Length > 0 );
    
    for( i = 0; i < MapRecords.Length; ++i )
    {
        LongNames.Items[i].ContextID = i;
        LongNames.Items[i].Focused.Text = MapRecords[i].LongName;
        LongNames.Items[i].Blurred.Text = LongNames.Items[i].Focused.Text;
        
        MiniEdRecord = class'xUtil'.static.GetMiniedBaseMapInfo( MapRecords[i].MapName );
        
        Themes.Items[i].bDisabled = 1;
        Themes.Items[i].Focused.Text = MiniEdRecord.Theme;
        Themes.Items[i].Blurred.Text = Themes.Items[i].Focused.Text;
    }

    LayoutMenuStringList( LongNames );
    LayoutMenuStringList( Themes );
	UpdateScrollBar();
    ScrollListTo(0);
    FocusOnWidget(LongNames.Items[0]);
}

simulated function HandleInputBack()
{
    GotoMenuClass( "MiniEd.MenuMiniEdGameType", Args );
}

simulated function UpdateScrollBar()
{
    if( LongNames.Items.Length <= LongNames.DisplayCount )
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

        ScrollBar.Position = LongNames.Position;
        ScrollBar.Length = LongNames.Items.Length;
        ScrollBar.DisplayCount = LongNames.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    LongNames.Position = ScrollBar.Position;
    Themes.Position = ScrollBar.Position;
    LayoutMenuStringList( LongNames );
    LayoutMenuStringList( Themes );
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

simulated function OnSelect(int ContextID)
{
	local String URL;
	
	RestoreVideo();
		
	URL = 
	    MapRecords[ContextID].MapName
	    $ "?Game=MiniEd.MiniEdInfo"
	    $ "?MENU=MiniEd.MenuEditor"
	    $ "?MAKING_NEW_MINIED_MAP";
	
	log("URL" @ URL);
	
	PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
}

simulated function OnFocus( int MapIndex )
{
    local String MapBink;
    MapBink = MapRecords[MapIndex].MapName $ "Loop.bik";
    SetBackgroundVideo( MapBink );
}

defaultproperties
{
     Headings(0)=(Text="Map",DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.220000,Pass=3,Style="NormalLabel")
     Headings(1)=(Text="Theme",DrawPivot=DP_MiddleRight,PosX=0.885000)
     HeadingSeperator=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=100,G=100,R=100,A=100),DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.253000,ScaleX=63.000000,ScaleY=0.100000,Pass=5)
     LongNames=(Template=(Blurred=(ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.500000),OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     Themes=(Template=(Blurred=(DrawPivot=DP_MiddleRight,ScaleX=0.800000,ScaleY=0.800000)),PosX1=0.885000,PosX2=0.885000,Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     MenuTitle=(Text="Select Base Map")
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
