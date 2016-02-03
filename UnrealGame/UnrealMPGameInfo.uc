//=============================================================================
// UnrealMPGameInfo.
//
//
//=============================================================================
class UnrealMPGameInfo extends GameInfo
	config;

var globalconfig int  MinPlayers	"PI:Min Players:Bots:0:40:Text;3";		// bots fill in to guarantee this level in net game 
var config bool bTeamScoreRounds	"PI:Team Score Rounds:Rules:0:20:Check";
var bool	bSoaking;
var float EndTime;
var LevelGameRules LevelRules;

// mc - localized PlayInfo descriptions & extra info
var private localized string MPGIPropsDisplayText[2];

function bool ShouldRespawn(Pickup Other)
{
	return false;
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 2;
	if ( Level.NetMode == NM_Standalone )
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	return FRand();
}

function bool TooManyBots(Controller botToRemove) //amb
{
	return ( (Level.NetMode != NM_Standalone) && (NumBots + NumPlayers > MinPlayers) );
}

function LogOut( Controller Exiting )
{
	if ( UnrealPawn(Exiting.Pawn) != None )
		UnrealPawn(Exiting.Pawn).Logout();
	Super.LogOut(Exiting);
}

function RestartGame()
{
	// local Actor A;

	if ( EndTime > Level.TimeSeconds ) // still showing end screen
		return;

    // gam -- disabled for now! Might be causing maplist rotation cocking!
	//if ( RemainingRounds > 0 )
	//{
	//	RemainingRounds--;
	//	ForEach AllActors(class'Actor', A)
	//		A.Reset();
	//	return;
	//}
			
	Super.RestartGame();
}

function ChangeLoadOut(PlayerController P, string LoadoutName);
function ForceAddBot();

/* only allow pickups if they are in the pawns loadout
*/
function bool PickupQuery(Pawn Other, Pickup item)
{
	local byte bAllowPickup;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( (UnrealPawn(Other) != None) && !UnrealPawn(Other).IsInLoadout(item.inventorytype) )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

function InitPlacedBot(Bot B);

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting("Bots",  "MinPlayers",       default.MPGIPropsDisplayText[i++], 0, 40, "Text", "3;0:32");
	PlayInfo.AddSetting("Rules", "bTeamScoreRounds", default.MPGIPropsDisplayText[i++], 0, 20, "Check");
}

defaultproperties
{
     MPGIPropsDisplayText(0)="Min Players"
     MPGIPropsDisplayText(1)="Team Score Rounds"
     SecurityClass=Class'UnrealGame.UnrealSecurity'
     PlayerControllerClassName="UnrealGame.UnrealPlayer"
}
