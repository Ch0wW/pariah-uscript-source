// ====================================================================
//  Class:  XAdmin.SortedStringArray
//  Parent: XAdmin.StringArray
//
//  Sorted list - sorts based on tag
// ====================================================================

class SortedStringArray extends StringArray;

function int Add(string item, string tag, optional bool bUnique)
{
local int pos;

	pos = FindTagId(tag);

	if (pos < 0)
		return InsertAt(-pos-1, item, tag);
	else if (bUnique)
		return pos;
	else
		return InsertAt(pos, item, tag);
}

function int FindTagId(string Tag)
{
local int sz, min, max, pos;
    sz = AllItems.Length - 1;
    if (sz < 0 || IsBefore(Tag, AllItems[0].tag))
        return -1;

	if (Tag ~= AllItems[0].Tag)
		return 0;

	if (Tag ~= AllItems[sz].Tag)
		return sz;

	if (sz == 1)
		return -3;

	// Add tag to end of list
    if (!IsBefore(Tag,AllItems[sz].tag))
	    return (-(sz+1))-1;

    // Find the position of insertion
    max = sz;
    pos = sz;
    do {
        if (tag ~= AllItems[pos].tag)
            return pos;
        if (IsBefore(Tag,AllItems[pos].tag))
            max = pos;
        else min = pos;

        pos = (min + max)/2;
    } until (max-min < 2);
    if (pos == 0)
		return 1;

    return -pos-2;
}

defaultproperties
{
}
