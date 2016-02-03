class MenuProfileMain extends MenuTemplateTitledBA;

struct OptionData
{
    var int                 mEnabled;
    var localized string    mEnableText;
};

const                   cNumOptions = 4;
var OptionData          mOptionData[cNumOptions];
var() MenuButtonText    mOptions[cNumOptions];
var() config int        mPosition;
var ProfileData         mProfileData;
var bool                mIsSplit;


simulated function Init( String Args )
{
    mIsSplit = PlayerController(Owner).IsSharingScreen();

    mProfileData = GetProfileData();
    assert(mProfileData != None);   

    Super.Init( Args );

    UpdateOptions(true);
}

simulated function int GetProfileCount()
{
    local Array<string> Profiles;

    GetProfileList( Profiles );
    return( Profiles.Length );
}

simulated function SetOption(out int option, bool predicate)
{
    //log("opt="$option$" enabled="$predicate);
    mOptionData[option++].mEnabled = int(predicate);
}

simulated function UpdateOptions(bool reFocus)
{
    local int profileCount;
    local int option;
    local bool validProfileLoaded;
    local EProfileState profileState;
    local string playerName;

    log(self@" UPDATE OPTIONS!!");

    if(!mIsSplit)
    {
        playerName = GetPlayerName();
    }
    
    profileState = GetProfileState(playerName);
    validProfileLoaded = (profileState == EPS_Loaded);
    profileCount = GetProfileCount();
    
    //log("profileState:" @ profileState);
    //log("profileCount:" @ profileCount );
    //log("validProfileLoaded:" @ validProfileLoaded );
    
    // Set option visibility...
    
    // Edit (current)
    SetOption(option, validProfileLoaded);
    // Load
    SetOption(option, profileCount > 0);
    // New
    SetOption(option, profileCount < int(LoadSaveCommand("MAX_SAVED_GAMES")));
    // Delete
    SetOption(option, profileCount > 0);

    if(reFocus)
    {
        LayoutArray( mOptions[0], 'TitledOptionLayout' );
        mPosition = Clamp( mPosition, 0, cNumOptions - 1 );
        FocusOnWidget( mOptions[mPosition] );    
    }
        
    if(validProfileLoaded)
    {
        ShowCurrentProfile(playerName);
    }
    else
    {
        CurrentProfileText.bHidden = 1;
    }
}

simulated event PostEditChange()
{
    UpdateOptions(false);
}

simulated function SavePosition()
{
    for( mPosition = 0; mPosition < cNumOptions; mPosition++ )
    {
        if( mOptions[mPosition].bHasFocus != 0 )
            break;
    }
    
    if( mPosition >= cNumOptions )
        mPosition = 0;

    SaveConfig();
}

simulated function OnLoad()
{
    SavePosition();
    if(mOptionData[mPosition].mEnabled == 1)
    {
        CallMenuClass("XInterfaceCommon.MenuProfileSelect");
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuProfileWarning", MakeQuotedString(mOptionData[mPosition].mEnableText));
    }
}

simulated function OnEdit()
{
    SavePosition();
    if(mOptionData[mPosition].mEnabled == 1)
    {
        CallMenuClass("XInterfaceCommon.MenuProfileEdit");
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuProfileWarning", MakeQuotedString(mOptionData[mPosition].mEnableText));
    }    
}

simulated function OnNew()
{
    SavePosition();
        
    if(mOptionData[mPosition].mEnabled == 1)
    {
        if(mIsSplit)
        {
            assert(PreviousMenu == None);
            mProfileData.InitNew("SplitSave", self);
        }
        else
        {
            assert(PreviousMenu != None);
            assert(PreviousMenu.IsA('MenuMain'));
            mProfileData.InitNew("DoneSave", PreviousMenu);
        }

        mProfileData.SetRequirements(mProfileData.cNeedName);

        if(LowStorage())
        {
            CallMenuClass("XInterfaceCommon.MenuLowStorage");    
        }
        else
        {
            CallMenuClass(EditNameMenuClass());
        }
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuProfileWarning", MakeQuotedString(mOptionData[mPosition].mEnableText));
    }
}

simulated function OnDelete()
{
    SavePosition();
    if(mOptionData[mPosition].mEnabled == 1)
    {
        CallMenuClass( "XInterfaceCommon.MenuProfileSelect", "DELETE" );
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuProfileWarning", MakeQuotedString(mOptionData[mPosition].mEnableText));
    }
}

simulated function bool MenuClosed(Menu closingMenu)
{
    log(self@" closingMenu="$closingMenu);
    UpdateOptions(false);
    return(true);
}

simulated function HandleInputBack()
{
    if(mIsSplit)
    {
        CallMenuClass("XInterfaceCommon.MenuPause", "SPLIT_PROFILE_MAIN");
    }
    else
    {
        CloseMenu();
    }
}

simulated function SplitSave()
{
    local Menu top, m, p;

    log(self$" @#$% split create new profile - done saving!!!");
    
    top = PlayerController(Owner).Player.Console.CurMenu;
    if(!top.IsA('MenuProfileSaving'))
    {
        return;
    }
    
    m = top.PreviousMenu;
    while(m != self)
    {
        assert(m != None);
        p = m.PreviousMenu;
        log(self$" @#$% split create new profile - destroy m="$m);
        m.Destroy();
        m = p;
    }
    
    log(self$" @#$% split create new profile - now close profile main");
    CloseMenu();
}

defaultproperties
{
     mOptionData(0)=(mEnableText="There is no profile loaded. Please load a profile to edit.")
     mOptionData(1)=(mEnableText="There are no profiles to load.")
     mOptionData(2)=(mEnableText="All saved game slots have been filled. Please delete an existing profile to make room for a new one.")
     mOptionData(3)=(mEnableText="There are no profiles to delete.")
     mOptions(0)=(Blurred=(Text="Edit",PosX=0.145000),HelpText="Modify the current profile.",OnSelect="OnEdit",Style="TitledTextOption")
     mOptions(1)=(Blurred=(Text="Load"),HelpText="Load a profile.",OnSelect="OnLoad")
     mOptions(2)=(Blurred=(Text="New"),HelpText="Create a new profile.",OnSelect="OnNew")
     mOptions(3)=(Blurred=(Text="Delete"),HelpText="Delete a profile.",OnSelect="OnDelete")
     MenuTitle=(Text="Profiles")
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
