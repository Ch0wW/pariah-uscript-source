// ====================================================================
//  Class:  XAdmin.xWebQueryDefaults
//  Parent: XWebAdmin.xWebQueryHandler
//
//  WebAdmin handler for modifying default game settings
// ====================================================================

class xWebQueryDefaults extends xWebQueryHandler
	config;

var config string DefaultsIndexPage;	// Defaults Menu Page
var config string DefaultsMapsPage;
var config string DefaultsRulesPage;
var config string DefaultsIPPolicyPage;	// Special Case of Multi-part list page
var config string DefaultsRestartPage;

// Custom Skin Support
var config string DefaultsRowPage;

// evo ---
var localized string DefaultsMapsLink;
var localized string DefaultsIPPolicyLink;
var localized string DefaultsRestartLink;
var localized string IDBan;

// Error messages
var localized string ActiveMapNotFound;
var localized string InactiveMapNotFound;
var localized string CannotModify;
// --- evo

var localized string NoteMapsPage;
var localized string NoteRulesPage;
var localized string NotePolicyPage;

function bool Init()
{
	local int i;

	if (GamePI == None)
		SetGamePI("");

	for (i = 0; i < GamePI.Settings.Length; i++)
		if (GamePI.Settings[i].ExtraPriv != "" && InStr(NeededPrivs, GamePI.Settings[i].ExtraPriv) == -1)
			NeededPrivs = NeededPrivs $ "|" $ GamePI.Settings[i].ExtraPriv;

	return true;
}

function bool Query(WebRequest Request, WebResponse Response)
{
	if (!CanPerform(NeededPrivs))
		return false;

	MapTitle(Response);

	switch (Mid(Request.URI, 1))
	{
	case DefaultPage:			QueryDefaults(Request, Response); return true;		// Done : General
	case DefaultsIndexPage:		QueryDefaultsMenu(Request, Response); return true;// Done : General
	case DefaultsMapsPage:		if (!MapIsChanging()) QueryDefaultsMaps(Request, Response); return true;
	case DefaultsRulesPage:		if (!MapIsChanging()) QueryDefaultsRules(Request, Response); return true;
	case DefaultsIPPolicyPage:	if (!MapIsChanging()) QueryDefaultsIPPolicy(Request, Response); return true;
	case DefaultsRestartPage:	if (!MapIsChanging()) QueryRestartPage(Request, Response); return true;
	}
	return false;
}

//*****************************************************************************
function QueryDefaults(WebRequest Request, WebResponse Response)
{
	local String GameType, PageStr, Filter;

	// if no gametype specified use the first one in the list
	GameType = Request.GetVariable("GameType", String(Level.Game.Class));

	// if no page specified, use the first one
	PageStr = Request.GetVariable("Page", DefaultsMapsPage);
	Filter = StringIf(Request.GetVariable("Filter") != "", "&Filter="$ Request.GetVariable("Filter"), "");

	Response.Subst("IndexURI", 	DefaultsIndexPage $ "?GameType=" $ GameType $ "&Page=" $ PageStr $ Filter);
	Response.Subst("MainURI", 	PageStr $ "?GameType=" $GameType $ Filter);

	ShowFrame(Response, DefaultPage);
}

function QueryDefaultsMenu(WebRequest Request, WebResponse Response)
{
local string	GameType, Page, TempStr, Content;
local int i;

	GameType = SetGamePI(Request.GetVariable("GameType", string(Level.Game.Class)));
	Page = Request.GetVariable("Page");

	// set currently active page
	if (CanPerform("Gt"))
	{
		if (Request.GetVariable("GameTypeSet", "") != "")
		{
			TempStr = Request.GetVariable("GameTypeSelect", GameType);
			if (!(TempStr ~= GameType))
				GameType = TempStr;
		}

		Response.Subst("GameTypeButton", SubmitButton("GameTypeSet", Update));
		Response.Subst("GameTypeSelect", Select("GameType", GenerateGameTypeOptions(GameType)));
	}
	else
		Response.Subst("GameTypeSelect", Level.Game.Default.GameName);

	// set background colors
	Response.Subst("DefaultBG", DefaultBG);	// for unused tabs

	// Set URIs
	Content = MakeMenuRow(Response, GameType $ "&Page=" $ DefaultsMapsPage, DefaultsMapsLink);
	for (i = 0; i<GamePI.Groups.Length; i++)
		Content = Content $ MakeMenuRow(Response, GameType $ "&Page=" $ DefaultsRulesPage $ "&Filter=" $ GamePI.Groups[i], GamePI.Groups[i]);

	Content = Content $ MakeMenuRow(Response, GameType $ "&Page=" $ DefaultsIPPolicyPage, DefaultsIPPolicyLink);
	Content = Content $ "<br>" $ MakeMenuRow(Response, GameType $ "&Page=" $ DefaultsRestartPage, DefaultsRestartLink);

	Response.Subst("Content", Content);
	Response.Subst("Filter", Request.GetVariable("Filter", ""));
	Response.Subst("Page", Page);
	Response.Subst("PostAction", DefaultPage);
	ShowPage(Response, DefaultsIndexPage);
}

// TODO: add highlight code
function string MakeMenuRow(WebResponse Response, string URI, string Title)
{
	Response.Subst("URI", DefaultPage $ "?GameType=" $ URI);
	Response.Subst("URIText", Title);
	return WebInclude("defaults_menu_row");
}

function QueryDefaultsMaps(WebRequest Request, WebResponse Response)
{
local String GameType, ListName, Tmp, MapName;

// Strings containing generated html (possibly move to .inc?)
local string CustomMapSelect;
local StringArray ExcludeMaps, IncludeMaps, MovedMaps;
local int i, Count, MoveCount, id, CurrentList, Index;
local array<string> Arr;

	if (CanPerform("Ml"))
	{
		GameType = Request.GetVariable("GameType");	// provided by index page
		Index = MapHandler.GetGameIndex(GameType);
		// Get index of maplist from select
		Tmp = Request.GetVariable("MapListNum");

		// Maybe viewing a non-active list
		if (Tmp != "")
			CurrentList = int(Tmp);

		else CurrentList = MapHandler.GetActiveList(Index);
		ListName = MapHandler.GetMapListTitle(Index, CurrentList);

		// Available maplists
		ExcludeMaps = ReloadExcludeMaps(GameType);
		IncludeMaps = ReloadIncludeMaps(ExcludeMaps, Index, CurrentList);
		MovedMaps = New(None) class'SortedStringArray';

		Tmp = Request.GetVariable("MoveMap","");

		// If name in textbox isn't the same as the name of the active list,
		// and we're moving maps, should track of name until we either save or cancel
		if (Tmp != "")
		{
			ListName = Request.GetVariable("ListName", ListName);
			switch (Tmp)
			{
				case " > ":
				case ">":
					Count = Request.GetVariableCount("ExcludeMapsSelect");
					for (i = Count - 1; i >= 0; i--)
					{
						if (ExcludeMaps.Count() > 0)
						{
							MapName = Request.GetVariableNumber("ExcludeMapsSelect", i);
							id = IncludeMaps.MoveFrom(ExcludeMaps, MapName);
							if (id >= 0)
							{
								MovedMaps.CopyFromId(IncludeMaps, id);
								MapHandler.AddMap(Index, CurrentList, MapName);
							}
							else
								Log(InactiveMapNotFound$Request.GetVariableNumber("ExcludeMapsSelect", i),'WebAdmin');
						}
					}
					break;

				case " < ":
				case "<":
					if (Request.GetVariableCount("IncludeMapsSelect") > 0)
					{
						Count = Request.GetVariableCount("IncludeMapsSelect");
						for (i = Count-1; i >= 0; i--)
						{
							MapName = Request.GetVariableNumber("IncludeMapsSelect", i);
							if (IncludeMaps.Count() > 0)
							{
								id = ExcludeMaps.MoveFrom(IncludeMaps, MapName);
								if (id >= 0)
								{
									MovedMaps.CopyFromId(ExcludeMaps, id);
									MapHandler.RemoveMap(Index, CurrentList, MapName);
								}
								else
									Log(ActiveMapNotFound $ Request.GetVariableNumber("IncludeMapsSelect", i),'WebAdmin');
							}
						}
					}
					break;

				case ">>":
					while (ExcludeMaps.Count() > 0)
					{
						id = IncludeMaps.MoveFromId(ExcludeMaps, ExcludeMaps.Count()-1);
						if (id >= 0)
						{
							MovedMaps.CopyFromId(IncludeMaps, id);
							MapHandler.AddMap(Index, CurrentList, IncludeMaps.GetTag(id));
						}
					}

					break;

				case "<<":
					while (IncludeMaps.Count() > 0)
					{
						id =  ExcludeMaps.MoveFromId(IncludeMaps, IncludeMaps.Count()-1);
						if (id >= 0)
						{
							MovedMaps.CopyFromId(ExcludeMaps, id);
							MapHandler.ClearList(Index, CurrentList);
						}
					}

					break;

				case "Up":
					MoveCount = int(Abs(float(Request.GetVariable("MoveMapCount"))));
					Count = Request.GetVariableCount("IncludeMapsSelect");
					for (i = 0; i<Count; i++)
						MovedMaps.CopyFrom(IncludeMaps, Request.GetVariableNumber("IncludeMapsSelect", i));

					MoveCount = -MoveCount;
					for (i = 0; i<IncludeMaps.Count(); i++)
					{
						if (MovedMaps.FindTagId(IncludeMaps.GetTag(i)) >= 0)
						{
							MapHandler.ShiftMap(Index, CurrentList, IncludeMaps.GetTag(i), MoveCount);
							IncludeMaps.ShiftStrict(i, MoveCount);
						}
					}
					break;

				case "Down":
					MoveCount = int(Abs(float(Request.GetVariable("MoveMapCount"))));
					Count = Request.GetVariableCount("IncludeMapsSelect");
					for (i = 0; i<Count; i++)
						MovedMaps.CopyFrom(IncludeMaps, Request.GetVariableNumber("IncludeMapsSelect", i));

					for (i = IncludeMaps.Count()-1; i >= 0; i--)
					{
						if (MovedMaps.FindTagId(IncludeMaps.GetTag(i)) >= 0)
						{
							MapHandler.ShiftMap(Index, CurrentList, IncludeMaps.GetTag(i), MoveCount);
							IncludeMaps.ShiftStrict(i, MoveCount);
						}
					}

					break;
			}
		}

		if (Request.GetVariable("Save") != "")
		{
			ListName = Request.GetVariable("ListName", ListName);
			UpdateCustomMapList(Index, CurrentList, ListName);
		}

		else if (Request.GetVariable("New") != "")
		{
			Arr.Length = 0;
			for (i = 0; i < IncludeMaps.Count(); i++)
				Arr[Arr.Length] = IncludeMaps.GetTag(i);
			MapHandler.ResetList(Index, CurrentList);
			MapHandler.AddList(GameType, Request.GetVariable("ListName", ListName), Arr);
			ExcludeMaps = ReloadExcludeMaps(GameType);
			IncludeMaps = ReloadIncludeMaps(ExcludeMaps, Index, CurrentList);
		}

		else if (Request.GetVariable("Use") != "")
			MapHandler.ApplyMapList(Index, CurrentList);

		else if (Request.GetVariable("Delete") != "")
		{
			MapHandler.RemoveList(Index, CurrentList);
			ListName = MapHandler.GetMapListTitle(Index, MapHandler.GetActiveList(Index));
			ExcludeMaps = ReloadExcludeMaps(GameType);
			IncludeMaps = ReloadIncludeMaps(ExcludeMaps, Index, MapHandler.GetActiveList(Index));
		}

		CustomMapSelect = GenerateMapListOptions(GameType, CurrentList);
		// Fill response values
		Response.Subst("GameType", GameType);
		Response.Subst("Session", "Session");
		Response.Subst("MapListName", ListName);
		Response.Subst("MapListOptions", CustomMapSelect);
		Response.Subst("ExcludeMapsOptions", GenerateMapListSelect(ExcludeMaps, MovedMaps));
		Response.Subst("IncludeMapsOptions", GenerateMapListSelect(IncludeMaps, MovedMaps));

		Response.Subst("Section", DefaultsMapsLink);
		Response.Subst("PostAction", DefaultsMapsPage);
		Response.Subst("PageHelp", NoteMapsPage);

		ShowPage(Response, DefaultsMapsPage);
	}
	else
		AccessDenied(Response);
}

function QueryDefaultsRules(WebRequest Request, WebResponse Response)
{
local int i, j;
local bool bMarked, bSave;
local String GameType, Content, Data, Op, Mark, Filter, SecLevel, TempStr;
local array<string> Options;

	if (!CanPerform("Ms"))
	{
		AccessDenied(Response);
		return;
	}

	GameType = SetGamePI(Request.GetVariable("GameType"));
	Filter = Request.GetVariable("Filter");

	bSave = Request.GetVariable("Save", "") != "";

	Content = "";
	Mark = WebInclude("defaults_mark");
	Response.Subst("Section", Filter);
	Response.Subst("Filter", Filter);
	for (i = 0; i<GamePI.Settings.Length; i++)
	{
		if (GamePI.Settings[i].Grouping == Filter && GamePI.Settings[i].SecLevel <= CurAdmin.MaxSecLevel() && (GamePI.Settings[i].ExtraPriv == "" || CanPerform(GamePI.Settings[i].ExtraPriv)))
		{
			Options.Length = 0;
			TempStr = HtmlDecode(Request.GetVariable(GamePI.Settings[i].SettingName, ""));
			if (bSave)
				GamePI.StoreSetting(i, TempStr, GamePI.Settings[i].Data);

			bMarked = bMarked || GamePI.Settings[i].bGlobal;
			Response.Subst("Mark", StringIf(bMarked, Mark, ""));
			Response.Subst("DisplayText", HtmlEncode(GamePI.Settings[i].DisplayName));
			SecLevel = StringIf (CurAdmin.bMasterAdmin, string(GamePI.Settings[i].SecLevel), "");
			Response.Subst("SecLevel", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" $ SecLevel);

			if (GamePI.Settings[i].RenderType ~= "Text")
			{
				Data = "8";
				if (GamePI.Settings[i].Data != "")
				{
					Data = GamePI.Settings[i].Data;
					Divide(GamePI.Settings[i].Data, ";", Data, Op);
					GamePI.SplitStringToArray(Options, Op, ":");
					j = int(Data);
				}

				Op = "";
				if (Options.Length > 1)
					Op = " ("$Options[0]$" - "$Options[1]$")";

				Response.Subst("Content", Textbox(GamePI.Settings[i].SettingName, j, 2*j, HtmlEncode(GamePI.Settings[i].Value)) $ Op);
				Response.Subst("FormObject", WebInclude(NowrapLeft));
			}

			else if (GamePI.Settings[i].RenderType ~= "Check")
			{
				if (bSave && GamePI.Settings[i].Value == "")
					GamePI.StoreSetting(i, "False");

				Response.Subst("Content", Checkbox(GamePI.Settings[i].SettingName, GamePI.Settings[i].Value ~= "True", GamePI.Settings[i].Data != ""));
				Response.Subst("FormObject", WebInclude(NowrapLeft));
			}

			else if (GamePI.Settings[i].RenderType ~= "Select")
			{
				Data = "";
				// Build a set of options from PID.Data
				GamePI.SplitStringToArray(Options, GamePI.Settings[i].Data, ";");
				for (j = 0; (j+1)<Options.Length; j += 2)
				{
					Data += ("<option value='"$Options[j]$"'");
					If (GamePI.Settings[i].Value == Options[j])
						Data @= "selected";
					Data += (">"$HtmlEncode(Options[j+1])$"</option>");
				}

				Response.Subst("Content", Select(GamePI.Settings[i].SettingName, Data));
				Response.Subst("FormObject", WebInclude(NowrapLeft));
			}

			Content += WebInclude(DefaultsRowPage);
		}
	}
	GamePI.SaveSettings();

	if (Content == "")
		Content = CannotModify;

	Response.Subst("TableContent", Content);
    Response.Subst("PostAction", DefaultsRulesPage);
   	Response.Subst("GameType", GameType);
	Response.Subst("SubmitValue", Accept);
	Response.Subst("PageHelp", NoteRulesPage);
	ShowPage(Response, DefaultsRulesPage);
}

function QueryDefaultsIPPolicy(WebRequest Request, WebResponse Response)
{
local int i, j;
local bool bIpBan;
local string policies, tmpN, tmpV;
local string PolicyType;

	if (CanPerform("Xi"))
	{
		Response.Subst("Section", DefaultsIPPolicyLink);
		if (Request.GetVariable("Update") != "")
		{
			i = int(Request.GetVariable("IpNo", "-1"));
			if(i > -1 && ValidMask(Request.GetVariable("IPMask")))
			{
				if (i >= Level.Game.AccessControl.IPPolicies.Length)
				{
					i = Level.Game.AccessControl.IPPolicies.Length;
					Level.Game.AccessControl.IPPolicies.Length = i+1;
				}
				Level.Game.AccessControl.IPPolicies[i] = Request.GetVariable("AcceptDeny")$","$Request.GetVariable("IPMask");
				Level.Game.AccessControl.SaveConfig();
			}
		}

		if(Request.GetVariable("Delete") != "")
		{
			i = int(Request.GetVariable("IdNo", "-1"));
			if (i == -1)
			{
				bIpBan = True;
				i = int(Request.GetVariable("IpNo", "-1"));
			}

			if (i > -1)
			{
				if ( bIpBan && i < Level.Game.AccessControl.IPPolicies.Length )
				{
					Level.Game.AccessControl.IPPolicies.Remove(i,1);
					Level.Game.AccessControl.SaveConfig();
				}

				if ( !bIpBan && i < Level.Game.AccessControl.BannedIDs.Length )
				{
					Level.Game.AccessControl.BannedIDs.Remove(i,1);
					Level.Game.AccessControl.SaveConfig();
				}
			}
		}

		Policies = "";
		if (Level.Game.AccessControl.bBanById)
		{
			for (i = 0; i < Level.Game.AccessControl.BannedIds.Length; i++)
			{
				j = InStr(Level.Game.AccessControl.BannedIDs[i], " ");
				tmpN = Mid(Level.Game.AccessControl.BannedIDs[i], j + 1);
				tmpV = Left(Level.Game.AccessControl.BannedIDs[i], j);

				Response.Subst("PolicyType", IDBan);
				Response.Subst("PolicyCell", tmpN $ ":" @ tmpV $ "&nbsp;&nbsp;");
				Response.Subst("PostAction", DefaultsIPPolicyPage $ "?IDNo="$string(i));
				Response.Subst("UpdateButton", "");
				Policies = Policies $ WebInclude(DefaultsIPPolicyPage $ "_row");
			}
		}

		for(i=0; i<Level.Game.AccessControl.IPPolicies.Length; i++)
		{
			j = InStr(Level.Game.AccessControl.IPPolicies[i], ",");
			tmpN = Left(Level.Game.AccessControl.IPPolicies[i], j);
			tmpV = Mid(Level.Game.AccessControl.IPPolicies[i], j + 1);

			PolicyType = RadioButton("AcceptDeny", "ACCEPT", tmpN ~= "ACCEPT") @ Accept $ "<br>";
			PolicyType = PolicyType $ RadioButton("AcceptDeny", "DENY", tmpN ~= "DENY") @ Deny;

			Response.Subst("PolicyType", PolicyType);
			Response.Subst("PolicyCell", Textbox("IPMask", 15, 25, tmpV) $ "&nbsp;&nbsp;");
			Response.Subst("PostAction", DefaultsIPPolicyPage $ "?IpNo="$string(i));
			Response.Subst("UpdateButton", SubmitButton("Update", Update));
			Policies = Policies $ WebInclude(DefaultsIPPolicyPage $ "_row");
		}

		Response.Subst("Policies", policies);
		Response.Subst("PostAction", DefaultsIPPolicyPage$"?IpNo="$string(i));
		Response.Subst("PageHelp", NotePolicyPage);
		ShowPage(Response, DefaultsIPPolicyPage);
	}
	else
		AccessDenied(Response);
}

// evo ---
function bool ValidMask(string mask)
{
	local int i;
	local string Octets[4];
	local string tmp;

	// First check each octet to make sure it's a byte
	while (mask != "")
	{
		if (Left(mask,1) == ".")
		{
			if (!ValidOctet(tmp))
				return false;

			Octets[i++] = tmp;
			Mask = Mid(Mask,1);
			tmp = "";
		}

		EatStr(tmp, Mask, 1);
	}

	if (!ValidOctet(tmp))
		return false;

	Octets[i++] = tmp;

	// Check to make sure we only have 4 valid bytes
	if (i > 4) return false;

	return true;
}

function bool ValidOctet(string tmp)
{
	local int i;

	if (tmp == "") return false;
	if (ValidMaskOctet(tmp)) return true;

	i = int(tmp);
	if (i == 0 && tmp != "0") return false;
	if (i < 0 || i > 255) return false;

	return true;
}

function bool ValidMaskOctet(string tmp)
{
	local string s;

	if (tmp == "" || len(tmp) > 3 || right(tmp,1) != "*")
		return false;

	while (tmp != "")
	{
		s = left(tmp,1);
		if (s == "*")
			break;

		if (s < "0" || s > "9")
			return false;

		tmp = mid(tmp,1);
	}
	return true;
}
// --- evo

defaultproperties
{
     DefaultsIndexPage="defaults_menu"
     DefaultsMapsPage="defaults_maps"
     DefaultsRulesPage="defaults_rules"
     DefaultsIPPolicyPage="defaults_ippolicy"
     DefaultsRestartPage="defaults_restart"
     DefaultsRowPage="defaults_row"
     DefaultsMapsLink="Maps"
     DefaultsIPPolicyLink="Access Policies"
     DefaultsRestartLink="Restart Level"
     IDBan="(Global Ban)"
     ActiveMapNotFound="Active map not found: "
     InactiveMapNotFound="Inactive map not found: "
     CannotModify="** You cannot modify any settings in this section **"
     NoteMapsPage="To save any changes to a custom maplist, click the Save button.  To apply the selected maplist to the server's map rotation, click the 'Use' button."
     NoteRulesPage="Configurable game parameters can be changed from this page.  Some parameters may affect more than one gametype."
     NotePolicyPage="Any banned players will automatically be added to this listing. You will only be able to add manual bans for IP addresses."
     DefaultPage="defaultsframe"
     Title="Defaults"
     NeededPrivs="G|M|X|Gt|Ml|Ms|Xi|Xb"
}
