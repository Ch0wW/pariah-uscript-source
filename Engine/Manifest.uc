class Manifest extends Object
    native
    exportstructs;

struct ManifestEntry
{
    var string  Name;
    var int     Size; 
    var string  Date;
    var string  Time;
	var string	Progress;
	var int     Difficulty;
    var int     Corrupt;
};

var() transient const array<ManifestEntry> ManifestEntries;

function LogEntries()
{
    local int i;
    local ManifestEntry entry;
    
    log(self$":");
    
    for(i = 0; i < ManifestEntries.Length; ++i)
    {
        log("--- entry "$i);
        entry = ManifestEntries[i];
        log("Name="$entry.Name);
        log("Size="$entry.Size);
        log("Date="$entry.Date);
        log("Time="$entry.Time);
        log("Progress="$entry.Progress);
        log("Difficulty="$entry.Difficulty);
        log("Corrupt="$entry.Corrupt);
        log("----------");
    }
}

defaultproperties
{
}
