class xMasterBotList extends Object;

const mNumRaces = 6;

var() array<xUtil.PlayerRecord>     mCharInfo;
var() xBotPlayerList                mBotNames[mNumRaces];
var() int                           mNumNames;

function Created()
{
    class'xUtil'.static.GetPlayerList(mCharInfo);
}

function Init(int allowedINTs)
{
    local int i;

    for (i=0; i<mNumRaces; i++)
    {
        mBotNames[i] = new class'xBotPlayerList';  // sjs[sg]
    }

    for (i=0; i<mCharInfo.Length; i++)
    {
        if ((mCharInfo[i].Source & allowedINTs) == 0)
            continue;

        if (mCharInfo[i].Species == SPECIES_None)
        {
            log(self$" species is none, index="$i);
            continue;
        }

        mBotNames[int(mCharInfo[i].Species)].AddCharInfo(mCharInfo[i], i);
    }

    for (i=0; i<mNumRaces; i++)
    {
        mNumNames += mBotNames[i].maNames.Length;
        mBotNames[i].Init(0);
    }
}

function bool AllUsed()
{
    local int teamIdx;
    local bool bAllUsed;

    bAllUsed = true;

    for (teamIdx=0; teamIdx<mNumRaces; teamIdx++)
    {
        bAllUsed = bAllUsed && mBotNames[teamIdx].mbAllUsed;
        if (!bAllUsed)
            break;
    }

    return bAllUsed;
}

defaultproperties
{
}
