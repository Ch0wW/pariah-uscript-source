// ====================================================================
//  Class:  XAdmin.xWebQueryAdmins
//  Parent: XWebAdmin.xWebQueryHandler
//
//  WebAdmin handler for activities related to managing the users / groups
//	that are allowed to log into the server
// ====================================================================

class xWebQueryAdmins extends xWebQueryHandler
	config;

// TODO:
// Fix log spam in adding groups function

struct RowGroup { var array<string>	rows; };

var config string AdminsIndexPage;
var config string UsersHomePage;
var config string UsersAccountPage;
var config string UsersAddPage;
var config string UsersBrowsePage;
var config string UsersEditPage;
var config string UsersGroupsPage;
var config string UsersMGroupsPage;
var config string GroupsAddPage;
var config string GroupsBrowsePage;
var config string GroupsEditPage;

var config string PrivilegeTable;

// Localization
var localized string NoteUserHomePage;
var localized string NoteAccountPage;
var localized string NoteUserAddPage;
var localized string NoteUserEditPage;
var localized string NoteUsersBrowsePage;
var localized string NoteGroupAddPage;
var localized string NoteGroupEditPage;
var localized string NoteGroupsBrowsePage;
var localized string NoteGroupAccessPage;
var localized string NoteMGroupAccessPage;

// Single words
var localized string NameText;
var localized string Deleting;
var localized string Group;
var localized string Groups;
var localized string User;
var localized string Modify;
var localized string Managed;
var localized string Privileges;
var localized string SecurityLevel;

// Title & Section Names
var localized string AdminPageTitle;
var localized string AdminHomeTitle;
var localized string AdminAccountTitle;
var localized string BrowseUsersTitle;
var localized string BrowseGroupsTitle;
var localized string AddUserTitle;
var localized string AddUserButton;
var localized string AddGroupTitle;
var localized string AddGroupButton;
var localized string EditUserTitle;
var localized string EditUserButton;
var localized string EditGroupTitle;
var localized string EditGroupButton;
var localized string ModifyUserGroup;
var localized string ModifyMUserGroup;

// Status messages
var localized string UserRemoved;
var localized string GroupRemoved;


// Error Messages
var localized string AdminNotFound;
var localized string GroupNotFound;
var localized string PrivTitle;

var localized string NoneText;
var localized string NoneItemText;
var localized string PasswordError;
var localized string InsufficientPrivs;
var localized string InvalidItem;
var localized string InvalidCharacters;
var localized string NameExists;
var localized string YouMustSelect;
var localized string DoesNotExist;
var localized string CouldNotCreate;
var localized string NegSecLevel;
var localized string CannotAssignHigher;
var localized string CannotAssignPrivs;

function bool Query(WebRequest Request, WebResponse Response)
{
	if (!CanPerform(NeededPrivs))
		return false;

	switch (Mid(Request.URI, 1))
	{
	case DefaultPage:		QueryAdminsFrame(Request, Response); return true;
	case AdminsIndexPage:	QueryAdminsMenu(Request, Response); return true;

	case UsersHomePage:		if (!MapIsChanging()) QueryUsersHomePage(Request, Response); return true;
	case UsersAccountPage:	if (!MapIsChanging()) QueryUserAccountPage(Request, Response); return true;
	case UsersBrowsePage:	if (!MapIsChanging()) QueryUsersBrowsePage(Request, Response); return true;
	case UsersAddPage:		if (!MapIsChanging()) QueryUsersAddPage(Request, Response); return true;
	case UsersEditPage:		if (!MapIsChanging()) QueryUsersEditPage(Request, Response); return true;
	case UsersGroupsPage:	if (!MapIsChanging()) QueryUsersGroupsPage(Request, Response); return true;
	case UsersMGroupsPage:	if (!MapIsChanging()) QueryUsersMGroupsPage(Request, Response); return true;
	case GroupsBrowsePage:	if (!MapIsChanging()) QueryGroupsBrowsePage(Request, Response); return true;
	case GroupsAddPage:		if (!MapIsChanging()) QueryGroupsAddPage(Request, Response); return true;
	case GroupsEditPage:	if (!MapIsChanging()) QueryGroupsEditPage(Request, Response); return true;
	}
	return false;
}

function QueryAdminsFrame(WebRequest Request, WebResponse Response)
{
local String Page;

	// if no page specified, use the default
	Page = Request.GetVariable("Page", UsersHomePage);

	Response.Subst("IndexURI", 	AdminsIndexPage$"?Page="$Page);
	Response.Subst("MainURI", 	Page);

	ShowPage(Response, DefaultPage);
}

function QueryAdminsMenu(WebRequest Request, WebResponse Response)
{
	Response.Subst("Title", 			AdminPageTitle);

	Response.Subst("UsersHomeURI", 		UsersHomePage);
	Response.Subst("UserAccountURI", 	UsersAccountPage);
	Response.Subst("UsersAddURI", 		UsersAddPage);
	Response.Subst("GroupsAddURI", 		GroupsAddPage);
	Response.Subst("UsersBrowseURI", 	UsersBrowsePage);
	Response.Subst("GroupsBrowseURI", 	GroupsBrowsePage);

	ShowPage(Response, AdminsIndexPage);
}

function QueryUsersHomePage(WebRequest Request, WebResponse Response)
{
	Response.Subst("AdminName", CurAdmin.UserName);
	Response.Subst("Section", AdminHomeTitle);
	Response.Subst("PageHelp", NoteUserHomePage);
	ShowPage(Response, UsersHomePage);
}

function QueryUserAccountPage(WebRequest Request, WebResponse Response)
{
local string upass;

	Response.Subst("NameValue", HtmlEncode(CurAdmin.UserName));
	if (Request.GetVariable("edit", "") != "")
	{
		// Can only change his password
		upass = Request.GetVariable("Password", CurAdmin.Password);
		if (!CurAdmin.ValidPass(upass))
			StatusError(Response, PasswordError);
		else if (upass != CurAdmin.Password)
		{
			CurAdmin.Password = upass;
			Level.Game.AccessControl.SaveAdmins();
		}
	}

	Response.Subst("PassValue", CurAdmin.Password);
	Response.Subst("PrivTable", GetPrivsTable(CurAdmin.Privileges, true));
	Response.Subst("GroupLinks", "");
	Response.Subst("SubmitValue", Accept);
	Response.Subst("PostAction", UsersAccountPage);
	Response.Subst("Section", AdminAccountTitle);
	Response.Subst("PageHelp", NoteAccountPage);
	ShowPage(Response, UsersAccountPage);
}

function QueryUsersBrowsePage(WebRequest Request, WebResponse Response)
{
local xAdminUser User;
local string tmp;

	if (CanPerform("Al|Aa|Ae|Ag|Am"))
	{
		// Delete an Admin
		if (Request.GetVariable("delete") != "")
		{
			// Delete specified Admin Group
			User = Level.Game.AccessControl.Users.FindByName(Request.GetVariable("delete"));
			if (User != None)
			{
				if (CurAdmin.CanManageUser(User))
				{
					StatusOk(Response, ReplaceTag(UserRemoved, "%UserName%", HtmlEncode(User.UserName)));
					// Remove User
					User.UnlinkGroups();
					Level.Game.AccessControl.Users.Remove(User);
					Level.Game.AccessControl.SaveAdmins();
				}
				else
				{
					tmp = ReplaceTag(InsufficientPrivs, "%Action%", Deleting);
					tmp = ReplaceTag(tmp, "%Item%", Group);
					StatusError(Response, tmp);
				}
			}
			else StatusError(Response, ReplaceTag(InvalidItem, "%Item%", Group));
		}
		// Show the list
		Response.Subst("BrowseList", GetUsersForBrowse(Response));

		Response.Subst("Section", BrowseUsersTitle);
		Response.Subst("PageHelp", NoteUsersBrowsePage);
		ShowPage(Response, UsersBrowsePage);
	}
	else
		AccessDenied(Response);
}

function QueryUsersAddPage(WebRequest Request, WebResponse Response)
{
local xAdminUser User;
local xAdminGroup Group;
local xAdminGroupList Groups;
local string uname, upass, uprivs, ugrp, ErrMsg;

	if (CanPerform("Aa"))
	{
		if (CurAdmin.bMasterAdmin)
			Groups = Level.Game.AccessControl.Groups;
		else
			Groups = CurAdmin.ManagedGroups;

		if (Request.GetVariable("addnew") != "")
		{
			// Humm .. AddNew
			uname = Request.GetVariable("Username");
			upass = Request.GetVariable("Password");
			uprivs = FixPrivs(Request, "");
			ugrp = Request.GetVariable("Usergroup");
			Group = Groups.FindByName(ugrp);

			if (!CurAdmin.ValidName(uname))
				ErrMsg = ReplaceTag(InvalidCharacters, "%Item%", User);
			else if (Level.Game.AccessControl.Users.FindByName(uname) != None)
				ErrMsg = NameExists@User;
			else if (!CurAdmin.ValidPass(upass))
				ErrMsg = PasswordError;
			else if (ugrp == "")
				ErrMsg = YouMustSelect@Group$"!";
			else if (Group == None)
				ErrMsg = ReplaceTag(DoesNotExist, "%Item%", Group);

			Response.Subst("NameValue", HtmlEncode(uname));
			Response.Subst("PassValue", upass);
			Response.Subst("PrivTable", GetPrivsTable(uprivs));

			if (ErrMsg == "")
			{
				// All settings are fine, create the new Group.
				User = Level.Game.AccessControl.Users.Create(uname, upass, uprivs);
				if (User != None)
				{
					User.AddGroup(Group);
					Level.Game.AccessControl.Users.Add(User);
					Level.Game.AccessControl.SaveAdmins();
				}
				else
				{
					// Only re-add the DDL if there was a problem.
					ErrMsg = CouldNotCreate@User$"!";
				}
			}

			if (ErrMsg != "")
				StatusError(Response, ErrMsg);
		}
		else
			Response.Subst("PrivTable", GetPrivsTable(""));

		if (User != None)
		{
			Response.Subst("PostAction", UsersEditPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", EditUserButton);
			Response.Subst("Section", EditUserTitle);
			Response.Subst("PageHelp", NoteUserEditPage);
			ShowPage(Response, UsersEditPage);
		}
		else
		{
			Response.Subst("Groups", GetGroupOptions(Groups, ugrp));
			Response.Subst("PostAction", UsersAddPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", AddUserButton);
			Response.Subst("Section", AddUserTitle);
			Response.Subst("PageHelp", NoteUserAddPage);
			ShowPage(Response, UsersAddPage);
		}
	}
	else
		AccessDenied(Response);
}

function QueryUsersEditPage(WebRequest Request, WebResponse Response)
{
local xAdminUser User;
local string uname, upass, privs, ErrMsg;

	if (CanPerform("Aa|Ae"))
	{
		ErrMsg = "";

		Response.Subst("Section", EditUserTitle);

		User = Level.Game.AccessControl.GetUser(Request.GetVariable("edit"));
		if (User != None)
		{
			if (CurAdmin.CanManageUser(User))
			{
				// Operations
				if (Request.GetVariable("mod") != "")
				{
					// Validate the changes and modify the user information
					uname = Request.GetVariable("Username");
					upass = Request.GetVariable("Password");
					privs = FixPrivs(Request, User.Privileges);
					if (uname != User.UserName)
					{
						if (User.ValidName(uname))
						{
							if (Level.Game.AccessControl.GetUser(uname) == None)
								User.UserName = uname;
							else
								ErrMsg = NameExists@User;
						}
						else
							ErrMsg = ReplaceTag(InvalidCharacters, "%Item%", User);
					}

					if (ErrMsg == "" && !(upass == User.Password))
					{
						if (User.ValidPass(upass))
							User.Password = upass;
						else
							ErrMsg = PasswordError;
					}

					if (ErrMsg == "" && privs != User.Privileges)
					{
						User.Privileges = privs;
						User.RedoMergedPrivs();
					}
					if (ErrMsg == "")
						Level.Game.AccessControl.SaveAdmins();
				}

				if (ErrMsg != "")
					StatusError(Response, ErrMsg);

				Response.Subst("NameValue", HtmlEncode(User.UserName));
				Response.Subst("PassValue", HtmlEncode(User.Password));
				Response.Subst("PrivTable", GetPrivsTable(User.Privileges));
				Response.Subst("PostAction", UsersEditPage);
				Response.Subst("SubmitName", "mod");
				Response.Subst("SubmitValue", EditUserButton);
				Response.Subst("PageHelp", NoteUserEditPage);
				ShowPage(Response, UsersEditPage);
			}
			else
			{
				ErrMsg = ReplaceTag(InsufficientPrivs, "%Action%", Modify);
				ErrMsg = ReplaceTag(ErrMsg, "%Item%", User);
				ShowMessage(Response, PrivTitle, ErrMsg);
			}
		}
		else
			ShowMessage(Response, AdminNotFound, ReplaceTag(DoesNotExist, "%Item%", User));
	}
	else
		AccessDenied(Response);
}

function QueryUsersGroupsPage(WebRequest Request, WebResponse Response)
{
local xAdminUser		User;
local xAdminGroupList	Groups;
local xAdminGroup		Group;
local StringArray	  GrpNames;
local string GroupRows, GrpName, Str;
local int i;
local bool bModify, bChecked;

	if (CanPerform("Ag"))
	{
		User = Level.Game.AccessControl.Users.FindByName(Request.GetVariable("edit"));
		if (User != None)
		{
			if (CurAdmin.CanManageUser(User))
			{
				if (CurAdmin.bMasterAdmin)
					Groups = Level.Game.AccessControl.Groups;
				else
					Groups = CurAdmin.ManagedGroups;

				// Work with a table of checkboxes now
				GroupRows = "";
				bModify = (Request.GetVariable("submit") != "");

				// Make a sorted list of Groups
				GrpNames = new(None)class'SortedStringArray';
				for (i=0; i<Groups.Count(); i++)
					GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

				for (i=0; i<GrpNames.Count(); i++)
				{
					GrpName = GrpNames.GetItem(i);
					Group = Groups.FindByName(GrpName);
					bChecked = Request.GetVariable(GrpName) != "";

					if (bModify)
					{
						if (User.Groups.Contains(Group))
						{
							if (!bChecked)	// Remove the user from the group
								User.RemoveGroup(Group);
						}
						else
						{
							if (bChecked)
								User.AddGroup(Group);
						}
					}
					Response.Subst("GroupName", GrpName);

					Str = "";
					if (User.Groups.Contains(Group))
						Str = " checked";
					Response.Subst("Checked", Str);
					GroupRows += WebInclude("users_groups_row");
				}

				if (bModify)
					Level.Game.AccessControl.SaveAdmins();

				// Now just build up the page as a table with checkboxes
				Response.Subst("NameValue", HtmlEncode(User.UserName));
				Response.Subst("GroupRows", GroupRows);
				Response.Subst("PostAction", UsersGroupsPage);
				Response.Subst("Section", ModifyUserGroup@HtmlEncode(User.UserName));
				Response.Subst("PageHelp", NoteGroupAccessPage);
				ShowPage(Response, UsersGroupsPage);
			}
			else
			{
				Str = ReplaceTag(InsufficientPrivs, "%Action%", Modify);
				Str = ReplaceTag(Str, "%Item%", User);
				ShowMessage(Response, PrivTitle, Str);
			}
		}
		else
			ShowMessage(Response, AdminNotFound, ReplaceTag(DoesNotExist, "%Item%", User));
	}
	else
		AccessDenied(Response);
}

function QueryUsersMGroupsPage(WebRequest Request, WebResponse Response)
{
local xAdminUser		User;
local xAdminGroupList	Groups;
local xAdminGroup		Group;
local StringArray	  GrpNames;
local string GroupRows, GrpName, Str;
local int i;
local bool bModify, bChecked;

	if (CanPerform("Am"))
	{

		User = Level.Game.AccessControl.Users.FindByName(Request.GetVariable("edit"));
		if (User != None)
		{
			if (CurAdmin.CanManageUser(User))
			{
				if (CurAdmin.bMasterAdmin)
					Groups = Level.Game.AccessControl.Groups;
				else
					Groups = CurAdmin.ManagedGroups;

				// Work with a table of checkboxes now
				GroupRows = "";
				bModify = (Request.GetVariable("submit") != "");

				// Make a sorted list of Groups
				GrpNames = new(None)class'SortedStringArray';
				for (i=0; i<Groups.Count(); i++)
					GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

				for (i=0; i<GrpNames.Count(); i++)
				{
					GrpName = GrpNames.GetItem(i);
					Group = Groups.FindByName(GrpName);
					bChecked = Request.GetVariable(GrpName) != "";

					if (bModify)
					{
						if (User.ManagedGroups.Contains(Group))
						{
							if (!bChecked)	// Remove the user from the group
								User.RemoveManagedGroup(Group);
						}
						else
						{
							if (bChecked)
								User.AddManagedGroup(Group);
						}
					}
					Response.Subst("GroupName", GrpName);

					Str = "";
					if (User.ManagedGroups.Contains(Group))
						Str = " checked";
					Response.Subst("Checked", Str);
					GroupRows += WebInclude("users_groups_row");
				}

				if (bModify)
					Level.Game.AccessControl.SaveAdmins();

				// Now just build up the page as a table with checkboxes
				Response.Subst("Managed", Managed);
				Response.Subst("NameValue", HtmlEncode(User.UserName));
				Response.Subst("GroupRows", GroupRows);
				Response.Subst("PostAction", UsersMGroupsPage);
				Response.Subst("Section", ModifyMUserGroup@HtmlEncode(User.UserName));
				Response.Subst("PageHelp", NoteMGroupAccessPage);
				ShowPage(Response, UsersGroupsPage);
			}
			else
			{
				Str = ReplaceTag(InsufficientPrivs, "%Action%", Modify);
				Str = ReplaceTag(Str, "%Item%", User);
				ShowMessage(Response, PrivTitle, Str);
			}
		}
		else
			ShowMessage(Response, AdminNotFound, ReplaceTag(DoesNotExist, "%Item%", User));
	}
	else
		AccessDenied(Response);
}

function QueryGroupsBrowsePage(WebRequest Request, WebResponse Response)
{
local xAdminGroup Group;
local string Str;

	if (CanPerform("Gl|Ge"))
	{
		Response.Subst("Section", BrowseGroupsTitle);
		if (Request.GetVariable("delete") != "")
		{
			// Delete specified Admin Group
			Group = Level.Game.AccessControl.Groups.FindByName(Request.GetVariable("delete"));
			if (Group != None)
			{
				if (CurAdmin.CanManageGroup(Group))
				{
					StatusOk(Response, ReplaceTag(GroupRemoved, "%GroupName%", HtmlEncode(Group.GroupName)));
					Group.UnlinkUsers();
					Level.Game.AccessControl.Groups.Remove(Group);
					Level.Game.AccessControl.SaveAdmins();
				}
				else
				{
					Str = ReplaceTag(InsufficientPrivs, "%Action%", Deleting);
					Str = ReplaceTag(Str, "%Item%", Group);
					StatusError(Response, Str);
				}
			}
			else
				StatusError(Response, ReplaceTag(InvalidItem, "%Item%", Group));
		}
		Response.Subst("BrowseList", GetGroupsForBrowse(Response));
		Response.Subst("PageHelp", NoteGroupsBrowsePage);
		ShowPage(Response, GroupsBrowsePage);
	}
	else
		AccessDenied(Response);
}

function QueryGroupsAddPage(WebRequest Request, WebResponse Response)
{
local xAdminGroup Group;
local string gname, gprivs, ErrMsg;
local int gsec;

	if (CanPerform("Ga"))
	{
		if (Request.GetVariable("addnew") != "")
		{
			// Humm .. AddNew
			gname = Request.GetVariable("GroupName");
			gprivs = FixPrivs(Request, "");
			gsec = int(Request.GetVariable("GameSec"));

			if (!class'xAdminGroup'.static.ValidName(gname))
				ErrMsg = ReplaceTag(InvalidCharacters, "%Item%", gname);
			else if (Level.Game.AccessControl.Groups.FindByName(gname) != None)
				ErrMsg = NameExists@Group$"!";
			else if (gsec < 0)
				ErrMsg = NegSecLevel;
			else if (gsec > CurAdmin.MaxSecLevel())
				ErrMsg = CannotAssignHigher;

			Response.Subst("NameValue", HtmlEncode(gname));
			Response.Subst("PrivTable", GetPrivsTable(gprivs));
			Response.Subst("GameSecValue", string(gsec));

			if (ErrMsg == "")
			{
				// All settings are fine, create the new Group.
				Group = Level.Game.AccessControl.Groups.CreateGroup(gname, gprivs, byte(gsec));
				if (Group != None)
				{
					CurAdmin.AddManagedGroup(Group);
					Level.Game.AccessControl.Groups.Add(Group);
					Level.Game.AccessControl.SaveAdmins();
				}
				else
					ErrMsg = CouldNotCreate@Group$"!";
			}

			if (ErrMsg != "")
				StatusError(Response, ErrMsg);
		}
		else
			Response.Subst("PrivTable", GetPrivsTable(""));

		if (Group != None)
		{
			Response.Subst("PostAction", GroupsEditPage);
			Response.Subst("SubmitName", "mod");
			Response.Subst("SubmitValue", EditGroupButton);
			Response.Subst("PageHelp", NoteGroupEditPage);
			Response.Subst("Section", EditGroupTitle);
		}
		else
		{
			Response.Subst("PostAction", GroupsAddPage);
			Response.Subst("SubmitName", "addnew");
			Response.Subst("SubmitValue", AddGroupButton);
			Response.Subst("Section", AddGroupTitle);
			Response.Subst("PageHelp", NoteGroupAddPage);
		}
		ShowPage(Response, GroupsEditPage);
	}
	else
		AccessDenied(Response);
}

function QueryGroupsEditPage(WebRequest Request, WebResponse Response)
{
local xAdminGroup Group;
local string ErrMsg, gname, gprivs;
local int gsec;

	if (CanPerform("Gm"))
	{
		Response.Subst("Section", EditGroupTitle);

		Group = Level.Game.AccessControl.Groups.FindByName(Request.GetVariable("edit"));
		if (Group != None)		// Do not let admins fake the system.
		{
			if (CurAdmin.CanManageGroup(Group))
			{
				if (Request.GetVariable("mod") != "")
				{
					// Save the changes
					gname = Request.GetVariable("GroupName");
					gprivs = FixPrivs(Request, Group.Privileges);
					gsec = Clamp(int(Request.GetVariable("GameSec")), 0, 255);
					if (gname != Group.GroupName)
					{
						if (Group.ValidName(gname))
						{
							if (Level.Game.AccessControl.Groups.FindByName(gname) == None)
								Group.GroupName = gname;
							else
								ErrMsg = ReplaceTag(NameExists, "%Item%", Group);
						}
						else
							ErrMsg = ReplaceTag(InvalidCharacters, "%Item%", Group);
					}

					if (ErrMsg == "")
					{
						if (gprivs != Group.Privileges)
							Group.SetPrivs(gprivs);

						Group.GameSecLevel = gsec;
						Level.Game.AccessControl.SaveAdmins();
					}
				}

				if (ErrMsg != "")
					StatusError(Response, ErrMsg);

				Response.Subst("NameValue", HtmlEncode(Group.GroupName));
				Response.Subst("PrivTable", GetPrivsTable(Group.Privileges));
				Response.Subst("GameSecValue", string(Group.GameSecLevel));
				Response.Subst("PostAction", GroupsEditPage);
				Response.Subst("SubmitName", "mod");
				Response.Subst("SubmitValue", EditGroupButton);
				Response.Subst("PageHelp", NoteGroupEditPage);
				ShowPage(Response, GroupsEditPage);
			}
			else
			{
				ErrMsg = ReplaceTag(InsufficientPrivs, "%Action%", Modify);
				ErrMsg = ReplaceTag(ErrMsg, "%Item%", Group);
				ShowMessage(Response, PrivTitle, ErrMsg);
			}
		}
		else
			ShowMessage(Response, GroupNotFound, ReplaceTag(DoesNotExist, "%Item%", Group));
	}
	else
		AccessDenied(Response);
}

// Must not forget to show only the Users from groups that the admin can manage
function string GetUsersForBrowse(WebResponse Response)
{
local ObjectArray	Users;
local xAdminUser	User;
local string OutStr, Tmp;
local int i;
local bool CanDelete;

	CanDelete = CanPerform("Aa");
	Users = ManagedUsers();

	// Now, just make the users list a bunch of Rows
	if (Users.Count() == 0)
	{
		Response.Subst("Content", ReplaceTag(NoneItemText, "%Item%", User));
		Response.Subst("RowContent", WebInclude(CellLeft));
		return WebInclude(RowLeft);
	}

	Response.Subst("Content", NameText);
	Tmp = WebInclude(CellLeft);
	Response.Subst("Content", Privileges);
	Tmp = Tmp $ WebInclude(CellLeft);
	Response.Subst("Content", "&nbsp;");
	Tmp = StringIf(CanDelete, Tmp $ WebInclude(CellLeft), Tmp);
	Response.Subst("RowContent", Tmp);
	OutStr = WebInclude(RowLeft);

	for (i = 0; i<Users.Count(); i++)
	{
		User = xAdminUser(Users.GetItem(i));
		Response.Subst("Username", Hyperlink(UsersEditPage$"?edit="$HtmlEncode(User.UserName), HtmlEncode(User.UserName), CanPerform("Ae|Aa")));
		Response.Subst("Privileges", User.Privileges);
		Response.Subst("Groups", StringIf(CanPerform("Ag"), Hyperlink(UsersGroupsPage$"?edit="$HtmlEncode(User.UserName),Groups, true), ""));
		Response.Subst("Managed", StringIf(CanPerform("Am"), Hyperlink(UsersMGroupsPage$"?edit="$HtmlEncode(User.UserName),Managed$Groups, true), ""));
		Response.Subst("Delete", StringIf(CanDelete, Hyperlink(UsersBrowsePage$"?delete="$HtmlEncode(User.UserName), DeleteText, true), ""));
		OutStr += WebInclude("users_row");
	}
	return OutStr;
}

// Must not forget to show only the Groups that the admin can add users to
function string GetGroupsForBrowse(WebResponse Response)
{
local xAdminGroup	Group;
local xAdminGroupList Groups;
local string OutStr, Tmp;
local int i;
local bool CanDelete, CanEdit;

	CanDelete = CanPerform("Gd");
	CanEdit = CanPerform("Ge");
	if(CurAdmin.bMasterAdmin) Groups = Level.Game.AccessControl.Groups;
	else Groups = CurAdmin.ManagedGroups;

	if (Groups.Count() == 0)
	{
		Response.Subst("Content", ReplaceTag(NoneItemText, "%Item%", Group));
		Response.Subst("RowContent", WebInclude(CellLeft));
		return WebInclude(RowLeft);
	}

	Response.Subst("Content", NameText);
	Tmp = WebInclude(CellLeft);
	Response.Subst("Content", Privileges);
	Tmp = Tmp $ WebInclude(CellLeft);
	Response.Subst("Content", SecurityLevel);
	Tmp = Tmp $ WebInclude(CellLeft);
	Response.Subst("Content", "&nbsp;");
	Tmp = StringIf(CanDelete, Tmp $ WebInclude(CellLeft), Tmp);
	Response.Subst("RowContent", Tmp);
	OutStr = WebInclude(RowLeft);

	for (i=0; i<Groups.Count(); i++)
	{
		Group = Groups.Get(i);
		// Build 1 Group Row
		Response.Subst("Groupname", Hyperlink(GroupsEditPage$"?edit="$HtmlEncode(Group.GroupName),HtmlEncode(Group.GroupName),true));
		Response.Subst("Privileges", Group.Privileges);
		Response.Subst("Gamesec", string(Group.GameSecLevel));
		Response.Subst("Delete", StringIf(CanDelete, HyperLink(GroupsBrowsePage $ "?delete=" $ HtmlEncode(Group.GroupName), DeleteText, True), ""));
		OutStr += WebInclude("groups_row");
	}
	return OutStr;
}

function string GetPrivsHeader(string privs, string text, bool cond, string tag)
{
	Resp.Subst("Checkbox", Checkbox(Tag, Instr("|"$privs$"|", "|"$tag$"|") != -1, !cond));
	Resp.Subst("Text", text);
	return WebInclude("privs_header");
}

function string GetPrivsItem(string privs, string text, bool cond, string tag, optional bool bReadOnly)
{
	local string S;
	if (!cond)
		return "";

	Cond = InStr("|" $ Privs $ "|", "|" $ Tag $ "|") != -1;
	while (Privs != "" && Cond == True)
	{
		S = NextPriv(Privs);
		if (S == Left(Tag,1))
			Cond = False;
	}

	Resp.Subst("Checkbox", Checkbox(Tag, Cond, !bReadOnly));
	Resp.Subst("Text", text);
	return WebInclude("privs_element");
}

function ObjectArray ManagedUsers()
{
local ObjectArray Users;
local int i, j;
local xAdminGroup Group;
local xAdminUser User;
local xAdminGroupList Groups;

	Users = New(None) class'SortedObjectArray';
	if (CurAdmin.bMasterAdmin) Groups = Level.Game.AccessControl.Groups;
	else Groups = CurAdmin.ManagedGroups;

	for (i=0; i<Groups.Count(); i++)
	{
		Group = Groups.Get(i);
		for (j=0; j<Group.Users.Count(); j++)
		{
			User = Group.Users.Get(j);
			if (Users.FindTagId(User.UserName) < 0)
				Users.Add(User, User.UserName);
		}
	}
	return Users;
}

function string MakePrivsTable(xPrivilegeBase PM, string privs, bool bReadOnly)
{
local int TagIndex, CurCol, maxcols;
local string MainStr, SubStr, Main, SPriv, OutStr;
local string PrivHeader, PrivItems;
local bool   bShowPrivGroup, bHasPriv, bCanEdit;

	MainStr = PM.MainPrivs;
	OutStr = "";
	TagIndex = 0;
	maxcols = 3;
	CurCol = 1;
	while (MainStr != "")
	{
		// Step 1: Check for a main privilege type
		Main = NextPriv(MainStr);
		SubStr = PM.SubPrivs;
		bShowPrivGroup = CheckPrivilegeGroup(Main, SubStr);

		// If we could manage anything, lets make checkboxes for them
		bCanEdit = CanPerform(Main) && !bReadOnly;
		PrivHeader = "";
		PrivHeader = GetPrivsHeader(privs, PM.Tags[TagIndex++], bCanEdit, Main);
		while (SubStr != "")
		{
			SPriv = NextPriv(SubStr);
			// Only allow manager to modify privileges that he has access to
			bHasPriv = CanPerform(SPriv);
			bCanEdit = !bReadOnly && bHasPriv;
			if (Left(SPriv,1) == Main && bShowPrivGroup && bHasPriv)
			{
				if (CurCol > maxcols)
				{
					CurCol = 1;
					PrivItems += "</tr><tr>";
				}

				PrivItems += GetPrivsItem(privs, PM.Tags[TagIndex++], true, SPriv, bCanEdit);
				CurCol++;
			}
		}

		if (bShowPrivGroup)
		{
			Resp.Subst("PrivilegeRows", PrivItems);
			OutStr = OutStr $ PrivHeader $ WebInclude(PrivilegeTable);
		}
	}
	return OutStr;
}

function string GetPrivsTable(string privs, optional bool bNoEdit)
{
local string str;
local int i;

	// Start by getting all rows for known privilege groups
	str = "";
	for (i=0; i<Level.Game.AccessControl.PrivManagers.Length; i++)
		str = str$MakePrivsTable(Level.Game.AccessControl.PrivManagers[i], privs, bNoEdit);

	if (str == "")
		str = CannotAssignPrivs;
	return str;
}

// This function determines which privileges will appear as checked in webadmin
function string FixPrivs(WebRequest Request, string oldprivs)
{
local string privs, myprivs, priv;

// Can only modify settings that I have access to
	if (CurAdmin.bMasterAdmin)
		myprivs = Level.Game.AccessControl.AllPrivs;
	else
		myprivs = CurAdmin.MergedPrivs;

	privs = "";

	// Keep any privs which the currently logged in admin does not have
	while (oldprivs != "")
	{
		priv = NextPriv(oldprivs);
		if (Instr("|"$myprivs$"|", "|"$priv$"|") == -1)
		{
			if (Privs != "") Privs += "|";
			Privs += Priv;
		}
	}

	// If this priv is checked, and the Main priv for the group is not checked, add the priv
	while (myprivs != "")
	{
		priv = NextPriv(myprivs);
		if (Request.GetVariable(priv) != "" &&
			InStr("|" $ Privs $ "|", "|" $ Left(Priv, 1) $ "|") == -1)
		{
			if (Privs != "") Privs += "|";
			Privs += Priv;
		}
	}
	return privs;
}

function string GetGroupOptions(xAdminGroupList Groups, string grpsel)
{
local int i;
local string OutStr, GrpName;
local StringArray	  GrpNames;

	if (Groups.Count() == 0)
		return "<option value=\"\">"$NoneText$"</option>";

	// Step 1: Sort the groups
	GrpNames = new(None) class'SortedStringArray';
	for (i=0; i<Groups.Count(); i++)
		GrpNames.Add(Groups.Get(i).GroupName, Groups.Get(i).GroupName);

	if (GrpNames.Count() == 0)
		return "<option value=\"\">" $ NoneText $ "</option>";

	// Step 2: Build the group list
	OutStr = "";
	for (i=0; i<GrpNames.Count(); i++)
	{
		GrpName = GrpNames.GetItem(i);
		OutStr = OutStr$"<option value='"$GrpName$"'";
		if (GrpName == grpsel)
			OutStr = OutStr$" selected";
		OutStr = OutStr$">"$HtmlEncode(GrpName)$"</option>";
	}
	return OutStr;
}

// Returns true if we have any of the privilege from this priv group
function bool CheckPrivilegeGroup(string MainPriv, string SubPrivs)
{
	local string Tmp;

	if (CanPerform(MainPriv))
		return true;

	while (SubPrivs != "")
	{
		Tmp = NextPriv(SubPrivs);
		if (CanPerform(Tmp))
			return true;
	}

	return false;
}

defaultproperties
{
     AdminsIndexPage="admins_menu"
     UsersHomePage="admins_home"
     UsersAccountPage="admins_account"
     UsersAddPage="users_add"
     UsersBrowsePage="users_browse"
     UsersEditPage="users_edit"
     UsersGroupsPage="users_groups"
     UsersMGroupsPage="users_mgroups"
     GroupsAddPage="groups_add"
     GroupsBrowsePage="groups_browse"
     GroupsEditPage="groups_edit"
     PrivilegeTable="admins_priv_table"
     NoteUserHomePage="Welcome to Admins &amp; Groups Management"
     NoteAccountPage="Here you can change your password if required. You can also see which privileges were assigned to you by your manager."
     NoteUserAddPage="As an Admin of this server you can add new Admins and give them privileges. Make sure that the password assigned to the new Admin is not easy to hack."
     NoteUserEditPage="As an Admin of this server you can modify informations and privileges for another Admin that you can Manage."
     NoteUsersBrowsePage="Here you can see other Admins that you can manage and modify their privilege and groups assignment."
     NoteGroupAddPage="You can create new groups which will have a common set of privileges. Groups are used to give the same privileges to multiple Admins."
     NoteGroupEditPage="You can modify which privileges were assigned to this group. Note that you can only change privileges that you have yourself."
     NoteGroupsBrowsePage="Here you can see all the groups that you can manage, click on a group name to modify it."
     NoteGroupAccessPage="Here you can decide in which groups the selected admin will be part of. This will decide which base privileges this admin will have."
     NoteMGroupAccessPage="Here you can decide which groups this admin will be able to manage. He will be able to assign other admins to this group."
     NameText="Name"
     Deleting="deleting"
     Group="group"
     Groups="Groups"
     User="user"
     Modify="modify"
     Managed="Managed "
     Privileges="Privileges"
     SecurityLevel="Security Level"
     AdminPageTitle="Users &amp; Groups Management"
     AdminHomeTitle="Admin Home Page"
     AdminAccountTitle="Account"
     BrowseUsersTitle="Browse Available Users"
     BrowseGroupsTitle="Browse Available Groups"
     AddUserTitle="Add a New Administrator"
     AddUserButton="Add Admin"
     AddGroupTitle="Add New Administration Group"
     AddGroupButton="Add Group"
     EditUserTitle="Modify an Administrator"
     EditUserButton="Modify Admin"
     EditGroupTitle="Modify an Administration Group"
     EditGroupButton="Modify Group"
     ModifyUserGroup="Modify Groups for"
     ModifyMUserGroup="Modify Managed Groups for"
     UserRemoved="User '%UserName%' was removed!"
     GroupRemoved="Group '%GroupName%' was removed!"
     AdminNotFound="Admin Not Found"
     GroupNotFound="Group Not Found"
     PrivTitle="Insufficient Privileges"
     NoneText="*** None ***"
     NoneItemText="** There are no %Item%s to list **"
     PasswordError="Invalid characters in password or password not at least 6 characters."
     InsufficientPrivs="Your privileges prevent you from %Action% this %Item%."
     InvalidItem="Invalid %Item% name specified!"
     InvalidCharacters="Invalid characters in %Item% name!"
     NameExists="Must specify a unique name for"
     YouMustSelect="You must select a"
     DoesNotExist="The selected %Item% does not exist!"
     CouldNotCreate="Exceptional error creating new"
     NegSecLevel="Negative security level is invalid!"
     CannotAssignHigher="You cannot assign a security level higher than yours"
     CannotAssignPrivs="You cannot assign privileges"
     DefaultPage="adminsframe"
     Title="Admins & Groups"
     NeededPrivs="A|G|Al|Aa|Ae|Ag|Am|Gl|Ga|Ge"
}
