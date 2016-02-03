class MenuCustomMaps extends MenuTemplateTitledBXA;

enum EMapState
{
    MS_Unpublished,
    MS_Published,
    MS_OutOfSync,
    MS_Downloadable,
    MS_Damaged,
    MS_Downloaded
};

struct CustomMapState
{
    var() String    MapName;   // DM-SuperMidget_Shaggie76
    var() String    LongName;  // SuperMidget
    var() String    Author;    // Shaggie76
    var() EMapState MapState;
};

var() localized String StateLabels[6];

var() localized String StringPublish;
var() localized String StringUnpublish;
var() localized String StringDelete;
var() localized String StringDownload;

var() localized String StringConfirmDelete;
var() localized String StringConfirmDeleteDamaged;
var() localized String StringConfirmRepublish;
var() localized String StringConfirmRedownload;
var() localized String StringConfirmUnpublish;
var() localized String StringConfirmUnsafeUnpublish;

var() MenuStringList    MapNameAuthor;
var() MenuStringList    MapStates;
var() MenuScrollArea    ScrollArea;
var() MenuScrollBar     ScrollBar;
var() MenuButtonSprite  ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget  PageUpArea, PageDownArea;

var() MenuText			NoMapsFound;

var() Array<CustomMapState> Maps;

var() bool IsSelf;

simulated function Init( String Args )
{
    Super.Init( Args );
    log( "Args:" @ Args );
    
    if( Args == "SELF" )
    {
        IsSelf = true;
    }
    
    Refresh();
}

simulated function String Pork()
{
    local int i, c;
    local String MapName;    
    local String ListText;    

    c = Rand(20);
    
    for( i = 0; i < c; i++ )
    {
        MapName = "DM-" $ Rand(100) $ "SuperMidgets" $ "@" $ "Shaggie" $ ( 70 + Rand(10) );
        ListText = ListText @ MakeQuotedString(MapName) @ Rand(40000000) @ Rand(40000000) @ "###";
    }
    
    return(ListText);
}

simulated function ParseList( String ListText )
{
    local int MapIndex;
    local int MapRecordIndex;

    local int ModTimeLow;
    local int ModTimeHigh;
    local int TimeOrder;

    local Array<xUtil.MapRecord> MapRecords;
    
    Maps.Length = 0;
    MapIndex = 0;

    class'xUtil'.static.GetMapList( MapRecords, true, true );

    while( ListText != "" )
    {
        Maps[MapIndex].MapName = ParseToken(ListText);
        
        CrackLiveMapName( Maps[MapIndex].MapName, Maps[MapIndex].LongName, Maps[MapIndex].Author );
        
        ModTimeHigh = int( ParseToken(ListText) );
        ModTimeLow = int( ParseToken(ListText) );
        
        if( ParseToken(ListText) != "###" )
            log( "*** ParseList error, terminator not found!", 'Error' );

        for( MapRecordIndex = 0; MapRecordIndex < MapRecords.Length; ++MapRecordIndex )
        {
            if( MapRecords[MapRecordIndex].MapClass != MC_Live )
            {
                continue;
            }
        
            if( Maps[MapIndex].MapName ~= GetCustomMapName(MapRecords[MapRecordIndex].MapName) )
            {
                break;
            }
        }
        
        if( MapRecordIndex < MapRecords.Length )
        {
            class'xUtil'.static.CompareFileTimes( MapRecords[MapRecordIndex].ModTimeLow, MapRecords[MapRecordIndex].ModTimeHigh, ModTimeLow, ModTimeHigh, TimeOrder );

            if( MapRecords[MapRecordIndex].LiveStatus != MS_Safe )
            {
                Maps[MapIndex].MapState = MS_Damaged;
            }
            else if( TimeOrder != 0 )
            {
                Maps[MapIndex].MapState = MS_OutOfSync;
                log( Maps[MapIndex].LongName @ "OOS. Local:" @ MapRecords[MapRecordIndex].ModTimeLow @ MapRecords[MapRecordIndex].ModTimeHigh @ "Remote:" @ ModTimeLow @ ModTimeHigh );
            }
            else
            {
                if( IsSelf )
                {
                    Maps[MapIndex].MapState = MS_Published;
                }
                else
                {
                    Maps[MapIndex].MapState = MS_Downloaded;
                }
            }
            
            // Remove this map record so we can append the unpublished ones at the end:
            MapRecords.Remove( MapRecordIndex, 1 );
        }
        else
        {
            Maps[MapIndex].MapState = MS_Downloadable;
        }
        
        MapIndex++;
    }
    
    if( IsSelf )
    {
        for( MapRecordIndex = 0; MapRecordIndex < MapRecords.Length; ++MapRecordIndex )
        {
            if( MapRecords[MapRecordIndex].MapClass != MC_Live )
            {
                continue;
            }

            Maps[MapIndex].MapName = GetCustomMapName(MapRecords[MapRecordIndex].MapName);
            CrackLiveMapName( Maps[MapIndex].MapName, Maps[MapIndex].LongName, Maps[MapIndex].Author );

            if( MapRecords[MapRecordIndex].LiveStatus != MS_Safe )
            {
                Maps[MapIndex].MapState = MS_Damaged;
            }
            else
            {
                Maps[MapIndex].MapState = MS_Unpublished;
            }

            MapIndex++;
        }
    }
}

simulated function Refresh()
{
    local int i;
    local int PrevFocusIndex;
    
    for( PrevFocusIndex = 0; PrevFocusIndex < MapNameAuthor.Items.Length; ++PrevFocusIndex )
    {
        if( bool(MapNameAuthor.Items[PrevFocusIndex].bHasFocus) )
        {
            break;
        }
    }
    
    if( IsOnConsole() )
    {
        ParseList( ConsoleCommand("XLIVE STORAGE GET_MAPS") );
    }
    else
    {
        ParseList( Pork() );
    }
    
    FocusOnNothing();

    MapNameAuthor.Items.Remove( 0, MapNameAuthor.Items.Length );
    MapStates.Items.Remove( 0, MapStates.Items.Length );

    for( i = 0; i < Maps.Length; ++i )
    {
        MapNameAuthor.Items[i].ContextID = i;
        MapNameAuthor.Items[i].Focused.Text = Maps[i].LongName $ "\\n____" $ Maps[i].Author;
        MapNameAuthor.Items[i].Blurred.Text = MapNameAuthor.Items[i].Focused.Text;
        
        MapStates.Items[i].Focused.Text = StateLabels[int(Maps[i].MapState)] $ "\\n_"; // Check out my drunken style. "_" == " " 
        MapStates.Items[i].Blurred.Text = MapStates.Items[i].Focused.Text;
        MapStates.Items[i].bDisabled = 1;
    }

    Assert( MapNameAuthor.Items.Length == MapStates.Items.Length );
    
    LayoutMenuStringList( MapNameAuthor );
    LayoutMenuStringList( MapStates );
    
	UpdateScrollBar();
    
    if( Maps.Length == 0 )
    {
        NoMapsFound.bHidden = 0;
        HideAButton(1);
        HideXButton(1);
    }
    else
    {
        NoMapsFound.bHidden = 1;
        FocusOnMap(PrevFocusIndex);
    }
}

simulated function UpdateScrollBar()
{
    if( MapNameAuthor.Items.Length <= MapNameAuthor.DisplayCount )
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

        ScrollBar.Position = MapNameAuthor.Position;
        ScrollBar.Length = MapNameAuthor.Items.Length;
        ScrollBar.DisplayCount = MapNameAuthor.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    MapNameAuthor.Position = ScrollBar.Position;
    MapStates.Position = ScrollBar.Position;
    LayoutMenuStringList( MapNameAuthor );
    LayoutMenuStringList( MapStates );
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

simulated function int FindSelectedMap()
{
    local int i;
    
    for( i = 0; i < MapNameAuthor.Items.Length; ++i )
    {
        if( bool(MapNameAuthor.Items[i].bHasFocus) )
        {
            return(i);
        }
    }
    
    return(-1);
}

simulated function FocusOnMap( int i )
{
    local int NewPosition;
    
    if( i >= MapNameAuthor.Items.Length )
        return;
    
    if( MapNameAuthor.Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, MapNameAuthor.Items.Length - MapNameAuthor.DisplayCount ) );

        ScrollListTo( NewPosition );
        Assert( MapNameAuthor.Items[i].bHidden == 0 );
    }

    FocusOnWidget( MapNameAuthor.Items[i] );
}

simulated function ConfirmStorageAction( String Command, bool ShowProgress, int MapIndex, String Question )
{
    local MenuStorageConfirm M;
    
    M = Spawn( class'MenuStorageConfirm', Owner );
    
    Question = ReplaceSubstring( Question, "<MAPNAME>", Maps[MapIndex].LongName );
    
    M.SetText( Question );
    M.ShowProgress = ShowProgress;
    M.Command = Command @ MakeQuotedString(Maps[MapIndex].MapName);
    
    CallMenu(M);
}

simulated function OnAButton()
{
    local int i;
    
    i = FindSelectedMap();

    if( i < 0 )
    {
        return;
    }
    
    if( IsSelf )
    {
        switch( Maps[i].MapState )
        {
            case MS_Unpublished:
                CallMenuClass( "XInterfaceLive.MenuStorageTask", "XLIVE STORAGE PUBLISH" @ MakeQuotedString(Maps[i].MapName) );
                break;
            
            case MS_OutOfSync:
                ConfirmStorageAction( "XLIVE STORAGE PUBLISH", true, i, StringConfirmRepublish );
                break;

            case MS_Downloadable:
                CallMenuClass( "XInterfaceLive.MenuStorageTask", "XLIVE STORAGE DOWNLOAD" @ MakeQuotedString(Maps[i].MapName) );
                break;
            
            case MS_Damaged:
                CallMenuClass( "XInterfaceCommon.MenuCorruptContent", MakeQuotedString(Maps[i].MapName) @ "CLOSE" );
                break;
        }
    }
    else
    {
        switch( Maps[i].MapState )
        {
            case MS_Downloadable:
                CallMenuClass( "XInterfaceLive.MenuStorageTask", "XLIVE STORAGE DOWNLOAD" @ MakeQuotedString(Maps[i].MapName) );
                break;
                
            case MS_OutOfSync:
                ConfirmStorageAction( "XLIVE STORAGE DOWNLOAD", true, i, StringConfirmRedownload );
                break;
            
            case MS_Damaged:
                CallMenuClass( "XInterfaceCommon.MenuCorruptContent", MakeQuotedString(Maps[i].MapName) @ "CLOSE" );
                break;
        }
    }
}

simulated function OnXButton()
{
    local int i;
    
    i = FindSelectedMap();

    if( i < 0 )
    {
        return;
    }

    if( IsSelf )
    {    
        switch( Maps[i].MapState )
        {
            case MS_Unpublished:
                ConfirmStorageAction( "DELETE", false, i, StringConfirmDelete );
                break;
            
            case MS_Damaged:
                ConfirmStorageAction( "DELETE", false, i, StringConfirmDeleteDamaged );
                break;
            
            case MS_Published:
            case MS_OutOfSync:
                ConfirmStorageAction( "XLIVE STORAGE UNPUBLISH", true, i, StringConfirmUnpublish );
                break;
            
            case MS_Downloadable:
                ConfirmStorageAction( "XLIVE STORAGE UNPUBLISH", true, i, StringConfirmUnsafeUnpublish );
                break;
        }
    }
    else
    {
        switch( Maps[i].MapState )
        {
            case MS_OutOfSync:
            case MS_Damaged:
            case MS_Downloaded:
                ConfirmStorageAction( "DELETE", false, i, StringConfirmDelete );
                break;
        }
    }
}

simulated function OnFocus( int i )
{
    switch( Maps[i].MapState )
    {
        case MS_Unpublished:
            Assert( IsSelf );
            HideAButton(0);
            HideXButton(0);
            ALabel.Text = StringPublish;
            XLabel.Text = StringDelete;
            break;
        
        case MS_Published:
            Assert( IsSelf );
            HideAButton(1);
            HideXButton(0);
            XLabel.Text = StringUnpublish;
            break;

        case MS_OutOfSync:
            HideAButton(0);
            HideXButton(0);
            
            if( IsSelf )
            {
                ALabel.Text = StringPublish;
                XLabel.Text = StringUnpublish;
            }
            else
            {
                ALabel.Text = StringDownload;
                XLabel.Text = StringDelete;
            }
            break;

        case MS_Downloadable:
            HideAButton(0);
            ALabel.Text = StringDownload;
            
            if( IsSelf )
            {
                HideXButton(0);
                XLabel.Text = StringUnpublish;
            }
            else
            {
                HideXButton(1);
            }
            
            break;

        case MS_Damaged:
            HideAButton(0);
            HideXButton(0);
            ALabel.Text = default.ALabel.Text; // Select
            XLabel.Text = StringDelete;
            break;

        case MS_Downloaded:
            Assert( !IsSelf );
            HideAButton(1);
            HideXButton(0);
            XLabel.Text = StringDelete;
            break;
            
        default:
            HideAButton(1);
            HideXButton(1);
            break;
    }

    bDynamicLayoutDirty = true;
}

defaultproperties
{
     StateLabels(0)="Unpublished"
     StateLabels(1)="Published"
     StateLabels(2)="Out of Sync"
     StateLabels(3)="Downloadable"
     StateLabels(4)="Damaged"
     StateLabels(5)="Downloaded"
     StringPublish="Publish"
     StringUnpublish="Unpublish"
     StringDelete="Delete"
     StringDownload="Download"
     StringConfirmDelete="Are you sure you want to delete <MAPNAME>?\n\n"
     StringConfirmDeleteDamaged="Are you sure you want to delete <MAPNAME>?\n\nIt is damaged and can not be used."
     StringConfirmRepublish="Are you sure you want to publish <MAPNAME> again?\n\nThis will replace the published copy with the copy from your Xbox."
     StringConfirmRedownload="Are you sure you want to download <MAPNAME> again?\n\nThis will replace the copy on your Xbox with the published copy."
     StringConfirmUnpublish="Are you sure you want to stop publishing <MAPNAME>?\n\nYour friends will no longer be able to download this map."
     StringConfirmUnsafeUnpublish="Are you sure you want to stop publishing <MAPNAME>?\n\nYour friends will no longer be able to download this map and you do not have a local copy of it on your Xbox."
     MapNameAuthor=(Template=(Blurred=(MaxSizeX=0.800000,bWordWrap=1),BackgroundFocused=(PosX=-0.050000,PosY=-0.030000,ScaleX=0.340000,ScaleY=0.035000),OnFocus="OnFocus",OnSelect="OnAButton"),PosY1=0.330000,PosY2=0.670000,DisplayCount=4,OnScroll="UpdateScrollBar",Style="TitledStringList")
     MapStates=(Template=(Blurred=(DrawPivot=DP_MiddleRight,MaxSizeX=0.300000,bWordWrap=1,TextAlign=TA_Right)),PosX1=0.500000,PosY1=0.330000,PosX2=0.500000,PosY2=0.670000,DisplayCount=4,Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     NoMapsFound=(Text="No maps found.",Style="MessageText")
     APlatform=MWP_All
     MenuTitle=(Text="Custom Maps")
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
