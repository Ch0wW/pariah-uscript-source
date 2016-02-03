class MenuProfileSelect extends MenuTemplateTitledBA;

var() localized string        mSelectText;
var() localized string        mDeleteText;
var() localized string        mIsCurrentlyLoadedWarning;
var() localized string        mCorruptText;
var() localized String        mStringNotSet;
var() localized string        mBlocksText;
var() localized string        mKBText;
var() bool                    mDeleteMode;
var() MenuStringList          mProfileList;
var() int                     mLastFocused;
var() array<string>           mProfiles;
var() string                  mActiveProfile;
var() Manifest                mSaveManifest;
var() bool                    mIsSplit;
var() PlayerController        mPlayerOwner;

const DetailsMax = 5;

var() MenuText                mProfileDetails[DetailsMax];
var() localized string        mProfileDetailText[DetailsMax];
var() Array<xUtil.MapRecord>  mMapRecords;


simulated function Init(string args)
{    
    mDeleteMode = (ParseToken(args) ~= "DELETE");
    mPlayerOwner = PlayerController(Owner);
    mIsSplit = mPlayerOwner.IsSharingScreen();
    
    class'xUtil'.static.GetMapList( mMapRecords, false, false, "SP-" );
    
    Super.Init(args);
    UpdateProfileList(-1);
}

simulated function UpdateProfileList(int focusMe)
{
    local string currentProfileName;
    local int i;
    local int loadedIndex;
    local string n;

    mProfiles.Length = 0;
    mActiveProfile = "";
    
    LanguageChange();
    
    mSaveManifest = GetManifest();
    //mSaveManifest.LogEntries();
        
    GetProfileList(mProfiles);
    FocusOnNothing();
    mProfileList.Items.Length = Min(mProfiles.Length, mProfileList.DisplayCount);

    currentProfileName = GetPlayerName();
    //log(self@"::UpdateProfileList currentProfileName="$currentProfileName);
    
    loadedIndex = -1;
    for(i = 0; i < mProfileList.Items.Length; ++i)
    {
        mProfileList.Items[i].ContextID = i;
        n = mProfiles[i];
        if(currentProfileName != "" && currentProfileName ~= n)
        {
            assert(loadedIndex < 0);
            loadedIndex = i;
        }
        
            mProfileList.Items[i].Focused.Text = n;
            mProfileList.Items[i].Blurred.Text = n;
        }
    
    ShowCurrentProfile(currentProfileName);
    LayoutMenuStringList(mProfileList);
    
    assert(mProfiles.Length == mProfileList.Items.Length);
    assert(mProfileList.Items.Length <= mProfileList.DisplayCount);
    
    if(mProfiles.Length == 0)
    {
        return;
    }
    
    if(focusMe < 0)
    {
        mLastFocused = loadedIndex;
    }
    
    mLastFocused = Clamp(mLastFocused, 0, Min(mProfileList.Items.Length - 1, mProfileList.DisplayCount));

    //log(self@"::UpdateProfileList focus="$mLastFocused);

    Assert(mProfileList.Items[mLastFocused].bHidden == 0);
    
    FocusOnWidget(mProfileList.Items[mLastFocused]);
    ShowProfileDetails(mLastFocused);
}

simulated function OnFocus()
{
    local int i;
    
    for(i = 0; i < mProfileList.Items.Length; ++i)
    {
        if(mProfileList.Items[i].bHasFocus != 0)
        {
            mLastFocused = i;
			ShowProfileDetails(i);
			break;
        }
    }
}

simulated function OnSelect()
{
    local int i;

    for(i = 0; i < mProfileList.Items.Length; i++)
    {
        if(mProfileList.Items[i].bHasFocus != 0)
        {
            if(mDeleteMode)
            {
                DeleteProfile(i);
            }
            else
            {
                LoadProfile(i);
            }
            break;
        }
    }
}

simulated function ShowProfileDetails(int profileListIndex)
{
    local int i;
    local Manifest.ManifestEntry e;
    local string difficultyText;
    local int manifestIndex;
    
    if(mIsSplit)
    {
        for(i = 0; i < DetailsMax; ++i)
        {
            mProfileDetails[i].bHidden = 1;
        }
        return;
    }
    
    manifestIndex = -1;
    // find the manifestIndex that corresponds to the profileListIndex;
    for(i = 0; i < mSaveManifest.ManifestEntries.Length; ++i)
    {
        if(mSaveManifest.ManifestEntries[i].Name == mProfiles[profileListIndex])
        {
            manifestIndex = i;
            break;
        }
    }
    
    if(manifestIndex < 0)
    {
        assert(false);
        return;
    }
    
    e = mSaveManifest.ManifestEntries[manifestIndex];
    if(e.Corrupt == 1)
    {
        mProfileDetails[0].Text = mCorruptText;
        for(i = 1; i < DetailsMax; ++i)
        {
            mProfileDetails[i].Text = "";
        }
        return;
    }

    for(i = 0; i < DetailsMax; ++i)
    {
        mProfileDetails[i].Text = mProfileDetailText[i];
        mProfileDetails[i].bHidden = 0;
    }
    
    UpdateTextField(mProfileDetails[0].Text, "<Size>", string(e.Size));
    if(IsOnConsole())
    {
        UpdateTextField(mProfileDetails[0].Text, "<Unit>", mBlocksText);
    }
    else
    {
        UpdateTextField(mProfileDetails[0].Text, "<Unit>", mKBText);
    }
    UpdateTextField(mProfileDetails[1].Text, "<Date>", e.Date);
    UpdateTextField(mProfileDetails[2].Text, "<Time>", e.Time);
    UpdateTextField(mProfileDetails[3].Text, "<Progress>", FindNiceChapterName(e.Progress));
    
    difficultyText = mStringNotSet;
    if(e.Difficulty >= 0)
    {
        difficultyText = class'GameInfo'.static.GetDifficultyName(e.Difficulty);
    }
    UpdateTextField(mProfileDetails[4].Text, "<Difficulty>", difficultyText);
    
    // hack - hide size for PC!
    if(!IsOnConsole())
    {
        for(i = 0; i < DetailsMax - 1; ++i)
        {
            mProfileDetails[i].Text = mProfileDetails[i+1].Text;
        }
        mProfileDetails[DetailsMax - 1].bHidden = 1;
    }
}

simulated function string FindNiceChapterName(string fileName)
{
    local int i;
	for( i = 0; i < mMapRecords.Length; ++i )
    {
        if(fileName ~= mMapRecords[i].MapName)
        {
            return(class'GameProfile'.static.GetChapterEntry(mMapRecords[i].MapName, mMapRecords[i].LongName));
        }
    }
    //assert(false);
    return("");
}

simulated function LoadProfile(int i)
{
    local MenuProfileLoading m;
    local string currentProfileName;
    local string message;
    
    currentProfileName = GetPlayerName();
    if(mProfiles[i] == currentProfileName)
    {
        message = mIsCurrentlyLoadedWarning;
        UpdateTextField(message, "<ProfileName>", currentProfileName);    
        CallMenuClass("XInterfaceCommon.MenuProfileWarning", MakeQuotedString(message));
        return;
    }
    
    // verify before attempting to load
    if(GetProfileState(mProfiles[i]) == EPS_Corrupt)
    {
        CallMenuClass("XInterfaceCommon.MenuCorruptContent", MakeQuotedString(mProfiles[i]) @ "CLOSE");
        return;
    }
    
    mActiveProfile = mProfiles[i];
    m = MenuProfileLoading(CallMenuClassEx("XInterfaceCommon.MenuProfileLoading", "LOAD" @ mActiveProfile));
    assert(m != None);
    m.mCallbackName = 'DoLoad';
    m.mCallbackObject = self;   
}

simulated function DoLoad()
{
    assert(mActiveProfile != "");
    if(bool(LoadSaveCommand("LOAD", "NAME=" $ mActiveProfile)))
    {
        UpdateProfileList(-1);
    }
    else
    {
        warn("Failed to load profile" @ mActiveProfile);
    }
    mLastFocused = -1;
    mActiveProfile = "";
    Done();
}

simulated function DeleteProfile(int i)
{
    mActiveProfile = mProfiles[i];
    CallMenuClass("XInterfaceCommon.MenuProfileDeleteConfirm", mActiveProfile);
}

simulated function DoDelete()
{
    assert(mActiveProfile != "");        
    if(bool(LoadSaveCommand("DELETE", "NAME=" $ mActiveProfile)))
    {
        UpdateProfileList(mLastFocused);
    }
    else
    {
        warn("Failed to delete profile" @ mActiveProfile);
    }
    mActiveProfile = "";
    Done();    
}

simulated function Done()
{
    local Menu top, m, p, bottom;
    local MenuProfileLoading mpl;
       
    log("#Done#");    
    log(self);  
       
    top = mPlayerOwner.Player.Console.CurMenu;
    log("top="$top);  

    mpl = MenuProfileLoading(top);
    if(mpl == None)
    {
        assert(false);
        return;
    }
    
    m = top.PreviousMenu;
    while(m != self)
    {
        if(m == None)
        {
            assert(false);
            return;
        }
        log("m="$m);
        p = m.PreviousMenu;
        log("p="$p);
        log("#Destroy# m="$m);
        m.Destroy();
        m = p;
    }
    
    // return to this menu if deleting and there are still profiles to del, 
    // otherwise return to main profile menu
    if(mDeleteMode && mProfiles.Length > 0)
    {
        top.PreviousMenu = self;
        mPlayerOwner.Player.Console.PrevMenu = self;
    }
    else if(mIsSplit && !mpl.mDeleteMode)
    {
        // here we smash down to the bottom of the menu stack 
        // (from where the utilityoverlay spawned profilemain)
        log("mIsSplit="$mIsSplit);
        log("playerowner="$mPlayerOwner);
        log("mPlayerOwner.myHud="$mPlayerOwner.myHud);
        log("mPlayerOwner.myHud.UtilityOverlay="$mPlayerOwner.myHud.UtilityOverlay);
        bottom = mPlayerOwner.myHud.UtilityOverlay.GetBottomMenu();
        log("bottom="$bottom);  
        top.PreviousMenu = bottom;
        mPlayerOwner.Player.Console.PrevMenu = bottom;
        m = self;
        while(m != bottom && m != None)
        {
            log("m="$m);  
            p = m.PreviousMenu;
            log("p="$p);  
            log("#Destroy# m="$m);
            m.Destroy();
            m = p;
        }
    }
    else
    {
        top.PreviousMenu = PreviousMenu;
        mPlayerOwner.Player.Console.PrevMenu = PreviousMenu;
        Destroy();
    }
    
    log("#Done Done#");
}

simulated function LanguageChange()
{
    if(mDeleteMode)
    {
        MenuTitle.Text = mDeleteText;
    }
    else
    {
        MenuTitle.Text = mSelectText;
    }
}

defaultproperties
{
     mSelectText="Load Profile"
     mDeleteText="Delete Profile"
     mIsCurrentlyLoadedWarning="<ProfileName> is already loaded."
     mCorruptText="Profile is corrupt"
     mStringNotSet="Not Set"
     mBlocksText="blocks"
     mKBText="KB"
     mProfileList=(Template=(Blurred=(MaxSizeX=0.440000,bEllipsisOnLeft=1),OnFocus="OnFocus",OnSelect="OnSelect"),PosX1=0.120000,PosY1=0.250000,PosX2=0.120000,PosY2=0.750000,DisplayCount=10,Pass=3,Style="CheveronButtonList")
     mProfileDetails(0)=(MenuFont=Font'Engine.FontSmall',PosX=0.565000,PosY=0.250000,MaxSizeX=0.420000,Pass=3)
     mProfileDetails(4)=(PosX=0.565000,PosY=0.450000)
     mProfileDetailText(0)="Size: <Size> <Unit>"
     mProfileDetailText(1)="Date: <Date> "
     mProfileDetailText(2)="Time: <Time>"
     mProfileDetailText(3)="Progress: <Progress>"
     mProfileDetailText(4)="Difficulty: <Difficulty>"
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
