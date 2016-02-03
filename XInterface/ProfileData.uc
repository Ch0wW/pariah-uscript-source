class ProfileData extends Object
    native;

// This data will be used to create a profile, it is lazily defined as req'd
var private string          mName;
var private int             mDifficulty;        // TODO: what is the valid range here: [0-3] ?

// What requires definition for the current menu selection (SP/MP/Settings)?
const                       cNeedName       = 1;
const                       cNeedDifficulty = 2;
const                       cNeedAll        = 3;
var private byte            mRequirements;

// Initialized?
var private bool            mDataInit; 
var private bool            mModeInit; 

// new or existing profile?
var private bool            mNewProfile;

// name of the callback 
var private string          mDoneSaveCallback;
var private Object          mDoneSaveCallbackObject;

// full disk?
var private bool            mContinueWithoutSaving;


// Initialization - for new Profiles
simulated function InitNew(string doneSaveCallback, Object doneSaveCallbackObj)
{
    log(self@" InitNew!");

    Reset();
    mNewProfile = true;
    mDataInit = true;
    mDoneSaveCallback = doneSaveCallback;
    mDoneSaveCallbackObject = doneSaveCallbackObj;
    LogProfileData();
}

// Initialization - for existing Profiles

// I can't believe how ass this is!
simulated function InitExisting
(
    MenuBase menu, 
    string currentProfileName, 
    string doneSaveCallback,
    Object doneSaveCallbackObj
)
{   
    local MenuBase.EProfileState profileState;
    local GameProfile gProfile;

    //log(self@" InitExisting!");
    
    assert(menu != None);
    gProfile = menu.GetCurrentGameProfile();
    assert(gProfile != None);
    
    Reset();
    
    mName = currentProfileName;
    mDifficulty = gProfile.GetDifficultyIndex();
    
    mDataInit = true;
    mDoneSaveCallback = doneSaveCallback;
    mDoneSaveCallbackObject = doneSaveCallbackObj;

    LogProfileData();
    
    // don't allow invalid names
    profileState = menu.GetProfileState(currentProfileName);
    //log(self@"profileState="$profileState); 
    assert(profileState == EPS_Valid || profileState == EPS_Loaded);      
}          

// debugging
simulated function LogProfileData()
{
    return;
    log(self@" mName="$mName);
    log(self@" mDifficulty="$mDifficulty);
    log(self@" mRequirements="$mRequirements);
    log(self@" mDataInit="$mDataInit);
    log(self@" mModeInit="$mModeInit);
    log(self@" mNewProfile="$mNewProfile);
    log(self@" mDoneSaveCallback="$mDoneSaveCallback);
    log(self@" mDoneSaveCallbackObject="$mDoneSaveCallbackObject);
}

// Clean up
simulated function Reset()
{   
    //log(self@" Reset!!!");

    mName                   = "";
    mDifficulty             = default.mDifficulty;
    mRequirements           = 0;
    mDataInit               = false;
    mModeInit               = false;
    mNewProfile             = false;
    mDoneSaveCallback       = "";
    mDoneSaveCallbackObject = None;
}


// Set the requirements based on the menu selection
simulated function SetRequirements(byte req)
{   
    mRequirements = req;
    mModeInit = true;
}


// accessors - yes, there can be privacy in UnrealScript!
simulated function bool DefineName()
{
    assert(mModeInit);
    return(bool(mRequirements & cNeedName));
}

simulated function bool DefineDifficulty()
{
    assert(mModeInit);
    return(bool(mRequirements & cNeedDifficulty));
}

simulated function string Name(optional string newName)
{
    if(newName != "")
    {
        mName = newName;
    }
    else
    {
        assert(mDataInit);
    }
    return(mName);
}

simulated function int Difficulty(optional string newDifficulty)
{
    local int diff;
    if(newDifficulty != "")
    {
        diff = int(newDifficulty);
        if(diff >= 0)
        {
            mDifficulty = diff;
        }
    }
    else
    {
        assert(mDataInit);
    }
    return(mDifficulty);
}

simulated function string DoneSaveCallback(optional string callbackName)
{
    if(callbackName != "")
    {
        mDoneSaveCallback = callbackName;
    }
    else
    {
        assert(mDataInit);
    }
    return(mDoneSaveCallback);
}

simulated function Object DoneSaveCallbackObject(optional Object callbackObj)
{
    if(callbackObj != None)
    {
        mDoneSaveCallbackObject = callbackObj;
    }
    else
    {
        assert(mDataInit);
    }
    return(mDoneSaveCallbackObject);
}

simulated function bool NewProfile()
{
    assert(mDataInit);
    return(mNewProfile);
}

simulated function bool ContinueWithoutSaving(optional string newCWoS)
{
    if(newCWoS != "")
    {
        mContinueWithoutSaving = bool(newCWoS);
    }
    else
    {
        assert(mDataInit);
    }
    //log(self$" @@@@@@@@@@@@@@@@@@@@ mContinueWithoutSaving="$mContinueWithoutSaving);
    return(mContinueWithoutSaving);
}


// helpers
simulated function bool ValidName() 
{
    assert(mDataInit);
    return(mName != "");
}

simulated function bool ValidDifficulty() 
{
    assert(mDataInit);
    return(mDifficulty >= 0);
}

simulated function bool Initialized()
{
    return(mDataInit);
}

simulated function bool NeedName()
{
    assert(Initialized());
    return(DefineName() && !ValidName());
}

simulated function bool NeedDifficulty()
{
    assert(Initialized());
    return(DefineDifficulty() && !ValidDifficulty());
}

// Is everything that needs definition defined?
simulated function bool AllDefined()
{
    assert(Initialized());
    return(!NeedName() && !NeedDifficulty());
}

simulated private function string AppendContinueWithoutSaving()
{
    if(mContinueWithoutSaving)
    {
        return("CONTINUE_WITHOUT_SAVING=1");
    }
    return("");
}


// save data
simulated function Save(MenuBase menu)
{
    local GameProfile gProfile;
    
    LogProfileData();

    assert(AllDefined());   
    
    if(mNewProfile)
    {
        log(self@" create new save game...");        
        
        // create a new save game
        if
        (
            !bool
            (
                menu.LoadSaveCommand
                (
                    "CREATE", 
                    "NAME=" $ mName @ 
                    "DIFFICULTY=" $ mDifficulty @
                    AppendContinueWithoutSaving()
                )
            )
        )
        {
            warn("Cannot create save game");
            return;
        }
    }
    else
    {
        log(self@" updating existing save game...");        
        
        if(DefineName())
        {
	        //UpdateURL("Name", n, true);
            //menu.LoadSaveCommand("RENAME", "NEWNAME=" $ mName );
            //pc.UpdatePlayer(mName);
        }

        gProfile = menu.GetCurrentGameProfile();
        assert(gProfile != None);
        
        if(DefineDifficulty())
        {
            gProfile.SetDifficultyIndex(mDifficulty);
        }
        
        menu.UpdateGameProfile();
    }
}

defaultproperties
{
     mDifficulty=-1
}
