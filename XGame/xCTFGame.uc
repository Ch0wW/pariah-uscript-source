//=============================================================================
// xCTFGame.
//=============================================================================
class xCTFGame extends CTFGame
    config;
    
function PostBeginPlay()
{
    local xUtil.PlayerRecord PlayerRecord;
    local Array <xUtil.WeaponRecord> WeaponRecords;
    
    Super.PostBeginPlay();
    
	log( "Precaching MP resources..." );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerA");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );

    PlayerRecord = class'xUtil'.static.FindPlayerRecord("TeamPlayerB");
    log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
        	
	class'xUtil'.static.GetWeaponList( WeaponRecords );
}

function PreLoadData()
{
    class'xDeathmatch'.static.PreLoadGameTypeData();
	PreLoad(class'xRedFlag');
	PreLoad(class'xBlueFlag');
}


function ScoreKill(Controller Killer, Controller Other)
{
	if (xPlayer(Killer)!=None)
	  xPlayer(Killer).LogMultiKills();
		
    Super.ScoreKill( Killer, Other );
}


function StartMatch()
{
    Super.StartMatch();
    EvaluateHint('CTFStart', None);
}

function CheckHints(PlayerController PC)
{
    local int t;
    local CTFFlag Flag;

    for (t = 0; t < 2; t++)
    {
        Flag = CTFFlag( TeamGame(Level.Game).Teams[t].Flag );
        if (Flag != None)
        {
            if (IsLookingAt(PC, Flag))
            {
                if (PC.PlayerReplicationInfo.Team.TeamIndex == t)
                {
                    if (Flag.bHome)
                    {
                        EvaluateHint('LookAtMyFlag', Flag);
                    }
                    else if (!Flag.bHeld)
                    {
                        EvaluateHint('LookAtMyDroppedFlag', Flag);
                    }
                }
                else
                {
                    if (Flag.bHome)
                    {
                        EvaluateHint('LookAtEnemyFlag', Flag);
                    }
                }
            }
            else if (IsLookingAt(PC, Flag.HomeBase))
            {
                if (PC.PlayerReplicationInfo.Team.TeamIndex == t)
                {
                    if (!Flag.bHome && PC.PlayerReplicationInfo.HasFlag != None)
                    {
                        EvaluateHint('LookatEmptyFlagBase', Flag.HomeBase);
                    }
                }
            }
        }
    }
}

defaultproperties
{
     CaptureSound(0)=Sound'PariahAnnouncer.red_team_scores'
     CaptureSound(1)=Sound'PariahAnnouncer.blue_team_scores'
     ReturnSounds(0)=Sound'PariahAnnouncer.red_flag_returned'
     ReturnSounds(1)=Sound'PariahAnnouncer.blue_flag_returned'
     DroppedSounds(0)=Sound'PariahAnnouncer.blue_flag_dropped'
     DroppedSounds(1)=Sound'PariahAnnouncer.red_flag_dropped'
     EndGameSound(0)=Sound'PariahAnnouncer.red_team_wins'
     EndGameSound(1)=Sound'PariahAnnouncer.blue_team_wins'
     AltEndGameSound(0)=Sound'PariahAnnouncer.you_have_won_the_game'
     AltEndGameSound(1)=Sound'PariahAnnouncer.you_have_lost_the_game'
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
     MinGoalScore=1
     ListPriority=8
     DeathMessageClass=Class'XGame.xDeathMessage'
     ScoreBoardType="XInterfaceHuds.ScoreBoardCaptureTheFlag"
     HUDType="XInterfaceHuds.HudACaptureTheFlag"
     MapListType="XInterfaceMP.MapListCaptureTheFlag"
     ScreenshotName="PariahMapThumbNails.GameTypes.CaptureTheFlag"
     DecoTextName="XGame.CTFGame"
     Acronym="CTF"
     bNeedPreLoad=True
}
