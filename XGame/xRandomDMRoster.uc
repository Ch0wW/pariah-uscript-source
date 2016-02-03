class xRandomDMRoster extends DMRoster
    DependsOn(xUtil);

var class<xMasterBotList>   mMasterBotListClass;
var xMasterBotList          mMasterBotList;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    InitBotList();
}

function Destroyed()
{
    mMasterBotList = None;
    Super.Destroyed();
}

function InitBotList()
{
    local int i;
    local xUtil.EINTPresets preset;

    preset = EIP_L123;
    if (GetCurrentGameProfile() == None)
        preset = EIP_L123AndExt;

    // Init roster with rosterentrys
    mMasterBotList = new mMasterBotListClass;  // sjs[sg]
    mMasterBotList.Init(class'xUtil'.static.AllowedINTs(preset));

    for (i=0; i<mMasterBotList.mNumNames; i++)
    {
        Roster[i] = RandomRosterEntry();
    }
}

function xRosterEntry RandomRosterEntry()
{
    local xRosterEntry xre;
    local int teamIdx;
    local int nameIdx;
    local string plrName;
    local int prIdx;

    if (mMasterBotList.AllUsed())
    {
        log("RandomRosterEntry(): All players used", 'Error');
        return None;
    }

    do 
    {
        teamIdx = Rand(mMasterBotList.mNumRaces);
		nameIdx = mMasterBotList.mBotNames[teamIdx].GetRandomName(plrName,true);
    } 
    until (nameIdx != -1)
	
    prIdx = mMasterBotList.mBotNames[teamIdx].GetPlayerRecordIndex(nameIdx);

    xre = class'xRosterEntry'.static.CreateRosterEntry(prIdx, new(Level) class'xRosterEntry');  // sjs[sg]

    return xre;
}

function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	return true;
}

defaultproperties
{
     mMasterBotListClass=Class'XGame.xMasterBotList'
}
