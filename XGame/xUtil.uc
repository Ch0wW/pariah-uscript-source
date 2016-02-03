class xUtil extends Object
    exportstructs
    native;

struct GameTypeRecord
{
    var() String GameName;
    var() String ClassName;
    var() String MapPrefix;
    var() String Acronym;
    var() String MapListType;
    var() String ScreenshotName;
    var() Material Screenshot;
    var() String DecoTextName;
    var() int DefaultGoalScore;
    var() int MinGoalScore;
    var() int DefaultTimeLimit;
    var() int DefaultMaxLives;
    var() int DefaultRemainingRounds;
    var() int bTeamGame;
    var() int MaxPlayersOnDedicated;
    var() int MaxPlayersOnListen;
    var() int bCustomMaps;
};

enum EMapClass
{
    MC_NonCustom,
    MC_Offline,
    MC_Live
};

enum EMapStatus
{
    MS_Unchecked,
    MS_Safe,
    MS_Unsafe
};

struct MapRecord
{
    var() String MapName;
    var() String LongName;
    var() String ScreenshotName;
    var() Material Screenshot;
    var() String VignetteName;
    var() Material Vignette;
    var() String VideoFile;
    var() int IdealPlayerCountMin;
    var() int IdealPlayerCountMax;
    var() EMapClass MapClass;
    var() EMapStatus OfflineStatus;
    var() EMapStatus LiveStatus;
    var() int ModTimeLow;    
    var() int ModTimeHigh;  
};

struct WeaponRecord
{
    var() string WeaponClassName;
    var() string FriendlyName;
    var() string AttachmentMeshName;
    var() float  AttachmentDrawScale;
    var() string PickupMeshName;
    var() byte   Priority;
    var() byte   ExchangeFireModes;
};

struct MutatorRecord
{
    var() string            ClassName;
    var() class<Mutator>    MutClass; // not filled in by GetMutatorList()
    var() string            IconMaterialName;
    var() Material          IconMaterial; // not filled in by GetMutatorList()
    var() string            ConfigMenuClassName;
    var() string            GroupName;
    var() int               SinglePlayerOnly;
    var() int               OnByDefault;
    var() localized string  FriendlyName;
    var() localized string  Description;
    var() byte              bActivated;
};

enum EWepAffinityType
{
    WepAff_Damage,
    WepAff_Ammo,
    WepAff_FireRate,
    WepAff_Accuracy,
};

struct WepAffinityData
{
    var() string            WepString;
    var() class<Weapon>     WepClass;
    var() EWepAffinityType  Type;
    var() float             Value;
};

enum ESpecies   // character species, used for triggering race-specific combos
{
    SPECIES_Alien,
    SPECIES_Bot,
	SPECIES_Egypt,
    SPECIES_Jugg,
	SPECIES_Merc,
    SPECIES_Night,
    SPECIES_None
};

//TODO: comment on how to add data to this
//MH: Add fields to this bad boy, and edit the CacheParseLine( UCachePlayers& ...)
struct PlayerRecord
{
    var() String                    DefaultName;            // Character's name, also used as selection tag
    var() ESpecies                  Species;                // Species
    var() String                    MeshName;               // Mesh type
    var() String                    BodySkinName;           // Body texture name
    var() String                    BodySkinNameMP;         // Body texture name
    var() String                    FaceSkinName;           // Face texture name
    var() String                    FaceSkinNameMP;         // Face texture name
    var() String                    SoundGroupClassName;    // Sound Group name
    var() String                    GibGroupClassName;      // Gib Group name
    var() WepAffinityData           WepAffinity;            // Weapon affinity
    var() String                    PortraitName;           // Menu picture file-name.
    var() Material                  Portrait;
    var() String                    TextName;               // Decotext reference
    var() String                    ClassName;              // Not used, but might be of use to others
    var() String                    SkeletonMeshName;       // Mesh to swap in when skeletized by the ion cannon blast
    var() int                       Source;                 // L1=0x01, L2=0x02, L3=0x04, extra=0x08
    var() String                    VoiceClassName;         // voice pack class name
	var() String					FavVehicle;				// Favourite Car
    var() const int                 RecordIndex;
    var() const byte                bLoaded;
};


struct MiniEdMapRecord //xmatt
{
	var() String MapName;
	var() String LongName;
	var() String ScreenshotName;
	var() String Theme;
	var() String Desc;
	var() int    LayerSets[3];
	var() int    LayersInSets[3];
	var() int    SkySet;
	var() String Time;
	var() ColorHSV LightColor[3];
};


struct MiniEdSkyRecord //xmatt
{
	var() String DayVersionName;
	var() String DayVersionThumbName;
	var() String NightVersionName;
	var() String NightVersionThumbName;
	var() Color DayFogColors[3];
	var() Color NightFogColors[3];
};


struct MiniEdLayerSetRecord //xmatt
{
	var() String VersionsThumbs[3];
	var() String Versions[3];
};


enum EINTPresets
{
    EIP_L1,         // League 1
    EIP_L123,       // Leagues 1, 2 & 3
    EIP_L1AndExt,   // League 1 & any extra
    EIP_L123AndExt, // Leagues 1, 2 & 3 & any extra
};

var() string LeaguePlayerRecords[3];

native final simulated static function CompareFileTimes(int low1, int high1, int low2, int high2, out int result);
native final simulated static function GetGameTypeList(out array<GameTypeRecord> GameTypeRecords);
native final simulated static function UnlockCustomMaps(String Prefix);
native final simulated static function GetMapList(out array<MapRecord> MapRecords, bool IsLive, bool IncludeUnsafe, optional String FileNamePrefix);
native final simulated static function Material GetMapVignette(String MapName);
native final simulated static function GetPlayerList(out array<PlayerRecord> PlayerRecords);
native final simulated static function PlayerRecord GetPlayerRecord(int index);
native final simulated static function PlayerRecord GetRandPlayerRecord(optional bool bL1Only);
native final simulated static function PlayerRecord FindPlayerRecord(string charName);
native final simulated static function PlayerRecord CheckLoadLimits(LevelInfo Info, int index);
native final simulated static function LoadPlayerRecordResources(int index, optional bool bMPResources);
native final simulated static function GetWeaponList(out array<WeaponRecord> WeaponRecords);
native final simulated static function WeaponRecord FindWeaponRecord(string WeaponName);
native final simulated static function UpdateWeaponRecord(WeaponRecord record);
native final simulated static function GetMutatorList(out array<MutatorRecord> MutatorRecords);

native final static function bool CorrectAutoAim(out vector newAim, vector start, vector fireDir, Pawn target, 
                                                      vector aimSpot, float maxHoffset, float maxVoffset, float hitOffsetRatio);
 
native final static function bool LoadUserINI(PlayerController pc, string iniFileName, out string playerName, out string characterName);

//xmatt--
native final simulated static function GetThemeInfo(
	String Theme,
	out array<String> MeshNames,
	out array<String> MeshThumbs,
	out array<String> MeshDesc,
	out array<int> MeshMemory,
	out array<int> SkyTexturesIndices );

/*
  Desc: Get the record of a base map
  params:
		- MapName: The name of the base map (ex: Lonely Isle)
  xmatt
*/
native final simulated static function MiniEdMapRecord GetMiniedBaseMapInfo( String MapName );
native final simulated static function bool CustomMapExists( String PrefixedMapName );
native final simulated static function int GetMaxCustomMapNameLen( String BaseMapName, String Gamertag );
native final simulated static function GetSkiesInfo( array<int> SkyRequested, out array<MiniEdSkyRecord> SkyRecords );
native final simulated static function GetSoundInfo( out array<String> SoundNames, out array<String> SoundFileNames );
native final simulated static function GetLayersInfo( array<int> Requested, out array<MiniEdLayerSetRecord> LayerSetsRecords );
native final simulated static function DeleteCustomMap( bool bLiveMap, String SavedMapName );
//--xmatt


// rj ---
native final simulated static function FillDecoText( DecoText decoText, string rawText, int maxColumns );
// --- rj

simulated static function int AllowedINTs(EINTPresets preset)
{
    local int allow;

    switch(preset)
    {
        case EIP_L1:
            allow = 0x1;
            break;
        case EIP_L123:
            allow = 0x7;
            break;
        case EIP_L1AndExt:
            allow = 0x9;
            break;
        case EIP_L123AndExt:
        default:
            allow = 0xf;
    }

    return allow;
}

simulated static function FilterPlayerRecords(out array<PlayerRecord> filteredRecords, EINTPresets filter)
{
    local array<PlayerRecord> allRecords;
    local int i;

log("bitch");
    GetPlayerList(allRecords);

    for (i=0; i<allRecords.Length; i++)
    {
        if ((allRecords[i].Source & AllowedINTs(filter)) == 0)
            continue;

        filteredRecords[filteredRecords.Length] = allRecords[i];
    }
}

simulated static function string GetFavoriteWeaponName(int playerRecordIndex)
{
    local PlayerRecord pr;
    local WeaponRecord wr; 
    
    pr = GetPlayerRecord(playerRecordIndex);
    wr = FindWeaponRecord(pr.WepAffinity.WepString);
    
    return wr.FriendlyName;
}

simulated static function string GetSpeciesName(ESpecies s)
{
	local string n;

	switch ( s )
	{
	case SPECIES_Alien:
		n = "Alien";
		break;
	case SPECIES_Bot:
		n = "Robot";
		break;
	case SPECIES_Egypt:
		n = "Egyptian";
		break;
	case SPECIES_Jugg:
		n = "Juggernaut";
		break;
	case SPECIES_Merc:
		n = "Mercenary";
		break;
	case SPECIES_Night:
		n = "Night";
		break;
	case SPECIES_None:
		n = "Human";
		break;
	}
	return n;
}

defaultproperties
{
     LeaguePlayerRecords(0)="XPlayersL1"
     LeaguePlayerRecords(1)="XPlayersL2"
     LeaguePlayerRecords(2)="XPlayersL3"
}
