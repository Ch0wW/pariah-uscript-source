//-----------------------------------------------------------
//
//-----------------------------------------------------------
class xMapLists extends Info;

struct GameList
{
	var() string GameType;
	var() int Active;
};

struct xMapList
{
	var() int			Current;
	var() string 		GameType;
	var() string 		Title;
	var() array<string> Maps;
};

var() protected config array<GameList> GameRecords;
var() protected config array<xMapList> MapRecords;

var() localized string DefaultListName;
var() localized string InvalidGameType;
var() localized string ReallyInvalidGameType;
var() localized string DefaultListExists;

struct CustomMapList
{
	var GameList 		GameRec;
	var array<xMapList> MapLists;
};
var protected array<CustomMapList> AllLists;

event PreBeginPlay()
{
	local int i, j, k;
	local string GameName;
	local bool bValid;

	Super.PreBeginPlay();

	GameName = Level.GetNextInt("Engine.GameInfo", i++);
	while (GameName != "")
	{
		// Could actually load game class
		bValid = class<GameInfo>(DynamicLoadObject(GameName, class'Class')) != None;
		for (j = 0; j < GameRecords.Length; j++)
		{
			// already have a game record for this gametype
			if (GameName ~= GameRecords[j].GameType)
			{
				if (bValid)
					break;
				else
				{
					// this gametype was removed from server
					log(GameName@InvalidGameType);
					for (k = 0; k < MapRecords.Length; k++)
					{
						if (MapRecords[k].GameType ~= GameRecords[j].GameType)
							MapRecords.Remove(k--,1);
					}
					GameRecords.Remove(j--,1);
					continue;
				}
			}
		}

		if (j == GameRecords.Length && bValid)
		{
			GameRecords.Length = GameRecords.Length + 1;
			GameRecords[j].GameType = GameName;
			CreateDefaultList(GameRecords[j].GameType);
		}

		GameName = Level.GetNextInt("Engine.GameInfo", i++);
	}
}

event PostBeginPlay()
{
	SaveConfig();
	InitGameLists();
	Super.PostBeginPlay();
}

//  Other classes only allowed to interact with AllLists array
function InitGameLists()
{
	local CustomMapList NewList;
	local int i;

	AllLists.Length = 0;
	for (i = 0; i < GameRecords.Length; i++)
	{
		NewList.GameRec = GameRecords[i];
		NewList.MapLists = GetAllMapLists(i);
		AllLists[AllLists.Length] = NewList;
	}
}

function bool ValidGameType(string GameType)
{
	local int i;

	for (i = 0; i < GameRecords.Length; i++)
	{
		if (GameType ~= GameRecords[i].GameType)
			return true;
	}

	return false;
}

function CreateDefaultList(string GameType)
{
	local class<GameInfo> GameClass;
	local string ListName;
	local array<string> Arr;

	GameClass = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
	if (GameClass != None)
	{
		ListName = DefaultListName @ GameClass.default.Acronym;
		Level.Game.LoadMapList(GameClass.default.MapPrefix, Arr);

		if (!AddList(GameType, ListName, Arr))
			Warn(DefaultListExists);
	}

	else warn(ReplaceTag(ReallyInvalidGameType, "gametype", GameType));
}

function bool AddList(string GameType, string NewName, array<string> Maps)
{
	local int i, j;
	local xMapList NewRecord;
	local class<GameInfo> GIClass;

	if (ValidGameType(GameType))
		NewRecord.GameType = GameType;
	else return false;

	//check that we aren't using this name already
	// If so, generate a unique name
	for (i = 0; i < MapRecords.Length; i++)
	{
		if (MapRecords[i].Title ~= NewName)
		{
			NewName = NewName $ string(j++);
			i = -1;
		}
	}

	NewRecord.Title = NewName;

	// Make sure new maplist always has maps
	if (Maps.Length == 0)
	{
		GIClass = class<GameInfo>(DynamicLoadObject(GameType,class'Class'));
		if (GIClass.default.MapPrefix == "")
			Maps = GetAllGametypeMaps();
		else Level.Game.LoadMapList(GIClass.default.MapPrefix, Maps);
	}
	NewRecord.Maps = Maps;
	MapRecords[MapRecords.Length] = NewRecord;

	i = GetGameIndex(GameType);
	if (i >= 0)
		AllLists[i].MapLists[AllLists[i].MapLists.Length] = NewRecord;

	SaveConfig();
	return true;
}

function bool RemoveList(int GameIndex, int MapListIndex)
{
	local int i;
	if (!ValidMapListIndex(GameIndex, MapListIndex))
		return false;

	i = GetMapRecordIndex(GameIndex,MapListIndex);
	AllLists[GameIndex].MapLists.Remove(MapListIndex, 1);
	MapRecords.Remove(i, 1);
	if (AllLists[GameIndex].MapLists.Length == 0)
		CreateDefaultList(AllLists[GameIndex].GameRec.GameType);
	SaveConfig();
}

function ResetList(int GameIndex, int MapListIndex)
{
	local int i;
	if (!ValidMapListIndex(GameIndex, MapListIndex))
		return;

	i = GetMapRecordIndex(GameIndex,MapListIndex);
	AllLists[GameIndex].MapLists[MapListIndex] = MapRecords[i];
}

function bool RenameList(int GameIndex, int MapListIndex, string NewName)
{
	local int i;
	if (!ValidMapListIndex(GameIndex, MapListIndex))
		return false;

	i = GetMapRecordIndex(GameIndex,MapListIndex);
	MapRecords[i].Title = NewName;
	InitGameLists();
	SaveConfig();
}

function bool ClearList(int GameIndex, int MapListIndex)
{
	if (!ValidMapListIndex(GameIndex, MapListIndex))
		return false;

	AllLists[GameIndex].MapLists[MapListIndex].Maps.Length = 0;
}

function bool AddMap(int GameIndex, int MapIndex, string MapName)
{
	local int i;

	if (ValidMapListIndex(GameIndex, MapIndex))
	{
		for (i = 0; i < AllLists[GameIndex].MapLists[MapIndex].Maps.Length; i++)
		{
			if (AllLists[GameIndex].MapLists[MapIndex].Maps[i] ~= MapName)
				return false;
		}

		AllLists[GameIndex].MapLists[MapIndex].Maps[i] = MapName;
		return true;
	}

	return false;
}

function bool RemoveMap(int GameIndex, int MapIndex, string MapName)
{
	local int i;

	if (ValidMapListIndex(GameIndex, MapIndex))
	{
		for (i = 0; i < AllLists[GameIndex].MapLists[MapIndex].Maps.Length; i++)
		{
			if (AllLists[GameIndex].MapLists[MapIndex].Maps[i] ~= MapName)
			{
				AllLists[GameIndex].MapLists[MapIndex].Maps.Remove(i,1);
				return true;
			}
		}
	}

	// didn't find it
	return false;
}

function int GetGameIndex(string GameType)
{
	local int i;

	for(i = 0; i < AllLists.Length; i++)
		if (AllLists[i].GameRec.GameType ~= GameType)
			return i;

	return -1;
}

function int GetMapListIndex(int GameIndex, string MapListName)
{
	local int i;

	if (!ValidGameIndex(GameIndex))
		return -1;

	for (i = 0; i < AllLists[GameIndex].MapLists.Length; i++)
		if (AllLists[GameIndex].MapLists[i].Title ~= MapListName)
			return i;

	return -1;
}

function string GetMapListTitle(int GameIndex, int MapIndex)
{
	if (ValidMapListIndex(GameIndex, MapIndex))
		return AllLists[GameIndex].MapLists[MapIndex].Title;

	return "";
}

function array<string> GetMapListNames(int GameIndex)
{
	local int i;
	local array<string> ListNames;

	if (ValidGameIndex(GameIndex))
	{
		for (i = 0; i < AllLists[GameIndex].MapLists.Length; i++)
			ListNames[ListNames.Length] = AllLists[GameIndex].MapLists[i].Title;
	}

	return ListNames;
}

function array<string> GetMapList(int GameIndex, int MapIndex)
{
	if (ValidMapListIndex(GameIndex, MapIndex))
		return AllLists[GameIndex].MapLists[MapIndex].Maps;
}

function int GetActiveList(int GameIndex)
{
	if (ValidGameIndex(GameIndex))
		return AllLists[GameIndex].GameRec.Active;

	return -1;
}

function bool SetActiveList(int GameIndex, int NewActive)
{
	if (!ValidMapListIndex(GameIndex, NewActive))
		return false;

	AllLists[GameIndex].GameRec.Active = NewActive;
	return true;
}

function bool ApplyMapList(int GameIndex, int NewList)
{
	local class<GameInfo> GameClass;
	local MapList List;
	local int i;

	if (ValidMapListIndex(GameIndex, NewList))
	{
		SetActiveList(GameIndex, NewList);
		SaveGame(GameIndex);
		GameClass = class<GameInfo>(DynamicLoadObject(GameRecords[GameIndex].GameType,class'Class'));
		if (GameClass != None && GameClass.Default.MapListType != "")
		{
			List = Level.Game.GetMapList(GameClass.Default.MapListType);
			if (List != None)
			{
				List.Clear();
				for ( i = 0; i < AllLists[GameIndex].MapLists[NewList].Maps.Length; i++ )
				{
					List.AddMap( AllLists[GameIndex].MapLists[NewList].Maps[i], true, false );
				}
				List.CurrentMapIndex = 0;
				MapRecords[i].Current = 0;
				List.SaveConfig();
				List.Destroy();
			}
		}
		SaveConfig();
		return true;
	}

	return false;
}

// Apply or cancel changes
function bool SaveGame(int GameIndex)
{
	local int i;

	if (!ValidGameIndex(GameIndex))
		return false;

	GameRecords[GameIndex].Active = AllLists[GameIndex].GameRec.Active;
	for (i = 0; i < AllLists[GameIndex].MapLists.Length; i++)
		SaveMapList(GameIndex, i);

	return True;
}

function bool SaveMapList(int GameIndex, int MapIndex)
{
	local int i;

	if (!ValidMapListIndex(GameIndex,MapIndex))
		return false;

	i = GetMapRecordIndex(GameIndex,MapIndex);
	if (i < 0)
		return false;

	MapRecords[i] = AllLists[GameIndex].MapLists[MapIndex];
	return true;
}

function bool CancelChange(int GameIndex)
{
	if (!ValidGameIndex(GameIndex))
		return false;

	AllLists[GameIndex].GameRec.Active = GameRecords[GameIndex].Active;
	RefreshList(GameIndex);
	return true;
}

// Adapted from xWebAdmin.StringArray
function ShiftMap(int GameIndex, int MapListIndex, string MapName, int Count)
{
	local int i,id;
	local xMapList List;

	id = -1;
	if (!ValidMapListIndex(GameIndex, MapListIndex))
		return;

	List = AllLists[GameIndex].MapLists[MapListIndex];
	for (i = 0; i < List.Maps.Length; i++)
	{
		if (List.Maps[i] ~= MapName)
		{
			id = i;
			break;
		}
	}

	if (Count == 0 || id == List.Maps.Length)
		return;

	if (Count < 0)
	{
		// Move items toward 0
		if (id + Count < 0)
			Count = -id;
		List.Maps.Insert(id + Count, 1);
		List.Maps[id+Count] = List.Maps[id+1];
		List.Maps.Remove( id + 1, 1 );
	}
	else
	{
		if ((id + Count + 1) >= List.Maps.Length)
			Count = List.Maps.Length - id - 1;

		List.Maps.Insert(id + Count + 1, 1);
		List.Maps[id + Count + 1] = List.Maps[id];
		List.Maps.Remove(id, 1);
	}

	AllLists[GameIndex].MapLists[MapListIndex] = List;
}

protected function array<xMapList> GetAllMapLists(int GameRecIndex)
{
	local int i;
	local GameList GameRecord;
	local array<xMapList> GameMapLists;

	GameRecord = GameRecords[GameRecIndex];
	for (i = 0; i < MapRecords.Length; i++)
		if (MapRecords[i].GameType ~= GameRecord.GameType)
			GameMapLists[GameMapLists.Length] = MapRecords[i];

	if (GameMapLists.Length == 0)
		CreateDefaultList(GameRecord.GameType);

	return GameMapLists;
}

protected function RefreshList(int Index)
{
	AllLists[Index].MapLists = GetAllMapLists(Index);
}

protected function int GetMapRecordIndex(int GameIndex, int MapListIndex)
{
	local int i, j;
	local string GameType;

	if (ValidGameIndex(GameIndex))
		GameType = GameRecords[GameIndex].GameType;

	for (i = 0; i < MapRecords.Length; i++)
		if (MapRecords[i].GameType ~= GameType)
			if (MapListIndex == j++)
				return i;

	return -1;
}

protected function bool ValidGameIndex(int GameIndex)
{
	return GameIndex >= 0 && GameIndex < AllLists.Length;
}

protected function bool ValidMapListIndex(int GameIndex, int MapListIndex)
{
	return MapListIndex >= 0 && ValidGameIndex(GameIndex) && MapListIndex < AllLists[GameIndex].MapLists.Length;
}

protected function array<string> GetAllGametypeMaps()
{
	local int i, j, k;
	local class<GameInfo> GIClass;
	local array<string> Tmp, AllMaps, Used;

	for (i = 0; i < AllLists.Length; i++)
	{
		Tmp.Length = 0;
		GIClass = class<GameInfo>(DynamicLoadObject(AllLists[i].GameRec.GameType,class'Class'));
		if (GIClass != None && GIClass.default.MapPrefix != "")
		{
			for (k = 0; k < Used.Length; k++)
				if (GIClass.default.MapPrefix ~= Used[k])
					break;

			// Don't add the same maplist twice
			if (k < Used.Length) continue;
			Used[Used.Length] = GIClass.default.MapPrefix;
			GIClass.static.LoadMapList(GIClass.default.MapPrefix, Tmp);
		}

		if (Tmp.Length > 0)
		{
			AllMaps.Insert(0, Tmp.Length);
			for (j = 0; j < Tmp.Length; j++)
				AllMaps[j] = Tmp[j];
		}
	}

	return AllMaps;
}

function string ReplaceTag(string from, string tag, coerce string value)
{
local string rep;

	rep = from;
	ReplaceSubstring(rep, "%"$tag$"%", value);
	return rep;
}

defaultproperties
{
     DefaultListName="Default"
     InvalidGameType="could not be loaded.  Normally, this means an .u file has been deleted, but the .int file has not."
     ReallyInvalidGameType="The requested gametype '%gametype%' could not be loaded."
     DefaultListExists="Gametype already has a default list!"
}
