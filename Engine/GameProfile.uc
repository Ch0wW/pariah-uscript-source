class GameProfile extends Object
	native;

// rename GameProfile -> SavedGameData

const MaxStrLen = 15;
const MaxSPLevels = 18;

enum ESessionMode
{
    ESM_None,           // not set
    ESM_Resume,         // normal mode, play from current checkpoint with saving
    ESM_Overwrite,      // overwrite real save, then continue in resume mode
    ESM_Replay,         // replay specified level without saving
    ESM_ContinueWoS,    // almost replay, but whole profile is without saving (temp save only)
};

var private string                  mName;
var private string                  mProgress;
var private int                     mUnlockedChapter; // may be different from progress (replay old or cheating)
var private int                     mSavePoint;
var private int                     mDifficultyIndex;
var private SavedPlayerData         mResumePlayerData;
var private SavedPlayerData         mLevelStartPlayerData[MaxSPLevels];
var private string                  mSavedPlayerClass;
var private int                     mNumPlayers;
var private transient ESessionMode  mSessionMode;
var private const string            mResume;
var private const string            mOverwrite;
var private const string            mReplay;
var private const string            mContinueWoS;
var private transient string        mNextURL;
var private transient bool          mSavingLevelStartPlayerData;


// called from native code before saving
event Update(GameInfo game)
{
    local SavedPlayerData pd;
    local bool overwrite;
    
    if(mSessionMode == ESM_Overwrite)
    {
        // return to resume mode
        mSessionMode = ESM_Resume;
        overwrite = true;
    }

    if(!(mSessionMode == ESM_Resume || ContinueWithoutSaving(game)))
    {
        return;
    }

    mNumPlayers = Clamp(game.Level.GetLocalPlayerCount(), 1, 2);

    log(self$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Update!!!! mSavePoint="$mSavePoint);
    log(self$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Update!!!! mNumPlayers="$mNumPlayers);

    // this is a beginning of chapter save to save the start inv
    if(mSavingLevelStartPlayerData)
    {
        mSavingLevelStartPlayerData = false;
        pd = GetStartPlayerData(string(game.XLevel.Outer.Name));

        log(pd$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Update!!!!");

        pd.Update(game, mNumPlayers);
        
        // overwrite should fall-through and overwrite the resume data with the start data
        if(!overwrite)
        {
            return;
        }
    }
    
    // update the saved checkpoint inventory
    // this is where the resume data is overwriten for the overwrite mode
    // SP_LEVEL will be overwritten next checkpoint
    mResumePlayerData.Update(game, mNumPlayers);
}
    
// 
simulated function bool ContinueWithoutSaving(Actor a)
{
    return("" != a.ConsoleCommand("LOADSAVE CONTINUE_WITHOUT_SAVING CURRENT=1"));
}

// should this checkpoint save
simulated function bool ShouldSave()
{
    return(mSessionMode == ESM_Resume || mSessionMode == ESM_Overwrite);
}

// TODO: shouldn't really need this: should incr mSavePoint on Update call,
// but currently can't trust that it is only called when needed!
simulated function SaveProgress()
{
    if(ShouldSave())
    {
        ++mSavePoint;
        log(self$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ SaveProgress!!!! mSavePoint="$mSavePoint);
    }
}

// return true if something was modified (ie GameProfile setup the inventory)
simulated function bool SetupInventory(PlayerController PC, GameInfo game)
{
    local SavedPlayerData pd;
    local bool cWoS;
    
	// TODO: in replay mode, need to restore saved inventory from temp gameprofile
    
    // continue without saving?
    cWoS = ContinueWithoutSaving(game);

    log(self$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ SetupInventory!!!! cWoS="$cWoS);
    
    // for resume or cWoS, use the saved checkpoint inventory
    if(mSessionMode == ESM_Resume || cWoS)
    {
        return(mResumePlayerData.SetupInventory(PC, game, mNumPlayers));
    }

    // for play/overwrite, use the saved starting inventory
    pd = GetStartPlayerData(string(game.XLevel.Outer.Name));

    log(pd$" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ SetupInventory!!!!");

    return(pd.SetupInventory(PC, game, mNumPlayers));
}

simulated function bool SavePlayerData(LevelInfo level)
{
    //local bool travelSplit;
    local int playerCount;
    
    log(self$" level="$level);
    
    playerCount = Clamp(level.GetLocalPlayerCount(), 1, 2);
    
    log(self$" playerCount="$playerCount);
    log(self$" mNumPlayers="$mNumPlayers);
    
    //travelSplit = bool(level.ConsoleCommand("LOADSAVE TRAVEL_SPLIT"));

    //log(self$" travelSplit="$travelSplit);
    
    mSavingLevelStartPlayerData = (mSavePoint == 0) && ShouldSave() && (playerCount == mNumPlayers);
    
        //((!travelSplit && mNumPlayers == 1) || (travelSplit && mNumPlayers == 2));
    
    log(self$" @@@@@@@@@@2 SavePlayerData mSessionMode="$mSessionMode);
    log(self$" @@@@@@@@@@2 SavePlayerData mSavePoint="$mSavePoint);
    log(self$" @@@@@@@@@@2 mSavingLevelStartPlayerData="$mSavingLevelStartPlayerData);
    
    return(mSavingLevelStartPlayerData);
}

// sets the mode for this session
event SetSessionMode(string mode)
{
    switch(mode)
    {
        case mResume:
            mSessionMode = ESM_Resume;
            break;
        case mOverwrite:
            mSessionMode = ESM_Overwrite;
            break;
        case mReplay:
            mSessionMode = ESM_Replay;
            break;
        case mContinueWoS:
            mSessionMode = ESM_ContinueWoS;
            break;
        default:
            assert(false);
            break;
    }
    log("SetSessionMode mode="$mode);
    log("SetSessionMode mSessionMode="$mSessionMode);
}

// update progress, and change mode to resume to allow saving
event OverwriteProgress(string newChapter)
{
    assert(mSessionMode == ESM_Overwrite);
    SetProgress(newChapter); 
}

simulated function string GetName()
{
    return(mName);
}

// means that we hit at least one savepoint in the current map, and therefore
// the map won't start at it's beginning when resuming play
simulated function bool MidwaySavePoint()
{
    return(mSavePoint > 0);
}

// return the current chapter number [1-18]
simulated function int GetCurrentChapterNumber()
{
    return(GetChapterNumber(mProgress));
}

// return the unlocked chapter number [1-18]
simulated function int GetUnlockedChapterNumber()
{
    return(mUnlockedChapter);
}

// get/set the difficulty index
simulated function int GetDifficultyIndex()
{
    return(mDifficultyIndex);
}

simulated function SetDifficultyIndex(int diffIndex)
{
    mDifficultyIndex = diffIndex;
}

// get the launch URL
simulated function string GetNextURL(string levelName, optional ESessionMode mode)
{
    assert(levelName != "");
   
    if(mode == ESM_None)
    {
        mode = mSessionMode;
    }
    log("mode="$mode);
    
    mNextURL = StripSuffix(levelName);
    
    AddOption("Game", "PariahSP.SinglePlayer");
    AddOption("Name", mName);
    AddOption("SaveGame", mName);
    if(mode != ESM_None)
    {
        AddOption("SessionMode", GetSessionMode(mode));
    }
    AddOption("Hints", "1");

    `log("GameProfile: mNextURL="$mNextURL);

    return mNextURL;
}

simulated function bool ChangeLevel(GameInfo game, string nextChapter)
{
    // TODO: in replay mode, need to save inventory to temp gameprofile
    return(ContinueWithoutSaving(game) || SetProgress(nextChapter));
}

// set the next chapter, return value indicates if save is needed
// can go "back in time" if overwriting
simulated function bool SetProgress(string nextChapter)
{
    local int progressChapter;
    if(ShouldSave())
    {
        mProgress = nextChapter;
        mSavePoint = 0;
        progressChapter = GetChapterNumber(mProgress);
        
        // unlocked chapter could be > due to cheats
        if(progressChapter > mUnlockedChapter)
        {
            mUnlockedChapter = progressChapter;
        }
        
        return(true);
    }
    return(false);
}

simulated function LogSavedData()
{
    local int i;
    
    `log(" LogSavedData... mName="$mName);
    `log(" LogSavedData... mProgress="$mProgress);
    `log(" LogSavedData... mSavePoint="$mSavePoint);
    `log(" LogSavedData... mDifficultyIndex="$mDifficultyIndex);
    `log(" LogSavedData... mSessionMode="$mSessionMode);
    `log(" LogSavedData... mNextURL="$mNextURL);
    
    // log saved player data
    mResumePlayerData.LogSavedData(mNumPlayers);
    for(i = 0; i < MaxSPLevels; ++i)
    {
        mLevelStartPlayerData[i].LogSavedData(mNumPlayers);
    }

    `log(" DONE LogSavedData ");
}

// cheat
simulated function UnlockChapters()
{
    mUnlockedChapter = MaxSPLevels;
}

// return the number [1 to MaxSPLevels] that represents the chapter
simulated static function int GetChapterNumber( String FileName )
{
    local String expectedPrefix;
    local string number;
    local string prefix;

    expectedPrefix = "SP-CHAPTER_";
    
    prefix = Left(FileName, 11);
    number = Right(FileName, 2);

    //log(self$" prefix="$prefix);
    //log(self$" number="$number);

    assert(prefix ~= expectedPrefix);
  
    if(InStr(number, "0") == 0)
    {
        number = Right(number, 1);
    }
    
    return(int(number));
}

simulated static function string GetChapterEntry( String FileName, String LongFileName )
{
    return(GetChapterNumber(FileName) @ "-" @ LongFileName);
}

// remove the map extension
simulated private function string StripSuffix( string inString )
{
	local int l;

	// search backwards for period
	//
	l = Len( inString ) - 1;
	while ( l >= 0 )
	{
		if ( Mid( inString, l, 1 ) == "." )
		{
			break;
		}
		l--;
	}
	if ( l > 0 )
	{
		return Left( inString, l );
	}
	else
	{
		return inString;
	}
}

simulated private function AddOption(string key, string value)
{
    mNextURL = mNextURL $ "?" $ key $ "=" $ value;
}

//simulated private function string CapStringLen(string s, optional string version)
//{
//    s = s $ version;
//    if (Len(s) <= MaxStrLen)
//        return s;
//    return Left(s, MaxStrLen - Len(version)) $ version;
//}

simulated private function string GetSessionMode(ESessionMode mode)
{   
    local string ret;
    switch(mode)
    {
        case ESM_Resume:
            ret = mResume;
            break;
        case ESM_Overwrite:
            ret = mOverwrite;
            break;
        case ESM_Replay:
            ret = mReplay;
            break;
        case ESM_ContinueWoS:
            ret = mContinueWoS;
            break;
        default:
            assert(false);
            break;
    }
    return(ret);
}

simulated private function SavedPlayerData GetStartPlayerData(string chapterName)
{
    local int chapterIndex;
    
    chapterIndex = -1 + GetChapterNumber(chapterName);
    assert(chapterIndex >= 0);
    assert(chapterIndex < MaxSPLevels);
    
    return(mLevelStartPlayerData[chapterIndex]);
}

defaultproperties
{
     mUnlockedChapter=1
     mDifficultyIndex=-1
     mNumPlayers=1
     mProgress="SP-Chapter_01"
     mSavedPlayerClass="PariahSP.PariahSavedPlayerData"
     mResume="Resume"
     mOverwrite="Overwrite"
     mReplay="Replay"
     mContinueWoS="ContinueWoS"
}
