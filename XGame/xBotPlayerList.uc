class xBotPlayerList extends xNameList;

var() xNameList  mRaceSpecificTeamNames;
var() array<int> mMasterListIndicies;

function Created()
{
}

function Init(int options)
{
    Super.Created();
}

function int GetPlayerRecordIndex(int index)
{
    return mMasterListIndicies[index];
}

function AddCharInfo(xUtil.PlayerRecord p, int masterListIndex)
{
    maNames[maNames.Length] = p.DefaultName;
    mMasterListIndicies[mMasterListIndicies.Length] = masterListIndex;
}

defaultproperties
{
     mDefaultName="XGame.xPawn"
}
