//=============================================================================
// UnrealTeamInfo.
// includes list of bots on team for multiplayer games
// 
//=============================================================================

class UnrealTeamInfo extends TeamInfo
	placeable;

var() RosterEntry DefaultRosterEntry;
var() export editinline array<RosterEntry> Roster;
var() class<UnrealPawn> AllowedTeamMembers[32];
var() byte TeamAlliance;
var int DesiredTeamSize;
var TeamAI AI;
var Color HudTeamColor;
var int NextAvailPlayerIndex; //amb

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	if ( !UnrealMPGameInfo(Level.Game).bTeamScoreRounds )
		Score = 0;
}

simulated function class<Pawn> NextLoadOut(class<Pawn> CurrentLoadout)
{
	local int i;
	local class<Pawn> Result;

	Result = AllowedTeamMembers[0];

	for ( i=0; i<ArrayCount(AllowedTeamMembers) - 1; i++ )
	{
		if ( AllowedTeamMembers[i] == CurrentLoadout )
		{
			if ( AllowedTeamMembers[i+1] != None )
				Result = AllowedTeamMembers[i+1];
			break;
		}
		else if ( AllowedTeamMembers[i] == None )
			break;
	}

	return Result;
}

function bool NeedsBotMoreThan(UnrealTeamInfo T)
{
	return ( (DesiredTeamSize - Size) > (T.DesiredTeamSize - T.Size) );
}

// amb ---
// players are in starting lineup order... need a menu option to specify this!
function RosterEntry ChooseBotClass(optional string botName)
{
    if (botName == "")
        return GetNextBot();

    return GetNamedBot(botName);
}

function RosterEntry GetNextBot()
{
    local RosterEntry re;

    // jjs - temp. allow reuse of roster slots until roster gets populated.
    if (NextAvailPlayerIndex >= Roster.Length)
        NextAvailPlayerIndex = 0;
    re = Roster[NextAvailPlayerIndex++];
    return re;

    //do 
    //{
    //    if (NextAvailPlayerIndex >= Roster.Length)
    //    {
    //        log("Requesting more players than available, Roster.Length="$Roster.Length, 'Error');
    //        return None;
    //    }

    //    re = Roster[NextAvailPlayerIndex++];

    //} until (re != None && re.bTaken==false);

    //re.bTaken = true;

    //return re;
}

function RosterEntry GetNamedBot(string botName)
{
    local RosterEntry re;
    local int i;

    for (i=0; i<Roster.Length; i++)
    {
        // TODO: bot customizing may break this
        if (Roster[i].PlayerName ~= botName && !Roster[i].bTaken)
        {
            re = Roster[i];
            re.bTaken = true;
            return re;
        }
    }

    // not found or taken already...
    return GetNextBot();
}
// --- amb

function bool AddToTeam( Controller Other )
{
	local bool bResult;

	bResult = Super.AddToTeam(Other);

	if ( bResult && (Other.PawnClass != None) && !BelongsOnTeam(Other.PawnClass) )
		Other.PawnClass = DefaultPlayerClass;

	if(Other.IsA('bot'))
	{
		Other.SetPawnClass("", Level.Game.GetCharacterClass(self));
	}

	return bResult;
}

/* BelongsOnTeam()
returns true if PawnClass is allowed to be on this team
*/
function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	local int i;

	for ( i=0; i<ArrayCount(AllowedTeamMembers); i++ )
		if ( PawnClass == AllowedTeamMembers[i] )
			return true;

	return false;
}

function SetBotOrders(Bot NewBot, RosterEntry R) 
{
    if( AI != None ) // gam
	    AI.SetBotOrders( NewBot, R );
}


function RemoveFromTeam(Controller Other)
{
	Super.RemoveFromTeam(Other);
	if ( AI != None )
		AI.RemoveFromTeam(Other);
}

function UpdateOrders(Bot B, name NewOrders);

function Cleanup();

defaultproperties
{
     DesiredTeamSize=8
     HudTeamColor=(B=255,G=255,R=255,A=255)
}
