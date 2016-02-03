class MenuMain extends MenuTemplateTitledA;

var() MenuButtonText    Options[6];
var() MenuLayer         AttractModeLayer;
var() config int        Position;
var bool                bLinkActive;
var bool                bFoundCrossTitleInvite;
var ProfileData         mProfileData;
var EProfileState       mProfileState;
var string              OptionDestinationMenu[5];
var localized string    NoProfileLoadedText;

struct ProfileInfo
{
    var string          mName;
    var EProfileState   mState;
};

var array<ProfileInfo>  mProfiles;
var int                 mValidProfileIndex;


simulated function Init( String Args )
{
    bLinkActive = false;

    class'GameEngine'.default.DisconnectMenuClass = "";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();

    Super.Init( Args );

    SetTimer(0.1, true);
    UpdateOptions();

    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            continue;
    }
    
    FocusOnWidget( Options[Position] );
    
    assert(mProfileData == None);
    mProfileData = GetProfileData();
    assert(mProfileData != None);
    UpdateProfileData();
}

simulated function Destroyed()
{
    mProfileData.Reset();
    Super.Destroyed();
}
 
simulated function bool ValidProfileIndex()
{
    return(mValidProfileIndex >= 0 && mValidProfileIndex < mProfiles.Length);
}
    
simulated private function UpdateProfileData()
{
    local string playerName;
    local int i;
    local array<string> profiles;
    local PlayerController pc;
        
    mValidProfileIndex = -1;
    mProfiles.Length = 0;
    mProfileData.Reset();
    
    GetProfileList(profiles);
    for (i = 0; i < profiles.Length; ++i)
    {
        mProfiles[i].mName = profiles[i];
        mProfiles[i].mState = GetProfileState(profiles[i]);
        if(!ValidProfileIndex() && mProfiles[i].mState == EPS_Valid)
        {
            mValidProfileIndex = i;
        }
    }

    playerName = GetPlayerName();
    log(self@" playerName="$playerName);
    
    pc = PlayerController(Owner);
    assert(pc != None);
    
    mProfileState = GetProfileState(playerName);
    switch(mProfileState)
    {
        case EPS_Default: // no "current" profile loaded - either first run or util region has been cleared
        case EPS_Missing: // cached user.ini on the Z: drive has no corresponding save (deleted via dash?)
        case EPS_Corrupt: // corrupt menu leads to creation if no valid profiles
            if(!ValidProfileIndex())
            {
                mProfileData.InitNew("DoneSave", self);
            }
            break;
            
        case EPS_Loaded:
            mProfileData.InitExisting(self, playerName, "DoneSave", self);
            break;

        case EPS_InUse:
        case EPS_Valid:
        default:
            warn("Found invalid profile state:"$mProfileState);
            assert(false);
    }
}

simulated function Tick( float Delta )
{
    local MenuAttractMode M;
    
    Super.Tick( Delta );

    M = MenuAttractMode( AttractModeLayer.Layer );
    if( M != None )
    {
        M.MainMenu = self;
    }
}

simulated function bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if( AttractModeLayer.Layer != None )
    {
        return( AttractModeLayer.Layer.HandleInputKeyRaw(Key, Action) );
    }
    else
    {
        return(false);
    }
}

simulated function bool HandleInputAxis( Interactions.EInputKey Key, float Delta )
{
    if( AttractModeLayer.Layer != None )
    {
        return( AttractModeLayer.Layer.HandleInputAxis(Key, Delta) );
    }
    else
    {
        return(false);
    }
}

simulated function UpdateOptions()
{
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated event PostEditChange()
{
    UpdateOptions();
}

simulated function Timer()
{
    CheckForCrossTitleInvite();
}

simulated function CheckForCrossTitleInvite()
{
    if( bFoundCrossTitleInvite )
        return;
    
    if( "TRUE" == ConsoleCommand("XLIVE IS_CROSS_TITLE_INVITE") )
    {
        CallMenuClass("XInterfaceLive.MenuAcceptCrossTitleInvite");
        bFoundCrossTitleInvite = true;
        return;
    }
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(Options); Position++ )
    {
        if( Options[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(Options) )
        Position = 0;

    SaveConfig();
}

// make sure a valid profile is loaded and fully defined before proceeding
simulated function bool ProfileDefined()
{
    return(mProfileState == EPS_Loaded && mProfileData.AllDefined());
}

simulated function HandleUndefinedProfile()
{
    local string nextMenuClass;
    local string nextMenuArgs;
    
    //log(self@" profilestate="$mProfileState);
    
    switch(mProfileState)
    {    
        case EPS_Default:
        case EPS_Missing:
            if(ValidProfileIndex())
            {
                nextMenuClass = "XInterfaceCommon.MenuProfileWarning";
                nextMenuArgs = MakeQuotedString(NoProfileLoadedText) @ "SELECT";
            }
            else
            {
                if(LowStorage())
                {
                    nextMenuClass = "XInterfaceCommon.MenuLowStorage";
                }
                else
                {      
                    nextMenuClass = EditNameMenuClass();
                }
            }
            break;
            
        case EPS_Loaded:
            assert(!mProfileData.AllDefined());
            assert(!mProfileData.NeedName());
            assert(mProfileData.NeedDifficulty());
            nextMenuClass = "XInterfaceCommon.MenuProfileEditDifficulty";
            break;
        
        case EPS_Corrupt:
            nextMenuClass = "XInterfaceCommon.MenuCorruptContent";
            nextMenuArgs = MakeQuotedString(GetPlayerName());
            if(ValidProfileIndex())
            {
                // there exists a valid profile, so after corrupt message, allow selection of existing one
                nextMenuArgs = nextMenuArgs @ "SELECT_VALID";
            }
            break;
            
        case EPS_Valid:
        case EPS_InUse:
        default:
            assert(false);
    }

    CallMenuClass(nextMenuClass, nextMenuArgs);
}

simulated function OnOption(byte req)
{
    SavePosition();
    mProfileData.SetRequirements(req);
    if(ProfileDefined())
    {
        CallMenuClass(OptionDestinationMenu[Position]);
    }
    else
    {
        HandleUndefinedProfile();
    }
}

simulated function OnSinglePlayer()
{
    OnOption(mProfileData.cNeedName | mProfileData.cNeedDifficulty);
    // TODO: The player hasn't unlocked anything yet; kick them straight into chapter 1.
}

simulated function OnMultiplayer()
{
    OnOption(mProfileData.cNeedName);
}

simulated function OnSettings()
{
    OnOption(mProfileData.cNeedName);
}

simulated function OnProfile()
{    
    SavePosition();
    CallMenuClass(OptionDestinationMenu[Position]);
}

simulated function OnMiniEditor()
{
    SavePosition();
    mProfileData.SetRequirements(mProfileData.cNeedName);
    if(ProfileDefined())
    {
	    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
	    class'GameEngine'.default.DisconnectMenuArgs = "";
	    class'GameEngine'.static.StaticSaveConfig();
        PlayerController(Owner).ConsoleCommand( "REBOOTMINIED" );
    }
    else
    {
        HandleUndefinedProfile();
    }
}

function OnQuit()
{
    CallMenuClass( "XInterfaceCommon.MenuQuit" );
}

simulated function HandleInputBack();

// sneaky... insert the new menu between self and next
simulated function InsertMenuClassBetween( String MenuClassName, Menu next, optional String Args )
{
    local MenuBase m;
	assert(MenuClassName!="");
    m = Spawn( class<MenuBase>( DynamicLoadObject( MenuClassName, class'Class' ) ), Owner );
    m.PreviousMenu = self;
    PlayerController(Owner).Player.Console.PrevMenu = self;
    next.PreviousMenu = m;
    m.CrossFadeLevel = 0;
    m.Init(Args);
}

simulated function DoneSave()
{
    local Menu top;
    local Menu m;
    local Menu p;
    local bool insert;
       
    top = PlayerController(Owner).Player.Console.CurMenu;
    if(!top.IsA('MenuProfileSaving'))
    {
        return;
    }
    
    insert = true;
    m = top.PreviousMenu;
    while(m != self)
    {
        assert(m != None);
        if(m.IsA('MenuProfileMain') || m.IsA('MenuProfileEdit')) //hacky hacky
        {
            insert = false;
            top.PreviousMenu = m;
            break;
        }
        p = m.PreviousMenu;
        m.Destroy();
        m = p;
    }
    
    assert(Position >= 0 && Position <= 4);
       
    if(Position == 2) //hacky: mini-ed 
    {
        assert(OptionDestinationMenu[Position] == "MINIED");
        top.PreviousMenu = self;
    }
    else if(insert)
    {
        InsertMenuClassBetween(OptionDestinationMenu[Position], top);
    }
    
    UpdateProfileData();
}

simulated function bool MenuClosed(Menu closingMenu)
{
    log(self@" closingMenu="$closingMenu);
    
    if(closingMenu.IsA('MenuProfileMain') || closingMenu.IsA('MenuProfileLoading'))
    {
        UpdateProfileData();
    }

    return(true);
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Single Player"),HelpText="Play the single player campaign.",OnSelect="OnSinglePlayer",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Multiplayer"),HelpText="Play online or against bots.",OnSelect="OnMultiplayer")
     Options(2)=(Blurred=(Text="Map Editor"),HelpText="Create your own maps.",OnSelect="OnMiniEditor")
     Options(3)=(Blurred=(Text="Settings"),HelpText="Adjust game settings.",OnSelect="OnSettings")
     Options(4)=(Blurred=(Text="Profiles"),HelpText="Manage your profiles.",OnSelect="OnProfile")
     Options(5)=(Blurred=(Text="Quit"),HelpText="Exit the game.",OnSelect="OnQuit",Platform=MWP_PC)
     AttractModeLayer=(MenuClassName="XInterfaceCommon.MenuAttractMode",Pass=10)
     OptionDestinationMenu(0)="XInterfaceCommon.MenuSinglePlayer"
     OptionDestinationMenu(1)="XInterfaceMP.MenuMultiplayerMain"
     OptionDestinationMenu(2)="MINIED"
     OptionDestinationMenu(3)="XInterfaceSettings.MenuSettingsMain"
     OptionDestinationMenu(4)="XInterfaceCommon.MenuProfileMain"
     NoProfileLoadedText="Please select a profile"
     mValidProfileIndex=-1
     MenuTitle=(Text="Main Menu")
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
