class MenuHostMapList extends MenuTemplateTitledBXYA;

var MenuHostMain HostMain;

var() MenuStringList    MapNames;
var() MenuStringList    Checkboxes;
var() MenuScrollArea    ScrollArea;
var() MenuScrollBar     ScrollBar;
var() MenuButtonSprite  ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget  PageUpArea, PageDownArea;

var() MenuButtonSprite  Checked;
var() MenuButtonSprite  Unchecked;

var() localized String  StringAdd;
var() localized String  StringRemove;

var() localized String  StringNoMaps;

simulated function Init( String Args )
{
    local String MapName;
    local int i;
    local int RecordIndex;
    local MapList Maps;
    
    Super.Init( Args );
    
    HostMain = MenuHostMain(PreviousMenu);
    Assert( HostMain != None );
    Maps = HostMain.GameSettings[HostMain.GameTypeIndex].Maps;
    Assert( Maps != None );
    
    Maps.CurrentMapIndex = Clamp( Maps.CurrentMapIndex, 0, Maps.MapEntries.Length - 1 );

    for( i = 0; i < Maps.MapEntries.Length; ++i )
    {
        MapName = Maps.MapEntries[(Maps.CurrentMapIndex + i) % Maps.MapEntries.Length].MapName;
        
        RecordIndex = FindMapRecord(MapName);
        
        MapNames.Items[i].ContextID = i;
        MapNames.Items[i].Focused.Text = HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords[RecordIndex].LongName;
        MapNames.Items[i].Blurred.Text = MapNames.Items[i].Focused.Text;
        
        Checkboxes.Items[i].ContextID = i;
        
        if( bool(Maps.MapEntries[(Maps.CurrentMapIndex + i) % Maps.MapEntries.Length].bSelected) )
        {
            Checkboxes.Items[i].BackgroundBlurred.WidgetTexture = Checked.Blurred.WidgetTexture;
            Checkboxes.Items[i].BackgroundFocused.WidgetTexture = Checked.Focused.WidgetTexture;
        }
        else
        {
            Checkboxes.Items[i].BackgroundBlurred.WidgetTexture = Unchecked.Blurred.WidgetTexture;
            Checkboxes.Items[i].BackgroundFocused.WidgetTexture = Unchecked.Focused.WidgetTexture;
        }
    }
    
    Assert( MapNames.Items.Length == Checkboxes.Items.Length );
    
    LayoutMenuStringList( MapNames );
    LayoutMenuStringList( Checkboxes );
	UpdateScrollBar();
}

simulated function HandleInputBack()
{
    if( SaveMapList() )
    {
        HostMain.Refresh();
        CloseMenu();
        RestoreVideo();
    }
}

simulated function String GetFileName( String LongName )
{
    local int i;
    
    for( i = 0; i < HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords.Length; ++i )
    {
        if( LongName ~= HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords[i].LongName )
        {
            return( HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords[i].MapName );
        }
    }
    
    assert(false);
    return("");
}

simulated function bool SaveMapList()
{
    local int i;
    local int Count;
    local MapList Maps;
	local MenuMessageBox MessageBox;
	local String MapName;
	local bool bSelected;
    
    if( MapNames.Items.Length == 0 )
    {
        return(true);
    }
    
    Maps = HostMain.GameSettings[HostMain.GameTypeIndex].Maps;
    Assert( Maps != None );
    
    for( i = 0; i < MapNames.Items.Length; ++i )
    {
        if( Checkboxes.Items[i].BackgroundBlurred.WidgetTexture == Checked.Blurred.WidgetTexture )
        {
            ++Count;
        }
    }
    
    if( Count == 0 )
    {
        MessageBox = Spawn( class'XInterfaceCommon.MenuMessageBox', Owner );
        MessageBox.SetText( StringNoMaps );
        CallMenu( MessageBox );
        return(false);
    }
    
    Maps = HostMain.GameSettings[HostMain.GameTypeIndex].Maps;
    Assert( Maps != None );
    
    Maps.Clear();
    
    for( i = 0; i < MapNames.Items.Length; ++i )
    {
    	MapName = GetFileName( MapNames.Items[i].Blurred.Text );
        
        if( Checkboxes.Items[i].BackgroundBlurred.WidgetTexture == Checked.Blurred.WidgetTexture )
    	    bSelected = true;
    	else
    	    bSelected = false;
    	
        Maps.AddMap( MapName, bSelected, false );
    }
    
    return(true);
}

simulated function int FindMapRecord( String MapName )
{
    local int i;
    
    for( i = 0; i < HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords.Length; ++i )
    {
        if( HostMain.GameSettings[HostMain.GameTypeIndex].MapRecords[i].MapName ~= MapName )
        {
            return(i);
        }
    }
    
    log("Could not find map record for" @ MapName, 'Error');
    Assert(false);
}

simulated function UpdateScrollBar()
{
    if( MapNames.Items.Length <= MapNames.DisplayCount )
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

        ScrollBar.Position = MapNames.Position;
        ScrollBar.Length = MapNames.Items.Length;
        ScrollBar.DisplayCount = MapNames.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    MapNames.Position = ScrollBar.Position;
    Checkboxes.Position = ScrollBar.Position;
    LayoutMenuStringList( MapNames );
    LayoutMenuStringList( Checkboxes );
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

simulated function OnSelect(int i)
{
    if( Checkboxes.Items[i].BackgroundBlurred.WidgetTexture == Checked.Blurred.WidgetTexture )
    {
        Checkboxes.Items[i].BackgroundBlurred.WidgetTexture = Unchecked.Blurred.WidgetTexture;
        Checkboxes.Items[i].BackgroundFocused.WidgetTexture = Unchecked.Focused.WidgetTexture;
    }
    else
    {
        Checkboxes.Items[i].BackgroundBlurred.WidgetTexture = Checked.Blurred.WidgetTexture;
        Checkboxes.Items[i].BackgroundFocused.WidgetTexture = Checked.Focused.WidgetTexture;
    }
    
    OnFocus(i);
}

simulated function int FindCurrentMap()
{
    local int i;
    
    for( i = 0; i < MapNames.Items.Length; ++i )
    {
        if( MapNames.Items[i].bHasFocus != 0 )
        {
            return(i);
        }

        if( Checkboxes.Items[i].bHasFocus != 0 )
        {
            return(i);
        }
    }
    
    return(-1);
}

simulated function SwapRows( int i, int j )
{
    local MenuButtonText Temp;
    
    Assert( i != j );
    
    Temp = MapNames.Items[i];
    MapNames.Items[i] = MapNames.Items[j];
    MapNames.Items[j] = Temp;
    
    MapNames.Items[i].ContextId = i;
    MapNames.Items[j].ContextId = j;

    Temp = Checkboxes.Items[i];
    Checkboxes.Items[i] = Checkboxes.Items[j];
    Checkboxes.Items[j] = Temp;
    
    Checkboxes.Items[i].ContextId = i;
    Checkboxes.Items[j].ContextId = j;
}

simulated function OnYButton()
{
    local int i;
    
    i = FindCurrentMap();
    
    if( i <= 0 )
    {
        return;
    }
    
    FocusOnNothing();
    SwapRows( i, i - 1 );
    OnListScroll();
    FocusOnWidget(MapNames.Items[i - 1]);
}

simulated function OnXButton()
{
    local int i;
    
    i = FindCurrentMap();
    
    if( (i < 0) || (i >= (MapNames.Items.Length - 1)) )
    {
        return;
    }
    
    FocusOnNothing();
    SwapRows( i, i + 1 );
    OnListScroll();
    FocusOnWidget(MapNames.Items[i + 1]);
}

simulated function OnFocus( int i )
{
    if( Checkboxes.Items[i].BackgroundBlurred.WidgetTexture == Checked.Blurred.WidgetTexture )
    {
        ALabel.Text = StringRemove;
    }
    else
    {
        ALabel.Text = StringAdd;
    }

    bDynamicLayoutDirty = true;
    ShowMapBink(i);
}

simulated function ShowMapBink( int MapIndex )
{
    local String MapBink;
    local int i;
    
    MapBink = GetFileName( MapNames.Items[MapIndex].Blurred.Text );

    i = InStr( MapBink, "?" );
    
    if( i > 0 )
    {
        MapBink = Left( MapBink, i );
    }
    
    MapBink = MapBink $ "Loop.bik";
    
    SetBackgroundVideo( MapBink );
}

defaultproperties
{
     MapNames=(Template=(OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     Checkboxes=(Template=(OnSelect="OnSelect"),Style="TitledCheckboxList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     Checked=(bHidden=1,Style="ButtonChecked")
     Unchecked=(bHidden=1,Style="ButtonUnchecked")
     StringAdd="Add"
     StringRemove="Remove"
     StringNoMaps="No maps selected!"
     YLabel=(Text="Move Up")
     YPlatform=MWP_Console
     ALabel=(Text="")
     XLabel=(Text="Move Down")
     XPlatform=MWP_Console
     MenuTitle=(Text="Map List")
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
