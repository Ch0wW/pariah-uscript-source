//=============================================================================
// Mutator.
//
// Mutators allow modifications to gameplay while keeping the game rules intact.  
// Mutators are given the opportunity to modify player login parameters with 
// ModifyLogin(), to modify player pawn properties with ModifyPlayer(), to change 
// the default weapon for players with GetDefaultWeapon(), or to modify, remove, 
// or replace all other actors when they are spawned with CheckRelevance(), which 
// is called from the PreBeginPlay() function of all actors except those (Decals, 
// Effects and Projectiles for performance reasons) which have bGameRelevant==true.
//=============================================================================
class Mutator extends Info
    DependsOn(GameInfo)
    native;

var Mutator NextMutator;
var class<Weapon> DefaultWeapon;
var string DefaultWeaponName;
var bool SinglePlayerOnly; // sjs - allows sharing of _some_ singleplayer mutators for multiplayer fun
var bool ListInServerBrowser; // gam
var int AffectedTeamIndex; // sjs - the team index this mutator's affect should apply to (255==all teams)
var() float SinglePlayerValue; // sjs - the value of the gamepowerup when calculating singleplayer rewards
var bool bUserAdded;		// mc - mutator was added by user (cmdline or mutator list)
var bool OnByDefault;       // UI logic for mutator is reversed (can you smell the hack-sauce?)

var() string            IconMaterialName;
var() string            ConfigMenuClassName;
var() string            GroupName; // Will only allow one mutator with this tag to be selected.
var() localized string  FriendlyName;
var() localized string  Description;

enum ETeamBias
{
    ETB_Owner,
    ETB_Other,
    ETB_All
};

var() ETeamBias TeamBias;

/* Don't call Actor PreBeginPlay() for Mutator 
*/
event PreBeginPlay()
{
}

// sjs - returns true if the mutator should apply its affect
function bool CheckTeamFilter(Pawn p)
{
    if( AffectedTeamIndex==255 )
        return true;

    if( p.PlayerReplicationInfo != None && p.PlayerReplicationInfo.Team != None )
    {
        if( p.PlayerReplicationInfo.Team.TeamIndex == AffectedTeamIndex )
            return true;
    }
    return false;
}

function ModifyLogin(out string Portal, out string Options)
{
	if ( NextMutator != None )
		NextMutator.ModifyLogin(Portal, Options);
}

/* called by GameInfo.RestartPlayer()
	change the players jumpz, etc. here
*/
function ModifyPlayer(Pawn Other)
{
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

/* return what should replace the default weapon
   mutators further down the list override earlier mutators
*/
function Class<Weapon> GetDefaultWeapon()
{
	local Class<Weapon> W;

	//log("GetDefaultWeapon");

	if ( NextMutator != None )
	{
		W = NextMutator.GetDefaultWeapon();
		if ( W == None )
			W = MyDefaultWeapon();
	}
	else
		W = MyDefaultWeapon();
	return W;
}

/* GetInventoryClass()
return an inventory class - either the class specified by InventoryClassName, or a 
replacement.  Called when spawning initial inventory for player
*/
function Class<Inventory> GetInventoryClass(string InventoryClassName)
{
	InventoryClassName = GetInventoryClassOverride(InventoryClassName);
	if ( InventoryClassName!="" )
		return class<Inventory>(DynamicLoadObject(InventoryClassName, class'Class'));
	else
		return None;
}

/* GetInventoryClassOverride()
return the string passed in, or a replacement class name string.
*/
function string GetInventoryClassOverride(string InventoryClassName)
{
	// here, in mutator subclass, change InventoryClassName if desired.  For example:
	// if ( InventoryClassName == "Weapons.DorkyDefaultWeapon"
	//		InventoryClassName = "ModWeapons.SuperDisintegrator"

	if ( NextMutator != None )
		return NextMutator.GetInventoryClassOverride(InventoryClassName);
	return InventoryClassName;
}

function class<Weapon> MyDefaultWeapon()
{
	if ( (DefaultWeapon == None) && (DefaultWeaponName != "") )
		DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));

	return DefaultWeapon;
}

function AddMutator(Mutator M)
{
    // gam ---
	if ( GroupName != "" && M.GroupName == GroupName )
	{
        log(M$" not allowed (already have" @ GroupName @ "mutator: "$ M $" )", 'Error');
		return;
	}
	// --- gam

	if ( NextMutator == None )
		NextMutator = M;
	else
		NextMutator.AddMutator(M);
}

/* ReplaceWith()
Call this function to replace an actor Other with an actor of aClass.
*/
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		return false;
	if ( aClassName != "" )
		aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location 
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

/* Force game to always keep this actor, even if other mutators want to get rid of it
*/
function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	bResult = CheckReplacement(Other, bSuperRelevant);
	if ( bResult && (NextMutator != None) )
		bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckRelevance(Actor Other)
{
	local bool bResult;
	local byte bSuperRelevant;

	if ( AlwaysKeep(Other) )
		return true;

	// allow mutators to remove actors

	bResult = IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

//
// Called when a player sucessfully changes to a new class
//
function PlayerChangedClass(Controller aPlayer)
{
	NextMutator.PlayerChangedClass(aPlayer);
}

// sjs - called game events, todo: hook this up to stuff
function EventNotify(Pawn Other,Pawn Instigator,Name EventName, float Value)
{
    if ( NextMutator != None )
		NextMutator.EventNotify(Other, Instigator, EventName, value);
}

//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = RetrivePlayerName();
}

function GetServerPlayers( out GameInfo.ServerResponseLine ServerState )
{
}

// jmw - Allow mod authors to hook in to the %X var parsing

function string ParseChatPercVar(Controller Who, string Cmd)
{
	if (NextMutator !=None)
		Cmd = NextMutator.ParseChatPercVar(Who,Cmd);
		
	return Cmd;
}

function MutatorFillPlayInfo(PlayInfo PlayInfo)
{
	FillPlayInfo(PlayInfo);

	if (NextMutator != None)
    	NextMutator.MutatorFillPlayInfo(PlayInfo);
}

defaultproperties
{
     AffectedTeamIndex=255
     IconMaterialName="InterfaceContent.Controller.ControllerS"
     FriendlyName="Mutator"
     Description="Description"
     ListInServerBrowser=True
}
