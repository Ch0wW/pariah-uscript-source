class xNameList extends Object
    abstract;


var() localized array<string>   maNames;
var() localized string          mDefaultName;
var() transient array<int>      maUsed;
var() bool                      mbUniqueOnly;
var() bool                      mbAllUsed;
var() int                       mNumUsed;


function Init(int options);

function Created()
{
    local int i;
    for (i=0; i<maNames.Length; i++)
        maUsed[i] = 0;
}

function int GetRandomName(out string s, bool useit) //always use!
{
    local int rnd;

    if (mbAllUsed || maNames.Length==0)
    {
        s = mDefaultName;
        return -1;
    }

    rnd = Rand(maNames.Length);

    if (mbUniqueOnly)
    {
        CheckUnique(rnd);
        
        if (useit)
            UseName(rnd);
    }

    s = GetName(rnd);

    return rnd;
}

function string GetName(int index)
{
    return maNames[index];
}

function CheckUnique(out int rnd)
{
    for (rnd=rnd; rnd<maNames.Length; rnd++)
    {
        if (!IsUsed(rnd))
            return;
    }

    rnd = 0;
    CheckUnique(rnd);
}

function bool IsUsed(int i)
{
    return (maUsed[i] == 1);
}

function RemoveName(int index)
{
    maNames.Remove(index, 1);
    maUsed.Remove(index, 1);
}

function UseName(int i)
{
    assert(ValidName(i));
    assert(!mbAllUsed);

    if (mbUniqueOnly)
        assert(!IsUsed(i));

    mNumUsed++;
    maUsed[i] = 1;

    mbAllUsed = true;
    for (i=0; i<maNames.Length; i++)
    {
        if (maUsed[i] == 0)
        {
            mbAllUsed = false;
            break;
        }
    }
}

function bool ValidName(int i)
{
    return (i >= 0 && i < maNames.Length);
}

function int FindName(string s)
{
    local int i;

    for (i=0; i<maNames.Length; i++)
        if (s ~= maNames[i])
            return i;

    return -1;
}

function int UseNextName()
{
    local int i;

    assert(!mbAllUsed);

    for (i=0; i<maNames.Length; i++)
    {
        if (!IsUsed(i))
        {
            UseName(i);
            return i;
        }
    }

    assert(false);
}

defaultproperties
{
     mDefaultName="NoName"
     mbUniqueOnly=True
}
