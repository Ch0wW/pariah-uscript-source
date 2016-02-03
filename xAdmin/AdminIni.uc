// ====================================================================
//  Class:  XAdmin.AdminIni
//  Parent: Engine.Admin
//
//  TODO: Implement <cmd> help for inline help text ?
// ====================================================================

class AdminIni extends AdminBase;

var AccessControlIni	Manager;
var xAdminUser			AdminUser;
var GameConfigSet		ConfigSet;
var xMapLists			MapHandler;

var protected string	NextMutators;
var protected string	NextGameType;

// Localization
var localized string Msg_PlayerList;
var localized string Msg_FinishGameEditFirst;
var localized string Msg_FinishGameRestart;
var localized string Msg_GameNoSupportBots;
var localized string Msg_StatsNoBots;
var localized string Msg_NextMapNotFound;
var localized string Msg_ChangingMapTo;
var localized string Msg_PlayerBanned;
var localized string Msg_SessionBanned;
var localized string Msg_PlayerKicked;
var localized string Msg_NoBotGameFull;
var localized string Msg_NoAddNamedBot;
var localized string Msg_NoBotsPlaying;
var localized string Msg_SetBotNeedVal;
var localized string Msg_MutNeedGameEdit;
var localized string Msg_NoMutatorInUse;
var localized string Msg_NoUnusedMuts;
var localized string Msg_AddedMutator;
var localized string Msg_ErrAddingMutator;
var localized string Msg_RemovedMutator;
var localized string Msg_ErrRemovingMutator;
var localized string Msg_MapListNeedGameEdit;
var localized string Msg_MapRotationList;
var localized string Msg_NoMapInRotation;
var localized string Msg_NoMapsAdded;
var localized string Msg_AddedMapToList;
var localized string Msg_NoMapsRemoved;
var localized string Msg_RemovedMapFromList;
var localized string Msg_NoMapsFound;
var localized string Msg_MapIsInRotation;
var localized string Msg_MapNotInRotation;
var localized string Msg_MustEndGameEdit;
var localized string Msg_EditingClass;
var localized string Msg_EditFailed;
var localized string Msg_AlreadyEdited;
var localized string Msg_NotEditing;
var localized string Msg_EditingCompleted;
var localized string Msg_EditingCancelled;
var localized string Msg_UnknownParam;
var localized string Msg_NoParamsFound;
var localized string Msg_ParamModified;
var localized string Msg_ParamNotModified;
var localized string Msg_EditingMapList;

var localized string Msg_MapListAdded;
var localized string Msg_MapListRemoved;
var localized string Msg_AllMapLists;
var localized string Msg_RemovedFromList;
var localized string Msg_MapIsNotInRotation;
var localized string Msg_AllGameMaps;

function Created()
{
	if (AccessControlIni(Level.Game.AccessControl) != None)
	{
		Manager = AccessControlIni(Level.Game.AccessControl);
		MapHandler = AccessControlIni(Level.Game.AccessControl).MapHandler;
	}
}

// Execute an administrative console command on the server.
exec function DoLogin( string Username, string Password )
{
	if (AdminUser == None && Manager.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
		AdminUser = Manager.GetLoggedAdmin(Outer);
		Manager.AdminEntered(Outer, Username);
	}
}

exec function DoLogout()
{
	if (Manager.AdminLogout(Outer))
	{
		Manager.ReleaseConfigSet(ConfigSet, Self);
		Manager.AdminExited(Outer);
		bAdmin=false;
	}
}

// TODO: Remove for release ?
exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log(Msg_PlayerList);
	ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
		log(PRI.RetrivePlayerName()@"( ping"@PRI.Ping$")");
}

exec function RestartMap()
{
	if (CanPerform("Mr") || CanPerform("Mc"))	  // Mr = MapRestart, Mc = Map Change
	{
		if (ConfigSet == None)
			DoSwitch("?restart");
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}
}

exec function Switch( string URL )
{
	DoSwitch(URL);
}

function DoSwitch( string URL)
{
	if (CanPerform("Mc"))
	{
		if (ConfigSet == None)
		{
			// Rebuild the URL based on edited game settings
			if (NextGameType != "" && Level.Game.ParseOption(URL, "Game") == "")
				URL=URL$"?Game="$NextGameType;

			if (NextMutators != "" && Level.Game.ParseOption(URL, "Mutator") == "")
				URL=URL$"?Mutator="$NextMutators;

			Level.ServerTravel( URL, false );
		}
		else
			ClientMessage(Msg_FinishGameRestart);
	}
}

function GotoNextMap()
{
local string NextMap;
local MapList MyList;
local GameInfo G;

	if (CanPerform("Mc"))
	{
		if (ConfigSet == None)
		{

			G = Level.Game;
			if ( G.bChangeLevels && !G.bAlreadyChanged && (G.MapListType != "") )
			{
				// open a the nextmap actor for this game type and get the next map
				G.bAlreadyChanged = true;
				MyList = G.GetMapList(G.MapListType);
				if (MyList != None)
				{
					NextMap = MyList.GetNextMap();
					MyList.Destroy();
				}
				if ( NextMap == "" )
					NextMap = GetMapName(G.MapPrefix, NextMap,1);

				if ( NextMap != "" )
				{
					DoSwitch(NextMap);
					ClientMessage(ReplaceTag(Msg_ChangingMapTo, "NextMap", NextMap));
					return;
				}
			}
			ClientMessage(Msg_NextMapNotFound);
			Level.ServerTravel( "?Restart", false );
		}
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}
}

exec function Kick( string Cmd, string Extra )
{
local array<string> Params;
local array<PlayerReplicationInfo> AllPRI;
local Controller	C, NextC;
local int i;

	if (CanPerform("Kp") || CanPerform("Kb"))		// Kp = Kick Players, Kb = Kick/Ban
	{
		if (Cmd ~= "List")
		{
			// Get the list of players to kick by showing their PlayerID
			// TODO: Display Fixed Playername (no garbage chars in name)?
			// TODO: Display Sorted ?
			Level.Game.GameReplicationInfo.GetPRIArray(AllPRI);
			for (i = 0; i<AllPRI.Length; i++)
				ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].RetrivePlayerName());
			return;
		}

		if (Cmd ~= "Ban" || Cmd ~= "Session")
		   Params = SplitParams(Extra);

		else if (Extra != "")
		   Params = SplitParams(Cmd@Extra);

		else
        	Params = SplitParams(Cmd);

		// go thru all Players
		for (C = Level.ControllerList; C != None; C = NextC)
		{
			NextC = C.NextController;
			// Allow to kick bots too, for now i dont
			// What about Spectators ?? hummm ...
			if (C != Owner && PlayerController(C) != None && C.PlayerReplicationInfo != None)
			{
				for (i = 0; i<Params.Length; i++)
				{
					if ((IsNumeric(Params[i]) && C.PlayerReplicationInfo.PlayerID == int(Params[i]))
							|| MaskedCompare(C.PlayerReplicationInfo.RetrivePlayerName(), Params[i]))
					{
						// Kick that player
						if (Cmd ~= "Ban")
						{
							ClientMessage(ReplaceTag(Msg_PlayerBanned, "Player", C.PlayerReplicationInfo.RetrivePlayerName()));
							Manager.BanPlayer(PlayerController(C));
						}
						else if (Cmd ~= "Session")
						{
							ClientMessage(ReplaceTag(Msg_SessionBanned, "Player", C.PlayerReplicationInfo.RetrivePlayerName()));
							Manager.BanPlayer(PlayerController(C), true);
						}
						else
						{
							Manager.KickPlayer(PlayerController(C));
							ClientMessage(ReplaceTag(Msg_PlayerKicked, "Player", C.PlayerReplicationInfo.RetrivePlayerName()));
						}
						break;
					}
				}
			}
		}
	}
}

exec function User( string Cmd, string Extra)
{
	if (Cmd ~= "List")	// Admin User List *mask*
	{
		SendUserList(Extra);
	}
	else if (Cmd ~= "Del")	// Admin User Del *mask*
	{
		// TODO: Later .. need to make sure its acceptable to do so
	}
	else if (Cmd ~= "Logged") // List of currently logged admins
	{
		SendLoggedList();
	}
}

// All Bots functions are not Persistent unless Level.Game.SaveConfig()
exec function Bots( string Cmd, string Extra)
{
local int MinV, i, j;
local array<string> Params;
local array<XUtil.PlayerRecord>	BotList, BotsToAdd;
local DeathMatch	Game;
local Controller	C, NextC;
local xBot			Bot;

	if (CanPerform("Mb"))
	{
		Game = DeathMatch(Level.Game);
		if (Game == None)
		{
			ClientMessage(Msg_GameNoSupportBots);
			return;
		}

		if (Game.GameStats != None)
		{
			ClientMessage(Msg_StatsNoBots);
			return;
		}

		Params = SplitParams(Extra);
		if (Cmd ~= "Add")
		{
			MinV = Game.MinPlayers;
			if (MinV == 32)
			{
				ClientMessage(Msg_NoBotGameFull);
				return;
			}

			if (Params.Length == 0)
			{
				Game.ForceAddBot();
			}
			else if (Params.Length == 1 && IsNumeric(Params[0]))
			{
//				Log("Trying to add"@int(Params[0])@"bots");
				MinV = Min(32, MinV + int(Params[0]));
				while (Game.MinPlayers < MinV)
					Game.ForceAddBot();
			}
			else	// Else add named bots
			{
				if (!Game.IsInState('MatchInProgress'))
				{
					ClientMessage(Msg_NoAddNamedBot);
					return;
				}
				MakeBotsList(BotList);
				// First Build a list of Bots to add
				for (i = 0; i<BotList.Length; i++)
				{
					for (j = 0; j<Params.Length; j++)
					{
						if (MaskedCompare(BotList[i].DefaultName, Params[j]))
						{
							BotsToAdd[BotsToAdd.Length] = BotList[i];
							BotList.Remove(i, 1);
							i--;
						}
					}
				}
				MinV = Min(32, MinV + BotsToAdd.Length);
				while (Game.MinPlayers<MinV)
				{
//					Log("Trying to add"@BotsToAdd[0].DefaultName);
					if (!Game.AddBot(BotsToAdd[0].DefaultName))
						break;
//					Log("Bot added successfully");
					BotsToAdd.Remove(0, 1);
				}
			}
		}
		else if (Cmd ~= "Kill")
		{
			if (Game.MinPlayers == 0 || Game.NumBots == 0)
			{
				ClientMessage(Msg_NoBotsPlaying);
				return;
			}

			if (Params.Length == 0) // Kill 1 random bot
			{
				Game.KillBots(1);
			}
			else if (Params.Length == 1 && IsNumeric(Params[0])) // Kill a Number of Bots
			{
//				log("Trying to remove"@int(Params[0])@"bots");
				Game.KillBots(int(Params[0]));
			}
			else	// Kill Named Bots
			{
				// TODO: Rework Loop ?
				for (C = Level.ControllerList; C != None; C = NextC)
				{
					Bot = xBot(C);
					NextC = C.NextController;
					if (Bot != None && Bot.PlayerReplicationInfo != None)
					{
						for (i = 0; i<Params.Length; i++)
						{
							if (MaskedCompare(Bot.PlayerReplicationInfo.RetrivePlayerName(), Params[i]))
							{
//								Log("Trying to kill"@Bot.PlayerReplicationInfo.RetrivePlayerName());
								Game.KillBot(C);
								break;
							}
						}
					}
				}
			}
		}
		else if (Cmd ~= "Set")	// Minimum number of Players
		{
			if (Params.Length == 1 && IsNumeric(Params[0]) && int(Params[0]) < 33)
			{
				Game.MinPlayers=int(Params[0]);
			}
			else
				ClientMessage(Msg_SetBotNeedVal);
		}
	}
}

// TODO: Mutators Logic should be separate from GameConfigSet since
//       they are not associated to a game type.
exec function Mutators( string Cmd, string Extra)
{
local array<string> Values;
local int i;

	if (CanPerform("Mu"))
	{
		// TODO: Separate Mutator stuff from ConfigSet ?
		if  (ConfigSet == None)
		{
			ClientMessage(Msg_MutNeedGameEdit);
			return;
		}

		if (Cmd ~= "Used")
		{
			// List Used Mutators
			Values = ConfigSet.GetUsedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoMutatorInUse);
		}
		else if (Cmd ~= "Unused")
		{
			Values = ConfigSet.GetUnusedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoUnusedMuts);
		}
		else if (Cmd ~= "Add")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.AddMutator(Values[i]))
					ClientMessage(ReplaceTag(Msg_AddedMutator, "Mutator", Values[i]));
				else
					ClientMessage(ReplaceTag(Msg_ErrAddingMutator, "Mutator", Values[i]));
			}
		}
		else if (Cmd ~= "Del")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.DelMutator(Values[i]))
					ClientMessage(ReplaceTag(Msg_RemovedMutator, "Mutator", Values[i]));
				else
					ClientMessage(ReplaceTag(Msg_ErrRemovingMutator, "Mutator", Values[i]));
			}
		}
	}
}

exec function Map( string Cmd )
{
	if (Cmd ~= "Restart")
	{
		RestartMap();
	}
	else if (Cmd ~= "Next")
	{
		GotoNextMap();
	}
	else if (Cmd ~= "List")
	{
		ShowCurrentMapList();
	}
	else
	{
		DoSwitch(Cmd);
	}
}

function ShowCurrentMapList()
{
	local int i, c;
	local array<string> Ar;

	i = MapHandler.GetGameIndex(string(Level.Game.Class));
	c = MapHandler.GetActiveList(i);
	Level.Game.static.LoadMapList(Level.Game.MapPrefix, Ar);
	SendComplexMsg(Ar, Msg_AllGameMaps@MapHandler.GetMapListTitle(i,c));
}

function array<string> GetMapListNames(string GameType)
{
	local int i;
	local array<string> Ar;

	i = MapHandler.GetGameIndex(GameType);
	Ar = MapHandler.GetMapListNames(i);
	return Ar;
}

exec function MapList( string Cmd, string Extra )
{
local array<string> Values, Tmp;
local string Str;
local int i, c;

	if (CanPerform("Ml"))
	{
		Cmd = Caps(Cmd);
		if (ConfigSet == None)
		{
			i = MapHandler.GetGameIndex(string(Level.Game.Class));
			if (Extra == "")
				c = MapHandler.GetActiveList(i);
			else c = int(Extra);
			Str = MapHandler.GetMapListTitle(i, c);

			switch (Cmd)
			{
			case "LIST":
				Values = MapHandler.GetMapListNames(i);
				SendComplexMsg(Values, ReplaceTag(Msg_AllMapLists, "gametype", string(Level.Game.Class)));
				break;

			case "USED":
				Values = MapHandler.GetMapList(i, c);
				SendComplexMsg(Values, ReplaceTag(Msg_MapRotationList, "maplist", Str));
				break;

			case "SWITCH":
				MapHandler.ApplyMapList(i, c);
				break;

			default:
				ClientMessage(Msg_MapListNeedGameEdit);
				break;
			}
		}
		else
		{
			i = MapHandler.GetGameIndex(ConfigSet.GetEditedClass());

			switch (Cmd)
			{
			case "LIST":
				if (Extra == "")
				{
					Values = ConfigSet.GetLists();
					SendComplexMsg(Values, "MapLists for"@ConfigSet.GetEditedClass());
				}
				else
				{
					Values = ConfigSet.GetMaps();
					Str = MapHandler.GetMapListTitle(i, int(Extra));
					SendComplexMsg(Values, ReplaceTag(Msg_MapRotationList,"maplist",Str));
				}
				break;

			case "USED":
				Str = ReplaceTag(Msg_MapRotationList, "maplist", MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				Values = ConfigSet.GetMaps();
				if (Values.Length > 0)
					SendComplexMsg(Values, Str);
				else ClientMessage(Msg_NoMapInRotation);
				break;

			case "SWITCH":
				ClientMessage(Msg_MustEndGameEdit);
				break;

			case "EDIT":
				if (Extra == "") Extra = string(ConfigSet.GetActiveList());
				ConfigSet.CurrentMapList = int(extra);
				ClientMessage(ReplaceTag(Msg_EditingMapList, "List", MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList)));
				break;

			case "ENDEDIT":
				ConfigSet.EndEdit(bool(Extra));
				break;

			case "NEW":
				Str = ConfigSet.GetEditedClass();
				MapHandler.AddList(Str, Extra, Values);
				ClientMessage(ReplaceTag(Msg_MapListAdded, "listname", Extra)@Str$".");
				break;

			case "REMOVE":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				MapHandler.RemoveList(i, ConfigSet.CurrentMapList);
				ClientMessage(ReplaceTag(Msg_MapListRemoved, "listname", Str)@ConfigSet.GetEditedClass()$".");
				break;

			case "ADD":
				Values = ConfigSet.AddMaps(Extra);
				if (Values.Length == 0)
					ClientMessage(Msg_NoMapsAdded@Str$".");
				else SendComplexMsg(Values, Msg_AddedMapToList @ MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				break;

			case "DEL":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				Values = ConfigSet.RemoveMaps(Extra);
				if (Values.Length == 0)
					ClientMessage(Msg_NoMapsRemoved@Str$".");
				else SendComplexMsg(Values, Msg_RemovedFromList @ MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList));
				break;

			case "FIND":
				Str = MapHandler.GetMapListTitle(i, ConfigSet.CurrentMapList);
				Values = ConfigSet.FindMaps(Extra);
				for (i = 0; i<Values.Length; i++)
				{
					if (Left(Values[i], 1) != "+")
					{
						Tmp[Tmp.Length] = Values[i];
						Values.Remove(i--,1);
					}

					else Values[i] = Mid(Values[i],1);
				}
				if (Values.Length > 0)
					SendComplexMsg(Values, ReplaceTag(Msg_MapIsInRotation,"maplist",Str));
				else ClientMessage(ReplaceTag(Msg_NoMapsFound, "maplist", Str));

				if (Tmp.Length > 0)
					SendComplexMsg(Tmp, ReplaceTag(Msg_MapIsNotInRotation,"maplist",Str));
				break;
			}

		}
	}
}

exec function Game( string Cmd, string Extra )
{
local array<string> Params;
local string LastParam, LastValue;
local int p;

	if (Cmd ~= "ChangeTo")	// Admin Game ChangeTo <gameclass>
	{
		if (CanPerform("Mt"))
		{
			if (ConfigSet != None)
			{
				ClientMessage(Msg_MustEndGameEdit);
				return;
			}
			NextGameType = FindGameType(Extra);
		}
		return;
	}

	if (!CanPerform("Ms"))
		return;

	if (Cmd ~= "Edit")	// Admin Game Edit [CTF]
	{
		if (Manager.LockConfigSet(ConfigSet, Self))
		{
			if (ConfigSet.StartEdit(Extra))
				ClientMessage(ReplaceTag(Msg_EditingClass, "Class", ConfigSet.GetEditedClass()));
			else
			{
				ClientMessage(Msg_EditFailed);
				Manager.ReleaseConfigSet(ConfigSet, Self);
			}
		}
		else
			ClientMessage(Msg_AlreadyEdited);
		return;
	}

	if  (ConfigSet == None)
	{
		ClientMessage(Msg_NotEditing);
		return;
	}

	if (Cmd ~= "EndEdit")
	{
		ConfigSet.EndEdit(true);
		NextMutators = ConfigSet.NextMutators;
		Manager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCompleted);
	}
	else if (Cmd ~= "CancelEdit")
	{
		ConfigSet.EndEdit(false);
		Manager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCancelled);
	}
	else if (Cmd ~= "Get")
	{
		if (Instr(Extra, "*") == -1 && Instr(Extra, " ") == -1)
		{
			LastValue = ConfigSet.GetNamedParam(Extra);
			if (LastValue == "")
				ClientMessage(ReplaceTag(Msg_UnknownParam,"Value", Extra));
			else
				ClientMessage(Extra@"="@LastValue);
		}
		else
		{
			Params = ConfigSet.GetMaskedParams(Extra);
			if (Params.Length == 0)
				ClientMessage(Msg_NoParamsFound);
			else
				for (p = 0; p<Params.Length; p+=2)
					ClientMessage(Params[p]@"="@Params[p+1]);
		}
	}
	else if (Cmd ~= "Set")
	{
		p = Instr(Extra, " ");
		if (p >= 0)
		{
			LastParam = Left(Extra, p);
			LastValue = Mid(Extra, p+1);
			if (ConfigSet.SetNamedParam(LastParam, LastValue))
			{
				ClientMessage(Msg_ParamModified);
				return;
			}
		}
		ClientMessage(Msg_ParamNotModified);
	}
}

protected function SendComplexMsg(array<string> Arr, string Title)
{
	local int 		i, Longest;
	local string 	Line, Border;
	local string	Prefix, Suffix;



	for (i = 0; i < Arr.Length; i++)
		if ( Len(Arr[i]) > Longest )
			Longest = Len(Arr[i]);

// Account for borders
	Longest += 8;
	for (Border = ""; Len(Border) < Longest; Border = Border $ "-");

	ClientMessage(Title);
	ClientMessage(Border);

	for (i = 0; i < Arr.Length; i++)
	{
		Prefix = Right("[] "$i, 4)$")";
		Suffix = " []";
		Line = Prefix $ Arr[i] $ Suffix;
		while (Len(Line) < Longest)
		{
			Suffix = " " $ Suffix;
			Line = Prefix $ Arr[i] $ Suffix;
		}
		ClientMessage(Line);
	}
	ClientMessage(Border);
}

protected function bool CanPerform(string priv)
{
  return AdminUser != None && AdminUser.HasPrivilege(priv);
}

protected function SendUserList(string mask)	// Todo: Mask Feature
{
local xAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(Manager.Groups);
	for (i=0; i<uList.Count(); i++)
		ClientMessage(string(i)$uList.Get(i).UserName);
}

/// TODO: Check if should send ALL logged admins or only
protected function SendLoggedList()
{
local xAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(Manager.Groups);
	for (i=0; i<uList.Count(); i++)
		if (Manager.IsLogged(uList.Get(i)))
			ClientMessage(string(i)$uList.Get(i).UserName);
}

protected function string FindGameType(string GameType)
{
local class<GameInfo>	TempClass;
local String 			NextGame;
local int				i;

	// Compile a list of all gametypes.
	i = 0;
	NextGame = Level.GetNextInt("Engine.GameInfo", 0);
	while (NextGame != "")
	{
		TempClass = class<GameInfo>(DynamicLoadObject(NextGame, class'Class'));
		if (TempClass != None)
		{
			if (GameType ~= string(TempClass))				break;
			if (GameType ~= TempClass.default.Acronym)		break;
			if (GameType ~= TempClass.default.DecoTextName)	break;
			if (Right(string(TempClass), Len(GameType)+1) ~= ("."$GameType))			break;
			if (Right(TempClass.default.DecoTextName, Len(GameType)+1) ~= ("."$GameType))	break;
		}
		NextGame = Level.GetNextInt("Engine.GameInfo", ++i);
	}
	return NextGame;
}

function MakeBotsList(out array<XUtil.PlayerRecord> BotList)
{
local xBot Bot;
local int i;
local Controller C;

	// Get Full Bot List
	class'XUtil'.static.GetPlayerList(BotList);
	// Filter out Playing Bots
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		Bot = xBot(C);
		if (Bot != None && Bot.PlayerReplicationInfo != None)
		{
			for (i = 0; i<BotList.Length; i++)
			{
				if (Bot.PlayerReplicationInfo.CharacterName == BotList[i].DefaultName)
				{
					BotList.Remove(i,1);
					break;
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////
// TODO: Find Centralized place for the following functions
////////////////////////////////////////////////////////////

// TODO: Improve mask wildcards .. "*" = Any Size, "?" = 1 char
// Mask can be *|*Name|Name*|*Name*|Name
protected function bool MaskedCompare(string SettingName, string Mask)
{
local bool bMaskLeft, bMaskRight;
local int MaskLen;

	if (Mask == "*" || Mask == "**")
		return true;

	MaskLen = Len(Mask);
	bMaskLeft = Left(Mask, 1) == "*";
	bMaskRight = Right(Mask, 1) == "*";

	if (bMaskLeft && bMaskRight)
		return Instr(Caps(SettingName), Mid(Caps(Mask), 1, MaskLen-2)) >= 0;

	if (bMaskLeft)
		return Left(SettingName, MaskLen -1) ~= Left(Mask, MaskLen - 1);

	if (bMaskRight)
		return Right(SettingName, MaskLen -1) ~= Right(Mask, MaskLen - 1);

	return SettingName ~= Mask;
}

// TODO: Add support for bPositiveOnly
function bool IsNumeric(string Param, optional bool bPositiveOnly)
{
local int p;

	p=0;
	while (Mid(Param, p, 1) == " ") p++;
	while (Mid(Param, p, 1) >= "0" && Mid(Param, p, 1) <= "9") p++;
	while (Mid(Param, p, 1) == " ") p++;

	if (Mid(Param, p) != "")
		return false;

	return true;
}

function array<string> SplitParams(string Params)
{
local array<string> Splitted;
local string Delim;
local int p, start;

	while (Params != "")
	{
		p = 0;
		while (Mid(Params, p, 1) == " ") p++;
		if (Mid(Params, p) == "")
			break;

		// Special case: Delimited string
		start = p;
		if (Mid(Params, p, 1) == "\"")
		{
			p++;
			start++;
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != "\"")
				p++;

			// Do not accept unfinished quoted strings
			if (Mid(Params, p, 1) == "\"")
			{
				Splitted[Splitted.Length] = Mid(Params, start, p-start);
				p++;
			}
		}
		else
		{
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != Delim)
				p++;
			Splitted[Splitted.Length] = Mid(Params, start, p-start);
		}
		Params = Mid(Params, p);
	}
	return Splitted;
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
     Msg_PlayerList="Player List:"
     Msg_FinishGameEditFirst="You must finish your Game Edit before restarting the map"
     Msg_FinishGameRestart="You must finish your Game Edit before changing or restarting the map"
     Msg_GameNoSupportBots="The current Game Type does not support Bots"
     Msg_StatsNoBots="Cannot control bots when Worlds Stats are enabled"
     Msg_NextMapNotFound="Next map not found; Restarting same map"
     Msg_ChangingMapTo="Changing Map to %NextMap%"
     Msg_PlayerBanned="%Player% has been banned from this server"
     Msg_SessionBanned="%Player% has been banned for this match"
     Msg_PlayerKicked="%Player% has been kicked"
     Msg_NoBotGameFull="Cannot add a bot, game is full."
     Msg_NoAddNamedBot="Can only add named bots once the match has started"
     Msg_NoBotsPlaying="No bots are currently playing"
     Msg_SetBotNeedVal="This command requires a numeric value between 0 and 32"
     Msg_MutNeedGameEdit="You must use 'Game Edit' command before 'Mutators' commands"
     Msg_NoMutatorInUse="No Mutators in use"
     Msg_NoUnusedMuts="Found no unused mutators"
     Msg_AddedMutator="Added '%Mutator%' to used mutator list."
     Msg_ErrAddingMutator="Error Adding '%Mutator%'To Used Mutator List"
     Msg_RemovedMutator="Removed '%Mutator%' From Used Mutator List"
     Msg_ErrRemovingMutator="Error Removing '%Mutator%' from used mutator List"
     Msg_MapListNeedGameEdit="You must use 'Game Edit' command before 'MapList' command"
     Msg_MapRotationList="Active maps for maplist %maplist%."
     Msg_NoMapInRotation="No maps configured for %maplist%."
     Msg_NoMapsAdded="No maps added to the maplist %maplist%."
     Msg_AddedMapToList="Maps successfully added to maplist"
     Msg_NoMapsRemoved="No maps were removed from the maplist %maplist%."
     Msg_RemovedMapFromList="Maps successfully removed from maplist"
     Msg_NoMapsFound="No matching maps in maplist %maplist% were found."
     Msg_MapIsInRotation="Matching %maplist% maps"
     Msg_MapNotInRotation="Matching maps which are not members of %maplist%."
     Msg_MustEndGameEdit="You must end your Game Edit first"
     Msg_EditingClass="Editing %Class%"
     Msg_EditFailed="Failed Starting To Edit"
     Msg_AlreadyEdited="Game Already being edited by Someone Else"
     Msg_NotEditing="You are not editing Game Settings, use 'Game Edit' first"
     Msg_EditingCompleted="Editing Completed"
     Msg_EditingCancelled="Editing Cancelled"
     Msg_UnknownParam="Unknown Parameter : %Value%"
     Msg_NoParamsFound="No Parameters found!"
     Msg_ParamModified="Modification SuccessFull"
     Msg_ParamNotModified="Could not Modify Parameter"
     Msg_EditingMapList="Now editing maplist"
     Msg_MapListAdded="Maplist %listname% successfully added for gametype"
     Msg_MapListRemoved="Maplist %listname% successfully removed from gametype"
     Msg_AllMapLists="Available maplists for %gametype%."
     Msg_AllGameMaps="Maps that are valid (can be added) to"
}
