class MenuSinglePlayer extends MenuTemplateTitledBA;

var() MenuStringList	ChapterList;
var() MenuScrollArea	ScrollArea;
var() MenuScrollBar		ScrollBar;
var() MenuButtonSprite	ScrollBarArrowUp, ScrollBarArrowDown;
var() MenuActiveWidget	PageUpArea, PageDownArea;

var() Array<xUtil.MapRecord> MapRecords;

var() localized String ResumeString;
var() localized String Savepoint;

var int         mCurrentChapterNumber;
var bool        mMidwaySavePoint;
var int         mSelectedMapIndex;


simulated function Init( String Args )
{
    local GameProfile gProfile;
    local int unlockedChapter;
    local int mapIndex;

    Super.Init( Args );
    
    gProfile = GetCurrentGameProfile();
    assert(gProfile != None);
    mCurrentChapterNumber = gProfile.GetCurrentChapterNumber();
    unlockedChapter = gProfile.GetUnlockedChapterNumber();
    mMidwaySavePoint = gProfile.MidwaySavePoint();
        
    //log("mCurrentChapterNumber="$mCurrentChapterNumber);
    //log("unlockedChapter="$unlockedChapter);
    //log("midway save="$mMidwaySavePoint);
    
    class'xUtil'.static.GetMapList( MapRecords, false, false, "SP-" );
	//for( mapIndex = 0; mapIndex < MapRecords.Length; ++mapIndex )
    //{
    //    log("1 - map record ("$mapIndex$") = "$MapRecords[mapIndex].MapName);
    //}

    MapRecords.Remove( unlockedChapter, Max(MapRecords.Length - unlockedChapter, 0) );
   
	for( mapIndex = 0; mapIndex < MapRecords.Length; ++mapIndex )
    {
        //log("2 - map record ("$mapIndex$") = "$MapRecords[mapIndex].MapName);
        if(ShowChapter(mapIndex))
        {
            AddChapterEntry(gProfile.GetChapterEntry(MapRecords[mapIndex].MapName, MapRecords[mapIndex].LongName));
            //log("ShowChapter mapIndex="$mapIndex);
        }
        if(ShowResume(mapIndex))
        {
            AddChapterEntry(ResumeString);
            //log("ShowResume mapIndex="$mapIndex);
        }
    }
    
    LayoutMenuStringList( ChapterList );
	UpdateScrollBar();
	
    //log("ChapterList.Items.Length="$ChapterList.Items.Length);
	
	assert(ChapterList.Items.Length > 0);
	FocusOnChapter( GetListIndex(CurrentMapIndex()) );
	ShowCurrentProfile(GetPlayerName());
}

// add chapter entry
simulated function AddChapterEntry(string text)
{
    local int listIndex;
    listIndex = ChapterList.Items.Length;
    ChapterList.Items[listIndex].ContextID = listIndex;
    ChapterList.Items[listIndex].Focused.Text = text;
    ChapterList.Items[listIndex].Blurred.Text = ChapterList.Items[listIndex].Focused.Text;
}

// Resume is always shown, but in the case of resuming from a mid-way savepoint (ie. not from the 
// start of a chapter) then two entries are shown for the chapter (chX (start) & resume),
// so the list to map indicies are not necessarily 1 to 1
simulated function int GetMapIndex(int listIndex)
{
    if(mMidwaySavePoint && listIndex > CurrentMapIndex())
    {
        return(listIndex - 1);
    }
    return(listIndex);
}

// backward mapping - will select resume if two entries are shown for the current chapter
simulated function int GetListIndex(int mapIndex)
{
    if(mMidwaySavePoint && mapIndex >= CurrentMapIndex())
    {
        return(mapIndex + 1);
    }
    return(mapIndex);
}

simulated function int CurrentMapIndex()
{
    return(mCurrentChapterNumber - 1);
}

simulated function bool ShowResume(int mapIndex)
{
    return(CurrentMapIndex() == mapIndex);
}

simulated function bool ShowChapter(int mapIndex)
{
    return(mapIndex != CurrentMapIndex() || mMidwaySavePoint);
}

simulated function bool SelectedResume(int listIndex)
{
    local int mapIndex;
    mapIndex = GetMapIndex(listIndex); 
    return(mapIndex == CurrentMapIndex() && GetListIndex(mapIndex) == listIndex);
}

simulated function OnSelect(int listIndex)
{
    local GameProfile gProfile;

    gProfile = GetCurrentGameProfile();
    Assert(gProfile != None);
    
    // resume last unlocked map
    log("listIndex="$listIndex);

    mSelectedMapIndex = GetMapIndex(listIndex);
    if(gProfile.ContinueWithoutSaving(self))
    {
        PlayChapter(mSelectedMapIndex, ESM_ContinueWoS);
    }
    else if(SelectedResume(listIndex))
    {
        if(!mMidwaySavePoint || bool(LoadSaveCommand("VALID_SAVEPOINT")))
        {
            PlayChapter(mSelectedMapIndex, ESM_Resume);
        }
        else
        {
            CallMenuClass("XInterfaceCommon.MenuCorruptContent", MakeQuotedString(Savepoint) @ "CLOSE");
        }
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuOverwriteProgress");
    }
}

simulated function bool MenuClosed(Menu closingMenu)
{
    local GameProfile.ESessionMode mode;
    log(self@" closingMenu="$closingMenu);
    
    if(closingMenu.IsA('MenuOverwriteProgress'))
    {
        mode = MenuOverwriteProgress(closingMenu).mMode;
        if(mode != ESM_None)
        {
            PlayChapter(mSelectedMapIndex, mode);
        }
    }

    return(true);
}

simulated function PlayChapter(int mapIndex, GameProfile.ESessionMode mode)
{
    local GameProfile gProfile;
    local String URL;

    gProfile = GetCurrentGameProfile();
    Assert(gProfile != None);
        
    URL = gProfile.GetNextURL(MapRecords[mapIndex].MapName, mode);
    log("SP LaunchURL="$URL);

    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();

    RestoreVideo();

    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
}

simulated function OnFocus( int listIndex )
{
    local String MapBink;
    local int i;
    local int mapIndex;
    
    mapIndex = GetMapIndex(listIndex);
    
    MapBink = MapRecords[mapIndex].MapName;
    MapBink = MapBink $ "Loop.bik";
    
    i = InStr(MapBink, "SP-");

    if(i == 0)
    {
        MapBink = "Chapter" $ Mid(MapBink, InStr(MapBink, "_") + 1);
        SetBackgroundVideo( MapBink );
    }
}

simulated function HandleInputBack()
{
    RestoreVideo();
    
    if( PreviousMenu != None )
    {
        CloseMenu();
    }
    else
    {
        GotoMenuClass( "XInterfaceCommon.MenuMain" );
    }
}

simulated function FocusOnChapter( int i )
{
    local int NewPosition;
    
    if( ChapterList.Items[i].bHidden != 0 )
    {
        NewPosition = Min( i, Max( 0, ChapterList.Items.Length - ChapterList.DisplayCount ) );

        ChapterList.Position = NewPosition;

        LayoutMenuStringList( ChapterList );
        UpdateScrollBar();
        
        Assert( ChapterList.Items[i].bHidden == 0 );
    }
    
    FocusOnWidget( ChapterList.Items[i] );
}

simulated function UpdateScrollBar()
{
    if( ChapterList.Items.Length <= ChapterList.DisplayCount )
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

        ScrollBar.Position = ChapterList.Position;
        ScrollBar.Length = ChapterList.Items.Length;
        ScrollBar.DisplayCount = ChapterList.DisplayCount;
        LayoutMenuScrollBarEx( ScrollBar, PageUpArea, PageDownArea );
    }
}

simulated function OnListScroll()
{
    ChapterList.Position = ScrollBar.Position;
    LayoutMenuStringList( ChapterList );
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
     ChapterList=(Template=(OnFocus="OnFocus",OnSelect="OnSelect"),OnScroll="UpdateScrollBar",Style="TitledStringList")
     ScrollArea=(OnScrollPageUp="OnListPageUp",OnScrollLinesUp="OnListScrollLinesUp",OnScrollLinesDown="OnListScrollLinesDown",OnScrollPageDown="OnListPageDown",Style="TitledStringListScrollArea")
     ScrollBar=(OnScroll="OnListScroll",Style="TitledStringListScrollBar")
     ScrollBarArrowUp=(OnSelect="OnListScrollUp",Style="TitledStringListArrowUp")
     ScrollBarArrowDown=(OnSelect="OnListScrollDown",Style="TitledStringListArrowDown")
     PageUpArea=(OnSelect="OnListPageUp",Style="TitledStringListPageScrollArea")
     PageDownArea=(OnSelect="OnListPageDown",Style="TitledStringListPageScrollArea")
     ResumeString="Resume"
     Savepoint="Your last savepoint"
     MenuTitle=(Text="Select Chapter")
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
