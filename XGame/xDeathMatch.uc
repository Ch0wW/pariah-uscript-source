//=============================================================================
// xDeathMatch.
//=============================================================================
class xDeathMatch extends DeathMatch
    config;


// amb --- added this to force weaponssounds to be loaded at loadmap time
function PostBeginPlay()
{
    local xUtil.PlayerRecord PlayerRecord;
    local Array <xUtil.WeaponRecord> WeaponRecords;
    
    Super.PostBeginPlay();
    
	log( "Precaching MP resources..." );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("DMPlayerA");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("DMPlayerB");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
        	
	class'xUtil'.static.GetWeaponList( WeaponRecords );
}
// --- amb

static function PreLoadGameTypeData()
{
	Preload(class'BloodJet');
}

function PreLoadData()
{
    class'xDeathmatch'.static.PreLoadGameTypeData();
}

function ScoreKill(Controller Killer, Controller Other)
{
	if (xPlayer(Killer)!=None)
	{
  	 	xPlayer(Killer).LogMultiKills();
	}
	
    Super.ScoreKill( Killer, Other );
}

defaultproperties
{
     EndGameSound(0)=Sound'PariahAnnouncer.you_have_won_the_game'
     EndGameSound(1)=Sound'PariahAnnouncer.you_have_lost_the_game'
     LevelRulesClass=Class'XGame.xLevelGameRules'
     BotNames(0)="Stubbs"
     BotNames(1)="Stockton"
     BotNames(2)="Raphael"
     BotNames(3)="Jahal"
     BotNames(4)="Noah"
     BotNames(5)="Greo"
     BotNames(6)="Mick"
     BotNames(7)="Howie"
     BotNames(8)="Tonklin"
     BotNames(9)="Jones"
     BotNames(10)="Eddy"
     BotNames(11)="Garren"
     BotNames(12)="Mitchel"
     BotNames(13)="Jayton"
     BotNames(14)="Jared"
     BotNames(15)="Aaron"
     BotNames(16)="Lance"
     BotNames(17)="Morgan"
     MinGoalScore=10
     ListPriority=10
     DeathMessageClass=Class'XGame.xDeathMessage'
     ScreenshotName="PariahMapThumbNails.GameTypes.Deathmatch"
     DecoTextName="XGame.Deathmatch"
     Acronym="DM"
     bNeedPreLoad=True
}
