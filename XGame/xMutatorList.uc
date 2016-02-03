class xMutatorList extends Actor
    DependsOn(xUtil);

var() array<xUtil.MutatorRecord> MutatorList;

simulated function Init(optional bool bLoadClasses)
{
    local xUtil.MutatorRecord tmp;
    local int i, j;

    class'xUtil'.static.GetMutatorList(MutatorList);

    // removed non-owned reward mutators for SP
    for (i=0; i<MutatorList.Length; i++)
    {
        if (!AllowMutator(MutatorList[i]))
        {
            MutatorList.Remove(i,1);
            i--;
        }
    }

    // sort by name
    for (i=0; i<MutatorList.Length-1; i++)
    {
        for (j=i+1; j<MutatorList.Length; j++)
        {
            if (MutatorList[j].FriendlyName < MutatorList[i].FriendlyName)
            {
                tmp = MutatorList[i];
                MutatorList[i] = MutatorList[j];
                MutatorList[j] = tmp;
            }
        }
    }

    if (bLoadClasses)
        LoadClasses();
}

simulated function LoadClasses()
{
    local int i;

    for (i=0; i<MutatorList.Length; i++)
	{
		assert(MutatorList[i].ClassName!="");
        MutatorList[i].MutClass = class<Mutator>(DynamicLoadObject(MutatorList[i].ClassName,class'Class'));
	}
}

simulated function bool AllowMutator(xUtil.MutatorRecord Mut)
{
    return( Mut.SinglePlayerOnly == 0 );
}

defaultproperties
{
}
