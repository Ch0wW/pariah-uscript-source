class PlayInfo extends object
	native exportstructs;

struct PlayInfoData
{
	var const Property    ThisProp;	   // Pointer to property
	var const class<Info> ClassFrom;   // Which class was this Property from
	var const string      SettingName; // Name of the class member
	var const string      DisplayName; // Display Name of the control (from .INT/.INI File ?)
	var const string      RenderType;  // Type of rendered control
	var const string      Grouping;    // Grouping for this parameter
	var const string      Data;        // Extra Data (like Gore Level Texts)
	var const string      ExtraPriv;   // Extra Privileges Required to set this parameter
	var const byte        SecLevel;    // Sec Level Required to set this param. (Read from Ini file afterwards)
	var const byte        Weight;      // Importance of the setting compared to others in its group
	var const bool        bGlobal;     // GlobalConfig Property ? (Set by native function)
	var const string      Value;	   // Value of the setting
};

var const array<PlayInfoData>	Settings;
var const array<class<info> >	InfoClasses;
var const array<int>			ClassStack;
var const array<string>			Groups;
var const string				LastError;

native final function Clear();
native final function AddClass(class<Info> Class);
native final function PopClass();
native final function AddSetting(string Group, string PropertyName, string Description, byte SecLevel, byte Weight, string RenderType, optional string Extras, optional string ExtraPrivs);
native final function bool SaveSettings();	// Saves stored settings to ini file
native final function bool StoreSetting(int index, coerce string NewVal, optional string RangeData);	// Only validates and sets Settins[index].Value to passed value
native final function int FindIndex(string SettingName);
native final function SplitStringToArray(out array<string> AStr, string Str, string Divider);

final function Init()
{
local int i;

	Log("Settings.Length"$Settings.Length);
	for (i = 0; i<Settings.Length; i++)
	{
		Log("Settings["$i$"]="$Settings[i].SettingName@"-"@Settings[i].Grouping@"-"@Settings[i].Value);
	}
}

defaultproperties
{
}
