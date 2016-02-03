//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
	abstract;

struct MapEntry
{
    var() String MapName;
    var() int bSelected;
};

var(Maps) config array<MapEntry> MapEntries;
var(Maps) config int CurrentMapIndex;

// When Spawned, removed any list entry that are empty
event Spawned()
{
    local int i;
    local bool bDirty;

	bDirty = false;

	for( i = 0; i < MapEntries.Length; ++i )
	{
		if( MapEntries[i].MapName == "" )
		{
			MapEntries.Remove(i, 1);
			i--;
			bDirty = true;
		}
	}

	if( bDirty )
	{
		SaveConfig();
		Log("MapList had invalid entries!", 'Error');
	}
}

function GetAllMaps(out String s) // sjs
{
    local int i;

    s = "";
    
	for( i = 0; i < MapEntries.Length; ++i )
    {
        if( i == 0 )
        {
            s = MapEntries[i].MapName;
        }
        else
        {
            s = s $ "," $ MapEntries[i].MapName;
        }
    }
}

function String GetFirstMap()
{
    local int i;
    
    // Find first map in queue that is selected:
    
	for( i = 0; i < MapEntries.Length; ++i )
	{
	    if( bool(MapEntries[(CurrentMapIndex + i) % (MapEntries.Length)].bSelected) )
	    {
	        return(MapEntries[(CurrentMapIndex + i) % (MapEntries.Length)].MapName);
	    }
	}

    log("Could not find a selected map in cycle!", 'Error');
	return("");
}

function String GetNextMap()
{
	local String CurrentMap;
	local int i;
    local String Extension;
    local int ExtensionLen;
    
    Extension = ".prh";
    ExtensionLen = Len(Extension);
    
	CurrentMap = GetURLMap();
	
	if( Level.IsCustomMap() )
	{
	    CurrentMap = CurrentMap $ "?custommap=" $ Level.GetCustomMap();
	}
	
	if( Right(CurrentMap, ExtensionLen) ~= Extension )
	{
	    CurrentMap = Left(CurrentMap, Len(CurrentMap) - ExtensionLen);
	}
	
	if( CurrentMap != "")
	{
	    // Find it in the list and advance it accordingly:
	
	    for( i = 0; i < MapEntries.Length; ++i )
		{
			if( CurrentMap ~= MapEntries[i].MapName )
			{
			    CurrentMapIndex = i;
				break;
			}
		}
		
		if( i == MapEntries.Length )
		{
		    log("Could not find" @ CurrentMap @ "in map list!", 'Error');
		}
	}

	CurrentMapIndex = (CurrentMapIndex + 1) % (MapEntries.Length);

    // Find next map in queue that is selected:
    
	for( i = 0; i < MapEntries.Length; ++i )
	{
	    if( bool(MapEntries[(CurrentMapIndex + i) % (MapEntries.Length)].bSelected) )
	    {
	        CurrentMapIndex = (CurrentMapIndex + i) % (MapEntries.Length);
	    
	        CurrentMap = MapEntries[CurrentMapIndex].MapName;
	        SaveConfig();
	        return(CurrentMap);
	    }
	}

    log("Could not find next map in cycle!", 'Error');
	return(CurrentMap);
}

function bool MapIsSelected( String MapName )
{
    local int i;

	for( i = 0; i < MapEntries.Length; ++i )
	{
        if( (MapEntries[i].MapName ~= MapName) && bool(MapEntries[i].bSelected)  )
        {
            return(true);
        }
    }
    
    return(false);
}

function bool MapIsKnown( String MapName )
{
    local int i;

    for( i = 0; i < MapEntries.Length; ++i )
    {
        if( MapEntries[i].MapName ~= MapName )
        {
            return(true);
        }
    }
    
    return(false);
}

function AddMap( String MapName, bool bSelected, bool bAtFront )
{
    local int i;

    for( i = 0; i < MapEntries.Length; ++i )
    {
        if( MapEntries[i].MapName ~= MapName )
        {
            MapEntries[i].bSelected = int(bSelected);
            return;
        }
    }

    if( bAtFront )
    {
        MapEntries.Insert(0,1);
        i = 0;
    }
    else
    {
        i = MapEntries.Length;
    }
    
    MapEntries[i].MapName = MapName;
    MapEntries[i].bSelected = int(bSelected);
}

function SelectExclusive( String MapName )
{
    local int i;
    local bool found;

    for( i = 0; i < MapEntries.Length; ++i )
    {
        if( MapEntries[i].MapName ~= MapName )
        {
            MapEntries[i].bSelected = 1;
            CurrentMapIndex = i;
            found = true;
        }
        else
        {
            MapEntries[i].bSelected = 0;
        }
    }

    if( !found )
    {
        log("Adding unknown map" @ MapName, 'Log');

        i = MapEntries.Length;
        
        MapEntries[i].MapName = MapName;
        MapEntries[i].bSelected = 1;
        CurrentMapIndex = i;
    }
}

function Clear()
{
    MapEntries.Remove( 0, MapEntries.Length );
    CurrentMapIndex = 0;
}

function bool IsEmpty()
{
    local int i;

    for( i = 0; i < MapEntries.Length; ++i )
    {
        if( bool(MapEntries[i].bSelected) )
        {
            return(false);
        }
    }
    
    return(true);
}

defaultproperties
{
}
