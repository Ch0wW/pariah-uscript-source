class MenuMiniEdLoad extends MenuTemplateTitledBXA;

var() MenuText          Headings[2];
var() MenuSprite        HeadingSeperator;

var() MenuStringList    DeleteButtons;
var() MenuStringList	LongNames;
var() MenuStringList	Classes; // PC: Theme, Xbox: [Live|Offline|Damaged]
var() MenuScrollArea	ScrollArea;
var() MenuScrollBar		ScrollBar;
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget	PageUpArea, PageDownArea;

var() MenuText			NoMapsFound;

var() Array<xUtil.MapRecord> MapRecords;

var() localized String StringTheme;
var() localized String StringClass;
var() localized String StringLive;
var() localized String StringOffline;
var() localized String StringDamaged;

var() config int Position;

var() MenuButtonSprite  Checked;
var() MenuButtonSprite  Unchecked;

simulated function Init( String Args )
{
    Super.Init(Args);
    Refresh();
}

simulated function Refresh()
{
    local xUtil.MiniEdMapRecord MiniEdRecord;
    local int i;
    local EMenuWidgetPlatform Platform;

    Platform = GetPlatform();

    class'xUtil'.static.GetMapList( MapRecords, false, true );
    Assert( MapRecords.Length > 0 );
    
    // Remove the non-custom maps:
    for( i = 0; i < MapRecords.Length; ++i )
    {
        if( MapRecords[i].MapClass == MC_NonCustom )
        {
            MapRecords.Remove( i, 1 );
            --i;
        }
    }
    
    for( i = 0; i < MapRecords.Length; ++i )
    {
        LongNames.Items[i].ContextID = i;
        LongNames.Items[i].Focused.Text = MapRecords[i].LongName;
        LongNames.Items[i].Blurred.Text = LongNames.Items[i].Focused.Text;
        
        if( Platform == MWP_Xbox )
        {
            if( MapRecords[i].OfflineStatus != MS_Safe )
            {
                Classes.Items[i].Focused.Text = StringDamaged;
            }
            else if( MapRecords[i].MapClass == MC_Live )
            {
                if( (PlayerController(Owner).LiveStatus == LS_SignedIn) && (MapRecords[i].LiveStatus != MS_Safe) )
                {
                    Classes.Items[i].Focused.Text = StringDamaged;
                }
                else
                {
                    Classes.Items[i].Focused.Text = StringLive;
                }
            }
            else
            {
                Classes.Items[i].Focused.Text = StringOffline;
            }

            DeleteButtons.Items[i].bHidden = 1;
        }
        else
        {
            MiniEdRecord = class'xUtil'.static.GetMiniedBaseMapInfo( BaseMapName(MapRecords[i].MapName) );
            Classes.Items[i].Focused.Text = MiniEdRecord.Theme;

            DeleteButtons.Items[i].ContextID = MapRecords.Length + i;
            DeleteButtons.Items[i].BackgroundBlurred.WidgetTexture = Unchecked.Blurred.WidgetTexture;
            DeleteButtons.Items[i].BackgroundFocused.WidgetTexture = Checked.Focused.WidgetTexture;
        }

        Classes.Items[i].bDisabled = 1;
        Classes.Items[i].Blurred.Text = Classes.Items[i].Focused.Text;
    }

    if( Platform != MWP_Xbox )
    {
        Assert( LongNames.Items.Length == DeleteButtons.Items.Length );
        LayoutMenuStringList( DeleteButtons );
    }

    LayoutMenuStringList( LongNames );
    LayoutMenuStringList( Classes );
    
	UpdateScrollBar();
    ScrollListTo(0);
    
    if( Platform == MWP_Xbox )
    {
        Headings[1].Text = StringClass;
    }
    else
    {
        Headings[1].Text = StringTheme;
    }
    
    if( LongNames.Items.Length > 0 )
    {
        Position = Clamp(Position, 0, (LongNames.Items.Length - 1 ));
        ScrollListTo(Position);
        FocusOnWidget(LongNames.Items[Position]);

        if( Platform == MWP_Xbox )
        {
            HideXButton(0);
        }
        else
        {
            HideXButton(1);
        }

        NoMapsFound.bHidden = 1;

        Headings[0].bHidden = 0;
        Headings[1].bHidden = 0;
	    HeadingSeperator.bHidden = 0;
    }
    else
    {
        HideAButton(1);
        HideXButton(1);
    
        NoMapsFound.bHidden = 0;
    
        Headings[0].bHidden = 1;
        Headings[1].bHidden = 1;
	    HeadingSeperator.bHidden = 1;
    }
}

simulated function HandleInputBack()
{
    SavePosition();
    GotoMenuClass( "MiniEd.MenuMiniEdMain" );
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
    Classes.Position = ScrollBar.Position;
    DeleteButtons.Position = ScrollBar.Position;
    LayoutMenuStringList( LongNames );
    LayoutMenuStringList( Classes );
    LayoutMenuStringList( DeleteButtons );
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
    local int i;

    if( GetPlatform() == MWP_PC )
    {
        for( i = 0; i < DeleteButtons.Items.Length; i++ )
        {
            if( DeleteButtons.Items[i].ContextID == ContextID )
            {
                GotoMenuClass( "MiniEd.MenuMiniEdDeleteConfirm", GetCustomMapName(MapRecords[i].MapName) );
                return;
            }
        }
    }


    URL = 
        MapRecords[ContextId].MapName
        $ "?MENU=MiniEd.MenuEditor"
        $ "?LOADING_MINIED_MAP";
        
    if( GetPlatform() == MWP_Xbox )
    {
        if( MapRecords[ContextID].OfflineStatus != MS_Safe ) 
        {
            CallMenuClass( "XInterfaceCommon.MenuCorruptContent", MakeQuotedString(MapRecords[ContextID].LongName) @ "CLOSE" );
            return;
        }
        
        if( (MapRecords[ContextID].MapClass == MC_Live) && (PlayerController(Owner).LiveStatus == LS_SignedIn) && (MapRecords[ContextID].LiveStatus != MS_Safe) ) 
        {
            CallMenuClass( "XInterfaceCommon.MenuCorruptContent", MakeQuotedString(MapRecords[ContextID].LongName) @ "CLOSE" );
            return;
        }
        
        if( (PlayerController(Owner).LiveStatus != LS_SignedIn) && (MapRecords[ContextID].MapClass == MC_Live) ) 
        {
			CallMenuClass("MiniEd.MenuMiniEdLoadLiveOffline", URL);
            return;        
        }
    }
    
    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );	
}

simulated function OnFocus(int ContextID)
{
    local String MapBink;
    local int i;

    MapBink = MapRecords[ContextID].MapName;
    
    i = InStr( MapBink, "?" );
    
    if( i > 0 )
    {
        MapBink = Left( MapBink, i );
    }
    
    MapBink = MapBink $ "Loop.bik";
    
    SetBackgroundVideo( MapBink );
}

simulated function int FindCurrentMap()
{
    local int i;
    
    for( i = 0; i < LongNames.Items.Length; ++i )
    {
        if( LongNames.Items[i].bHasFocus != 0 )
        {
            return(i);
        }
    }
    
    return(-1);
}

simulated function OnXButton()
{
    local int i;
    local bool Damaged;
    
    i = FindCurrentMap();
    
    if( i < 0 )
    {
        log("Can't delete, no map in focus");
        return;
    }

    if( GetPlatform() == MWP_Xbox )
    {
        if( MapRecords[i].OfflineStatus != MS_Safe )
        {
            Damaged = true;
        }
        else if( MapRecords[i].MapClass == MC_Live )
        {
            if( (PlayerController(Owner).LiveStatus == LS_SignedIn) && (MapRecords[i].LiveStatus != MS_Safe) )
            {
                Damaged = true;
            }
        }
    }
    
    SavePosition();
    GotoMenuClass( "MiniEd.MenuMiniEdDeleteConfirm", GetCustomMapName(MapRecords[i].MapName) @ String(Damaged) );
}

simulated function SavePosition()
{
    Position = FindCurrentMap();
    SaveConfig();
}

defaultproperties
{
     Headings(0)=(Text="Map",DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.220000,Pass=3,Style="NormalLabel")
     Headings(1)=(DrawPivot=DP_MiddleRight,PosX=0.885000)
     HeadingSeperator=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=100,G=100,R=100,A=100),DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.253000,ScaleX=63.000000,ScaleY=0.100000,Pass=5)
     DeleteButtons=(Template=(BackgroundBlurred=(ScaleX=0.600000,ScaleY=0.600000),OnSelect="OnSelect"),Style="TitledCheckboxList")
     LongNames=(Template=(Blurred=(ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.500000),OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     Classes=(Template=(Blurred=(DrawPivot=DP_MiddleRight,ScaleX=0.800000,ScaleY=0.800000)),PosX1=0.885000,PosX2=0.885000,Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     NoMapsFound=(Text="No maps found.",Style="MessageText")
     StringTheme="Theme"
     StringClass="Class"
     StringLive="Xbox Live"
     StringOffline="Offline"
     StringDamaged="Damaged"
     Checked=(Blurred=(WidgetTexture=Texture'MiniEdTextures.GUI.trashcan'),bHidden=1,Style="ButtonChecked")
     Unchecked=(Blurred=(WidgetTexture=Texture'MiniEdTextures.GUI.trashcan'),bHidden=1,Style="ButtonUnchecked")
     XLabel=(Text="Delete")
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
